# Import-BrowserBookmarks

> **SubModule:** GenXdev.Webbrowser | **Type:** Function | **Aliases:** —

## Synopsis

> Imports bookmarks from a file or collection into a web browser.

## Description

Imports bookmarks into Microsoft Edge or Google Chrome from either a CSV file or
a collection of bookmark objects. The bookmarks are added to the browser's
bookmark bar or specified folders. Firefox import is not currently supported.


## Syntax

```powershell
Import-BrowserBookmarks [[-InputFile] <String>] [<CommonParameters>]

Import-BrowserBookmarks [[-Bookmarks] <Array>] [<CommonParameters>]

Import-BrowserBookmarks [-Chrome] [-Edge] [-Firefox] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-InputFile` | String | ☐ | Path to CSV file with bookmarks to import |
| `-Bookmarks` | Array | ☐ | Collection of bookmarks to import |
| `-Chrome` | SwitchParameter | ☐ | Import into Google Chrome |
| `-Edge` | SwitchParameter | ☐ | Import into Microsoft Edge |
| `-Firefox` | SwitchParameter | ☐ | Import into Firefox (not supported) |

## Examples

### Import-BrowserBookmarks -InputFile "C:\MyBookmarks.csv" -Edge Imports bookmarks from the CSV file into Microsoft Edge.

```powershell
Import-BrowserBookmarks -InputFile "C:\MyBookmarks.csv" -Edge
Imports bookmarks from the CSV file into Microsoft Edge.
```

### $bookmarks = @(     @{         Name = "Microsoft";         URL = "https://microsoft.com";         Folder = "Tech"     } ) Import-BrowserBookmarks -Bookmarks $bookmarks -Chrome Imports a collection of bookmarks into Google Chrome.

```powershell
$bookmarks = @(
    @{
        Name = "Microsoft";
        URL = "https://microsoft.com";
        Folder = "Tech"
    }
)
Import-BrowserBookmarks -Bookmarks $bookmarks -Chrome
Imports a collection of bookmarks into Google Chrome.
```

## Parameter Details

### `-InputFile <String>`

> Path to CSV file with bookmarks to import

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | FromFile |

<hr/>

### `-Bookmarks <Array>`

> Collection of bookmarks to import

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | FromCollection |

<hr/>

### `-Chrome`

> Import into Google Chrome

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

> Import into Microsoft Edge

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

> Import into Firefox (not supported)

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
- [Import-GenXdevBookmarkletMenu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-GenXdevBookmarkletMenu.md)
- [Open-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BrowserBookmarks.md)
- [Open-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Webbrowser.md)
- [Open-WebbrowserSideBySide](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebbrowserSideBySide.md)
- [Show-WebsiteInAllBrowsers](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-WebsiteInAllBrowsers.md)
