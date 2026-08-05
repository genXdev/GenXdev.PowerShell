# Find-Item

> **SubModule:** GenXdev.FileSystem | **Type:** Cmdlet | **Aliases:** `l`

## Synopsis

> Search for files and directories with advanced filtering options.

## Description

```text
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
                  just the first match per file(-List)
            * Case Sensitivity Control: Case-sensitive matching(-CaseSensitive)
                  with culture-specific options(-Culture)
            * Context Capture: Show lines before and after matches(-Context) for
                  better understanding
            *Inverse Matching: Find files that don't contain the pattern (-NotMatch)
            * Output Formats: Raw string output(-Raw), quiet boolean response(-Quiet),
                  or full MatchInfo objects
            * Pattern Types: Regular expressions(default) or simple literal string
                  matching(-SimpleMatch)
            * Encoding Support: Specify file encoding(-Encoding) for accurate text
                  processing
        * Path Type Flexibility: Handles relative, absolute, UNC, rooted paths, and
              NTFS alternate data streams(ADS) with optional content search in streams.
        * Multi-Drive Support: Searches across all drives with - AllDrives or specific
              drives via -SearchDrives, including optical disks if specified.
        * Directory and File Filtering: Options to search directories only(-Directory),
              both files and directories(-FilesAndDirectories), or files with content matching.
        * Exclusion and Limits: Exclude patterns with -Exclude, set max recursion depth
              -MaxRecursionDepth), file size limits(-MaxFileSize, -MinFileSize), and modified
              date filters(-ModifiedAfter, -ModifiedBefore).
        * Output Customization: Supports PassThru for FileInfo/DirectoryInfo objects,
              relative paths, hyperlinks in attended mode, or plain paths in unattended mode
              (use -NoLinks in case of mishaps to enforce unattended mode).
        * Performance Optimizations: Skips non-text files by default for content search
              (override with -IncludeNonTextFileMatching), handles long paths(>260 chars),
              and follows symlinks/junctions.
        * Safety Features: Timeout support(-TimeoutSeconds), ignores inaccessible items,
              skips system attributes by default, and prevents infinite loops with visited node tracking.

        * Valid categories for the -Category parameter are: Pictures, Videos, Music, Documents, Spreadsheets, Presentations, Archives, Installers, Executables, Databases, DesignFiles, Ebooks, Subtitles, Fonts, EmailFiles, 3DModels, GameAssets, MedicalFiles, FinancialFiles, LegalFiles, SourceCode, Scripts, MarkupAndData, Configuration, Logs, TextFiles, WebFiles, MusicLyricsAndChords, CreativeWriting, Recipes, ResearchFiles
```

## Syntax

```powershell
Find-Item [[-Name] <String[]>] [[-RelativeBasePath] <String>] [-AllDrives] [-AttributesToSkip <IO.FileAttributes>] [-CaseNameMatching <IO.MatchCasing>] [-Category <String[]>] [-Directory] [-DriveLetter <Char[]>] [-Exclude <String[]>] [-FilesAndDirectories] [-FollowSymlinkAndJunctions] [-IncludeAlternateFileStreams] [-IncludeNonTextFileMatching] [-IncludeOpticalDiskDrives] [-Input <Object>] [-LimitToRoot] [-MaxDegreeOfParallelism <Int32>] [-MaxFileSize <Int64>] [-MaxRecursionDepth <Int32>] [-MaxSearchUpDepth <Int32>] [-MinFileSize <Int64>] [-ModifiedAfter <DateTime?>] [-ModifiedBefore <DateTime?>] [-NoLinks] [-NoRecurse] [-PassThru] [-Root <String[]>] [-SearchADSContent] [-SearchDrives <String[]>] [-TimeoutSeconds <Int32?>] [<CommonParameters>]

Find-Item [[-Content] <String[]>] [-AllMatches] [-CaseSensitive] [-Context <Int32[]>] [-Culture <String>] [-Encoding <String>] [-List] [-NoEmphasis] [-NotMatch] [-Quiet] [-Raw] [-SimpleMatch] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Name` | String[] | ☐ | File name or pattern to search for. Default<br>is '*' 🌐 wildcards |
| `-Input` | Object | ☐ | File name or pattern to search for. Default<br>is '*' 🌐 wildcards |
| `-Content` | String[] | ☐ | Regular expression pattern to search within<br>content 🌐 wildcards |
| `-RelativeBasePath` | String | ☐ | Base path for resolving relative paths in<br>output |
| `-Category` | String[] | ☐ | The `-Category` parameter. |
| `-MaxDegreeOfParallelism` | Int32 | ☐ | Maximum degree of parallelism for directory<br>tasks |
| `-TimeoutSeconds` | Int32? | ☐ | Optional: cancellation timeout in seconds |
| `-AllDrives` | SwitchParameter | ☐ | Search across all available drives |
| `-Directory` | SwitchParameter | ☐ | Search for directories only |
| `-FilesAndDirectories` | SwitchParameter | ☐ | Include both files and directories |
| `-PassThru` | SwitchParameter | ☐ | Output matched items as objects |
| `-IncludeAlternateFileStreams` | SwitchParameter | ☐ | Include alternate data streams in search<br>results |
| `-NoRecurse` | SwitchParameter | ☐ | Do not recurse into subdirectories |
| `-FollowSymlinkAndJunctions` | SwitchParameter | ☐ | Follow symlinks and junctions during<br>directory traversal |
| `-IncludeOpticalDiskDrives` | SwitchParameter | ☐ | Include optical disk drives |
| `-SearchDrives` | String[] | ☐ | Optional: search specific drives |
| `-DriveLetter` | Char[] | ☐ | Optional: search specific drives |
| `-Root` | String[] | ☐ | Optional: search specific directories |
| `-LimitToRoot` | SwitchParameter | ☐ | Enforces searching only within Root<br>directories by stripping directory components<br>from Name inputs |
| `-IncludeNonTextFileMatching` | SwitchParameter | ☐ | Include non-text files when searching file<br>contents |
| `-NoLinks` | SwitchParameter | ☐ | Forces unattended mode and will not generate<br>links |
| `-CaseNameMatching` | IO.MatchCasing | ☐ | Gets or sets the case-sensitivity for files<br>and directories |
| `-SearchADSContent` | SwitchParameter | ☐ | When set, performs content search within<br>alternate data streams (ADS). When not set,<br>outputs ADS file info without searching their<br>content. |
| `-MaxRecursionDepth` | Int32 | ☐ | Maximum recursion depth for directory<br>traversal. 0 means unlimited. |
| `-MaxSearchUpDepth` | Int32 | ☐ | Maximum recursion depth for continuing<br>searching upwards the tree for relative<br>searches, while no items are found. 0 means<br>disabled. |
| `-MaxFileSize` | Int64 | ☐ | Maximum file size in bytes to include in<br>results. 0 means unlimited. |
| `-MinFileSize` | Int64 | ☐ | Minimum file size in bytes to include in<br>results. 0 means no minimum. |
| `-ModifiedAfter` | DateTime? | ☐ | Only include files modified after this<br>date/time (UTC). |
| `-ModifiedBefore` | DateTime? | ☐ | Only include files modified before this<br>date/time (UTC). |
| `-AttributesToSkip` | IO.FileAttributes | ☐ | File attributes to skip (e.g., System, Hidden<br>or None). |
| `-Exclude` | String[] | ☐ | Exclude files or directories matching these<br>wildcard patterns (e.g., *.tmp, *\bin\*). |
| `-AllMatches` | SwitchParameter | ☐ | Indicates that the cmdlet searches for more<br>than one match in each line of text. Without<br>this parameter, Select-String finds only the<br>first match in each line of text. |
| `-CaseSensitive` | SwitchParameter | ☐ | Indicates that the cmdlet matches are<br>case-sensitive. By default, matches aren't<br>case-sensitive. |
| `-Context` | Int32[] | ☐ | Captures the specified number of lines before<br>and after the line that matches the pattern. |
| `-Culture` | String | ☐ | Specifies a culture name to match the<br>specified pattern. The Culture parameter must<br>be used with the SimpleMatch parameter. The<br>default behavior uses the culture of the<br>current PowerShell runspace (session). |
| `-Encoding` | String | ☐ | Specifies the type of encoding for the target<br>file. Supports Select-String compatible<br>values and extended .NET encodings. |
| `-List` | SwitchParameter | ☐ | Only the first instance of matching text is<br>returned from each input file. This is the<br>most efficient way to retrieve a list of<br>files that have contents matching the regular<br>expression. |
| `-NoEmphasis` | SwitchParameter | ☐ | Disables highlighting of matching strings in<br>output. |
| `-NotMatch` | SwitchParameter | ☐ | The NotMatch parameter finds text that<br>doesn't match the specified pattern. |
| `-Quiet` | SwitchParameter | ☐ | Indicates that the cmdlet returns a simple<br>response instead of a MatchInfo object. The<br>returned value is $true if the pattern is<br>found or $null if the pattern is not found. |
| `-Raw` | SwitchParameter | ☐ | Causes the cmdlet to output only the matching<br>strings, rather than MatchInfo objects. This<br>is the results in behavior that's the most<br>similar to the Unix grep or Windows<br>findstr.exe commands. |
| `-SimpleMatch` | SwitchParameter | ☐ | Indicates that the cmdlet uses a simple match<br>rather than a regular expression match. In a<br>simple match, Select-String searches the<br>input for the text in the Pattern parameter.<br>It doesn't interpret the value of the Pattern<br>parameter as a regular expression statement. |

## Examples

### Examples 1

```powershell
Find-Item -Content "translation"

# Short form:
l -mc translation
```

Find files containing a specific word
Search for all files in the current directory and subdirectories that contain the word "translation".

### Examples 2

```powershell
Find-Item "*.js" "Version == `"\d\d?\.\d\d?\.\d\d?`""

# Short form:
l *.js "Version == `"\d\d?\.\d\d?\.\d\d?`""
```

Find JavaScript files with a version string
Search for JavaScript files containing a version string in the format "Version == `x.y.z`".

### Examples 3

```powershell
Find-Item -Directory

# Short form:
l -dir
```

List all directories
Find all directories in the current directory and its subdirectories.

### Examples 4

```powershell
Find-Item ".\*.xml" -PassThru | % FullName

# Short form:
l *.xml -pt | % FullName
```

Find XML files and pass objects
Search for all .xml files and pass the results as objects through the pipeline.

### Examples 5

```powershell
Find-Item -IncludeAlternateFileStreams

# Short form:
l -ads
```

Include alternate data streams
Search for all files and include their alternate data streams in the results.

### Examples 6

```powershell
Find-Item "*.pdf" -AllDrives

# Short form:
l *.pdf -alldrives
```

Search across all drives
Search for all PDF files across all available drives.

### Examples 7

```powershell
Find-Item "*.log" -TimeoutSeconds 300 -MaxDegreeOfParallelism 4

# Short form:
l *.log -maxseconds 300 -threads 4
```

Custom timeout and parallelism
Search for log files with a 5-minute timeout and limited parallelism.

### Examples 8

```powershell
Get-ChildItem -Path "C:\Logs" | Find-Item -Content "error"

# Short form:
ls C:\Logs | l -matchcontent "error"
```

Pipeline input
Pass file paths from Get-ChildItem to search for files containing "error".

### Examples 9

```powershell
Find-Item "*.txt" -MaxRecursionDepth 2

# Short form:
l *.txt -maxdepth 2
```

Limit recursion depth
Search for text files but limit recursion to 2 directory levels.

### Examples 10

```powershell
Find-Item -MinFileSize 1048576 -MaxFileSize 10485760

# Short form:
l -minsize 1048576 -maxsize 10485760
```

Filter by file size
Find files larger than 1MB but smaller than 10MB.

### Examples 11

```powershell
Find-Item -ModifiedAfter "2025-01-01"

# Short form:
l -after "2025-01-01"
```

Filter by modification date
Find files modified after January 1, 2025.

### Examples 12

```powershell
Find-Item -Exclude "*.tmp", "*\bin\*"

# Short form:
l -skiplike "*.tmp", "*\bin\*"
```

Exclude specific patterns
Search for all files but exclude temporary files and bin directories.

### Examples 13

```powershell
Find-Item "*.docx" -SearchDrives "C:\", "D:\"

# Short form:
l *.docx -drives C:\, D:\
```

Search specific drives
Search for .docx files on C: and D: drives only.

### Examples 14

```powershell
Find-Item -Content "Error" -CaseSensitive

# Short form:
l -mc "Error" -CaseSensitive
```

Case-sensitive content search
Search for files containing "Error" (case-sensitive) in their content.

### Examples 15

```powershell
Find-Item -IncludeAlternateFileStreams -SearchADSContent -Content "secret"

# Short form:
l -ads -sads -mc "secret"
```

Search alternate data stream content
Search for files with alternate data streams containing "secret".

### Examples 16

```powershell
Find-Item "*.ps1" -Content "function" -AllMatches

# Short form:
l *.ps1 -mc "function" -AllMatches
```

Find all matches per line
Search for all occurrences of "function" in each line, not just the first match.

### Examples 17

```powershell
Find-Item "*.log" -Content "error" -Context 2,3

# Short form:
l *.log -mc "error" -Context 2,3
```

Show context around matches
Display 2 lines before and 3 lines after each match for better understanding.

### Examples 18

```powershell
Find-Item "*.txt" -Content "TODO:.*" -Raw

# Short form:
l *.txt -mc "TODO:.*" -Raw
```

Get only matching strings
Return just the matching text strings instead of full match objects.

### Examples 19

```powershell
Find-Item "*.config" -Content "database" -Quiet

# Short form:
l *.config -mc "database" -Quiet
```

Simple boolean check
Return true/false instead of match details to check if pattern exists.

### Examples 20

```powershell
Find-Item "*.cs" -Content "class.*Controller" -List

# Short form:
l *.cs -mc "class.*Controller" -List
```

Find first match only per file
Stop at the first match in each file for efficient file listing.

### Examples 21

```powershell
Find-Item "*.txt" -Content "$variable[0]" -SimpleMatch

# Short form:
l *.txt -mc "$variable[0]" -SimpleMatch
```

Literal string matching
Search for exact text without regex interpretation using SimpleMatch.

### Examples 22

```powershell
Find-Item "*.js" -Content "console\.log" -NotMatch

# Short form:
l *.js -mc "console\.log" -NotMatch
```

Find files NOT containing pattern
Use NotMatch to find files that don't contain the specified pattern.

### Examples 23

```powershell
Find-Item "*.txt" -Content "café" -Encoding UTF8

# Short form:
l *.txt -mc "café" -Encoding UTF8
```

Specify file encoding
Search files with specific encoding for accurate text processing.

### Examples 24

```powershell
Find-Item "*.txt" -Content "Müller" -SimpleMatch -Culture "de-DE"

# Short form:
l *.txt -mc "Müller" -SimpleMatch -Culture "de-DE"
```

Cultural text comparison
Use culture-specific matching with SimpleMatch for international text.

### Examples 25

```powershell
Find-Item "*.log" -Content "exception" -MinFileSize 1024 -ModifiedAfter "2025-01-01" -MaxRecursionDepth 3

# Short form:
l *.log -mc "exception" -minsize 1024 -after "2025-01-01" -maxdepth 3
```

Complex content search with file filters
Combine file size, date, and content filters for precise searches.

## Parameter Details

### `-Name <String[]>`

> File name or pattern to search for. Default is '*'

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `like`, `Path`, `LiteralPath`, `Query`, `SearchMask`, `Include` |
| **Accept wildcard characters?** | Yes |

<hr/>

### `-Input <Object>`

> File name or pattern to search for. Default is '*'

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `FullName` |
| **Accept wildcard characters?** | Yes |

<hr/>

### `-Content <String[]>`

> Regular expression pattern to search within content

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `mc`, `matchcontent`, `regex`, `Pattern` |
| **Accept wildcard characters?** | Yes |
| **Parameter set** | WithPattern |

<hr/>

### `-RelativeBasePath <String>`

> Base path for resolving relative paths in output

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `base` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Category <String[]>`

> The `-Category` parameter.

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

### `-TimeoutSeconds <Int32?>`

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
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Directory`

> Search for directories only

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `dir` |
| **Accept wildcard characters?** | No |

<hr/>

### `-FilesAndDirectories`

> Include both files and directories

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `both`, `DirectoriesAndFiles` |
| **Accept wildcard characters?** | No |

<hr/>

### `-PassThru`

> Output matched items as objects

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `pt` |
| **Accept wildcard characters?** | No |

<hr/>

### `-IncludeAlternateFileStreams`

> Include alternate data streams in search results

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
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
| **Default value** | `False` |
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
| **Default value** | `False` |
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
| **Default value** | `False` |
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
| **Default value** | *(none)* |
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
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Root <String[]>`

> Optional: search specific directories

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-LimitToRoot`

> Enforces searching only within Root directories by stripping directory components from Name inputs

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `limit` |
| **Accept wildcard characters?** | No |

<hr/>

### `-IncludeNonTextFileMatching`

> Include non-text files when searching file contents

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `binary` |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoLinks`

> Forces unattended mode and will not generate links

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `nl`, `ForceUnattenedMode` |
| **Accept wildcard characters?** | No |

<hr/>

### `-CaseNameMatching <IO.MatchCasing>`

> Gets or sets the case-sensitivity for files and directories

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `PlatformDefault` |
| **Accept pipeline input?** | False |
| **Aliases** | `casing`, `CaseSearchMaskMatching ` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SearchADSContent`

> When set, performs content search within alternate data streams (ADS). When not set, outputs ADS file info without searching their content.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | `sads` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxRecursionDepth <Int32>`

> Maximum recursion depth for directory traversal. 0 means unlimited.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `md`, `depth`, `maxdepth` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxSearchUpDepth <Int32>`

> Maximum recursion depth for continuing searching upwards the tree for relative searches, while no items are found. 0 means disabled.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `maxupward` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxFileSize <Int64>`

> Maximum file size in bytes to include in results. 0 means unlimited.

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

> Minimum file size in bytes to include in results. 0 means no minimum.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `minsize`, `minlength` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ModifiedAfter <DateTime?>`

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

### `-ModifiedBefore <DateTime?>`

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
| **Default value** | `None` |
| **Accept pipeline input?** | False |
| **Aliases** | `skipattr` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Exclude <String[]>`

> Exclude files or directories matching these wildcard patterns (e.g., *.tmp, *\bin\*).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `skiplike` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AllMatches`

> Indicates that the cmdlet searches for more than one match in each line of text. Without this parameter, Select-String finds only the first match in each line of text.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-CaseSensitive`

> Indicates that the cmdlet matches are case-sensitive. By default, matches aren't case-sensitive.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-Context <Int32[]>`

> Captures the specified number of lines before and after the line that matches the pattern.

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

> Specifies a culture name to match the specified pattern. The Culture parameter must be used with the SimpleMatch parameter. The default behavior uses the culture of the current PowerShell runspace (session).

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

> Specifies the type of encoding for the target file. Supports Select-String compatible values and extended .NET encodings.

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

### `-List`

> Only the first instance of matching text is returned from each input file. This is the most efficient way to retrieve a list of files that have contents matching the regular expression.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-NoEmphasis`

> Disables highlighting of matching strings in output.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-NotMatch`

> The NotMatch parameter finds text that doesn't match the specified pattern.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-Quiet`

> Indicates that the cmdlet returns a simple response instead of a MatchInfo object. The returned value is $true if the pattern is found or $null if the pattern is not found.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-Raw`

> Causes the cmdlet to output only the matching strings, rather than MatchInfo objects. This is the results in behavior that's the most similar to the Unix grep or Windows findstr.exe commands.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

### `-SimpleMatch`

> Indicates that the cmdlet uses a simple match rather than a regular expression match. In a simple match, Select-String searches the input for the text in the Pattern parameter. It doesn't interpret the value of the Pattern parameter as a regular expression statement.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | WithPattern |

<hr/>

## Related Links

- [Copy-FilesToDateFolder](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-FilesToDateFolder.md)
- [Expand-Path](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Expand-Path.md)
- [Find-DuplicateFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-DuplicateFiles.md)
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
