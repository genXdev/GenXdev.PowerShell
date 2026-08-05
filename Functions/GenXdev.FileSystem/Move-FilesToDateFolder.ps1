<#
.SYNOPSIS
Moves files matching search criteria into date-based subfolders.

.DESCRIPTION
Searches for files using the same parameter set as `Find-Item` and moves each
matched file into a subfolder of `TargetFolder` based on the file's creation
or media date. The cmdlet supports content matching, drive-wide searches and
many filters. It can optionally delete empty source folders after moving.

Attempts several strategies to determine an accurate creation or capture
date for the specified file. strategies include reading image EXIF metadata,
parsing date/time information from filenames, and falling back to the file's
last-write time when no other reliable information is available.

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

.PARAMETER TargetFolder
The root path where matched files will be moved into date-based
subfolders. This parameter is required.

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

.PARAMETER DeleteEmptyDirs
When present, empty source folders (and empty parents) will be removed after
files are moved.

.PARAMETER TargetFolderNameDateSyntax
Controls the date folder format. Valid values: `Year + Month + Day`,
`Year + Month`, `Year`.

.EXAMPLE
Move all pictures and videos to the corresponsing Android Onedrive App Image backup folders
    Move-FilesToDateFolder -TargetFolder "$(folder OneDrive)\Pictures\Camera Roll" `
                           -SourceFolder ~\Pictures\*, "$(folder OneDrive)\*", ~\desktop\* `
                           -FollowSymlinkAndJunctions `
                           -DeleteEmptyDirs `
                           -Category 'Pictures', 'Videos' `
                           -Confirm:$false

.EXAMPLE
Move all jpg files from the current directory into date folders under
`D:\Archive` (dry run):

    Move-FilesToDateFolder -TargetFolder 'D:\Archive' -Name '*.jpg' -WhatIf

.EXAMPLE
Move all files across drives matching `*.mp4` into monthly folders and delete
empty source folders:

    Move-FilesToDateFolder -TargetFolder 'E:\Media\Videos' -Name '.\*.mp4' -DeleteEmptyDirs

#>
function Move-FilesToDateFolder {

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    param(
        ########################################################################
        [Parameter(Position = 0, Mandatory = $true, HelpMessage = 'Target root folder where matched files will be moved into date-based subfolders')]
        [ValidateNotNullOrEmpty()]
        [string] $TargetFolder,
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
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Delete empty source directories after moving files')]
        [switch] $DeleteEmptyDirs,
        ########################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Target folder name date syntax')]
        [ValidateSet(
            'Year + Month + Day',
            'Year + Month',
            'Year'
        )]
        [string] $TargetFolderNameDateSyntax = 'Year + Month'
        ########################################################################
    )

    begin {

        $params = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Find-Item' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        $sourceFolders = @{}
        $uniqueNameCounters = @{}
    }

    process {

        Microsoft.PowerShell.Utility\Write-Progress -Id 11 -Activity "Moving files to date folders" -Status "Enumerating files..." -PercentComplete 0

        GenXdev\Find-Item @params -PassThru -Quiet -ProgressAction Continue | Microsoft.PowerShell.Core\ForEach-Object -ErrorAction Continue {

            $item = $_
            $creationDate = GenXdev\Get-MediaFileCreationDate -FilePath $item.FullName

            if ($creationDate -ne [DateTime]::MinValue) {

                $dateFolderName = $creationDate.ToString('yyyy-MM-dd')
                switch ($TargetFolderNameDateSyntax) {
                    'Year + Month + Day' { $dateFolderName = $creationDate.ToString('yyyy-MM-dd') + "\" + $creationDate.ToString('MM') + "\" + $creationDate.ToString('dd') }
                    'Year + Month' { $dateFolderName = $creationDate.ToString('yyyy') + "\" + $creationDate.ToString('MM') }
                    'Year' { $dateFolderName = $creationDate.ToString('yyyy') }
                }

                $destinationPath = GenXdev\Expand-Path "$TargetFolder\$dateFolderName\$($item.Name)"

                if ($item.FullName -eq $destinationPath) {

                    return
                }

                if ([IO.File]::Exists($destinationPath)) {

                    # check file sizes
                    $existingFileSize = (Microsoft.PowerShell.Management\Get-Item -LiteralPath $destinationPath -Force).Length
                    $currentFileSize = $item.Length

                    if ($existingFileSize -ne $currentFileSize) {

                        $uniqueNo = 1;
                        if (-not $uniqueNameCounters.ContainsKey($destinationPath)) {

                            $uniqueNameCounters[$destinationPath] = $uniqueNo
                        }
                        else {

                            $uniqueNo = $uniqueNameCounters[$destinationPath] + 1;
                            $uniqueNameCounters[$destinationPath] = $uniqueNo;
                        }

                        $baseName = [IO.Path]::GetFileNameWithoutExtension($item.Name)
                        $extension = [IO.Path]::GetExtension($item.Name)
                        $newFileName = "$baseName ($($uniqueNo))$extension"
                        $destinationPath = GenXdev\Expand-Path "$TargetFolder\$dateFolderName\$newFileName" -CreateDirectory
                    }
                    else {

                        if ($PSCmdlet.ShouldProcess($item.FullName, "Delete already existing file: $($item.FullName)")) {

                            try {

                                Microsoft.PowerShell.Utility\Write-Verbose "Deleting already existing file: $($item.FullName)"
                                Microsoft.PowerShell.Management\Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop
                                if ($DeleteEmptyDirs) {

                                    $sourceFolders[$item.DirectoryName] = $true
                                }
                            }
                            catch {

                                Microsoft.PowerShell.Utility\Write-Warning "Failed to delete already existing file: $($item.FullName)"
                            }
                        }

                        return
                    }
                }

                if ($PSCmdlet.ShouldProcess($item.FullName, "Move to $destinationPath")) {
                    try {
                        $destinationPath = GenXdev\Expand-Path $destinationPath -CreateDirectory

                        Microsoft.PowerShell.Utility\Write-Verbose "Moving '$($item.FullName)' to '$destinationPath'"
                        Microsoft.PowerShell.Management\Move-Item -LiteralPath $item.FullName -Destination $destinationPath -Force -ErrorAction Stop

                        if ($DeleteEmptyDirs) {
                            $sourceFolders[$item.DirectoryName] = $true
                        }
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Warning "Move failed for '$($item.FullName)' -> '$destinationPath': $_"

                        # Fallback: try to copy the file and then remove the original
                        try {
                            if ($PSCmdlet.ShouldProcess($item.FullName, "Copy to $destinationPath")) {

                                Microsoft.PowerShell.Utility\Write-Verbose "Copying '$($item.FullName)' to '$destinationPath'"
                                Microsoft.PowerShell.Management\Copy-Item -LiteralPath $item.FullName -Destination $destinationPath -Force -ErrorAction Stop

                                try {
                                    Microsoft.PowerShell.Management\Remove-Item -LiteralPath $item.FullName -Force -ErrorAction Stop
                                    if ($DeleteEmptyDirs) {
                                        $sourceFolders[$item.DirectoryName] = $true
                                    }
                                }
                                catch {
                                    Microsoft.PowerShell.Utility\Write-Warning "Copied but failed to remove original '$($item.FullName)': $_"
                                }
                            }
                            else {
                                Microsoft.PowerShell.Utility\Write-Information "WhatIf: would copy '$($item.FullName)' to '$destinationPath'"
                            }
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Warning "Failed to copy '$($item.FullName)' to '$destinationPath': $_"
                        }
                    }
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Information "WhatIf: would move '$($item.FullName)' to '$destinationPath'"
                }
            }

        }
    }

    end {
        if ($DeleteEmptyDirs) {

            # Normalize root paths if LimitToRoot is set so we don't delete above them
            $normalizedRoots = @()
            if ($LimitToRoot -and $Root -and $Root.Count -gt 0) {
                foreach ($r in $Root) {
                    try {
                        $rp = Microsoft.PowerShell.Management\Resolve-Path -LiteralPath $r -ErrorAction SilentlyContinue
                        if ($rp) { $normalizedRoots += $rp.Path }
                    }
                    catch { }
                }
            }

            $sourceFolders.Keys | Microsoft.PowerShell.Core\ForEach-Object {
                $dirToCheck = $_
                while ($dirToCheck) {
                    if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $dirToCheck -PathType Container)) { break }

                    $children = Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath $dirToCheck -Force -ErrorAction SilentlyContinue
                    if ($children -and $children.Count -gt 0) { break }

                    # If LimitToRoot is used, do not delete above any configured root paths
                    if ($normalizedRoots.Count -gt 0) {
                        $underAnyRoot = $false
                        foreach ($rootPath in $normalizedRoots) {
                            if ($dirToCheck.StartsWith($rootPath, [System.StringComparison]::InvariantCultureIgnoreCase)) { $underAnyRoot = $true; break }
                        }
                        if (-not $underAnyRoot) { break }
                    }

                    if ($PSCmdlet.ShouldProcess($dirToCheck, 'Remove directory')) {
                        try {
                            Microsoft.PowerShell.Management\Remove-Item -LiteralPath $dirToCheck -Force -ErrorAction Stop
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Verbose "Failed to remove directory '$dirToCheck': $_"
                            break
                        }
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Information "WhatIf: would remove directory '$dirToCheck'"
                        break
                    }

                    $parent = Microsoft.PowerShell.Management\Split-Path -Parent $dirToCheck
                    if ([string]::IsNullOrWhiteSpace($parent)) { break }

                    # Stop if we've reached the drive root
                    $root = [System.IO.Path]::GetPathRoot($parent)
                    if ($parent -eq $root) { break }

                    $dirToCheck = $parent
                }
            }
        }

        Microsoft.PowerShell.Utility\Write-Progress -Id 12 -Activity "Moving files to date folders" -Status "Completed" -PercentComplete 100 -complete
    }
}