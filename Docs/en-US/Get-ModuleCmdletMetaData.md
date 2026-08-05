# Get-ModuleCmdletMetaData

> **SubModule:** GenXdev.Coding.PowerShell.Modules | **Type:** Function | **Aliases:** —

## Synopsis

> Retrieves metadata for all cmdlets in a PowerShell module.

## Description

Retrieves full cmdlet metadata (synopsis, description, parameters,
examples, outputs, and aliases) for every cmdlet in the specified
module, adding SubModuleName and CmdletType properties to each result.
Sub-module assignment uses two independent paths:
- Script cmdlets (.ps1): source file matched against .psm1 dot-source
  directory mappings (Functions\<(Sub)ModuleName>\FileName.ps1). The
  dot-source pattern . "$PSScriptRoot\Functions\<Sub>\<File>" is
  parsed from each .psm1 to build the filename-to-sub-module map. A
  fallback scans Functions\*\ directly for modules without nested
  .psm1 files.
- Compiled cmdlets (.dll / .cs): namespace from
  ImplementationType.Namespace (e.g., GenXdev.FileSystem). C#
  source files are named Verb-Noun.cs or Verb-Noun.Cmdlet.cs
  (the .Cmdlet suffix denotes a partial class co-located with
  helper types). They use [Cmdlet("Verb", "Noun")] for
  registration and [System.ComponentModel.Description(@"...")]
  for comment-based help using the same .KEYWORD syntax as
  PowerShell (.SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE,
  etc.). The  .EXAMPLE keyword uses fenced ```powershell code
  blocks with the description below the fence (vs. unfenced
  code in .ps1 help).
  To see how a C# cmdlet receives its metadata through
  attributes only, visit:
    https://github.com/genXdev/GenXdev.PowerShell/blob/main/Functions/GenXdev.FileSystem/Find-Item.Cmdlet.cs


## Syntax

```powershell
Get-ModuleCmdletMetaData -ModuleName <String> [-ApiEndpoint <String>] [-ApiKey <String>] [-Language <String>] [-Model <String>] [-NoSupportForJsonSchema] [-PromptForSettings] [-SkipTranslation] [-TranslationInstructions <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ModuleName` | String | ✅ | The name of the PowerShell module to retrieve<br>cmdlet metadata for |
| `-Language` | String | ☐ | BCP 47 language tag for translation (e.g., <br>nl-NL, de-DE) |
| `-Model` | String | ☐ | The model identifier or pattern to use for AI<br>translations |
| `-ApiEndpoint` | String | ☐ | The API endpoint URL for AI translations |
| `-ApiKey` | String | ☐ | The API key for authenticated AI translations |
| `-PromptForSettings` | SwitchParameter | ☐ | Launch interactive prompt to configure LLM<br>settings |
| `-NoSupportForJsonSchema` | SwitchParameter | ☐ | Indicates that LLM has no support for JSON<br>schemas |
| `-TranslationInstructions` | String | ☐ | Custom AI translation instructions |
| `-SkipTranslation` | SwitchParameter | ☐ | Skip LLM-based translation |

## Examples

### Get-ModuleCmdletMetaData -ModuleName 'GenXdev' Returns metadata for all cmdlets in the GenXdev module.

```powershell
Get-ModuleCmdletMetaData -ModuleName 'GenXdev'
Returns metadata for all cmdlets in the GenXdev module.
```

### Get-ModuleCmdletMetaData -ModuleName 'GenXdev' -Language 'nl-NL' Returns Dutch-translated metadata for all GenXdev cmdlets.

```powershell
Get-ModuleCmdletMetaData -ModuleName 'GenXdev' -Language 'nl-NL'
Returns Dutch-translated metadata for all GenXdev cmdlets.
```

## Parameter Details

### `-ModuleName <String>`

> The name of the PowerShell module to retrieve  cmdlet metadata for

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

> BCP 47 language tag for translation (e.g.,  nl-NL, de-DE)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
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
| **Position?** | Named |
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
| **Position?** | Named |
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

### `-TranslationInstructions <String>`

> Custom AI translation instructions

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

> Skip LLM-based translation

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

- `Collections.Hashtable[]`

## Related Links

- [Assert-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevCmdlet.md)
- [Assert-GenXdevCmdletTests](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevCmdletTests.md)
- [Assert-GenXdevTest](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevTest.md)
- [Assert-ModuleDefinition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-ModuleDefinition.md)
- [EnsureCopilotKeyboardShortCut](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureCopilotKeyboardShortCut.md)
- [EnsureDefaultGenXdevRefactors](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureDefaultGenXdevRefactors.md)
- [Get-CmdletMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CmdletMetaData.md)
- [Get-GenXDevModule](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevModule.md)
- [Get-GenXDevModuleInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevModuleInfo.md)
- [Get-GenXDevNewModulesInOrderOfDependency](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevNewModulesInOrderOfDependency.md)
- [Invoke-GenXdevPSFormatter](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevPSFormatter.md)
- [Invoke-GenXdevScriptAnalyzer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevScriptAnalyzer.md)
- [New-ModuleMarkdownHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleMarkdownHelp.md)
- [New-ModuleXmlHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleXmlHelp.md)
- [Search-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Search-GenXdevCmdlet.md)
- [Show-GenXdevCmdLetInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-GenXdevCmdLetInIde.md)
