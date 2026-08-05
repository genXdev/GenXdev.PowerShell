###############################################################################
<#
.SYNOPSIS
Shows a short alphabetical list of all PowerShell verbs.

.DESCRIPTION
Displays PowerShell approved verbs in a comma-separated list. If specific verbs
are provided as input, only matching verbs will be shown. Supports wildcards.

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

.PARAMETER Verb
One or more verb patterns to filter the output. Supports wildcards.
If omitted, all approved verbs are shown.

.EXAMPLE
Show-Verb
Shows all approved PowerShell verbs

.EXAMPLE
Show-Verb -Verb "Get*"
Shows all approved verbs starting with "Get"

.EXAMPLE
showverbs "Set*", "Get*"
Shows all approved verbs starting with "Set" or "Get" using the alias
#>
function Show-Verb {

    [CmdletBinding()]
    [Alias('showverbs')]
    param(
        ########################################################################
        [parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'One or more verb patterns to filter (supports wildcards)',
            Mandatory = $False
        )]
        [SupportsWildcards()]
        [string[]] $Verb = @()
        ########################################################################
    )

    # dont remove this line [dontrefactor]

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose "Starting Show-Verb with filter patterns: $($Verb -join ', ')"
    }


    process {

        # if no specific verbs requested, get all approved verbs
        if ($Verb.Length -eq 0) {

            $verbs = Microsoft.PowerShell.Utility\Get-Verb
        }
        else {
            # filter verbs based on provided patterns
            $verbs = Microsoft.PowerShell.Utility\Get-Verb |
                Microsoft.PowerShell.Core\ForEach-Object -ErrorAction SilentlyContinue {

                    $existingVerb = $PSItem

                    foreach ($verb in $Verb) {

                        if ($existingVerb.Verb -like $verb) {

                            $existingVerb
                        }
                    }
                }
        }

        # sort verbs alphabetically and return as comma-separated string
        ($verbs |
            Microsoft.PowerShell.Utility\Sort-Object { $PSItem.Verb } |
            Microsoft.PowerShell.Core\ForEach-Object Verb -ErrorAction SilentlyContinue) -Join ', '
    }

    end {
    }
}