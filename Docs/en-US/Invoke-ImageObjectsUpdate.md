# Invoke-ImageObjectsUpdate

> **SubModule:** GenXdev.AI.Queries | **Type:** Function | **Aliases:** `imageobjectdetection`

## Synopsis

> Updates object detection metadata for image files in a specified directory.

## Description

This function processes images in a specified directory to detect objects using
artificial intelligence. It creates JSON metadata files containing detected
objects, their positions, confidence scores, and labels. The function supports
batch processing with configurable confidence thresholds and can optionally
skip existing metadata files or retry previously failed detections.


## Syntax

```powershell
Invoke-ImageObjectsUpdate [[-ImageDirectories] <String[]>] [-ClearSession] [-Language <String>] [-LLMQueryType <String>] [-Model <String>] [-OnlyNew] [-PreferencesDatabasePath <String>] [-Recurse] [-RetryFailed] [-SessionOnly] [-SkipSession] [-TimeoutSeconds <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ImageDirectories` | String[] | ☐ | The directory paths containing images to<br>process |
| `-Recurse` | SwitchParameter | ☐ | Process images in specified directory and all<br>subdirectories |
| `-OnlyNew` | SwitchParameter | ☐ | Only process images that don't already have<br>face  metadata files |
| `-RetryFailed` | SwitchParameter | ☐ | Will retry previously failed image keyword <br>updates |
| `-Language` | String | ☐ | The language for generated descriptions and <br>keywords |
| `-LLMQueryType` | String | ☐ | The type of LLM query |
| `-Model` | String | ☐ | The model identifier or pattern to use for AI<br>operations |
| `-TimeoutSeconds` | Int32 | ☐ | The timeout in seconds for AI operations |
| `-PreferencesDatabasePath` | String | ☐ | Database path for preference data files |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for AI  preferences |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without  affecting session |

## Examples

### Invoke-ImageObjectsUpdate -ImageDirectories @("C:\Photos", "D:\Pictures") -Recurse This example processes all images in C:\Photos and D:\Pictures and all subdirectories using default settings with 0.5 confidence threshold.

```powershell
Invoke-ImageObjectsUpdate -ImageDirectories @("C:\Photos", "D:\Pictures") -Recurse
This example processes all images in C:\Photos and D:\Pictures and all
subdirectories using default settings with 0.5 confidence threshold.
```

### Invoke-ImageObjectsUpdate @("C:\Photos", "C:\Archive") -RetryFailed -OnlyNew This example processes only new images and retries previously failed ones in multiple directories using positional parameter syntax.

```powershell
Invoke-ImageObjectsUpdate @("C:\Photos", "C:\Archive") -RetryFailed -OnlyNew
This example processes only new images and retries previously failed ones
in multiple directories using positional parameter syntax.
```

### Invoke-ImageObjectsUpdate -ImageDirectories "C:\Photos" -UseGPU `     -ConfidenceThreshold 0.7 This example uses GPU acceleration with higher confidence threshold of 0.7 for more accurate but fewer object detections.

```powershell
Invoke-ImageObjectsUpdate -ImageDirectories "C:\Photos" -UseGPU `
    -ConfidenceThreshold 0.7
This example uses GPU acceleration with higher confidence threshold of 0.7
for more accurate but fewer object detections.
```

## Parameter Details

### `-ImageDirectories <String[]>`

> The directory paths containing images to process

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `@('.\')` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Recurse`

> Process images in specified directory and all  subdirectories

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-OnlyNew`

> Only process images that don't already have face  metadata files

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-RetryFailed`

> Will retry previously failed image keyword  updates

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

> The language for generated descriptions and  keywords

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
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
- [Invoke-ImageScenesUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageScenesUpdate.md)
- [Invoke-LLMBooleanEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMBooleanEvaluation.md)
- [Invoke-LLMQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMQuery.md)
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
