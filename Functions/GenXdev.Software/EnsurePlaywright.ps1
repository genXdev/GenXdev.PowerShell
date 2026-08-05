###############################################################################
<#
.SYNOPSIS
Ensures the Playwright .NET assembly and browser binaries are available.

.DESCRIPTION
Internal helper that downloads and loads the Microsoft.Playwright NuGet
assembly and then installs the actual browser binaries (Chromium, Firefox,
WebKit) via Playwright's built-in CLI. Idempotent — skips steps that are
already completed.

Called by Connect-PlaywrightViaDebuggingPort, Open-PlayWrightBrowser,
and explicitly from EnsureGenXdev during environment setup.

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

#>
function EnsurePlaywright {

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]

    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to Playwright browser installation and set persistent flag.'
        )]
        [switch] $AutoConsent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to ALL third-party software installations and set persistent flag for all packages.'
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
        Microsoft.PowerShell.Utility\Write-Verbose 'Ensuring Playwright environment is ready...'

        # track whether browser binaries need to be installed
        $script:needBrowserInstall = $false
    }

    process {


        ########################################################################
        # Step 1: Ensure Microsoft.Playwright .NET assembly is loaded
        ########################################################################

        $assemblyAlreadyLoaded = $null -ne (
            [System.AppDomain]::CurrentDomain.GetAssemblies() |
                Microsoft.PowerShell.Core\Where-Object {
                    $PSItem.GetName().Name -eq 'Microsoft.Playwright'
                }
        )

        if (-not $assemblyAlreadyLoaded) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Microsoft.Playwright assembly not loaded. Downloading via EnsureNuGetAssembly...'
            )

            $ensureParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\EnsureNuGetAssembly'
            $null = GenXdev\EnsureNuGetAssembly @ensureParams -PackageKey 'Microsoft.Playwright' -TypeName 'Microsoft.Playwright.Playwright'

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Microsoft.Playwright assembly loaded successfully.'
            )
            $script:needBrowserInstall = $true
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Microsoft.Playwright assembly already loaded.'
            )
        }

        ########################################################################
        # Step 2: Ensure browser binaries are installed
        ########################################################################

        # determine the Playwright cache directory for browser binaries
        $playwrightCacheDir = Microsoft.PowerShell.Management\Join-Path `
            -Path $env:LOCALAPPDATA `
            -ChildPath 'ms-playwright'

        # check if Chromium binary exists as a proxy for all browsers
        $browsersAlreadyInstalled = $false

        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $playwrightCacheDir) {

            $existingChromium = Microsoft.PowerShell.Management\Get-ChildItem `
                -LiteralPath $playwrightCacheDir `
                -Directory `
                -Filter 'chromium-*' `
                -ErrorAction SilentlyContinue

            if ($existingChromium -and $existingChromium.Count -gt 0) {

                $browsersAlreadyInstalled = $true
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Playwright browser binaries found at: ${playwrightCacheDir}"
                )
            }
        }

        if ((-not $browsersAlreadyInstalled) -or $script:needBrowserInstall) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Installing Playwright browser binaries (Chromium, Firefox, WebKit)...'
            )

            Microsoft.PowerShell.Utility\Write-Verbose (
                'This may take several minutes on first run. Subsequent runs will skip this step.'
            )

            try {

                # invoke Playwright's built-in CLI to download browser binaries
                $exitCode = [Microsoft.Playwright.Program]::Main(@('install'))

                if ($exitCode -ne 0) {

                    Microsoft.PowerShell.Utility\Write-Warning (
                        "Playwright browser installation exited with code ${exitCode}. " +
                        'Some browsers may not be available.'
                    )
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Playwright browser binaries installed successfully.'
                    )
                }

                # verify browser binaries exist on disk
                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $playwrightCacheDir) {
                    $existingChromium = Microsoft.PowerShell.Management\Get-ChildItem `
                        -LiteralPath $playwrightCacheDir `
                        -Directory `
                        -Filter 'chromium-*' `
                        -ErrorAction SilentlyContinue

                    if (-not $existingChromium -or $existingChromium.Count -eq 0) {
                        Microsoft.PowerShell.Utility\Write-Warning (
                            'Playwright browser installation verification — ' +
                            'no Chromium binaries found on disk. ' +
                            'Web automation may not be fully available.'
                        )
                    }
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Warning (
                        'Playwright browser installation verification — ' +
                        'cache directory not found.'
                    )
                }
            }
            catch {

                Microsoft.PowerShell.Utility\Write-Warning (
                    "Failed to install Playwright browser binaries: $($_.Exception.Message)"
                )
            }
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Playwright browser binaries already installed. Skipping download.'
            )
        }
    }

    end {

        Microsoft.PowerShell.Utility\Write-Verbose (
            'Playwright environment check complete.'
        )
    }
}