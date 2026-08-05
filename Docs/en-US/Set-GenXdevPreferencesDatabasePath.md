# Set-GenXdevPreferencesDatabasePath

> **SubModule:** GenXdev.Data.Preferences | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Sets the database path for preferences used in GenXdev.Data operations.

## Description

* Configures the global database path used by the GenXdev.Data module for
  various preference storage and data operations.
* Settings are stored in the current session (using Global variables) and
  can be cleared from the session (using -ClearSession).


## Syntax

```powershell
Set-GenXdevPreferencesDatabasePath [[-PreferencesDatabasePath] <String>] [-ClearSession] [-SessionOnly] [-SkipSession] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-PreferencesDatabasePath` | String | ☐ | A database path where preference data files<br>are located |
| `-SkipSession` | SwitchParameter | ☐ | Dont use alternative settings stored in<br>session for Data preferences like Language,<br>Database paths, etc |
| `-SessionOnly` | SwitchParameter | ☐ | When specified, stores the setting only in<br>the current session (Global variable) without<br>persisting to preferences |
| `-ClearSession` | SwitchParameter | ☐ | When specified, clears only the session<br>setting (Global variable) without affecting<br>persistent preferences |

## Examples

### Examples 1

```powershell
Set-GenXdevPreferencesDatabasePath -PreferencesDatabasePath "C:\Data\Preferences.db"
```

Sets the database path in the current session (Global variable).

### Examples 2

```powershell
Set-GenXdevPreferencesDatabasePath "C:\MyPreferences.db"
```

Sets the database path using positional parameter.

### Examples 3

```powershell
Set-GenXdevPreferencesDatabasePath "C:\TempPrefs.db" -SessionOnly
```

Sets the path only for the current session without persisting.

### Examples 4

```powershell
Set-GenXdevPreferencesDatabasePath -ClearSession
```

Clears the Global variable for the database path.

## Parameter Details

### `-PreferencesDatabasePath <String>`

> A database path where preference data files are located

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
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
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> When specified, stores the setting only in the current session (Global variable) without persisting to preferences

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

> When specified, clears only the session setting (Global variable) without affecting persistent preferences

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
- [Set-GenXdevDefaultPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevDefaultPreference.md)
- [Set-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreference.md)
