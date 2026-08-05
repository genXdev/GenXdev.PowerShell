# Invoke-GenXdevScriptAnalyzer

> **SubModule:** GenXdev.Coding.PowerShell.Modules | **Type:** Function | **Aliases:** —

## Synopsis

> Invokes PowerShell Script Analyzer to analyze PowerShell scripts for compliance
and best practices.

## Description

This function provides a wrapper around PSScriptAnalyzer to analyze PowerShell
scripts for compliance issues, best practices violations, and potential bugs.
It supports both file-based analysis and string-based script analysis with
customizable rules and settings.


## Syntax

```powershell
Invoke-GenXdevScriptAnalyzer -ScriptFilePath <String> [<CommonParameters>]

Invoke-GenXdevScriptAnalyzer -ScriptDefinition <String> [<CommonParameters>]

Invoke-GenXdevScriptAnalyzer [-EnableExit] [-Fix] [-Recurse] [-ReportSummary] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ScriptFilePath` | String | ✅ | Specifies the path to the script file. |
| `-ScriptDefinition` | String | ✅ | Specifies the script definition as a string. |
| `-EnableExit` | SwitchParameter | ☐ | Specifies that the tool should exit on error. |
| `-Fix` | SwitchParameter | ☐ | Enables automatic fixing of violations. |
| `-Recurse` | SwitchParameter | ☐ | Recursively process files. |
| `-ReportSummary` | SwitchParameter | ☐ | Reports a summary after analysis. |

## Examples

### Invoke-GenXdevScriptAnalyzer -Path "C:\Scripts\MyScript.ps1"

```powershell
Invoke-GenXdevScriptAnalyzer -Path "C:\Scripts\MyScript.ps1"
```

### Invoke-GenXdevScriptAnalyzer -ScriptDefinition "Get-Process | Where-Object {$_.Name -eq 'notepad'}"

```powershell
Invoke-GenXdevScriptAnalyzer -ScriptDefinition "Get-Process | Where-Object {$_.Name -eq 'notepad'}"
```

### Invoke-GenXdevScriptAnalyzer -Path "C:\Scripts\" -Recurse -Fix

```powershell
Invoke-GenXdevScriptAnalyzer -Path "C:\Scripts\" -Recurse -Fix
```

## Parameter Details

### `-ScriptFilePath <String>`

> Specifies the path to the script file.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `Path`, `FullName` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Path |

<hr/>

### `-ScriptDefinition <String>`

> Specifies the script definition as a string.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Script |

<hr/>

### `-EnableExit`

> Specifies that the tool should exit on error.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Fix`

> Enables automatic fixing of violations.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Recurse`

> Recursively process files.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ReportSummary`

> Reports a summary after analysis.

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
- [Get-CmdletMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CmdletMetaData.md)
- [Get-GenXDevModule](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevModule.md)
- [Get-GenXDevModuleInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevModuleInfo.md)
- [Get-GenXDevNewModulesInOrderOfDependency](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevNewModulesInOrderOfDependency.md)
- [Get-ModuleCmdletMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ModuleCmdletMetaData.md)
- [Invoke-GenXdevPSFormatter](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevPSFormatter.md)
- [New-ModuleMarkdownHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleMarkdownHelp.md)
- [New-ModuleXmlHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleXmlHelp.md)
- [Search-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Search-GenXdevCmdlet.md)
- [Show-GenXdevCmdLetInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-GenXdevCmdLetInIde.md)
