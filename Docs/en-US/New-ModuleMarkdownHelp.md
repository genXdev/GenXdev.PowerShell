# New-ModuleMarkdownHelp

> **SubModule:** GenXdev.Coding.PowerShell.Modules | **Type:** Function | **Aliases:** —

## Synopsis

> Generates rich Markdown help files for any PowerShell module.

## Description

Generates a comprehensive Markdown help site for any PowerShell module:
one .md file per cmdlet with all metadata sections, plus a README.md
index with per-sub-module tables linking to each cmdlet file.
Sub-module discovery uses two independent paths:
- Script cmdlets (.ps1): source file path is matched against .psm1
  dot-source directory mappings. The convention is:
  . "$PSScriptRoot\Functions\<(Sub)ModuleName>\<FileName>.ps1"
  where the sub-folder name becomes the (sub-)module name (e.g.,
  Functions\GenXdev.FileSystem -> GenXdev.FileSystem). For modules
  without nested .psm1 files, the Functions\*\ directory structure
  is scanned directly.
- Compiled cmdlets (.cs / .dll): the namespace from
  ImplementationType.Namespace (e.g., GenXdev.FileSystem) identifies
  the sub-module. C# files are named Verb-Noun.cs or
  Verb-Noun.Cmdlet.cs (the .Cmdlet suffix marks a partial class).
  Help text lives in a [System.ComponentModel.Description(@"...")]
  attribute using the same .KEYWORD syntax as PowerShell
  comment-based help (.SYNOPSIS, .DESCRIPTION, .PARAMETER,
   .EXAMPLE, .NOTES, .LINK). The .EXAMPLE keyword uses fenced
  triple-backquoted powershell blocks in C# vs. unfenced code in .ps1 help.
To see how a C# cmdlet receives its metadata through attributes only,
visit:
  https://github.com/genXdev/GenXdev.PowerShell/blob/main/Functions/GenXdev.FileSystem/Find-Item.Cmdlet.cs
Output is written to <ModuleRoot>\Docs\<Language>\. Each cmdlet .md
includes Synopsis, Description, Syntax, a compact Parameters table,
Examples, and per-parameter detail sections with property tables. A
README.md index groups cmdlets by sub-module.


## Syntax

```powershell
New-ModuleMarkdownHelp -ModuleName <String> [-ApiEndpoint <String>] [-ApiKey <String>] [-Force] [-Language <String>] [-LinkPrefix <String>] [-Model <String>] [-NoLicense] [-NoSupportForJsonSchema] [-OutputPath <String>] [-PromptForSettings] [-SkipTranslation] [-TranslationInstructions <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ModuleName` | String | ✅ | The name of the PowerShell module to generate<br>help for |
| `-OutputPath` | String | ☐ | Custom output directory for .md files. <br>Defaults to <moduleRoot>\Docs\<language>. |
| `-Language` | String | ☐ | BCP 47 language tag for the generated help <br>(e.g., en-US, nl-NL, de-DE) |
| `-Force` | SwitchParameter | ☐ | Overwrite existing .md files without<br>prompting |
| `-SkipTranslation` | SwitchParameter | ☐ | Skip LLM translation; keep help in source <br>language |
| `-Model` | String | ☐ | The model identifier or pattern to use for AI<br>translations |
| `-ApiEndpoint` | String | ☐ | The API endpoint URL for AI translations |
| `-ApiKey` | String | ☐ | The API key for authenticated AI translations |
| `-PromptForSettings` | SwitchParameter | ☐ | Launch interactive prompt to configure LLM<br>settings |
| `-NoSupportForJsonSchema` | SwitchParameter | ☐ | Indicates that LLM has no support for JSON<br>schemas |
| `-LinkPrefix` | String | ☐ | URL prefix for README index links (e.g., <br>https://github.com/<githubuser>/<reponame>/blob/main/Docs/en-US/) |
| `-TranslationInstructions` | String | ☐ | Custom AI translation instructions |
| `-NoLicense` | SwitchParameter | ☐ | Will exclude license info from cmdlet help<br>markdown |

## Examples

### New-ModuleMarkdownHelp -ModuleName 'Microsoft.WinGet.Client' -SkipTranslation Generates Docs\ folder with one .md per WinGet cmdlet + README.md index.

```powershell
New-ModuleMarkdownHelp -ModuleName 'Microsoft.WinGet.Client' -SkipTranslation
Generates Docs\ folder with one .md per WinGet cmdlet + README.md index.
```

### New-ModuleMarkdownHelp -ModuleName 'GenXdev' -Language 'nl-NL' -Force -Model 'deepseek-v4-pro' -ApiKey 'your-api-key' -ApiEndpoint 'https://api.deepseek.com/chat/completions' Generates Dutch-translated markdown help, overwriting existing files.

```powershell
New-ModuleMarkdownHelp -ModuleName 'GenXdev' -Language 'nl-NL' -Force -Model 'deepseek-v4-pro' -ApiKey 'your-api-key' -ApiEndpoint 'https://api.deepseek.com/chat/completions'
Generates Dutch-translated markdown help, overwriting existing files.
```

### New-ModuleMarkdownHelp -ModuleName 'GenXdev' -LinkPrefix `     'https://github.com/genXdev/GenXdev.PowerShell/Docs/' -SkipTranslation Generates help with absolute GitHub links in the README index.

```powershell
New-ModuleMarkdownHelp -ModuleName 'GenXdev' -LinkPrefix `
    'https://github.com/genXdev/GenXdev.PowerShell/Docs/' -SkipTranslation
Generates help with absolute GitHub links in the README index.
```

## Parameter Details

### `-ModuleName <String>`

> The name of the PowerShell module to generate  help for

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-OutputPath <String>`

> Custom output directory for .md files.  Defaults to <moduleRoot>\Docs\<language>.

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

> Overwrite existing .md files without prompting

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

> Skip LLM translation; keep help in source  language

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

> URL prefix for README index links (e.g.,  https://github.com/<githubuser>/<reponame>/blob/main/Docs/en-US/)

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

### `-NoLicense`

> Will exclude license info from cmdlet help markdown

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

- `String[]`

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
- [New-ModuleXmlHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleXmlHelp.md)
- [Search-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Search-GenXdevCmdlet.md)
- [Show-GenXdevCmdLetInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-GenXdevCmdLetInIde.md)
