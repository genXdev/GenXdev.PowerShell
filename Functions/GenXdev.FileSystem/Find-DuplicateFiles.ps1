###############################################################################

# don't remove this line [dontrefactor]

<#
.SYNOPSIS
Find duplicate files across multiple directories based on configurable criteria.

.DESCRIPTION
Recursively searches specified directories for duplicate files. Files are
considered duplicates if the content is either exactly the same or starts with
the same content (for partial comparison using the -ComparePartial switch).
The cmdlet uses a quick hash of the initial bytes of the file for efficient grouping before performing full content comparisons.
The size of this quick hash can be configured with the -CompareByteLength parameter,
allowing for a balance between performance and accuracy in duplicate detection,
only files that have a minimum length of this CompareByteLength value will be considered for duplicate detection,
smaller files will be grouped based on filename only.

.LICENSE
Copyright (C) 2026 René Vaessen / GenXdev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>.

.PARAMETER Name
File name or wildcard pattern to match. Defaults to `*`.

.PARAMETER Input
Pipeline input for file paths or objects with a `FullName`/`Name` property.

.PARAMETER Content
Regular expression patterns to match inside file contents (when applicable).

.PARAMETER RelativeBasePath
Base path used to resolve relative paths in output; defaults to the current
directory.

.PARAMETER Category
Optional filter to include only files that belong to selected categories.

.PARAMETER MaxDegreeOfParallelism
Maximum parallel directory operations. `0` means automatic.

.PARAMETER TimeoutSeconds
Optional timeout in seconds for the search operation.

.PARAMETER AllDrives
Switch to search across all mounted drives.

.PARAMETER Directory
Only search for directories instead of files.

.PARAMETER FilesAndDirectories
Include both files and directories in search results.

.PARAMETER PassThru
Output matched items as objects instead of formatted text.

.PARAMETER IncludeAlternateFileStreams
Include alternate data streams (ADS) in the search results.

.PARAMETER NoRecurse
Do not recurse into subdirectories when searching.

.PARAMETER FollowSymlinkAndJunctions
Follow symbolic links and junctions during traversal.

.PARAMETER IncludeOpticalDiskDrives
Include optical disks when enumerating drives.

.PARAMETER SearchDrives
Explicit list of drive root paths to search.

.PARAMETER DriveLetter
List of drive letters to search.

.PARAMETER Root
Base directories to combine with `Name` patterns when searching.

.PARAMETER LimitToRoot
When used, restricts matches to provided `Root` directories and prevents
escaping above them.

.PARAMETER IncludeNonTextFileMatching
Allow content matching against non-text files (binary/media) when doing
content search.

.PARAMETER NoLinks
Operate in unattended mode; do not generate links or interactive prompts.

.PARAMETER CaseNameMatching
Controls case-sensitivity for file name matching.

.PARAMETER SearchADSContent
When set, also search within alternate data streams (ADS) contents.

.PARAMETER MaxRecursionDepth
Maximum directory recursion depth; `0` means unlimited.

.PARAMETER MaxSearchUpDepth
Maximum upward search depth when performing relative searches.

.PARAMETER MaxFileSize
Maximum file size in bytes to include; `0` means unlimited.

.PARAMETER MinFileSize
Minimum file size in bytes to include; `0` means no minimum.

.PARAMETER ModifiedAfter
Only include items modified after this UTC date/time.

.PARAMETER ModifiedBefore
Only include items modified before this UTC date/time.

.PARAMETER AttributesToSkip
File attributes to exclude from results (for example `System`).

.PARAMETER Exclude
Wildcard patterns to exclude files or directories from the search.

.PARAMETER AllMatches
Return all matches per line when using content pattern matching.

.PARAMETER CaseSensitive
Make content pattern matches case-sensitive.

.PARAMETER Context
Capture context lines around found content matches.

.PARAMETER Culture
Culture name used for pattern matching when using `SimpleMatch`.

.PARAMETER Encoding
File encoding to use for content operations.

.PARAMETER List
Only the first match per file is returned (efficient list mode).

.PARAMETER NoEmphasis
Disable highlighting in output.

.PARAMETER NotMatch
Return files that do not match the provided content pattern.

.PARAMETER Raw
Output only matching strings instead of `MatchInfo` objects.

.PARAMETER SimpleMatch
Use simple string matching (not regular expressions) for content matching.

.PARAMETER ComparePartial
Will return of files with different sizes as long as they start with the same filename and content, this detect broken downloads/copy operations

.PARAMETER CompareByteLength
Quick compare byte length of files, used for fast indexing and searching of duplicates, this will not compare content of files

.EXAMPLE
Find duplicate text files in the Documents folder based on exact content:
Find-DuplicateFiles ~\Documents\*.doc* -ComparePartial

.EXAMPLE
Removes all duplicate media files in the Pictures and Videos folders, keeping only one copy of each duplicate set:
(Find-DuplicateFiles ~\Pictures\*, ~\Videos\* -Category Pictures, Videos -ComparePartial).Duplicates.FullName | Remove-Item -Force -Verbose

#>
function Find-DuplicateFiles {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias('fdf')]

    param(
        ########################################################################
        [Parameter(Position = 1, Mandatory = $false, HelpMessage = 'File name or pattern to search for. Default is ''*''')]
        [SupportsWildcards()]
        [Alias("SourceFolder")]
        [ValidateNotNullOrEmpty()]
        [string[]] $Name = @('*'),
        ########################################################################
        [Parameter(Mandatory = $false, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true, HelpMessage = 'File name or pattern to search for from pipeline input. Default is ''*''')]
        [Alias('FullName')]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [object] $Input,
        ########################################################################
        [Parameter(Position = 2, Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'Regular expression pattern to search within content')]
        [Alias('mc', 'matchcontent', 'regex', 'Pattern')]
        [ValidateNotNull()]
        [SupportsWildcards()]
        [string[]] $Content = @('.*'),
        ########################################################################
        [Parameter(Position = 3, Mandatory = $false, HelpMessage = 'Base path for resolving relative paths in output')]
        [Alias('base')]
        [ValidateNotNullOrEmpty()]
        [string] $RelativeBasePath = '.\',
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Only output files belonging to selected categories')]
        [Alias('filetype')]
        [ValidateSet(
            'Pictures',
            'Videos',
            'Music',
            'Documents',
            'Spreadsheets',
            'Presentations',
            'Archives',
            'Installers',
            'Executables',
            'Databases',
            'DesignFiles',
            'Ebooks',
            'Subtitles',
            'Fonts',
            'EmailFiles',
            '3DModels',
            'GameAssets',
            'MedicalFiles',
            'FinancialFiles',
            'LegalFiles',
            'SourceCode',
            'Scripts',
            'MarkupAndData',
            'Configuration',
            'Logs',
            'TextFiles',
            'WebFiles',
            'MusicLyricsAndChords',
            'CreativeWriting',
            'Recipes',
            'ResearchFiles'
        )]
        [string[]] $Category,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Maximum degree of parallelism for directory tasks')]
        [Alias('threads')]
        [int] $MaxDegreeOfParallelism = 0,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Optional: cancellation timeout in seconds')]
        [Alias('maxseconds')]
        [int] $TimeoutSeconds,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Search across all available drives')]
        [switch] $AllDrives,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Search for directories only')]
        [Alias('dir')]
        [switch] $Directory,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Include both files and directories')]
        [Alias('both', 'DirectoriesAndFiles')]
        [switch] $FilesAndDirectories,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Output matched items as objects')]
        [Alias('pt')]
        [switch] $PassThru,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Include alternate data streams in search results')]
        [Alias('ads')]
        [switch] $IncludeAlternateFileStreams,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Do not recurse into subdirectories')]
        [Alias('nr')]
        [switch] $NoRecurse,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Follow symlinks and junctions during directory traversal')]
        [Alias('symlinks', 'sl')]
        [switch] $FollowSymlinkAndJunctions,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Include optical disk drives')]
        [switch] $IncludeOpticalDiskDrives,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Optional: search specific drives')]
        [Alias('drives')]
        [string[]] $SearchDrives = @(),
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Optional: search specific drives')]
        [char[]] $DriveLetter = @(),
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Optional: search specific directories')]
        [string[]] $Root = @(),
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Enforces searching only within Root directories by stripping directory components from Name inputs')]
        [Alias('limit')]
        [switch] $LimitToRoot,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Include non-text files when searching file contents')]
        [Alias('binary')]
        [switch] $IncludeNonTextFileMatching,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Forces unattended mode and will not generate links')]
        [Alias('nl', 'ForceUnattenedMode')]
        [switch] $NoLinks,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Gets or sets the case-sensitivity for files and directories')]
        [Alias('casing', 'CaseSearchMaskMatching')]
        [System.IO.MatchCasing] $CaseNameMatching = [System.IO.MatchCasing]::PlatformDefault,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'When set, performs content search within alternate data streams (ADS)')]
        [Alias('sads')]
        [switch] $SearchADSContent,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Maximum recursion depth for directory traversal. 0 means unlimited.')]
        [Alias('md', 'depth', 'maxdepth')]
        [int] $MaxRecursionDepth = 0,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Maximum recursion depth for continuation searching upwards the tree. 0 means disabled.')]
        [Alias('maxupward')]
        [int] $MaxSearchUpDepth = 0,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Maximum file size in bytes to include in results. 0 means unlimited.')]
        [Alias('maxlength', 'maxsize')]
        [long] $MaxFileSize = 0,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Minimum file size in bytes to include in results. 0 means no minimum.')]
        [Alias('minsize', 'minlength')]
        [long] $MinFileSize = 0,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Only include files modified after this date/time (UTC)')]
        [Alias('ma', 'after')]
        [DateTime] $ModifiedAfter,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Only include files modified before this date/time (UTC)')]
        [Alias('before', 'mb')]
        [DateTime] $ModifiedBefore,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'File attributes to skip (e.g., System, Hidden or None)')]
        [Alias('skipattr')]
        [System.IO.FileAttributes] $AttributesToSkip = [System.IO.FileAttributes]::System,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Exclude files or directories matching these wildcard patterns')]
        [Alias('skiplike')]
        [string[]] $Exclude = @('*\.git\*'),
        ########################################################################
        [Parameter(Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'Search for more than one match in each line of text')]
        [switch] $AllMatches,
        ########################################################################
        [Parameter(Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'Matches are case-sensitive')]
        [switch] $CaseSensitive,
        ########################################################################
        [Parameter(Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'Captures context lines around matches')]
        [int[]] $Context,
        ########################################################################
        [Parameter(Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'Culture name used for pattern matching')]
        [string] $Culture,
        ########################################################################
        [Parameter(Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'Specifies encoding for target files')]
        [ValidateSet('ASCII', 'ANSI', 'BigEndianUnicode', 'BigEndianUTF32', 'OEM', 'Unicode', 'UTF7', 'UTF8', 'UTF8BOM', 'UTF8NoBOM', 'UTF32', 'Default')]
        [string] $Encoding = 'UTF8NoBOM',
        ########################################################################
        [Parameter(Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'Only the first match per file is returned')]
        [switch] $List,
        ########################################################################
        [Parameter(Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'Disables highlighting of matching strings in output')]
        [switch] $NoEmphasis,
        ########################################################################
        [Parameter(Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'The NotMatch parameter finds text that does not match the pattern')]
        [switch] $NotMatch,
        ########################################################################
        [Parameter(Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'Output only matching strings instead of MatchInfo objects')]
        [switch] $Raw,
        ########################################################################
        [Parameter(Mandatory = $false, ParameterSetName = 'WithPattern', HelpMessage = 'Use simple string matching instead of regex')]
        [switch] $SimpleMatch,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will return of files with different sizes as long as they start with the same filename and content, this detect broken downloads/copy operations'
        )]
        [switch] $ComparePartial,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Quick compare byte length of files, used for fast indexing and searching of duplicates, this will not compare content of files'
        )]
        [int] $CompareByteLength = 65536
    )

    begin {

        $CompareByteLength = [Math]::Max(1, $CompareByteLength)

        $params = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Find-Item' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        $foundFiles = @{}

        [byte[]] $hashBuffer = Microsoft.PowerShell.Utility\New-Object byte[] $CompareByteLength
        [System.Security.Cryptography.SHA256] $sha256 = [System.Security.Cryptography.SHA256]::Create()
    }

    process {

        Microsoft.PowerShell.Utility\Write-Progress -Id 1 -Activity "Finding duplicates" -Status "Enumerating files..." -PercentComplete 0

        GenXdev\Find-Item @params -PassThru -Quiet -ProgressAction Continue | Microsoft.PowerShell.Core\ForEach-Object -ErrorAction Continue {

            $item = $_

            $QuickHash = [string]::Empty

            if ($item.Length -gt 0) {
                try {
                    $fileStream = $item.OpenRead()
                    $readLength = $fileStream.Read($hashBuffer, 0, $CompareByteLength)
                    $null = $sha256.Initialize()
                    $sha256Bytes = $sha256.ComputeHash($hashBuffer, 0, $readLength)
                    $QuickHash = [BitConverter]::ToString($sha256Bytes).Replace('-', '')
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning "Failed to compute hash for file '$($item.FullName)': $_"
                    return
                }
                finally {
                    if ($fileStream) {
                        $null = $fileStream.Close()
                        $null = $fileStream.Dispose()
                        $fileStream = $null
                    }
                }
            }

            $key = $QuickHash -eq "" ? [IO.Path]::GetFileNameWithoutExtension($item.Name).ToLowerInvariant() : $QuickHash

            if (-not $foundFiles.ContainsKey($key)) {

                $foundFiles[$key] = @()
            }

            $foundFiles[$key] += [PSCustomObject]@{

                FullName      = $item.FullName
                Name          = $item.Name
                Size          = $item.Length
                Extension     = $item.Extension
                LastWriteTime = $item.LastWriteTimeUtc
            }
        }
    }

    end {

        function Compare-ByteArraysFast ([byte[]]$array1, [byte[]]$array2) {

            # Quick reference check and length check first
            if ($array1.Length -ne $array2.Length) { return $false }

            # Use LINQ SequenceEqual for byte array comparison
            # MemoryExtensions requires Span<T> which is ByRef-like and not supported in PowerShell
            return [System.Linq.Enumerable]::SequenceEqual($array1, $array2)
        }

        [byte[]] $compareBuffer1 = Microsoft.PowerShell.Utility\New-Object byte[] (1024 * 1024)
        [byte[]] $compareBuffer2 = Microsoft.PowerShell.Utility\New-Object byte[] (1024 * 1024)

        $i = 0
        foreach ($group in $foundFiles.GetEnumerator()) {

            if ($i % 20 -eq 0) {

                Microsoft.PowerShell.Utility\Write-Progress -Id 1 -Activity "Finding duplicates" -Status "Processing group $($i + 1) of $($foundFiles.Count)" -PercentComplete ([math]::Round((($i + 1) / $foundFiles.Count) * 100, 2))
            }

            if ($group.Value.Count -gt 1) {

                $groups = @($group.Value | Microsoft.PowerShell.Utility\Sort-Object -Property @{Expression = 'Size'; Descending = $true }, @{Expression = 'LastWriteTime'; Descending = $false })

                $first = $groups[0]
                $hash = [string]::Empty

                Microsoft.PowerShell.Utility\Write-Progress -Id 1 -Activity "Finding duplicates" -Status "Processing file $($first.Name)" -PercentComplete ([math]::Round((($i + 1) / $foundFiles.Count) * 100, 2))

                try {
                    $hash = Microsoft.PowerShell.Utility\Get-FileHash -LiteralPath $first.FullName -Algorithm SHA256
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning "Failed to compute hash for original file '$($first.FullName)': $_"
                    continue
                }

                $duplicates = @($groups | Microsoft.PowerShell.Utility\Select-Object -Skip 1 | Microsoft.PowerShell.Core\ForEach-Object -erroraction Continue {

                        if ($ComparePartial -and ($_.Size -ne $first.Size)) {

                            try {

                                $fileStream1 = (Microsoft.PowerShell.Management\Get-Item -LiteralPath $_.FullName -Force).OpenRead()
                                $fileStream2 = (Microsoft.PowerShell.Management\Get-Item -LiteralPath $first.FullName -Force).OpenRead()

                                $bytesRead1 = 0
                                do {

                                    $bytesRead1 = $fileStream1.Read($compareBuffer1, 0, $compareBuffer1.Length)

                                    if ($bytesRead1 -eq 0) {
                                        break
                                    }

                                    $bytesRead2 = $fileStream2.Read($compareBuffer2, 0, $bytesRead1)

                                    if ($bytesRead2 -ne $bytesRead1) {
                                        return;
                                    }

                                    if ($bytesRead1 -eq $compareBuffer1.Length) {
                                        $segment1 = $compareBuffer1
                                        $segment2 = $compareBuffer2
                                    }
                                    else {
                                        $segment1 = $compareBuffer1[0..($bytesRead1 - 1)]
                                        $segment2 = $compareBuffer2[0..($bytesRead1 - 1)]
                                    }

                                    if (-not (Compare-ByteArraysFast $segment1 $segment2)) {
                                        return
                                    }

                                } while ($bytesRead1 -gt 0)

                                $_
                            }
                            catch {
                                Microsoft.PowerShell.Utility\Write-Warning "Failed to compare files '$($_.FullName)' and '$($first.FullName)': $_"
                                return
                            }
                            finally {

                                if ($fileStream1) {

                                    $null = $fileStream1.Close()
                                    $null = $fileStream1.Dispose()
                                    $fileStream1 = $null
                                }

                                if ($fileStream2) {

                                    $null = $fileStream2.Close()
                                    $null = $fileStream2.Dispose()
                                    $fileStream2 = $null
                                }
                            }
                        }
                        else {
                            try {
                                $duplicateHash = Microsoft.PowerShell.Utility\Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256
                            }
                            catch {
                                Microsoft.PowerShell.Utility\Write-Warning "Failed to compute hash for file '$($_.FullName)': $_"
                                $null = $fileStream1.Close()
                                $null = $fileStream1.Dispose()
                                $fileStream1 = $null
                                return
                            }

                            if ($hash.Hash -eq $duplicateHash.Hash) {
                                $_
                            }
                        }
                    })

                if ($duplicates.Count -gt 0) {

                    Microsoft.PowerShell.Utility\Write-Output ([PSCustomObject] @{

                            OriginalFile = $first
                            Duplicates   = $duplicates
                        })
                }
            }

            $i++
        }

        if ($sha256) {

            $null = $sha256.Dispose()
            $sha256 = $null
        }
    }
}