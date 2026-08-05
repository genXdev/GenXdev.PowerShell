# GenXdev.AI

## Overview

GenXdev.AI manages multi-provider LLM settings, powers interactive text and
audio chat sessions, handles AI-powered text translation with persistent
caching, exposes an MCP (Model Context Protocol) server so external AI
editors can invoke GenXdev cmdlets as tools, and optionally routes unknown
shell commands to AI for suggestions.

## Features

* Large Language Model (LLM) API helpers
    * Perform AI operations through OpenAI-compatible chat
      completion endpoints with `Invoke-LLMQuery` -> `llm`
    * Expose PowerShell cmdlets as tool functions to LLM models
      with user-controlled execution
    * Interactive text chat sessions with `New-LLMTextChat` ->
      `llmchat`
    * AI-powered command suggestions with
      `Invoke-AIPowershellCommand` -> `hint`
    * Secure execution model with mandatory user confirmation for
      system-modifying operations

* Audio and Speech Processing
    * Transcribe audio/video files using `Whisper AI` model with
      `Start-AudioTranscription` -> `transcribefile`
    * Interactive audio chat sessions with `New-LLMAudioChat` ->
      `llmaudiochat`
    * Real-time audio transcription with `Start-AudioTranscription`
      -> `transcribe`
    * Generate subtitle files for media content using `Save-Transcriptions`
    * Record and process spoken audio with default input devices

* Text Processing and Enhancement
    * Add contextual emoticons with:
      `Add-EmoticonsToText` -> `emojify`
    * Translate text between languages with:
      `Get-TextTranslation` -> `translate`
    * AI-powered text transformation with:
      `Invoke-LLMTextTransformation` -> `spellcheck`
    * Extract string lists and evaluate statements with:
        * `Invoke-LLMStringListEvaluation` -> `getlist`
        * `Invoke-LLMBooleanEvaluation` -> `equalstrue`

### Additional Resources

- [DeepStack Face Recognition Functions](README-GenXdev.AI.DeepStack.md)

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Set-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AILLMSettings.md) | `llmsettings` | Configure LLM providers interactively or by parameter |
| [Get-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AILLMSettings.md) | — | View current LLM provider configuration |
| [New-LLMTextChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMTextChat.md) | `llmchat` | Start an interactive AI text chat session |
| [New-LLMAudioChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMAudioChat.md) | `llmaudiochat` | Start an interactive AI audio chat session |
| [Get-TextTranslation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TextTranslation.md) | `translate` | Translate text between languages with caching |
| [Start-GenXdevMCPServer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-GenXdevMCPServer.md) | — | Expose GenXdev cmdlets as MCP tools for AI editors |
| [Set-GenXdevCommandNotFoundAction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevCommandNotFoundAction.md) | — | Route unknown commands to AI for suggestions |
| [Invoke-WinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WinMerge.md) | — | Launch WinMerge to compare files side by side |

## How It All Comes Together

`Set-AILLMSettings` (`llmsettings`) configures LLM providers per query type
(text, images, audio, video), each with its own endpoint, API key, and model.
Other AI cmdlets throughout GenXdev read this configuration.

`New-LLMTextChat` (`llmchat`) and `New-LLMAudioChat` (`llmaudiochat`) start
interactive chat sessions that use the configured LLM settings.
`Start-GenXdevMCPServer` exposes GenXdev cmdlets as MCP tools for external
AI editors.

`Get-TextTranslation` (`translate`) translates text between languages and
caches results on disk via `Merge-TranslationCache`, avoiding repeated API
calls for the same text. `Invoke-WinMerge` launches WinMerge to compare two
files side by side.

`Set-GenXdevCommandNotFoundAction` can optionally route unrecognized shell
commands to AI for suggestions instead of showing the default error.

## See Also

- [GenXdev.AI.Queries](README-GenXdev.AI.Queries.md) — LLM queries, image metadata, transcription
- [GenXdev.AI.DeepStack](README-GenXdev.AI.DeepStack.md) — Face recognition via DeepStack
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevai)
