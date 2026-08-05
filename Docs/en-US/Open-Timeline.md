# Open-Timeline

> **SubModule:** GenXdev.Queries.Websites | **Type:** Function | **Aliases:** `timeline`

## Synopsis

> Opens an interactive timeline showing current time, date, century, and
millennium.

## Description

Opens a web-based interactive timeline.
Supports multiple languages and visual customization options.


## Syntax

```powershell
Open-Timeline [[-Language] <String>] [-AcceptLang <String>] [-All] [-ApplicationMode] [-BorderDarkColor <String>] [-BorderLightColor <String>] [-BorderWidth <Int32>] [-Bottom] [-BrowserExtensions] [-Centered] [-Chrome] [-Chromium] [-ClearSession] [-DisablePopupBlocker] [-DragedNodeBackground <String>] [-Edge] [-Firefox] [-FocusedNodeBackground <String>] [-FocusedNodeForeground <String>] [-FocusWindow] [-Force] [-FullScreen] [-Headless] [-Height <Int32>] [-KeysToSend <String[]>] [-Left] [-Maximize] [-Monitor <Int32>] [-NewWindow] [-NoApplicationMode] [-NoBorders] [-NoBrowserExtensions] [-NoFullScreen] [-PassThru] [-PlayWright] [-Private] [-RestoreFocus] [-ReturnOnlyURL] [-ReturnURL] [-Right] [-RotationDelaySeconds <Int32>] [-SendKeyDelayMilliSeconds <Int32>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-SetRestored] [-SideBySide] [-SkipSession] [-SpectateOnly] [-Top] [-UnFocusedNodeBackground <String>] [-UnFocusedNodeForeground <String>] [-Webkit] [-Width <Int32>] [-X <Int32>] [-Y <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Private` | SwitchParameter | ☐ | Opens in incognito/private browsing mode |
| `-Force` | SwitchParameter | ☐ | Force enable debugging port, stopping<br>existing browsers if needed |
| `-Edge` | SwitchParameter | ☐ | Opens in Microsoft Edge |
| `-Chrome` | SwitchParameter | ☐ | Opens in Google Chrome |
| `-Chromium` | SwitchParameter | ☐ | Opens in Microsoft Edge or Google Chrome,<br>depending on what the default browser is |
| `-Firefox` | SwitchParameter | ☐ | Opens in Firefox |
| `-PlayWright` | SwitchParameter | ☐ | Use Playwright-managed browser instead of the<br>OS-installed browser |
| `-Webkit` | SwitchParameter | ☐ | Opens the Playwright-managed WebKit browser. <br>Implies -PlayWright |
| `-Headless` | SwitchParameter | ☐ | Run the browser without a visible window |
| `-All` | SwitchParameter | ☐ | Opens in all registered modern browsers |
| `-Monitor` | Int32 | ☐ | The monitor to use, 0 = default, -1 is<br>discard, -2 = Configured secondary monitor,<br>defaults to `Global:DefaultSecondaryMonitor<br>or 2 if not found |
| `-NoFullScreen` | SwitchParameter | ☐ | Don't open in fullscreen mode |
| `-Width` | Int32 | ☐ | The initial width of the webbrowser window |
| `-Height` | Int32 | ☐ | The initial height of the webbrowser window |
| `-X` | Int32 | ☐ | The initial X position of the webbrowser<br>window |
| `-Y` | Int32 | ☐ | The initial Y position of the webbrowser<br>window |
| `-Left` | SwitchParameter | ☐ | Place browser window on the left side of the<br>screen |
| `-Right` | SwitchParameter | ☐ | Place browser window on the right side of the<br>screen |
| `-Top` | SwitchParameter | ☐ | Place browser window on the top side of the<br>screen |
| `-Bottom` | SwitchParameter | ☐ | Place browser window on the bottom side of<br>the screen |
| `-Centered` | SwitchParameter | ☐ | Place browser window in the center of the<br>screen |
| `-NoApplicationMode` | SwitchParameter | ☐ | Do show the browser controls |
| `-BrowserExtensions` | SwitchParameter | ☐ | Don't prevent loading of browser extensions |
| `-AcceptLang` | String | ☐ | Set the browser accept-lang http header |
| `-KeysToSend` | String[] | ☐ | Keystrokes to send to the Browser window, <br>see documentation for cmdlet GenXdev\Send-Key |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the browser window after opening |
| `-SetForeground` | SwitchParameter | ☐ | Set the browser window to foreground after<br>opening |
| `-Maximize` | SwitchParameter | ☐ | Maximize the window after positioning |
| `-SetRestored` | SwitchParameter | ☐ | Restore the window to normal state after<br>positioning |
| `-RestoreFocus` | SwitchParameter | ☐ | Restore PowerShell window focus |
| `-NewWindow` | SwitchParameter | ☐ | Don't re-use existing browser window,<br>instead, create a new one |
| `-PassThru` | SwitchParameter | ☐ | Returns a [System.Diagnostics.Process] object<br>of the browserprocess |
| `-SpectateOnly` | SwitchParameter | ☐ | Don't start a new game, just watch the AI<br>play |
| `-ReturnURL` | SwitchParameter | ☐ | Don't open webbrowser, just return the url |
| `-ReturnOnlyURL` | SwitchParameter | ☐ | After opening webbrowser, return the url |
| `-Language` | String | ☐ | Override default browser language, or select<br>[All] for rotation of all languages every<br>minute |
| `-DragedNodeBackground` | String | ☐ | Overwrite the css-color-style for painting<br>the currently dragged node's background |
| `-FocusedNodeBackground` | String | ☐ | Overwrite the css-color-style for painting<br>the focused node's (In center) background |
| `-FocusedNodeForeground` | String | ☐ | Overwrite the css-color-style for painting<br>the focused node's (in center) foreground<br>text |
| `-UnFocusedNodeBackground` | String | ☐ | Overwrite the css-color-style for painting<br>the focused node's (In center) background |
| `-UnFocusedNodeForeground` | String | ☐ | Overwrite the css-color-style for painting<br>the unfocused node's (in center) foreground<br>text |
| `-BorderLightColor` | String | ☐ | Overwrite the default css border-light-color<br>colorstyle |
| `-BorderDarkColor` | String | ☐ | Overwrite the default css border-dark-color<br>colorstyle |
| `-BorderWidth` | Int32 | ☐ | Overwrite the default width for painting the<br>node borders |
| `-RotationDelaySeconds` | Int32 | ☐ | Overwrite the default width for the<br>background rotation delay |
| `-FullScreen` | SwitchParameter | ☐ | Opens in fullscreen mode |
| `-ApplicationMode` | SwitchParameter | ☐ | Hide the browser controls |
| `-NoBrowserExtensions` | SwitchParameter | ☐ | Prevent loading of browser extensions |
| `-DisablePopupBlocker` | SwitchParameter | ☐ | Disable the popup blocker |
| `-SendKeyEscape` | SwitchParameter | ☐ | Escape control characters when sending keys |
| `-SendKeyHoldKeyboardFocus` | SwitchParameter | ☐ | Prevent returning keyboard focus to<br>PowerShell after sending keys |
| `-SendKeyUseShiftEnter` | SwitchParameter | ☐ | Send Shift+Enter instead of regular Enter for<br>line breaks |
| `-SendKeyDelayMilliSeconds` | Int32 | ☐ | Delay between sending different key sequences<br>in milliseconds |
| `-NoBorders` | SwitchParameter | ☐ | Removes the borders of the browser window. |
| `-SideBySide` | SwitchParameter | ☐ | Position browser window either fullscreen on<br>different monitor than PowerShell, or side by<br>side with PowerShell on the same monitor. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for AI preferences |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for AI preferences |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without affecting session |

## Examples

### Open-Timeline -Language "English" Opens an interactive timeline with Van Gogh-inspired visuals in English.

```powershell
Open-Timeline -Language "English"
Opens an interactive timeline with Van Gogh-inspired visuals in English.
```

### timeline -mon 2 Opens timeline on monitor 2 using aliases.

```powershell
timeline -mon 2
Opens timeline on monitor 2 using aliases.
```

### Open-Timeline -Private -Chrome -FullScreen Opens timeline in Chrome incognito mode in fullscreen.

```powershell
Open-Timeline -Private -Chrome -FullScreen
Opens timeline in Chrome incognito mode in fullscreen.
```

## Parameter Details

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

> Force enable debugging port, stopping existing browsers if needed

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

> Opens in Microsoft Edge or Google Chrome, depending on what the default browser is

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

### `-Monitor <Int32>`

> The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary monitor, defaults to `Global:DefaultSecondaryMonitor or 2 if not found

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-2` |
| **Accept pipeline input?** | False |
| **Aliases** | `m`, `mon` |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoFullScreen`

> Don't open in fullscreen mode

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nfs`, `nf` |
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

### `-NoApplicationMode`

> Do show the browser controls

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `na`, `napp`, `noappmode` |
| **Accept wildcard characters?** | No |

<hr/>

### `-BrowserExtensions`

> Don't prevent loading of browser extensions

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ext`, `Extensions` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AcceptLang <String>`

> Set the browser accept-lang http header

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
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

> Don't re-use existing browser window, instead, create a new one

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

> Returns a [System.Diagnostics.Process] object of the browserprocess

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `pt` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SpectateOnly`

> Don't start a new game, just watch the AI play

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
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

### `-Language <String>`

> Override default browser language, or select [All] for rotation of all languages every minute

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DragedNodeBackground <String>`

> Overwrite the css-color-style for painting the currently dragged node's background

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-FocusedNodeBackground <String>`

> Overwrite the css-color-style for painting the focused node's (In center) background

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-FocusedNodeForeground <String>`

> Overwrite the css-color-style for painting the focused node's (in center) foreground text

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-UnFocusedNodeBackground <String>`

> Overwrite the css-color-style for painting the focused node's (In center) background

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-UnFocusedNodeForeground <String>`

> Overwrite the css-color-style for painting the unfocused node's (in center) foreground text

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-BorderLightColor <String>`

> Overwrite the default css border-light-color colorstyle

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-BorderDarkColor <String>`

> Overwrite the default css border-dark-color colorstyle

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-BorderWidth <Int32>`

> Overwrite the default width for painting the node borders

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-RotationDelaySeconds <Int32>`

> Overwrite the default width for the background rotation delay

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `15` |
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

> Prevent returning keyboard focus to PowerShell after sending keys

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

> Send Shift+Enter instead of regular Enter for line breaks

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

> Delay between sending different key sequences in milliseconds

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

> Use alternative settings stored in session for AI preferences

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

> Clear alternative settings stored in session for AI preferences

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

> Store settings only in persistent preferences without affecting session

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

- [Open-GameOfLife](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GameOfLife.md)
- [Open-GenXdevAppCatalog](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GenXdevAppCatalog.md)
- [Open-ViralSimulation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-ViralSimulation.md)
- [Open-Yab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Yab.md)
- [Open-YabAIBattle](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-YabAIBattle.md)
