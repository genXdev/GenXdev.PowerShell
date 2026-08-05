# Find-BrowserBookmark

> **SubModule:** GenXdev.Webbrowser | **Type:** Function | **Aliases:** `bookmarks`

## Synopsis

> Finds bookmarks from one or more web browsers.

## Description

Searches through bookmarks from Microsoft Edge, Google Chrome, or Mozilla Firefox.
Returns bookmarks that match one or more search queries in their name, URL, or
folder path. If no queries are provided, returns all bookmarks from the selected
browsers.


## Syntax

```powershell
Find-BrowserBookmark [[-Queries] <String[]>] [-Chrome] [-Count <Int32>] [-Edge] [-Firefox] [-PassThru] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Queries` | String[] | ☐ | Search terms to find matching bookmarks 🌐<br>wildcards |
| `-Edge` | SwitchParameter | ☐ | Search through Microsoft Edge bookmarks |
| `-Chrome` | SwitchParameter | ☐ | Search through Google Chrome bookmarks |
| `-Firefox` | SwitchParameter | ☐ | Search through Firefox bookmarks |
| `-Count` | Int32 | ☐ | Maximum number of results to return |
| `-PassThru` | SwitchParameter | ☐ | Return bookmark objects instead of just URLs |

## Examples

### Find-BrowserBookmark -Query "github" -Edge -Chrome -Count 10 Searches Edge and Chrome bookmarks for "github", returns first 10 URLs

```powershell
Find-BrowserBookmark -Query "github" -Edge -Chrome -Count 10
Searches Edge and Chrome bookmarks for "github", returns first 10 URLs
```

### bookmarks powershell -e -ff -PassThru Searches Edge and Firefox bookmarks for "powershell", returns full objects

```powershell
bookmarks powershell -e -ff -PassThru
Searches Edge and Firefox bookmarks for "powershell", returns full objects
```

## Parameter Details

### `-Queries <String[]>`

> Search terms to find matching bookmarks

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `q`, `Name`, `Text`, `Query` |
| **Accept wildcard characters?** | Yes |

<hr/>

### `-Edge`

> Search through Microsoft Edge bookmarks

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

> Search through Google Chrome bookmarks

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ch` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Firefox`

> Search through Firefox bookmarks

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ff` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Count <Int32>`

> Maximum number of results to return

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `99999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PassThru`

> Return bookmark objects instead of just URLs

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

- [Close-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-Webbrowser.md)
- [Close-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-WebbrowserTab.md)
- [Export-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Export-BrowserBookmarks.md)
- [Get-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-BrowserBookmark.md)
- [Get-DefaultWebbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DefaultWebbrowser.md)
- [Get-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Webbrowser.md)
- [Import-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-BrowserBookmarks.md)
- [Import-GenXdevBookmarkletMenu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-GenXdevBookmarkletMenu.md)
- [Open-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BrowserBookmarks.md)
- [Open-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Webbrowser.md)
- [Open-WebbrowserSideBySide](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebbrowserSideBySide.md)
- [Show-WebsiteInAllBrowsers](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-WebsiteInAllBrowsers.md)
