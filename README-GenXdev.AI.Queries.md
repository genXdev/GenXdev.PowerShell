# GenXdev.AI.Queries

## Overview

GenXdev.AI.Queries wraps LLM chat completion APIs for raw queries and
structured outputs (boolean, list, transformation), powers AI-driven
PowerShell command generation, and provides the image metadata pipeline —
face detection, object recognition, scene classification, keyword
generation, EXIF updates, and audio/video transcription via Whisper.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Invoke-LLMQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMQuery.md) | `llm`, `qllm` | Send queries to any configured LLM provider |
| [Invoke-AIPowershellCommand](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-AIPowershellCommand.md) | `hint` | Generate and execute PowerShell commands from natural language |
| [Invoke-LLMBooleanEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMBooleanEvaluation.md) | `equalstrue` | Ask the AI: is this statement true or false? |
| [Invoke-LLMStringListEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMStringListEvaluation.md) | `getlist` | Extract a structured list of strings from text |
| [Invoke-LLMTextTransformation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMTextTransformation.md) | `spellcheck` | Rewrite, spellcheck, or transform text via AI |
| [Add-EmoticonsToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-EmoticonsToText.md) | `emojify` | Add contextually appropriate emoticons to text |
| [ConvertTo-CorporateSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-CorporateSpeak.md) | `corporatize` | Make blunt text polite and professional |
| [ConvertFrom-CorporateSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertFrom-CorporateSpeak.md) | `uncorporatize` | Make corporate-speak direct and clear |
| [Get-Fallacy](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Fallacy.md) | `dispicetext` | Identify logical fallacies in text |
| [Find-Image](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-Image.md) | `li`, `findimages` | Search images by metadata, objects, faces, scenes |
| [Start-AudioTranscription](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-AudioTranscription.md) | `transcribe`, `transcribefile` | Transcribe audio/video to text via Whisper |
| [Save-Transcriptions](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Save-Transcriptions.md) | — | Generate subtitle files from audio/video |
| [Invoke-ImageKeywordUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageKeywordUpdate.md) | `imagekeywordgeneration` | Generate AI descriptions and keywords for images |
| [Invoke-ImageFacesUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageFacesUpdate.md) | `imagepeopledetection` | Detect and register faces in images |
| [Invoke-ImageObjectsUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageObjectsUpdate.md) | `imageobjectdetection` | Detect objects in images |
| [Invoke-ImageScenesUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageScenesUpdate.md) | `imagescenedetection` | Classify scenes in images |
| [Update-AllImageMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-AllImageMetaData.md) | `updateallimages` | Batch-run all image metadata updates |
| [Show-FoundImagesInBrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-FoundImagesInBrowser.md) | `showfoundimages` | Display image search results in a masonry gallery |

## How It All Comes Together

`Invoke-LLMQuery` (`llm`) sends prompts to the LLM provider configured via
`Set-AILLMSettings` in GenXdev.AI. The other text cmdlets (`spellcheck`,
`emojify`, `corporatize`, `uncorporatize`, `dispicetext`, `equalstrue`,
`getlist`) are higher-level wrappers that call the LLM for specific use
cases: transforming text, extracting lists, evaluating boolean statements,
identifying fallacies, and adjusting tone.

`Invoke-AIPowershellCommand` (`hint`) generates PowerShell commands from
natural-language descriptions using the LLM and can optionally execute them.

The image cmdlets (`Invoke-ImageFacesUpdate`, `Invoke-ImageObjectsUpdate`,
`Invoke-ImageScenesUpdate`, `Invoke-ImageKeywordUpdate`) process image
directories, generating metadata that `Find-Image` can later search with
filters like `-Objects "person, dog"` or `-SceneType "kitchen"`.
`Update-AllImageMetaData` runs all four in sequence. Results can be
displayed in a browser gallery via `Show-FoundImagesInBrowser`.

`Start-AudioTranscription` (`transcribe`) converts audio and video files
to text using Whisper. `Save-Transcriptions` generates subtitle files from
the output.

## See Also

- [GenXdev.AI](README-GenXdev.AI.md) — LLM provider configuration and chat sessions
- [GenXdev.AI.DeepStack](README-GenXdev.AI.DeepStack.md) — Face recognition backend
- [GenXdev.Media](README-GenXdev.Media.md) — Media playback and VLC control
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevaiqueries)
