# Invoke-WinMerge

> **SubModule:** GenXdev.AI | **Type:** Function | **Aliases:** —

## Synopsis

> Launches WinMerge to compare two files side by side.

## Description

Launches the WinMerge application to compare source and target files in a side by
side diff view. The function validates the existence of both input files and
ensures WinMerge is properly installed before launching. Provides optional
wait functionality to pause execution until WinMerge closes.


## Syntax

```powershell
Invoke-WinMerge -SourcecodeFilePath <String> -TargetcodeFilePath <String> [-AutoConsent] [-AutoConsentAllPackages] [-SessionOnly] [-Wait] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-SourcecodeFilePath` | String | ✅ | Path to the source file to compare |
| `-TargetcodeFilePath` | String | ✅ | Path to the target file to compare against |
| `-Wait` | SwitchParameter | ☐ | Wait for WinMerge to close before continuing |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to this installation<br>type and set persistent flag.. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installations. Useful for unattended or CI/CD<br>scenarios. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences |

## Examples

### Invoke-WinMerge -SourcecodeFilePath "C:\source\file1.txt" `                 -TargetcodeFilePath "C:\target\file2.txt" `                 -Wait

```powershell
Invoke-WinMerge -SourcecodeFilePath "C:\source\file1.txt" `
                -TargetcodeFilePath "C:\target\file2.txt" `
                -Wait
```

### merge "C:\source\file1.txt" "C:\target\file2.txt"

```powershell
merge "C:\source\file1.txt" "C:\target\file2.txt"
```

## Parameter Details

### `-SourcecodeFilePath <String>`

> Path to the source file to compare

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-TargetcodeFilePath <String>`

> Path to the target file to compare against

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Wait`

> Wait for WinMerge to close before continuing

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsent`

> Automatically consent to this installation type and set persistent flag..

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsentAllPackages`

> Automatically consent to third-party software  installations. Useful for unattended or CI/CD scenarios.

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

## Related Links

- [Get-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AILLMSettings.md)
- [Get-SpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SpeechToText.md)
- [Get-TextTranslation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TextTranslation.md)
- [Get-VectorSimilarity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-VectorSimilarity.md)
- [Invoke-AILLMSettingsPrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-AILLMSettingsPrompt.md)
- [Merge-TranslationCache](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Merge-TranslationCache.md)
- [New-GenXdevMCPToken](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-GenXdevMCPToken.md)
- [New-LLMAudioChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMAudioChat.md)
- [New-LLMTextChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMTextChat.md)
- [Receive-RealTimeSpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Receive-RealTimeSpeechToText.md)
- [Set-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AILLMSettings.md)
- [Set-GenXdevCommandNotFoundAction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevCommandNotFoundAction.md)
- [Start-GenXdevMCPServer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-GenXdevMCPServer.md)
- [Test-DeepLinkImageFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-DeepLinkImageFile.md)
