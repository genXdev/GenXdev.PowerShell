###############################################################################
<#
.SYNOPSIS
Downloads and loads .NET assemblies from NuGet packages based on package key or ID.

.DESCRIPTION
This function ensures that the specified NuGet package assemblies are downloaded
and loaded into the current PowerShell session. It supports automatic detection
and loading with fallback to a JSON manifest for configuration overrides,
handling edge cases like stub dependencies (e.g., SQLite). Installation uses
the dotnet CLI exclusively for reliable package management and loads assemblies
directly from the global NuGet cache without copying. Lazy loading checks if
the type is already available before proceeding.

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

        # Global cache fallback path (cross-platform)
        $globalCache = if ($env:OS -eq 'Windows_NT') {
            "$env:USERPROFILE\.nuget\packages"
        }
        else {
            "$env:HOME/.nuget/packages"
        }
        Microsoft.PowerShell.Utility\Write-Verbose "Global cache path: ${globalCache}"

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
                # Find latest version using dotnet list command
                Microsoft.PowerShell.Utility\Write-Verbose "No version specified or in JSON; querying latest from NuGet using dotnet"
                try {
                    $null = & dotnet list package --outdated --include-prerelease --source https://api.nuget.org/v3/index.json 2>$null
                    # For simplicity, we'll use a default "latest" approach via dotnet add package without version
                    $Version = "latest"
                    Microsoft.PowerShell.Utility\Write-Verbose "Will use latest version available"
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning "Could not determine latest version, will use dotnet's default behavior"
                    $Version = "latest"
                }
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



        # Check and install dotnet SDK if missing (for fallback)
        Microsoft.PowerShell.Utility\Write-Verbose "Checking for dotnet CLI"
        if (-not (Microsoft.PowerShell.Core\Get-Command dotnet -ErrorAction SilentlyContinue)) {
            Microsoft.PowerShell.Utility\Write-Host "dotnet CLI not found; attempting install via winget if available..."

            # verify administrative privileges are available
            if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                $json = $PSBoundParameters | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsureNuGetAssembly @params
"@)) -PauseAfterCompletion -JobDescription 'Installing .Net SDK 10 for NuGet package management and compilation'
            }
            else {
                # Request consent for .NET SDK installation using embedded consent logic
                $sdkDescription = if ($Description) { $Description } else { "Required for NuGet package management and compilation" }

                # Use Copy-IdenticalParamValues to pass parameters to Confirm-InstallationConsent
                $sdkConsentParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\Confirm-InstallationConsent' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                # Set fixed values for .NET SDK consent
                $sdkConsentParams['ApplicationName'] = "Microsoft .NET SDK 10"
                $sdkConsentParams['Source'] = 'Winget'
                $sdkConsentParams['Description'] = $sdkDescription
                $sdkConsentParams['Publisher'] = "Microsoft"

                $consentResult = GenXdev\Confirm-InstallationConsent @sdkConsentParams

                if (-not $consentResult) {
                    throw "Installation consent denied for Microsoft .NET SDK 10. Cannot proceed without dotnet CLI. Please install .NET SDK 9+ manually from https://dotnet.microsoft.com/download/dotnet/9.0"
                }

                Microsoft.PowerShell.Utility\Write-Verbose "Invoking winget install Microsoft.DotNet.SDK.9 --accept-package-agreements --accept-source-agreements"
                winget install Microsoft.DotNet.SDK.10 --accept-package-agreements --accept-source-agreements
                # Reload PATH after install
                Microsoft.PowerShell.Utility\Write-Verbose "Reloading PATH environment variable"
                $env:Path = [System.Environment]::GetEnvironmentVariable("Path", "Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path", "User")
                Microsoft.PowerShell.Utility\Write-Verbose "PATH reloaded"
            }

            # Re-check after install
            if (-not (Microsoft.PowerShell.Core\Get-Command dotnet -ErrorAction SilentlyContinue)) {
                throw "dotnet install failed; manual installation required."
            }
            Microsoft.PowerShell.Utility\Write-Verbose "dotnet CLI installed successfully"
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "dotnet CLI already available"
        }

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

                # Install using dotnet CLI
                $tempDir = Microsoft.PowerShell.Management\Join-Path ([System.IO.Path]::GetTempPath()) ([Guid]::NewGuid())
                Microsoft.PowerShell.Utility\Write-Verbose "Creating temporary directory for dotnet installation: ${tempDir}"
                Microsoft.PowerShell.Management\New-Item -Path $tempDir -ItemType Directory -Force | Microsoft.PowerShell.Core\Out-Null
                Microsoft.PowerShell.Utility\Write-Verbose "Pushing location to ${tempDir}"
                Microsoft.PowerShell.Management\Push-Location -LiteralPath $tempDir
                try {
                    Microsoft.PowerShell.Utility\Write-Verbose "Invoking dotnet new classlib -n dummy --force"
                    & dotnet new classlib -n dummy --force | Microsoft.PowerShell.Core\Out-Null
                    Microsoft.PowerShell.Management\Set-Location dummy

                    $actualVersion = $Version
                    if ($Version -eq "latest") {
                        $addCmd = "dotnet add package $PackageId"
                        Microsoft.PowerShell.Utility\Write-Verbose "Invoking ${addCmd}"
                        & dotnet add package $PackageId | Microsoft.PowerShell.Core\Out-Null
                    }
                    else {
                        $addCmd = "dotnet add package $PackageId --version $Version"
                        Microsoft.PowerShell.Utility\Write-Verbose "Invoking ${addCmd}"
                        & dotnet add package $PackageId --version $Version | Microsoft.PowerShell.Core\Out-Null
                    }
                    # Always discover the actual installed version from project.assets.json
                    $objDir = Microsoft.PowerShell.Management\Join-Path (Microsoft.PowerShell.Management\Get-Location) "obj"
                    $assetsFile = Microsoft.PowerShell.Management\Join-Path $objDir "project.assets.json"
                    if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $assetsFile) {
                        $assets = Microsoft.PowerShell.Management\Get-Content -LiteralPath $assetsFile | Microsoft.PowerShell.Utility\ConvertFrom-Json
                        if ($assets.libraries) {
                            foreach ($libName in $assets.libraries.PSObject.Properties.Name) {
                                $parts = $libName -split '/'
                                if ($parts.Length -eq 2 -and $parts[0].ToLower() -eq $packageLower) {
                                    $rawVersion = $parts[1]
                                    $actualVersion = $rawVersion
                                    Microsoft.PowerShell.Utility\Write-Verbose "Discovered installed version: ${actualVersion}"
                                    break
                                }
                            }
                        }
                    }
                    if (-not $actualVersion -or $actualVersion -eq "latest") {
                        throw "Could not determine actual version installed for ${PackageId}"
                    }

                    Microsoft.PowerShell.Utility\Write-Verbose "Invoking dotnet restore"
                    & dotnet restore | Microsoft.PowerShell.Core\Out-Null

                    # Copy main package and all dependencies from global cache to local destination
                    $cacheDir = Microsoft.PowerShell.Management\Join-Path $globalCache "$packageLower\$actualVersion"
                    Microsoft.PowerShell.Utility\Write-Verbose "Checking main package cache directory: ${cacheDir}"

                    if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $cacheDir)) {
                        throw "Package not found in global cache at: ${cacheDir}"
                    }
                    if ($cacheDir) {
                        # Calculate the correct target directory name using actual version
                        $targetPkgDir = Microsoft.PowerShell.Management\Join-Path $Destination "$packageLower.$actualVersion"

                        # Remove target directory if it exists to avoid nested structure
                        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $targetPkgDir) {
                            Microsoft.PowerShell.Management\Remove-Item -LiteralPath $targetPkgDir -Recurse -Force -ErrorAction SilentlyContinue
                        }

                        Microsoft.PowerShell.Utility\Write-Verbose "Copying main package from ${cacheDir} to ${targetPkgDir}"
                        Microsoft.PowerShell.Management\Copy-Item $cacheDir -Destination $targetPkgDir -Recurse -Force
                        Microsoft.PowerShell.Utility\Write-Verbose "Main package copied to ${targetPkgDir}"

                        # Update pkgDir to the actual location after copying
                        $pkgDir = $targetPkgDir                        # Also copy dependencies by parsing the project assets
                        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $assetsFile) {
                            Microsoft.PowerShell.Utility\Write-Verbose "Reading project assets for dependencies: ${assetsFile}"
                            $assets = Microsoft.PowerShell.Management\Get-Content -LiteralPath $assetsFile | Microsoft.PowerShell.Utility\ConvertFrom-Json
                            if ($assets.libraries) {
                                foreach ($libName in $assets.libraries.PSObject.Properties.Name) {
                                    if ($libName -ne "$packageLower/$actualVersion") {
                                        $parts = $libName -split '/'
                                        if ($parts.Length -eq 2) {
                                            $depName = $parts[0].ToLower()
                                            $depVersion = $parts[1]

                                            $depCacheDir = Microsoft.PowerShell.Management\Join-Path $globalCache "$depName\$depVersion"
                                            $depDestDir = Microsoft.PowerShell.Management\Join-Path $Destination "$depName.$depVersion"

                                            if ((Microsoft.PowerShell.Management\Test-Path -LiteralPath $depCacheDir) -and (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $depDestDir))) {
                                                Microsoft.PowerShell.Utility\Write-Verbose "Copying dependency ${depName} ${depVersion} from cache"
                                                Microsoft.PowerShell.Management\Copy-Item $depCacheDir -Destination $Destination -Recurse -Force
                                                $copiedDepDir = Microsoft.PowerShell.Management\Join-Path $Destination (Microsoft.PowerShell.Management\Split-Path $depCacheDir -Leaf)
                                                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $copiedDepDir) {
                                                    Microsoft.PowerShell.Management\Rename-Item $copiedDepDir $depDestDir -Force -ErrorAction SilentlyContinue
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }
                    else {
                        throw "Cache directory not found: ${cacheDir}"
                    }
                }
                finally {
                    # Store assets file content before cleaning up temp directory
                    Microsoft.PowerShell.Management\Pop-Location
                    Microsoft.PowerShell.Utility\Write-Verbose "Cleaning up temp directory: ${tempDir}"
                    Microsoft.PowerShell.Management\Remove-Item $tempDir -Recurse -Force -ErrorAction SilentlyContinue
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