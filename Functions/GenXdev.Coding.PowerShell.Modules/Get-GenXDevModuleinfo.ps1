# Don't remove this line [dontrefactor]

###############################################################################
<#
.SYNOPSIS
Retrieves detailed information about GenXdev PowerShell modules.

.DESCRIPTION
This function examines GenXdev PowerShell modules and returns information about
their configuration, versions, and presence of key files. It can process either
specified modules or all available modules.

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

.PARAMETER ModuleName
Array of module names to analyze. If empty, processes all available modules.
GenXdev.Local module is explicitly blocked from processing.

.EXAMPLE
Get-GenXDevModuleInfo -ModuleName "GenXdev.Console"

.EXAMPLE
"GenXdev.Console" | Get-GenXDevModuleInfo
#>
function Get-GenXDevModuleInfo {

    [CmdletBinding()]

    param(
        ########################################################################
        [parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Names of modules to analyze'
        )]
        [Alias('Name', 'Module')]
        [string[]] $ModuleName = @(),
        ########################################################################
        [switch] $IncludeLocal
    )

    begin {
        # get all available genxdev modules
        Microsoft.PowerShell.Utility\Write-Verbose 'Retrieving all available GenXdev modules'
        [System.IO.FileSystemInfo[]] $AllModules = @(GenXdev\Get-GenXDevModule -IncludeLocal:$IncludeLocal)
    }

    process {

        # process specified modules if any were provided
        if ($ModuleName.Count -gt 0) {

            foreach ($currentModuleName in $ModuleName) {

                foreach ($currentModule in $AllModules) {

                    # skip if module name doesn't match
                    if ($currentModule.Parent.Name -ne $currentModuleName) {

                        continue
                    }

                    # construct path to module configuration file
                    $configPath = "$($currentModule.FullName)\$currentModuleName.psd1"
                    Microsoft.PowerShell.Utility\Write-Verbose "Processing config file: $configPath"

                    # read and parse module configuration
                    $configText = [IO.File]::ReadAllText($configPath)
                    $config = Microsoft.PowerShell.Utility\Invoke-Expression -Command ($configText)

                    # calculate current and new version numbers
                    $currentVersion = [Version]::new($config.ModuleVersion)
                    $newVersion = [Version]::new(
                        $currentVersion.Major,
                        $currentVersion.Minor + 2,
                        $currentVersion.Build
                    ).ToString()

                    # return module information hashtable
                    @{
                        ModulePath     = $currentModule.FullName
                        ModuleName     = $currentModuleName
                        ConfigPath     = $configPath
                        ConfigText     = $configText
                        Config         = $config
                        CurrentVersion = $currentVersion
                        NewVersion     = $newVersion
                        HasREADME      = [IO.File]::Exists(
                            "$($currentModule.FullName)\README.md"
                        )
                        HasLICENSE     = [IO.File]::Exists(
                            "$($currentModule.FullName)\LICENSE"
                        )
                    }
                }
            }
            return
        }

        # process all modules if no specific modules were requested
        foreach ($currentModule in $AllModules) {

            $currentModuleName = $currentModule.Parent.Name
            Microsoft.PowerShell.Utility\Write-Verbose "Processing module: $currentModuleName"

            # construct path to module configuration file
            $configPath = "$($currentModule.FullName)\$currentModuleName.psd1"

            # read and parse module configuration
            $configText = [IO.File]::ReadAllText($configPath)
            $config = Microsoft.PowerShell.Utility\Invoke-Expression -Command ($configText)

            # calculate current and new version numbers
            $currentVersion = [Version]::new($config.ModuleVersion)
            $newVersion = [Version]::new(
                $currentVersion.Major,
                $currentVersion.Minor + 1,
                $currentVersion.Build
            ).ToString()

            # return module information hashtable
            @{
                ModulePath     = $currentModule.FullName
                ModuleName     = $currentModuleName
                ConfigPath     = $configPath
                ConfigText     = $configText
                Config         = $config
                CurrentVersion = $currentVersion
                NewVersion     = $newVersion
                HasREADME      = [IO.File]::Exists(
                    "$($currentModule.FullName)\README.md"
                )
                HasLICENSE     = [IO.File]::Exists(
                    "$($currentModule.FullName)\LICENSE"
                )
            }
        }
    }

    end {
    }
}