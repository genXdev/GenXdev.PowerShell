################################################################################
<#
.SYNOPSIS
Retrieves GenXDev modules in dependency order.

.DESCRIPTION
This function returns a list of GenXDev modules arranged in the correct dependency
order to ensure proper module loading. It first retrieves all module information
and then orders them based on their dependencies, starting with core modules and
ending with dependent modules. This ensures modules are loaded in the correct
sequence.

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
One or more module names to filter the results. If not provided, all modules are
returned in their dependency order. The function will maintain the correct
dependency chain even when filtering specific modules.

.EXAMPLE
Get-GenXDevNewModulesInOrderOfDependency -ModuleName "GenXdev.Helpers"

.EXAMPLE
"GenXdev.Console" | Get-GenXDevNewModulesInOrderOfDependency
#>
function Get-GenXDevNewModulesInOrderOfDependency {

    [CmdletBinding()]
    param(
        ########################################################################
        [Alias("Name", "Module")]
        [parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = "One or more module names to filter by"
        )]
        [string[]] $ModuleName = @('GenXdev*')
        ########################################################################
    )

    begin {

        # retrieve all available genxdev module information for processing
        Microsoft.PowerShell.Utility\Write-Verbose "Retrieving GenXDev module information..."
        $Modules = GenXdev\Get-GenXDevModuleInfo
    }

    process {

        # create a new array list to store modules in their dependency order
        [System.Collections.Generic.List[object]] $results = @()

        # helper function to find a module by name in the modules collection
        function findModule($requested) {

            $found = $false;
            foreach ($m in $ModuleName) {
                if ($requested -like "*$($m)*") {
                    $found = $true
                    break;
                }
            }

            if (-not $found) {
                return $null
            }

            $Modules |
                Microsoft.PowerShell.Core\Where-Object -Property "ModuleName" -EQ $requested
        }

        # add modules in dependency order starting with core dependencies
        Microsoft.PowerShell.Utility\Write-Verbose "Adding modules in dependency order..."
        $module = findModule GenXdev
        if ($module) { $null = $results.Add($module) }

        # return modules in their proper dependency order
        Microsoft.PowerShell.Utility\Write-Verbose "Returning $($results.Count) modules"
        $results | Microsoft.PowerShell.Core\ForEach-Object {
            $_
        }
    }

    end {
    }
}
################################################################################