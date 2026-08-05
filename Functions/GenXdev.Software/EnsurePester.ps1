###############################################################################
<#
.SYNOPSIS
Ensures Pester testing framework is available for use.

.DESCRIPTION
This function verifies if the Pester module is installed in the current
PowerShell environment. If not found, it automatically installs it from the
PowerShell Gallery and imports it into the current session. This ensures that
Pester testing capabilities are available when needed.

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
EnsurePester
This ensures Pester is installed and ready for use
#>
function EnsurePester {

    [CmdletBinding()]
    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to Pester installation ' +
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

        # inform user that we're checking pester installation
        Microsoft.PowerShell.Utility\Write-Verbose 'Checking for Pester module installation...'
    }


    process {

        # attempt silent import of pester to check if it's available
        Microsoft.PowerShell.Core\Import-Module -Name Pester -ErrorAction SilentlyContinue

        $found = (Microsoft.PowerShell.Core\Get-Module -Name Pester -ErrorAction SilentlyContinue);

        # verify if pester module is now loaded in the current session
        if ((-not $found) -or ($found.Version -lt '6.0.1')) {

            # notify about installation attempt through verbose and regular output
            Microsoft.PowerShell.Utility\Write-Verbose 'Pester module not found, attempting installation...'
            Microsoft.PowerShell.Utility\Write-Host 'Pester not found. Installing Pester...'

            try {
                # confirm installation consent before installing Pester
                $pesterConsent = GenXdev\Confirm-InstallationConsent `
                    -ApplicationName 'Pester' `
                    -Source 'PowerShell Gallery' `
                    -Description 'PowerShell unit testing framework for automated test execution' `
                    -Publisher 'Pester Team' `
                    -AutoConsent:$AutoConsent `
                    -AutoConsentAllPackages:$AutoConsentAllPackages

                if (-not $pesterConsent) {
                    throw 'Installation consent denied for Pester module'
                }

                # install pester module from the powershell gallery
                $null = PowerShellGet\Install-Module -Name Pester `
                    -Force `
                    -SkipPublisherCheck

                # load the newly installed pester module
                $null = Microsoft.PowerShell.Core\Import-Module -Name Pester -Force

                # verify Pester was installed successfully
                $found = Microsoft.PowerShell.Core\Get-Module -Name Pester -ErrorAction SilentlyContinue
                if ((-not $found) -or ($found.Version -lt '6.0.1')) {
                    throw 'Pester installation verification failed — module not loaded after installation.'
                }

                Microsoft.PowerShell.Utility\Write-Host 'Pester installed successfully.'
                Microsoft.PowerShell.Utility\Write-Verbose 'Pester module installation and import completed.'
            }
            catch {
                # report any installation failures
                throw "Failed to install Pester. Error: ${PSItem}"
            }
        }
        else {
            # inform that pester is already available
            Microsoft.PowerShell.Utility\Write-Verbose 'Pester module already installed and imported.'
        }
    }

    end {
    }
}