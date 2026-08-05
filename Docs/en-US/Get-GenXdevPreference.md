# Get-GenXdevPreference

> **SubModule:** GenXdev.Data.Preferences | **Type:** Cmdlet | **Aliases:** `getPreference`

## Synopsis

> Retrieves a preference value from the GenXdev preferences store.

## Description

* Implements a five-tier preference retrieval system:
  session, local prefs, local defaults, OneDrive, then fallback default.
* First checks the session for a preference value.
* If not found, checks the local preferences store.
* If not found, checks the local defaults store.
* If not found, checks OneDrive shared defaults.
* If still not found, returns the provided default value.


## Syntax

```powershell
Get-GenXdevPreference -Name <String> [[-DefaultValue] <String>] [-ClearSession] [-PreferencesDatabasePath <String>] [-SessionOnly] [-SkipSession] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Name` | String | ✅ | The name of the preference to retrieve |
| `-DefaultValue` | String | ☐ | The default value if preference is not found |
| `-PreferencesDatabasePath` | String | ☐ | Database path for preference data files |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for Data preferences like Language, Database<br>paths, etc |
| `-ClearSession` | SwitchParameter | ☐ | Clear the session setting (Global variable)<br>before retrieving |
| `-SkipSession` | SwitchParameter | ☐ | Dont use alternative settings stored in<br>session for Data preferences like Language,<br>Database paths, etc |

## Examples

### Examples 1

```powershell
Get-GenXdevPreference -Name "Theme" -DefaultValue "Dark"
```

Retrieves the "Theme" preference with fallback to default "Dark".

### Examples 2

```powershell
getPreference "Theme" "Dark"
```

Uses the alias and positional parameters.

## Parameter Details

### `-Name <String>`

> The name of the preference to retrieve

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `PreferenceName` |
| **Accept wildcard characters?** | No |

<hr/>

### `-DefaultValue <String>`

> The default value if preference is not found

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByPropertyName) |
| **Aliases** | `DefaultPreference` |
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

## Related Links

- [Get-GenXdevPreferenceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreferenceNames.md)
- [Get-GenXdevPreferencesDatabasePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreferencesDatabasePath.md)
- [Remove-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-GenXdevPreference.md)
- [Set-GenXdevDefaultPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevDefaultPreference.md)
- [Set-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreference.md)
- [Set-GenXdevPreferencesDatabasePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreferencesDatabasePath.md)
