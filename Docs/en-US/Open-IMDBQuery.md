# Open-IMDBQuery

> **SubModule:** GenXdev.Queries.Webbrowser | **Type:** Function | **Aliases:** `imdb`

## Synopsis

> Opens an IMDB search query in a web browser.

## Description

Opens a "Internet Movie Database" query in a web browser with extensive
configuration options. This function provides a convenient wrapper around
the IMDB search functionality, allowing users to search for movies, TV shows,
actors, and other entertainment content directly from PowerShell.
The function accepts search terms and constructs proper IMDB search URLs,
then opens them in the specified web browser with customizable window
positioning, browser selection, and display options. It supports all major
browsers including Edge, Chrome, and Firefox, with options for private
browsing, fullscreen mode, and window management.
Key features include multi-monitor support, language localization, keyboard
automation, and comprehensive browser configuration options. The function
can handle multiple search queries simultaneously and provides options for
both interactive use and automated workflows.


## Syntax

```powershell
Open-IMDBQuery -Queries <String[]> [[-Language] <String>] [-AcceptLang <String>] [-All] [-ApplicationMode] [-Bottom] [-Centered] [-Chrome] [-Chromium] [-ClearSession] [-DisablePopupBlocker] [-Edge] [-Firefox] [-FocusWindow] [-Force] [-FullScreen] [-Headless] [-Height <Int32>] [-KeysToSend <String[]>] [-Left] [-Maximize] [-Monitor <Int32>] [-NewWindow] [-NoBorders] [-NoBrowserExtensions] [-PassThru] [-PlayWright] [-Private] [-RestoreFocus] [-ReturnOnlyURL] [-ReturnURL] [-Right] [-SendKeyDelayMilliSeconds <Int32>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-SetRestored] [-SideBySide] [-SkipSession] [-Top] [-Webkit] [-Width <Int32>] [-X <Int32>] [-Y <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Queries` | String[] | ✅ | The search terms to query on IMDB |
| `-Language` | String | ☐ | The language of the returned search results |
| `-Monitor` | Int32 | ☐ | The monitor to use, 0 = default, -1 is<br>discard,  -2 = Configured secondary monitor,<br>defaults to -1 |
| `-Width` | Int32 | ☐ | The initial width of the webbrowser window |
| `-Height` | Int32 | ☐ | The initial height of the webbrowser window |
| `-X` | Int32 | ☐ | The initial X position of the webbrowser<br>window |
| `-Y` | Int32 | ☐ | The initial Y position of the webbrowser<br>window |
| `-AcceptLang` | String | ☐ | Set the browser accept-lang http header |
| `-KeysToSend` | String[] | ☐ | Keystrokes to send to the Browser window, <br>see documentation for cmdlet GenXdev\Send-Key |
| `-Private` | SwitchParameter | ☐ | Opens in incognito/private browsing mode |
| `-Force` | SwitchParameter | ☐ | Force enable debugging port, stopping<br>existing  browsers if needed |
| `-Edge` | SwitchParameter | ☐ | Opens in Microsoft Edge |
| `-Chrome` | SwitchParameter | ☐ | Opens in Google Chrome |
| `-Chromium` | SwitchParameter | ☐ | Opens in Microsoft Edge or Google Chrome, <br>depending on what the default browser is |
| `-Firefox` | SwitchParameter | ☐ | Opens in Firefox |
| `-PlayWright` | SwitchParameter | ☐ | Use Playwright-managed browser instead of the<br>OS-installed browser |
| `-Webkit` | SwitchParameter | ☐ | Opens the Playwright-managed WebKit browser. <br>Implies -PlayWright |
| `-Headless` | SwitchParameter | ☐ | Run the browser without a visible window |
| `-All` | SwitchParameter | ☐ | Opens in all registered modern browsers |
| `-Left` | SwitchParameter | ☐ | Place browser window on the left side of the<br>screen |
| `-Right` | SwitchParameter | ☐ | Place browser window on the right side of the<br>screen |
| `-Top` | SwitchParameter | ☐ | Place browser window on the top side of the<br>screen |
| `-Bottom` | SwitchParameter | ☐ | Place browser window on the bottom side of<br>the screen |
| `-Centered` | SwitchParameter | ☐ | Place browser window in the center of the<br>screen |
| `-FullScreen` | SwitchParameter | ☐ | Opens in fullscreen mode |
| `-ApplicationMode` | SwitchParameter | ☐ | Hide the browser controls |
| `-NoBrowserExtensions` | SwitchParameter | ☐ | Prevent loading of browser extensions |
| `-DisablePopupBlocker` | SwitchParameter | ☐ | Disables the browser's popup blocking<br>functionality |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the browser window after opening |
| `-SetForeground` | SwitchParameter | ☐ | Set the browser window to foreground after<br>opening |
| `-Maximize` | SwitchParameter | ☐ | Maximize the window after positioning |
| `-SetRestored` | SwitchParameter | ☐ | Restore the window to normal state after<br>positioning |
| `-RestoreFocus` | SwitchParameter | ☐ | Restore PowerShell window focus |
| `-NewWindow` | SwitchParameter | ☐ | Don't re-use existing browser window,<br>instead,  create a new one |
| `-PassThru` | SwitchParameter | ☐ | Returns a [System.Diagnostics.Process] object<br>of the browserprocess |
| `-ReturnURL` | SwitchParameter | ☐ | Don't open webbrowser, just return the url |
| `-ReturnOnlyURL` | SwitchParameter | ☐ | After opening webbrowser, return the url |
| `-SendKeyEscape` | SwitchParameter | ☐ | Escapes control characters when sending<br>keystrokes to the browser |
| `-SendKeyHoldKeyboardFocus` | SwitchParameter | ☐ | Prevents returning keyboard focus to<br>PowerShell  after sending keystrokes |
| `-SendKeyUseShiftEnter` | SwitchParameter | ☐ | Uses Shift+Enter instead of regular Enter for<br>line breaks when sending keys |
| `-SendKeyDelayMilliSeconds` | Int32 | ☐ | Delay between sending different key sequences<br>in milliseconds |
| `-NoBorders` | SwitchParameter | ☐ | Removes the borders of the window |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for AI  preferences |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without  affecting session |
| `-SideBySide` | SwitchParameter | ☐ | Open browser windows side by side |

## Examples

### Open-IMDBQuery -Queries "The Matrix" -Monitor 0 Opens an IMDB search for "The Matrix" on the default monitor.

```powershell
Open-IMDBQuery -Queries "The Matrix" -Monitor 0
Opens an IMDB search for "The Matrix" on the default monitor.
```

### imdb "The Matrix" -m 0 Opens an IMDB search for "The Matrix" using the alias and shorthand parameters.

```powershell
imdb "The Matrix" -m 0
Opens an IMDB search for "The Matrix" using the alias and shorthand parameters.
```

### "Inception", "Interstellar" | Open-IMDBQuery -Language "French" -Chrome Searches for multiple movies on IMDB with French language results in Chrome.

```powershell
"Inception", "Interstellar" | Open-IMDBQuery -Language "French" -Chrome
Searches for multiple movies on IMDB with French language results in Chrome.
```

### Open-IMDBQuery -Queries "Tom Hanks" -FullScreen -RestoreFocus Searches for Tom Hanks on IMDB in fullscreen mode, then returns focus to PowerShell.

```powershell
Open-IMDBQuery -Queries "Tom Hanks" -FullScreen -RestoreFocus
Searches for Tom Hanks on IMDB in fullscreen mode, then returns focus to
PowerShell.
```

## Parameter Details

### `-Queries <String[]>`

> The search terms to query on IMDB

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `q`, `Name`, `Text`, `Query` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Language <String>`

> The language of the returned search results

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Monitor <Int32>`

> The monitor to use, 0 = default, -1 is discard,  -2 = Configured secondary monitor, defaults to -1

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | `m`, `mon` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Width <Int32>`

> The initial width of the webbrowser window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Height <Int32>`

> The initial height of the webbrowser window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-X <Int32>`

> The initial X position of the webbrowser window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Y <Int32>`

> The initial Y position of the webbrowser window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AcceptLang <String>`

> Set the browser accept-lang http header

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `lang`, `locale` |
| **Accept wildcard characters?** | No |

<hr/>

### `-KeysToSend <String[]>`

> Keystrokes to send to the Browser window,  see documentation for cmdlet GenXdev\Send-Key

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Private`

> Opens in incognito/private browsing mode

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `incognito`, `inprivate` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Force`

> Force enable debugging port, stopping existing  browsers if needed

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Edge`

> Opens in Microsoft Edge

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `e` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Chrome`

> Opens in Google Chrome

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ch` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Chromium`

> Opens in Microsoft Edge or Google Chrome,  depending on what the default browser is

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `c` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Firefox`

> Opens in Firefox

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ff` |
| **Accept wildcard characters?** | No |

<hr/>

### `-PlayWright`

> Use Playwright-managed browser instead of the  OS-installed browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `pw` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Webkit`

> Opens the Playwright-managed WebKit browser.  Implies -PlayWright

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `wk` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Headless`

> Run the browser without a visible window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `hl` |
| **Accept wildcard characters?** | No |

<hr/>

### `-All`

> Opens in all registered modern browsers

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Left`

> Place browser window on the left side of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Right`

> Place browser window on the right side of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Top`

> Place browser window on the top side of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Bottom`

> Place browser window on the bottom side of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Centered`

> Place browser window in the center of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-FullScreen`

> Opens in fullscreen mode

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fs`, `f` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ApplicationMode`

> Hide the browser controls

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `a`, `app`, `appmode` |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoBrowserExtensions`

> Prevent loading of browser extensions

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `de`, `ne`, `NoExtensions` |
| **Accept wildcard characters?** | No |

<hr/>

### `-DisablePopupBlocker`

> Disables the browser's popup blocking functionality

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `allowpopups` |
| **Accept wildcard characters?** | No |

<hr/>

### `-FocusWindow`

> Focus the browser window after opening

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fw`, `focus` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SetForeground`

> Set the browser window to foreground after opening

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fg` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Maximize`

> Maximize the window after positioning

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SetRestored`

> Restore the window to normal state after positioning

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-RestoreFocus`

> Restore PowerShell window focus

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `rf`, `bg` |
| **Accept wildcard characters?** | No |

<hr/>

### `-NewWindow`

> Don't re-use existing browser window, instead,  create a new one

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nw`, `new` |
| **Accept wildcard characters?** | No |

<hr/>

### `-PassThru`

> Returns a [System.Diagnostics.Process] object  of the browserprocess

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `pt` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ReturnURL`

> Don't open webbrowser, just return the url

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ReturnOnlyURL`

> After opening webbrowser, return the url

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyEscape`

> Escapes control characters when sending keystrokes to the browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `Escape` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyHoldKeyboardFocus`

> Prevents returning keyboard focus to PowerShell  after sending keystrokes

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `HoldKeyboardFocus` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyUseShiftEnter`

> Uses Shift+Enter instead of regular Enter for  line breaks when sending keys

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `UseShiftEnter` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyDelayMilliSeconds <Int32>`

> Delay between sending different key sequences  in milliseconds

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DelayMilliSeconds` |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoBorders`

> Removes the borders of the window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nb` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Use alternative settings stored in session for  preferences

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ClearSession`

> Clear alternative settings stored in session for AI  preferences

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipSession`

> Store settings only in persistent preferences without  affecting session

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SideBySide`

> Open browser windows side by side

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `sbs` |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Copy-PDFsFromGoogleQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-PDFsFromGoogleQuery.md)
- [Open-BingQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BingQuery.md)
- [Open-BuiltWithSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BuiltWithSiteInfo.md)
- [Open-GithubQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GithubQuery.md)
- [Open-GoogleQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GoogleQuery.md)
- [Open-GoogleSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GoogleSiteInfo.md)
- [Open-GrokipediaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GrokipediaQuery.md)
- [Open-InstantStreetViewQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-InstantStreetViewQuery.md)
- [Open-MovieQuote](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-MovieQuote.md)
- [Open-SearchEngine](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SearchEngine.md)
- [Open-SimularWebSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SimularWebSiteInfo.md)
- [Open-StackOverflowQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-StackOverflowQuery.md)
- [Open-WaybackMachineSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WaybackMachineSiteInfo.md)
- [Open-WebsiteAndPerformQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebsiteAndPerformQuery.md)
- [Open-WhoisHostSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WhoisHostSiteInfo.md)
- [Open-WikipediaNLQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WikipediaNLQuery.md)
- [Open-WikipediaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WikipediaQuery.md)
- [Open-WolframAlphaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WolframAlphaQuery.md)
- [Open-YoutubeQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-YoutubeQuery.md)
