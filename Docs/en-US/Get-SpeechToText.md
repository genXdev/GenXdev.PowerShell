# Get-SpeechToText

> **SubModule:** GenXdev.AI | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Converts audio files to text using OpenAI's Whisper speech recognition model.

## Description

Processes audio files and converts speech to text using the Whisper.NET library, which implements OpenAI's Whisper automatic speech recognition (ASR) system. It supports multiple languages, translation capabilities, and various transcription quality settings.


## Syntax

```powershell
Get-SpeechToText -Input <Object> [-AudioContextSize <Int32?>] [-CpuThreads <Int32>] [-DontSuppressBlank] [-EntropyThreshold <Single?>] [-LanguageIn <String>] [-LengthPenalty <Single?>] [-LogProbThreshold <Single?>] [-MaxDuration <TimeSpan?>] [-MaxInitialTimestamp <TimeSpan?>] [-MaxLastTextTokens <Int32?>] [-MaxSegmentLength <Int32?>] [-MaxTokensPerSegment <Int32?>] [-ModelFileDirectoryPath <String>] [-ModelType <Whisper.net.Ggml.GgmlType>] [-NoContext] [-NoSpeechThreshold <Single?>] [-Offset <TimeSpan?>] [-Passthru] [-PrintSpecialTokens] [-Prompt <String>] [-SingleSegmentOnly] [-SplitOnWord] [-SuppressRegex <String>] [-Temperature <Single?>] [-TemperatureInc <Single?>] [-TokenTimestampsSumThreshold <Single>] [-WithBeamSearchSamplingStrategy] [-WithProgress] [-WithTokenTimestamps] [-WithTranslate] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ModelFileDirectoryPath` | String | ☐ | Path to the model file directory |
| `-Input` | Object | ✅ | Audio file path, FileInfo object, or any<br>audio format supported by Whisper. |
| `-LanguageIn` | String | ☐ | Sets the input language to detect, defaults<br>to 'en' |
| `-CpuThreads` | Int32 | ☐ | Sets the output language |
| `-Temperature` | Single? | ☐ | Temperature for speech detection |
| `-TemperatureInc` | Single? | ☐ | Temperature increment |
| `-NoSpeechThreshold` | Single? | ☐ | No speech threshold |
| `-Prompt` | String | ☐ | Prompt to use for the model |
| `-SuppressRegex` | String | ☐ | Regex to suppress tokens from the output |
| `-TokenTimestampsSumThreshold` | Single | ☐ | Sum threshold for token timestamps, defaults<br>to 0.5 |
| `-MaxTokensPerSegment` | Int32? | ☐ | Maximum number of tokens per segment |
| `-AudioContextSize` | Int32? | ☐ | Size of the audio context |
| `-MaxDuration` | TimeSpan? | ☐ | Maximum duration of the audio |
| `-Offset` | TimeSpan? | ☐ | Offset for the audio |
| `-MaxLastTextTokens` | Int32? | ☐ | Maximum number of last text tokens |
| `-MaxSegmentLength` | Int32? | ☐ | Maximum segment length |
| `-MaxInitialTimestamp` | TimeSpan? | ☐ | Start timestamps at this moment |
| `-LengthPenalty` | Single? | ☐ | Length penalty |
| `-EntropyThreshold` | Single? | ☐ | Entropy threshold |
| `-LogProbThreshold` | Single? | ☐ | Log probability threshold |
| `-ModelType` | Whisper.net.Ggml.GgmlType | ☐ | Whisper model type to use, defaults to<br>LargeV3Turbo |
| `-Passthru` | SwitchParameter | ☐ | Returns objects instead of strings |
| `-WithTokenTimestamps` | SwitchParameter | ☐ | Whether to include token timestamps |
| `-SplitOnWord` | SwitchParameter | ☐ | Whether to split on word boundaries |
| `-WithTranslate` | SwitchParameter | ☐ | Whether to translate the output |
| `-WithProgress` | SwitchParameter | ☐ | Whether to show progress |
| `-DontSuppressBlank` | SwitchParameter | ☐ | Whether to NOT suppress blank lines |
| `-SingleSegmentOnly` | SwitchParameter | ☐ | Whether to use single segment only |
| `-PrintSpecialTokens` | SwitchParameter | ☐ | Whether to print special tokens |
| `-NoContext` | SwitchParameter | ☐ | Don't use context |
| `-WithBeamSearchSamplingStrategy` | SwitchParameter | ☐ | Use beam search sampling strategy |

## Examples

### Examples 1

```powershell
Get-SpeechToText -Input "C:\audio\recording.wav"
```

Transcribes an audio file to text using default settings.

### Examples 2

```powershell
Get-ChildItem "C:\audio\*.wav" | Get-SpeechToText
```

Transcribes all WAV files in a directory.

### Examples 3

```powershell
Get-SpeechToText -Input "audio.mp3" -LanguageIn "es" -WithTranslate
```

Transcribes Spanish audio and translates it to English.

### Examples 4

```powershell
Get-SpeechToText -Input "recording.wav" -Passthru -WithTokenTimestamps
```

Returns SegmentData objects with precise timing information.

## Parameter Details

### `-ModelFileDirectoryPath <String>`

> Path to the model file directory

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Input <Object>`

> Audio file path, FileInfo object, or any audio format supported by Whisper.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue) |
| **Aliases** | `WaveFile` |
| **Accept wildcard characters?** | No |

<hr/>

### `-LanguageIn <String>`

> Sets the input language to detect, defaults to 'en'

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

> Sets the output language

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Temperature <Single?>`

> Temperature for speech detection

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-TemperatureInc <Single?>`

> Temperature increment

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoSpeechThreshold <Single?>`

> No speech threshold

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Prompt <String>`

> Prompt to use for the model

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

> Regex to suppress tokens from the output

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-TokenTimestampsSumThreshold <Single>`

> Sum threshold for token timestamps, defaults to 0.5

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxTokensPerSegment <Int32?>`

> Maximum number of tokens per segment

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AudioContextSize <Int32?>`

> Size of the audio context

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxDuration <TimeSpan?>`

> Maximum duration of the audio

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Offset <TimeSpan?>`

> Offset for the audio

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxLastTextTokens <Int32?>`

> Maximum number of last text tokens

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxSegmentLength <Int32?>`

> Maximum segment length

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxInitialTimestamp <TimeSpan?>`

> Start timestamps at this moment

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LengthPenalty <Single?>`

> Length penalty

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-EntropyThreshold <Single?>`

> Entropy threshold

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LogProbThreshold <Single?>`

> Log probability threshold

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ModelType <Whisper.net.Ggml.GgmlType>`

> Whisper model type to use, defaults to LargeV3Turbo

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `Tiny` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Passthru`

> Returns objects instead of strings

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-WithTokenTimestamps`

> Whether to include token timestamps

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SplitOnWord`

> Whether to split on word boundaries

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-WithTranslate`

> Whether to translate the output

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-WithProgress`

> Whether to show progress

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DontSuppressBlank`

> Whether to NOT suppress blank lines

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SingleSegmentOnly`

> Whether to use single segment only

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PrintSpecialTokens`

> Whether to print special tokens

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoContext`

> Don't use context

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-WithBeamSearchSamplingStrategy`

> Use beam search sampling strategy

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Outputs


## Related Links

- [Get-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AILLMSettings.md)
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
