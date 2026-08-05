###############################################################################
<#
.SYNOPSIS
Opens a web browser to search for lyrics of currently playing VLC media.

.DESCRIPTION
This function detects if VLC Media Player is running and searches for lyrics
based on the currently playing media title. It automatically opens a search
query in a web browser to find lyrics for the current track. The function
supports multiple browsers and provides extensive window positioning and
display options.

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

.PARAMETER Queries
The search terms to find a track. If not specified, automatically uses the
VLC window title.

.PARAMETER EndPoint
The search endpoint to invoke the query on. Valid options are Bing, Github,
Google, or Youtube. Defaults to Google.

.PARAMETER Language
The language of the returned search results. Supports many languages
including English, Spanish, French, German, and many others.

.PARAMETER Private
Opens in incognito/private browsing mode to prevent saving browsing history.

.PARAMETER Force
Force enable debugging port, stopping existing browsers if needed for
debugging purposes.

.PARAMETER Edge
Opens the search results in Microsoft Edge browser.

.PARAMETER Chrome
Opens the search results in Google Chrome browser.

.PARAMETER Chromium
Opens in Microsoft Edge or Google Chrome, depending on what the default
browser is configured as.

.PARAMETER Firefox
Opens the search results in Firefox browser.

.PARAMETER All
Opens the search results in all registered modern browsers simultaneously.

.PARAMETER Monitor
The monitor to use for displaying the browser window. 0 = default,
-1 = discard positioning, -2 = configured secondary monitor.
Defaults to -1 (no positioning).

.PARAMETER ShowWindow
Opens the browser window in fullscreen mode.

.PARAMETER Width
The initial width of the web browser window in pixels.

.PARAMETER Height
The initial height of the web browser window in pixels.

.PARAMETER X
The initial X position of the web browser window on screen.

.PARAMETER Y
The initial Y position of the web browser window on screen.

.PARAMETER Left
Place browser window on the left side of the screen.

.PARAMETER Right
Place browser window on the right side of the screen.

.PARAMETER Top
Place browser window on the top side of the screen.

.PARAMETER Bottom
Place browser window on the bottom side of the screen.

.PARAMETER Centered
Place browser window in the center of the screen.

.PARAMETER ApplicationMode
Hide the browser controls for a cleaner, app-like experience.

.PARAMETER NoBrowserExtensions
Prevent loading of browser extensions to improve performance and security.

.PARAMETER DisablePopupBlocker
Disable the popup blocker to allow all popups to display.

.PARAMETER AcceptLang
Set the browser accept-lang HTTP header for localized content.

.PARAMETER KeysToSend
Keystrokes to send to the browser window after opening. See documentation
for cmdlet GenXdev\Send-Key for format details.

.PARAMETER SendKeyEscape
Escape control characters when sending keys to prevent interpretation.

.PARAMETER SendKeyHoldKeyboardFocus
Prevent returning keyboard focus to PowerShell after sending keys.

.PARAMETER SendKeyUseShiftEnter
Send Shift+Enter instead of regular Enter for line breaks in key sequences.

.PARAMETER SendKeyDelayMilliSeconds
Delay between sending different key sequences in milliseconds.

.PARAMETER FocusWindow
Focus the browser window after opening to bring it to the foreground.

.PARAMETER SetForeground
Set the browser window to foreground after opening for immediate visibility.

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER RestoreFocus
Restore PowerShell window focus after opening the browser.

.PARAMETER NewWindow
Don't re-use existing browser window, instead create a new window instance.

.PARAMETER PassThru
Returns a [System.Diagnostics.Process] object of the browser process.

.PARAMETER ReturnURL
Don't open web browser, just return the constructed URL string.

.PARAMETER ReturnOnlyURL
After opening web browser, return the URL that was opened.

.PARAMETER NoBorders
Removes window borders from the browser window for a borderless display.

.PARAMETER SessionOnly
Use a session that is not persisted after closing the browser.

.PARAMETER ClearSession
Clear browser session data before opening the browser.

.PARAMETER SkipSession
Skip using any existing browser session data.

.PARAMETER SideBySide
Open browser windows side by side when multiple windows are created.

.EXAMPLE
Open-VlcMediaPlayerLyrics

Opens a Google search for lyrics of the currently playing VLC media.

.EXAMPLE
vlclyrics -Edge -Private

Opens lyrics search in Microsoft Edge using private/incognito mode.
#>
function Open-VlcMediaPlayerLyrics {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias('vlclyrics')]

    param(
        ###############################################################################
        [Alias('q', 'Name', 'Text', 'Query')]
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromRemainingArguments = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Search terms to find a track'
        )]
        [string[]] $Queries,
        ###############################################################################
        [ValidateSet(
            'Bing',
            'Github',
            'Google',
            'Youtube'
        )]
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'The endpoint to invoke the query on'
        )]
        [string] $EndPoint = 'Google',
        ###############################################################################
        [ValidateSet(
            'Afrikaans',
            'Akan',
            'Albanian',
            'Amharic',
            'Arabic',
            'Armenian',
            'Azerbaijani',
            'Basque',
            'Belarusian',
            'Bemba',
            'Bengali',
            'Bihari',
            'Bork, bork, bork!',
            'Bosnian',
            'Breton',
            'Bulgarian',
            'Cambodian',
            'Catalan',
            'Cherokee',
            'Chichewa',
            'Chinese (Simplified)',
            'Chinese (Traditional)',
            'Corsican',
            'Croatian',
            'Czech',
            'Danish',
            'Dutch',
            'Elmer Fudd',
            'English',
            'Esperanto',
            'Estonian',
            'Ewe',
            'Faroese',
            'Filipino',
            'Finnish',
            'French',
            'Frisian',
            'Ga',
            'Galician',
            'Georgian',
            'German',
            'Greek',
            'Guarani',
            'Gujarati',
            'Hacker',
            'Haitian Creole',
            'Hausa',
            'Hawaiian',
            'Hebrew',
            'Hindi',
            'Hungarian',
            'Icelandic',
            'Igbo',
            'Indonesian',
            'Interlingua',
            'Irish',
            'Italian',
            'Japanese',
            'Javanese',
            'Kannada',
            'Kazakh',
            'Kinyarwanda',
            'Kirundi',
            'Klingon',
            'Kongo',
            'Korean',
            'Krio (Sierra Leone)',
            'Kurdish',
            'Kurdish (Soranî)',
            'Kyrgyz',
            'Laothian',
            'Latin',
            'Latvian',
            'Lingala',
            'Lithuanian',
            'Lozi',
            'Luganda',
            'Luo',
            'Macedonian',
            'Malagasy',
            'Malay',
            'Malayalam',
            'Maltese',
            'Maori',
            'Marathi',
            'Mauritian Creole',
            'Moldavian',
            'Mongolian',
            'Montenegrin',
            'Nepali',
            'Nigerian Pidgin',
            'Northern Sotho',
            'Norwegian',
            'Norwegian (Nynorsk)',
            'Occitan',
            'Oriya',
            'Oromo',
            'Pashto',
            'Persian',
            'Pirate',
            'Polish',
            'Portuguese (Brazil)',
            'Portuguese (Portugal)',
            'Punjabi',
            'Quechua',
            'Romanian',
            'Romansh',
            'Runyakitara',
            'Russian',
            'Scots Gaelic',
            'Serbian',
            'Serbo-Croatian',
            'Sesotho',
            'Setswana',
            'Seychellois Creole',
            'Shona',
            'Sindhi',
            'Sinhalese',
            'Slovak',
            'Slovenian',
            'Somali',
            'Spanish',
            'Spanish (Latin American)',
            'Sundanese',
            'Swahili',
            'Swedish',
            'Tajik',
            'Tamil',
            'Tatar',
            'Telugu',
            'Thai',
            'Tigrinya',
            'Tonga',
            'Tshiluba',
            'Tumbuka',
            'Turkish',
            'Turkmen',
            'Twi',
            'Uighur',
            'Ukrainian',
            'Urdu',
            'Uzbek',
            'Vietnamese',
            'Welsh',
            'Wolof',
            'Xhosa',
            'Yiddish',
            'Yoruba',
            'Zulu'
        )]
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'The language of the returned search results'
        )]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard, ' +
            '-2 = Configured secondary monitor, defaults to -1, ' +
            'no positioning'
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the webbrowser window'
        )]
        [int] $Width = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the webbrowser window'
        )]
        [int] $Height = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the webbrowser window'
        )]
        [int] $X = -999999,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the webbrowser window'
        )]
        [int] $Y = -999999,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser accept-lang http header'
        )]
        [Alias('lang', 'locale')]
        [string] $AcceptLang = $null,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Browser window, ' +
                'see documentation for cmdlet GenXdev\Send-Key')
        )]
        [string[]] $KeysToSend,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between sending different key sequences ' +
                'in milliseconds')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in incognito/private browsing mode'
        )]
        [Alias('incognito', 'inprivate')]
        [switch] $Private,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force enable debugging port, stopping existing ' +
                'browsers if needed')
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Microsoft Edge'
        )]
        [Alias('e')]
        [switch] $Edge,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Google Chrome'
        )]
        [Alias('ch')]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Opens in Microsoft Edge or Google Chrome, ' +
                'depending on what the default browser is')
        )]
        [Alias('c')]
        [switch] $Chromium,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Firefox'
        )]
        [Alias('ff')]
        [switch] $Firefox,
        ###############################################################################
        [Alias('pw')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use Playwright-managed browser instead of the ' +
                'OS-installed browser')
        )]
        [switch] $PlayWright,
        ###############################################################################
        [Alias('wk')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Opens the Playwright-managed WebKit browser. ' +
                'Implies -PlayWright')
        )]
        [switch] $Webkit,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Run the browser without a visible window'
        )]
        [Alias('hl')]
        [switch] $Headless,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in all registered modern browsers'
        )]
        [switch] $All,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in fullscreen mode'
        )]
        [Alias('sw')]
        [switch] $ShowWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the left side of the screen'
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the right side of the screen'
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the top side of the screen'
        )]
        [switch] $Top,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window in the center of the screen'
        )]
        [switch] $Centered,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hide the browser controls'
        )]
        [Alias('a', 'app', 'appmode')]
        [switch] $ApplicationMode,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prevent loading of browser extensions'
        )]
        [Alias('de', 'ne', 'NoExtensions')]
        [switch] $NoBrowserExtensions,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable the popup blocker'
        )]
        [Alias('allowpopups')]
        [switch] $DisablePopupBlocker,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Prevent returning keyboard focus to PowerShell ' +
                'after sending keys')
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Send Shift+Enter instead of regular Enter for ' +
                'line breaks')
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the browser window after opening'
        )]
        [Alias('fw', 'focus')]
        [switch] $FocusWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ###############################################################################
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
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Don't re-use existing browser window, instead, " +
                "create a new one")
        )]
        [Alias('nw', 'new')]
        [switch] $NewWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Returns a [System.Diagnostics.Process] object of ' +
                'the browserprocess')
        )]
        [Alias('pt')]
        [switch] $PassThru,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't open webbrowser, just return the url"
        )]
        [switch] $ReturnURL,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'After opening webbrowser, return the url'
        )]
        [switch] $ReturnOnlyURL,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes window borders from the browser window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use a session that is not persisted after closing ' +
                'the browser')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear browser session data before opening the browser'
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip using any existing browser session'
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open browser windows side by side'
        )]
        [Alias('sbs')]
        [switch] $SideBySide
        ###############################################################################
    )

    begin {

        # initialize collection to store queries from pipeline input
        $queryList = @()

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Initializing VLC Media Player lyrics search function"
        )
    }

    process {

        # accumulate queries from pipeline input for batch processing
        if ($Queries) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Adding ${Queries} queries from pipeline input"
            )

            $queryList += $Queries
        }
    }

    end {

        # attempt to find a running vlc media player window
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Searching for VLC Media Player process"
        )

        $vlcWindow = GenXdev\Get-Window -ProcessName vlc

        # proceed only if vlc is found and running
        if ($null -ne $vlcWindow) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Found VLC window with title: ${vlcWindow.Title}"
            )

            # ensure genxdev.queries module is available for search functionality
            $queriesModuleCount = @(
                Microsoft.PowerShell.Core\Get-Module GenXdev.Queries `
                    -ErrorAction SilentlyContinue
            ).Count

            # install and import the queries module if not already loaded
            if ($queriesModuleCount -eq 0) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Installing and importing GenXdev.Queries module"
                )

                $null = PowerShellGet\Install-Module GenXdev.Queries `
                    -SkipPublisherCheck

                $null = Microsoft.PowerShell.Core\Import-Module GenXdev.Queries
            }

            # copy parameters to pass through to the google query function
            $invocationArguments = GenXdev\Copy-IdenticalParamValues `
                -FunctionName 'GenXdev\Open-GoogleQuery' `
                -BoundParameters $PSBoundParameters

            # determine search query based on pipeline input or vlc window title
            if ($queryList.Count -gt 0) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Using ${queryList.Count} queries from pipeline input"
                )

                $invocationArguments.Queries = $queryList
            }
            else {

                # construct lyrics search query from vlc window title
                $lyricsQuery = 'lyrics ' + $vlcWindow.Title.Replace("- VLC media player", "")

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Using VLC window title for query: ${lyricsQuery}"
                )

                $invocationArguments.Queries = @($lyricsQuery)
            }

            # execute the search query in the web browser
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Opening lyrics search in web browser"
            )

            $null = GenXdev\Open-GoogleQuery @invocationArguments
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "VLC Media Player is not currently running"
            )
        }
    }
}
###############################################################################