# GenXdev.Helpers

## Overview

GenXdev.Helpers provides general helpers that don't fit any of the other
categories. Mockable Spectre.Console terminal UI integration, LLM
tool-call execution, JSON Schema example generation, NuGet assembly loading,
file output formatting with hyperlinks, module import utilities, and user
consent management.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Invoke-SpectrePrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SpectrePrompt.md) | — | Display a Spectre.Console selection or input prompt |
| [Invoke-SpectreAsk](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SpectreAsk.md) | — | Prompt for text input via Spectre.Console |
| [Invoke-SpectreConfirm](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SpectreConfirm.md) | — | Display a yes/no confirmation dialog |
| [Write-SpectreMarkupLine](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-SpectreMarkupLine.md) | — | Write Spectre.Console markup-formatted output |
| [ConvertTo-LLMOpenAIApiFunctionDefinition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-LLMOpenAIApiFunctionDefinition.md) | — | Convert a PowerShell function to an OpenAI tool definition |
| [Invoke-CommandFromToolCall](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-CommandFromToolCall.md) | — | Execute a validated LLM tool call as a PowerShell command |
| [Get-LLMJsonOutput](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-LLMJsonOutput.md) | — | Extract valid JSON from LLM response text |
| [Get-JsonExampleFromSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-JsonExampleFromSchema.md) | — | Generate example JSON from a JSON Schema |
| [ResolveInputObjectFileNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ResolveInputObjectFileNames.md) | — | Expand pipeline input into resolved file/directory paths |
| [Import-GenXdevModules](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-GenXdevModules.md) | `reloadgenxdev` | Import all GenXdev modules into the global scope |
| [Invoke-OnEachGenXdevModule](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-OnEachGenXdevModule.md) | `foreach-genxdev-module-do` | Run a script block against every GenXdev module |
| [EnsureNuGetAssembly](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureNuGetAssembly.md) | — | Download and load .NET assemblies from NuGet |
| [EnsureGenXdev](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureGenXdev.md) | — | Ensure all GenXdev modules are loaded |
| [Confirm-InstallationConsent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Confirm-InstallationConsent.md) | — | Prompt for and persist third-party installation consent |
| [Show-Verb](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-Verb.md) | `showverbs` | Display all approved PowerShell verbs |
| [WriteFileOutput](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/WriteFileOutput.md) | — | Output file paths as clickable terminal hyperlinks |

## How It All Comes Together

The Spectre.Console cmdlets (`Invoke-SpectrePrompt`, `Invoke-SpectreAsk`,
`Invoke-SpectreConfirm`, `Write-SpectreMarkupLine`, `Write-SpectreLine`)
provide terminal UI prompts and markup-formatted output.

`ConvertTo-LLMOpenAIApiFunctionDefinition` converts a PowerShell function
into an OpenAI-compatible tool definition. `Invoke-CommandFromToolCall`
executes a validated LLM tool call as a PowerShell command.
`Get-LLMJsonOutput` extracts valid JSON from LLM response text that may
contain markdown fences or other non-JSON content.

`ResolveInputObjectFileNames` expands pipeline input into resolved file and
directory paths. `WriteFileOutput` outputs file paths as clickable terminal
hyperlinks.

`Import-GenXdevModules` (`reloadgenxdev`) imports all GenXdev modules.
`Invoke-OnEachGenXdevModule` (`foreach-genxdev-module-do`) runs a script
block against each GenXdev module. `EnsureGenXdev` ensures all GenXdev
modules are loaded. `EnsureNuGetAssembly` downloads and loads .NET
assemblies from NuGet packages.

`Get-JsonExampleFromSchema` generates an example JSON string from a JSON
Schema definition. `Get-AIDefaultLLMSettings` returns available default
LLM settings. `Get-PowerShellRoot` returns the PowerShell workspace root
path. `Show-Verb` (`showverbs`) lists approved PowerShell verbs.
`Confirm-InstallationConsent` prompts for and persists third-party
installation consent. `Assert-RefactorFile` executes a refactoring
operation on a source file. `Approve-NewTextFileContent` provides
interactive file content comparison and approval using WinMerge.
`Test-RefactorLLMSelection` evaluates source files for refactoring
eligibility using LLM analysis. `GenerateMasonryLayoutHtml` generates
a responsive masonry layout HTML gallery from image data.

## See Also

- [GenXdev.AI](README-GenXdev.AI.md) — LLM chat (uses tool-call infrastructure)
- [GenXdev.FileSystem](README-GenXdev.FileSystem.md) — File resolution
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevhelpers)
