# don't remove this line [dontrefactor]

###############################################################################
<#
.SYNOPSIS
Retrieves refactor definitions from GenXdev preferences based on name patterns.

.DESCRIPTION
Searches for and loads refactor definition sets stored in GenXdev preferences.
Each refactor set is stored as a JSON string in a preference with name starting
with 'refactor_set_'. The function deserializes matching sets into objects.

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
One or more name patterns to match against refactor set names. Patterns are
matched against the portion of the preference name after 'refactor_set_' prefix.
Supports wildcards. If omitted, returns all refactor sets.

.EXAMPLE
Get-Refactor -Name "CodeStyle*"
Returns refactor definitions matching pattern "CodeStyle*"

.EXAMPLE
refactor "UnitTest"
Uses alias to find refactor definitions containing "UnitTest"
#>
function Get-Refactor {

    [CmdletBinding()]
    [Alias('refactors')]
    [OutputType([GenXdev.Helpers.RefactorDefinition[]])]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Pattern(s) to search for refactor definitions',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [Alias('PreferenceName')]
        [string[]] $Name = @('*'),
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
        # no initialization needed
    }


    process {
        # get all preference names that could contain refactor definitions
        Microsoft.PowerShell.Utility\Write-Verbose 'Searching for refactor set preferences...'

        # Copy identical parameters for Get-GenXdevPreferenceNames
        $prefNamesParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-GenXdevPreferenceNames' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        $prefNames = GenXdev\Get-GenXdevPreferenceNames @prefNamesParams |
            Microsoft.PowerShell.Core\Where-Object { $_ -like 'refactor_set_*' }
        & {
            foreach ($prefName in $prefNames) {

                Microsoft.PowerShell.Utility\Write-Verbose "Processing preference: $prefName"

                # check each provided name pattern against current preference
                foreach ($pattern in $Name) {

                    # extract name portion after refactor_set_ prefix
                    $actualName = $prefName.Substring('refactor_set_'.Length)

                    # skip if pattern doesn't match the actual name
                    if (-not ($actualName -like $pattern)) {

                        continue
                    }

                    # attempt to load and parse the JSON content
                    # Copy identical parameters for Get-GenXdevPreference
                    $prefParams = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'GenXdev\Get-GenXdevPreference' `
                        -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                        $prefParams.Name = $prefName
                        $existingJson = GenXdev\Get-GenXdevPreference @prefParams -ErrorAction SilentlyContinue

                    # process non-empty JSON content
                    if (-not [string]::IsNullOrWhiteSpace($existingJson)) {
                        try {
                            # deserialize JSON into refactor definition object
                            [GenXdev.Helpers.RefactorDefinition] $refactorSet = (Microsoft.PowerShell.Utility\ConvertFrom-Json $existingJson) -as [GenXdev.Helpers.RefactorDefinition]

                            # check containers
                            if (($null -eq $refactorSet.State.Unselected) -or

                                ($null -eq $refactorSet.State.Selected) -or
                                ($null -eq $refactorSet.State.Refactored) -or
                                ($null -eq $refactorSet.Log)) {

                                $newSet = [GenXdev.Helpers.RefactorDefinition]::new()
                                $newSet.Name = $refactorSet.Name
                                $newSet.Priority = $refactorSet.Priority
                                $newSet.SelectionSettings.Script = (!!$refactorSet.SelectionSettings ? $refactorSet.SelectionSettings.Script : '')

                                $refactorSet = $newSet
                            }

                            Microsoft.PowerShell.Utility\Write-Verbose ('Successfully parsed refactor set from ' +
                                "preference: $prefName")
                            Microsoft.PowerShell.Utility\Write-Output $refactorSet
                        }
                        catch {
                            $errorMsg = "Failed to parse refactor set from $prefName"
                            Microsoft.PowerShell.Utility\Write-Error $errorMsg
                            Microsoft.PowerShell.Utility\Write-Verbose "$errorMsg : $_"
                        }
                    }

                    break;
                }
            }
        }.GetNewClosure() | Microsoft.PowerShell.Utility\Sort-Object -Property Priority -Descending
    }

    end {
    }
}