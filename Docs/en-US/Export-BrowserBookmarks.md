# Export-BrowserBookmarks

> **SubModule:** GenXdev.Webbrowser | **Type:** Function | **Aliases:** —

## Synopsis

> Exports browser bookmarks to a JSON file.

## Description

The Export-BrowserBookmarks cmdlet exports bookmarks from a specified web browser
(Microsoft Edge, Google Chrome, or Mozilla Firefox) to a JSON file. Only one
browser type can be specified at a time. The bookmarks are exported with full
preservation of their structure and metadata.


## Syntax

```powershell
Export-BrowserBookmarks -OutputFile <String> [-Chrome] [-Edge] [<CommonParameters>]

Export-BrowserBookmarks [-Firefox] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-OutputFile` | String | ✅ | Path to the JSON file where bookmarks will be<br>saved |
| `-Chrome` | SwitchParameter | ☐ | Export bookmarks from Google Chrome |
| `-Edge` | SwitchParameter | ☐ | Export bookmarks from Microsoft Edge |
| `-Firefox` | SwitchParameter | ☐ | Export bookmarks from Mozilla Firefox |

## Examples

### Export-BrowserBookmarks -OutputFile "C:\MyBookmarks.json" -Edge

```powershell
Export-BrowserBookmarks -OutputFile "C:\MyBookmarks.json" -Edge
```

### Export-BrowserBookmarks "C:\MyBookmarks.json" -Chrome

```powershell
Export-BrowserBookmarks "C:\MyBookmarks.json" -Chrome
```

## Parameter Details

### `-OutputFile <String>`

> Path to the JSON file where bookmarks will be saved

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Chrome`

> Export bookmarks from Google Chrome

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ch` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Edge`

> Export bookmarks from Microsoft Edge

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `e` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Firefox`

> Export bookmarks from Mozilla Firefox

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ff` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Firefox |

<hr/>

## Related Links

- [Close-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-Webbrowser.md)
- [Close-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-WebbrowserTab.md)
- [Find-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-BrowserBookmark.md)
- [Get-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-BrowserBookmark.md)
- [Get-DefaultWebbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DefaultWebbrowser.md)
- [Get-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Webbrowser.md)
- [Import-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-BrowserBookmarks.md)
- [Import-GenXdevBookmarkletMenu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-GenXdevBookmarkletMenu.md)
- [Open-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BrowserBookmarks.md)
- [Open-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Webbrowser.md)
- [Open-WebbrowserSideBySide](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebbrowserSideBySide.md)
- [Show-WebsiteInAllBrowsers](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-WebsiteInAllBrowsers.md)
