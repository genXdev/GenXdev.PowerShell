# Expand-Path

> **SubModule:** GenXdev.FileSystem | **Type:** Function | **Aliases:** `ep`

## Synopsis

> Expands any given file reference to a full pathname.

## Description

Expands any given file reference to a full pathname, with respect to the user's
current directory. Can optionally assure that directories or files exist.


## Syntax

```powershell
Expand-Path -FilePath <String> [-CreateDirectory] [-CreateFile] [-DeleteExistingFile] [-DirectoryMustExist] [-FileMustExist] [-ForceDrive <Char>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-FilePath` | String | ✅ | Path to expand |
| `-CreateDirectory` | SwitchParameter | ☐ | Will create directory if it does not exist |
| `-CreateFile` | SwitchParameter | ☐ | Will create an empty file if it does not<br>exist |
| `-DeleteExistingFile` | SwitchParameter | ☐ | Will delete the file if it already exists |
| `-ForceDrive` | Char | ☐ | Will force the use of a specific drive |
| `-FileMustExist` | SwitchParameter | ☐ | Will throw if file does not exist |
| `-DirectoryMustExist` | SwitchParameter | ☐ | Will throw if directory does not exist |

## Examples

### Expand-Path -FilePath ".\myfile.txt" -CreateFile

```powershell
Expand-Path -FilePath ".\myfile.txt" -CreateFile
```

### ep ~\documents\test.txt -CreateFile

```powershell
ep ~\documents\test.txt -CreateFile
```

## Parameter Details

### `-FilePath <String>`

> Path to expand

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-CreateDirectory`

> Will create directory if it does not exist

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-CreateFile`

> Will create an empty file if it does not exist

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DeleteExistingFile`

> Will delete the file if it already exists

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ForceDrive <Char>`

> Will force the use of a specific drive

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `'*'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-FileMustExist`

> Will throw if file does not exist

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DirectoryMustExist`

> Will throw if directory does not exist

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

- [Copy-FilesToDateFolder](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-FilesToDateFolder.md)
- [Find-DuplicateFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-DuplicateFiles.md)
- [Find-Item](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-Item.md)
- [Invoke-Fasti](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-Fasti.md)
- [Move-FilesToDateFolder](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Move-FilesToDateFolder.md)
- [Move-ItemWithTracking](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Move-ItemWithTracking.md)
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
