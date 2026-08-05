# New-ModuleXmlHelp

> **SubModule:** GenXdev.Coding.PowerShell.Modules | **Type:** Function | **Aliases:** —

## Synopsis

> Generates MAML XML help files for any PowerShell module.

## Description

Generates MAML XML help files for any PowerShell module by extracting
metadata from all cmdlets in a module using Get-CmdletMetaData and
producing both ModuleName.dll-Help.xml (for C# cmdlets) and
ModuleName-help.xml (for .ps1 script cmdlets) in the output directory
under <ModuleRoot>\<Language>\.
Each help file includes all 9 MAML sections: command details,
description, syntax, parameters, input types, return values, alerts,
examples, and related links. Works with any module that has
discoverable cmdlets — GenXdev modules, community modules, or your
own custom modules.
Cmdlet sources are resolved using the same two-path strategy as
Get-CmdletMetaData:
- Script cmdlets (.ps1): source files under
  Functions\<(Sub)ModuleName>\FileName.ps1, dot-sourced by .psm1 files
  via . "$PSScriptRoot\Functions\<(Sub)ModuleName>\<FileName>".
- Compiled cmdlets (.cs / .dll): identified by their
  [Cmdlet("Verb", "Noun")] attribute and assigned to sub-modules via
  ImplementationType.Namespace (e.g., GenXdev.FileSystem). C# files
  are named Verb-Noun.cs or Verb-Noun.Cmdlet.cs (the .Cmdlet suffix
  is for partial classes sharing a source file with helper types).
  Help text lives in a [System.ComponentModel.Description(@"...")]
  attribute using the same .KEYWORD syntax as comment-based help
  (.SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE, .NOTES,
  .LINK). The  .EXAMPLE keyword uses fenced ```powershell blocks
  (description below the fence) vs. unfenced code in .ps1 help.
To see how a C# cmdlet receives its metadata through attributes only,
visit:
  https://github.com/genXdev/GenXdev.PowerShell/blob/main/Functions/GenXdev.FileSystem/Find-Item.Cmdlet.cs


## Syntax

```powershell
New-ModuleXmlHelp -ModuleName <String> [-ApiEndpoint <String>] [-ApiKey <String>] [-Force] [-Language <String>] [-LinkPrefix <String>] [-Model <String>] [-NoSupportForJsonSchema] [-PromptForSettings] [-SkipTranslation] [-TranslationInstructions <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ModuleName` | String | ✅ | The name of the PowerShell module to generate<br>help for |
| `-Language` | String | ☐ | BCP 47 language tag for the generated help <br>(e.g., en-US, nl-NL, de-DE) |
| `-Force` | SwitchParameter | ☐ | Overwrite existing help XML files without<br>prompting |
| `-SkipTranslation` | SwitchParameter | ☐ | Skip LLM translation; keep help in source<br>language |
| `-Model` | String | ☐ | The model identifier or pattern to use for AI<br>translations |
| `-ApiEndpoint` | String | ☐ | The API endpoint URL for AI translations |
| `-ApiKey` | String | ☐ | The API key for authenticated AI translations |
| `-PromptForSettings` | SwitchParameter | ☐ | Launch interactive prompt to configure LLM<br>settings |
| `-NoSupportForJsonSchema` | SwitchParameter | ☐ | Indicates that LLM has no support for JSON<br>schemas |
| `-LinkPrefix` | String | ☐ | URL prefix for the Online Version link in<br>each  cmdlet related links (e.g., <br>https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/) |
| `-TranslationInstructions` | String | ☐ | Custom instructions for the LLM translation <br>(passed to Get-TextTranslation) |

## Examples

### New-ModuleXmlHelp -ModuleName 'Microsoft.WinGet.Client' Generates English help XML for the WinGet client module in en-US\.

```powershell
New-ModuleXmlHelp -ModuleName 'Microsoft.WinGet.Client'
Generates English help XML for the WinGet client module in en-US\.
```

### New-ModuleXmlHelp -ModuleName 'GenXdev' -Language 'nl-NL' -Force  -Model 'deepseek-v4-pro' -ApiKey 'your-api-key' -ApiEndpoint 'https://api.deepseek.com/chat/completions' Generates Dutch help XML for GenXdev, overwriting existing files.

```powershell
New-ModuleXmlHelp -ModuleName 'GenXdev' -Language 'nl-NL' -Force  -Model 'deepseek-v4-pro' -ApiKey 'your-api-key' -ApiEndpoint 'https://api.deepseek.com/chat/completions'
Generates Dutch help XML for GenXdev, overwriting existing files.
```

### New-ModuleXmlHelp -ModuleName 'PSReadLine' -WhatIf Shows what files would be created without actually writing them.

```powershell
New-ModuleXmlHelp -ModuleName 'PSReadLine' -WhatIf
Shows what files would be created without actually writing them.
```

### New-ModuleXmlHelp -ModuleName 'GenXdev' -LinkPrefix `     'https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/' -Force Generates English help XML with per-cmdlet Online Version URLs pointing to GitHub Markdown docs. Get-Help <cmdlet> -Online opens the browser.

```powershell
New-ModuleXmlHelp -ModuleName 'GenXdev' -LinkPrefix `
    'https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/' -Force
Generates English help XML with per-cmdlet Online Version URLs pointing
to GitHub Markdown docs. Get-Help <cmdlet> -Online opens the browser.
```

## Parameter Details

### `-ModuleName <String>`

> The name of the PowerShell module to generate help for

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

> BCP 47 language tag for the generated help  (e.g., en-US, nl-NL, de-DE)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `'en-US'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Force`

> Overwrite existing help XML files without prompting

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

> Skip LLM translation; keep help in source language

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

### `-LinkPrefix <String>`

> URL prefix for the Online Version link in each  cmdlet related links (e.g.,  https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/)

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

> Custom instructions for the LLM translation  (passed to Get-TextTranslation)

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

- `IO.FileInfo[]`

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
- [Get-ModuleCmdletMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ModuleCmdletMetaData.md)
- [Invoke-GenXdevPSFormatter](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevPSFormatter.md)
- [Invoke-GenXdevScriptAnalyzer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevScriptAnalyzer.md)
- [New-ModuleMarkdownHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleMarkdownHelp.md)
- [Search-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Search-GenXdevCmdlet.md)
- [Show-GenXdevCmdLetInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-GenXdevCmdLetInIde.md)
