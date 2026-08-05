# Set-FoundLocation

> **SubModule:** GenXdev.FileSystem | **Type:** Function | **Aliases:** `lcd`

## Synopsis

> Finds the first matching file or folder and sets the location to it.

## Description

This cmdlet will help you change directories quickly by using search phrases
that will find the first matching folder or file (optional) and changes
directory to it. Supports advanced filtering by content, file attributes,
size, modification dates, and many other criteria.


## Syntax

```powershell
Set-FoundLocation -Name <String> [-AllDrives] [-AttributesToSkip <IO.FileAttributes>] [-CaseNameMatching <IO.MatchCasing>] [-Category <String[]>] [-DirectoriesAndFiles] [-DriveLetter <Char[]>] [-ExactMatch] [-Exclude <String[]>] [-File] [-FollowSymlinkAndJunctions] [-IncludeAlternateFileStreams] [-IncludeNonTextFileMatching] [-IncludeOpticalDiskDrives] [-MaxDegreeOfParallelism <Int32>] [-MaxFileSize <Int64>] [-MaxRecursionDepth <Int32>] [-MinFileSize <Int64>] [-ModifiedAfter <DateTime>] [-ModifiedBefore <DateTime>] [-NoRecurse] [-Push] [-Root <String[]>] [-SearchADSContent] [-SearchDrives <String[]>] [-TimeoutSeconds <Int32>] [<CommonParameters>]

Set-FoundLocation -InputObject <Object> [<CommonParameters>]

Set-FoundLocation [[-Content] <String[]>] [-CaseSensitive] [-Culture <String>] [-Encoding <String>] [-NotMatch] [-SimpleMatch] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Name` | String | ✅ | File name or pattern to search for. 🌐<br>wildcards |
| `-InputObject` | Object | ✅ | File name or pattern to search for from<br>pipeline input.  Default is '*' 🌐 wildcards |
| `-Content` | String[] | ☐ | Regular expression pattern to search within<br>file contents 🌐 wildcards |
| `-Category` | String[] | ☐ | Only output files belonging to selected<br>categories |
| `-MaxDegreeOfParallelism` | Int32 | ☐ | Maximum degree of parallelism for directory<br>tasks |
| `-TimeoutSeconds` | Int32 | ☐ | Optional: cancellation timeout in seconds |
| `-AllDrives` | SwitchParameter | ☐ | Search across all available drives |
| `-File` | SwitchParameter | ☐ | Search for filenames only and change to<br>folder of first  found file |
| `-DirectoriesAndFiles` | SwitchParameter | ☐ | Include filename matching and change to<br>folder of first  found file |
| `-IncludeAlternateFileStreams` | SwitchParameter | ☐ | Include alternate data streams in search<br>results |
| `-NoRecurse` | SwitchParameter | ☐ | Do not recurse into subdirectories |
| `-FollowSymlinkAndJunctions` | SwitchParameter | ☐ | Follow symlinks and junctions during<br>directory traversal |
| `-IncludeOpticalDiskDrives` | SwitchParameter | ☐ | Include optical disk drives |
| `-SearchDrives` | String[] | ☐ | Optional: search specific drives |
| `-DriveLetter` | Char[] | ☐ | Optional: search specific drives |
| `-Root` | String[] | ☐ | Optional: search specific base folders<br>combined with  provided Names |
| `-IncludeNonTextFileMatching` | SwitchParameter | ☐ | Include non-text files (binaries, images,<br>etc.) when  searching file contents |
| `-CaseNameMatching` | IO.MatchCasing | ☐ | Gets or sets the case-sensitivity for files<br>and directories |
| `-SearchADSContent` | SwitchParameter | ☐ | When set, performs content search within<br>alternate data  streams (ADS). When not set,<br>outputs ADS file info without  searching<br>their content. |
| `-MaxRecursionDepth` | Int32 | ☐ | Maximum recursion depth for directory<br>traversal. 0 means  unlimited. |
| `-MaxFileSize` | Int64 | ☐ | Maximum file size in bytes to include in<br>results. 0 means  unlimited. |
| `-MinFileSize` | Int64 | ☐ | Minimum file size in bytes to include in<br>results. 0 means  no minimum. |
| `-ModifiedAfter` | DateTime | ☐ | Only include files modified after this<br>date/time (UTC). |
| `-ModifiedBefore` | DateTime | ☐ | Only include files modified before this<br>date/time (UTC). |
| `-AttributesToSkip` | IO.FileAttributes | ☐ | File attributes to skip (e.g., System, Hidden<br>or None). |
| `-Exclude` | String[] | ☐ | Exclude files or directories matching these<br>wildcard  patterns (e.g., *.tmp, *\\bin\\*). |
| `-CaseSensitive` | SwitchParameter | ☐ | Indicates that the cmdlet matches are<br>case-sensitive. By  default, matches aren't<br>case-sensitive. |
| `-Culture` | String | ☐ | Specifies a culture name to match the<br>specified pattern. The  Culture parameter<br>must be used with the SimpleMatch parameter. <br>The default behavior uses the culture of the<br>current PowerShell  runspace (session). |
| `-Encoding` | String | ☐ | Specifies the type of encoding for the target<br>file. The  default value is utf8NoBOM. |
| `-NotMatch` | SwitchParameter | ☐ | The NotMatch parameter finds text that<br>doesn't match the  specified pattern. |
| `-SimpleMatch` | SwitchParameter | ☐ | Indicates that the cmdlet uses a simple match<br>rather than a  regular expression match. In a<br>simple match, Select-String  searches the<br>input for the text in the Pattern parameter.<br>It  doesn't interpret the value of the<br>Pattern parameter as a  regular expression<br>statement. |
| `-Push` | SwitchParameter | ☐ | Use Push-Location instead of Set-Location and<br>push the location  onto the location stack |
| `-ExactMatch` | SwitchParameter | ☐ | When set, only exact name matches are<br>considered. By default,  wildcard matching is<br>used unless the Name contains wildcard <br>characters. |

## Examples

### Set-FoundLocation *.Console Changes to the first directory matching the pattern '*.Console'.

```powershell
Set-FoundLocation *.Console
Changes to the first directory matching the pattern '*.Console'.
```

### lcd *.Console Changes to the first directory matching the pattern '*.Console' using the alias.

```powershell
lcd *.Console
Changes to the first directory matching the pattern '*.Console' using the alias.
```

### Set-FoundLocation -Name "*.ps1" -Content "function" Changes to the directory containing the first PowerShell file that contains the word 'function'.

```powershell
Set-FoundLocation -Name "*.ps1" -Content "function"
Changes to the directory containing the first PowerShell file that contains
the word 'function'.
```

### Set-FoundLocation *test* -File Changes to the directory containing the first file with 'test' in its name.

```powershell
Set-FoundLocation *test* -File
Changes to the directory containing the first file with 'test' in its name.
```

### Set-FoundLocation * '1\.\d+\.2025' Changes to the directory containing the first file which content  matches the pattern '1.\d+\.2025'.

```powershell
Set-FoundLocation * '1\.\d+\.2025'
Changes to the directory containing the first file which content  matches the pattern '1.\d+\.2025'.
```

## Parameter Details

### `-Name <String>`

> File name or pattern to search for.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `like`, `Path`, `LiteralPath`, `Query`, `SearchMask`, `Include` |
| **Accept wildcard characters?** | Yes |

<hr/>

### `-InputObject <Object>`

> File name or pattern to search for from pipeline input.  Default is '*'

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `FullName` |
| **Accept wildcard characters?** | Yes |
| **Parameter set** | InputObject |

<hr/>

### `-Content <String[]>`

> Regular expression pattern to search within file contents

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `@(".*")` |
| **Accept pipeline input?** | False |
| **Aliases** | `mc`, `matchcontent`, `regex`, `Pattern` |
| **Accept wildcard characters?** | Yes |
| **Parameter set** | WithPattern |

<hr/>

### `-Category <String[]>`

> Only output files belonging to selected categories

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `filetype` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxDegreeOfParallelism <Int32>`

> Maximum degree of parallelism for directory tasks

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `threads` |
| **Accept wildcard characters?** | No |

<hr/>

### `-TimeoutSeconds <Int32>`

> Optional: cancellation timeout in seconds

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `maxseconds` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AllDrives`

> Search across all available drives

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-File`

> Search for filenames only and change to folder of first  found file

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `filename` |
| **Accept wildcard characters?** | No |

<hr/>

### `-DirectoriesAndFiles`

> Include filename matching and change to folder of first  found file

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `both`, `FilesAndDirectories` |
| **Accept wildcard characters?** | No |

<hr/>

### `-IncludeAlternateFileStreams`

> Include alternate data streams in search results

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ads` |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoRecurse`

> Do not recurse into subdirectories

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nr` |
| **Accept wildcard characters?** | No |

<hr/>

### `-FollowSymlinkAndJunctions`

> Follow symlinks and junctions during directory traversal

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `symlinks`, `sl` |
| **Accept wildcard characters?** | No |

<hr/>

### `-IncludeOpticalDiskDrives`

> Include optical disk drives

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SearchDrives <String[]>`

> Optional: search specific drives

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | `drives` |
| **Accept wildcard characters?** | No |

<hr/>

### `-DriveLetter <Char[]>`

> Optional: search specific drives

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Root <String[]>`

> Optional: search specific base folders combined with  provided Names

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-IncludeNonTextFileMatching`

> Include non-text files (binaries, images, etc.) when  searching file contents

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `binary` |
| **Accept wildcard characters?** | No |

<hr/>

### `-CaseNameMatching <IO.MatchCasing>`

> Gets or sets the case-sensitivity for files and directories

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `(
            [System.IO.MatchCasing]::PlatformDefault)` |
| **Accept pipeline input?** | False |
| **Aliases** | `casing`, `CaseSearchMaskMatching` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SearchADSContent`

> When set, performs content search within alternate data  streams (ADS). When not set, outputs ADS file info without  searching their content.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `sads` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxRecursionDepth <Int32>`

> Maximum recursion depth for directory traversal. 0 means  unlimited.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `md`, `depth`, `maxdepth` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxFileSize <Int64>`

> Maximum file size in bytes to include in results. 0 means  unlimited.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `maxlength`, `maxsize` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MinFileSize <Int64>`

> Minimum file size in bytes to include in results. 0 means  no minimum.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `minsize`, `minlength` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ModifiedAfter <DateTime>`

> Only include files modified after this date/time (UTC).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ma`, `after` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ModifiedBefore <DateTime>`

> Only include files modified before this date/time (UTC).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `before`, `mb` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AttributesToSkip <IO.FileAttributes>`

> File attributes to skip (e.g., System, Hidden or None).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `(
            [System.IO.FileAttributes]::System)` |
| **Accept pipeline input?** | False |
| **Aliases** | `skipattr` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Exclude <String[]>`

> Exclude files or directories matching these wildcard  patterns (e.g., *.tmp, *\\bin\\*).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@("*\\.git\\*")` |
| **Accept pipeline input?** | False |
| **Aliases** | `skiplike` |
| **Accept wildcard characters?** | No |

<hr/>

### `-CaseSensitive`

> Indicates that the cmdlet matches are case-sensitive. By  default, matches aren't case-sensitive.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-Culture <String>`

> Specifies a culture name to match the specified pattern. The  Culture parameter must be used with the SimpleMatch parameter.  The default behavior uses the culture of the current PowerShell  runspace (session).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-Encoding <String>`

> Specifies the type of encoding for the target file. The  default value is utf8NoBOM.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `"UTF8NoBOM"` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-NotMatch`

> The NotMatch parameter finds text that doesn't match the  specified pattern.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-SimpleMatch`

> Indicates that the cmdlet uses a simple match rather than a  regular expression match. In a simple match, Select-String  searches the input for the text in the Pattern parameter. It  doesn't interpret the value of the Pattern parameter as a  regular expression statement.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-Push`

> Use Push-Location instead of Set-Location and push the location  onto the location stack

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ExactMatch`

> When set, only exact name matches are considered. By default,  wildcard matching is used unless the Name contains wildcard  characters.

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
- [Expand-Path](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Expand-Path.md)
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
- [Set-LocationParent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent.md)
- [Set-LocationParent2](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent2.md)
- [Set-LocationParent3](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent3.md)
- [Set-LocationParent4](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent4.md)
- [Set-LocationParent5](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent5.md)
- [Start-RoboCopy](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-RoboCopy.md)
- [Write-FileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-FileAtomic.md)
- [Write-JsonFileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-JsonFileAtomic.md)
- [Write-TextFileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-TextFileAtomic.md)
