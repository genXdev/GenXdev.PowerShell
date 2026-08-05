###############################################################################
<#
.SYNOPSIS
Ensures SSMS is installed and accessible from the command line.

.DESCRIPTION
Verifies if SSMS is installed and available in the system PATH. If not
found, it first checks if the PATH environment variable needs updating. If that
doesn't resolve the issue, it installs SSMS using WinGet and configures
the PATH environment variable.

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
EnsureSSMSInstalled
Checks and ensures SSMS is installed and accessible.
#>
function EnsureSSMSInstalled {

    [CmdletBinding()]
    param(
        [switch] $Force,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to SSMS installation ' +
                'and set persistent flag.')
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

        $searchPath = GenXdev\Find-Item `
            "${Env:ProgramFiles(x86)}\*SQL Server Management*\Ssms.exe",
        "${Env:ProgramFiles}\*SQL Server Management*\Ssms.exe" |
            Microsoft.PowerShell.Utility\Sort-Object LastWriteTime -Descending | Microsoft.PowerShell.Utility\Select-Object -First 1

        if ($Force -or -not $searchPath) {

            # verify administrative privileges are available
            if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                $json = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev\EnsureSSMSInstalled" |
                    Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsureSSMSInstalled @params
"@)) -JobDescription 'Installing SQL Server Management Studio';

                return;
            }

            $consent = GenXdev\Confirm-InstallationConsent `
                -ApplicationName 'SQL Server Management Studio 22 Preview' `
                -Source 'Winget' `
                -Description 'Required for SQL Server database management and administration' `
                -Publisher 'Microsoft' `
                -AutoConsent:$AutoConsent `
                -AutoConsentAllPackages:$AutoConsentAllPackages

            if (-not $consent) {
                throw "Installation consent denied for SQL Server Management Studio. Cannot proceed with SSMS installation."
            }

            Microsoft.WinGet.Client\Install-WinGetPackage -Id "Microsoft.SQLServerManagementStudio.22.Preview"
        }
    }


    process {

    }

    end {

        $searchPath = GenXdev\Find-Item  `
            "${Env:ProgramFiles(x86)}\*SQL Server Management*\Ssms.exe",
        "${Env:ProgramFiles}\*SQL Server Management*\Ssms.exe" |
            Microsoft.PowerShell.Utility\Sort-Object LastWriteTime -Descending | Microsoft.PowerShell.Utility\Select-Object -First 1

        if (-not $searchPath) {
            Throw "SSMS not found after installation attempt."
        }
    }
}