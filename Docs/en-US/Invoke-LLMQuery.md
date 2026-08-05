# Invoke-LLMQuery

> **SubModule:** GenXdev.AI.Queries | **Type:** Function | **Aliases:** `qllm`, `llm`

## Synopsis

> Sends queries to an OpenAI compatible Large Language Chat completion API and
processes responses.

## Description

This function sends queries to an OpenAI compatible Large Language Chat
completion API and processes responses. It supports text and image inputs,
handles tool function calls, and can operate in various chat modes including
text and audio.
The function provides comprehensive support for LLM interaction including:
- Text and image input processing
- Tool function calling and command execution
- Interactive chat modes (text and audio)
- Model initialization and configuration
- Response formatting and processing
- Session management and caching
- Window positioning and display control


## Syntax

```powershell
Invoke-LLMQuery [[-Query] <String>] [[-Instructions] <String>] [[-Attachments] <String[]>] [-ApiEndpoint <String>] [-ApiKey <String>] [-AudioContextSize <Int32>] [-AudioTemperature <Double>] [-ChatMode <String>] [-ChatOnce] [-ClearSession] [-ContinueLast] [-CpuThreads <Int32>] [-DontAddThoughtsToHistory] [-DontSpeak] [-DontSpeakThoughts] [-EntropyThreshold <Double>] [-ExposedCmdLets <GenXdev.Helpers.ExposedCmdletDefinition[]>] [-FilterForJsonOutput] [-Functions <Collections.Hashtable[]>] [-Gpu <Int32>] [-ImageDetail <String>] [-IncludeThoughts] [-Language <String>] [-LengthPenalty <Double>] [-LLMQueryType <String>] [-LogProbThreshold <Double>] [-MarkupBlocksTypeFilter <String[]>] [-MaxToolcallBackLength <Int32>] [-Model <String>] [-NoConfirmationToolFunctionNames <String[]>] [-NoContext] [-NoSessionCaching] [-NoSpeechThreshold <Double>] [-NoSupportForJsonSchema] [-NoVOX] [-OnlyResponses] [-OutputMarkdownBlocksOnly] [-PreferencesDatabasePath <String>] [-PromptForSettings] [-QuietToolChainInvocations] [-ResponseFormat <String>] [-SessionOnly] [-SilenceThreshold <Double>] [-SkipSession] [-Speak] [-SpeakThoughts] [-SuppressRegex <String>] [-Temperature <Double>] [-TemperatureResponse <Double>] [-TimeoutSeconds <Int32>] [-UseDesktopAudioCapture] [-WithBeamSearchSamplingStrategy] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Query` | String | ☐ | Query text to send to the model |
| `-Instructions` | String | ☐ | System instructions for the model |
| `-Attachments` | String[] | ☐ | Array of file paths to attach |
| `-ResponseFormat` | String | ☐ | A JSON schema for the requested output format |
| `-Temperature` | Double | ☐ | Temperature for response randomness (0.0-1.0) |
| `-Functions` | Collections.Hashtable[] | ☐ | Array of function definitions |
| `-ExposedCmdLets` | GenXdev.Helpers.ExposedCmdletDefinition[] | ☐ | Array of PowerShell command definitions to<br>use  as tools |
| `-NoConfirmationToolFunctionNames` | String[] | ☐ | Tool functions that don't require user <br>confirmation |
| `-QuietToolChainInvocations` | SwitchParameter | ☐ | Suppresses Write-Host output during <br>intermediate tool chain invocations |
| `-ImageDetail` | String | ☐ | Image detail level |
| `-LLMQueryType` | String | ☐ | The type of LLM query |
| `-Model` | String | ☐ | The model identifier or pattern to use for AI<br>operations |
| `-Gpu` | Int32 | ☐ | The `-Gpu` parameter. |
| `-ApiEndpoint` | String | ☐ | The API endpoint URL for AI operations |
| `-ApiKey` | String | ☐ | The API key for authenticated AI operations |
| `-PromptForSettings` | SwitchParameter | ☐ | Launch interactive prompt to configure LLM<br>settings |
| `-NoSupportForJsonSchema` | SwitchParameter | ☐ | Indicates that LLM has no support for JSON<br>schemas |
| `-TimeoutSeconds` | Int32 | ☐ | The timeout in seconds for AI operations |
| `-PreferencesDatabasePath` | String | ☐ | Database path for preference data files |
| `-AudioTemperature` | Double | ☐ | Temperature for audio generation randomness |
| `-TemperatureResponse` | Double | ☐ | Temperature for response randomness (audio<br>chat) |
| `-Language` | String | ☐ | Language code or name for audio chat |
| `-CpuThreads` | Int32 | ☐ | Number of CPU threads to use for audio chat |
| `-SuppressRegex` | String | ☐ | Regular expression to suppress certain<br>outputs in audio chat |
| `-AudioContextSize` | Int32 | ☐ | Audio context size for audio chat |
| `-SilenceThreshold` | Double | ☐ | Silence threshold for audio chat |
| `-LengthPenalty` | Double | ☐ | Length penalty for audio chat responses |
| `-EntropyThreshold` | Double | ☐ | Entropy threshold for audio chat |
| `-LogProbThreshold` | Double | ☐ | Log probability threshold for audio chat |
| `-NoSpeechThreshold` | Double | ☐ | No speech threshold for audio chat |
| `-DontSpeak` | SwitchParameter | ☐ | Do not speak audio responses |
| `-DontSpeakThoughts` | SwitchParameter | ☐ | Do not speak audio thoughts |
| `-NoVOX` | SwitchParameter | ☐ | Disable VOX (voice activation) for audio chat |
| `-UseDesktopAudioCapture` | SwitchParameter | ☐ | Use desktop audio capture for audio chat |
| `-NoContext` | SwitchParameter | ☐ | Disable context for audio chat |
| `-WithBeamSearchSamplingStrategy` | SwitchParameter | ☐ | Use beam search sampling strategy for audio<br>chat |
| `-OnlyResponses` | SwitchParameter | ☐ | Return only responses (no intermediate<br>output) |
| `-IncludeThoughts` | SwitchParameter | ☐ | Include model's thoughts in output |
| `-DontAddThoughtsToHistory` | SwitchParameter | ☐ | Exclude thought processes from conversation <br>history |
| `-ContinueLast` | SwitchParameter | ☐ | Continue from last conversation |
| `-Speak` | SwitchParameter | ☐ | Enable text-to-speech for AI responses |
| `-SpeakThoughts` | SwitchParameter | ☐ | Enable text-to-speech for AI thought<br>responses |
| `-OutputMarkdownBlocksOnly` | SwitchParameter | ☐ | Will only output markup block responses |
| `-FilterForJsonOutput` | SwitchParameter | ☐ | Extracts the outermost JSON object or array <br>from the response, discarding markdown fences<br>and  surrounding text. Automatically enabled<br>when  -ResponseFormat is set; use this switch<br>to force it for  plain-text calls expecting<br>JSON output. |
| `-MarkupBlocksTypeFilter` | String[] | ☐ | Will only output markup blocks of the <br>specified types |
| `-ChatMode` | String | ☐ | Enable chat mode |
| `-ChatOnce` | SwitchParameter | ☐ | Used internally, to only invoke chat mode<br>once  after the llm invocation |
| `-NoSessionCaching` | SwitchParameter | ☐ | Don't store session in session cache |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  AI preferences |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session <br>for AI preferences |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without affecting session |
| `-MaxToolcallBackLength` | Int32 | ☐ | Maximum length of tool callback output in<br>characters. Output exceeding this length will<br>be trimmed with a warning message. Default is<br>100000 characters. |

## Examples

### Invoke-LLMQuery -Query "What is 2+2?" -Model "qwen" -Temperature 0.7 Sends a simple mathematical query to the qwen model with specified temperature.

```powershell
Invoke-LLMQuery -Query "What is 2+2?" -Model "qwen" -Temperature 0.7
Sends a simple mathematical query to the qwen model with specified temperature.
```

### qllm "What is 2+2?" -Model "qwen" Uses the alias to send a query with default parameters.

```powershell
qllm "What is 2+2?" -Model "qwen"
Uses the alias to send a query with default parameters.
```

### Invoke-LLMQuery -Query "Analyze this image" -Attachments @("image.jpg") -Model "qwen" Sends a query with an image attachment for analysis.

```powershell
Invoke-LLMQuery -Query "Analyze this image" -Attachments @("image.jpg") -Model "qwen"
Sends a query with an image attachment for analysis.
```

### llm "Start a conversation" -ChatMode "textprompt" -Model "qwen" Starts an interactive text chat session with the specified model.

```powershell
llm "Start a conversation" -ChatMode "textprompt" -Model "qwen"
Starts an interactive text chat session with the specified model.
```

## Parameter Details

### `-Query <String>`

> Query text to send to the model

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `''` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Instructions <String>`

> System instructions for the model

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Attachments <String[]>`

> Array of file paths to attach

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ResponseFormat <String>`

> A JSON schema for the requested output format

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Temperature <Double>`

> Temperature for response randomness (0.0-1.0)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Functions <Collections.Hashtable[]>`

> Array of function definitions

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ExposedCmdLets <GenXdev.Helpers.ExposedCmdletDefinition[]>`

> Array of PowerShell command definitions to use  as tools

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoConfirmationToolFunctionNames <String[]>`

> Tool functions that don't require user  confirmation

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | `NoConfirmationFor` |
| **Accept wildcard characters?** | No |

<hr/>

### `-QuietToolChainInvocations`

> Suppresses Write-Host output during  intermediate tool chain invocations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ImageDetail <String>`

> Image detail level

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `'low'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LLMQueryType <String>`

> The type of LLM query

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `'SimpleIntelligence'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Model <String>`

> The model identifier or pattern to use for AI  operations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Gpu <Int32>`

> The `-Gpu` parameter.

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

### `-NoSupportForJsonSchema`

> Indicates that LLM has no support for JSON schemas

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-TimeoutSeconds <Int32>`

> The timeout in seconds for AI operations

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

### `-AudioTemperature <Double>`

> Temperature for audio generation randomness

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-TemperatureResponse <Double>`

> Temperature for response randomness (audio chat)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Language <String>`

> Language code or name for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-CpuThreads <Int32>`

> Number of CPU threads to use for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SuppressRegex <String>`

> Regular expression to suppress certain outputs in audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AudioContextSize <Int32>`

> Audio context size for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SilenceThreshold <Double>`

> Silence threshold for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LengthPenalty <Double>`

> Length penalty for audio chat responses

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-EntropyThreshold <Double>`

> Entropy threshold for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LogProbThreshold <Double>`

> Log probability threshold for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoSpeechThreshold <Double>`

> No speech threshold for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DontSpeak`

> Do not speak audio responses

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DontSpeakThoughts`

> Do not speak audio thoughts

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoVOX`

> Disable VOX (voice activation) for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-UseDesktopAudioCapture`

> Use desktop audio capture for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoContext`

> Disable context for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-WithBeamSearchSamplingStrategy`

> Use beam search sampling strategy for audio chat

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-OnlyResponses`

> Return only responses (no intermediate output)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-IncludeThoughts`

> Include model's thoughts in output

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DontAddThoughtsToHistory`

> Exclude thought processes from conversation  history

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ContinueLast`

> Continue from last conversation

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Speak`

> Enable text-to-speech for AI responses

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SpeakThoughts`

> Enable text-to-speech for AI thought responses

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-OutputMarkdownBlocksOnly`

> Will only output markup block responses

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-FilterForJsonOutput`

> Extracts the outermost JSON object or array  from the response, discarding markdown fences and  surrounding text. Automatically enabled when  -ResponseFormat is set; use this switch to force it for  plain-text calls expecting JSON output.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MarkupBlocksTypeFilter <String[]>`

> Will only output markup blocks of the  specified types

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@('json', 'powershell', 'C#',
            'python', 'javascript', 'typescript', 'html', 'css', 'yaml',
            'xml', 'bash')` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ChatMode <String>`

> Enable chat mode

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `chat` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ChatOnce`

> Used internally, to only invoke chat mode once  after the llm invocation

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoSessionCaching`

> Don't store session in session cache

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

> Clear alternative settings stored in session  for AI preferences

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

> Store settings only in persistent preferences  without affecting session

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxToolcallBackLength <Int32>`

> Maximum length of tool callback output in characters. Output exceeding this length will be trimmed with a warning message. Default is 100000 characters.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `100000` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Add-EmoticonsToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-EmoticonsToText.md)
- [ConvertFrom-CorporateSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertFrom-CorporateSpeak.md)
- [ConvertFrom-DiplomaticSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertFrom-DiplomaticSpeak.md)
- [ConvertTo-CorporateSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-CorporateSpeak.md)
- [ConvertTo-DiplomaticSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-DiplomaticSpeak.md)
- [Find-Image](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-Image.md)
- [Get-AIKnownFacesRootpath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AIKnownFacesRootpath.md)
- [Get-AIMetaLanguage](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AIMetaLanguage.md)
- [Get-Fallacy](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Fallacy.md)
- [Get-ScriptExecutionErrorFixPrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ScriptExecutionErrorFixPrompt.md)
- [Get-SimularMovieTitles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SimularMovieTitles.md)
- [Invoke-AIPowershellCommand](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-AIPowershellCommand.md)
- [Invoke-ImageFacesUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageFacesUpdate.md)
- [Invoke-ImageKeywordUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageKeywordUpdate.md)
- [Invoke-ImageMetadataUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageMetadataUpdate.md)
- [Invoke-ImageObjectsUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageObjectsUpdate.md)
- [Invoke-ImageScenesUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageScenesUpdate.md)
- [Invoke-LLMBooleanEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMBooleanEvaluation.md)
- [Invoke-LLMStringListEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMStringListEvaluation.md)
- [Invoke-LLMTextTransformation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMTextTransformation.md)
- [Invoke-QueryImageContent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-QueryImageContent.md)
- [Remove-ImageMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-ImageMetaData.md)
- [Save-FoundImageFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Save-FoundImageFaces.md)
- [Save-Transcriptions](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Save-Transcriptions.md)
- [Set-AIKnownFacesRootpath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AIKnownFacesRootpath.md)
- [Set-AIMetaLanguage](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AIMetaLanguage.md)
- [Show-FoundImagesInBrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-FoundImagesInBrowser.md)
- [Start-AudioTranscription](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-AudioTranscription.md)
- [Update-AllImageMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-AllImageMetaData.md)
