# GenXdev.FileSystem

## Overview

GenXdev.FileSystem provides advanced file and directory management beyond what
the built-in PowerShell providers offer. It handles long paths (>260 chars),
multi-threaded search with a custom pattern parser, robust copy via RoboCopy,
atomic file writes, duplicate detection, and project-wide text replacement.

## Features

* Simple but agile utility for renaming text throughout a project directory,
  including file- and directory- names: Rename-InProject -> rip

* Pretty good wrapper for robocopy, Microsoft's robust file copy utility: Start-RoboCopy -> rc, xc
    * Folder synchronization
    * Support for extra long pathnames > 256 characters
    * Restartable mode backups
    * Support for copying and fixing security settings
    * Advanced file attribute features
    * Advanced symbolic link and junction support
    * Monitor mode (restart copying after change threshold)
    * Optimization features for LargeFiles, multithreaded copying and
      network compression
    * Recovery mode (copy from failing disks)

* Find files with Find-Item -> l
    * Fast multi-threaded search: utilizes parallel and asynchronous
      IO processing with configurable maximum degree of parallelism
      (default based on CPU cores) for efficient file and directory scanning.
    * Advanced Pattern Matching: Supports wildcards (*, ?), recursive patterns
      like **, and complex path structures for precise file and directory queries.
      **/filename will only recurse until filename is matched. multiple of these
      patterns are allowed, as long as the are preceeded with a filename or
      directoryname to match.
      This pattern parser has the power of Resolve-Path but has recursion
      features, and does only support * and ? as wildcards,
      preventing bugs with paths with [ ] brackets in them, eliminating
      the need for -LiteralPath parameter, while maintaining integrity
      for paths sections without wildcards, unlike a wildcard match on the
      whole full path.
    * Enhanced Content Searching: Comprehensive Select-String integration
      with regular expression patterns within file contents using the
      -Content parameter.
        * Large File Optimization: Handles extremely large files with smart
          overlapping buffers and minimal heap allocation
        * Multiple Match Options: Find all matches per line (-AllMatches) or
          just the first match per file (-List)
        * Case Sensitivity Control: Case-sensitive matching (-CaseSensitive)
          with culture-specific options (-Culture)
        * Context Capture: Show lines before and after matches (-Context) for
          better understanding
        * Inverse Matching: Find files that don't contain the pattern (-NotMatch)
        * Output Formats: Raw string output (-Raw), quiet boolean response (-Quiet),
          or full MatchInfo objects
        * Pattern Types: Regular expressions (default) or simple literal string
          matching (-SimpleMatch)
        * Encoding Support: Specify file encoding (-Encoding) for accurate text
          processing
    * Path Type Flexibility: Handles relative, absolute, UNC, rooted paths, and
      NTFS alternate data streams (ADS) with optional content search in streams.
    * Multi-Drive Support: Searches across all drives with -AllDrives or specific
      drives via -SearchDrives, including optical disks if specified.
    * Directory and File Filtering: Options to search directories only (-Directory),
      both files and directories (-FilesAndDirectories), or files with content matching.
    * Exclusion and Limits: Exclude patterns with -Exclude, set max recursion depth
      -MaxRecursionDepth), file size limits (-MaxFileSize, -MinFileSize), and modified
      date filters (-ModifiedAfter, -ModifiedBefore).
    * Output Customization: Supports PassThru for FileInfo/DirectoryInfo objects,
      relative paths, hyperlinks in attended mode, or plain paths in unattended mode
      (use -NoLinks in case of mishaps to enforce unattended mode).
    * Performance Optimizations: Skips non-text files by default for content search
      (override with -IncludeNonTextFileMatching), handles long paths (>260 chars),
      and follows symlinks/junctions.
    * Safety Features: Timeout support (-TimeoutSeconds), ignores inaccessible items,
      skips system attributes by default, and prevents infinite loops with visited node tracking.

* Easily change directories with Set-FoundLocation -> lcd
    * Find directories by name/wildcard
    * Supports most of Find-Items parameters, like searching in file contents to match
      the directory to change location too
    * Has autocompletion, just type the first letters and press Tab or CTRL-SPACE

* Delete complete directory contents with Remove-AllItems -> sdel
    * Optionally delete the root folder as well

* Move files and directories with Move-ItemWithTracking

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Find-Item](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-Item.md) | `l` | Fast multi-threaded file/directory search with content matching |
| [Start-RoboCopy](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-RoboCopy.md) | `rc`, `xc` | Robust file copy with sync, restartable mode, long path support |
| [Set-FoundLocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-FoundLocation.md) | `lcd` | Find a directory by name and jump to it (with tab-completion) |
| [Rename-InProject](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Rename-InProject.md) | `rip` | Tex replacement across all files and file/directory names in a project (skips .git etc) |
| [Remove-AllItems](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-AllItems.md) | `sdel` | Recursively delete directory contents |
| [Find-DuplicateFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-DuplicateFiles.md) | `fdf` | Find duplicate files across directories by hash or criteria |
| [Expand-Path](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Expand-Path.md) | `ep` | Resolve any file reference to a full path |
| [Copy-FilesToDateFolder](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-FilesToDateFolder.md) | — | Copy files into date-based subfolder structures |
| [Write-FileAtomic](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-FileAtomic.md) | — | Write bytes to a file atomically to prevent corruption |

## How It All Comes Together

`Find-Item` (`l`) searches for files and directories with a custom pattern
parser. Its pattern syntax supports wildcards and recursive patterns like
`**` without the `[bracket]` issues of `Resolve-Path`. It can also search
file contents via `Select-String` integration.

`Set-FoundLocation` (`lcd`) finds a directory by name or wildcard and changes
the current location to it, with tab-completion. Related location cmdlets
(`..`, `...`, through `......`) navigate up one to five directory levels.

`Start-RoboCopy` (`rc`, `xc`) wraps Microsoft's RoboCopy with support for sync
mode, restartable copies, long paths, and multi-threaded transfers.

`Copy-FilesToDateFolder` and `Move-FilesToDateFolder` sort files into
date-based subfolder structures.

`Write-FileAtomic`, `Write-JsonFileAtomic`, and `Write-TextFileAtomic` write
files by creating a temp file and renaming it into place, preventing
corruption if the write is interrupted.

`Rename-InProject` (`rip`) replaces text across filenames, directory names,
and file contents in a single pass.

`Remove-AllItems` (`sdel`) recursively deletes directory contents.

`Find-DuplicateFiles` (`fdf`) finds duplicate files by hash or other criteria.

`Expand-Path` (`ep`) resolves any file reference to a full path.

## See Also

- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevfilesystem)
- [GenXdev.Media](README-GenXdev.Media.md) — Media playback and metadata
- [GenXdev.Data.Preferences](README-GenXdev.Data.Preferences.md) — Preferences system
