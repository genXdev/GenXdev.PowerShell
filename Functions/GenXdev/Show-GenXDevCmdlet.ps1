###############################################################################
<#
.SYNOPSIS
Displays GenXdev PowerShell modules with their cmdlets and aliases.

.DESCRIPTION
Lists all installed GenXdev PowerShell modules and their associated cmdlets and
aliases. Uses Get-GenXDevCmdlet to retrieve cmdlet information and optionally
their script positions. Provides filtering and various display options.

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

.PARAMETER Filter
Pattern to filter cmdlets by name. Wildcards (*) are supported and automatically
added if not present. Example: "Get" becomes "*Get*"

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

.PARAMETER Online
When specified, opens the GitHub documentation page instead of console output.

.PARAMETER OnlyAliases
When specified displays only aliases of cmdlets who have them.

.PARAMETER ShowTable
When specified, displays results in a table format with Name and Description.

.PARAMETER OnlyReturnModuleNames
Only return unique module names instead of displaying cmdlet details.

.EXAMPLE
Show-GenXdevCmdlet -CmdletName "Get" -ModuleName "Console" -ShowTable
Lists all cmdlets starting with "Get" in the Console module as a table

.EXAMPLE
cmds get -m console
Lists all cmdlets starting with "Get" in the Console module

.EXAMPLE
Show-GenXdevCmdlet -OnlyReturnModuleNames
Returns only unique module names
#>
function Show-GenXdevCmdlet {

    [CmdletBinding()]
    [Alias('cmds')]
    [OutputType([System.Collections.ArrayList], [void])]

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
        [string] $CmdletName,
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
        [switch] $ExactMatch,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open GitHub documentation instead of console output'
        )]
        [switch] $Online,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'When specified displays only aliases of cmdlets'
        )]
        [Alias('aliases', 'nonboring', 'notlame', 'handyonces')]
        [switch] $OnlyAliases,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Display results in table format'
        )]
        [Alias('table', 'grid')]
        [switch] $ShowTable,
        #######################################################################
        [switch] $PassThru
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose 'Initializing Show-GenXdevCmdlet'

        # initialize results collection
        $results = [System.Collections.ArrayList]::new()

        if (-not ($CmdletName.Contains('*') -or $CmdletName.Contains('?'))) {

            $CmdletName = "*$CmdletName*"
        }
    }


    process {
        $wpDone = $false;
        try {
            # copy identical parameters between functions for passing to Get-GenXDevCmdlet
            $invocationParams = GenXdev\Copy-IdenticalParamValues `
                -FunctionName 'GenXdev\Get-GenXDevCmdlet' `
                -BoundParameters $PSBoundParameters `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # if only module names are requested, return them directly
            if ($OnlyReturnModuleNames) {
                Microsoft.PowerShell.Utility\Write-Verbose 'Returning unique module names directly'
                return GenXdev\Get-GenXDevCmdlet @invocationParams -OnlyReturnModuleNames
            }

            # get cmdlets using Get-GenXDevCmdlet
            [GenXdev.Helpers.GenXdevCmdletInfo[]] $cmdlets = GenXdev\Get-GenXDevCmdlet @invocationParams

            foreach ($cmdletData in $cmdlets) {

                # handle online documentation
                if ($Online) {

                    if (@('GenXdev.Local', 'GenXdev.Scripts').IndexOf($cmdlet.BaseModule) -lt 0) {


                        $url = "https://github.com/genXdev/$($cmdletData.BaseModule)#$($cmdletData.Name)";

                        if ([string]::IsNullOrWhiteSpace($CmdletName)) {

                            $url = "https://github.com/genXdev/$($cmdletData.ModulBaseModuleName)#Cmdlet+Index)";
                        }

                        Microsoft.PowerShell.Utility\Write-Verbose "Opening documentation for $($cmdletData.BaseModule)"

                        if (Microsoft.PowerShell.Core\Get-Module GenXdev.Webbrowser -ErrorAction SilentlyContinue) {

                            GenXdev\Open-Webbrowser -Url $url -SideBySide:(!$wpDone) -RestoreFocus -Monitor ($wpDone ? -1 : 0)
                            $wpDone = $true;
                        }
                        else {
                            Microsoft.PowerShell.Management\Start-Process $url
                        }

                        if ([string]::IsNullOrWhiteSpace($CmdletName)) {

                            return;
                        }
                    }

                    continue
                }

                # filter aliases if OnlyAliases specified
                if ($OnlyAliases) {

                    $cmdletData.Aliases = @($cmdletData.Aliases.Split(',') |
                            Microsoft.PowerShell.Core\ForEach-Object { if ($_.Trim() -notlike '*-*') { $_.Trim() } } |
                            Microsoft.PowerShell.Utility\Select-Object -First 1) -join ', '

                    if ([string]::IsNullOrWhiteSpace($cmdletData.Aliases)) {

                        $cmdletData.Aliases = ''
                        continue
                    }
                }

                # add to results collection
                $null = $results.Add([PSCustomObject]$cmdletData)
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Error processing cmdlets: $_"
        }
    }

    end {
        if ($PassThru) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Returning results as output'
            return $results
        }
        if ($results.Count -eq 0) {
            Microsoft.PowerShell.Utility\Write-Verbose 'No results found matching criteria'
            return
        }

        if ($ShowTable) {

            if ($OnlyAliases) {

                # display as table
                $results |
                    Microsoft.PowerShell.Utility\Select-Object ModuleName, Aliases, Description |
                    Microsoft.PowerShell.Utility\Format-Table -AutoSize
            }
            else {

                # display as table
                $results |
                    Microsoft.PowerShell.Utility\Select-Object ModuleName, Name, Aliases, Description |
                    Microsoft.PowerShell.Utility\Format-Table -AutoSize
            }
        }
        else {
            # group by module and display with formatting
            $results | Microsoft.PowerShell.Utility\Group-Object ModuleName | Microsoft.PowerShell.Core\ForEach-Object {
                "`r`n$($_.Name):" | Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Yellow

                $all = @($_.Group | Microsoft.PowerShell.Core\ForEach-Object {

                        if ($OnlyAliases) {

                            $_.Aliases.Split(',') |
                                Microsoft.PowerShell.Utility\Select-Object -First 1 |
                                Microsoft.PowerShell.Core\ForEach-Object {

                                    if ($_.Trim() -notlike '*-*') {

                                        $_.Trim()
                                    }
                                }
                            }
                            elseif (-not [string]::IsNullOrWhiteSpace($_.Aliases)) {

                                "$($_.Name) --> $($_.Aliases)"
                            }
                            else {

                                $_.Name
                            }
                        })

                    [string]::Join(', ', $all) | Microsoft.PowerShell.Utility\Write-Host -ForegroundColor White
                }
            }
        }
    }