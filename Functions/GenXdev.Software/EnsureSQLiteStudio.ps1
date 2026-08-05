###############################################################################
<#
.SYNOPSIS
Ensures SQLiteStudio is installed and accessible from the command line.

.DESCRIPTION
Verifies if SQLiteStudio is installed and available in the system PATH. If not
found, it first checks if the PATH environment variable needs updating. If that
doesn't resolve the issue, it installs SQLiteStudio using WinGet and configures
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
EnsureSQLiteStudio
Checks and ensures SQLiteStudio is installed and accessible.
#>
function EnsureSQLiteStudio {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to SQLiteStudio and WinGet ' +
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

        # check if sqlitestudio executable is available in the system path
        if (@(Microsoft.PowerShell.Core\Get-Command 'SQLiteStudio.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

            # determine the default installation directory for sqlitestudio
            $sqliteStudioPath = (GenXdev\Expand-Path "${env:ProgramFiles}\SQLiteStudio")

            # get current user path environment variable
            $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

            # add sqlitestudio to path if not already present
            if ($currentPath -notlike "*$sqliteStudioPath*") {

                Microsoft.PowerShell.Utility\Write-Verbose 'Adding SQLiteStudio directory to user PATH...'
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$currentPath;$sqliteStudioPath",
                    'User')
            }

            # ensure current session has updated path only if not already present
            if ($env:PATH -notlike "*$sqliteStudioPath*") {
                $env:PATH = "$env:PATH;$sqliteStudioPath"
            }

            # verify if path update resolved the missing executable
            if (@(Microsoft.PowerShell.Core\Get-Command 'SQLiteStudio.exe' -ErrorAction SilentlyContinue).Length -gt 0) {

                return
            }

            # verify administrative privileges are available
            if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                $json = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev\EnsureSQLiteStudio" |
                    Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsureSQLiteStudio @params
"@)) -JobDescription 'Installing SQLiteStudio';

                return;
            }

            Microsoft.PowerShell.Utility\Write-Host 'SQLiteStudio not found. Installing SQLiteStudio...'

            # Request consent before installing SQLiteStudio
            $consent = GenXdev\Confirm-InstallationConsent `
                -ApplicationName 'SQLiteStudio' `
                -Source 'Winget' `
                -Description 'Database management tool required for SQLite operations' `
                -Publisher 'Pawel Salawa' `
                -AutoConsent:$AutoConsent `
                -AutoConsentAllPackages:$AutoConsentAllPackages

            if (-not $consent) {
                Microsoft.PowerShell.Utility\Write-Error 'Installation consent denied for SQLiteStudio. SQLite operations may not be available.'
                return
            }

            # attempt installation using winget
            Microsoft.PowerShell.Utility\Write-Verbose 'Installing SQLiteStudio using WinGet...'
            Microsoft.WinGet.Client\Install-WinGetPackage -Id 'PawelSalawa.SQLiteStudio' -Force
        }
    }

    end {
        if (-not (Microsoft.PowerShell.Core\Get-Command 'SQLiteStudio.exe' -ErrorAction SilentlyContinue)) {
                throw 'SQLiteStudio installation verification failed — executable not found after installation.'
            }
    }
}