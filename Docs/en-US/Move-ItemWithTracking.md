# Move-ItemWithTracking

> **SubModule:** GenXdev.FileSystem | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Moves files and directories while preserving filesystem links and
references.

## Description

* Uses the Windows MoveFileEx API to move files and directories with link
  tracking enabled, ensuring filesystem references are maintained.
* If the source path is under Git control, it attempts to use git mv to
  track the rename in Git.
* Falls back to MoveFileEx if Git is not available or git mv fails.


## Syntax

```powershell
Move-ItemWithTracking -Path <String> -Destination <String> [-Force] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Path` | String | ✅ | Source path of file/directory to move |
| `-Destination` | String | ✅ | Destination path to move to |
| `-Force` | SwitchParameter | ☐ | Overwrite destination if it exists |

## Examples

### Examples 1

```powershell
Move-ItemWithTracking -Path "C:\temp\oldfile.txt" -Destination "D:\newfile.txt"
```

Moves a file while preserving filesystem links and Git tracking.

### Examples 2

```powershell
"C:\temp\olddir" | Move-ItemWithTracking -Destination "D:\newdir" -Force
```

Moves a directory, overwriting destination if it exists.

## Parameter Details

### `-Path <String>`

> Source path of file/directory to move

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `FullName` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Destination <String>`

> Destination path to move to

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Force`

> Overwrite destination if it exists

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Copy-FilesToDateFolder](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-FilesToDateFolder.md)
- [Expand-Path](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Expand-Path.md)
- [Find-DuplicateFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-DuplicateFiles.md)
- [Find-Item](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-Item.md)
- [Invoke-Fasti](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-Fasti.md)
- [Move-FilesToDateFolder](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Move-FilesToDateFolder.md)
- [Move-ToRecycleBin](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Move-ToRecycleBin.md)
- [ReadJsonWithRetry](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ReadJsonWithRetry.md)
- [Remove-AllItems](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-AllItems.md)
- [Remove-ItemWithFallback](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-ItemWithFallback.md)
- [Remove-OnReboot](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-OnReboot.md)
- [Rename-InProject](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Rename-InProject.md)
- [Set-FoundLocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-FoundLocation.md)
- [Set-LocationParent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent.md)
- [Set-LocationParent2](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent2.md)
- [Set-LocationParent3](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent3.md)
- [Set-LocationParent4](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent4.md)
- [Set-LocationParent5](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent5.md)
- [Start-RoboCopy](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-RoboCopy.md)
- [Write-FileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-FileAtomic.md)
- [Write-JsonFileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-JsonFileAtomic.md)
- [Write-TextFileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-TextFileAtomic.md)
