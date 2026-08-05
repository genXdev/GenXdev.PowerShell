################################################################################
<#
.SYNOPSIS
Retrieves all GenXDev modules from a specified path.

.DESCRIPTION
This function searches through a directory structure for GenXdev modules,
excluding any with '.local' in the name. For each valid module found, it returns
the most recent version folder (1.x) that contains a valid module manifest
(.psd1) file.

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

.PARAMETER Path
The root directory to search for GenXdev modules. If not specified, defaults to
the parent directory of the script's location.

.EXAMPLE
Get-GenXDevModule -Path "C:\PowerShell\Modules"

.EXAMPLE
Get-GenXDevModule "C:\PowerShell\Modules"
#>
function Get-GenXDevModule {

    [CmdletBinding()]

    param(
        ########################################################################
        [Alias("RootPath", "FullPath")]
        [parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "The root path to search for GenXdev modules"
        )]
        [string] $Path,
        ########################################################################
        [switch] $IncludeLocal
    )

    begin {

        # if no path provided, navigate up 4 levels from script location
        if (-not $Path) {

            $Path = (GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\")
        }

        # log the path being searched
        Microsoft.PowerShell.Utility\Write-Verbose "Searching for GenXdev modules in: $Path"
    }


    process {

        # enumerate all directories starting with 'GenXdev'
        Microsoft.PowerShell.Management\Get-ChildItem -Path "$Path\GenXdev*" -Directory |
            Microsoft.PowerShell.Core\ForEach-Object {

                # store module information for processing
                $moduleName = $_.Name
                $moduleRootPath = $_.FullName

                # skip modules containing '.local' in their name
                if ((-not $IncludeLocal) -and ($moduleName.ToLowerInvariant().Contains('.local'))) {
                    Microsoft.PowerShell.Utility\Write-Verbose "Skipping local module: $moduleName"
                    return
                }

                # find the highest numbered 1.x version directory with valid psd1
                Microsoft.PowerShell.Management\Get-ChildItem -Path "$moduleRootPath\3.*" -Directory |
                    Microsoft.PowerShell.Utility\Sort-Object -Property Name -Descending |
                    Microsoft.PowerShell.Utility\Select-Object -First 1 |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        # verify existence of module manifest
                        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath "$($_.FullName)\$moduleName.psd1") {

                            Microsoft.PowerShell.Utility\Write-Verbose "Found valid module: $moduleName in $($_.FullName)"
                            $_
                        }
                    }
                }
    }

    end {
    }
}
################################################################################