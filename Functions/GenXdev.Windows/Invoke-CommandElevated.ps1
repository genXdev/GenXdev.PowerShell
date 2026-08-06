<#
.SYNOPSIS
Runs code in an elevated PowerShell session, streaming output back to the original terminal.

.DESCRIPTION
Ensures a scriptblock is executed in an elevated (admin) session using a proper user-experience.
After the scriptblock has completed, the environment variables are updated to reflect any changes made in the elevated session.
In contrast to other Environment variables, the directories in $ENV:PATH is merged.

.LICENSE
Copyright (C) 2026 René Vaessen / GenXdev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>.

.PARAMETER ScriptBlock
Scriptblock to execute in elevated session

.PARAMETER JobDescription
Description of the job to be displayed in the window title

.PARAMETER PauseAfterCompletion
Optionally pauses after the scriptblock has completed

.PARAMETER DontUpdateEnvironment
Optionally skips updating the environment after the elevated session has completed.

.EXAMPLE
Invoke-CommandElevated { sfc /scannow } -PauseAfterCompletion
#>
function Invoke-CommandElevated {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "Scriptblock to execute in elevated session")]
        [ScriptBlock] $ScriptBlock,

        [Parameter(Mandatory = $false, Position = 1, HelpMessage = "Description of the job to be displayed in the window title")]
        [String] $JobDescription = "Launching elevated session",

        [Parameter(Mandatory = $false, HelpMessage = "Optionally pauses after the scriptblock has completed")]
        [Switch] $PauseAfterCompletion,

        [Parameter(Mandatory = $false, HelpMessage = "Optionally skips updating the environment after the elevated session has completed.")]
        [Switch] $DontUpdateEnvironment
    )

    $JobDescriptionEscaped = "$JobDescription".Replace('"', '`"');

    if (GenXdev\CurrentUserHasElevatedRights) {
        Microsoft.PowerShell.Core\Invoke-Command -ScriptBlock $ScriptBlock
        return
    }

    1..25 | Microsoft.PowerShell.Core\ForEach-Object {

        Microsoft.PowerShell.Utility\Write-Progress -Id 11232 -Activity "$JobDescription" -Status "Prepare for upcoming UAC prompt.." -PercentComplete $_
        Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 80
    }

    [System.Diagnostics.Process] $process;
    try {
        $CurrentWindow = GenXdev\Get-PowershellMainWindow

        $command = @"
        `$ErrorOccurred = `$false;
        `$Host.UI.RawUI.WindowTitle = "$JobDescriptionEscaped"
Import-Module -Name GenXdev -Version '3.34.0';
GenXdev\Set-WindowPosition -X $($CurrentWindow.Left) -Y $($CurrentWindow.Top) -Width $($CurrentWindow.Width) -Height $($CurrentWindow.Height) -SetRestored -SetForeground;
GenXdev\Set-WindowPosition -Process (Get-Process -Pid `$PID) -X $($CurrentWindow.Left) -Y $($CurrentWindow.Top) -Width $($CurrentWindow.Width) -Height $($CurrentWindow.Height) -SetRestored -SetForeground;
try {
    1..10 | % {
        Write-Progress -Id 11233 -Activity "$JobDescriptionEscaped" -Status "Executing elevated command.." -PercentComplete (`$_ * 10)
        Start-Sleep -Milliseconds 200
    }
    Write-Progress -Id 11233 -PercentComplete 100 -Completed
    Write-Host "--------------------" -foregroundcolor Cyan;
    Write-Host "$JobDescriptionEscaped" -foregroundcolor Yellow;
    Write-Host "--------------------" -foregroundcolor Cyan;

    $ScriptBlock

    Write-Host "--------------------" -foregroundcolor Cyan;

    $(($true -eq $PauseAfterCompletion) ? 'Pause' : '')
}
catch {
    `$ErrorOccurred = `$true;
    Write-Progress -Id 11233 -Activity "$JobDescriptionEscaped" -Status "Error occured!" -PercentComplete 100 -Completed
    Write-Host "--------------------" -foregroundcolor Cyan;
    GenXdev\Show-ExceptionPanel `$PSItem.Exception
    Write-Host "--------------------" -foregroundcolor Cyan;
    Pause
}
finally {
    1..10 | % {
        Write-Progress -Id 11233 -Activity "$JobDescriptionEscaped" -Status "Returning to previous session" -PercentComplete (`$_ * 10)
        Start-Sleep -Milliseconds 200
    }

    Write-Progress -Id 11233 -Activity "$JobDescriptionEscaped" -Status "Returning to previous session" -PercentComplete 100 -Completed

    Exit (`$ErrorOccurred ? 1 : 0)
}
"@;

        Microsoft.PowerShell.Utility\Write-Verbose "Elevating command: $command"

        $encodedCommand = [Convert]::ToBase64String([System.Text.Encoding]::Unicode.GetBytes($command));

        $arguments = @(
            "-NoProfile",
            "-NoLogo",
            "-MTA",
            "-EncodedCommand",
            $encodedCommand
        );

        $process = Microsoft.PowerShell.Management\Start-Process `
            -FilePath (Microsoft.PowerShell.Management\Get-Process -Pid $PID).Path `
            -ArgumentList $arguments `
            -WorkingDirectory $PWD.Path `
            -WindowStyle Minimized `
            -Verb "RunAs" `
            -PassThru;

        if (-not $process) {

            throw "User cancelled"
        }

        Microsoft.PowerShell.Utility\Write-Progress -Id 11232 -Activity "$JobDescription" -Status "Loading PowerShell modules.." -PercentComplete 25
    }
    catch {

        Microsoft.PowerShell.Utility\Write-Progress -Id 11232 -PercentComplete 100 -Completed
        throw "User cancelled"
    }

    $i = 25;
    while (-not $process.HasExited) {

        Microsoft.PowerShell.Utility\Write-Progress -Id 11232 -Activity "$JobDescription" -Status "Loading PowerShell modules.." -PercentComplete ([Math]::Min(75, $i++))

        Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 250
    }

    $errorOccurred = $process.ExitCode -ne 0
    if ($errorOccurred) {

        75..100 | Microsoft.PowerShell.Core\ForEach-Object {

            Microsoft.PowerShell.Utility\Write-Progress -Id 11232 -Activity "$JobDescription" -Status ($errorOccurred ? "Completed with error!" : "Completed") -PercentComplete $_
            Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 80
        }
    }

    Microsoft.PowerShell.Utility\Write-Progress -Id 11232 -PercentComplete 100 -Completed

    if (-not $DontUpdateEnvironment) {

        GenXdev\Update-Environment
    }

    GenXdev\Set-WindowPosition -SetForeground -RestoreFocus
}