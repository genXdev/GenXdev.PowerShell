# Get-Refactor

> **SubModule:** GenXdev.Coding | **Type:** Function | **Aliases:** `refactors`

## Synopsis

> Retrieves refactor definitions from GenXdev preferences based on name patterns.

## Description

Searches for and loads refactor definition sets stored in GenXdev preferences.
Each refactor set is stored as a JSON string in a preference with name starting
with 'refactor_set_'. The function deserializes matching sets into objects.


## Syntax

```powershell
Get-Refactor [[-Name] <String[]>] [-ClearSession] [-DefaultValue <String>] [-PreferencesDatabasePath <String>] [-SessionOnly] [-SkipSession] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Name` | String[] | ☐ | Pattern(s) to search for refactor definitions<br>🌐 wildcards |
| `-PreferencesDatabasePath` | String | ☐ | Database path for preference data files |
| `-DefaultValue` | String | ☐ | The default value if preference is not found |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for Data  preferences like Language, Database<br>paths, etc |
| `-ClearSession` | SwitchParameter | ☐ | Clear the session setting (Global variable)<br>before  retrieving |
| `-SkipSession` | SwitchParameter | ☐ | Dont use alternative settings stored in<br>session for  Data preferences like Language,<br>Database paths, etc |

## Examples

### Get-Refactor -Name "CodeStyle*" Returns refactor definitions matching pattern "CodeStyle*"

```powershell
Get-Refactor -Name "CodeStyle*"
Returns refactor definitions matching pattern "CodeStyle*"
```

### refactor "UnitTest" Uses alias to find refactor definitions containing "UnitTest"

```powershell
refactor "UnitTest"
Uses alias to find refactor definitions containing "UnitTest"
```

## Parameter Details

### `-Name <String[]>`

> Pattern(s) to search for refactor definitions

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `@('*')` |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `PreferenceName` |
| **Accept wildcard characters?** | Yes |

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

### `-DefaultValue <String>`

> The default value if preference is not found

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DefaultPreference` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Use alternative settings stored in session for Data  preferences like Language, Database paths, etc

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ClearSession`

> Clear the session setting (Global variable) before  retrieving

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipSession`

> Dont use alternative settings stored in session for  Data preferences like Language, Database paths, etc

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

## Outputs

- `GenXdev.Helpers.RefactorDefinition[]`

## Related Links

- [Add-FeatureLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-FeatureLineToREADME.md)
- [Add-IdeaLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-IdeaLineToREADME.md)
- [Add-IssueLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-IssueLineToREADME.md)
- [Add-LineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-LineToREADME.md)
- [Add-ReleaseNoteLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-ReleaseNoteLineToREADME.md)
- [Add-TodoLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-TodoLineToREADME.md)
- [Backup-CompletedFeatures](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedFeatures.md)
- [Backup-CompletedIdeas](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedIdeas.md)
- [Backup-CompletedIssues](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedIssues.md)
- [Backup-CompletedReleaseNotes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedReleaseNotes.md)
- [Backup-CompletedTodoos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedTodoos.md)
- [Backup-READMESections](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-READMESections.md)
- [Get-Features](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Features.md)
- [Get-Ideas](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Ideas.md)
- [Get-Issues](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Issues.md)
- [Get-RefactorReport](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RefactorReport.md)
- [Get-ReleaseNotes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ReleaseNotes.md)
- [Get-Todoos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Todoos.md)
- [New-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-Refactor.md)
- [Open-SourceFileInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SourceFileInIde.md)
- [Publish-ReleaseNotesToManifest](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Publish-ReleaseNotesToManifest.md)
- [Remove-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-Refactor.md)
- [Start-NextRefactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-NextRefactor.md)
- [Update-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-Refactor.md)
- [VSCode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/VSCode.md)
