###############################################################################
<#
.SYNOPSIS
Adds an idea item to the README.md file.

.DESCRIPTION
Adds a timestamped idea to the "## Ideas" section of a README.md file.
Can display the modified section and open in Visual Studio Code.

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
The idea text to add. Will be prefixed with current date if not empty.

.PARAMETER Code
Opens the README in Visual Studio Code after modification.

.PARAMETER Show
Displays the modified section after changes.

.PARAMETER UseHomeREADME
Uses README in PowerShell profile directory instead of current location.

.PARAMETER UseOneDriveREADME
Uses README in OneDrive directory instead of current location.

.PARAMETER Priority
Line priority for sorting within the section. Higher values appear first.

.PARAMETER SortByDate
Sort lines by date (yyyyMMdd prefix) instead of priority.

.PARAMETER Ascending
Reverse the sort order. By default, higher priority/newer dates appear first.

.PARAMETER First
Limit the -Show output to the first N lines. Does not affect file storage.

.EXAMPLE
Add-IdeaLineToREADME -Line "Create new PowerShell module" -Show

.EXAMPLE
idea "New feature idea" -UseOneDriveREADME
#>
function Add-IdeaLineToREADME {

    [CmdletBinding()]
    [Alias('idea')]
    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromRemainingArguments = $false,
            HelpMessage = 'The idea text to add'
        )]
        [AllowEmptyString()]
        [string] $Line = '',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Mark idea as completed'
        )]
        [switch] $Done,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open README in Visual Studio Code'
        )]
        [switch] $Code,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the modified section'
        )]
        [switch] $Show,
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
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'Priority for sorting (higher = shown first, default 1)'
        )]
        [int] $Priority = 1,

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
            HelpMessage = 'Limit -Show output to the first N lines'
        )]
        [int] $First = 0,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show only completed (☒) items when used with -Show'
        )]
        [switch] $OnlyCompleted,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Exclude completed (☒) items when used with -Show'
        )]
        [switch] $ExcludeCompleted,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Archive completed items from this section'
        )]
        [switch] $ArchiveCompleted,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'File path for archiving completed items externally'
        )]
        [string] $ArchiveFilePath
        #######################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Starting Add-IdeaLineToREADME'
    }


    process {

        if (![string]::IsNullOrWhiteSpace($Line) -and !$Done) {
            # prefix line with current date
            $Line = "$([DateTime]::Now.ToString('yyyyMMdd')) --> $Line"
            Microsoft.PowerShell.Utility\Write-Verbose "Formatted idea line: $Line"
        }

        # add line to readme using base function
        GenXdev\Add-LineToREADME `
            -Code:$Code `
            -Show:$Show `
            -Section '## Ideas' `
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