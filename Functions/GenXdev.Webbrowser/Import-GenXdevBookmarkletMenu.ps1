################################################################################
<#
.SYNOPSIS
Imports GenXdev JavaScript bookmarklets into browser bookmark collections.

.DESCRIPTION
This function scans a directory for GenXdev bookmarklet files with the
.bookmarklet.txt extension and imports them into the specified web browser
as bookmarks. The bookmarklets are placed in browser-specific folders and
can be used as interactive tools in web pages. The function supports Edge,
Chrome, and Firefox browsers and provides a preview mode for safety.

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

.PARAMETER SnippetsPath
The file system path to the directory containing bookmarklet snippet files.
Each file should have a .bookmarklet.txt extension and contain JavaScript
code that can be executed as a bookmarklet in web browsers.

.PARAMETER TargetFolder
The target browser bookmark folder where the bookmarklets will be imported.
If not specified, the folder is automatically determined based on the
selected browser type. Uses browser-specific default bookmark bar locations.

.PARAMETER Edge
Specifies Microsoft Edge as the target browser for importing bookmarklets.
When used, bookmarklets are placed in the Edge Bookmarks Bar folder for
easy access from the browser toolbar.

.PARAMETER Chrome
Specifies Google Chrome as the target browser for importing bookmarklets.
When used, bookmarklets are placed in the Chrome Bookmarks Bar folder for
easy access from the browser toolbar.

.PARAMETER Firefox
Specifies Mozilla Firefox as the target browser for importing bookmarklets.
When used, bookmarklets are placed in the Firefox bookmarks folder
structure for browser integration.

.PARAMETER WhatIf
Performs a dry run of the import operation without actually creating any
bookmarks. Displays what bookmarklets would be imported and where they
would be placed for verification before executing the actual import.

.EXAMPLE
Import-GenXdevBookmarkletMenu -Edge

Imports all bookmarklet files from the default snippets directory into
Microsoft Edge's bookmark bar folder.

.EXAMPLE
Import-GenXdevBookmarkletMenu -SnippetsPath "C:\MyBookmarklets" -Chrome -WhatIf

Shows what bookmarklets would be imported from the specified path into
Google Chrome without actually performing the import operation.
#>
function Import-GenXdevBookmarkletMenu {

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'Medium')]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = "Path to directory containing bookmarklet snippet files"
        )]
        [string] $SnippetsPath = "$($MyInvocation.MyCommand.Module.ModuleBase)\Bookmarklets",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = "Target bookmark folder in browser bookmark structure"
        )]
        [string] $TargetFolder = "",
        ###############################################################################
        [Alias('e')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Import bookmarklets into Microsoft Edge browser"
        )]
        [switch] $Edge,
        ###############################################################################
        [Alias('ch')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Import bookmarklets into Google Chrome browser"
        )]
        [switch] $Chrome,
        ###############################################################################
        [Alias('ff')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Import bookmarklets into Mozilla Firefox browser"
        )]
        [switch] $Firefox
        ###############################################################################
    )

    begin {

        # validate the snippets directory exists before proceeding
        if (Microsoft.PowerShell.Management\Test-Path $SnippetsPath) {

            # change to the snippets directory for file operations
            Microsoft.PowerShell.Management\Set-Location $SnippetsPath

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Changed directory to snippets path: ${SnippetsPath}"
            )
        }
        else {

            # output error message when snippets directory is not found
            Microsoft.PowerShell.Utility\Write-Error "Snippets path not found: ${SnippetsPath}"

            return
        }
    }

    process {

        # find all bookmarklet files with the expected extension
        $bookmarkletFiles = Microsoft.PowerShell.Management\Get-ChildItem -Filter "*.bookmarklet.txt"

        # check if any bookmarklet files were found in the directory
        if ($bookmarkletFiles.Count -eq 0) {

            Microsoft.PowerShell.Utility\Write-Warning "No bookmarklet files found in ${SnippetsPath}"

            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Found $($bookmarkletFiles.Count) snippet files to import"
        )

        # determine target folder path based on selected browser
        if ([string]::IsNullOrEmpty($TargetFolder)) {

            if ($Edge) {

                # set default Edge bookmark bar folder path
                $TargetFolder = "Edge\Bookmarks Bar\▼"

            }
            elseif ($Chrome) {

                # set default Chrome bookmark bar folder path
                $TargetFolder = "Chrome\Bookmarks Bar\▼"

            }
            elseif ($Firefox) {

                # set default Firefox bookmark folder path
                $TargetFolder = "Firefox\▼"

            }
            else {

                # default to Edge browser when no browser is specified
                $TargetFolder = "Edge\Bookmarks Bar\▼"

                $Edge = $true
            }
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Target folder: ${TargetFolder}"
        )

        # create bookmark objects from each bookmarklet file
        $bookmarksToImport = $bookmarkletFiles |
            Microsoft.PowerShell.Core\ForEach-Object {

                # read the javascript content from the bookmarklet file
                $bookmarkletUrl = Microsoft.PowerShell.Management\Get-Content $_.FullName -Raw

                # extract bookmark name by removing the file extension
                $bookmarkName = $_.BaseName -replace '\.bookmarklet$', ''

                # create structured bookmark object for import operation
                [PSCustomObject]@{
                    Name         = $bookmarkName
                    URL          = $bookmarkletUrl.Trim()
                    Folder       = $TargetFolder
                    DateAdded    = $_.CreationTime
                    DateModified = $_.LastWriteTime
                }
            }

        # check if user wants to proceed with the import operation
        if (-not $PSCmdlet.ShouldProcess(
            "Import $($bookmarksToImport.Count) bookmarklets to ${TargetFolder}",
            "Import bookmarklets",
            "Confirm Bookmarklet Import")) {

            return
        }

        # prepare parameters for the import browser bookmarks function
        $importParams = @{
            Bookmarks = $bookmarksToImport
        }

        # add browser-specific parameters to the import operation
        if ($Edge) {
            $importParams.Edge = $true
        }

        if ($Chrome) {
            $importParams.Chrome = $true
        }

        if ($Firefox) {
            $importParams.Firefox = $true
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Importing $($bookmarksToImport.Count) bookmarks to folder " +
            "'${TargetFolder}'"
        )

        # execute the bookmark import operation with error handling
        try {

            GenXdev\Import-BrowserBookmarks @importParams -Verbose

            Microsoft.PowerShell.Utility\Write-Host (
                "Successfully imported snippets as bookmarks!"
            ) -ForegroundColor Green

            Microsoft.PowerShell.Utility\Write-Host (
                "Check your browser's '${TargetFolder}' folder for the " +
                "imported bookmarks."
            ) -ForegroundColor Cyan

        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error "Failed to import bookmarks: ${_}"
        }
    }

    end {

         # check if user wants to proceed with the import operation
        if (-not $PSCmdlet.ShouldProcess(
            "Close any open browser instances",
            "Close browsers",
            "Confirm Browser Closure")) {

            return
        }
        $params = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Close-Webbrowser' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue);

        GenXdev\Close-Webbrowser @params
    }
}
################################################################################