###############################################################################
<#
.SYNOPSIS
Starts a Playwright-managed browser with a persistent user profile.

.DESCRIPTION
Launches a browser instance powered by Playwright. The BrowserType
parameter determines which browser engine and launch mode to use:

- ChromeNormal / EdgeNormal: Launches your OS-installed Chrome or Edge
  via Playwright's Channel API, avoiding the "controlled by automation"
  infobar and anti-bot detection problems.
- ChromiumNormal: Auto-detects Chrome or Edge (whichever is installed
  and set as the system default) and uses the Channel API. Falls back
  to the bundled Playwright Chromium if neither is installed.
- ChromiumPlaywright: Always uses Playwright's bundled Chromium binary
  (never the OS-installed browser).
- FirefoxPlaywright: Uses Playwright's bundled Firefox binary. Channel
  API is not available for Firefox in the Playwright .NET bindings.
- WebKitPlaywright: Uses Playwright's bundled WebKit binary.

Anti-detection measures applied for Chromium-based browsers:
- Disables blink automation flags (removes infobar)
- Sets viewport to null and starts maximized for native window sizing
- Uses 'no-preference' color scheme to avoid white background
- Sets standard browser args (no-first-run, no-default-browser-check)

Persistent profiles per BrowserType are stored under GenXdev AppData.
The launched browser and its context/page are stored in
$Global:GenXdevPlaywright for use by other cmdlets.

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

.PARAMETER BrowserType
The browser to launch: ChromeNormal, EdgeNormal, ChromiumNormal
(auto-detects Chrome or Edge), ChromiumPlaywright, FirefoxPlaywright,
or WebKitPlaywright.

.PARAMETER Headless
Run the browser in headless mode (no visible window).

.PARAMETER Proxy
Proxy server URL (e.g. "http://proxy:8080").

.PARAMETER AcceptLang
Set the browser's Accept-Language HTTP header.

.PARAMETER Width
Initial viewport width in pixels. Also passed to Set-WindowPosition for
OS window sizing.

.PARAMETER Height
Initial viewport height in pixels. Also passed to Set-WindowPosition for
OS window sizing.

.PARAMETER Force
Close any existing Playwright browser and start a new one.

.PARAMETER AutoConsent
Automatically consent to this installation type and set persistent flag...

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation (Playwright
browsers).

.PARAMETER Monitor
Monitor selection: 0=primary, 1+=specific monitor, -1=current,
-2=secondary.

.PARAMETER X
Window horizontal position in pixels.

.PARAMETER Y
Window vertical position in pixels.

.PARAMETER Left
Places window on left half of screen.

.PARAMETER Right
Places window on right half of screen.

.PARAMETER Top
Places window on top half of screen.

.PARAMETER Bottom
Places window on bottom half of screen.

.PARAMETER Centered
Centers window on screen.

.PARAMETER Fullscreen
Maximizes window to fill entire screen.

.PARAMETER NoBorders
Removes window borders and title bar for a cleaner appearance.

.PARAMETER RestoreFocus
Returns focus to PowerShell window after positioning.

.PARAMETER SideBySide
Positions browser either fullscreen on a different monitor than
PowerShell, or side by side with PowerShell on the same monitor.

.PARAMETER FocusWindow
Focus the window after positioning.

.PARAMETER SetForeground
Set the window to foreground after positioning.

.PARAMETER Minimize
Minimizes the window after positioning.

.PARAMETER Maximize
Maximize the window after positioning.

.PARAMETER SetRestored
Restore the window to normal state after positioning.

.PARAMETER KeysToSend
Keystrokes to send to the window after positioning, see documentation
for cmdlet GenXdev\Send-Key.

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys.

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on target window when sending keys.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys.

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending
keys.

.PARAMETER PassThru
Returns window helper object for further manipulation.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting
session.

.PARAMETER OnlyOutputCoords
Only output the calculated coordinates and size without actually
positioning the window. Returns a hashtable with Left, Top, Width,
and Height properties representing global (multi-monitor)
coordinates.

.EXAMPLE
Open-PlayWrightBrowser
Launches your OS-installed Chrome or Edge (auto-detected) with a
persistent profile and anti-detection measures.

.EXAMPLE
Open-PlayWrightBrowser -BrowserType EdgeNormal
Launches Microsoft Edge via Playwright's Channel API.

.EXAMPLE
Open-PlayWrightBrowser -BrowserType ChromiumPlaywright
Uses the bundled Playwright Chromium binary.

.EXAMPLE
Open-PlayWrightBrowser -BrowserType FirefoxPlaywright -Headless
Launches the bundled Firefox in headless mode.

.EXAMPLE
Open-PlayWrightBrowser -Width 1280 -Height 720 -Force
Restarts the browser with a 1280x720 viewport.
#>
function Open-PlayWrightBrowser {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [OutputType([Hashtable])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidUsingPlainTextForPassword', '')]
    [Alias('spb')]

    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = ('The browser to launch: Chrome, Edge, Chromium ' +
                '(auto-detects Chrome or Edge), Firefox, or WebKit')
        )]
        [ValidateSet('ChromeNormal', 'EdgeNormal', 'ChromiumNormal',
            'ChromiumPlaywright', 'FirefoxPlaywright', 'WebKitPlaywright')]
        [string] $BrowserType = 'ChromiumNormal',

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Run the browser without a visible window'
        )]
        [Alias('hl')]
        [switch] $Headless,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Proxy server URL (e.g. http://proxy:8080)'
        )]
        [string] $Proxy,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser Accept-Language HTTP header'
        )]
        [Alias('lang', 'locale')]
        [string] $AcceptLang,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Initial viewport width in pixels'
        )]
        [Alias('w')]
        [ValidateRange(320, 7680)]
        [int] $Width = -1,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Initial viewport height in pixels'
        )]
        [Alias('h')]
        [ValidateRange(240, 4320)]
        [int] $Height = -1,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Close existing browser and start fresh'
        )]
        [Alias('f')]
        [switch] $Force,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to this installation type and set persistent flag..'
        )]
        [switch] $AutoConsent,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to third-party software ' +
            'installation (Playwright browsers)'
        )]
        [Alias('Consent')]
        [switch] $AutoConsentAllPackages,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The monitor to use, 0 = default, -1 is discard, ' +
                '-2 = Configured secondary monitor, defaults to ' +
                "`$Global:DefaultSecondaryMonitor or 2 if not found")
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -1,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the webbrowser window'
        )]
        [int] $X = -999999,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the webbrowser window'
        )]
        [int] $Y = -999999,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the left side of the screen'
        )]
        [switch] $Left,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the right side of the screen'
        )]
        [switch] $Right,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the top side of the screen'
        )]
        [switch] $Top,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the bottom side of the screen'
        )]
        [switch] $Bottom,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window in the center of the screen'
        )]
        [switch] $Centered,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximizes window to fill entire screen'
        )]
        [Alias('fs')]
        [switch] $Fullscreen,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Position browser window either fullscreen on ' +
                'different monitor than PowerShell, or side by side with ' +
                'PowerShell on the same monitor')
        )]
        [Alias('sbs')]
        [switch] $SideBySide,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the browser window after opening'
        )]
        [Alias('fw', 'focus')]
        [switch] $FocusWindow,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Minimizes the window after positioning'
        )]
        [switch] $Minimize,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore the window to normal state after positioning'
        )]
        [switch] $SetRestored,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Window, ' +
                'see documentation for cmdlet GenXdev\Send-Key')
        )]
        [string[]] $KeysToSend,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between different input strings in ' +
                'milliseconds when sending keys')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Returns window helper object for further manipulation'
        )]
        [Alias('pt')]
        [switch] $PassThru,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences ' +
                'without affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only output the calculated coordinates and size ' +
                'without actually positioning the window')
        )]
        [switch] $OnlyOutputCoords
        ########################################################################
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting Playwright ${BrowserType} browser..."
        )

        # ensure Playwright assembly and browser binaries are available
        $pwParams = @{}
        if ($PSBoundParameters.ContainsKey('AutoConsent')) {
            $pwParams.AutoConsent = $AutoConsent
        }
        if ($PSBoundParameters.ContainsKey('AutoConsentAllPackages')) {
            $pwParams.AutoConsentAllPackages = $AutoConsentAllPackages
        }
        GenXdev\EnsurePlaywright @pwParams

        ########################################################################
        # Detect installed browsers for channel support
        ########################################################################

        # Check which real browsers are available on this system
        $script:hasChrome = $false
        $script:hasEdge = $false
        $script:hasFirefox = $false

        try {
            $allBrowsers = @(GenXdev\Get-Webbrowser)
            foreach ($browser in $allBrowsers) {
                if ($browser.Name -match 'Chrome') {
                    $script:hasChrome = $true
                }
                if ($browser.Name -match 'Edge') {
                    $script:hasEdge = $true
                }
                if ($browser.Name -match 'Firefox') {
                    $script:hasFirefox = $true
                }
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Could not detect installed browsers: $($_.Exception.Message)"
            )
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Installed browsers — Chrome: ${script:hasChrome}, " +
            "Edge: ${script:hasEdge}, Firefox: ${script:hasFirefox}"
        )

        # initialize global state container if needed
        if ($Global:GenXdevPlaywright -isnot [Hashtable]) {
            $Global:GenXdevPlaywright = @{}
        }

        # copy window positioning parameters for delegation to Set-WindowPosition
        $wpparams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Set-WindowPosition' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue
        )

        Microsoft.PowerShell.Utility\Write-Verbose (
            'Window positioning parameters copied: ' +
            "$($wpparams.Keys -join ', ')"
        )
    }

    process {

        ########################################################################
        # Step 1: Handle Force — close existing browser
        ########################################################################

        if ($Force -and $Global:GenXdevPlaywright.ContainsKey($BrowserType)) {

            if ($PSCmdlet.ShouldProcess(
                    "${BrowserType} browser",
                    'Close existing instance and start new'
                )) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Force flag set — closing existing ${BrowserType} browser..."
                )

                try {

                    $existing = $Global:GenXdevPlaywright[$BrowserType]

                    if ($existing.Context) {
                        $existing.Context.CloseAsync().GetAwaiter().GetResult()
                    }

                    if ($existing.Browser) {
                        $existing.Browser.CloseAsync().GetAwaiter().GetResult()
                    }
                }
                catch {

                    Microsoft.PowerShell.Utility\Write-Warning (
                        "Error closing existing browser: $($_.Exception.Message)"
                    )
                }

                $Global:GenXdevPlaywright.Remove($BrowserType)
            }
        }

        ########################################################################
        # Step 2: Check if browser is already running
        ########################################################################

        if ($Global:GenXdevPlaywright.ContainsKey($BrowserType)) {

            $existing = $Global:GenXdevPlaywright[$BrowserType]

            if ($existing.Browser -and $existing.Browser.IsConnected) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "${BrowserType} browser already running. Use -Force to restart."
                )

                return $existing
            }
            else {

                # stale entry — clean it up
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Removing stale ${BrowserType} entry from global state."
                )

                $Global:GenXdevPlaywright.Remove($BrowserType)
            }
        }

        ########################################################################
        # Step 3: Get profile directory
        ########################################################################

        $profileDir = GenXdev\Get-PlaywrightProfileDirectory `
            -BrowserType $BrowserType

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Using profile directory: ${profileDir}"
        )

        ########################################################################
        # Step 4: Build browser launch options
        ########################################################################

        if ($PSCmdlet.ShouldProcess(
                "${BrowserType} browser",
                'Launch persistent context'
            )) {

            $launchOptions = [Microsoft.Playwright.BrowserTypeLaunchPersistentContextOptions]::new()

            # headless mode — use ToBool() so -Headless:$false works correctly
            $launchOptions.Headless = $Headless.ToBool()

            # channel and anti-detection logic
            # BrowserType encodes the launch mode in its name:
            # - *Normal: use OS-installed browser via Channel API
            # - *Playwright: use bundled Playwright binary
            $script:useRealBrowser = $false
            $script:channelName = $null

            switch ($BrowserType) {
                'ChromeNormal' {
                    if ($script:hasChrome) {
                        $launchOptions.Channel = 'chrome'
                        $script:useRealBrowser = $true
                        $script:channelName = 'chrome'
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Warning (
                            'Chrome is not installed on this system. ' +
                            'Falling back to bundled Playwright Chromium.'
                        )
                    }
                }
                'EdgeNormal' {
                    if ($script:hasEdge) {
                        $launchOptions.Channel = 'msedge'
                        $script:useRealBrowser = $true
                        $script:channelName = 'msedge'
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Warning (
                            'Edge is not installed on this system. ' +
                            'Falling back to bundled Playwright Chromium.'
                        )
                    }
                }
                'ChromiumNormal' {
                    # Auto-detect: prefer Chrome, then Edge, then bundled
                    if ($script:hasChrome) {
                        $launchOptions.Channel = 'chrome'
                        $script:useRealBrowser = $true
                        $script:channelName = 'chrome'
                    }
                    elseif ($script:hasEdge) {
                        $launchOptions.Channel = 'msedge'
                        $script:useRealBrowser = $true
                        $script:channelName = 'msedge'
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Warning (
                            'Neither Chrome nor Edge is installed. ' +
                            'Falling back to bundled Playwright Chromium.'
                        )
                    }
                }
                'ChromiumPlaywright' {
                    # Always use bundled Playwright Chromium binary
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Using bundled Playwright Chromium binary.'
                    )
                }
                'FirefoxPlaywright' {
                    # Playwright .NET does not support channel for Firefox.
                    # Always use bundled binary.
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Firefox channel not supported in Playwright ' +
                        '.NET API. Using bundled Playwright Firefox.'
                    )
                }
                'WebKitPlaywright' {
                    # WebKit has no OS-installed equivalent on Windows.
                    # Always use bundled binary.
                }
            }

            if ($script:useRealBrowser) {
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Using real browser via channel: ${script:channelName}"
                )
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Using bundled Playwright browser binary.'
                )
            }

            # viewport size — when using a real browser in headed mode,
            # set viewport to null and maximize to let the native window
            # manager handle sizing (avoids zoom/scale issues)
            if ($script:useRealBrowser -and (-not $Headless.ToBool())) {
                if ($Width -le 0 -and $Height -le 0) {
                    # No custom size requested — let the browser window
                    # size naturally
                    $launchOptions.ViewportSize = $null
                }
                elseif ($Width -gt 0 -and $Height -gt 0) {
                    $launchOptions.ViewportSize = [Microsoft.Playwright.ViewportSize]::new()
                    $launchOptions.ViewportSize.Width = $Width
                    $launchOptions.ViewportSize.Height = $Height
                }
                elseif ($Width -gt 0) {
                    $launchOptions.ViewportSize = [Microsoft.Playwright.ViewportSize]::new()
                    $launchOptions.ViewportSize.Width = $Width
                    $launchOptions.ViewportSize.Height = 720
                }
                elseif ($Height -gt 0) {
                    $launchOptions.ViewportSize = [Microsoft.Playwright.ViewportSize]::new()
                    $launchOptions.ViewportSize.Width = 1280
                    $launchOptions.ViewportSize.Height = $Height
                }
            }
            else {
                # Bundled Playwright browser — use explicit viewport
                if ($Width -gt 0 -and $Height -gt 0) {
                    $launchOptions.ViewportSize = [Microsoft.Playwright.ViewportSize]::new()
                    $launchOptions.ViewportSize.Width = $Width
                    $launchOptions.ViewportSize.Height = $Height
                }
                elseif ($Width -gt 0) {
                    $launchOptions.ViewportSize = [Microsoft.Playwright.ViewportSize]::new()
                    $launchOptions.ViewportSize.Width = $Width
                    $launchOptions.ViewportSize.Height = 720
                }
                elseif ($Height -gt 0) {
                    $launchOptions.ViewportSize = [Microsoft.Playwright.ViewportSize]::new()
                    $launchOptions.ViewportSize.Width = 1280
                    $launchOptions.ViewportSize.Height = $Height
                }
            }

            # color scheme — use NoPreference to avoid the stark white
            # background that Playwright defaults to in automation mode
            $launchOptions.ColorScheme = 'NoPreference'

            # user agent — Playwright's default UA can differ from a real
            # browser's and may include automation markers. Override with
            # a normal Chrome/Edge UA string to avoid detection.
            if ($script:useRealBrowser) {
                # Real browser via channel — the browser uses its own UA,
                # but the context-level override ensures consistency and
                # masks any Playwright-specific headers.
                if ($script:channelName -eq 'msedge') {
                    $launchOptions.UserAgent =
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' +
                    'AppleWebKit/537.36 (KHTML, like Gecko) ' +
                    'Chrome/131.0.0.0 Safari/537.36 Edg/131.0.0.0'
                }
                else {
                    $launchOptions.UserAgent =
                    'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' +
                    'AppleWebKit/537.36 (KHTML, like Gecko) ' +
                    'Chrome/131.0.0.0 Safari/537.36'
                }
            }
            elseif ($BrowserType -eq 'ChromiumPlaywright') {
                # Bundled Playwright Chromium — override UA to match a
                # real Chrome install, hiding the Playwright marker.
                $launchOptions.UserAgent =
                'Mozilla/5.0 (Windows NT 10.0; Win64; x64) ' +
                'AppleWebKit/537.36 (KHTML, like Gecko) ' +
                'Chrome/131.0.0.0 Safari/537.36'
            }

            # proxy settings
            if ($Proxy) {
                $launchOptions.Proxy = [Microsoft.Playwright.Proxy]::new()
                $launchOptions.Proxy.Server = $Proxy
            }

            # accept-language header
            if ($AcceptLang) {
                $launchOptions.Locale = $AcceptLang
            }


            # args for a normal-looking browser
            $launchOptions.Args = [System.Collections.Generic.List[string]]::new()

            # Clean up basic flags (Removed the flag causing the new warning)
            $launchOptions.Args.Add('--disable-features=Translate')
            $launchOptions.Args.Add('--no-first-run')
            $launchOptions.Args.Add('--no-default-browser-check')

            # FIX THE GRAY BOX: Instead of a null viewport with forced scaling,
            # we explicitly specify a massive default viewport boundary.
            # This forces Chrome to render the document canvas all the way to the edges.
            $launchOptions.ViewportSize = [Microsoft.Playwright.ViewportSize]::new()
            if ($useRealBrowser) {

                $launchOptions.ViewportSize.Width = -1
                $launchOptions.ViewportSize.Height = -1
            }

            # When using a real browser in headed mode, start maximized
            # so the window manager handles native sizing correctly
            if ($script:useRealBrowser -and (-not $Headless.ToBool()) -and
                $Width -le 0 -and $Height -le 0) {
                $launchOptions.Args.Add('--start-maximized')
            }

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Launch options prepared. Launching persistent context...'
            )

            ####################################################################
            # Step 5: Launch the persistent context
            ####################################################################

            try {

                $playwright = [Microsoft.Playwright.Playwright]::CreateAsync().
                GetAwaiter().GetResult()

                # Map BrowserType to Playwright's engine name.
                # Playwright engines: chromium, firefox, webkit.
                $engineMap = @{
                    'ChromeNormal'       = 'chromium'
                    'EdgeNormal'         = 'chromium'
                    'ChromiumNormal'     = 'chromium'
                    'ChromiumPlaywright' = 'chromium'
                    'FirefoxPlaywright'  = 'firefox'
                    'WebKitPlaywright'   = 'webkit'
                }
                $engineName = $engineMap[$BrowserType]
                $browserTypeObj = $playwright[$engineName]

                $context = $browserTypeObj.LaunchPersistentContextAsync(
                    $profileDir,
                    $launchOptions
                ).GetAwaiter().GetResult()

                # get the browser from the context (it's the parent)
                $browser = $context.Browser

                # get or wait for the first page
                $pages = $context.Pages

                if ($pages.Count -gt 0) {
                    $page = $pages[0]
                }
                else {
                    $page = $context.NewPageAsync().GetAwaiter().GetResult()
                }

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "${BrowserType} browser launched successfully."
                )

                # store in global state
                $state = @{
                    Browser    = $browser
                    Context    = $context
                    Page       = $page
                    Playwright = $playwright
                    Port       = $null  # no debugging port — direct Playwright API
                }

                $Global:GenXdevPlaywright[$BrowserType] = $state

                # also set legacy aliases for backward compatibility
               $Global:chromeSession  = $null
                $Global:playwrightController = $page
                $Global:chrome = $state

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Browser state stored in $Global:GenXdevPlaywright'
                )

                ############################################################
                # Step 6: Position the browser window via Set-WindowPosition
                ############################################################

                # Skip window positioning in headless mode — no window to position
                if ($Headless.ToBool()) {
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Headless mode — skipping window positioning.'
                    )

                    return $state
                }

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Looking for browser window...'
                )

                # find the browser window — retry up to 10 seconds
                # search for ms-playwright (bundled) or chrome.exe/msedge.exe
                # (real browser) depending on the launch mode
                $window = $null
                $retries = 0

                do {
                    Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 200

                    if ($script:useRealBrowser) {
                        # Real browser via channel — look for chrome.exe
                        # or msedge.exe, not ms-playwright
                        $exeName = if ($script:channelName -eq 'msedge') {
                            'msedge'
                        }
                        else {
                            'chrome'
                        }
                        $pwProcesses = @(Microsoft.PowerShell.Management\Get-Process `
                                -Name $exeName -ErrorAction SilentlyContinue |
                                Microsoft.PowerShell.Core\Where-Object {
                                    $PSItem.MainWindowHandle -ne 0
                                } |
                                Microsoft.PowerShell.Utility\Sort-Object {
                                    $PSItem.StartTime
                                } -Descending)
                    }
                    else {
                        # Bundled browser — look for ms-playwright in path
                        $pwProcesses = @(Microsoft.PowerShell.Management\Get-Process `
                                -ErrorAction SilentlyContinue |
                                Microsoft.PowerShell.Core\Where-Object {
                                    $PSItem.Path -and (
                                        $PSItem.Path -like '*\ms-playwright\*'
                                    ) -and $PSItem.MainWindowHandle -ne 0
                                } |
                                Microsoft.PowerShell.Utility\Sort-Object {
                                    $PSItem.StartTime
                                } -Descending)
                    }

                    foreach ($pwProcess in $pwProcesses) {
                        $window = [GenXdev.Helpers.WindowObj]::GetMainWindow(
                            $pwProcess, 1, 80
                        )

                        if ($window -and $window.Length -gt 0) {
                            break
                        }
                    }

                    if ($window -and $window.Length -gt 0) {
                        break
                    }

                    $retries++
                    Microsoft.PowerShell.Utility\Start-Sleep 1
                } while ($retries -lt 50)

                if ($window -and $window.Length -gt 0) {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Browser window found. Delegating positioning to Set-WindowPosition...'
                    )

                    # remove KeysToSend from wpparams — Set-WindowPosition
                    # handles keys separately via its own params
                    if ($wpparams.ContainsKey('KeysToSend')) {
                        $null = $wpparams.Remove('KeysToSend')
                    }

                    $null = GenXdev\Set-WindowPosition @wpparams `
                        -WindowHelper:$window[0] -ErrorAction SilentlyContinue
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Browser window not found within timeout. ' +
                        'Skipping window positioning.'
                    )
                }

                return $state
            }
            catch {

                Microsoft.PowerShell.Utility\Write-Error (
                    "Failed to launch ${BrowserType} browser: $($_.Exception.Message)"
                )

                throw
            }
        }
    }

    end {

        Microsoft.PowerShell.Utility\Write-Verbose (
            'Open-PlayWrightBrowser completed.'
        )
    }
}