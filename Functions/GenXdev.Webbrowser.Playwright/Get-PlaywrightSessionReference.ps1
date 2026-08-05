###############################################################################
<#
.SYNOPSIS
Gets a reference to the current Playwright browser session.

.DESCRIPTION
Returns a hashtable containing the Playwright Page, BrowserContext, and session
data for the current browser page. This reference can be used with
Invoke-WebbrowserEvaluation -ByReference to target a specific page.

The browser type can be specified using the -Edge, -Chrome, -Chromium,
-Firefox, or -Webkit switches. If no switch is specified, Chromium is preferred.

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

.PARAMETER Edge
Prefer Microsoft Edge browser session.

.PARAMETER Chrome
Prefer Google Chrome browser session.

.PARAMETER Chromium
Prefer the default Chromium-based browser session.

.PARAMETER Firefox
Prefer Firefox browser session.

.PARAMETER Webkit
Prefer WebKit browser session.

.EXAMPLE
Get a reference to the current browser session
$sessionRef = Get-PlaywrightSessionReference

.EXAMPLE
Store the reference and use it later to execute JavaScript
$ref = Get-PlaywrightSessionReference
Invoke-WebbrowserEvaluation "document.title" -ByReference $ref
#>
function Get-PlaywrightSessionReference {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [OutputType([hashtable])]
    param(
        ###############################################################################
        [Alias('e')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prefer Microsoft Edge browser session'
        )]
        [switch] $Edge,
        ###############################################################################
        [Alias('ch')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prefer Google Chrome browser session'
        )]
        [switch] $Chrome,
        ###############################################################################
        [Alias('c')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Prefer Microsoft Edge or Google Chrome, ' +
                'depending on what the default browser is')
        )]
        [switch] $Chromium,
        ###############################################################################
        [Alias('ff')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prefer Firefox browser session'
        )]
        [switch] $Firefox,
        ###############################################################################
        [Alias('wk')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prefer WebKit browser session'
        )]
        [switch] $Webkit
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose 'Checking for active Playwright browser session'

        # create global data storage if it doesn't exist
        if ($Global:Data -isnot [Hashtable]) {
            $global:Data = @{}
        }
        # determine preferred browser type from switches
        $preferredType = if ($Webkit) {
            'WebKitPlaywright'
        }
        elseif ($Firefox) {
            'FirefoxPlaywright'
        }
        else {
            # Edge, Chrome, Chromium, or default all map to ChromiumNormal
            'ChromiumNormal'
        }
    }


    process {

        # resolve the active Playwright browser page
        $activeBrowser = if (
            $Global:GenXdevPlaywright.ContainsKey($preferredType)) {
            $Global:GenXdevPlaywright[$preferredType]
        }
        elseif ($Global:GenXdevPlaywright.ContainsKey('ChromiumNormal')) {
            $Global:GenXdevPlaywright['ChromiumNormal']
        }
        elseif ($Global:GenXdevPlaywright.ContainsKey('ChromeNormal')) {
            $Global:GenXdevPlaywright['ChromeNormal']
        }
        elseif ($Global:GenXdevPlaywright.ContainsKey('EdgeNormal')) {
            $Global:GenXdevPlaywright['EdgeNormal']
        }
        elseif ($Global:GenXdevPlaywright.ContainsKey('ChromiumPlaywright')) {
            $Global:GenXdevPlaywright['ChromiumPlaywright']
        }
        elseif ($Global:GenXdevPlaywright.ContainsKey('FirefoxPlaywright')) {
            $Global:GenXdevPlaywright['FirefoxPlaywright']
        }
        elseif ($Global:GenXdevPlaywright.ContainsKey('WebKitPlaywright')) {
            $Global:GenXdevPlaywright['WebKitPlaywright']
        }
        else {
            $null
        }

        if (-not $activeBrowser) {
            throw 'No Playwright browser is running. Use Open-PlayWrightBrowser to launch one first.'
        }

        Microsoft.PowerShell.Utility\Write-Verbose 'Found active Playwright session'

        if ($activeBrowser.Page.IsClosed) {
            throw 'Browser page has been closed. Use Open-PlayWrightBrowser to launch a new session.'
        }

        # build session reference object for backward compatibility
        $sessionObj = [PSCustomObject]@{
            Url         = $activeBrowser.Page.Url
            Page        = $activeBrowser.Page
            Context     = $activeBrowser.Context
            BrowserType = $activeBrowser.BrowserType
            data        = $global:Data
        }

        # set global variables for backward compatibility
        $Global:playwrightController = $activeBrowser.Page
        $Global:chromeSession = $sessionObj

        return $sessionObj
    }

    end {
    }
}