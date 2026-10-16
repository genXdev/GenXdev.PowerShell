###############################################################################
<#
.SYNOPSIS
Downloads and loads .NET assemblies from NuGet packages based on package key or ID.

.DESCRIPTION
This function ensures that the specified NuGet package assemblies are downloaded
and loaded into the current PowerShell session. It supports automatic detection
and loading with fallback to a JSON manifest for configuration overrides,
handling edge cases like stub dependencies (e.g., SQLite). Installation uses
the NuGet CLI, which resolves the dependency graph and lays each package out
next to its dependencies in the destination, from where the assemblies are then
loaded. Lazy loading checks if the type is already available before proceeding.

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

.PARAMETER PackageKey
The unique identifier for the package, either a key from the packages.json
manifest or the direct NuGet PackageId.

.PARAMETER ManifestPath
Optional path to the packages.json manifest. Defaults to module root if omitted.

.PARAMETER Version
Optional specific version to install and load. If omitted, uses highest from
JSON or latest from NuGet.

.PARAMETER TypeName
Optional .NET type name to verify after loading (e.g., 'Microsoft.Data.Sqlite.SQLiteConnection').

.PARAMETER ForceLatest
Switch to fallback to latest version if specified version fails.

.PARAMETER Destination
Optional custom destination path for package installation. Defaults to persistent local or global cache.

.PARAMETER Description
Optional description of the software and its purpose for consent prompts. If not provided, a default description is used.

.PARAMETER Publisher
Optional publisher or vendor of the software for consent prompts. If not provided, attempts to read from packages.json or uses default.

.PARAMETER AutoConsent
Force a consent prompt even if a preference is already set for the package.

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation and set a persistent preference flag, bypassing interactive prompts.

.EXAMPLE
EnsureNuGetAssembly -PackageKey "Microsoft.Data.Sqlite.Core"

.EXAMPLE
EnsureNuGetAssembly -PackageKey "Microsoft.Playwright" -Version "1.54.0" -TypeName "Microsoft.Playwright.Playwright"

.EXAMPLE
EnsureNuGetAssembly -PackageKey "Microsoft.Data.Sqlite.Core" -AutoConsentAllPackages
#>
function EnsureNuGetAssembly {

    [CmdletBinding()]

    param(
        [Parameter(Mandatory = $true, Position = 0,
            HelpMessage = "Package key from packages.json or direct NuGet PackageId.")]
        [string] $PackageKey,

        [Parameter(Mandatory = $false,
            HelpMessage = "Path to packages.json; defaults to module root if omitted.")]
        [string] $ManifestPath,

        [Parameter(Mandatory = $false,
            HelpMessage = "Specific version; if omitted, use highest from JSON or latest.")]
        [string] $Version,

        [Parameter(Mandatory = $false,
            HelpMessage = "TypeName to verify loading.")]
        [string] $TypeName,

        [Parameter(Mandatory = $false,
            HelpMessage = "Fallback to latest if exact version fails.")]
        [switch] $ForceLatest,

        [Parameter(Mandatory = $false,
            HelpMessage = "Custom install destination; defaults to local persistent or global cache.")]
        [string] $Destination,

        ###############################################################################
        [Parameter(Mandatory = $false,
            HelpMessage = "Optional description of the software and its purpose for consent.")]
        [string] $Description,

        ###############################################################################
        [Parameter(Mandatory = $false,
            HelpMessage = "Optional publisher or vendor of the software for consent.")]
        [string] $Publisher,

        ###############################################################################
        [Parameter(Mandatory = $false,
            HelpMessage = "Force a prompt even if preference is set for consent.")]
        [switch] $AutoConsent,
        ###############################################################################
        [Parameter(Mandatory = $false,
            HelpMessage = "Automatically consent to ALL third-party software installations and set persistent flag.")]
        [switch] $AutoConsentAllPackages,
        ###############################################################################
        [Parameter(Mandatory = $false,
            HelpMessage = ('Only auto consent during session'))]
        [switch] $SessionOnly
        ###############################################################################
    )
    begin {
        # Lazy check if type already loaded
        if ($TypeName -and ($TypeName -as [type])) {
            return
        }

        # Fully qualified cmdlet usage for explicitness
        Microsoft.PowerShell.Utility\Write-Verbose "Starting EnsureNuGetAssembly for ${PackageKey}"

        # Preferred TFMs for .NET 9+ (PowerShell 7.5+)
        $frameworkPreference = @(
            'net10.0', 'net9.0', 'net8.0', 'net7.0', 'net6.0',
            'netstandard2.1', 'netstandard2.0'
        )

        # Add older fallbacks from old function
        $frameworkFallback = @(
            'netcoreapp3.1', 'net461', 'net46',
            'net451', 'net45'
        )

        # Module root using custom helper
        $moduleRoot = GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\"

        # Default manifest path if not provided
        if (-not $ManifestPath) {
            $ManifestPath = Microsoft.PowerShell.Management\Join-Path $moduleRoot 'packages.json'
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Using manifest path: ${ManifestPath}"

        # Default destination: persistent local as in old
        if (-not $Destination) {
            $Destination = Microsoft.PowerShell.Management\Join-Path $env:LOCALAPPDATA 'GenXdev\NuGetPackages'
            Microsoft.PowerShell.Utility\Write-Verbose "Creating default destination directory: ${Destination}"
            $null = Microsoft.PowerShell.Management\New-Item -Path $Destination -ItemType Directory -Force
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "Using provided destination: ${Destination}"
        }

        # Load JSON if exists
        $packages = $null
        $pkgConfig = $null
        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $ManifestPath) {
            Microsoft.PowerShell.Utility\Write-Verbose "Manifest file exists; loading content from ${ManifestPath}"
            try {
                $packages = Microsoft.PowerShell.Management\Get-Content -LiteralPath $ManifestPath |
                    Microsoft.PowerShell.Utility\ConvertFrom-Json -AsHashtable
                Microsoft.PowerShell.Utility\Write-Verbose "Successfully parsed manifest JSON"
            }
            catch {
                throw "Failed to parse manifest at ${ManifestPath}: $($_.Exception.Message)"
            }

            # Find config by key or PackageId
            $actualKey = $PackageKey
            if ($packages.ContainsKey($PackageKey)) {
                $pkgConfig = $packages[$PackageKey]
            }
            else {
                foreach ($key in $packages.Keys) {
                    if ($packages[$key].PackageId -eq $PackageKey) {
                        $actualKey = $key
                        $pkgConfig = $packages[$key]
                        break
                    }
                }
            }

            if ($pkgConfig) {
                Microsoft.PowerShell.Utility\Write-Verbose "Found JSON config for ${actualKey}"
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose "No JSON config found for ${PackageKey}; treating as direct PackageId"
            }
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "Manifest path does not exist: ${ManifestPath}; proceeding without JSON config"
        }

        # Determine PackageId
        $PackageId = if ($pkgConfig -and $pkgConfig.PackageId) {
            $pkgConfig.PackageId
        }
        else {
            $PackageKey
        }
        Microsoft.PowerShell.Utility\Write-Verbose "Determined PackageId: ${PackageId}"

        # Version determination
        if (-not $Version) {
            if ($pkgConfig -and $pkgConfig.Versions) {
                # Use highest version from JSON
                $Version = ($pkgConfig.Versions.Keys | Microsoft.PowerShell.Utility\Sort-Object -Descending) |
                    Microsoft.PowerShell.Utility\Select-Object -First 1
                Microsoft.PowerShell.Utility\Write-Verbose "Using highest JSON version: ${Version}"
            }
            elseif ($pkgConfig -and $pkgConfig.Version) {
                $Version = $pkgConfig.Version
                Microsoft.PowerShell.Utility\Write-Verbose "Using JSON version: ${Version}"
            }
            elseif ($pkgConfig -and $pkgConfig.DefaultVersion) {
                $Version = $pkgConfig.DefaultVersion
                Microsoft.PowerShell.Utility\Write-Verbose "Using JSON default version: ${Version}"
            }
            else {
                # The NuGet CLI resolves the newest version itself, so there is nothing
                # to probe here - a probe would cost a network round trip per invocation
                $Version = "latest"
                Microsoft.PowerShell.Utility\Write-Verbose "No version declared for ${PackageKey}; the NuGet CLI will resolve the latest"
            }
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "Using provided version: ${Version}"
        }

        # Version-specific config from JSON
        $versionConfig = if ($pkgConfig -and $pkgConfig.Versions -and $Version -and $pkgConfig.Versions.ContainsKey($Version)) {
            $pkgConfig.Versions[$Version]
        }
        else {
            $pkgConfig
        }
        Microsoft.PowerShell.Utility\Write-Verbose "Version-specific config loaded (if any)"

        # Assemblies from JSON or default
        $Assemblies = if ($versionConfig -and $versionConfig.Assemblies) {
            $versionConfig.Assemblies
        }
        else {
            @("$PackageId.dll")
        }
        Microsoft.PowerShell.Utility\Write-Verbose "Assemblies to load: $($Assemblies -join ', ')"

        # Native copy from JSON
        $nativeCopy = if ($versionConfig -and $versionConfig.NativeCopy) {
            $versionConfig.NativeCopy
        }
        if ($nativeCopy) {
            Microsoft.PowerShell.Utility\Write-Verbose "Native copy config found: From $($nativeCopy.From) to $($nativeCopy.To)"
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "No native copy config"
        }

        # RID for natives
        $rid = [System.Runtime.InteropServices.RuntimeInformation]::RuntimeIdentifier
        Microsoft.PowerShell.Utility\Write-Verbose "Runtime Identifier (RID): ${rid}"

        # TLS fix for retries
        Microsoft.PowerShell.Utility\Write-Verbose "Setting SecurityProtocol to Tls12"
        [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12



        # the NuGet CLI resolves and downloads a package, so the .NET SDK is not needed
        Microsoft.PowerShell.Utility\Write-Verbose "Ensuring the NuGet CLI is available"

        $nugetParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\EnsureNuGetCli' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        $nugetExe = GenXdev\EnsureNuGetCli @nugetParams

        Microsoft.PowerShell.Utility\Write-Verbose "NuGet CLI available at ${nugetExe}"

        # Loaded tracking as in old
        $loadedAssemblies = @()
    }
    process {
        # Lazy check if type already loaded
        if ($TypeName -and ($TypeName -as [type])) {
            Microsoft.PowerShell.Utility\Write-Verbose "${TypeName} already loaded; skipping"
            return
        }
        try {
            # Package dir - use local destination, not global cache
            $packageLower = $PackageId.ToLower()

            # Find existing package installation (if any) when version is "latest"
            $pkgDir = $null
            $installed = $false

            if ($Version -eq "latest") {
                # Look for existing main package first, then fallback to any related package
                $mainPkgs = Microsoft.PowerShell.Management\Get-ChildItem $Destination -Directory |
                    Microsoft.PowerShell.Core\Where-Object { $_.Name -match "^${packageLower}\.\d+(\.\d+)*(\.\d+)*$" } |
                    Microsoft.PowerShell.Utility\Sort-Object Name -Descending

                if ($mainPkgs) {
                    $pkgDir = $mainPkgs[0].FullName
                    Microsoft.PowerShell.Utility\Write-Verbose "Found existing main package: ${pkgDir}"
                }
                else {
                    # Fallback to any related package
                    $existingPkgs = Microsoft.PowerShell.Management\Get-ChildItem $Destination -Directory |
                        Microsoft.PowerShell.Core\Where-Object { $_.Name -like "${packageLower}.*" } |
                        Microsoft.PowerShell.Utility\Sort-Object Name -Descending

                    if ($existingPkgs) {
                        $pkgDir = $existingPkgs[0].FullName
                        Microsoft.PowerShell.Utility\Write-Verbose "Found existing related package: ${pkgDir}"
                    }
                }
            }
            else {
                # Use specific version directory
                $pkgDir = Microsoft.PowerShell.Management\Join-Path $Destination "$packageLower.$Version"
            }

            if (-not $pkgDir) {
                $pkgDir = Microsoft.PowerShell.Management\Join-Path $Destination "$packageLower.$Version"
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Package directory (local destination): ${pkgDir}"

            # Check if properly installed with validation
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $pkgDir) {
                Microsoft.PowerShell.Utility\Write-Verbose "Package directory exists at ${pkgDir}, validating completeness..."

                # For stub-based packages like SQLite, check if assemblies can be found and loaded
                # rather than checking if they exist in the main package directory
                $allAssembliesFound = $true
                $deps = Microsoft.PowerShell.Management\Get-ChildItem $Destination -Directory -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Core\Where-Object { $_.Name -match '\.[\d\.]+$' }
                if (-not $deps) { $deps = @() }

                foreach ($asm in $Assemblies) {
                    $found = $false

                    # Check main package
                    $directPath = Microsoft.PowerShell.Management\Join-Path $pkgDir $asm
                    if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $directPath) {
                        $found = $true
                        continue
                    }

                    # Check in lib subdirectories of main package
                    $libDir = Microsoft.PowerShell.Management\Join-Path $pkgDir "lib"
                    if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $libDir) {
                        $libSubDirs = Microsoft.PowerShell.Management\Get-ChildItem $libDir -Directory -ErrorAction SilentlyContinue
                        foreach ($subDir in $libSubDirs) {
                            $asmPath = Microsoft.PowerShell.Management\Join-Path $subDir.FullName $asm
                            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $asmPath) {
                                $found = $true
                                break
                            }
                        }
                    }

                    # Check in dependencies/stub packages
                    if (-not $found) {
                        foreach ($dep in $deps) {
                            $depAsm = Microsoft.PowerShell.Management\Get-ChildItem $dep.FullName -Recurse -Filter $asm.Split('/')[-1] -ErrorAction SilentlyContinue |
                                Microsoft.PowerShell.Utility\Select-Object -First 1
                            if ($depAsm) {
                                $found = $true
                                Microsoft.PowerShell.Utility\Write-Verbose "Assembly ${asm} found in dependency ${dep.Name}"
                                break
                            }
                        }
                    }

                    if (-not $found) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Assembly ${asm} not found in package or dependencies"
                        $allAssembliesFound = $false
                        break
                    }
                }

                if ($allAssembliesFound) {
                    $installed = $true
                    Microsoft.PowerShell.Utility\Write-Verbose "Package validation successful - all assemblies found"
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Verbose "Package validation failed - missing assemblies"
                }
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose "Package directory does not exist; proceeding to install"
            }            # Lazy check if type already loaded
            if ($TypeName -and ($TypeName -as [type])) {
                Microsoft.PowerShell.Utility\Write-Verbose "${TypeName} already loaded; skipping"
                return
            }
            else {
                if ($TypeName) {
                    Microsoft.PowerShell.Utility\Write-Verbose "${TypeName} not loaded; proceeding"
                }
            }

            if (-not $installed) {
                # Request consent for NuGet package installation using embedded consent logic
                $packageDescription = if ($Description) { $Description } else { "Required .NET assembly for PowerShell module functionality" }
                $packagePublisher = if ($Publisher) { $Publisher } elseif ($pkgConfig -and $pkgConfig.Publisher) { $pkgConfig.Publisher } else { "NuGet Package Author" }

                # Use Copy-IdenticalParamValues to pass parameters to Confirm-InstallationConsent
                $consentParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\Confirm-InstallationConsent' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                # Map PackageKey to ApplicationName and set fixed Source
                $consentParams['ApplicationName'] = $PackageId
                $consentParams['Source'] = 'NuGet'
                $consentParams['Description'] = $packageDescription
                $consentParams['Publisher'] = $packagePublisher

                $consentResult = GenXdev\Confirm-InstallationConsent @consentParams

                if (-not $consentResult) {
                    throw "Installation consent denied for package ${PackageId}. Cannot load required assemblies without this package."
                }

                Microsoft.PowerShell.Utility\Write-Host "One-time only just-in-time Installation of ${PackageId}, started, one moment please..." -ForegroundColor Cyan
                Microsoft.PowerShell.Utility\Write-Host "Installing ${PackageId} ${Version}..."

                # the NuGet CLI resolves the dependency graph and lays the package out
                # next to its dependencies in the destination
                $nugetCommand = @(
                    'install'
                    $PackageId
                    '-OutputDirectory'
                    $Destination
                    '-NonInteractive'
                    '-Source'
                    'https://api.nuget.org/v3/index.json'
                )

                if ($Version -ne 'latest') {
                    $nugetCommand += @('-Version', $Version)
                }

                Microsoft.PowerShell.Utility\Write-Verbose "Invoking NuGet: $($nugetCommand -join ' ')"
                & $nugetExe @nugetCommand | Microsoft.PowerShell.Core\Out-Null

                # the CLI lays every package out as <package id>.<version>
                $installedDir = Microsoft.PowerShell.Management\Get-ChildItem $Destination -Directory |
                    Microsoft.PowerShell.Core\Where-Object { $_.Name -match "^${packageLower}\.\d" } |
                    Microsoft.PowerShell.Utility\Sort-Object Name -Descending |
                    Microsoft.PowerShell.Utility\Select-Object -First 1

                if ($installedDir) {

                    $pkgDir = $installedDir.FullName
                    $actualVersion = $installedDir.Name.Substring($packageLower.Length + 1)
                    Microsoft.PowerShell.Utility\Write-Verbose "Installed ${PackageId} ${actualVersion} at ${pkgDir}"
                }

                if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $pkgDir)) {
                    throw "Package not found at ${pkgDir}"
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Verbose "Package confirmed at ${pkgDir}"
                }
            }

            # Parse .nuspec for files (medium priority, after install)
            $nuspecPath = Microsoft.PowerShell.Management\Join-Path $pkgDir "$PackageId.nuspec"
            Microsoft.PowerShell.Utility\Write-Verbose "Checking for .nuspec at ${nuspecPath}"
            $nuspecFiles = @()
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $nuspecPath) {
                Microsoft.PowerShell.Utility\Write-Verbose "Loading .nuspec XML"
                $nuspecXml = [xml](Microsoft.PowerShell.Management\Get-Content -LiteralPath $nuspecPath)
                $nuspecFiles = $nuspecXml.package.files.file | Microsoft.PowerShell.Utility\Select-Object -ExpandProperty target
                Microsoft.PowerShell.Utility\Write-Verbose "Extracted $($nuspecFiles.Count) file targets from .nuspec"
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose "No .nuspec found"
            }

            # Get deps for stub search - look in local destination
            Microsoft.PowerShell.Utility\Write-Verbose "Searching for dependent packages in local destination: ${Destination}"
            try {
                $allPkgs = Microsoft.PowerShell.Management\Get-ChildItem $Destination -Directory -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Core\Where-Object { $_.Name -match '\.[\d\.]+$' }
                if (-not $allPkgs) { $allPkgs = @() }
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Verbose "Failed to get dependent packages: $($_.Exception.Message)"
                $allPkgs = @()
            }
            Microsoft.PowerShell.Utility\Write-Verbose "Found $($allPkgs.Count) dependent packages"            # Skip AssemblyResolve handler to prevent stack overflow issues
            # Will be re-enabled once recursion issues are fully resolved
            Microsoft.PowerShell.Utility\Write-Verbose "Skipping AssemblyResolve event handler to prevent recursion"

            # Load assemblies
            $script:resolveDirs = @()
            foreach ($asm in $Assemblies) {
                $asmPath = $null
                $searched = @()

                # JSON relative path
                $asmFullPath = Microsoft.PowerShell.Management\Join-Path $pkgDir $asm
                Microsoft.PowerShell.Utility\Write-Verbose "Checking JSON relative path for ${asm}: ${asmFullPath}"
                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $asmFullPath) {
                    $asmPath = $asmFullPath
                    Microsoft.PowerShell.Utility\Write-Verbose "Found at JSON relative path"
                }
                else {
                    # Auto TFM scan
                    foreach ($fw in $frameworkPreference + $frameworkFallback) {
                        $libPath = Microsoft.PowerShell.Management\Join-Path $pkgDir "lib\$fw"
                        $searched += $libPath
                        Microsoft.PowerShell.Utility\Write-Verbose "Scanning TFM path: ${libPath}"
                        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $libPath) {
                            $foundAsm = Microsoft.PowerShell.Management\Get-ChildItem $libPath -Filter $asm.Split('/')[-1] -Recurse |
                                Microsoft.PowerShell.Utility\Select-Object -First 1
                            if ($foundAsm) {
                                $asmPath = $foundAsm.FullName
                                Microsoft.PowerShell.Utility\Write-Verbose "Found in TFM ${fw} at ${asmPath}"
                                break
                            }
                        }
                    }

                    # Fallback recursive (as in old)
                    if (-not $asmPath) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Performing recursive search in ${pkgDir} for ${asm.Split('/')[-1]}"
                        $asmPath = Microsoft.PowerShell.Management\Get-ChildItem $pkgDir -Recurse -Filter $asm.Split('/')[-1] |
                            Microsoft.PowerShell.Utility\Select-Object -First 1
                        if ($asmPath) {
                            $searched += "recursive in ${pkgDir}"
                            Microsoft.PowerShell.Utility\Write-Verbose "Found in recursive search at ${asmPath.FullName}"
                        }
                    }

                    # Search deps/stubs in local destination
                    if (-not $asmPath) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Searching dependencies for ${asm.Split('/')[-1]}"
                        foreach ($dep in $allPkgs) {
                            $depAsm = Microsoft.PowerShell.Management\Get-ChildItem $dep.FullName -Recurse -Filter $asm.Split('/')[-1] |
                                Microsoft.PowerShell.Utility\Select-Object -First 1
                            if ($depAsm) {
                                $asmPath = $depAsm.FullName
                                Microsoft.PowerShell.Utility\Write-Verbose "Found in dependency ${dep.Name} at ${asmPath}"
                                break
                            }
                            $searched += "dep ${dep.Name}"
                        }
                    }
                }

                if ($asmPath) {
                    try {
                        Microsoft.PowerShell.Utility\Write-Verbose "Loading assembly with Add-Type -Path ${asmPath}"
                        Microsoft.PowerShell.Utility\Add-Type -Path $asmPath
                        $script:resolveDirs += Microsoft.PowerShell.Management\Split-Path $asmPath -Parent
                        $loadedAssemblies += $asmPath
                        Microsoft.PowerShell.Utility\Write-Verbose "Loaded $asm from ${asmPath}"
                    }
                    catch {
                        throw "Load failed for ${asm}: $($_.Exception.Message). Searched: $($searched -join ', ')"
                    }
                }
                else {
                    throw "Assembly $asm not found. Searched: $($searched -join ', ')"
                }
            }

            # Native handling - copy native dependencies to managed assembly directories AFTER loading assemblies
            # Collect all directories where managed assemblies are loaded
            $managedAssemblyDirs = @()
            foreach ($asmPath in $loadedAssemblies) {
                $asmDir = Microsoft.PowerShell.Management\Split-Path $asmPath -Parent
                if ($managedAssemblyDirs -notcontains $asmDir) {
                    $managedAssemblyDirs += $asmDir
                }
            }

            # If no managed assemblies loaded, fall back to script directory
            if ($managedAssemblyDirs.Count -eq 0) {
                $managedAssemblyDirs = @($MyInvocation.MyCommand.Module.ModuleBase)
            }

            # Collect all native files we need to deploy
            $nativeFileSources = @()

            # Check main package for native files
            $nativeDir = Microsoft.PowerShell.Management\Join-Path $pkgDir "runtimes\$rid\native"
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $nativeDir) {
                $nativeFiles = Microsoft.PowerShell.Management\Get-ChildItem $nativeDir -File
                foreach ($nativeFile in $nativeFiles) {
                    $nativeFileSources += @{
                        SourcePath = $nativeFile.FullName
                        FileName   = $nativeFile.Name
                        Source     = "main package"
                    }
                }
            }

            # Check stub packages for native files
            $stubPattern = "stub.$($packageLower)*"
            $stubPkgs = Microsoft.PowerShell.Management\Get-ChildItem $Destination -Directory |
                Microsoft.PowerShell.Core\Where-Object { $_.Name -like $stubPattern }

            foreach ($stubPkg in $stubPkgs) {
                $stubNativeDir = Microsoft.PowerShell.Management\Join-Path $stubPkg.FullName "runtimes\$rid\native"
                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $stubNativeDir) {
                    $nativeFiles = Microsoft.PowerShell.Management\Get-ChildItem $stubNativeDir -File
                    foreach ($nativeFile in $nativeFiles) {
                        $nativeFileSources += @{
                            SourcePath = $nativeFile.FullName
                            FileName   = $nativeFile.Name
                            Source     = "stub package $($stubPkg.Name)"
                        }
                    }
                }
            }

            # Check dependencies for native files
            foreach ($dep in $allPkgs) {
                $depNativeDir = Microsoft.PowerShell.Management\Join-Path $dep.FullName "runtimes\$rid\native"
                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $depNativeDir) {
                    $nativeFiles = Microsoft.PowerShell.Management\Get-ChildItem $depNativeDir -File
                    foreach ($nativeFile in $nativeFiles) {
                        $nativeFileSources += @{
                            SourcePath = $nativeFile.FullName
                            FileName   = $nativeFile.Name
                            Source     = "dependency $($dep.Name)"
                        }
                    }
                }
            }

            # Deploy native files to all managed assembly directories
            if ($nativeFileSources.Count -gt 0) {
                Microsoft.PowerShell.Utility\Write-Verbose "Found $($nativeFileSources.Count) native files to deploy"

                foreach ($targetDir in $managedAssemblyDirs) {
                    Microsoft.PowerShell.Utility\Write-Verbose "Deploying native dependencies to managed assembly directory: ${targetDir}"

                    foreach ($nativeSource in $nativeFileSources) {
                        $targetPath = Microsoft.PowerShell.Management\Join-Path $targetDir $nativeSource.FileName

                        # Only copy if target doesn't exist or source is newer
                        $shouldCopy = $true
                        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $targetPath) {
                            $sourceLastWrite = (Microsoft.PowerShell.Management\Get-Item $nativeSource.SourcePath).LastWriteTime
                            $targetLastWrite = (Microsoft.PowerShell.Management\Get-Item $targetPath).LastWriteTime
                            $shouldCopy = $sourceLastWrite -gt $targetLastWrite
                        }

                        if ($shouldCopy) {
                            Microsoft.PowerShell.Utility\Write-Verbose "Copying $($nativeSource.FileName) from $($nativeSource.Source) to ${targetDir}"
                            Microsoft.PowerShell.Management\Copy-Item $nativeSource.SourcePath $targetPath -Force
                        }
                        else {
                            Microsoft.PowerShell.Utility\Write-Verbose "Skipping $($nativeSource.FileName) - already up to date in ${targetDir}"
                        }
                    }
                }
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose "No native dependencies required"
            }

            # Verify type
            if ($TypeName -and -not ($TypeName -as [type])) {
                throw "${TypeName} not loaded"
            }
            elseif ($TypeName) {
                Microsoft.PowerShell.Utility\Write-Verbose "${TypeName} verified as loaded"
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Warning "Failure; preserving ${pkgDir} for debug"
            throw
        }
    }
    end {
        Microsoft.PowerShell.Utility\Write-Verbose "Ensured ${PackageKey} with $($loadedAssemblies.Count) assemblies"
    }
}
###############################################################################