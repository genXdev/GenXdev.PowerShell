###############################################################################
<#
.SYNOPSIS
Displays todo items from a README.md file.

.DESCRIPTION
Shows all todo items from the "## Todoos" section of a README.md file. Can use
either the README in the current location, PowerShell profile directory, or
OneDrive directory.

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

.PARAMETER UseHomeREADME
Use README.md from PowerShell profile directory instead of current location.

.PARAMETER UseOneDriveREADME
Use README.md from OneDrive directory instead of current location.

.PARAMETER SortByDate
Sort lines by date (yyyyMMdd prefix) instead of priority.

.PARAMETER Ascending
Reverse the sort order. By default, higher priority/newer dates appear first.

.PARAMETER First
Limit the output to the first N lines.

.EXAMPLE
Todoos -UseHomeREADME

.EXAMPLE
Todoos -UseOneDriveREADME
#>
function Get-Todoos {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseBOMForUnicodeEncodedFile', '')]
    [Alias('todoos')]
    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use README in PowerShell profile directory'
        )]
        [switch] $UseHomeREADME,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use README in OneDrive directory'
        )]
        [switch] $UseOneDriveREADME,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sort lines by date (yyyyMMdd prefix) instead of priority'
        )]
        [switch] $SortByDate,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Reverse the sort order (ascending instead of descending)'
        )]
        [switch] $Ascending,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Limit output to the first N lines'
        )]
        [int] $First = 0,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show only completed (☒) items'
        )]
        [switch] $OnlyCompleted,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Exclude completed (☒) items, showing only incomplete'
        )]
        [switch] $ExcludeCompleted
        #######################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Starting Todoos function'
    }


    process {

        # display todos using base function
        GenXdev\Add-TodoLineToREADME `
            -Show `
            -SortByDate:$SortByDate `
            -Ascending:$Ascending `
            -OnlyCompleted:$OnlyCompleted `
            -ExcludeCompleted:$ExcludeCompleted `
            -First $First `
            -UseHomeREADME:$UseHomeREADME `
            -UseOneDriveREADME:$UseOneDriveREADME
    }

    end {
    }
}