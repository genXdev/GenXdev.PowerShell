# Open-StackOverflowQuery

> **SubModule:** GenXdev.Queries.Webbrowser | **Type:** Function | **Aliases:** `qso`

## Synopsis

> Opens Stack Overflow search queries in a web browser.

## Description

Opens one or more Stack Overflow search queries in a web browser with
comprehensive browser and display configuration options. This function provides
an advanced wrapper around Stack Overflow search functionality with extensive
options for window positioning, browser selection, and behavior customization.
Key features:
- Multiple search query support with pipeline input
- Smart browser detection and selection (Edge, Chrome, Firefox, all browsers)
- Advanced window positioning (left, right, top, bottom, centered, fullscreen)
- Multi-monitor support with automatic or manual monitor selection
- Private/incognito browsing mode support
- Application mode for distraction-free browsing
- Language localization support for international search results
- Extension and popup blocking options
- Focus management and window manipulation
- Keystroke automation to browser windows
- URL return options for automation workflows
The function automatically detects system capabilities and adjusts behavior
accordingly. For browsers not installed on the system, operations are silently
skipped without errors.


## Syntax

```powershell
Open-StackOverflowQuery -Queries <String[]> [[-Language] <String>] [-AcceptLang <String>] [-All] [-ApplicationMode] [-Bottom] [-Centered] [-Chrome] [-Chromium] [-ClearSession] [-DisablePopupBlocker] [-Edge] [-Firefox] [-FocusWindow] [-Force] [-FullScreen] [-Headless] [-Height <Int32>] [-KeysToSend <String[]>] [-Left] [-Maximize] [-Monitor <Int32>] [-NewWindow] [-NoBorders] [-NoBrowserExtensions] [-PassThru] [-PlayWright] [-Private] [-RestoreFocus] [-ReturnOnlyURL] [-ReturnURL] [-Right] [-SendKeyDelayMilliSeconds <Int32>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-SetRestored] [-SideBySide] [-SkipSession] [-Top] [-Webkit] [-Width <Int32>] [-X <Int32>] [-Y <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Queries` | String[] | ✅ | The search queries to perform on Stack<br>Overflow |
| `-Language` | String | ☐ | The language of the returned search results<br>for  localized Stack Overflow content |
| `-Monitor` | Int32 | ☐ | The monitor to use, 0 = default, -1 is<br>discard,  -2 = Configured secondary monitor,<br>defaults to -1, no positioning |
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
| `-FullScreen` | SwitchParameter | ☐ | Opens in fullscreen mode |
| `-Left` | SwitchParameter | ☐ | Place browser window on the left side of the<br>screen |
| `-Right` | SwitchParameter | ☐ | Place browser window on the right side of the<br>screen |
| `-Top` | SwitchParameter | ☐ | Place browser window on the top side of the<br>screen |
| `-Bottom` | SwitchParameter | ☐ | Place browser window on the bottom side of<br>the screen |
| `-Centered` | SwitchParameter | ☐ | Place browser window in the center of the<br>screen |
| `-ApplicationMode` | SwitchParameter | ☐ | Hide the browser controls |
| `-NoBrowserExtensions` | SwitchParameter | ☐ | Prevent loading of browser extensions |
| `-DisablePopupBlocker` | SwitchParameter | ☐ | Disable the popup blocker |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the browser window after opening |
| `-SetForeground` | SwitchParameter | ☐ | Set the browser window to foreground after<br>opening |
| `-Maximize` | SwitchParameter | ☐ | Maximize the window after positioning |
| `-SetRestored` | SwitchParameter | ☐ | Restore the window to normal state after<br>positioning |
| `-RestoreFocus` | SwitchParameter | ☐ | Restore PowerShell window focus |
| `-NewWindow` | SwitchParameter | ☐ | Don't re-use existing browser window,<br>instead,  create a new one |
| `-PassThru` | SwitchParameter | ☐ | Returns a [System.Diagnostics.Process] object<br>of  the browserprocess |
| `-ReturnURL` | SwitchParameter | ☐ | Don't open webbrowser, just return the url |
| `-ReturnOnlyURL` | SwitchParameter | ☐ | After opening webbrowser, return the url |
| `-SendKeyEscape` | SwitchParameter | ☐ | Escape control characters when sending keys |
| `-SendKeyHoldKeyboardFocus` | SwitchParameter | ☐ | Prevent returning keyboard focus to<br>PowerShell  after sending keys |
| `-SendKeyUseShiftEnter` | SwitchParameter | ☐ | Send Shift+Enter instead of regular Enter for<br>line breaks |
| `-SendKeyDelayMilliSeconds` | Int32 | ☐ | Delay between sending different key sequences<br>in milliseconds |
| `-NoBorders` | SwitchParameter | ☐ | Removes the borders of the browser window. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  Stack Overflow search preferences |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for  Stack Overflow search preferences |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without  affecting session for Stack Overflow<br>search |
| `-SideBySide` | SwitchParameter | ☐ | Position browser window either fullscreen on<br>different monitor than PowerShell, or side by<br>side with PowerShell on the same monitor. |

## Examples

### Open-StackOverflowQuery -Queries "powershell array" -Monitor 0 Opens a Stack Overflow search for "powershell array" on the primary monitor.

```powershell
Open-StackOverflowQuery -Queries "powershell array" -Monitor 0
Opens a Stack Overflow search for "powershell array" on the primary monitor.
```

### qso "powershell array" -mon 0 Opens a Stack Overflow search using the alias with monitor positioning.

```powershell
qso "powershell array" -mon 0
Opens a Stack Overflow search using the alias with monitor positioning.
```

### "powershell", "array manipulation" | Open-StackOverflowQuery -Language "English" -Chrome Opens multiple Stack Overflow searches in Chrome with English language preference.

```powershell
"powershell", "array manipulation" | Open-StackOverflowQuery -Language "English" -Chrome
Opens multiple Stack Overflow searches in Chrome with English language preference.
```

### Open-StackOverflowQuery -Queries "c# linq" -ReturnURL Returns the Stack Overflow search URL without opening a browser.

```powershell
Open-StackOverflowQuery -Queries "c# linq" -ReturnURL
Returns the Stack Overflow search URL without opening a browser.
```

## Parameter Details

### `-Queries <String[]>`

> The search queries to perform on Stack Overflow

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

> The language of the returned search results for  localized Stack Overflow content

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

> The monitor to use, 0 = default, -1 is discard,  -2 = Configured secondary monitor, defaults to -1, no positioning

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

> Disable the popup blocker

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

> Returns a [System.Diagnostics.Process] object of  the browserprocess

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

> Escape control characters when sending keys

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

> Prevent returning keyboard focus to PowerShell  after sending keys

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

> Send Shift+Enter instead of regular Enter for  line breaks

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

> Removes the borders of the browser window.

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

> Use alternative settings stored in session for  Stack Overflow search preferences

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

> Clear alternative settings stored in session for  Stack Overflow search preferences

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

> Store settings only in persistent preferences without  affecting session for Stack Overflow search

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

> Position browser window either fullscreen on different monitor than PowerShell, or side by side with PowerShell on the same monitor.

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
- [Open-IMDBQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-IMDBQuery.md)
- [Open-InstantStreetViewQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-InstantStreetViewQuery.md)
- [Open-MovieQuote](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-MovieQuote.md)
- [Open-SearchEngine](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SearchEngine.md)
- [Open-SimularWebSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SimularWebSiteInfo.md)
- [Open-WaybackMachineSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WaybackMachineSiteInfo.md)
- [Open-WebsiteAndPerformQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebsiteAndPerformQuery.md)
- [Open-WhoisHostSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WhoisHostSiteInfo.md)
- [Open-WikipediaNLQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WikipediaNLQuery.md)
- [Open-WikipediaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WikipediaQuery.md)
- [Open-WolframAlphaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WolframAlphaQuery.md)
- [Open-YoutubeQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-YoutubeQuery.md)
