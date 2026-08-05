# Invoke-GenXdevPSFormatter

> **SubModule:** GenXdev.Coding.PowerShell.Modules | **Type:** Function | **Aliases:** —

## Synopsis

> Formats PowerShell script files using PSScriptAnalyzer formatting rules.

## Description

This function applies PowerShell formatting rules to script files using
PSScriptAnalyzer's Invoke-Formatter cmdlet. It can process individual files or
recursively format multiple files in directories. The function uses customizable
formatting settings and provides detailed logging of the formatting process.


## Syntax

```powershell
Invoke-GenXdevPSFormatter -Path <String> [-Range <Int32[]>] [-Recurse] [-Settings <Object>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Path` | String | ✅ | Specifies the path to the script file to<br>format. |
| `-Settings` | Object | ☐ | A settings hashtable or a path to a<br>PowerShell data  file (.psd1) that contains<br>the formatting settings. |
| `-Range` | Int32[] | ☐ | The range within which formatting should take<br>place  as an array of four integers: starting<br>line number, starting  column number, ending<br>line number, ending column number. |
| `-Recurse` | SwitchParameter | ☐ | Recursively process files in subdirectories. |

## Examples

### Invoke-GenXdevPSFormatter -Path "C:\Scripts\MyScript.ps1"

```powershell
Invoke-GenXdevPSFormatter -Path "C:\Scripts\MyScript.ps1"
```

### Invoke-GenXdevPSFormatter -Path "C:\Scripts" -Recurse

```powershell
Invoke-GenXdevPSFormatter -Path "C:\Scripts" -Recurse
```

### "MyScript.ps1" | Invoke-GenXdevPSFormatter -Settings @{IncludeRules=@('PSUseCorrectCasing')}

```powershell
"MyScript.ps1" | Invoke-GenXdevPSFormatter -Settings @{IncludeRules=@('PSUseCorrectCasing')}
```

## Parameter Details

### `-Path <String>`

> Specifies the path to the script file to format.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `Name`, `FullName`, `ImagePath`, `FileName`, `ScriptFileName` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Settings <Object>`

> A settings hashtable or a path to a PowerShell data  file (.psd1) that contains the formatting settings.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Range <Int32[]>`

> The range within which formatting should take place  as an array of four integers: starting line number, starting  column number, ending line number, ending column number.

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

> Recursively process files in subdirectories.

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
- [Invoke-GenXdevScriptAnalyzer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevScriptAnalyzer.md)
- [New-ModuleMarkdownHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleMarkdownHelp.md)
- [New-ModuleXmlHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleXmlHelp.md)
- [Search-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Search-GenXdevCmdlet.md)
- [Show-GenXdevCmdLetInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-GenXdevCmdLetInIde.md)
