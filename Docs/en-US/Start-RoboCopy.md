# Start-RoboCopy

> **SubModule:** GenXdev.FileSystem | **Type:** Function | **Aliases:** `xc`, `rc`

## Synopsis

> Provides a PowerShell wrapper for Microsoft's Robust Copy (RoboCopy) utility.

## Description

A comprehensive wrapper for the RoboCopy command-line utility that provides
robust file and directory copying capabilities. This function exposes RoboCopy's
extensive feature set through PowerShell-friendly parameters while maintaining
most of its powerful functionality.
Key Features:
- Directory synchronization with mirror options
- Support for extra long pathnames (>256 characters)
- Security settings preservation
- Advanced file attribute handling
- Symbolic link and junction point management
- Monitor mode for continuous synchronization
- Performance optimization for large files
- Network compression support
- Recovery mode for failing devices


## Syntax

```powershell
Start-RoboCopy -Source <String> [[-DestinationDirectory] <String>] [[-Files] <String[]>] [[-Override] <String>] [-AttributeExcludeFilter <String>] [-AttributeIncludeFilter <String>] [-CompressibleContent] [-CopyOnlyDirectoryTreeStructureAndEmptyFiles] [-CopySymbolicLinksAsLinks] [-ExactTimestamps] [-FileExcludeFilter <String[]>] [-Force] [-IncludeSecurity] [-LargeFiles] [-LogAllFileNames] [-LogDirectoryNames] [-LogfileOverwrite] [-LogFilePath <String>] [-MaxFileAge <Int32>] [-MaxFileSize <Int32>] [-MaxLastAccessAge <Int32>] [-MinFileAge <Int32>] [-MinFileSize <Int32>] [-MinLastAccessAge <Int32>] [-Mirror] [-MonitorMode] [-MonitorModeRunHoursFrom <Int32>] [-MonitorModeRunHoursUntil <Int32>] [-MonitorModeThresholdMinutes <Int32>] [-MonitorModeThresholdNrOfChanges <Int32>] [-Move] [-MultiThreaded] [-RecoveryMode] [-RemoveAttributesAfterCopy <String>] [-ResetArchiveAttributeAfterSelection] [-SetAttributesAfterCopy <String>] [-SkipAllSymbolicLinks] [-SkipFilesWithoutArchiveAttribute] [-SkipSymbolicFileLinks] [-Unicode] [<CommonParameters>]

Start-RoboCopy [-SkipDirectories] [<CommonParameters>]

Start-RoboCopy [-CopyJunctionsAsJunctons] [-CopyOnlyDirectoryTreeStructure] [-DirectoryExcludeFilter <String[]>] [-MaxSubDirTreeLevelDepth <Int32>] [-SkipEmptyDirectories] [-SkipJunctions] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Source` | String | ✅ | The directory, filepath, or<br>directory+searchmask |
| `-DestinationDirectory` | String | ☐ | The destination directory to place the copied<br>files and directories into. If this directory<br>does not exist yet, all missing directories<br>will be created. Default value = `".\` |
| `-Files` | String[] | ☐ | Optional searchmask for selecting the files<br>that need to be copied. Default value = '* 🌐<br>wildcards |
| `-Mirror` | SwitchParameter | ☐ | Synchronizes the content of specified<br>directories, will also delete any files and<br>directories in the destination that do not<br>exist in the source |
| `-Move` | SwitchParameter | ☐ | Will move instead of copy all files from<br>source to destination |
| `-IncludeSecurity` | SwitchParameter | ☐ | Will also copy ownership, security<br>descriptors and auditing information of files<br>and directories |
| `-SkipDirectories` | SwitchParameter | ☐ | Copies only files from source and skips<br>sub-directories (no recurse) |
| `-SkipEmptyDirectories` | SwitchParameter | ☐ | Does not copy directories if they would be<br>empty |
| `-CopyOnlyDirectoryTreeStructure` | SwitchParameter | ☐ | Create directory tree only |
| `-CopyOnlyDirectoryTreeStructureAndEmptyFiles` | SwitchParameter | ☐ | Create directory tree and zero-length files<br>only |
| `-SkipAllSymbolicLinks` | SwitchParameter | ☐ | Don't copy symbolic links, junctions or the<br>content they point to |
| `-SkipSymbolicFileLinks` | SwitchParameter | ☐ | Don't copy file symbolic links but do follow<br>directory junctions |
| `-CopySymbolicLinksAsLinks` | SwitchParameter | ☐ | Instead of copying the content where symbolic<br>links point to, copy the links themselves |
| `-SkipJunctions` | SwitchParameter | ☐ | Don't copy directory junctions (symbolic link<br>for a folder) or the content they point to |
| `-CopyJunctionsAsJunctons` | SwitchParameter | ☐ | Instead of copying the content where<br>junctions point to, copy the junctions<br>themselves |
| `-Force` | SwitchParameter | ☐ | Will copy all files even if they are older<br>then the ones in the destination |
| `-SkipFilesWithoutArchiveAttribute` | SwitchParameter | ☐ | Copies only files that have the archive<br>attribute set |
| `-ResetArchiveAttributeAfterSelection` | SwitchParameter | ☐ | In addition of copying only files that have<br>the archive attribute set, will then reset<br>this attribute on the source |
| `-FileExcludeFilter` | String[] | ☐ | Exclude any files that matches any of these<br>names/paths/wildcards 🌐 wildcards |
| `-DirectoryExcludeFilter` | String[] | ☐ | Exclude any directories that matches any of<br>these names/paths/wildcards 🌐 wildcards |
| `-AttributeIncludeFilter` | String | ☐ | Copy only files that have all these<br>attributes set [RASHCNETO] |
| `-AttributeExcludeFilter` | String | ☐ | Exclude files that have any of these<br>attributes set [RASHCNETO] |
| `-SetAttributesAfterCopy` | String | ☐ | Will set the given attributes to copied files<br>[RASHCNETO] |
| `-RemoveAttributesAfterCopy` | String | ☐ | Will remove the given attributes from copied<br>files [RASHCNETO] |
| `-MaxSubDirTreeLevelDepth` | Int32 | ☐ | Only copy the top n levels of the source<br>directory tree |
| `-MinFileSize` | Int32 | ☐ | Skip files that are not at least n bytes in<br>size |
| `-MaxFileSize` | Int32 | ☐ | Skip files that are larger then n bytes |
| `-MinFileAge` | Int32 | ☐ | Skip files that are not at least: n days old<br>OR created before n date (if n < 1900 then n<br>= n days, else n = YYYYMMDD date) |
| `-MaxFileAge` | Int32 | ☐ | Skip files that are older then: n days OR<br>created after n date (if n < 1900 then n = n<br>days, else n = YYYYMMDD date) |
| `-MinLastAccessAge` | Int32 | ☐ | Skip files that are accessed within the last:<br>n days OR before n date (if n < 1900 then n =<br>n days, else n = YYYYMMDD date) |
| `-MaxLastAccessAge` | Int32 | ☐ | Skip files that have not been accessed in: n<br>days OR after n date (if n < 1900 then n = n<br>days, else n = YYYYMMDD date) |
| `-RecoveryMode` | SwitchParameter | ☐ | Will shortly pause and retry when I/O errors<br>occur during copying |
| `-MonitorMode` | SwitchParameter | ☐ | Will stay active after copying, and copy<br>additional changes after a a default<br>threshold of 10 minutes |
| `-MonitorModeThresholdMinutes` | Int32 | ☐ | Run again in n minutes Time, if changed |
| `-MonitorModeThresholdNrOfChanges` | Int32 | ☐ | Run again when more then n changes seen |
| `-MonitorModeRunHoursFrom` | Int32 | ☐ | Run hours - times when new copies may be<br>started, start-time, range 0000:2359 |
| `-MonitorModeRunHoursUntil` | Int32 | ☐ | Run hours - times when new copies may be<br>started, end-time, range 0000:2359 |
| `-LogFilePath` | String | ☐ | If specified, logging will also be done to<br>specified file |
| `-LogfileOverwrite` | SwitchParameter | ☐ | Don't append to the specified logfile, but<br>overwrite instead |
| `-LogDirectoryNames` | SwitchParameter | ☐ | Include all scanned directory names in output |
| `-LogAllFileNames` | SwitchParameter | ☐ | Include all scanned file names in output,<br>even skipped onces |
| `-Unicode` | SwitchParameter | ☐ | Output status as UNICODE |
| `-LargeFiles` | SwitchParameter | ☐ | Enables optimization for copying large files |
| `-MultiThreaded` | SwitchParameter | ☐ | Optimize performance by doing multithreaded<br>copying |
| `-CompressibleContent` | SwitchParameter | ☐ | If applicable use compression when copying<br>files between servers to safe bandwidth and<br>time |
| `-ExactTimestamps` | SwitchParameter | ☐ | When set, will use millisecond timestamp<br>matching instead of the default 2-second<br>tolerance |
| `-Override` | String | ☐ | Overrides, Removes, or Adds any specified<br>robocopy parameter. Usage: Add or replace<br>parameter: -Override<br>/SwitchWithValue:'SomeValue' -Override<br>/Switch Remove parameter: -Override -/Switch<br>Multiple overrides: -Override<br>`"/ReplaceThisSwitchWithValue:'SomeValue'<br>-/RemoveThisSwitch /AddThisSwitch`" |

## Examples

### ########################################################################Mirror a directory with security settings Start-RoboCopy -Source "C:\Projects" -DestinationDirectory "D:\Backup" `     -Mirror -IncludeSecurity

```powershell
########################################################################Mirror a directory with security settings
Start-RoboCopy -Source "C:\Projects" -DestinationDirectory "D:\Backup" `
    -Mirror -IncludeSecurity
```

### ########################################################################Monitor and sync changes every 10 minutes Start-RoboCopy -Source "C:\Documents" -DestinationDirectory "\\server\share" `     -MonitorMode -MonitorModeThresholdMinutes 10

```powershell
########################################################################Monitor and sync changes every 10 minutes
Start-RoboCopy -Source "C:\Documents" -DestinationDirectory "\\server\share" `
    -MonitorMode -MonitorModeThresholdMinutes 10
```

## Parameter Details

### `-Source <String>`

> The directory, filepath, or directory+searchmask

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DestinationDirectory <String>`

> The destination directory to place the copied files and directories into. If this directory does not exist yet, all missing directories will be created. Default value = `".\`

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `".$([System.IO.Path]::DirectorySeparatorChar)"` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Files <String[]>`

> Optional searchmask for selecting the files that need to be copied. Default value = '*

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | Yes |

<hr/>

### `-Mirror`

> Synchronizes the content of specified directories, will also delete any files and directories in the destination that do not exist in the source

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Move`

> Will move instead of copy all files from source to destination

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-IncludeSecurity`

> Will also copy ownership, security descriptors and auditing information of files and directories

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipDirectories`

> Copies only files from source and skips sub-directories (no recurse)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Default |

<hr/>

### `-SkipEmptyDirectories`

> Does not copy directories if they would be empty

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | SkipDirectories |

<hr/>

### `-CopyOnlyDirectoryTreeStructure`

> Create directory tree only

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | SkipDirectories |

<hr/>

### `-CopyOnlyDirectoryTreeStructureAndEmptyFiles`

> Create directory tree and zero-length files only

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipAllSymbolicLinks`

> Don't copy symbolic links, junctions or the content they point to

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipSymbolicFileLinks`

> Don't copy file symbolic links but do follow directory junctions

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-CopySymbolicLinksAsLinks`

> Instead of copying the content where symbolic links point to, copy the links themselves

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipJunctions`

> Don't copy directory junctions (symbolic link for a folder) or the content they point to

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | SkipDirectories |

<hr/>

### `-CopyJunctionsAsJunctons`

> Instead of copying the content where junctions point to, copy the junctions themselves

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | SkipDirectories |

<hr/>

### `-Force`

> Will copy all files even if they are older then the ones in the destination

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipFilesWithoutArchiveAttribute`

> Copies only files that have the archive attribute set

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ResetArchiveAttributeAfterSelection`

> In addition of copying only files that have the archive attribute set, will then reset this attribute on the source

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-FileExcludeFilter <String[]>`

> Exclude any files that matches any of these names/paths/wildcards

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | Yes |

<hr/>

### `-DirectoryExcludeFilter <String[]>`

> Exclude any directories that matches any of these names/paths/wildcards

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | Yes |
| **Parameter set** | SkipDirectories |

<hr/>

### `-AttributeIncludeFilter <String>`

> Copy only files that have all these attributes set [RASHCNETO]

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AttributeExcludeFilter <String>`

> Exclude files that have any of these attributes set [RASHCNETO]

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SetAttributesAfterCopy <String>`

> Will set the given attributes to copied files [RASHCNETO]

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-RemoveAttributesAfterCopy <String>`

> Will remove the given attributes from copied files [RASHCNETO]

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxSubDirTreeLevelDepth <Int32>`

> Only copy the top n levels of the source directory tree

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | SkipDirectories |

<hr/>

### `-MinFileSize <Int32>`

> Skip files that are not at least n bytes in size

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxFileSize <Int32>`

> Skip files that are larger then n bytes

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MinFileAge <Int32>`

> Skip files that are not at least: n days old OR created before n date (if n < 1900 then n = n days, else n = YYYYMMDD date)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxFileAge <Int32>`

> Skip files that are older then: n days OR created after n date (if n < 1900 then n = n days, else n = YYYYMMDD date)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MinLastAccessAge <Int32>`

> Skip files that are accessed within the last: n days OR before n date (if n < 1900 then n = n days, else n = YYYYMMDD date)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxLastAccessAge <Int32>`

> Skip files that have not been accessed in: n days OR after n date (if n < 1900 then n = n days, else n = YYYYMMDD date)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-RecoveryMode`

> Will shortly pause and retry when I/O errors occur during copying

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MonitorMode`

> Will stay active after copying, and copy additional changes after a a default threshold of 10 minutes

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MonitorModeThresholdMinutes <Int32>`

> Run again in n minutes Time, if changed

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MonitorModeThresholdNrOfChanges <Int32>`

> Run again when more then n changes seen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MonitorModeRunHoursFrom <Int32>`

> Run hours - times when new copies may be started, start-time, range 0000:2359

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MonitorModeRunHoursUntil <Int32>`

> Run hours - times when new copies may be started, end-time, range 0000:2359

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LogFilePath <String>`

> If specified, logging will also be done to specified file

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LogfileOverwrite`

> Don't append to the specified logfile, but overwrite instead

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LogDirectoryNames`

> Include all scanned directory names in output

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LogAllFileNames`

> Include all scanned file names in output, even skipped onces

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Unicode`

> Output status as UNICODE

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LargeFiles`

> Enables optimization for copying large files

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MultiThreaded`

> Optimize performance by doing multithreaded copying

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-CompressibleContent`

> If applicable use compression when copying files between servers to safe bandwidth and time

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ExactTimestamps`

> When set, will use millisecond timestamp matching instead of the default 2-second tolerance

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Override <String>`

> Overrides, Removes, or Adds any specified robocopy parameter. Usage: Add or replace parameter: -Override /SwitchWithValue:'SomeValue' -Override /Switch Remove parameter: -Override -/Switch Multiple overrides: -Override `"/ReplaceThisSwitchWithValue:'SomeValue' -/RemoveThisSwitch /AddThisSwitch`"

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 3 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

> This parameter accepts all remaining arguments.

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
- [Set-FoundLocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-FoundLocation.md)
- [Set-LocationParent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent.md)
- [Set-LocationParent2](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent2.md)
- [Set-LocationParent3](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent3.md)
- [Set-LocationParent4](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent4.md)
- [Set-LocationParent5](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-LocationParent5.md)
- [Write-FileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-FileAtomic.md)
- [Write-JsonFileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-JsonFileAtomic.md)
- [Write-TextFileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-TextFileAtomic.md)
