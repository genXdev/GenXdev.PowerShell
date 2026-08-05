# Get-CmdletMetaData

> **SubModule:** GenXdev.Coding.PowerShell.Modules | **Type:** Function | **Aliases:** —

## Synopsis

> Retrieves metadata for a specified GenXdev cmdlet, optionally translating help
text to another language.

## Description

```text
Extracts and returns comprehensive metadata about a GenXdev cmdlet
including its synopsis, description, parameters, examples, and other
help information. When a target language is specified via the -Language
parameter, the help text can be translated using AI-based translation
services. Custom translation instructions can be provided to fine-tune
the translation output.
Cmdlet discovery uses two independent paths:
- Script cmdlets (.ps1): the comment-based help block is parsed from
  the source file resolved via the function's ScriptBlock.File
  property. Source files live under
  Functions\<(Sub)ModuleName>\FileName.ps1, where the directory name
  identifies the sub-module (e.g., GenXdev.FileSystem\Find-Item.ps1
  -> sub-module GenXdev.FileSystem). Dot-sourcing in .psm1 files
  links these files:
  . "$PSScriptRoot\Functions\<(Sub)ModuleName>\<FileName>".
- Compiled cmdlets (.cs / .dll): metadata is extracted from the
  compiled assembly. C# source files follow the naming convention
  Verb-Noun.cs or Verb-Noun.Cmdlet.cs (the .Cmdlet suffix is used
  for partial classes that share a file with helper types). The
  [Cmdlet("Verb", "Noun")] attribute defines the cmdlet name, and
  the [System.ComponentModel.Description(@"...")] attribute
  provides comment-based help using the same .KEYWORD syntax as
  PowerShell comment-based help (.SYNOPSIS, .DESCRIPTION,
  .PARAMETER, .EXAMPLE, .OUTPUTS, .NOTES, .LINK). The  .EXAMPLE
  keyword uses a different format: code snippets go inside
  ```powershell fences, with the description below the fence
  (whereas in .ps1 comment-based help the code is unfenced and
  separated from the description by a blank line). The
  ImplementationType.Namespace (e.g., GenXdev.FileSystem)
  identifies the sub-module.
To see how a C# cmdlet receives its metadata through attributes only,
visit:
  https://github.com/genXdev/GenXdev.PowerShell/blob/main/Functions/GenXdev.FileSystem/Find-Item.Cmdlet.cs
When -Language is specified, help text is translated via
Get-TextTranslation using the persistent per-language JSON cache
under $env:LOCALAPPDATA\GenXdev.PowerShell\. Translation cache
files can be controlled and purged using the
GenXdev\Merge-TranslationCache cmdlet.
```

## Syntax

```powershell
Get-CmdletMetaData -Name <String> [[-Language] <String>] [[-TranslationInstructions] <String>] [[-Model] <String>] [[-ApiEndpoint] <String>] [[-ApiKey] <String>] [-NoSupportForJsonSchema] [-PromptForSettings] [-SkipTranslation] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Name` | String | ✅ | The name of the cmdlet to retrieve metadata<br>for |
| `-Language` | String | ☐ | BCP 47 language tag for translating help text<br>(e.g., nl-NL, de-DE). Omit to skip<br>translation. |
| `-TranslationInstructions` | String | ☐ | Custom instructions for the AI translation <br>model. Overrides the default<br>cmdlet-metadata-aware  translation<br>instructions. |
| `-Model` | String | ☐ | The model identifier or pattern to use for AI<br>translations |
| `-ApiEndpoint` | String | ☐ | The API endpoint URL for AI translations |
| `-ApiKey` | String | ☐ | The API key for authenticated AI translations |
| `-PromptForSettings` | SwitchParameter | ☐ | Launch interactive prompt to configure LLM<br>settings |
| `-NoSupportForJsonSchema` | SwitchParameter | ☐ | Indicates that LLM has no support for JSON<br>schemas |
| `-SkipTranslation` | SwitchParameter | ☐ | Skip LLM-based translation; keep help text in<br>the source language even when -Language is<br>specified. |

## Examples

### keyword uses a different format: code snippets go inside

keyword uses a different format: code snippets go inside
  ```powershell fences, with the description below the fence
(whereas in .ps1 comment-based help the code is unfenced and
separated from the description by a blank line). The
ImplementationType.Namespace (e.g., GenXdev.FileSystem)
identifies the sub-module.
To see how a C# cmdlet receives its metadata through attributes only,
visit:
https://github.com/genXdev/GenXdev.PowerShell/blob/main/Functions/GenXdev.FileSystem/Find-Item.Cmdlet.cs
When -Language is specified, help text is translated via
Get-TextTranslation using the persistent per-language JSON cache
under $env:LOCALAPPDATA\GenXdev.PowerShell\. Translation cache
files can be controlled and purged using the
GenXdev\Merge-TranslationCache cmdlet.

### Get-CmdletMetaData -Name "Find-Item" Retrieves metadata for the Find-Item cmdlet in the default language.

```powershell
Get-CmdletMetaData -Name "Find-Item"
Retrieves metadata for the Find-Item cmdlet in the default language.
```

### Get-CmdletMetaData -Name "Find-Item" -Language "nl-NL" Retrieves metadata for the Find-Item cmdlet with Dutch translations.

```powershell
Get-CmdletMetaData -Name "Find-Item" -Language "nl-NL"
Retrieves metadata for the Find-Item cmdlet with Dutch translations.
```

## Parameter Details

### `-Name <String>`

> The name of the cmdlet to retrieve metadata for

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Language <String>`

> BCP 47 language tag for translating help text  (e.g., nl-NL, de-DE). Omit to skip translation.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-TranslationInstructions <String>`

> Custom instructions for the AI translation  model. Overrides the default cmdlet-metadata-aware  translation instructions.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Model <String>`

> The model identifier or pattern to use for AI translations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 3 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ApiEndpoint <String>`

> The API endpoint URL for AI translations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 4 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ApiKey <String>`

> The API key for authenticated AI translations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 5 |
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

### `-SkipTranslation`

> Skip LLM-based translation; keep help text in  the source language even when -Language is specified.

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

- [Assert-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevCmdlet.md)
- [Assert-GenXdevCmdletTests](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevCmdletTests.md)
- [Assert-GenXdevTest](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevTest.md)
- [Assert-ModuleDefinition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-ModuleDefinition.md)
- [EnsureCopilotKeyboardShortCut](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureCopilotKeyboardShortCut.md)
- [EnsureDefaultGenXdevRefactors](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureDefaultGenXdevRefactors.md)
- [Get-GenXDevModule](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevModule.md)
- [Get-GenXDevModuleInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevModuleInfo.md)
- [Get-GenXDevNewModulesInOrderOfDependency](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevNewModulesInOrderOfDependency.md)
- [Get-ModuleCmdletMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ModuleCmdletMetaData.md)
- [Invoke-GenXdevPSFormatter](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevPSFormatter.md)
- [Invoke-GenXdevScriptAnalyzer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevScriptAnalyzer.md)
- [New-ModuleMarkdownHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleMarkdownHelp.md)
- [New-ModuleXmlHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleXmlHelp.md)
- [Search-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Search-GenXdevCmdlet.md)
- [Show-GenXdevCmdLetInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-GenXdevCmdLetInIde.md)
