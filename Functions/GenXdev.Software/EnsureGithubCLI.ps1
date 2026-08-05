###############################################################################
<#
.SYNOPSIS
Ensures GitHub CLI is properly installed and configured on the system.

.DESCRIPTION
Performs comprehensive checks and setup for GitHub CLI (gh):
- Verifies if GitHub CLI is installed and accessible in PATH
- Installs GitHub CLI via WinGet if not present
- Configures system PATH environment variable
- Installs GitHub Copilot extension
- Sets up GitHub authentication
The function handles all prerequisites and ensures a working GitHub CLI setup.

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
EnsureGithubCLI
This will verify and setup GitHub CLI if needed.
#>
function EnsureGithubCLI {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to GitHub CLI, Git, and ' +
                'WinGet module installation and set persistent flag.')
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
        $githubCliPath = "$env:ProgramFiles\GitHub CLI"
        $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

        if ($currentPath -notlike "*$githubCliPath*") {
            Microsoft.PowerShell.Utility\Write-Verbose 'Adding GitHub CLI to PATH...'
            [Environment]::SetEnvironmentVariable(
                'PATH',
                "$currentPath;$githubCliPath",
                'User')
        }

        # Update current session PATH only if not already present
        if ($env:PATH -notlike "*$githubCliPath*") {
            $env:PATH = "$env:PATH;$githubCliPath"
        }
        $gitCliPath = "$env:ProgramFiles\Git\cmd\git.exe"
        $currentPath = [Environment]::GetEnvironmentVariable('PATH', 'User')

        if ($currentPath -notlike "*$gitCliPath*") {
            Microsoft.PowerShell.Utility\Write-Verbose 'Adding GitHub CLI to PATH...'
            [Environment]::SetEnvironmentVariable(
                'PATH',
                "$currentPath;$gitCliPath",
                'User')
        }

        # Update current session PATH only if not already present
        if ($env:PATH -notlike "*$gitCliPath*") {
            $env:PATH = "$env:PATH;$gitCliPath"
        }
    }


    process {
        try {
            # First check and install Git if needed
            if (@(Microsoft.PowerShell.Core\Get-Command 'git.exe' -ErrorAction SilentlyContinue).Length -eq 0) {

                # verify administrative privileges are available
                if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                    $json = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName "GenXdev\EnsureGithubCLI" |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                    GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsureGithubCLI @params
"@)) -JobDescription 'Install Git and GitHub CLI';

                    if (-not (Microsoft.PowerShell.Core\Get-Command 'git.exe' -ErrorAction SilentlyContinue)) {
                        throw 'Git installation failed: Command not found after installation'
                    }

                    if (-not (Microsoft.PowerShell.Core\Get-Command 'gh.exe' -ErrorAction SilentlyContinue)) {
                        throw 'GitHub CLI installation failed: Command not found after installation'
                    }
                    return;
                }

                Microsoft.PowerShell.Utility\Write-Verbose 'Git not found, installing...'

                # Check user consent before installing Git
                $gitConsent = GenXdev\Confirm-InstallationConsent `
                    -ApplicationName 'Git for Windows' `
                    -Source 'WinGet' `
                    -Description 'Version control system required for GitHub CLI functionality' `
                    -Publisher 'Git for Windows Project' `
                    -AutoConsent:$AutoConsent `
                    -AutoConsentAllPackages:$AutoConsentAllPackages

                if (-not $gitConsent) {
                    throw 'User declined installation of Git for Windows'
                }

                try {
                    $null = Microsoft.WinGet.Client\Install-WinGetPackage -Id 'Git.Git' -Force
                }
                catch {
                    throw "Failed to install Git via WinGet: $_"
                }

                if (-not (Microsoft.PowerShell.Core\Get-Command 'git.exe' -ErrorAction SilentlyContinue)) {
                    throw 'Git installation failed: Command not found after installation'
                }
            }

            # Then proceed with GitHub CLI installation
            if (@(Microsoft.PowerShell.Core\Get-Command 'gh.exe' -ErrorAction SilentlyContinue).Length -eq 0) {
                Microsoft.PowerShell.Utility\Write-Verbose 'GitHub CLI not found in PATH, checking installation...'


                if (@(Microsoft.PowerShell.Core\Get-Command 'gh.exe' -ErrorAction SilentlyContinue).Length -eq 0) {
                    Microsoft.PowerShell.Utility\Write-Verbose 'Installing GitHub CLI...'

                    # Check user consent before installing GitHub CLI
                    $ghConsent = GenXdev\Confirm-InstallationConsent `
                        -ApplicationName 'GitHub CLI' `
                        -Source 'WinGet' `
                        -Description 'Command-line tool for GitHub operations and authentication' `
                        -Publisher 'GitHub' `
                        -AutoConsent:$AutoConsent `
                        -AutoConsentAllPackages:$AutoConsentAllPackages

                    if (-not $ghConsent) {
                        throw 'User declined installation of GitHub CLI'
                    }

                    try {
                        $null = Microsoft.WinGet.Client\Install-WinGetPackage -Id 'GitHub.cli' -Force
                    }
                    catch {
                        throw "Failed to install GitHub CLI via WinGet: $_"
                    }

                    if (-not (Microsoft.PowerShell.Core\Get-Command 'gh.exe' -ErrorAction SilentlyContinue)) {
                        throw 'GitHub CLI installation failed: Command not found after installation'
                    }

                    try {
                        Microsoft.PowerShell.Utility\Write-Verbose 'Initiating GitHub authentication...'
                        $null = gh auth login --web -h github.com
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Error "GitHub authentication failed: $_"
                    }
                }
            }
        }
        catch {
            $errorMessage = "Failed to setup GitHub CLI: $($_.Exception.Message)"
            Microsoft.PowerShell.Utility\Write-Error -Exception $_.Exception -Message $errorMessage -Category OperationStopped
            throw
        }
    }

    end {}
}