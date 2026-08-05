###############################################################################
<#
.SYNOPSIS
Ensures 7-Zip is installed and available on the PATH.

.DESCRIPTION
This function verifies if 7-Zip is installed on the system by checking both
the PATH and the default installation location. If not found, it attempts to
install 7-Zip via winget after obtaining user consent. Adds the 7-Zip
directory to the session PATH so that 7z.exe can be invoked directly.

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

.EXAMPLE
Ensure7Zip
7z x -y "-oC:\Output" archive.7z
#>
function Ensure7Zip {

    [CmdletBinding()]
    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to 7-Zip installation ' +
                'and set persistent flag.')
        )]
        [switch] $AutoConsent,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only auto consent during session')
        )]
        [switch]$SessionOnly
        #######################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Ensuring 7-Zip is installed...'

        # default installation directory
        $sevenZipDir = "${env:ProgramFiles}\7-Zip"
        $sevenZipExe = "${sevenZipDir}\7z.exe"


        # add the 7-Zip directory to the session PATH
        if ($env:Path -notlike "*${sevenZipDir}*") {
            $env:Path = "${sevenZipDir};${env:Path}"
            Microsoft.PowerShell.Utility\Write-Verbose "Added 7-Zip directory to PATH: ${sevenZipDir}"
        }
    }

    process {

        # check if 7z is available in PATH
        if ((Microsoft.PowerShell.Core\Get-Command '7z' -ErrorAction SilentlyContinue).Length -eq 0) {

            # try the default installation location
            if (-not [IO.File]::Exists($sevenZipExe)) {

                # verify administrative privileges are available
                if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                    $json = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName "GenXdev\Ensure7Zip" |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                    GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\Ensure7Zip @params
"@)) -JobDescription 'Installing 7-Zip';

                    return;
                }

                # 7-Zip not found — need to install
                Microsoft.PowerShell.Utility\Write-Verbose '7-Zip not found, attempting installation...'
                Microsoft.PowerShell.Utility\Write-Host '7-Zip not found. Installing 7-Zip...'

                try {
                    # request consent before installing 7-Zip
                    $consent = GenXdev\Confirm-InstallationConsent `
                        -ApplicationName '7-Zip' `
                        -Source 'Winget' `
                        -Description ('Archive extraction and compression ' +
                        'utility required for processing archive files') `
                        -Publisher 'Igor Pavlov' `
                        -AutoConsent:$AutoConsent `
                        -AutoConsentAllPackages:$AutoConsentAllPackages

                    if (-not $consent) {
                        throw '7-Zip installation was denied by user.'
                    }

                    # install 7-Zip via winget
                    Microsoft.PowerShell.Utility\Write-Verbose 'Installing 7-Zip via winget...'
                    Microsoft.WinGet.Client\Install-WinGetPackage -Id '7zip.7zip' -MatchOption EqualsCaseInsensitive

                    # verify installation succeeded
                    if (-not [IO.File]::Exists($sevenZipExe)) {

                        throw '7-Zip installation completed but 7z.exe was not found at the expected location.'
                    }

                    Microsoft.PowerShell.Utility\Write-Host '7-Zip installed successfully.'
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Error "Failed to install 7-Zip. Error: $PSItem"
                    throw
                }
            }

        }

        Microsoft.PowerShell.Utility\Write-Verbose '7-Zip is available on PATH.'
    }

    end {
        if ((Microsoft.PowerShell.Core\Get-Command '7z' -ErrorAction SilentlyContinue).Length -eq 0) {

            throw "7z installation failed"
        }
    }
}