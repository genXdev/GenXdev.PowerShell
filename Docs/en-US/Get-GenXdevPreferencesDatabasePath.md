# Get-GenXdevPreferencesDatabasePath

> **SubModule:** GenXdev.Data.Preferences | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Gets the configured database path for preference data files used in
GenXdev.Data operations.

## Description

* Retrieves the global database path used by the GenXdev.Data module for
  various preference storage and data operations.
* Checks Global variables first (unless SkipSession is specified), then
  falls back to persistent preferences, and finally uses system defaults.


## Syntax

```powershell
Get-GenXdevPreferencesDatabasePath [[-PreferencesDatabasePath] <String>] [-ClearSession] [-SessionOnly] [-SkipSession] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-PreferencesDatabasePath` | String | ☐ | Optional database path override |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for Data preferences like Language, Database<br>paths, etc |
| `-ClearSession` | SwitchParameter | ☐ | Clear the session setting (Global variable)<br>before retrieving |
| `-SkipSession` | SwitchParameter | ☐ | Dont use alternative settings stored in<br>session for Data preferences like Language,<br>Database paths, etc |

## Examples

### Examples 1

```powershell
Get-GenXdevPreferencesDatabasePath
```

Retrieves the database path from Global variables or preferences.

### Examples 2

```powershell
Get-GenXdevPreferencesDatabasePath -SkipSession
```

Skips the session variable and uses persistent preferences.

### Examples 3

```powershell
Get-GenXdevPreferencesDatabasePath -ClearSession
```

Clears the session setting before retrieving the path.

## Parameter Details

### `-PreferencesDatabasePath <String>`

> Optional database path override

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
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

- [Get-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreference.md)
- [Get-GenXdevPreferenceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXdevPreferenceNames.md)
- [Remove-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-GenXdevPreference.md)
- [Set-GenXdevDefaultPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevDefaultPreference.md)
- [Set-GenXdevPreference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreference.md)
- [Set-GenXdevPreferencesDatabasePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevPreferencesDatabasePath.md)
