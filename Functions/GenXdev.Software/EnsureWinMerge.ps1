###############################################################################
<#
.SYNOPSIS
Ensures WinMerge is installed and available for file comparison operations.

.DESCRIPTION
Verifies if WinMerge is installed and properly configured in the system PATH.
If not found, installs WinMerge using WinGet and adds it to the user's PATH.
Handles the complete installation and configuration process automatically.

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
EnsureWinMerge
Ensures WinMerge is installed and properly configured.
#>
function EnsureWinMerge {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to WinMerge and WinGet ' +
                'module installation and set persistent flag.')
        )]
        [switch] $AutoConsent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only auto consent during session')
        )]
        [switch]$SessionOnly
        ########################################################################
    )

    begin {

    }


    process {

        # verify if winmerge is available in current session
        if (@(Microsoft.PowerShell.Core\Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

            # define the standard installation location for winmerge
            $winMergePath = Microsoft.PowerShell.Management\Join-Path $env:LOCALAPPDATA 'Programs\WinMerge'

            # get the current user's path environment variable
            $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

            # ensure winmerge path exists in user's path variable
            if ($currentPath -notlike "*$winMergePath*") {

                Microsoft.PowerShell.Utility\Write-Verbose 'Adding WinMerge to system PATH...'
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$currentPath;$winMergePath",
                    'User')
            }

            # update current session's path only if not already present
            if ($env:PATH -notlike "*$winMergePath*") {
                $env:PATH = "$env:PATH;$winMergePath"
            }


            # check if winmerge is now accessible
            if (@(Microsoft.PowerShell.Core\Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue).Length -gt 0) {
                return
            }

            Microsoft.PowerShell.Utility\Write-Host 'WinMerge not found. Installing WinMerge...'

            # verify administrative privileges are available
            if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                $json = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev\EnsureWinMerge" |
                    Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsureWinMerge @params
"@)) -JobDescription 'Installing WinMerge';

                return;
            }

            # request user consent before installing winmerge
            $consentWinMerge = GenXdev\Confirm-InstallationConsent `
                -ApplicationName 'WinMerge' `
                -Source 'WinGet' `
                -Description 'Visual diff and merge tool for files and folders' `
                -Publisher 'WinMerge Team' `
                -AutoConsent:$AutoConsent `
                -AutoConsentAllPackages:$AutoConsentAllPackages

            if (-not $consentWinMerge) {
                throw 'Installation of WinMerge was denied by user.'
            }

            # install winmerge using winget package manager
            $null = Microsoft.WinGet.Client\Install-WinGetPackage -Id 'WinMerge.WinMerge' -Force
            # define the standard installation location for winmerge
            $winMergePath = Microsoft.PowerShell.Management\Join-Path $env:LOCALAPPDATA 'Programs\WinMerge'
        }
    }

    end {

        # get the current user's path environment variable
        $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

        # ensure winmerge path exists in user's path variable
        if ($currentPath -notlike "*$winMergePath*") {

            Microsoft.PowerShell.Utility\Write-Verbose 'Adding WinMerge to system PATH...'
            [Environment]::SetEnvironmentVariable(
                'PATH',
                "$currentPath;$winMergePath",
                'User')
        }

        # update current session's path only if not already present
        if ($env:PATH -notlike "*$winMergePath*") {
            $env:PATH = "$env:PATH;$winMergePath"
        }

        # verify successful installation
        if (-not (Microsoft.PowerShell.Core\Get-Command 'WinMergeU.exe' -ErrorAction SilentlyContinue)) {
            throw 'WinMerge installation failed.'
        }
    }
}