###############################################################################
<#
.SYNOPSIS
Archives completed todo items from the README to an external file.

.DESCRIPTION
Moves all completed (☒) todo items from the "## Todoos" section of the
README.md file to an external archive file. This keeps the README clean
while preserving a history of completed todo items.

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
The file path where completed todo items will be archived to.

.PARAMETER UseHomeREADME
Uses README in PowerShell profile directory instead of current location.

.PARAMETER UseOneDriveREADME
Uses README in OneDrive directory instead of current location.

.EXAMPLE
Backup-CompletedTodoos -Path "C:\temp\todo-archive.md"

.EXAMPLE
archive-todoos -Path ".\archive.md" -UseHomeREADME
#>
function Backup-CompletedTodoos {

    [CmdletBinding()]
    [Alias('archive-todoos')]
    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The file path where completed todo items will be archived to'
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

    begin {
        $params = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Add-LineToREADME' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        $params['Section'] = '## Todoos'
        $params['Line'] = ''
        $params['ArchiveCompleted'] = $true
        $params['ArchiveFilePath'] = $Path
    }

    process {
        GenXdev\Add-LineToREADME @params
    }

    end {
    }
}
