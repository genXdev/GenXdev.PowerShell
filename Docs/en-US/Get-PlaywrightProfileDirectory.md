# Get-PlaywrightProfileDirectory

> **SubModule:** GenXdev.Webbrowser.Playwright | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Gets the Playwright browser profile directory for persistent sessions.

## Description

* Creates and manages browser profile directories for Playwright automated
  testing.
* Profiles are stored in LocalAppData under
  GenXdev.Powershell\Playwright.profiles.
* Each BrowserType value gets its own subdirectory, keeping real-browser
  profiles (ChromeNormal, EdgeNormal) separate from bundled Playwright
  profiles (ChromiumPlaywright, FirefoxPlaywright, WebKitPlaywright).


## Syntax

```powershell
Get-PlaywrightProfileDirectory [[-BrowserType] <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-BrowserType` | String | ☐ | The browser type: ChromeNormal, EdgeNormal,<br>ChromiumNormal, ChromiumPlaywright,<br>FirefoxPlaywright, or WebKitPlaywright |

## Examples

### Examples 1

```powershell
Get-PlaywrightProfileDirectory -BrowserType ChromeNormal
```

Creates or returns path for the OS-installed Chrome browser profile.

### Examples 2

```powershell
Get-PlaywrightProfileDirectory -BrowserType ChromiumNormal
```

Creates or returns path for the auto-detected Chromium browser profile.

### Examples 3

```powershell
Get-PlaywrightProfileDirectory -BrowserType ChromiumPlaywright
```

Creates or returns path for the bundled Playwright Chromium profile.

## Parameter Details

### `-BrowserType <String>`

> The browser type: ChromeNormal, EdgeNormal, ChromiumNormal, ChromiumPlaywright, FirefoxPlaywright, or WebKitPlaywright

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Connect-PlaywrightViaDebuggingPort](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Connect-PlaywrightViaDebuggingPort.md)
- [Get-PlaywrightSessionReference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightSessionReference.md)
- [Get-WebbrowserTabDomNodes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WebbrowserTabDomNodes.md)
- [Invoke-WebbrowserEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WebbrowserEvaluation.md)
- [Open-PlayWrightBrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-PlayWrightBrowser.md)
- [Resume-WebbrowserTabVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-WebbrowserTabVideo.md)
- [Select-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Select-WebbrowserTab.md)
- [Set-BrowserVideoFullscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-BrowserVideoFullscreen.md)
- [Set-WebbrowserTabLocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WebbrowserTabLocation.md)
- [Stop-WebbrowserVideos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-WebbrowserVideos.md)
- [Unprotect-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unprotect-WebbrowserTab.md)
