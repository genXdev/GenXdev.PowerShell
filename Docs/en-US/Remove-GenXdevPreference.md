# Remove-GenXdevPreference

> **SubModule:** GenXdev.Data.Preferences | **Type:** Cmdlet | **Aliases:** `removePreference`

## Synopsis

> Removes a preference value from the GenXdev preferences store.

## Description

* Removes a preference value from the local store and optionally from the
  defaults store.
* Use -AllMachines to also remove the preference from OneDrive shared
  across all machines.


## Syntax

```powershell
Remove-GenXdevPreference -Name <String> [-AllMachines] [-ClearSession] [-PreferencesDatabasePath <String>] [-RemoveDefault] [-SessionOnly] [-SkipSession] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Name` | String | ✅ | The name of the preference to remove |
| `-RemoveDefault` | SwitchParameter | ☐ | Switch to also remove the preference from<br>defaults |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for Data preferences like Language, Database<br>paths, etc |
| `-ClearSession` | SwitchParameter | ☐ | Clear the session setting (Global variable)<br>before retrieving |
| `-PreferencesDatabasePath` | String | ☐ | Database path for preference data files |
| `-SkipSession` | SwitchParameter | ☐ | Dont use alternative settings stored in<br>session for Data preferences like Language,<br>Database paths, etc |
| `-AllMachines` | SwitchParameter | ☐ | Also remove the preference from OneDrive<br>shared across all machines |

## Examples

### Examples 1

```powershell
Remove-GenXdevPreference -Name "Theme"
```

Removes the "Theme" preference from the local store only.

### Examples 2

```powershell
removePreference "Theme" -RemoveDefault -AllMachines
```

Removes "Theme" from local, defaults, and OneDrive.

## Parameter Details

### `-Name <String>`

> The name of the preference to remove

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-RemoveDefault`

> Switch to also remove the preference from defaults

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Use alternative settings stored in session for Data preferences like Language, Database paths, etc

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ClearSession`

> Clear the session setting (Global variable) before retrieving

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PreferencesDatabasePath <String>`

> Database path for preference data files

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DatabasePath` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipSession`

> Dont use alternative settings stored in session for Data preferences like Language, Database paths, etc

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AllMachines`

> Also remove the preference from OneDrive shared across all machines

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreference.md)
- [Get-GenXdevPreferenceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreferenceNames.md)
- [Get-GenXdevPreferencesDatabasePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreferencesDatabasePath.md)
- [Set-GenXdevDefaultPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevDefaultPreference.md)
- [Set-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreference.md)
- [Set-GenXdevPreferencesDatabasePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreferencesDatabasePath.md)
