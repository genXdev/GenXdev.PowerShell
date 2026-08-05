###############################################################################
<#
.SYNOPSIS
Adds a todo item to the README.md file.

.DESCRIPTION
Adds a timestamped todo item to the "## Todoos" section of a README.md file.
The todo items can be marked as done and the modified section can be displayed.
Each new todo item is automatically timestamped unless marking as done.

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

.PARAMETER Line
The todo item text to add. Will be prefixed with current date if not empty.

.PARAMETER Code
Opens the README in Visual Studio Code after modification.

.PARAMETER Show
Displays the modified section after changes.

.PARAMETER Done
Marks the specified todo item as completed.

.PARAMETER SortByDate
Sort lines by date (yyyyMMdd prefix) instead of priority.

.PARAMETER Ascending
Reverse the sort order. By default, higher priority/newer dates appear first.

.PARAMETER First
Limit the -Show output to the first N lines. Does not affect file storage.

.PARAMETER UseHomeREADME
Uses README in PowerShell profile directory instead of current location.

.PARAMETER UseOneDriveREADME
Uses README in OneDrive directory instead of current location.

.EXAMPLE
Add-TodoLineToREADME -Line "Implement new feature" -Show -Code

.EXAMPLE
todo "Fix bug" -Done
#>
function Add-TodoLineToREADME {

    [CmdletBinding()]
    [Alias('todo')]
    param(
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromRemainingArguments = $false,
            HelpMessage = 'The todo item text to add'
        )]
        [AllowEmptyString()]
        [string] $Line = '',

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open README in Visual Studio Code'
        )]
        [switch] $Code,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the modified section'
        )]
        [switch] $Show,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Mark todo item as completed'
        )]
        [switch] $Done,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use README in PowerShell profile directory'
        )]
        [switch] $UseHomeREADME,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use README in OneDrive directory'
        )]
        [switch] $UseOneDriveREADME,

        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'Priority for sorting (higher = shown first, default 1)'
        )]
        [int] $Priority = 1,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sort lines by date (yyyyMMdd prefix) instead of priority'
        )]
        [switch] $SortByDate,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Reverse the sort order (ascending instead of descending)'
        )]
        [switch] $Ascending,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Limit -Show output to the first N lines'
        )]
        [int] $First = 0,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show only completed (☒) items when used with -Show'
        )]
        [switch] $OnlyCompleted,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Exclude completed (☒) items when used with -Show'
        )]
        [switch] $ExcludeCompleted,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Archive completed items from this section'
        )]
        [switch] $ArchiveCompleted,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'File path for archiving completed items externally'
        )]
        [string] $ArchiveFilePath
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose "Starting Add-TodoLineToREADME with parameters: $($PSBoundParameters |
            Microsoft.PowerShell.Utility\ConvertTo-Json)"
    }


    process {

        # only add timestamp if line is not empty and not marking as done
        if (![string]::IsNullOrWhiteSpace($Line) -and !$Done) {

            # prefix line with current date in yyyyMMdd format
            $Line = "$([DateTime]::Now.ToString('yyyyMMdd')) --> $Line"
            Microsoft.PowerShell.Utility\Write-Verbose "Formatted todo line: $Line"
        }

        # add line to readme using base function with specified parameters
        GenXdev\Add-LineToREADME `
            -Code:$Code `
            -Show:$Show `
            -Section '## Todoos' `
            -Line $Line `
            -Done:$Done `
            -UseHomeREADME:$UseHomeREADME `
            -UseOneDriveREADME:$UseOneDriveREADME `
            -Priority $Priority `
            -SortByDate:$SortByDate `
            -Ascending:$Ascending `
            -OnlyCompleted:$OnlyCompleted `
            -ExcludeCompleted:$ExcludeCompleted `
            -ArchiveCompleted:$ArchiveCompleted `
            -ArchiveFilePath $ArchiveFilePath `
            -First $First
    }

    end {
    }
}