###############################################################################
<#
.SYNOPSIS
Removes refactor sets from GenXdev preferences system.

.DESCRIPTION
Manages refactor sets in the GenXdev preferences system by removing specified
entries. Works with both custom and default refactor sets. Default sets are
protected unless explicitly allowed for removal. All refactor sets are
identified by the prefix "refactor_set_" in the preferences system.

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

.PARAMETER Name
One or more name patterns used to match refactor sets for removal. Supports
wildcard patterns like "*" and "?" for flexible matching. Multiple patterns can
be provided to target specific sets.

.PARAMETER RemoveDefault
Switch parameter that, when enabled, allows the removal of protected default or
standard refactor sets. By default, these sets are protected from deletion.

.EXAMPLE
Remove-Refactor -Name "CustomRefactor" -RemoveDefault
Removes a specific refactor set named "CustomRefactor" and allows removal
of default sets if matched

#>
function Remove-Refactor {

    [CmdletBinding(SupportsShouldProcess)]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The name of the refactor, accepts wildcards',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [Alias('PreferenceName')]
        [string[]] $Name,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'All',
            HelpMessage = 'Switch to also remove the standard refactor set'
        )]
        [switch] $RemoveDefault,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The default value if preference is not found'
        )]
        [AllowNull()]
        [AllowEmptyString()]
        [Alias('DefaultPreference')]
        [string] $DefaultValue,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for Data ' +
                'preferences like Language, Database paths, etc')
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear the session setting (Global variable) before ' +
                'retrieving')
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session for ' +
                'Data preferences like Language, Database paths, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ########################################################################
    )

    begin {

        # log operation start and search patterns for troubleshooting
        Microsoft.PowerShell.Utility\Write-Verbose ('Starting refactor removal process')
        Microsoft.PowerShell.Utility\Write-Verbose ("Search patterns to process: $($Name -join ', ')")
    }


    process {

        # copy identical parameters for GenXdev\Get-GenXdevPreferenceNames
        $params = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-GenXdevPreferenceNames' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # retrieve all preference names matching the refactor_set pattern
        GenXdev\Get-GenXdevPreferenceNames @params |
            Microsoft.PowerShell.Core\Where-Object { $_ -like 'refactor_set_*' } |
            Microsoft.PowerShell.Core\ForEach-Object {

                # store current preference name for processing
                $preferenceName = $_
                Microsoft.PowerShell.Utility\Write-Verbose "Processing preference: $preferenceName"

                # extract refactor name by removing the standard prefix
                $refactorName = $preferenceName.Substring('refactor_set_'.Length)

                # process each provided name pattern against current refactor
                $Name | Microsoft.PowerShell.Core\ForEach-Object {

                    # skip if pattern doesn't match current refactor name
                    if (-not ($refactorName -like $_)) {
                        return
                    }

                    # copy identical parameters for Get-GenXdevPreference
                    $getParams = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'GenXdev\Get-GenXdevPreference' `
                        -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                            -Scope Local `
                            -ErrorAction SilentlyContinue)

                    # retrieve current preference value
                    $preferenceValue = GenXdev\Get-GenXdevPreference `
                        @getParams `
                        -Name $preferenceName `
                        -ErrorAction SilentlyContinue

                    # only process if preference exists and has a value
                    if (-not [string]::IsNullOrWhiteSpace($preferenceValue)) {

                        # confirm removal with user before proceeding
                        if ($PSCmdlet.ShouldProcess(
                                "Refactor set: $refactorName",
                                'Remove')) {

                            Microsoft.PowerShell.Utility\Write-Verbose ('Removing refactor set: ' +
                                "$refactorName")

                            # copy identical parameters for Remove-GenXdevPreference
                            $removeParams = GenXdev\Copy-IdenticalParamValues `
                                -BoundParameters $PSBoundParameters `
                                -FunctionName 'GenXdev\Remove-GenXdevPreference' `
                                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                                    -Scope Local `
                                    -ErrorAction SilentlyContinue)

                            # remove preference from system
                            $null = GenXdev\Remove-GenXdevPreference `
                                @removeParams `
                                -Name $preferenceName `
                                -RemoveDefault:$RemoveDefault
                        }
                    }
                }
            }
    }

    end {

        Microsoft.PowerShell.Utility\Write-Verbose 'Refactor removal process completed'
    }
}