###############################################################################
<#
.SYNOPSIS
Adds a feature line to the README file with a timestamp.

.DESCRIPTION
Adds a feature line to the specified README file, prefixed with the current date
in yyyyMMdd format. The line can be formatted as code and optionally displayed.

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
The feature description text to add to the README file.

.PARAMETER Code
Switch to format the line as code in the README file.

.PARAMETER Show
Switch to display the README file after adding the line.

.PARAMETER UseHomeREADME
Switch to use the README file in the home directory.

.PARAMETER UseOneDriveREADME
Switch to use the README file in the OneDrive directory.

.PARAMETER Priority
Line priority for sorting within the section. Higher values appear first.

.PARAMETER SortByDate
Sort lines by date (yyyyMMdd prefix) instead of priority.

.PARAMETER Ascending
Reverse the sort order. By default, higher priority/newer dates appear first.

.PARAMETER First
Limit the -Show output to the first N lines. Does not affect file storage.

.EXAMPLE
Add-FeatureLineToREADME -Line "Added new Git feature"

.EXAMPLE
feature "Added new Git feature" -Code -Show
#>
function Add-FeatureLineToREADME {

    [CmdletBinding()]
    [Alias('feature')]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            ValueFromRemainingArguments = $false,
            Mandatory = $false,
            HelpMessage = 'The feature description text to add'
        )]
        [string] $Line = '',

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Format the line as code'
        )]
        [switch] $Code,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Display the README after adding the line'
        )]
        [switch] $Show,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use README in home directory'
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
            HelpMessage = 'Mark feature as completed'
        )]
        [switch] $Done,
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
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose "Starting Add-FeatureLineToREADME with line: $Line"
    }


    process {
        # format the line with timestamp if not empty
        if ([string]::IsNullOrWhiteSpace($Line) -eq $false -and !$Done) {
            $Line = "$([DateTime]::Now.ToString('yyyyMMdd')) --> $Line"
            Microsoft.PowerShell.Utility\Write-Verbose "Formatted line: $Line"
        }

        # add the line to the README file
        GenXdev\Add-LineToREADME `
            -Code:$Code `
            -Show:$Show `
            -Section '## Features' `
            -Line $Line `
            -Done:$Done `
            -UseHomeREADME:$UseHomeREADME `
            -UseOneDriveREADME:$UseOneDriveREADME `
            -Priority $Priority `
            -SortByDate:$SortByDate `
            -Ascending:$Ascending `
            -First $First
    }

    end {
    }
}