###############################################################################
<#
.SYNOPSIS
Ensures Sysinternals tools (PSTools) are installed and available.

.DESCRIPTION
Verifies if Sysinternals tools like handle.exe are installed and properly
configured on the system. If not found, installs the Sysinternals Suite
using WinGet, pre-accepts all End-User License Agreements (EULAs) via
registry keys, and handles the complete installation process automatically.

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

.PARAMETER Force
Switch to force reinstallation of Sysinternals tools even if they are already
installed.

.PARAMETER PSExeName
The executable name to check for verifying Sysinternals tools installation.
Default is 'handle.exe'.

.EXAMPLE
EnsurePSTools
Ensures Sysinternals tools are installed and properly configured.

.EXAMPLE
EnsurePSTools -Force -PSExeName 'procexp.exe'
Forces reinstallation of Sysinternals tools and uses procexp.exe to verify
installation.
###############################################################################>
function EnsurePSTools {

    [CmdletBinding()]
    param(
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Force reinstallation of Sysinternals tools'
        )]
        [switch]$Force,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to Sysinternals tools and ' +
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

        $Extra = ";($ENV:LOCALAPPDATA)\Microsoft\WinGet\Links\";
        $ENV:PATH = "$($ENV:PATH)".Replace($Extra, "") + $Extra
    }

    process {

        # check if we should install/reinstall based on force flag or missing executable
        if ($Force -or (@(Microsoft.PowerShell.Core\Get-Command procexp.exe `
                        -ErrorAction SilentlyContinue).Length -eq 0)) {

            # verify administrative privileges are available
            if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                $json = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev\EnsurePSTools" |
                    Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsurePSTools @params
"@)) -JobDescription 'Installing Sysinternals tools';

                # verify installation succeeded unless force was specified
                if (-not $Force -and (-not (Microsoft.PowerShell.Core\Get-Command "procexp" `
                                -ErrorAction SilentlyContinue))) {
                    throw "Sysinternals installation failed."
                }
                return;
            }

            # request consent before installing sysinternals packages
            $sysinternalsConsent = GenXdev\Confirm-InstallationConsent `
                -ApplicationName 'Microsoft Sysinternals Suite' `
                -Source 'WinGet' `
                -Description ('System administration and diagnostic tools. ' +
                'By consenting, you accept all End-User License ' +
                'Agreements (EULAs) for all Sysinternals tools in one go.') `
                -Publisher 'Microsoft' `
                -AutoConsent:$AutoConsent `
                -AutoConsentAllPackages:$AutoConsentAllPackages

            if (-not $sysinternalsConsent) {
                throw 'Installation consent denied for Microsoft Sysinternals Suite. Cannot proceed without system tools.'
            }

            # inform user about installation process starting
            Microsoft.PowerShell.Utility\Write-Host 'Installing Sysinternals packages...'

            # install the package with force to ensure success
            $null = Microsoft.WinGet.Client\Install-WinGetPackage -Id 'Microsoft.Sysinternals.Suite' -Force -MatchOption EqualsCaseInsensitive

            # verify installation succeeded unless force was specified
            if (-not $Force -and (-not (Microsoft.PowerShell.Core\Get-Command "procexp" `
                            -ErrorAction SilentlyContinue))) {
                throw "Sysinternals installation failed."
            }

            # pre-accept all Sysinternals EULAs by creating registry keys
            # for each tool in the installation directory
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Accepting Sysinternals EULAs via registry keys...')

            $procexpSource = (Microsoft.PowerShell.Core\Get-Command `
                    procexp.exe -ErrorAction SilentlyContinue).Source

            if ($procexpSource) {
                $installDir = Microsoft.PowerShell.Management\Split-Path `
                    -Parent (Microsoft.PowerShell.Management\Get-Item `
                        $procexpSource).Target

                # get unique tools by grouping 32/64-bit variants
                $tools = Microsoft.PowerShell.Management\Get-ChildItem `
                    $installDir -Filter *.exe |
                    Microsoft.PowerShell.Core\Where-Object {
                        $_.BaseName -notmatch '64$' -and
                        $_.BaseName -notmatch '-x86$'
                    }

                foreach ($tool in $tools) {
                    $productName = $tool.VersionInfo.ProductName
                    $keyName = if ($productName) {
                        $productName -replace '^Sysinternals\s+', '' `
                            -replace '^SysInternals\s+', ''
                    }
                    else {
                        $tool.BaseName
                    }

                    if (-not $keyName) { $keyName = $tool.BaseName }

                    $regPath = "HKCU:\SOFTWARE\Sysinternals\${keyName}"

                    if (-not (Microsoft.PowerShell.Management\Test-Path `
                                $regPath)) {
                        $null = Microsoft.PowerShell.Management\New-Item `
                            -Path $regPath -Force
                        $null = Microsoft.PowerShell.Management\New-ItemProperty `
                            -Path $regPath `
                            -Name 'EulaAccepted' `
                            -Value 1 `
                            -PropertyType DWord `
                            -Force
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "  Accepted EULA for: ${keyName}")
                    }
                }
            }
        }

        # log successful completion of the function
        Microsoft.PowerShell.Utility\Write-Verbose '✅ Sysinternals tools are ready.'
    }

    end {
    }
}