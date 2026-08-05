# Import-GenXdevBookmarkletMenu

> **SubModule:** GenXdev.Webbrowser | **Type:** Function | **Aliases:** —

## Synopsis

> Imports GenXdev JavaScript bookmarklets into browser bookmark collections.

## Description

This function scans a directory for GenXdev bookmarklet files with the


## Syntax

```powershell
Import-GenXdevBookmarkletMenu [[-SnippetsPath] <String>] [[-TargetFolder] <String>] [-Chrome] [-Edge] [-Firefox] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-SnippetsPath` | String | ☐ | Path to directory containing bookmarklet<br>snippet files |
| `-TargetFolder` | String | ☐ | Target bookmark folder in browser bookmark<br>structure |
| `-Edge` | SwitchParameter | ☐ | Import bookmarklets into Microsoft Edge<br>browser |
| `-Chrome` | SwitchParameter | ☐ | Import bookmarklets into Google Chrome<br>browser |
| `-Firefox` | SwitchParameter | ☐ | Import bookmarklets into Mozilla Firefox<br>browser |

## Examples

### Import-GenXdevBookmarkletMenu -Edge Imports all bookmarklet files from the default snippets directory into Microsoft Edge's bookmark bar folder.

```powershell
Import-GenXdevBookmarkletMenu -Edge
Imports all bookmarklet files from the default snippets directory into
Microsoft Edge's bookmark bar folder.
```

### Import-GenXdevBookmarkletMenu -SnippetsPath "C:\MyBookmarklets" -Chrome -WhatIf Shows what bookmarklets would be imported from the specified path into Google Chrome without actually performing the import operation.

```powershell
Import-GenXdevBookmarkletMenu -SnippetsPath "C:\MyBookmarklets" -Chrome -WhatIf
Shows what bookmarklets would be imported from the specified path into
Google Chrome without actually performing the import operation.
```

## Parameter Details

### `-SnippetsPath <String>`

> Path to directory containing bookmarklet snippet files

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `"$($MyInvocation.MyCommand.Module.ModuleBase)\Bookmarklets"` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-TargetFolder <String>`

> Target bookmark folder in browser bookmark structure

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `""` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Edge`

> Import bookmarklets into Microsoft Edge browser

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

> Import bookmarklets into Google Chrome browser

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

> Import bookmarklets into Mozilla Firefox browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ff` |
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
- [Open-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BrowserBookmarks.md)
- [Open-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Webbrowser.md)
- [Open-WebbrowserSideBySide](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebbrowserSideBySide.md)
- [Show-WebsiteInAllBrowsers](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-WebsiteInAllBrowsers.md)
