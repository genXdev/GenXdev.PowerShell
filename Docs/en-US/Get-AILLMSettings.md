# Get-AILLMSettings

> **SubModule:** GenXdev.AI | **Type:** Function | **Aliases:** —

## Synopsis

> Gets the LLM settings for AI operations in GenXdev.AI.

## Description

This function retrieves the LLM (Large Language Model) settings used by the
GenXdev.AI module for various AI operations. Settings are retrieved from
session variables, persistent preferences, or default settings JSON file, in
that order of precedence.
If no settings are found for the requested LLMQueryType, the function
automatically checks whether another LLMQueryType has been manually configured
and falls back to those settings. If no type has ever been configured and the
session is interactive, the user is prompted to select a default provider or
enter settings manually. In non-interactive sessions (e.g., SSH remoting), an
error is thrown with instructions for configuring settings.


## Syntax

```powershell
Get-AILLMSettings [[-LLMQueryType] <String>] [-ApiEndpoint <String>] [-ApiKey <String>] [-ClearSession] [-Model <String>] [-NonInteractive] [-NoSupportForImageUpload] [-NoSupportForJsonSchema] [-NoSupportForToolCalls] [-PreferencesDatabasePath <String>] [-PromptForSettings] [-SessionOnly] [-SkipSession] [-SuppressAutoPrompt] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-LLMQueryType` | String | ☐ | The type of LLM query to get settings for |
| `-Model` | String | ☐ | The model identifier or pattern to use for AI<br>operations |
| `-ApiEndpoint` | String | ☐ | The API endpoint URL for AI operations |
| `-ApiKey` | String | ☐ | The API key for authenticated AI operations |
| `-NoSupportForJsonSchema` | SwitchParameter | ☐ | Whether the endpoint does not support<br>json_schema response format |
| `-NoSupportForImageUpload` | SwitchParameter | ☐ | Whether the endpoint does not support image<br>upload functionality |
| `-NoSupportForToolCalls` | SwitchParameter | ☐ | Whether the endpoint does not support tool<br>calling functionality |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences like Language, Image<br>collections, etc |
| `-ClearSession` | SwitchParameter | ☐ | Clear the session setting (Global variable)<br>before retrieving |
| `-PreferencesDatabasePath` | String | ☐ | Database path for preference data files |
| `-SkipSession` | SwitchParameter | ☐ | Skip session settings and get from<br>preferences  or defaults only |
| `-PromptForSettings` | SwitchParameter | ☐ | Launch interactive prompt to configure LLM<br>settings |
| `-SuppressAutoPrompt` | SwitchParameter | ☐ | Suppress auto-prompt when ApiKey is missing. <br>Used internally to prevent recursion during<br>display. |
| `-NonInteractive` | SwitchParameter | ☐ | Force non-interactive mode — forwards to <br>Invoke-AILLMSettingsPrompt when<br>-PromptForSettings is used |

## Examples

### Get-AILLMSettings Gets the LLM settings for SimpleIntelligence query type (default).

```powershell
Get-AILLMSettings
Gets the LLM settings for SimpleIntelligence query type (default).
```

### Get-AILLMSettings -LLMQueryType "Coding" Gets the LLM settings for Coding query type.

```powershell
Get-AILLMSettings -LLMQueryType "Coding"
Gets the LLM settings for Coding query type.
```

### Get-AILLMSettings -SkipSession Gets the LLM settings from preferences or defaults only, ignoring session settings.

```powershell
Get-AILLMSettings -SkipSession
Gets the LLM settings from preferences or defaults only, ignoring session
settings.
```

### Get-AILLMSettings "Knowledge"

```powershell
Get-AILLMSettings "Knowledge"
```

## Parameter Details

### `-LLMQueryType <String>`

> The type of LLM query to get settings for

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `'SimpleIntelligence'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Model <String>`

> The model identifier or pattern to use for AI operations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
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
| **Position?** | Named |
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
| **Position?** | Named |
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

> Use alternative settings stored in session for  preferences like Language, Image collections, etc

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

> Clear the session setting (Global variable) before retrieving

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

> Skip session settings and get from preferences  or defaults only

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
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

### `-SuppressAutoPrompt`

> Suppress auto-prompt when ApiKey is missing.  Used internally to prevent recursion during display.

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

## Outputs

- `Collections.Hashtable`

## Related Links

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
- [Set-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AILLMSettings.md)
- [Set-GenXdevCommandNotFoundAction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevCommandNotFoundAction.md)
- [Start-GenXdevMCPServer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-GenXdevMCPServer.md)
- [Test-DeepLinkImageFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-DeepLinkImageFile.md)
