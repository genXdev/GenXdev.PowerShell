# Get-WebbrowserTabDomNodes

> **SubModule:** GenXdev.Webbrowser.Playwright | **Type:** Function | **Aliases:** `wl`

## Synopsis

> Queries and manipulates DOM nodes in the active browser tab using CSS selectors.

## Description

Uses browser automation to find elements matching a CSS selector and returns their
HTML content or executes custom JavaScript on each matched element. This function
is useful for web scraping and browser automation tasks.


## Syntax

```powershell
Get-WebbrowserTabDomNodes -QuerySelector <String[]> [[-ModifyScript] <String>] [-ByReference <PSObject>] [-Chrome] [-Chromium] [-Edge] [-Firefox] [-NoAutoSelectTab] [-Page <Object>] [-Webkit] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-QuerySelector` | String[] | ✅ | The query selector string or array of strings<br>to use for selecting DOM nodes |
| `-ModifyScript` | String | ☐ | The script to modify the output of the query<br>selector, e.g. e.outerHTML or<br>e.outerHTML='hello world |
| `-Edge` | SwitchParameter | ☐ | Use Microsoft Edge browser |
| `-Chrome` | SwitchParameter | ☐ | Use Google Chrome browser |
| `-Chromium` | SwitchParameter | ☐ | Use Microsoft Edge or Google Chrome, <br>depending on what the default browser is |
| `-Firefox` | SwitchParameter | ☐ | Use Firefox browser |
| `-Webkit` | SwitchParameter | ☐ | Use the Playwright-managed WebKit browser |
| `-Page` | Object | ☐ | Browser page object reference for targeting <br>a specific tab |
| `-ByReference` | PSObject | ☐ | Browser session reference object for  reusing<br>an existing browser session |
| `-NoAutoSelectTab` | SwitchParameter | ☐ | Prevent automatic tab selection |

## Examples

### Get HTML of all header divs Get-WebbrowserTabDomNodes -QuerySelector "div.header"

```powershell
Get HTML of all header divs
Get-WebbrowserTabDomNodes -QuerySelector "div.header"
```

### Pause all videos on the page wl "video" "e.pause()"

```powershell
Pause all videos on the page
wl "video" "e.pause()"
```

## Parameter Details

### `-QuerySelector <String[]>`

> The query selector string or array of strings to use for selecting DOM nodes

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ModifyScript <String>`

> The script to modify the output of the query selector, e.g. e.outerHTML or e.outerHTML='hello world

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `''` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Edge`

> Use Microsoft Edge browser

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

> Use Google Chrome browser

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

> Use Microsoft Edge or Google Chrome,  depending on what the default browser is

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

> Use Firefox browser

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

> Use the Playwright-managed WebKit browser

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

> Browser page object reference for targeting  a specific tab

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

> Browser session reference object for  reusing an existing browser session

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
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

## Related Links

- [Connect-PlaywrightViaDebuggingPort](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Connect-PlaywrightViaDebuggingPort.md)
- [Get-PlaywrightProfileDirectory](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightProfileDirectory.md)
- [Get-PlaywrightSessionReference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightSessionReference.md)
- [Invoke-WebbrowserEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WebbrowserEvaluation.md)
- [Open-PlayWrightBrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-PlayWrightBrowser.md)
- [Resume-WebbrowserTabVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-WebbrowserTabVideo.md)
- [Select-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Select-WebbrowserTab.md)
- [Set-BrowserVideoFullscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-BrowserVideoFullscreen.md)
- [Set-WebbrowserTabLocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WebbrowserTabLocation.md)
- [Stop-WebbrowserVideos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-WebbrowserVideos.md)
- [Unprotect-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unprotect-WebbrowserTab.md)
