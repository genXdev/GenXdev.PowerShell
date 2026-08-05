<#
.SYNOPSIS
Selects a browser tab from running Playwright-managed browsers.

.DESCRIPTION
Lists and selects browser tabs from all running Playwright-managed
browser instances. When called without selection criteria, displays
a table of all available tabs across all browser types. Supports
selection by numeric index, URL pattern, or direct page reference.

When a tab is selected, sets $Global:playwrightController and
$Global:chromeSession for backward compatibility with other
Webbrowser cmdlets.

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

.PARAMETER Id
Numeric tab index to select, shown when listing available tabs.

.PARAMETER Name
URL pattern to match against open tabs. Selects the first tab whose
URL contains the specified pattern. Supports wildcards.

.PARAMETER ByReference
Direct page reference from a Playwright browser state.

.PARAMETER Edge
Filter tabs to Microsoft Edge (Chromium-based) browser instances.

.PARAMETER Chrome
Filter tabs to Google Chrome (Chromium-based) browser instances.

.PARAMETER Chromium
Filter tabs to Chromium-based browser instances (Edge or Chrome).

.PARAMETER Firefox
Filter tabs to Firefox browser instances.

.PARAMETER PlayWright
Filter tabs to all Playwright-managed browser types.

.PARAMETER Webkit
Filter tabs to WebKit browser instances.

.PARAMETER All
Show tabs from all browser types (no filtering).

.PARAMETER Force
Skip confirmation and select the first matching tab automatically.

.EXAMPLE
Select-WebbrowserTab
Lists all open tabs across all Playwright browser types.

.EXAMPLE
Select-WebbrowserTab -Id 2
Selects the tab at index 2 from the list.

.EXAMPLE
st -Name "github.com"
Selects the first tab whose URL contains "github.com".

.EXAMPLE
st -Firefox -Id 0
Selects the first tab from the Firefox browser.
#>
function Select-WebbrowserTab {

    [CmdletBinding(DefaultParameterSetName = 'ById')]
    [OutputType([PSCustomObject])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidGlobalVars', '')]
    [Alias('st')]

    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ParameterSetName = 'ById',
            HelpMessage = 'Tab index from the shown list'
        )]
        [ValidateRange(0, [int]::MaxValue)]
        [int] $Id = -1,

        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'ByName',
            HelpMessage = 'Selects first tab containing this text in its URL'
        )]
        [Alias('Pattern')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string] $Name,

        ########################################################################
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'ByReference',
            HelpMessage = 'Direct page reference from a Playwright browser state'
        )]
        [ValidateNotNull()]
        [object] $ByReference,

        ########################################################################
        [Alias('e')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter tabs to Microsoft Edge browser instances'
        )]
        [switch] $Edge,

        ########################################################################
        [Alias('ch')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter tabs to Google Chrome browser instances'
        )]
        [switch] $Chrome,

        ########################################################################
        [Alias('c')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Filter tabs to Chromium-based browser ' +
                'instances (Edge or Chrome)')
        )]
        [switch] $Chromium,

        ########################################################################
        [Alias('ff')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter tabs to Firefox browser instances'
        )]
        [switch] $Firefox,

        ########################################################################
        [Alias('pw')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter tabs to all Playwright-managed browser types'
        )]
        [switch] $PlayWright,

        ########################################################################
        [Alias('wk')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter tabs to WebKit browser instances'
        )]
        [switch] $Webkit,

        ########################################################################
        [Alias('a')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show tabs from all browser types (no filtering)'
        )]
        [switch] $All,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip confirmation and select first matching tab'
        )]
        [switch] $Force
        ########################################################################
    )

    begin {
        # ensure global state container exists
        if ($Global:GenXdevPlaywright -isnot [Hashtable]) {
            $Global:GenXdevPlaywright = @{}
        }

        # resolve browser switches to filter types
        $browserFilter = if ($All) {
            $null
        }
        elseif ($Webkit) {
            @('WebKitPlaywright')
        }
        elseif ($Firefox) {
            @('FirefoxPlaywright')
        }
        elseif ($PlayWright) {
            @('ChromeNormal', 'EdgeNormal', 'ChromiumNormal',
                'ChromiumPlaywright', 'FirefoxPlaywright', 'WebKitPlaywright')
        }
        elseif ($Edge) {
            @('EdgeNormal')
        }
        elseif ($Chrome) {
            @('ChromeNormal')
        }
        elseif ($Chromium) {
            @('ChromeNormal', 'EdgeNormal', 'ChromiumNormal',
                'ChromiumPlaywright')
        }
        else {
            $null
        }

        # remove stale/disconnected browsers from global state
        $staleKeys = [System.Collections.Generic.List[string]]::new()
        foreach ($key in $Global:GenXdevPlaywright.Keys) {
            $state = $Global:GenXdevPlaywright[$key]
            if ($state.Browser -and -not $state.Browser.IsConnected) {
                $staleKeys.Add($key)
            }
        }
        foreach ($key in $staleKeys) {
            $null = $Global:GenXdevPlaywright.Remove($key)
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Removed stale browser state: ${key}"
            )
        }

        ########################################################################
        # Helper: Select a page and set global state for backward compatibility
        ########################################################################
        function SelectPage {
            param([PSCustomObject] $TabInfo)

            $page = $TabInfo.Page
            $state = $TabInfo.State

            # set backward-compat globals
            $Global:playwrightController = $page
            $Global:chrome = $state

            # build session object to mimic old CDP session format
            $Global:chromeSession = [PSCustomObject]@{
                id    = ''
                url   = $page.Url
                title = $TabInfo.Title
            }

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Selected tab [$($TabInfo.Index)] $($TabInfo.BrowserType): " +
                $TabInfo.Url
            )
        }
    }

    process {
        ########################################################################
        # Collect all pages from all running Playwright browser types
        ########################################################################
        function GatherAllPages {
            $allPages = [System.Collections.Generic.List[PSObject]]::new()
            $index = 0

            foreach ($browserKey in $Global:GenXdevPlaywright.Keys) {
                $state = $Global:GenXdevPlaywright[$browserKey]

                # skip if browser not connected
                if (-not ($state.Browser -and $state.Browser.IsConnected)) {
                    continue
                }

                # filter by browser type if specified
                if ($browserFilter -and $browserKey -notin $browserFilter) {
                    continue
                }

                try {
                    # gather pages from all contexts of this browser
                    $contexts = $state.Browser.Contexts
                    foreach ($ctx in $contexts) {
                        foreach ($page in $ctx.Pages) {
                            $url = $page.Url
                            $title = ''
                            try {
                                $title = $page.TitleAsync().
                                    GetAwaiter().GetResult()
                            }
                            catch { }

                            $allPages.Add([PSCustomObject]@{
                                    PSTypeName  = 'GenXdev.Webbrowser.TabInfo'
                                    Index       = $index
                                    BrowserType = $browserKey
                                    Url         = $url
                                    Title       = $title
                                    Page        = $page
                                    Context     = $ctx
                                    State       = $state
                                })
                            $index++
                        }
                    }
                }
                catch { }
            }

            return $allPages.ToArray()
        }

        ########################################################################
        # Format tab list for display (old-style Show-TabList format)
        ########################################################################
        function Format-TabList {
            param([array] $pages)

            $pages | Microsoft.PowerShell.Core\ForEach-Object {
                $isCurrent = ($null -ne $Global:playwrightController) -and
                    ($_.Page -eq $Global:playwrightController)

                [PSCustomObject]@{
                    id          = $_.Index
                    A           = $isCurrent ? '*' : ' '
                    BrowserType = $_.BrowserType
                    url         = $_.Url
                    title       = $_.Title
                }
            }
        }

        ########################################################################
        # Handle ByReference — direct page assignment
        ########################################################################
        if ($PSCmdlet.ParameterSetName -eq 'ByReference') {
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Selecting tab by direct reference'
            )

            $Global:playwrightController = $ByReference

            # build minimal session object for backward compat
            $Global:chromeSession = [PSCustomObject]@{
                id    = ''
                url   = $ByReference.Url
                title = ''
            }

            return $ByReference
        }

        ########################################################################
        # Gather all active pages
        ########################################################################
        $allPages = GatherAllPages

        if ($allPages.Count -eq 0) {
            Microsoft.PowerShell.Utility\Write-Warning (
                'No Playwright browser tabs found. Start a browser with ' +
                'Open-PlayWrightBrowser or Open-Webbrowser -PlayWright first.'
            )
            return
        }

        ########################################################################
        # Handle -Name selection
        ########################################################################
        if ($PSCmdlet.ParameterSetName -eq 'ByName') {
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Selecting tab by name pattern: ${Name}"
            )

            $matched = $allPages |
                Microsoft.PowerShell.Core\Where-Object { $_.Url -like "*${Name}*" } |
                Microsoft.PowerShell.Utility\Select-Object -First 1

            if (-not $matched) {
                Microsoft.PowerShell.Utility\Write-Warning (
                    "No tab found matching pattern: ${Name}"
                )
                return
            }

            SelectPage $matched
            return [PSCustomObject]@{
                Index       = $matched.Index
                BrowserType = $matched.BrowserType
                Url         = $matched.Url
                Title       = $matched.Title
            }
        }

        ########################################################################
        # Handle -Id selection
        ########################################################################
        if ($Id -ge 0) {
            $matched = $allPages | Microsoft.PowerShell.Core\Where-Object { $_.Index -eq $Id } |
                Microsoft.PowerShell.Utility\Select-Object -First 1

            if (-not $matched) {
                Microsoft.PowerShell.Utility\Write-Warning (
                    "No tab found with index: ${Id}"
                )
                return
            }

            SelectPage $matched
            return [PSCustomObject]@{
                Index       = $matched.Index
                BrowserType = $matched.BrowserType
                Url         = $matched.Url
                Title       = $matched.Title
            }
        }

        ########################################################################
        # No selection criteria — show list
        ########################################################################
        Format-TabList $allPages
        return
    }

    end {
    }
}