<#
.SYNOPSIS
Executes a script block on each GenXdev module in the workspace.

.DESCRIPTION
This function iterates through GenXdev modules in the workspace and executes
a provided script block against each module. It can filter modules by name
pattern, exclude local modules, include only published modules, or process
scripts instead of modules. The function automatically navigates to the
correct module directory before executing the script block.

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

.PARAMETER Script
The script block to execute for each GenXdev module. The module object is
passed as an argument to the script block.

.PARAMETER ModuleName
Filter to apply to module names. Supports wildcards and multiple patterns.
Defaults to 'GenXdev*' to include all GenXdev modules.

.PARAMETER NoLocal
Excludes local development modules from processing.

.PARAMETER OnlyPublished
Includes only published modules that have LICENSE and README.md files.

.PARAMETER FromScripts
Process scripts directory instead of module directories.

.PARAMETER IncludeScripts
Includes the scripts directory in addition to regular modules.

.PARAMETER IncludeGenXdevMainModule
Includes the main GenXdev module in addition to sub-modules.

.EXAMPLE
Invoke-OnEachGenXdevModule -Script { Write-Host $args[0].Name }

Lists all GenXdev module names.

.EXAMPLE
foreach-genxdev-module-do {
    param($ModuleObj, $isScriptsFolder, $isSubModule, $subModuleName)
    Get-ChildItem
} -ModuleName "GenXdev.AI"

Uses alias to list contents of the GenXdev.AI module directory.
#>
function Invoke-OnEachGenXdevModule {

    [CmdletBinding()]
    [Alias('foreach-genxdev-module-do')]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = ('The script block to execute for each ' +
                'GenXdev module')
        )]
        [Alias('ScriptBlock')]
        [scriptblock] $Script,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'Filter to apply to module names'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Module', 'BaseModuleName', 'SubModuleName')]
        [ValidatePattern('^(GenXdev|GenXde[v]\*|GenXdev(\.[\w\*\[\]\?]*)+)+$')]
        [SupportsWildcards()]
        [string[]] $ModuleName = @('GenXdev*'),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Excludes local development modules from processing'
        )]
        [switch] $NoLocal,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Includes only published modules that have LICENSE ' +
                'and README.md files')
        )]
        [switch] $OnlyPublished,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Process scripts directory instead of module directories'
        )]
        [switch] $FromScripts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Includes the scripts directory in addition to ' +
                'regular modules')
        )]
        [switch] $IncludeScripts
    )

    begin {

        # resolve the scripts directory path relative to current module
        $scriptsPath = [IO.Path]::GetFullPath("$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\..\Scripts")

        if (-not [IO.Directory]::Exists($scriptsPath)) {

            mkdir $scriptsPath
        }

        # resolve the modules directory path relative to current module
        $modulesPath = [IO.Path]::GetFullPath("$($MyInvocation.MyCommand.Module.ModuleBase)\..\..")

        if (-not [IO.Directory]::Exists($modulesPath)) {

            mkdir $modulesPath
        }

        # override module name filter when processing scripts only
        if ($FromScripts) {

            $ModuleName = @('GenXdev.Scripts')
        }

        $allGenXdevModules = @(Microsoft.PowerShell.Management\Get-ChildItem "$modulesPath\GenXdev*.psd1" -Recurse | Microsoft.PowerShell.Core\Where-Object { $_.FullName -like "*\3.33.0\GenXdev*" } | Microsoft.PowerShell.Core\ForEach-Object { [IO.Path]::GetFileNameWithoutExtension($_.FullName) }) +
        @("GenXdev.Scripts")

        $genXdevModules = $allGenXdevModules

        if ($ModuleName.Count -eq 1 -and $ModuleName[0] -eq 'GenXdev*') {

            $genXdevModules = @($allGenXdevModules | Microsoft.PowerShell.Core\ForEach-Object {

                    if ((-not ($IncludeScripts -or $FromScripts)) -and ($_ -like "GenXdev.Scripts")) {

                        return;
                    }

                    $_
                })
        }
    }

    process {
    }

    end {

        # iterate through each specified module name pattern
        $uniqueModulesNames = @($ModuleName | Microsoft.PowerShell.Core\ForEach-Object {

                $moduleToFind = $_

                foreach ($module in $genXdevModules) {

                    if ($module -like $moduleToFind) {

                        if (($module -like "GenXdev.Scripts") -and ($includeScripts)) {

                            $module
                            continue
                        }

                        if ([IO.File]::Exists(([IO.Path]::GetFullPath("$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\$module\3.33.0\$module.psd1")))) {

                            $module

                        }
                    }
                    elseif (Microsoft.PowerShell.Management\Test-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\$module\3.33.0\Functions\$moduleToFind" -ErrorAction SilentlyContinue) {

                        $module
                    }
                }
            } |
                Microsoft.PowerShell.Utility\Select-Object -Unique |
                Microsoft.PowerShell.Utility\Sort-Object {

                    $_.Length.ToString().PadLeft(5, '0') + "_" + $_.ToLower()
                })

        foreach ($nextModule in $uniqueModulesNames) {

            # split module name into parts for pattern matching
            $partsObj = $nextModule.Split(".")

            # output current module pattern being processed
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Processing module pattern: $nextModule")

            # define internal function to process individual modules
            function processModule {

                param($ModuleObj, $parts)

                # construct expected license file path for published modules
                $licenseFilePath = (
                    "$($ModuleObj.FullName)\3.33.0\LICENSE")

                # construct expected readme file path for published modules
                $readmeFilePath = (
                    "$($ModuleObj.FullName)\3.33.0\README.md")

                # skip license and readme checks for scripts directory
                if ($ModuleObj.FullName -eq $scriptsPath) {

                    $licenseFilePath = $null
                    $readmeFilePath = $null
                }

                # determine if module should be processed based on all filters
                $shouldProcess = (
                    (($ModuleObj.Name -like 'GenXdev') -or ($includeScripts -and ($ModuleObj.Name -like 'GenXdev.Scripts')) -or ((-not $OnlyPublished) -and (-not $NoLocal) -and ($ModuleObj.Name -like 'GenXdev.Local*'))) -and
                    ((-not $OnlyPublished) -or (
                        [IO.File]::Exists($licenseFilePath) -and
                        [IO.File]::Exists($readmeFilePath))))

                # process module if it passes all filters
                if ($shouldProcess) {

                    # output module name being processed
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Processing module: $($ModuleObj.Name)")

                    # save current location to restore after processing
                    $originalLocation = (
                        Microsoft.PowerShell.Management\Get-Location).Path

                    try {

                        # handle scripts directory with special logic
                        if ($ModuleObj.Name -like 'GenXdev.Scripts') {

                            # navigate directly to scripts directory
                            Microsoft.PowerShell.Management\Set-Location `
                                -LiteralPath $scriptsPath
                        }
                        else {

                            # initialize version variable for parsing
                            [version] $version = $null

                            # navigate to module root directory first
                            Microsoft.PowerShell.Management\Set-Location `
                                -LiteralPath "$($ModuleObj.FullName)"

                            # find the latest version directory for the module
                            $versionDirectory = (
                                Microsoft.PowerShell.Management\Get-ChildItem `
                                    -LiteralPath '.\' `
                                    -Filter "*.*.*" `
                                    -Directory `
                                    -ErrorAction SilentlyContinue |
                                    Microsoft.PowerShell.Core\Where-Object {
                                        [Version]::TryParse($_.Name, [ref]$version)
                                    } |
                                    Microsoft.PowerShell.Utility\Sort-Object {
                                        [Version]::new($_.Name)
                                    } -Descending |
                                    Microsoft.PowerShell.Utility\Select-Object `
                                        -First 1 |
                                    Microsoft.PowerShell.Core\ForEach-Object {
                                        $_.FullName
                                    })

                            # skip module if no valid version directory found
                            if ($null -eq $versionDirectory) {

                                # output warning for modules without version dirs
                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    "No version directory found for " +
                                    "$($ModuleObj.Name)")

                                return
                            }

                            # navigate to the specific version directory
                            Microsoft.PowerShell.Management\Set-Location `
                                -LiteralPath $versionDirectory

                            # output current working directory for debugging
                            Microsoft.PowerShell.Utility\Write-Verbose (
                                "Changed to directory: $versionDirectory")
                        }

                        # execute the user script with module context parameters
                        Microsoft.PowerShell.Core\Invoke-Command `
                            -ScriptBlock $Script `
                            -ArgumentList @(
                            ($ModuleObj | Microsoft.PowerShell.Utility\ConvertTo-Json | Microsoft.PowerShell.Utility\ConvertFrom-Json),
                            ($ModuleObj.Name -eq "GenXdev.Scripts"),
                            ($parts.Length -gt 2),
                            ($parts -join '.')) `
                            -NoNewScope
                    }
                    finally {

                        # always restore original working directory
                        Microsoft.PowerShell.Management\Set-Location `
                            -LiteralPath $originalLocation
                    }
                }
                else {

                    # output information about skipped modules
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Skipping module: $($ModuleObj.Name) (filtered out)")
                }
            }

            # handle scripts directory as a special case
            if ($nextModule -like 'GenXdev.Scripts') {

                # create mock module object for scripts directory
                processModule -parts $partsObj -ModuleObj @{
                    Name     = 'GenXdev.Scripts'
                    FullName = $scriptsPath
                }

                continue
            }

            try {

                # process the matching module
                processModule -parts $partsObj -ModuleObj @{
                    Name     = ($partsObj.Length -lt 2 ? $partsObj[0] : ($partsObj[0] + "." + $partsObj[1]))
                    FullName = "$modulesPath\$($partsObj.Length -lt 2 ? $partsObj[0] : ($partsObj[0]+"."+$partsObj[1]))"
                }
            }
            catch {

                # output any errors encountered during processing
                Microsoft.PowerShell.Utility\Write-Error `
                    $_.Exception.Message
            }
        }
    }
}
################################################################################