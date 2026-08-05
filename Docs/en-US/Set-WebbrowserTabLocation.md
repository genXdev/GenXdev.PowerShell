# Set-WebbrowserTabLocation

> **SubModule:** GenXdev.Webbrowser.Playwright | **Type:** Function | **Aliases:** `lt`, `Nav`

## Synopsis

> Navigates the current webbrowser tab to a specified URL.

## Description

Sets the location (URL) of the currently selected webbrowser tab. Supports both
Edge and Chrome browsers through optional switches. The navigation includes
validation of the URL and ensures proper page loading through async operations.


## Syntax

```powershell
Set-WebbrowserTabLocation -Url <String> [-ByReference <PSObject>] [-Chromium] [-Firefox] [-NoAutoSelectTab] [-Page <Object>] [-Webkit] [<CommonParameters>]

Set-WebbrowserTabLocation [-Edge] [<CommonParameters>]

Set-WebbrowserTabLocation [-Chrome] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Url` | String | ✅ | The URL to navigate to |
| `-NoAutoSelectTab` | SwitchParameter | ☐ | Prevent automatic tab selection |
| `-Edge` | SwitchParameter | ☐ | Navigate using Microsoft Edge browser |
| `-Chrome` | SwitchParameter | ☐ | Navigate using Google Chrome browser |
| `-Chromium` | SwitchParameter | ☐ | Navigate using Microsoft Edge or Google<br>Chrome,  depending on what the default<br>browser is |
| `-Firefox` | SwitchParameter | ☐ | Navigate using Firefox browser |
| `-Webkit` | SwitchParameter | ☐ | Navigate using the Playwright-managed WebKit<br>browser |
| `-Page` | Object | ☐ | Browser page object reference |
| `-ByReference` | PSObject | ☐ | Browser session reference object |

## Examples

### Set-WebbrowserTabLocation -Url "https://github.com/microsoft" -Edge

```powershell
Set-WebbrowserTabLocation -Url "https://github.com/microsoft" -Edge
```

### "https://github.com/microsoft" | lt -ch

```powershell
"https://github.com/microsoft" | lt -ch
```

## Parameter Details

### `-Url <String>`

> The URL to navigate to

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoAutoSelectTab`

> Prevent automatic tab selection

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

> Navigate using Microsoft Edge browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `e` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Edge |

<hr/>

### `-Chrome`

> Navigate using Google Chrome browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ch` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Chrome |

<hr/>

### `-Chromium`

> Navigate using Microsoft Edge or Google Chrome,  depending on what the default browser is

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

> Navigate using Firefox browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ff` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Webkit`

> Navigate using the Playwright-managed WebKit browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `wk` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Page <Object>`

> Browser page object reference

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ByReference <PSObject>`

> Browser session reference object

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Connect-PlaywrightViaDebuggingPort](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Connect-PlaywrightViaDebuggingPort.md)
- [Get-PlaywrightProfileDirectory](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightProfileDirectory.md)
- [Get-PlaywrightSessionReference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightSessionReference.md)
- [Get-WebbrowserTabDomNodes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WebbrowserTabDomNodes.md)
- [Invoke-WebbrowserEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WebbrowserEvaluation.md)
- [Open-PlayWrightBrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-PlayWrightBrowser.md)
- [Resume-WebbrowserTabVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-WebbrowserTabVideo.md)
- [Select-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Select-WebbrowserTab.md)
- [Set-BrowserVideoFullscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-BrowserVideoFullscreen.md)
- [Stop-WebbrowserVideos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-WebbrowserVideos.md)
- [Unprotect-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unprotect-WebbrowserTab.md)
