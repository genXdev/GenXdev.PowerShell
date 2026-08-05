# Receive-RealTimeSpeechToText

> **SubModule:** GenXdev.AI | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Converts real-time audio input to text using Whisper AI model.

## Description

This cmdlet captures audio from microphone or desktop and transcribes it to text in real-time using the Whisper AI model. It supports various audio sources, silence detection, and multiple configuration options for speech recognition.


## Syntax

```powershell
Receive-RealTimeSpeechToText [-AudioContextSize <Int32?>] [-AudioDevice <String>] [-CpuThreads <Int32>] [-DontSuppressBlank] [-EntropyThreshold <Single?>] [-IgnoreSilence] [-LanguageIn <String>] [-LengthPenalty <Single?>] [-LogProbThreshold <Single?>] [-MaxDuration <TimeSpan?>] [-MaxDurationOfSilence <TimeSpan?>] [-MaxInitialTimestamp <TimeSpan?>] [-MaxLastTextTokens <Int32?>] [-MaxSegmentLength <Int32?>] [-MaxTokensPerSegment <Int32?>] [-ModelFileDirectoryPath <String>] [-ModelType <Whisper.net.Ggml.GgmlType>] [-NoContext] [-NoSpeechThreshold <Single?>] [-Offset <TimeSpan?>] [-Passthru] [-PrintSpecialTokens] [-Prompt <String>] [-SilenceThreshold <Int32?>] [-SingleSegmentOnly] [-SplitOnWord] [-SuppressRegex <String>] [-Temperature <Single?>] [-TemperatureInc <Single?>] [-TokenTimestampsSumThreshold <Single>] [-UseDesktopAndRecordingDevice] [-UseDesktopAudioCapture] [-WithBeamSearchSamplingStrategy] [-WithProgress] [-WithTokenTimestamps] [-WithTranslate] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ModelFileDirectoryPath` | String | ☐ | Path to the model file |
| `-UseDesktopAudioCapture` | SwitchParameter | ☐ | Whether to use desktop audio capture instead<br>of microphone |
| `-UseDesktopAndRecordingDevice` | SwitchParameter | ☐ | Whether to use both desktop audio capture and<br>recording device simultaneously |
| `-AudioDevice` | String | ☐ | Use both desktop and recording device |
| `-Passthru` | SwitchParameter | ☐ | Returns objects instead of strings |
| `-WithTokenTimestamps` | SwitchParameter | ☐ | Whether to include token timestamps |
| `-TokenTimestampsSumThreshold` | Single | ☐ | Sum threshold for token timestamps, defaults<br>to 0.5 |
| `-SplitOnWord` | SwitchParameter | ☐ | Whether to split on word boundaries |
| `-MaxTokensPerSegment` | Int32? | ☐ | Maximum number of tokens per segment |
| `-IgnoreSilence` | SwitchParameter | ☐ | Whether to ignore silence (will mess up<br>timestamps) |
| `-MaxDurationOfSilence` | TimeSpan? | ☐ | Maximum duration of silence before<br>automatically stopping recording |
| `-SilenceThreshold` | Int32? | ☐ | Silence detect threshold (0..32767 defaults<br>to 30) |
| `-LanguageIn` | String | ☐ | Sets the input language to detect, defaults<br>to 'en' |
| `-CpuThreads` | Int32 | ☐ | Sets the output language |
| `-Temperature` | Single? | ☐ | Temperature for speech detection |
| `-TemperatureInc` | Single? | ☐ | Temperature increment |
| `-WithTranslate` | SwitchParameter | ☐ | Whether to translate the output |
| `-Prompt` | String | ☐ | Prompt to use for the model |
| `-SuppressRegex` | String | ☐ | Regex to suppress tokens from the output |
| `-WithProgress` | SwitchParameter | ☐ | Whether to show progress |
| `-AudioContextSize` | Int32? | ☐ | Size of the audio context |
| `-DontSuppressBlank` | SwitchParameter | ☐ | Whether to NOT suppress blank lines |
| `-MaxDuration` | TimeSpan? | ☐ | Maximum duration of the audio |
| `-Offset` | TimeSpan? | ☐ | Offset for the audio |
| `-MaxLastTextTokens` | Int32? | ☐ | Maximum number of last text tokens |
| `-SingleSegmentOnly` | SwitchParameter | ☐ | Whether to use single segment only |
| `-PrintSpecialTokens` | SwitchParameter | ☐ | Whether to print special tokens |
| `-MaxSegmentLength` | Int32? | ☐ | Maximum segment length |
| `-MaxInitialTimestamp` | TimeSpan? | ☐ | Start timestamps at this moment |
| `-LengthPenalty` | Single? | ☐ | Length penalty |
| `-EntropyThreshold` | Single? | ☐ | Entropy threshold |
| `-LogProbThreshold` | Single? | ☐ | Log probability threshold |
| `-NoSpeechThreshold` | Single? | ☐ | No speech threshold |
| `-NoContext` | SwitchParameter | ☐ | Don't use context |
| `-WithBeamSearchSamplingStrategy` | SwitchParameter | ☐ | Use beam search sampling strategy |
| `-ModelType` | Whisper.net.Ggml.GgmlType | ☐ | Whisper model type to use, defaults to Small |

## Examples

### Examples 1

```powershell
Receive-RealTimeSpeechToText
```

Basic usage with microphone.

### Examples 2

```powershell
Receive-RealTimeSpeechToText -UseDesktopAudioCapture
```

Using desktop audio capture.

### Examples 3

```powershell
Receive-RealTimeSpeechToText -AudioDevice "Microphone*"
```

Using specific audio device.

### Examples 4

```powershell
Receive-RealTimeSpeechToText -MaxDurationOfSilence "00:00:05"
```

With silence detection.

## Parameter Details

### `-ModelFileDirectoryPath <String>`

> Path to the model file

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

> Whether to use desktop audio capture instead of microphone

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-UseDesktopAndRecordingDevice`

> Whether to use both desktop audio capture and recording device simultaneously

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AudioDevice <String>`

> Use both desktop and recording device

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
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

### `-IgnoreSilence`

> Whether to ignore silence (will mess up timestamps)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxDurationOfSilence <TimeSpan?>`

> Maximum duration of silence before automatically stopping recording

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SilenceThreshold <Int32?>`

> Silence detect threshold (0..32767 defaults to 30)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
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

### `-ModelType <Whisper.net.Ggml.GgmlType>`

> Whisper model type to use, defaults to Small

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `Tiny` |
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
- [Set-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AILLMSettings.md)
- [Set-GenXdevCommandNotFoundAction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevCommandNotFoundAction.md)
- [Start-GenXdevMCPServer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-GenXdevMCPServer.md)
- [Test-DeepLinkImageFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-DeepLinkImageFile.md)
