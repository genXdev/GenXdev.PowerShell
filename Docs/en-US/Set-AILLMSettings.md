# Set-AILLMSettings

> **SubModule:** GenXdev.AI | **Type:** Function | **Aliases:** `llmsettings`

## Synopsis

> Sets the LLM settings for AI operations in GenXdev.AI.

## Description

Configures the LLM (Large Language Model) settings used by the GenXdev.AI
module for various AI operations. Settings can be stored persistently in
preferences (default), only in the current session (using -SessionOnly), or
cleared from the session (using -ClearSession). The function validates that at
least one setting parameter is provided unless clearing session settings.


## Syntax

```powershell
Set-AILLMSettings -LLMQueryType <String> [[-Model] <String>] [[-ApiEndpoint] <String>] [[-ApiKey] <String>] [-AllMachines] [-ClearSession] [-NonInteractive] [-NoSupportForImageUpload] [-NoSupportForJsonSchema] [-NoSupportForToolCalls] [-PreferencesDatabasePath <String>] [-PromptForSettings] [-SessionOnly] [-SkipSession] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-LLMQueryType` | String | ✅ | The type of LLM query |
| `-Model` | String | ☐ | The model identifier or pattern to use for AI<br>operations |
| `-ApiEndpoint` | String | ☐ | The API endpoint URL for AI operations |
| `-ApiKey` | String | ☐ | The API key for authenticated AI operations |
| `-NoSupportForJsonSchema` | SwitchParameter | ☐ | Whether the endpoint does not support<br>json_schema response format |
| `-NoSupportForImageUpload` | SwitchParameter | ☐ | Whether the endpoint does not support image<br>upload functionality |
| `-NoSupportForToolCalls` | SwitchParameter | ☐ | Whether the endpoint does not support tool<br>calling functionality |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for AI  preferences |
| `-PreferencesDatabasePath` | String | ☐ | Database path for preference data files |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without  affecting session |
| `-AllMachines` | SwitchParameter | ☐ | Also write LLM settings to OneDrive for<br>syncing  across multiple machines |
| `-PromptForSettings` | SwitchParameter | ☐ | Launch interactive prompt to configure LLM<br>settings |
| `-NonInteractive` | SwitchParameter | ☐ | Force non-interactive mode — forwards to <br>Invoke-AILLMSettingsPrompt when<br>-PromptForSettings is used |

## Examples

### Set-AILLMSettings -LLMQueryType "Coding" -Model "*Qwen*14B*" Sets the LLM settings for Coding query type persistently in preferences.

```powershell
Set-AILLMSettings -LLMQueryType "Coding" -Model "*Qwen*14B*"
Sets the LLM settings for Coding query type persistently in preferences.
```

### Set-AILLMSettings -LLMQueryType "SimpleIntelligence" -Model "maziyarpanahi/llama-3-groq-8b-tool-use" -SessionOnly Sets the LLM settings for SimpleIntelligence only for the current session.

```powershell
Set-AILLMSettings -LLMQueryType "SimpleIntelligence" -Model "maziyarpanahi/llama-3-groq-8b-tool-use" -SessionOnly
Sets the LLM settings for SimpleIntelligence only for the current
session.
```

### Set-AILLMSettings -LLMQueryType "Pictures" -ClearSession Clears the session LLM settings for Pictures query type without affecting persistent preferences.

```powershell
Set-AILLMSettings -LLMQueryType "Pictures" -ClearSession
Clears the session LLM settings for Pictures query type without affecting
persistent preferences.
```

### Set-AILLMSettings "Coding" "*Qwen*14B*" Sets the LLM settings for Coding query type using positional parameters.

```powershell
Set-AILLMSettings "Coding" "*Qwen*14B*"
Sets the LLM settings for Coding query type using positional parameters.
```

### Set-AILLMSettings -LLMQueryType "SimpleIntelligence" -Model "gpt-4o" -ApiEndpoint "https://api.openai.com/v1/chat/completions" -ApiKey "sk-..." -AllMachines Sets the LLM settings for SimpleIntelligence and syncs to OneDrive for use across multiple machines.

```powershell
Set-AILLMSettings -LLMQueryType "SimpleIntelligence" -Model "gpt-4o" -ApiEndpoint "https://api.openai.com/v1/chat/completions" -ApiKey "sk-..." -AllMachines
Sets the LLM settings for SimpleIntelligence and syncs to OneDrive for
use across multiple machines.
```

## Parameter Details

### `-LLMQueryType <String>`

> The type of LLM query

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Model <String>`

> The model identifier or pattern to use for AI operations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ApiEndpoint <String>`

> The API endpoint URL for AI operations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 7 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ApiKey <String>`

> The API key for authenticated AI operations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 8 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoSupportForJsonSchema`

> Whether the endpoint does not support json_schema response format

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoSupportForImageUpload`

> Whether the endpoint does not support image upload functionality

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoSupportForToolCalls`

> Whether the endpoint does not support tool calling functionality

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Use alternative settings stored in session for  preferences

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

> Clear alternative settings stored in session for AI  preferences

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

### `-SkipSession`

> Store settings only in persistent preferences without  affecting session

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

### `-PromptForSettings`

> Launch interactive prompt to configure LLM settings

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NonInteractive`

> Force non-interactive mode — forwards to  Invoke-AILLMSettingsPrompt when -PromptForSettings is used

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
- [Invoke-AILLMSettingsPrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-AILLMSettingsPrompt.md)
- [Invoke-WinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WinMerge.md)
- [Merge-TranslationCache](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Merge-TranslationCache.md)
- [New-GenXdevMCPToken](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-GenXdevMCPToken.md)
- [New-LLMAudioChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMAudioChat.md)
- [New-LLMTextChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMTextChat.md)
- [Receive-RealTimeSpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Receive-RealTimeSpeechToText.md)
- [Set-GenXdevCommandNotFoundAction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevCommandNotFoundAction.md)
- [Start-GenXdevMCPServer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-GenXdevMCPServer.md)
- [Test-DeepLinkImageFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-DeepLinkImageFile.md)
