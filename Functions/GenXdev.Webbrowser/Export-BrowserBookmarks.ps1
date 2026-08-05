###############################################################################
<#
.SYNOPSIS
Exports browser bookmarks to a JSON file.

.DESCRIPTION
The Export-BrowserBookmarks cmdlet exports bookmarks from a specified web browser
(Microsoft Edge, Google Chrome, or Mozilla Firefox) to a JSON file. Only one
browser type can be specified at a time. The bookmarks are exported with full
preservation of their structure and metadata.

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

.PARAMETER OutputFile
The path to the JSON file where the bookmarks will be saved. The path will be
expanded to a full path before use.

.PARAMETER Chrome
Switch parameter to export bookmarks from Google Chrome browser.

.PARAMETER Edge
Switch parameter to export bookmarks from Microsoft Edge browser.

.PARAMETER Firefox
Switch parameter to export bookmarks from Mozilla Firefox browser.

.EXAMPLE
Export-BrowserBookmarks -OutputFile "C:\MyBookmarks.json" -Edge

.EXAMPLE
Export-BrowserBookmarks "C:\MyBookmarks.json" -Chrome
#>
function Export-BrowserBookmarks {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'Path to the JSON file where bookmarks will be saved'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$OutputFile,
        ########################################################################
        [Alias('ch')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Export bookmarks from Google Chrome'
        )]
        [switch]$Chrome,
        ########################################################################
        [Alias('e')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Export bookmarks from Microsoft Edge'
        )]
        [switch]$Edge,
        ########################################################################
        [Alias('ff')]
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Firefox',
            HelpMessage = 'Export bookmarks from Mozilla Firefox'
        )]
        [switch]$Firefox
        ########################################################################
    )

    begin {
        # convert relative or partial path to full filesystem path
        $outputFilePath = GenXdev\Expand-Path $OutputFile

        # inform user about the output destination
        Microsoft.PowerShell.Utility\Write-Verbose "Exporting bookmarks to: $outputFilePath"
    }


    process {

        # initialize empty hashtable for browser selection parameters
        $bookmarksArguments = @{}

        # set appropriate flag based on selected browser type
        if ($Chrome) {
            $bookmarksArguments['Chrome'] = $true
            Microsoft.PowerShell.Utility\Write-Verbose 'Exporting Chrome bookmarks'
        }
        if ($Edge) {
            $bookmarksArguments['Edge'] = $true
            Microsoft.PowerShell.Utility\Write-Verbose 'Exporting Edge bookmarks'
        }
        if ($Firefox) {
            $bookmarksArguments['Firefox'] = $true
            Microsoft.PowerShell.Utility\Write-Verbose 'Exporting Firefox bookmarks'
        }

        # retrieve bookmarks and save them as formatted json to the output file
        GenXdev\Get-BrowserBookmark @bookmarksArguments |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 100 |
            Microsoft.PowerShell.Management\Set-Content -LiteralPath $outputFilePath -Force

        Microsoft.PowerShell.Utility\Write-Verbose 'Bookmarks exported successfully'
    }

    end {
    }
}