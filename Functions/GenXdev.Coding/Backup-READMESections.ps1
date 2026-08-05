###############################################################################
<#
.SYNOPSIS
Archives completed items from all README sections to an external file.

.DESCRIPTION
Moves all completed (☒) items from all tracked README sections (Todoos,
Issues, Ideas, Features, and Release notes) to an external archive file.
Delegates to the individual Backup-Completed* cmdlets for each section.

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
The file path where completed items from all sections will be archived to.

.PARAMETER UseHomeREADME
Uses README in PowerShell profile directory instead of current location.

.PARAMETER UseOneDriveREADME
Uses README in OneDrive directory instead of current location.

.EXAMPLE
Backup-READMESections -Path "C:\temp\full-archive.md"

.EXAMPLE
archive-readme-sections -Path ".\archive.md" -UseHomeREADME
#>
function Backup-READMESections {

    [CmdletBinding()]
    [Alias('archive-readme-sections')]
    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The file path where completed items from all sections will be archived to'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Path,

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
        [switch] $UseOneDriveREADME
    )

    process {
        GenXdev\Backup-CompletedTodoos -Path $Path `
            -UseHomeREADME:$UseHomeREADME `
            -UseOneDriveREADME:$UseOneDriveREADME

        GenXdev\Backup-CompletedIssues -Path $Path `
            -UseHomeREADME:$UseHomeREADME `
            -UseOneDriveREADME:$UseOneDriveREADME

        GenXdev\Backup-CompletedIdeas -Path $Path `
            -UseHomeREADME:$UseHomeREADME `
            -UseOneDriveREADME:$UseOneDriveREADME

        GenXdev\Backup-CompletedFeatures -Path $Path `
            -UseHomeREADME:$UseHomeREADME `
            -UseOneDriveREADME:$UseOneDriveREADME

        GenXdev\Backup-CompletedReleaseNotes -Path $Path `
            -UseHomeREADME:$UseHomeREADME `
            -UseOneDriveREADME:$UseOneDriveREADME
    }

    end {
    }
}
