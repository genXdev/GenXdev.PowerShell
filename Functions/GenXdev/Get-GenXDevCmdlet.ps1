###############################################################################
<#
.SYNOPSIS
Retrieves and lists all GenXdev cmdlets and their details.

.DESCRIPTION
Searches through installed GenXdev modules and script files to find cmdlets,
their aliases, and descriptions. Can filter by name pattern and module name.
Supports filtering by cmdlet definitions and provides flexible search options
across both local and published module paths.

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

.PARAMETER CmdletName
Search pattern to filter cmdlets. Supports wildcards (*) and exact matching.
When ExactMatch is false, automatically wraps simple strings with wildcards.

.PARAMETER DefinitionMatches
Regular expression to match cmdlet definitions. Used to filter cmdlets based
on their function content or implementation details.

.PARAMETER ModuleName
One or more GenXdev module names to search. Can omit GenXdev prefix. Supports
wildcards and validates module name patterns for GenXdev modules.

.PARAMETER NoLocal
Skip searching in local module paths. When specified, only searches in
published or system module locations.

.PARAMETER OnlyPublished
Limit search to published module paths only. Excludes local development
modules and focuses on released versions.

.PARAMETER FromScripts
Search in script files instead of module files. Changes the search target
from PowerShell modules to standalone script files.

.PARAMETER IncludeScripts
Includes the scripts directory in addition to regular modules. Expands the
search scope to cover both modules and scripts simultaneously.

.PARAMETER OnlyReturnModuleNames
Only return unique module names instead of full cmdlet details. Provides a
summary view of available modules rather than detailed cmdlet information.

.PARAMETER ExactMatch
Perform exact matching instead of wildcard matching. When specified, disables
automatic wildcard wrapping for simple search patterns.

.EXAMPLE
Get-GenXDevCmdlet -CmdletName "Get-*" -ModuleName "Console" -NoLocal

.EXAMPLE
gcmds Get-*

.EXAMPLE
Get-GenXDevCmdlet -OnlyReturnModuleNames
#>
function Get-GenXDevCmdlet {

    [CmdletBinding()]
    [OutputType([GenXdev.Helpers.GenXdevCmdletInfo], [string])]
    [Alias('gcmds')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Search pattern to filter cmdlets'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Filter', 'CmdLet', 'Cmd', 'FunctionName', 'Name')]
        [SupportsWildcards()]
        [string[]] $CmdletName,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Regular expression to match cmdlet definitions'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $DefinitionMatches,
        ###############################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'GenXdev module names to search'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Module', 'BaseModuleName', 'SubModuleName')]
        [ValidatePattern('^(GenXdev|GenXde[v]\*|GenXdev(\.[\w\*\[\]\?]*)+)+$')]
        [SupportsWildcards()]
        [string[]] $ModuleName,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip searching in local module paths'
        )]
        [switch] $NoLocal,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only search in published module paths'
        )]
        [switch] $OnlyPublished,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Search in script files instead of modules'
        )]
        [switch] $FromScripts,
        ###############################################################################
        [Parameter(
            ParameterSetName = "ModuleName",
            Mandatory = $false,
            HelpMessage = ('Includes the scripts directory in addition to ' +
                'regular modules')
        )]
        [switch] $IncludeScripts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only return unique module names'
        )]
        [switch] $OnlyReturnModuleNames,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Perform exact matching instead of wildcard matching'
        )]
        [switch] $ExactMatch
    )

    begin {

        # # get ps root path
        # $psRootPath = GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\..\"

        # store current location to restore later and prevent side effects
        $originalLocation = Microsoft.PowerShell.Management\Get-Location

        # initialize collection to store found cmdlets
        $cmdletCollection = [System.Collections.Generic.List[GenXdev.Helpers.GenXdevCmdletInfo]]::new()

        # output verbose information about search parameters
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting cmdlet search with CmdletName: ${CmdletName}, " +
            "ModuleName: ${ModuleName}, ExactMatch: ${ExactMatch}"
        )
    }

    process {

        #######################################################################
        # Helper: test if a value matches any pattern in an array using
        # -like (wildcard) or -eq (exact match)
        #######################################################################
        function Test-MatchesAnyPattern {
            param($Value, [string[]] $Patterns, [bool] $Exact)

            if (-not $Patterns -or $Patterns.Count -eq 0) { return $true }

            foreach ($p in $Patterns) {
                $pattern = $p
                if (-not $Exact -and
                    $pattern.IndexOfAny('*?[]'.ToCharArray()) -lt 0) {
                    $pattern = "*$pattern*"
                }
                if ($Value -like $pattern) { return $true }
            }
            return $false
        }

        #######################################################################
        # Resolve modules via direct directory scan (avoids PS7.x
        # AnalysisCache stack overflow in Get-Module -ListAvailable)
        #######################################################################
        $moduleDirs = [System.Collections.Generic.List[hashtable]]::new()

        foreach ($psPath in $env:PSModulePath.Split(';')) {
            if (-not [IO.Directory]::Exists($psPath)) { continue }
            foreach ($dir in [IO.Directory]::EnumerateDirectories(
                $psPath, 'GenXdev*')) {

                $dirName = [IO.Path]::GetFileName($dir)

                # Apply NoLocal filter early
                if ($NoLocal -and $dirName -like 'GenXdev.Local*') {
                    continue
                }

                # Apply ModuleName filter early where possible
                if ($ModuleName -and $ModuleName.Count -gt 0) {
                    $match = $false
                    foreach ($mn in $ModuleName) {
                        $pattern = $mn
                        if (-not $ExactMatch -and
                            $pattern.IndexOfAny('*?[]'.ToCharArray()) -lt 0) {
                            $pattern = "*$pattern*"
                        }
                        if ($dirName -like $pattern) {
                            $match = $true; break
                        }
                        if ($mn.StartsWith($dirName + '.')) {
                            $match = $true; break
                        }
                    }
                    if (-not $match) { continue }
                }

                # Find latest version subdirectory
                $latestVersionDir = $null
                $latestVersion = [version]'0.0'
                foreach ($verDir in [IO.Directory]::EnumerateDirectories(
                    $dir)) {
                    $verName = [IO.Path]::GetFileName($verDir)
                    if ($verName -notmatch
                        '^(\d+)\.(\d+)\.(\d+\.?\d*)$') { continue }
                    $ver = [version]$verName
                    if ($ver -gt $latestVersion) {
                        $latestVersion = $ver
                        $latestVersionDir = $verDir
                    }
                }

                if (-not $latestVersionDir) { continue }

                $jsonPath = [IO.Path]::Combine($latestVersionDir,
                    'cmdlets-meta.json')

                # Apply OnlyPublished filter
                if ($OnlyPublished) {
                    if (-not [IO.File]::Exists([IO.Path]::Combine(
                        $latestVersionDir, 'README.md'))) { continue }
                }

                if (-not [IO.File]::Exists($jsonPath)) { continue }

                $null = $moduleDirs.Add(@{
                        BaseModuleName = $dirName
                        VersionDir     = $latestVersionDir
                        JsonPath       = $jsonPath
                    })
            }
        }

        # Build list of { baseModuleName, versionDir, jsonPath } tuples
        $jsonModuleData = @($moduleDirs |
            Microsoft.PowerShell.Core\ForEach-Object {
                [PSCustomObject]$_
            })

        #######################################################################
        # Process each cmdlets-meta.json file
        #######################################################################
        foreach ($moduleData in $jsonModuleData) {
            $baseModuleName = $moduleData.BaseModuleName
            $versionDir = $moduleData.VersionDir

            # Check script-scoped memory cache first
            $cacheVarName = ($baseModuleName).Replace('.', '_') +
            'CmdletMeta'
            $entries = Microsoft.PowerShell.Utility\Get-Variable `
                -Name $cacheVarName `
                -Scope Script `
                -ValueOnly `
                -ErrorAction SilentlyContinue

            if ($null -eq $entries) {
                try {
                    $entries = Microsoft.PowerShell.Utility\ConvertFrom-Json `
                        -InputObject ([IO.File]::ReadAllText(
                            $moduleData.JsonPath))
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning `
                        "Failed to read $($moduleData.JsonPath): $_"
                    continue
                }
                Microsoft.PowerShell.Utility\Set-Variable `
                    -Name $cacheVarName `
                    -Scope Script `
                    -Value $entries
            }

            foreach ($entry in $entries) {

                # Filter by SubModuleName (in addition to base module)
                if ($ModuleName -and $ModuleName.Count -gt 0) {
                    if (-not (Test-MatchesAnyPattern `
                                -Value $entry.SubModuleName `
                                -Patterns $ModuleName `
                                -Exact $ExactMatch)) { continue }
                }

                # Filter by CmdletName
                if ($CmdletName -and $CmdletName.Count -gt 0) {
                    # Split into qualified (Module\Name) and bare patterns
                    $qPatterns = @($CmdletName |
                        Microsoft.PowerShell.Core\Where-Object {
                            $_ -match '\\'
                        })
                    $bPatterns = @($CmdletName |
                        Microsoft.PowerShell.Core\Where-Object {
                            $_ -notmatch '\\'
                        })

                    $nameMatch = $false

                    # Check qualified patterns (ModuleQualifier\CmdletName)
                    if ($qPatterns.Count -gt 0) {
                        foreach ($qp in $qPatterns) {
                            $ix = $qp.LastIndexOf('\')
                            $qMod = $qp.Substring(0, $ix)
                            $qName = $qp.Substring($ix + 1)
                            if ((Test-MatchesAnyPattern `
                                    -Value $baseModuleName `
                                    -Patterns @($qMod) `
                                    -Exact $ExactMatch) -and
                                (Test-MatchesAnyPattern `
                                    -Value $entry.CmdletName `
                                    -Patterns @($qName) `
                                    -Exact $ExactMatch)) {
                                $nameMatch = $true
                                break
                            }
                        }
                    }

                    # Check bare patterns (original behavior)
                    if (-not $nameMatch -and $bPatterns.Count -gt 0) {
                        $nameMatch = Test-MatchesAnyPattern `
                            -Value $entry.CmdletName `
                            -Patterns $bPatterns `
                            -Exact $ExactMatch
                    }

                    # Also check aliases (bare patterns only)
                    if (-not $nameMatch -and $bPatterns.Count -gt 0) {
                        foreach ($alias in $entry.Aliases) {
                            if (Test-MatchesAnyPattern `
                                    -Value $alias `
                                    -Patterns $bPatterns `
                                    -Exact $ExactMatch) {
                                $nameMatch = $true
                                break
                            }
                        }
                    }
                    if (-not $nameMatch) { continue }
                }

                # Determine source file path.
                # Most C# cmdlets use plain .cs. Cmdlets with partial
                # classes (like Find-Item) use .Cmdlet.cs for the main
                # file. Try .cs first, fall back to .Cmdlet.cs.
                $srcFilePath = if ($entry.CmdletType -eq 'Function') {
                    "$versionDir\Functions\$($entry.SubModuleName)\$($entry.CmdletName).ps1"
                }
                else {
                    $csPath = "$versionDir\Functions\$($entry.SubModuleName)\$($entry.CmdletName).cs"
                    if ([IO.File]::Exists($csPath)) {
                        $csPath
                    }
                    else {
                        "$versionDir\Functions\$($entry.SubModuleName)\$($entry.CmdletName).Cmdlet.cs"
                    }
                }

                # Apply DefinitionMatches filter (read source when needed)
                if ($DefinitionMatches) {
                    if ([IO.File]::Exists($srcFilePath)) {
                        $content = [IO.File]::ReadAllText($srcFilePath)
                        if ($content -notmatch $DefinitionMatches) {
                            continue
                        }
                    }
                    else { continue }
                }

                # Build GenXdevCmdletInfo
                $cmdletInfo = [GenXdev.Helpers.GenXdevCmdletInfo]@{
                    Name               = $entry.CmdletName
                    ModuleName         = $entry.SubModuleName
                    BaseModule         = $baseModuleName
                    LineNo             = 0
                    Description        = $entry.Description
                    Aliases            = $entry.Aliases -join ', '
                    ScriptFilePath     = $srcFilePath
                    ScriptTestFilePath = (
                        "$versionDir\Tests\$($entry.SubModuleName)\$($entry.CmdletName).Tests.ps1"
                    )
                }

                $null = $cmdletCollection.Add($cmdletInfo)
            }
        }

        #######################################################################
        # Handle scripts (-FromScripts / -IncludeScripts) using legacy path
        #######################################################################
        if (-not ($FromScripts -or $IncludeScripts)) { return }

        # resolve the scripts directory path relative to current module
        $scriptsPath = [IO.Path]::GetFullPath("$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\..\Scripts")

        if (-not [IO.Directory]::Exists($scriptsPath)) {

            mkdir $scriptsPath
        }

        GenXdev\Find-Item "$scriptsPath\*.ps1" -Passthru |
            Microsoft.PowerShell.Core\ForEach-Object {

                if ($_.Name -like '_*') { return }

                $cName = [IO.Path]::GetFileNameWithoutExtension(
                    $_.Name).Replace('.Cmdlet', '').Replace(
                    '.cmdlet', '')

                # Filter by CmdletName
                if ($CmdletName -and $CmdletName.Count -gt 0) {
                    # Split into qualified (Module\Name) and bare patterns
                    $qPatterns = @($CmdletName |
                        Microsoft.PowerShell.Core\Where-Object {
                            $_ -match '\\'
                        })
                    $bPatterns = @($CmdletName |
                        Microsoft.PowerShell.Core\Where-Object {
                            $_ -notmatch '\\'
                        })

                    $nameMatch = $false

                    # Check qualified patterns (ModuleQualifier\CmdletName)
                    if ($qPatterns.Count -gt 0) {
                        foreach ($qp in $qPatterns) {
                            $ix = $qp.LastIndexOf('\')
                            $qMod = $qp.Substring(0, $ix)
                            $qName = $qp.Substring($ix + 1)
                            if ((Test-MatchesAnyPattern `
                                    -Value 'GenXdev.Scripts' `
                                    -Patterns @($qMod) `
                                    -Exact $ExactMatch) -and
                                (Test-MatchesAnyPattern `
                                    -Value $cName `
                                    -Patterns @($qName) `
                                    -Exact $ExactMatch)) {
                                $nameMatch = $true
                                break
                            }
                        }
                    }

                    # Check bare patterns (original behavior)
                    if (-not $nameMatch -and $bPatterns.Count -gt 0) {
                        if ($ExactMatch) {
                            if ($cName.ToLowerInvariant() -ne `
                                    $bPatterns.ToLowerInvariant()) { return }
                        }
                        if ($cName -notlike $bPatterns) { return }
                    }

                    if (-not $nameMatch -and $bPatterns.Count -eq 0) {
                        return
                    }
                }

                # Filter by DefinitionMatches
                if ($DefinitionMatches) {

                    $content = [IO.File]::ReadAllText($_.FullName)
                    if ($content -notmatch $DefinitionMatches) {
                        return
                    }
                }

                $cmdletInfo = [GenXdev.Helpers.GenXdevCmdletInfo]@{
                    Name               = $cName
                    ModuleName         = 'GenXdev.Scripts'
                    BaseModule         = 'GenXdev.Scripts'
                    LineNo             = 0
                    Description        = ''
                    Aliases            = ''
                    ScriptFilePath     = $_.FullName
                    ScriptTestFilePath = (
                        GenXdev\Expand-Path "$([IO.Path]::GetDirectoryName($_.FullName))\$($cName).Tests.ps1")
                }

                $null = $cmdletCollection.Add($cmdletInfo)
            }
    }

    end {

        # restore the original location to prevent side effects
        Microsoft.PowerShell.Management\Set-Location -LiteralPath $originalLocation

        # output verbose completion message
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Completed cmdlet search and restored original location"
        )

        # return results based on OnlyReturnModuleNames parameter
        if ($OnlyReturnModuleNames) {

            # return unique BaseModule names
            $cmdletCollection |
                Microsoft.PowerShell.Core\ForEach-Object { $_.BaseModule } |
                Microsoft.PowerShell.Utility\Select-Object -Unique |
                Microsoft.PowerShell.Utility\Sort-Object {
                    "$($_.BaseModule.Length.ToString("00_"))$($_.BaseModule)"
                } -Descending ;
        }
        else {

            # return full cmdlet information objects
            $cmdletCollection
        }
    }

    ###############################################################################
}