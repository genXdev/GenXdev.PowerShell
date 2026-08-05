# Show-WebsiteInAllBrowsers

> **SubModule:** GenXdev.Webbrowser | **Type:** Function | **Aliases:** —

## Synopsis

> Opens a URL in multiple browsers simultaneously in a mosaic layout.

## Description

This function creates a mosaic layout of browser windows by opening the specified
URL in Chrome, Edge, Firefox, and a private browsing window. The browsers are
arranged in a 2x2 grid pattern:
- Chrome: Top-left quadrant
- Edge: Bottom-left quadrant
- Firefox: Top-right quadrant
- Private window: Bottom-right quadrant
All parameters from Open-Webbrowser are supported and passed through to control
browser positioning, behavior, and appearance. The function acts as a wrapper
that applies consistent quadrant positioning while allowing full customization
of browser launch parameters.


## Syntax

```powershell
Show-WebsiteInAllBrowsers -Url <String> [-AcceptLang <String>] [-All] [-ApplicationMode] [-Bottom] [-Centered] [-Chrome] [-Chromium] [-ClearSession] [-DisablePopupBlocker] [-Edge] [-Firefox] [-FocusWindow] [-Force] [-FullScreen] [-Headless] [-Height <Int32>] [-KeysToSend <String[]>] [-Left] [-Maximize] [-Monitor <Int32>] [-NewWindow] [-NoBorders] [-NoBrowserExtensions] [-PlayWright] [-Private] [-RestoreFocus] [-Right] [-SendKeyDelayMilliSeconds <Int32>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-SetRestored] [-SideBySide] [-SkipSession] [-Top] [-Webkit] [-Width <Int32>] [-X <Int32>] [-Y <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Url` | String | ✅ | The URLs to open in all browsers<br>simultaneously |
| `-Monitor` | Int32 | ☐ | The monitor to use, 0 = default, -1 is<br>discard,  -2 = Configured secondary monitor,<br>defaults to  `$Global:DefaultSecondaryMonitor<br>or 2 if not found |
| `-Width` | Int32 | ☐ | The initial width of the webbrowser window |
| `-Height` | Int32 | ☐ | The initial height of the webbrowser window |
| `-X` | Int32 | ☐ | The initial X position of the webbrowser<br>window |
| `-Y` | Int32 | ☐ | The initial Y position of the webbrowser<br>window |
| `-AcceptLang` | String | ☐ | Set the browser accept-lang http header |
| `-FullScreen` | SwitchParameter | ☐ | Opens in fullscreen mode |
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
| `-ApplicationMode` | SwitchParameter | ☐ | Hide the browser controls |
| `-NoBrowserExtensions` | SwitchParameter | ☐ | Prevent loading of browser extensions |
| `-DisablePopupBlocker` | SwitchParameter | ☐ | Disable the popup blocker |
| `-RestoreFocus` | SwitchParameter | ☐ | Restore PowerShell window focus |
| `-NewWindow` | SwitchParameter | ☐ | Don't re-use existing browser window,<br>instead,  create a new one |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the browser window after opening |
| `-SetForeground` | SwitchParameter | ☐ | Set the browser window to foreground after<br>opening |
| `-Maximize` | SwitchParameter | ☐ | Maximize the window after positioning |
| `-SetRestored` | SwitchParameter | ☐ | Restore the window to normal state after<br>positioning |
| `-KeysToSend` | String[] | ☐ | Keystrokes to send to the Browser window, <br>see documentation for cmdlet GenXdev\Send-Key |
| `-SendKeyEscape` | SwitchParameter | ☐ | Escape control characters when sending keys |
| `-SendKeyHoldKeyboardFocus` | SwitchParameter | ☐ | Prevent returning keyboard focus to<br>PowerShell  after sending keys |
| `-SendKeyUseShiftEnter` | SwitchParameter | ☐ | Send Shift+Enter instead of regular Enter for<br>line breaks |
| `-SendKeyDelayMilliSeconds` | Int32 | ☐ | Delay between sending different key sequences<br>in milliseconds |
| `-NoBorders` | SwitchParameter | ☐ | Removes the borders of the browser window. |
| `-SideBySide` | SwitchParameter | ☐ | Position browser window either fullscreen on<br>different monitor than PowerShell, or side by<br>side with PowerShell on the same monitor. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for AI preferences. |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for AI preferences. |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without affecting session. |

## Examples

### Show-WebsiteInAllBrowsers -Url "https://www.github.com" Opens github.com in four different browsers arranged in a mosaic layout.

```powershell
Show-WebsiteInAllBrowsers -Url "https://www.github.com"
Opens github.com in four different browsers arranged in a mosaic layout.
```

### "https://www.github.com" | Show-UrlInAllBrowsers Uses the function's alias and pipeline input to achieve the same result.

```powershell
"https://www.github.com" | Show-UrlInAllBrowsers
Uses the function's alias and pipeline input to achieve the same result.
```

## Parameter Details

### `-Url <String>`

> The URLs to open in all browsers simultaneously

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `Value`, `Uri`, `FullName`, `Website`, `WebsiteUrl` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Monitor <Int32>`

> The monitor to use, 0 = default, -1 is discard,  -2 = Configured secondary monitor, defaults to  `$Global:DefaultSecondaryMonitor or 2 if not found

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

### `-SessionOnly`

> Use alternative settings stored in session for AI preferences.

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

> Clear alternative settings stored in session for AI preferences.

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

> Store settings only in persistent preferences without affecting session.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Close-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-Webbrowser.md)
- [Close-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-WebbrowserTab.md)
- [Export-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Export-BrowserBookmarks.md)
- [Find-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-BrowserBookmark.md)
- [Get-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-BrowserBookmark.md)
- [Get-DefaultWebbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DefaultWebbrowser.md)
- [Get-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Webbrowser.md)
- [Import-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-BrowserBookmarks.md)
- [Import-GenXdevBookmarkletMenu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-GenXdevBookmarkletMenu.md)
- [Open-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BrowserBookmarks.md)
- [Open-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Webbrowser.md)
- [Open-WebbrowserSideBySide](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebbrowserSideBySide.md)
