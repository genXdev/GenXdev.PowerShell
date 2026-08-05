###############################################################################
<#
.SYNOPSIS
Ensures all GenXdev modules are properly loaded by invoking all Ensure*
cmdlets.

.DESCRIPTION
This function retrieves all GenXdev cmdlets that start with "Ensure" or
"Optimize-Ensure" (for c# cmdlets) and
executes each one to guarantee that all required GenXdev modules and
dependencies are properly loaded and available for use. Any failures during
the execution are caught and displayed as informational messages.

Optionally, it can also download and load all NuGet packages defined in the
packages.json manifest file.

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
Forces the execution of ensure operations even if they appear to be already
completed.

.PARAMETER DownloadAllNugetPackages
Downloads and loads all NuGet packages defined in the packages.json manifest
file.

.PARAMETER AutoConsent
Force a consent prompt even if a preference is already set for third-party
software installation, overriding any saved consent preferences.

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation and set a persistent
preference flag for all packages, bypassing interactive consent prompts.

.EXAMPLE
EnsureGenXdev

This command runs all available Ensure* cmdlets to initialize the GenXdev
environment.

.EXAMPLE
EnsureGenXdev -DownloadAllNugetPackages

This command runs all Ensure* cmdlets and also downloads and loads all NuGet
packages defined in the packages.json manifest file.

.EXAMPLE
EnsureGenXdev -DownloadAllNugetPackages -AutoConsentAllPackages

This command runs all Ensure* cmdlets and downloads NuGet packages.
#>
function EnsureGenXdev {

    [CmdletBinding()]
    # PSScriptAnalyzer rule exception: SideBySide and ShowWindow are used by Get-Variable
    [Diagnostics.CodeAnalysis.SuppressMessage('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        ###########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Forces the execution of ensure operations even if they appear to be already completed"
        )]
        [Switch] $Force,
        ###########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = "Downloads and loads all NuGet packages defined in the packages.json manifest file"
        )]
        [Switch] $DownloadAllNugetPackages,

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to this installation type and set persistent flag..'
        )]
        [switch] $AutoConsent,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to ALL third-party software installations and set persistent flag for all packages.'
        )]
        [switch] $AutoConsentAllPackages,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only auto consent during session')
        )]
        [switch]$SessionOnly
        ###########################################################################
    )

    begin {

        # initialize variables for local scope
        $sideBySide = $true
        $showWindow = $true

        # retrieve all ensure cmdlets from genxdev helpers module
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Retrieving all Ensure* cmdlets from GenXdev.Helpers module'
        )
    }

    process {
        # verify administrative privileges are available
        if (-not (GenXdev\CurrentUserHasElevatedRights)) {

            $json = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev\EnsureGenXdev" |
                Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

            GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsureGenXdev @params
"@)) -PauseAfterCompletion -JobDescription 'Installing all third-party software at once';

            return;
        }

        # ensure vs code installation is available
        try {
            # request consent for VSCode installation using embedded consent
            $vscodeParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Confirm-InstallationConsent' `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            # Set specific parameters for VSCode
            $vscodeParams['ApplicationName'] = 'Visual Studio Code'
            $vscodeParams['Source'] = 'Winget'
            $vscodeParams['Description'] = 'Code editor required for GenXdev development environment'
            $vscodeParams['Publisher'] = 'Microsoft'

            $consent = GenXdev\Confirm-InstallationConsent @vscodeParams

            if (-not $consent) {
                Microsoft.PowerShell.Utility\Write-Warning "VSCode installation consent denied. Some GenXdev features may not be available."
            }
            else {
                $ensureParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\EnsureVSCode'
                GenXdev\EnsureVSCode @ensureParams
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Warning "Failed to check VSCode installation consent: $($_.Exception.Message)"
        }

        # ensure Playwright browser binaries are available
        try {
            $pwParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'EnsurePlaywright' `
                -DefaultValues (
                Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                    -ErrorAction SilentlyContinue
            )

            GenXdev\EnsurePlaywright @pwParams
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Warning "Failed to ensure Playwright browsers: $($_.Exception.Message)"
        }

        # get all ensure cmdlets and execute each one (excluding self to prevent infinite recursion)
        (@(GenXdev\Get-GenXDevCmdlet Ensure*) + @(GenXdev\Get-GenXDevCmdlet Optimize-Ensure*)) |
            Microsoft.PowerShell.Core\ForEach-Object name |
            Microsoft.PowerShell.Core\Where-Object {

                # exclude self and other specific cmdlets to prevent recursion
                (@('EnsureGenXdev', 'EnsureGenXdev').IndexOf($_) -lt 0) -and
                ($_ -ne "EnsureNuGetAssembly") -and
                ($_ -ne "Optimize-EnsureNuGetAssembly")

            } |
            Microsoft.PowerShell.Core\ForEach-Object {

                try {

                    # skip empty or whitespace entries
                    if ([string]::IsNullOrWhiteSpace($_)) { return }

                    # execute the current ensure cmdlet
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Executing cmdlet: $_"
                    )

                    # copy identical parameter values for the target function
                    $params = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName $_ `
                        -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                    # get the command and invoke it with the copied parameters
                    $command = Microsoft.PowerShell.Core\Get-Command -Name $_
                    & $command @params
                }
                catch {

                    # capture and display any execution failures
                    $errorMessage = "Failed to ensure GenXdev module: $_"

                    Microsoft.PowerShell.Utility\Write-Host -Message $errorMessage -ForegroundColor Cyan
                }
            }

        # download all NuGet packages if requested
        if ($DownloadAllNugetPackages) {
            try {
                # request consent for NuGet packages installation using embedded consent
                $nugetParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\Confirm-InstallationConsent' `
                    -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                        -ErrorAction SilentlyContinue
                )

                # Set specific parameters for NuGet packages
                $nugetParams['ApplicationName'] = 'NuGet Packages'
                $nugetParams['Source'] = 'PowerShell Gallery'
                $nugetParams['Description'] = 'Third-party .NET assemblies and libraries for GenXdev functionality'
                $nugetParams['Publisher'] = 'Various'

                $nugetConsent = GenXdev\Confirm-InstallationConsent @nugetParams

                if (-not $nugetConsent) {
                    Microsoft.PowerShell.Utility\Write-Warning "NuGet packages installation consent denied. Some GenXdev features may not be available."
                    return
                }

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Processing all NuGet packages from packages.json'
                )

                # construct path to packages.json in GenXdev.PackageManagement module
                $packagesJsonPath = GenXdev\Expand-Path (
                    "$($MyInvocation.MyCommand.Module.ModuleBase)\packages.json"
                )

                # check if the packages configuration file exists
                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $packagesJsonPath) {
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Loading packages from: $packagesJsonPath"
                    )

                    # load and parse the package configuration
                    $packages = Microsoft.PowerShell.Management\Get-Content -LiteralPath $packagesJsonPath -ErrorAction Stop |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction Stop -AsHashtable

                    # iterate through each package key and ensure it's loaded
                    foreach ($packageKey in $packages.Keys) {
                        try {
                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Ensuring NuGet package: $packageKey"
                            )

                            # ensure the specific nuget assembly is loaded using embedded consent
                            $ensureParams = GenXdev\Copy-IdenticalParamValues `
                                -BoundParameters $PSBoundParameters `
                                -FunctionName 'GenXdev\EnsureNuGetAssembly' `
                                -DefaultValues (
                                Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                                    -ErrorAction SilentlyContinue
                            )

                            $ensureParams['PackageKey'] = $packageKey
                            GenXdev\EnsureNuGetAssembly @ensureParams
                        }
                        catch {
                            # capture and display package loading failures
                            $errorMessage = (
                                "Failed to ensure NuGet package: $packageKey - $($_.Exception.Message)"
                            )
                            Microsoft.PowerShell.Utility\Write-Host -Message $errorMessage -ForegroundColor Cyan
                        }
                    }
                }
                else {
                    # warn when packages configuration is not found
                    Microsoft.PowerShell.Utility\Write-Warning (
                        "packages.json not found at: $packagesJsonPath"
                    )
                }
            }
            catch {
                # capture and display general nuget processing failures
                $errorMessage = "Failed to process NuGet packages: $($_.Exception.Message)"
                Microsoft.PowerShell.Utility\Write-Host -Message $errorMessage -ForegroundColor Cyan
            }
        }

        # define the types of ai queries that require model initialization
        $queryTypes = @(
            'SimpleIntelligence',
            'Knowledge',
            'Pictures',
            'TextTranslation',
            'Coding',
            'ToolUse'
        )
    }

    end {
    }
}
###############################################################################