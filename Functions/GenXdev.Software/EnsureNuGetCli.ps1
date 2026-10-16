###############################################################################
<#
.SYNOPSIS
Ensures the NuGet CLI is installed and available.

.DESCRIPTION
This function verifies if the NuGet CLI is installed by checking the PATH and
the WinGet link directory it is installed into. If not found, it installs the
NuGet CLI via winget after obtaining user consent, and returns the full path
to nuget.exe so callers can invoke it directly.

The CLI resolves a NuGet dependency graph and lays a package out next to its
dependencies on its own, so nothing else in the module needs the .NET SDK to
download a package.

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

.PARAMETER AutoConsent
Automatically consent to the NuGet CLI installation and set persistent flag.

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation and set persistent
flag for all packages.

.PARAMETER SessionOnly
Only auto consent during the session.

.EXAMPLE
$nuget = EnsureNuGetCli
& $nuget install Newtonsoft.Json -OutputDirectory .

#>
function EnsureNuGetCli {

    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to the NuGet CLI installation ' +
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
        [switch] $SessionOnly
        #######################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Ensuring the NuGet CLI is available...'

        # locations a winget package lands in: the directory its executables are
        # linked into, and the package directory they are extracted into
        $wingetLinksPath = "${env:LOCALAPPDATA}\Microsoft\WinGet\Links"
        $nugetSymlink = "${wingetLinksPath}\nuget.exe"
        $wingetPackagesPath = "${env:LOCALAPPDATA}\Microsoft\WinGet"

        # resolves the CLI from the PATH, the winget link directory, or the
        # winget package directory it was extracted into
        function ResolveNuGetCli {

            # fastest: already reachable through the PATH
            $nugetCommand = Microsoft.PowerShell.Core\Get-Command 'nuget' `
                -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Utility\Select-Object -First 1

            if ($nugetCommand) {

                Microsoft.PowerShell.Utility\Write-Verbose "Found NuGet CLI on PATH: $($nugetCommand.Source)"
                return $nugetCommand.Source
            }

            # next: the link directory winget creates for a package
            if ([System.IO.File]::Exists($nugetSymlink)) {

                Microsoft.PowerShell.Utility\Write-Verbose "Found NuGet CLI link: ${nugetSymlink}"
                return $nugetSymlink
            }

            # last: the package directory winget extracted it into
            $foundExe = Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $wingetPackagesPath `
                -Filter 'nuget.exe' `
                -Recurse `
                -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Utility\Select-Object -First 1

            if ($foundExe) {

                Microsoft.PowerShell.Utility\Write-Verbose "Found NuGet CLI in the winget package directory: $($foundExe.FullName)"
                return $foundExe.FullName
            }

            return $null
        }

        $nugetExe = ResolveNuGetCli
    }

    process {

        if (-not $nugetExe) {

            Microsoft.PowerShell.Utility\Write-Host 'NuGet CLI not found. Installing NuGet CLI...'

            # request consent before installing the NuGet CLI
            $consentParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Confirm-InstallationConsent'

            $consent = GenXdev\Confirm-InstallationConsent `
                @consentParams `
                -ApplicationName 'NuGet CLI' `
                -Source 'Winget' `
                -Description ('Package manager CLI used to download NuGet packages ' +
                'and their dependencies') `
                -Publisher 'Microsoft'

            if (-not $consent) {
                throw 'NuGet CLI installation was denied by user.'
            }

            # install the NuGet CLI via winget
            Microsoft.PowerShell.Utility\Write-Verbose 'Installing the NuGet CLI via winget...'
            $null = Microsoft.WinGet.Client\Install-WinGetPackage -Id 'Microsoft.NuGet' `
                -MatchOption EqualsCaseInsensitive

            # refresh the PATH so the freshly installed CLI resolves
            $env:Path = [System.Environment]::GetEnvironmentVariable('Path', 'Machine') +
                ';' + [System.Environment]::GetEnvironmentVariable('Path', 'User')

            $nugetExe = ResolveNuGetCli

            if ($nugetExe) {

                Microsoft.PowerShell.Utility\Write-Host 'NuGet CLI installed successfully.'
            }
        }

        Microsoft.PowerShell.Utility\Write-Verbose "NuGet CLI: ${nugetExe}"
    }

    end {

        if (-not $nugetExe) {

            throw 'nuget.exe was not found after installation'
        }

        Microsoft.PowerShell.Utility\Write-Output $nugetExe
    }
}
