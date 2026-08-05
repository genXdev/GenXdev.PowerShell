# Get-Webbrowser

> **SubModule:** GenXdev.Webbrowser | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Returns a collection of installed modern web browsers.

## Description

* Discovers and returns details about modern web browsers installed on the
  system.
* Retrieves information including name, description, icon path, executable
  path and default browser status by querying the Windows registry.
* Only returns browsers that have the required capabilities registered in
  Windows.


## Syntax

```powershell
Get-Webbrowser [-Chrome] [-Chromium] [-Edge] [-Firefox] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Edge` | SwitchParameter | ☐ | Selects Microsoft Edge browser instances |
| `-Chrome` | SwitchParameter | ☐ | Selects Google Chrome browser instances |
| `-Chromium` | SwitchParameter | ☐ | Selects default chromium-based browser |
| `-Firefox` | SwitchParameter | ☐ | Selects Firefox browser instances |

## Examples

### Examples 1

```powershell
Get-Webbrowser | Select-Object Name, Description | Format-Table
```

Returns a collection of all installed modern web browsers.

### Examples 2

```powershell
Get-Webbrowser | Where-Object { $_.IsDefaultBrowser }
```

Filters to show only the system default browser.

## Parameter Details

### `-Edge`

> Selects Microsoft Edge browser instances

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `e` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Specific |

<hr/>

### `-Chrome`

> Selects Google Chrome browser instances

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `ch` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Specific |

<hr/>

### `-Chromium`

> Selects default chromium-based browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `c` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Specific |

<hr/>

### `-Firefox`

> Selects Firefox browser instances

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `ff` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Specific |

<hr/>

## Related Links

- [Close-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-Webbrowser.md)
- [Close-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-WebbrowserTab.md)
- [Export-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Export-BrowserBookmarks.md)
- [Find-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-BrowserBookmark.md)
- [Get-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-BrowserBookmark.md)
- [Get-DefaultWebbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DefaultWebbrowser.md)
- [Import-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-BrowserBookmarks.md)
- [Import-GenXdevBookmarkletMenu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-GenXdevBookmarkletMenu.md)
- [Open-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BrowserBookmarks.md)
- [Open-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Webbrowser.md)
- [Open-WebbrowserSideBySide](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebbrowserSideBySide.md)
- [Show-WebsiteInAllBrowsers](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-WebsiteInAllBrowsers.md)
