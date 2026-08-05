# Open-PlayWrightBrowser

> **SubModule:** GenXdev.Webbrowser.Playwright | **Type:** Function | **Aliases:** `spb`

## Synopsis

> Starts a Playwright-managed browser with a persistent user profile.

## Description

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


## Syntax

```powershell
Open-PlayWrightBrowser [[-BrowserType] <String>] [-AcceptLang <String>] [-AutoConsent] [-AutoConsentAllPackages] [-Bottom] [-Centered] [-ClearSession] [-FocusWindow] [-Force] [-Fullscreen] [-Headless] [-Height <Int32>] [-KeysToSend <String[]>] [-Left] [-Maximize] [-Minimize] [-Monitor <Int32>] [-NoBorders] [-OnlyOutputCoords] [-PassThru] [-Proxy <String>] [-RestoreFocus] [-Right] [-SendKeyDelayMilliSeconds <Int32>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-SetRestored] [-SideBySide] [-SkipSession] [-Top] [-Width <Int32>] [-X <Int32>] [-Y <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-BrowserType` | String | ☐ | The browser to launch: Chrome, Edge, Chromium<br>(auto-detects Chrome or Edge), Firefox, or<br>WebKit |
| `-Headless` | SwitchParameter | ☐ | Run the browser without a visible window |
| `-Proxy` | String | ☐ | Proxy server URL (e.g. http://proxy:8080) |
| `-AcceptLang` | String | ☐ | Set the browser Accept-Language HTTP header |
| `-Width` | Int32 | ☐ | Initial viewport width in pixels |
| `-Height` | Int32 | ☐ | Initial viewport height in pixels |
| `-Force` | SwitchParameter | ☐ | Close existing browser and start fresh |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to this installation<br>type and set persistent flag.. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation (Playwright browsers) |
| `-Monitor` | Int32 | ☐ | The monitor to use, 0 = default, -1 is<br>discard,  -2 = Configured secondary monitor,<br>defaults to  `$Global:DefaultSecondaryMonitor<br>or 2 if not found |
| `-X` | Int32 | ☐ | The initial X position of the webbrowser<br>window |
| `-Y` | Int32 | ☐ | The initial Y position of the webbrowser<br>window |
| `-Left` | SwitchParameter | ☐ | Place browser window on the left side of the<br>screen |
| `-Right` | SwitchParameter | ☐ | Place browser window on the right side of the<br>screen |
| `-Top` | SwitchParameter | ☐ | Place browser window on the top side of the<br>screen |
| `-Bottom` | SwitchParameter | ☐ | Place browser window on the bottom side of<br>the screen |
| `-Centered` | SwitchParameter | ☐ | Place browser window in the center of the<br>screen |
| `-Fullscreen` | SwitchParameter | ☐ | Maximizes window to fill entire screen |
| `-NoBorders` | SwitchParameter | ☐ | Removes the borders of the window |
| `-RestoreFocus` | SwitchParameter | ☐ | Restore PowerShell window focus |
| `-SideBySide` | SwitchParameter | ☐ | Position browser window either fullscreen on <br>different monitor than PowerShell, or side by<br>side with  PowerShell on the same monitor |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the browser window after opening |
| `-SetForeground` | SwitchParameter | ☐ | Set the browser window to foreground after<br>opening |
| `-Minimize` | SwitchParameter | ☐ | Minimizes the window after positioning |
| `-Maximize` | SwitchParameter | ☐ | Maximize the window after positioning |
| `-SetRestored` | SwitchParameter | ☐ | Restore the window to normal state after<br>positioning |
| `-KeysToSend` | String[] | ☐ | Keystrokes to send to the Window,  see<br>documentation for cmdlet GenXdev\Send-Key |
| `-SendKeyEscape` | SwitchParameter | ☐ | Escape control characters and modifiers when<br>sending keys |
| `-SendKeyHoldKeyboardFocus` | SwitchParameter | ☐ | Hold keyboard focus on target window when<br>sending keys |
| `-SendKeyUseShiftEnter` | SwitchParameter | ☐ | Use Shift+Enter instead of Enter when sending<br>keys |
| `-SendKeyDelayMilliSeconds` | Int32 | ☐ | Delay between different input strings in <br>milliseconds when sending keys |
| `-PassThru` | SwitchParameter | ☐ | Returns window helper object for further<br>manipulation |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for AI  preferences |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without affecting session |
| `-OnlyOutputCoords` | SwitchParameter | ☐ | Only output the calculated coordinates and<br>size  without actually positioning the window |

## Examples

### Open-PlayWrightBrowser Launches your OS-installed Chrome or Edge (auto-detected) with a persistent profile and anti-detection measures.

```powershell
Open-PlayWrightBrowser
Launches your OS-installed Chrome or Edge (auto-detected) with a
persistent profile and anti-detection measures.
```

### Open-PlayWrightBrowser -BrowserType EdgeNormal Launches Microsoft Edge via Playwright's Channel API.

```powershell
Open-PlayWrightBrowser -BrowserType EdgeNormal
Launches Microsoft Edge via Playwright's Channel API.
```

### Open-PlayWrightBrowser -BrowserType ChromiumPlaywright Uses the bundled Playwright Chromium binary.

```powershell
Open-PlayWrightBrowser -BrowserType ChromiumPlaywright
Uses the bundled Playwright Chromium binary.
```

### Open-PlayWrightBrowser -BrowserType FirefoxPlaywright -Headless Launches the bundled Firefox in headless mode.

```powershell
Open-PlayWrightBrowser -BrowserType FirefoxPlaywright -Headless
Launches the bundled Firefox in headless mode.
```

### Open-PlayWrightBrowser -Width 1280 -Height 720 -Force Restarts the browser with a 1280x720 viewport.

```powershell
Open-PlayWrightBrowser -Width 1280 -Height 720 -Force
Restarts the browser with a 1280x720 viewport.
```

## Parameter Details

### `-BrowserType <String>`

> The browser to launch: Chrome, Edge, Chromium  (auto-detects Chrome or Edge), Firefox, or WebKit

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `'ChromiumNormal'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
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

### `-Proxy <String>`

> Proxy server URL (e.g. http://proxy:8080)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AcceptLang <String>`

> Set the browser Accept-Language HTTP header

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `lang`, `locale` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Width <Int32>`

> Initial viewport width in pixels

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | `w` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Height <Int32>`

> Initial viewport height in pixels

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | `h` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Force`

> Close existing browser and start fresh

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `f` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsent`

> Automatically consent to this installation type and set persistent flag..

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsentAllPackages`

> Automatically consent to third-party software  installation (Playwright browsers)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `Consent` |
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

### `-Fullscreen`

> Maximizes window to fill entire screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fs` |
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

### `-SideBySide`

> Position browser window either fullscreen on  different monitor than PowerShell, or side by side with  PowerShell on the same monitor

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `sbs` |
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

### `-Minimize`

> Minimizes the window after positioning

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
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

> Keystrokes to send to the Window,  see documentation for cmdlet GenXdev\Send-Key

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

> Escape control characters and modifiers when sending keys

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

> Hold keyboard focus on target window when sending keys

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

> Use Shift+Enter instead of Enter when sending keys

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

> Delay between different input strings in  milliseconds when sending keys

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DelayMilliSeconds` |
| **Accept wildcard characters?** | No |

<hr/>

### `-PassThru`

> Returns window helper object for further manipulation

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `pt` |
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

> Store settings only in persistent preferences  without affecting session

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

### `-OnlyOutputCoords`

> Only output the calculated coordinates and size  without actually positioning the window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Outputs

- `Collections.Hashtable`

## Related Links

- [Connect-PlaywrightViaDebuggingPort](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Connect-PlaywrightViaDebuggingPort.md)
- [Get-PlaywrightProfileDirectory](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightProfileDirectory.md)
- [Get-PlaywrightSessionReference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightSessionReference.md)
- [Get-WebbrowserTabDomNodes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WebbrowserTabDomNodes.md)
- [Invoke-WebbrowserEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WebbrowserEvaluation.md)
- [Resume-WebbrowserTabVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-WebbrowserTabVideo.md)
- [Select-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Select-WebbrowserTab.md)
- [Set-BrowserVideoFullscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-BrowserVideoFullscreen.md)
- [Set-WebbrowserTabLocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WebbrowserTabLocation.md)
- [Stop-WebbrowserVideos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-WebbrowserVideos.md)
- [Unprotect-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unprotect-WebbrowserTab.md)
