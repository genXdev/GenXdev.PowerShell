###############################################################################
<#
.SYNOPSIS
Launches WinMerge to compare two files side by side.

.DESCRIPTION
Launches the WinMerge application to compare source and target files in a side by
side diff view. The function validates the existence of both input files and
ensures WinMerge is properly installed before launching. Provides optional
wait functionality to pause execution until WinMerge closes.

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

.PARAMETER SourcecodeFilePath
Full or relative path to the source file for comparison. The file must exist and
be accessible.

.PARAMETER TargetcodeFilePath
Full or relative path to the target file for comparison. The file must exist and
be accessible.

.PARAMETER Wait
Switch parameter that when specified will cause the function to wait for the
WinMerge application to close before continuing execution.

.EXAMPLE
Invoke-WinMerge -SourcecodeFilePath "C:\source\file1.txt" `
                -TargetcodeFilePath "C:\target\file2.txt" `
                -Wait

.EXAMPLE
merge "C:\source\file1.txt" "C:\target\file2.txt"
#>
function Invoke-WinMerge {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'Path to the source file to compare'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Microsoft.PowerShell.Management\Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]$SourcecodeFilePath,
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'Path to the target file to compare against'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidateScript({ Microsoft.PowerShell.Management\Test-Path -LiteralPath $_ -PathType Leaf })]
        [string]$TargetcodeFilePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Wait for WinMerge to close before continuing'
        )]
        [switch]$Wait,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to this installation type and set persistent flag..')
        )]
        [switch]$AutoConsent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installations. Useful for unattended or CI/CD scenarios.')
        )]
        [switch]$AutoConsentAllPackages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
        ########################################################################
    )


    begin {

        # verify that winmerge is installed and accessible
        Microsoft.PowerShell.Utility\Write-Verbose 'Verifying WinMerge installation status...'
        $ensureParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\EnsureWinMerge'
        GenXdev\EnsureWinMerge @ensureParams


        # convert any relative paths to full paths for reliability
        $sourcePath = GenXdev\Expand-Path $SourcecodeFilePath
        $targetPath = GenXdev\Expand-Path $TargetcodeFilePath


        # log the resolved file paths for troubleshooting
        Microsoft.PowerShell.Utility\Write-Verbose "Resolved source file path: $sourcePath"
        Microsoft.PowerShell.Utility\Write-Verbose "Resolved target file path: $targetPath"
    }



    process {

        # prepare the process start parameters including executable and files
        $processArgs = @{
            FilePath     = 'WinMergeU.exe'
            ArgumentList = $sourcePath, $targetPath
        }


        # add wait parameter if specified to block until winmerge closes
        if ($Wait) {
            $processArgs['Wait'] = $true
            Microsoft.PowerShell.Utility\Write-Verbose 'Will wait for WinMerge process to exit'
        }


        # launch winmerge with the configured parameters
        Microsoft.PowerShell.Utility\Write-Verbose 'Launching WinMerge application...'
        Microsoft.PowerShell.Management\Start-Process @processArgs
    }


    end {
    }
}