###############################################################################
<#
.SYNOPSIS
Navigates the current webbrowser tab to a specified URL.

.DESCRIPTION
Sets the location (URL) of the currently selected webbrowser tab. Supports both
Edge and Chrome browsers through optional switches. The navigation includes
validation of the URL and ensures proper page loading through async operations.

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

.PARAMETER Url
The target URL for navigation. Accepts pipeline input and must be a valid URL
string. This parameter is required.

.PARAMETER NoAutoSelectTab
Prevents automatic tab selection if no tab is currently selected.

.PARAMETER Edge
Switch parameter to specifically target Microsoft Edge browser. Cannot be used
together with -Chrome parameter.

.PARAMETER Chrome
Switch parameter to specifically target Google Chrome browser. Cannot be used
together with -Edge parameter.

.PARAMETER Page
Browser page object for execution when using ByReference mode.

.PARAMETER ByReference
Session reference object when using ByReference mode.

.EXAMPLE
Set-WebbrowserTabLocation -Url "https://github.com/microsoft" -Edge

.EXAMPLE
"https://github.com/microsoft" | lt -ch
#>
function Set-WebbrowserTabLocation {

    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSReviewUnusedParameter', '')]
    [CmdletBinding(
        SupportsShouldProcess = $true,
        DefaultParameterSetName = 'Default'
    )]
    [Alias('lt', 'Nav')]

    param(
        ########################################################################
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The URL to navigate to'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Url,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $false,
            HelpMessage = 'Prevent automatic tab selection'
        )]
        [switch] $NoAutoSelectTab,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Edge',
            HelpMessage = 'Navigate using Microsoft Edge browser'
        )]
        [Alias('e')]
        [switch] $Edge,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Chrome',
            HelpMessage = 'Navigate using Google Chrome browser'
        )]
        [Alias('ch')]
        [switch] $Chrome,
        ###############################################################################
        [Alias('c')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Navigate using Microsoft Edge or Google Chrome, ' +
                'depending on what the default browser is')
        )]
        [switch] $Chromium,
        ###############################################################################
        [Alias('ff')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Navigate using Firefox browser'
        )]
        [switch] $Firefox,
        ###############################################################################
        [Alias('wk')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Navigate using the Playwright-managed WebKit browser'
        )]
        [switch] $Webkit,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Browser page object reference',
            ValueFromPipeline = $false
        )]
        [object] $Page,
        ###############################################################################
        [Parameter(
            HelpMessage = 'Browser session reference object',
            ValueFromPipeline = $false
        )]
        [PSCustomObject] $ByReference
    )

    begin {
        # initialize reference tracking
        $reference = $null

        # resolve page from parameters or global Playwright state
        if (($null -eq $Page) -or ($null -eq $ByReference)) {

            if ($ByReference) {
                $reference = $ByReference
                $Page = $ByReference.Page
            }
            elseif ($Page) {
                $reference = @{ Page = $Page }
            }
            else {
                # use the active Playwright browser page
                $activeBrowser = if ($Global:GenXdevPlaywright.ContainsKey('ChromiumNormal')) {
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
                    if ($NoAutoSelectTab) {
                        throw 'No Playwright browser is running. Use Open-PlayWrightBrowser to launch one first.'
                    }

                    # auto-launch Chromium if no browser is running
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'No Playwright browser running. Auto-launching Chromium...'
                    )

                    try {
                        $activeBrowser = GenXdev\Open-PlayWrightBrowser `
                            -BrowserType Chromium `
                            -AutoConsentAllPackages
                    }
                    catch {
                        throw (
                            'Failed to auto-launch Playwright browser: ' +
                            "$($PSItem.Exception.Message)"
                        )
                    }
                }

                $Page = $activeBrowser.Page
                $reference = @{ Page = $Page }
            }
        }
        else {
            $reference = $ByReference
        }

        # validate browser context
        if (($null -eq $Page)) {

            throw 'No browser page available. Use Open-PlayWrightBrowser to launch a browser first.'
        }
    }


    process {

        if ($PSCmdlet.ShouldProcess($Url, 'Navigate to URL')) {

            Microsoft.PowerShell.Utility\Write-Verbose "Navigating to URL: $Url"
            $null = $Page.GotoAsync($Url).GetAwaiter().GetResult()
        }
    }

    end {
    }
}