# PermanentlyDeleteGitFolders

> **SubModule:** GenXdev.Coding.Git | **Type:** Function | **Aliases:** —

## Synopsis

> Permanently deletes specified folders from all branches in a Git repository.

## Description

Cleans a Git repository by removing specified folders from the entire commit
history across all branches. This is done by cloning the repository, using
git filter-branch to remove the folders, and force pushing the changes back.
This operation is destructive and permanently rewrites Git history.


## Syntax

```powershell
PermanentlyDeleteGitFolders -RepoUri <String> -Folders <String[]> [-tempPath <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-RepoUri` | String | ✅ | The URI of the Git repository to clean |
| `-Folders` | String[] | ✅ | Array of folder paths to permanently remove |
| `-tempPath` | String | ☐ | The `-tempPath` parameter. |

## Examples

### PermanentlyDeleteGitFolders `     -RepoUri "https://github.com/user/repo.git" `     -Folders "bin", "obj"

```powershell
PermanentlyDeleteGitFolders `
    -RepoUri "https://github.com/user/repo.git" `
    -Folders "bin", "obj"
```

## Parameter Details

### `-RepoUri <String>`

> The URI of the Git repository to clean

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Folders <String[]>`

> Array of folder paths to permanently remove

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-tempPath <String>`

> The `-tempPath` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `"~\convert.tmp\"` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Outputs

- `String[]`

## Related Links

- [Get-GitChangedFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GitChangedFiles.md)
- [New-GitCommit](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-GitCommit.md)
