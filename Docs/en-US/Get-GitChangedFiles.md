# Get-GitChangedFiles

> **SubModule:** GenXdev.Coding.Git | **Type:** Cmdlet | **Aliases:** `gitchanged`

## Synopsis

> Get the list of changed files in a Git repository.

## Description

This function retrieves the list of files that have been changed in the current Git repository. It can be used to identify which files have been modified, added, or deleted. By default, returns relative paths with .\ prefix. Use -PassThru to get FileInfo objects.


## Syntax

```powershell
Get-GitChangedFiles [-PassThru] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-PassThru` | SwitchParameter | ☐ | Returns FileInfo objects (like Get-ChildItem)<br>instead of path strings. |

## Examples

### Examples 1

```powershell
Get-GitChangedFiles
```

Returns relative paths like .\Modules\GenXdev.AI\3.33.0\README.md

### Examples 2

```powershell
Get-GitChangedFiles -PassThru
```

Returns FileInfo objects for each changed file.

## Parameter Details

### `-PassThru`

> Returns FileInfo objects (like Get-ChildItem) instead of path strings.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Outputs


## Related Links

- [New-GitCommit](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-GitCommit.md)
- [PermanentlyDeleteGitFolders](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/PermanentlyDeleteGitFolders.md)
