# Set-GenXdevDefaultPreference

> **SubModule:** GenXdev.Data.Preferences | **Type:** Cmdlet | **Aliases:** `setPreferenceDefault`

## Synopsis

> Sets a default preference value in the GenXdev preferences store.

## Description

* Manages default preferences in the GenXdev local defaults store.
* Handles storing values, removing preferences when values are empty.
* Use -AllMachines to also write the default to OneDrive for sharing
  across machines.


## Syntax

```powershell
Set-GenXdevDefaultPreference -Name <String> [[-Value] <String>] [[-PreferencesDatabasePath] <String>] [-AllMachines] [-ClearSession] [-SessionOnly] [-SkipSession] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Name` | String | ✅ | The name of the preference to set in defaults |
| `-Value` | String | ☐ | The value to store for the preference |
| `-PreferencesDatabasePath` | String | ☐ | Database path for preference data files |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for Data preferences like Language, Database<br>paths, etc |
| `-ClearSession` | SwitchParameter | ☐ | Clear the session setting (Global variable)<br>before retrieving |
| `-SkipSession` | SwitchParameter | ☐ | Dont use alternative settings stored in<br>session for Data preferences like Language,<br>Database paths, etc |
| `-AllMachines` | SwitchParameter | ☐ | Also write the default preference to OneDrive<br>for sharing across all machines |

## Examples

### Examples 1

```powershell
Set-GenXdevDefaultPreference -Name "Theme" -Value "Dark"
```

Sets the default theme preference to "Dark" locally.

### Examples 2

```powershell
setPreferenceDefault "EmailNotifications" "Disabled" -AllMachines
```

Uses the alias with -AllMachines to share across machines.

## Parameter Details

### `-Name <String>`

> The name of the preference to set in defaults

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByPropertyName) |
| **Aliases** | `PreferenceName` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Value <String>`

> The value to store for the preference

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByPropertyName) |
| **Aliases** | `PreferenceValue` |
| **Accept wildcard characters?** | No |

<hr/>

### `-PreferencesDatabasePath <String>`

> Database path for preference data files

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DatabasePath` |
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

### `-SkipSession`

> Dont use alternative settings stored in session for Data preferences like Language, Database paths, etc

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AllMachines`

> Also write the default preference to OneDrive for sharing across all machines

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
- [Remove-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-GenXdevPreference.md)
- [Set-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreference.md)
- [Set-GenXdevPreferencesDatabasePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreferencesDatabasePath.md)
