# Invoke-AILLMSettingsPrompt

> **SubModule:** GenXdev.AI | **Type:** Function | **Aliases:** `llmset`, `promptllmsettings`

## Synopsis

> Launches an interactive Spectre.Console prompt to configure LLM settings.

## Description

Provides an interactive terminal UI using Spectre.Console SelectionPrompt
(arrow keys + mouse) to guide the user through LLM provider configuration.
The user can pick a default provider (requiring only an API key) or enter all
settings manually. API keys are stored per provider family (e.g. "DeepSeek")
with user-given names like "Work" or "Personal", and are reused across query
types.
When -LLMQueryType is omitted, a type-selection menu is shown first with an
"ALL" option to configure all query types at once or in sequence.


## Syntax

```powershell
Invoke-AILLMSettingsPrompt [[-LLMQueryType] <String>] [-AllMachines] [-ClearSession] [-NonInteractive] [-PreferencesDatabasePath <String>] [-SessionOnly] [-SkipSession] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-LLMQueryType` | String | ☐ | The type of LLM query to configure (menu<br>shown if  omitted) |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  AI preferences |
| `-ClearSession` | SwitchParameter | ☐ | Clear the session setting (Global variable) <br>before saving |
| `-SkipSession` | SwitchParameter | ☐ | When specified, skips session settings and <br>writes only to persistent preferences or<br>defaults |
| `-AllMachines` | SwitchParameter | ☐ | Also write LLM settings to OneDrive for<br>syncing  across multiple machines |
| `-PreferencesDatabasePath` | String | ☐ | Database path for preference data files |
| `-NonInteractive` | SwitchParameter | ☐ | Force non-interactive mode. Used for testing <br>to verify guard clause behavior. |

## Examples

### Invoke-AILLMSettingsPrompt -LLMQueryType "ToolUse" Launches interactive setup for the ToolUse query type.

```powershell
Invoke-AILLMSettingsPrompt -LLMQueryType "ToolUse"
Launches interactive setup for the ToolUse query type.
```

### Invoke-AILLMSettingsPrompt Shows a type-selection menu, then launches interactive setup.

```powershell
Invoke-AILLMSettingsPrompt
Shows a type-selection menu, then launches interactive setup.
```

### Invoke-AILLMSettingsPrompt "Coding" -PreferencesDatabasePath "C:\custom\prefs" Launches interactive setup for Coding with a custom preferences database.

```powershell
Invoke-AILLMSettingsPrompt "Coding" -PreferencesDatabasePath "C:\custom\prefs"
Launches interactive setup for Coding with a custom preferences database.
```

## Parameter Details

### `-LLMQueryType <String>`

> The type of LLM query to configure (menu shown if  omitted)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Use alternative settings stored in session for  AI preferences

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

> Clear the session setting (Global variable)  before saving

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

> When specified, skips session settings and  writes only to persistent preferences or defaults

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AllMachines`

> Also write LLM settings to OneDrive for syncing  across multiple machines

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
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

### `-NonInteractive`

> Force non-interactive mode. Used for testing  to verify guard clause behavior.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AILLMSettings.md)
- [Get-SpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SpeechToText.md)
- [Get-TextTranslation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TextTranslation.md)
- [Get-VectorSimilarity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-VectorSimilarity.md)
- [Invoke-WinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WinMerge.md)
- [Merge-TranslationCache](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Merge-TranslationCache.md)
- [New-GenXdevMCPToken](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-GenXdevMCPToken.md)
- [New-LLMAudioChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMAudioChat.md)
- [New-LLMTextChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMTextChat.md)
- [Receive-RealTimeSpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Receive-RealTimeSpeechToText.md)
- [Set-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AILLMSettings.md)
- [Set-GenXdevCommandNotFoundAction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevCommandNotFoundAction.md)
- [Start-GenXdevMCPServer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-GenXdevMCPServer.md)
- [Test-DeepLinkImageFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-DeepLinkImageFile.md)
