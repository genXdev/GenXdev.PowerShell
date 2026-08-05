# Don't remove this line [dontrefactor]

###############################################################################
<#
.SYNOPSIS
Sets files to the Windows clipboard for file operations like copy/paste.

.DESCRIPTION
This function copies one or more file paths to the Windows clipboard,
enabling file operations like paste in Windows Explorer. It handles both
STA and MTA threading modes automatically, ensuring compatibility across
different PowerShell execution contexts. The function validates file
existence before adding paths to the clipboard.

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

.PARAMETER InputObject
Array of file paths to add to the clipboard. Accepts pipeline input and
supports various aliases for compatibility with different object properties.

.EXAMPLE
Set-ClipboardFiles -InputObject "C:\temp\file1.txt", "C:\temp\file2.txt"
Sets two files to the clipboard using full parameter names.

.EXAMPLE
"C:\temp\file1.txt", "C:\temp\file2.txt" | Set-ClipboardFiles
Sets files to clipboard using pipeline input.

.EXAMPLE
ls * -file | select -first 5 | Set-ClipboardFiles
Sets files to clipboard using pipeline input, selecting the first 5 files
#>
function Set-ClipboardFiles {

    [CmdletBinding(SupportsShouldProcess)]
    [Alias('setclipfiles', 'scbf')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    param (
        ###################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = ('Array of file paths to add to the clipboard')
        )]
        [Alias('Path', 'FullName', 'ImageFileName', 'FileName')]
        [string[]]$InputObject
        ###################################################################
    )

    begin {

        # initialize array to collect all file paths from pipeline and parameters
        $allFilePaths = @()
    }

    process {

        # collect file paths from pipeline input or direct parameter
        if ($null -ne $InputObject) {
            $allFilePaths += $InputObject
        }
    }

    end {

        # exit early if no file paths collected
        if ($allFilePaths.Count -eq 0) {
            return
        }

        # check if we should proceed with the operation
        if (-not $PSCmdlet.ShouldProcess("$($allFilePaths.Count) file(s)", 'Set to clipboard')) {
            return
        }

        $done = @{}
        # validate each file path and collect only existing files
        $validFilePaths = $allFilePaths |
            Microsoft.PowerShell.Core\ForEach-Object {

                # expand the file path to absolute path
                $path = GenXdev\Expand-Path $_

                if ($done.ContainsKey($path)) {
                    # skip if this path has already been processed
                    return
                }

                # mark this path as processed
                $done[$path] = $true

                # check if file exists and include in collection
                if ([System.IO.File]::Exists($path)) {

                    $path
                    return
                }

                if ([System.IO.Directory]::Exists($path)) {

                    # if it's a directory, return it as well
                    $path
                    return
                }
            }

        # exit if no valid file paths found
        if (($null -eq $validFilePaths) -or
            ($validFilePaths.Count -eq 0)) {

            return
        }

        # get current thread apartment state for clipboard compatibility
        $apartmentState = [System.Threading.Thread]::CurrentThread.GetApartmentState()

        # check if running in single-threaded apartment mode
        if ($apartmentState -eq 'STA') {

            # load the system.windows.forms assembly for clipboard operations
            Microsoft.PowerShell.Utility\Add-Type -AssemblyName System.Windows.Forms

            # create a string collection for the file paths
            $fileCollection = Microsoft.PowerShell.Utility\New-Object `
                System.Collections.Specialized.StringCollection

            # add each valid file path to the collection
            $validFilePaths |
                Microsoft.PowerShell.Core\ForEach-Object {

                    $null = $fileCollection.Add($_)
                }

            # output verbose information about direct clipboard operation
            Microsoft.PowerShell.Utility\Write-Verbose `
            ('Setting clipboard directly in STA mode with ' +
                "$($fileCollection.Count) files")

            # set clipboard directly in sta mode
            [System.Windows.Forms.Clipboard]::SetFileDropList($fileCollection)
        }
        else {

            # output verbose information about sta subprocess requirement
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Current thread is MTA mode, launching STA subprocess ' +
                'for clipboard operation')

            # convert file paths to json for subprocess parameter
            $jsonFilePaths = $validFilePaths | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

            # create a temporary file to store the json data
            $tempFile = GenXdev\Expand-Path ([System.IO.Path]::GetTempFileName()) -DeleteExistingFile -CreateDirectory
            $jsonFilePaths | Microsoft.PowerShell.Utility\Out-File $tempFile

            # define the powershell command to execute in sta mode
            $command = (
                'Microsoft.PowerShell.Utility\Add-Type -AssemblyName System.Windows.Forms;' +
                "`$InputObject = Microsoft.PowerShell.Management\Get-Content -LiteralPath '$tempFile' | " +
                'Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue;' +
                "Microsoft.PowerShell.Management\Remove-Item -LiteralPath '$tempFile' -Force -ErrorAction SilentlyContinue;" +
                "`$fileCollection = Microsoft.PowerShell.Utility\New-Object System.Collections.Specialized.StringCollection;" +
                "`$InputObject | Microsoft.PowerShell.Core\ForEach-Object { `$null = `$fileCollection.Add(`$_) };" +
                "[System.Windows.Forms.Clipboard]::SetFileDropList(`$fileCollection);"
            );

            try {

                # output verbose information about subprocess execution
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Executing STA subprocess for clipboard operation'

                # prepare arguments for powershell subprocess
                $pwshArgs = @(
                    '-STA',
                    '-NoProfile',
                    '-Command',
                    $command
                )

                # start powershell subprocess in sta mode and wait for completion
                Microsoft.PowerShell.Management\Start-Process `
                    -FilePath 'pwsh' `
                    -ArgumentList $pwshArgs `
                    -NoNewWindow `
                    -Wait
            }
            catch {

                # cleanup temp file in case of error
                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $tempFile) {
                    Microsoft.PowerShell.Management\Remove-Item -LiteralPath $tempFile -Force -ErrorAction SilentlyContinue
                }

                # output error if subprocess execution fails
                Microsoft.PowerShell.Utility\Write-Error `
                    "Error invoking pwsh: $_"
            }
        }
    }
}

###############################################################################