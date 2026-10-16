# Don't remove this line [dontrefactor]
###############################################################################
<#
.SYNOPSIS
Adds a line to a README.md markdown file in a specified section.

.DESCRIPTION
Finds and modifies a README.md file by adding a new line to a specified section.
Can create the section if it doesn't exist. Supports formatting lines as code
blocks and showing the modified section.

Will look in current directory first, then walk up directories to find the README
location. If not found, will use the README in the PowerShell profile directory.

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

.PARAMETER Line
The line of text to add to the README file.

.PARAMETER Section
The section header where the line should be added.

.PARAMETER Code
Switch to open the README in Visual Studio Code after modification.

.PARAMETER Show
Switch to display the modified section after changes.

.PARAMETER Done
Switch to mark a todo item as completed.

.PARAMETER Priority
Line priority for sorting within the section. Higher values appear first.
Defaults to 1. Negative values allowed.

.PARAMETER SortByDate
Sort lines by date (yyyyMMdd prefix) instead of priority.

.PARAMETER Ascending
Reverse the sort order. By default, higher priority/newer dates appear first.

.PARAMETER First
Limit the -Show output to the first N lines. Does not affect file storage.

.PARAMETER UseHomeREADME
Switch to use README in PowerShell profile directory.

.PARAMETER UseOneDriveREADME
Switch to use README in OneDrive directory.

.EXAMPLE
Add-LineToREADME -Line "New feature" -Section "## Features"

.EXAMPLE
Add-LineToREADME "High prio item" "## Issues" -Priority 5
#>
function Add-LineToREADME {

    [CmdletBinding()]
    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromRemainingArguments = $false,
            HelpMessage = 'The line to add to the README'
        )]
        [string] $Line = '',

        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The section to add the line to'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Section,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in Visual Studio Code after modifying'
        )]
        [switch] $Code,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the modified section'
        )]
        [switch] $Show,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Mark the item as completed'
        )]
        [switch] $Done,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use README in PowerShell profile directory'
        )]
        [switch] $UseHomeREADME,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use README in OneDrive directory'
        )]
        [switch] $UseOneDriveREADME,

        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'Priority for sorting (higher = shown first, default 1)'
        )]
        [int] $Priority = 1,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sort lines by date (yyyyMMdd prefix) instead of priority'
        )]
        [switch] $SortByDate,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Reverse the sort order (ascending instead of descending)'
        )]
        [switch] $Ascending,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Limit -Show output to the first N lines'
        )]
        [int] $First = 0,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show only completed (☒) items when used with -Show'
        )]
        [switch] $OnlyCompleted,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Exclude completed (☒) items when used with -Show'
        )]
        [switch] $ExcludeCompleted,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Archive completed items from this section'
        )]
        [switch] $ArchiveCompleted,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'File path for archiving completed items externally'
        )]
        [string] $ArchiveFilePath
    )

    begin {

        # helper function to find readme path by walking up directories
        function findReadMePath([string] $startDir) {

            $startDir = GenXdev\Expand-Path $startDir
            Microsoft.PowerShell.Management\Push-Location -LiteralPath $startDir

            try {
                # walk up directories looking for README.md
                $currentDir = (Microsoft.PowerShell.Management\Get-Location).Path
                while ($true) {
                    if ([System.IO.File]::Exists("$currentDir\README.md")) {
                        return "$currentDir\README.md"
                    }

                    # Get parent directory
                    $parent = GenXdev\Expand-Path "$currentDir\..\"

                    # Stop if we're at the root (parent equals current)
                    if ($parent -eq $currentDir) {
                        break
                    }

                    # Move up to parent
                    $currentDir = $parent
                }
            }
            finally {
                Microsoft.PowerShell.Management\Pop-Location
            }

            # fallback to onedrive readme
            return "$((GenXdev\Expand-Path -FilePath "$(GenXdev\Get-KnownFolderPath -KnownFolder 'OneDrive')\README.md" -CreateDirectory))";
        }

        # returns the dominant line ending used by the file content
        function DetectLineEnding([string] $text) {

            $crlf = ([regex]::Matches($text, "`r`n")).Count
            $lf = ([regex]::Matches($text, "`n")).Count - $crlf
            $cr = ([regex]::Matches($text, "`r")).Count - $crlf

            if ($crlf -ge $lf -and $crlf -ge $cr) { return "`r`n" }
            if ($lf -ge $cr) { return "`n" }
            return "`r"
        }

        # true when the file starts with a UTF-8 byte order mark
        function HasByteOrderMark([string] $path) {

            $stream = [IO.File]::OpenRead($path)
            try {
                if ($stream.Length -lt 3) { return $false }
                $bytes = [byte[]]::new(3)
                $null = $stream.Read($bytes, 0, 3)
                return ($bytes[0] -eq 0xEF -and $bytes[1] -eq 0xBB -and
                    $bytes[2] -eq 0xBF)
            }
            finally { $stream.Dispose() }
        }

        # marks every line that sits inside a fenced code block so that
        # lookalike headings and items inside code are never interpreted
        # as document structure
        function GetFenceMask([string[]] $lines) {

            $mask = [bool[]]::new($lines.Count)
            $openChar = ''
            $openLen = 0

            for ($i = 0; $i -lt $lines.Count; $i++) {

                if ($openChar -eq '') {
                    $m = [regex]::Match($lines[$i], '^\s{0,3}(`{3,}|~{3,})')
                    if ($m.Success) {
                        $openChar = $m.Groups[1].Value.Substring(0, 1)
                        $openLen = $m.Groups[1].Value.Length
                        $mask[$i] = $true
                    }
                    continue
                }

                $mask[$i] = $true
                $close = '^\s{0,3}' + [regex]::Escape($openChar) +
                '{' + $openLen + ',}\s*$'
                if ([regex]::IsMatch($lines[$i], $close)) {
                    $openChar = ''
                    $openLen = 0
                }
            }

            return , $mask
        }

        # a line that starts a README item
        function IsItemHeader([string] $line) {
            return ($line -match '^- (☐|☒)')
        }

        # markdown heading level of a line, or 0 when it is not a heading
        function GetHeadingLevel([string] $line) {
            $m = [regex]::Match($line, '^(#{1,6})\s*\S')
            if ($m.Success) { return $m.Groups[1].Value.Length }
            return 0
        }

        # section headings managed by these cmdlets
        function IsKnownSection([string] $line) {
            return ($line -match '^##\s+(Features|Issues|Todoos|Ideas|' +
                'Release notes)(\s+-\s+Archive)?\s*$')
        }

        # locates the exact heading line for a section name
        function FindSectionBounds(
            [string[]] $lines, [bool[]] $fence, [string] $section) {

            $wanted = $section.Trim()
            for ($i = 0; $i -lt $lines.Count; $i++) {
                if ($fence[$i]) { continue }
                if ($lines[$i].Trim() -ieq $wanted) {
                    return @{ Heading = $i; Start = $i + 1 }
                }
            }
            return $null
        }

        # first line index that no longer belongs to the section
        function FindSectionEnd(
            [string[]] $lines, [bool[]] $fence, [int] $start, [int] $level) {

            for ($i = $start; $i -lt $lines.Count; $i++) {

                if ($fence[$i]) { continue }
                $headingLevel = GetHeadingLevel $lines[$i]
                if ($headingLevel -lt 1 -or $headingLevel -gt $level) { continue }

                # a heading that follows a blank line always ends the section
                # and so does one that is followed by a blank line; a heading
                # glued into the middle of item text is part of that item
                # unless it is one of the known section headings
                $separated = ($i -eq 0) -or
                [string]::IsNullOrWhiteSpace($lines[$i - 1])
                $followedByBlank = ($i -ge $lines.Count - 1) -or
                [string]::IsNullOrWhiteSpace($lines[$i + 1])
                if ($separated -or $followedByBlank -or
                    (IsKnownSection $lines[$i].Trim())) {
                    return $i
                }
            }
            return $lines.Count
        }

        # groups section lines into atomic blocks: an item header plus all of
        # its continuation lines, so a multi line item can never be shredded
        function ParseBlocks(
            [string[]] $lines, [bool[]] $fence, [int] $start, [int] $end) {

            $blocks = [System.Collections.Generic.List[object]]::new()
            $current = $null

            for ($i = $start; $i -lt $end; $i++) {

                $startsItem = (-not $fence[$i]) -and (IsItemHeader $lines[$i])
                if ($startsItem -or $null -eq $current) {
                    $current = [pscustomobject]@{
                        Lines = [System.Collections.Generic.List[string]]::new()
                    }
                    $null = $blocks.Add($current)
                }
                $null = $current.Lines.Add($lines[$i])
            }

            return , $blocks
        }

        # sort key of a block, taken from its header line
        function BlockSortKey($block, [bool] $sortByDate, [bool] $ascending) {

            $header = $block.Lines[0]

            if ($sortByDate) {
                if ($header -match '(\d{8})\s*-->') { return $Matches[1] }
                if ($ascending) { return '00000000' }
                return '99999999'
            }

            if ($header -match '\[P(-?\d+)\]') { return [int]$Matches[1] }
            return 0
        }

        # sorts whole blocks on their header key, keeping ties in order
        function SortBlocks($blocks, [bool] $sortByDate, [bool] $ascending) {

            $sorted = $blocks |
            Microsoft.PowerShell.Utility\Sort-Object {
                BlockSortKey $_ $sortByDate $ascending
            } -Descending:(-not $ascending) -Stable

            return , @($sorted)
        }

        # flattens blocks back into a list of lines
        function FlattenBlocks($blocks) {

            $flat = [System.Collections.Generic.List[string]]::new()
            foreach ($block in $blocks) {
                foreach ($ln in $block.Lines) { $null = $flat.Add($ln) }
            }
            return , $flat
        }

        # determine which readme file to use
        if ($UseHomeREADME) {
            $readmePath = GenXdev\Expand-Path `
                -FilePath "$([IO.Path]::GetDirectoryName($Profile))\README.md"
        }
        elseif ($UseOneDriveREADME) {
            $readmePath = GenXdev\Expand-Path `
                -FilePath "$(GenXdev\Get-KnownFolderPath -KnownFolder 'OneDrive')\README.md" `
                -CreateDirectory
        }
        else {
            $readmePath = findReadMePath $PWD
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Using README at: $readmePath"

        # verify readme exists
        if (![IO.File]::Exists($readmePath)) {
            throw "README file not found at: $readmePath"
        }

        # load readme content, remembering line endings and byte order mark
        $readme = [IO.File]::ReadAllText($readmePath)
        $lineEnding = DetectLineEnding $readme
        [bool] $hasBom = HasByteOrderMark $readmePath

        # work on logical lines so CRLF, LF and CR files all behave the same
        [System.Collections.Generic.List[string]] $lines =
        [System.Collections.Generic.List[string]]::new()
        foreach ($ln in ($readme -split "`r`n|`n|`r")) { $null = $lines.Add($ln) }

        # code inside fences is never treated as document structure
        [bool[]] $fence = GetFenceMask $lines
        [int] $insertedCount = 0

        # Migrate existing lines to unified emoji prefix format
        # Converts old prefixes (- [X], - [☒], - [ ], * ) to - ☐ / - ☒
        # and adds [P1] priority if missing
        function MigrateReadmeLines(
            [System.Collections.Generic.List[string]] $lines,
            [bool[]] $fence, [string] $lf) {

            $knownSections = @(
                '## Features', '## Ideas', '## Issues',
                '## Todoos', '## Release notes'
            )
            $migrated = $false

            foreach ($sec in $knownSections) {

                $bounds = FindSectionBounds $lines $fence $sec
                if ($null -eq $bounds) { continue }

                $secLevel = ($sec -replace '^([#]+).*$', '$1').Length
                $end = FindSectionEnd $lines $fence $bounds.Start $secLevel

                for ($i = $bounds.Start; $i -lt $end; $i++) {

                    # never rewrite code, nor the inside of an item
                    if ($fence[$i]) { continue }
                    $ln = $lines[$i]
                    if ([string]::IsNullOrWhiteSpace($ln)) { continue }
                    if ($ln -match '^- (☐|☒) \[P') { continue }

                    $existingPrio = if ($ln -match '\[P(-?\d+)\]') {
                        "[P$($matches[1])]"
                    } else { '[P1]' }

                    $restText = $ln
                    $replacement = $null

                    if ($ln -match '^- \[X\] ') {
                        $restText = ($ln -replace '^- \[X\] ', '') -replace '\[P-?\d+\] ', ''
                        $replacement = "- ☒ $existingPrio $restText"
                    }
                    elseif ($ln -match '^- \[☒\] ') {
                        $restText = ($ln -replace '^- \[☒\] ', '') -replace '\[P-?\d+\] ', ''
                        $replacement = "- ☒ $existingPrio $restText"
                    }
                    elseif ($ln -match '^- \[ \] ') {
                        $restText = ($ln -replace '^- \[ \] ', '') -replace '\[P-?\d+\] ', ''
                        $replacement = "- ☐ $existingPrio $restText"
                    }
                    elseif ($ln -match '^- ☐ ') {
                        $restText = ($ln -replace '^- ☐ ', '') -replace '\[P-?\d+\] ', ''
                        $replacement = "- ☐ $existingPrio $restText"
                    }
                    elseif ($ln -match '^\* ') {
                        $restText = ($ln -replace '^\* ', '') -replace '\[P-?\d+\] ', ''
                        $replacement = "- ☐ $existingPrio $restText"
                    }

                    if ($null -ne $replacement -and $replacement -cne $ln) {
                        $lines[$i] = $replacement
                        $migrated = $true
                    }
                }
            }

            return $migrated
        }

        # content changed in-memory and must be persisted to disk
        [bool] $mutated = MigrateReadmeLines $lines $fence $lineEnding

        # -OnlyCompleted and -ExcludeCompleted are mutually exclusive
        if ($OnlyCompleted -and $ExcludeCompleted) {
            throw '-OnlyCompleted and -ExcludeCompleted are mutually exclusive.' +
            ' Use one or neither.'
        }

        [int] $sectionLevel =
        ($Section.Trim() -replace '^([#]+).*$', '$1').Length

        # resolve the real heading; never one that sits inside a code fence
        if ($null -eq (FindSectionBounds $lines $fence $Section)) {

            if ($lines.Count -gt 0 -and
                ![string]::IsNullOrWhiteSpace($lines[$lines.Count - 1])) {
                $null = $lines.Add('')
            }
            $null = $lines.Add($Section.Trim())
            $fence = GetFenceMask $lines
        }
    }

    process {

        # an empty line means "display or archive only"
        if ([string]::IsNullOrWhiteSpace($Line)) { return }

        # resolve the section for every pipeline item, an earlier item of the
        # same pipeline may have created it
        $bounds = FindSectionBounds $lines $fence $Section
        if ($null -eq $bounds) {
            Microsoft.PowerShell.Utility\Write-Warning `
                "Section '$Section' not found"
            return
        }
        $sectionEnd = FindSectionEnd $lines $fence $bounds.Start $sectionLevel

        if ($Done) {
            # only item headers are matched, so continuation lines of a multi
            # line item are never touched and the item stays intact
            $searchPattern = '- ☐ *' + $Line
            $literalPattern = '- ☐ *' +
            [System.Management.Automation.WildcardPattern]::Escape($Line)
            $found = $false
            $matchCount = 0

            for ($i = $bounds.Start; $i -lt $sectionEnd; $i++) {

                if ($fence[$i]) { continue }
                if (-not (IsItemHeader $lines[$i])) { continue }

                # user text may contain wildcard characters such as "byte[]"
                # or "?"; fall back to a literal match when that happens
                $isMatch = $false
                try { $isMatch = $lines[$i] -like $searchPattern }
                catch { $isMatch = $false }
                if (-not $isMatch) {
                    $isMatch = $lines[$i] -like $literalPattern
                }
                if (-not $isMatch) { continue }

                $matchCount++
                $found = $true
                $lines[$i] = $lines[$i].Replace('☐', '☒')
            }

            if (-not $found) {
                Microsoft.PowerShell.Utility\Write-Warning ("No line matching '" +
                    $Line + "' found in section '$Section'")
            }
            elseif ($matchCount -gt 1) {
                Microsoft.PowerShell.Utility\Write-Warning ("$matchCount lines matched '" +
                    $Line + "' in section '$Section'")
            }

            if ($found) { $mutated = $true }
            return
        }

        # duplicate detection compares whole item headers
        $dupLine = "- ☐ [P$Priority] $Line"
        for ($i = $bounds.Start; $i -lt $sectionEnd; $i++) {
            if ($lines[$i] -ceq $dupLine) {
                Microsoft.PowerShell.Utility\Write-Warning ("Duplicate line '$Line' in " +
                    "section '$Section'")
                return
            }
        }

        # insert after the heading; extra lines of a multi line paste become
        # continuation lines that belong to this item
        $newItemLines = $Line -split "`r`n|`n|`r"
        $insertAt = $bounds.Start + $insertedCount
        $lines.Insert($insertAt, "- ☐ [P$Priority] " + $newItemLines[0])
        for ($k = 1; $k -lt $newItemLines.Count; $k++) {
            $lines.Insert($insertAt + $k, $newItemLines[$k])
        }
        $insertedCount += $newItemLines.Count
        $fence = GetFenceMask $lines
        $mutated = $true
    }

    end {

        $bounds = FindSectionBounds $lines $fence $Section
        $sectionEnd = if ($null -ne $bounds) {
            FindSectionEnd $lines $fence $bounds.Start $sectionLevel
        }
        else { 0 }

        # Archive completed items if requested
        if ($ArchiveCompleted -and $null -ne $bounds) {

            $blocks = ParseBlocks $lines $fence $bounds.Start $sectionEnd
            $completed = [System.Collections.Generic.List[object]]::new()
            $remaining = [System.Collections.Generic.List[object]]::new()

            foreach ($block in $blocks) {
                if ((IsItemHeader $block.Lines[0]) -and
                    ($block.Lines[0] -match '^- ☒')) {
                    $null = $completed.Add($block)
                }
                else {
                    $null = $remaining.Add($block)
                }
            }

            if ($completed.Count -eq 0) {
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "No completed items found in section '$Section'")
            }
            else {
                $mutated = $true
                $datePrefix = [DateTime]::Now.ToString('yyyyMMdd')

                # the date prefix goes on the header line; continuation lines
                # of a multi line item move along untouched
                $archivedLines = [System.Collections.Generic.List[string]]::new()
                foreach ($block in $completed) {
                    $isHeader = $true
                    foreach ($ln in $block.Lines) {
                        if ($isHeader) {
                            $null = $archivedLines.Add(
                                ($ln -replace '^- (☒) ', "- `$1 $datePrefix --> "))
                            $isHeader = $false
                        }
                        else {
                            $null = $archivedLines.Add($ln)
                        }
                    }
                }

                # drop the completed blocks, keep the remaining ones intact
                $lines.RemoveRange($bounds.Start, $sectionEnd - $bounds.Start)
                $lines.InsertRange($bounds.Start, (FlattenBlocks $remaining))
                $fence = GetFenceMask $lines

                if (-not [string]::IsNullOrWhiteSpace($ArchiveFilePath)) {

                    # Archive to external file
                    $archivePath = GenXdev\Expand-Path `
                        -FilePath $ArchiveFilePath -CreateDirectory
                    $archiveHeader = "${lineEnding}### Archived from" +
                    " '$Section' on $datePrefix${lineEnding}"
                    [System.IO.File]::AppendAllText(
                        $archivePath,
                        $archiveHeader +
                        (($archivedLines -join $lineEnding) + $lineEnding)
                    )

                    # Migrate a previously used same-README archive section to
                    # the external file, then remove it from the README
                    $migrateSectionHeading = "$Section - Archive"
                    $prevBounds = FindSectionBounds $lines $fence `
                        $migrateSectionHeading
                    if ($null -ne $prevBounds) {
                        $prevEnd = FindSectionEnd $lines $fence `
                            $prevBounds.Start $sectionLevel
                        $prevContent = if ($prevEnd -gt $prevBounds.Start) {
                            @($lines[$prevBounds.Start..($prevEnd - 1)])
                        }
                        else { @() }

                        while ($prevContent.Count -gt 0 -and
                            [string]::IsNullOrWhiteSpace($prevContent[-1])) {
                            $prevContent = @($prevContent[0..($prevContent.Count - 2)])
                        }

                        if ($prevContent.Count -gt 0) {
                            $migrateHeader = "${lineEnding}### Migrated" +
                            " from '$migrateSectionHeading' on" +
                            " $datePrefix${lineEnding}"
                            [System.IO.File]::AppendAllText(
                                $archivePath,
                                $migrateHeader +
                                (($prevContent -join $lineEnding) + $lineEnding)
                            )
                        }

                        $lines.RemoveRange($prevBounds.Heading,
                            $prevEnd - $prevBounds.Heading)
                        $fence = GetFenceMask $lines
                    }
                }
                else {
                    # Move to a same-README archive section
                    $archiveSection = "$Section - Archive"
                    $archiveBounds = FindSectionBounds $lines $fence `
                        $archiveSection
                    if ($null -eq $archiveBounds) {
                        if ($lines.Count -gt 0 -and
                            ![string]::IsNullOrWhiteSpace($lines[$lines.Count - 1])) {
                            $null = $lines.Add('')
                        }
                        $null = $lines.Add($archiveSection)
                        $archiveBounds = @{
                            Heading = $lines.Count - 1
                            Start   = $lines.Count
                        }
                    }
                    $lines.InsertRange($archiveBounds.Start, $archivedLines)
                    $fence = GetFenceMask $lines
                }
            }
        }

        # sort whole blocks so a multi line item always moves as one unit
        if ($mutated -and !$Done) {
            $sortBounds = FindSectionBounds $lines $fence $Section
            if ($null -ne $sortBounds) {
                $sortEnd = FindSectionEnd $lines $fence $sortBounds.Start `
                    $sectionLevel
                $sortBlocks = ParseBlocks $lines $fence $sortBounds.Start $sortEnd
                $sorted = SortBlocks $sortBlocks $SortByDate.IsPresent `
                    $Ascending.IsPresent
                $lines.RemoveRange($sortBounds.Start,
                    $sortEnd - $sortBounds.Start)
                $lines.InsertRange($sortBounds.Start, (FlattenBlocks $sorted))
                $fence = GetFenceMask $lines
            }
        }

        # persist only when the underlying content actually changed
        if ($mutated) {
            $output = $lines -join $lineEnding
            if ($hasBom) { $output = [char]0xFEFF + $output }
            GenXdev\Write-TextFileAtomic -FilePath $readmePath -Data $output
        }

        # open in vscode if requested
        if ($Code) {
            GenXdev\VSCode $readmePath
        }

        # show modified section if requested
        if ($Show) {

            $showBounds = FindSectionBounds $lines $fence $Section
            $displayBlocks = if ($null -ne $showBounds) {
                $showEnd = FindSectionEnd $lines $fence $showBounds.Start `
                    $sectionLevel
                ParseBlocks $lines $fence $showBounds.Start $showEnd
            }
            else { @() }

            # Filter by completion status if requested
            if ($OnlyCompleted) {
                $displayBlocks = @($displayBlocks | Microsoft.PowerShell.Core\Where-Object {
                        (IsItemHeader $_.Lines[0]) -and ($_.Lines[0] -match '☒')
                    })
            }
            elseif ($ExcludeCompleted) {
                $displayBlocks = @($displayBlocks | Microsoft.PowerShell.Core\Where-Object {
                        -not ((IsItemHeader $_.Lines[0]) -and
                            ($_.Lines[0] -match '☒'))
                    })
            }

            $displayBlocks = SortBlocks $displayBlocks `
                $SortByDate.IsPresent $Ascending.IsPresent

            # Apply -First limit (only to output, not to the file)
            if ($First -gt 0 -and $displayBlocks.Count -gt $First) {
                $displayBlocks = @($displayBlocks[0..($First - 1)])
            }

            $ansiColorStart = [char]27 + '['
            $ansiColorYellow = "${ansiColorStart}33m"
            $ansiBackgroundColorBlue = "${ansiColorStart}44m"
            $ansiColorReset = "${ansiColorStart}0m"

            $renderedBlocks = foreach ($block in $displayBlocks) {
                $block.Lines -join "`r`n"
            }

            $sectionHeader = $Section.Trim("`r`n`t ")
            "$ansiBackgroundColorBlue${ansiColorYellow}${sectionHeader}${ansiColorReset}`r`n`r`n" +
            ($renderedBlocks -join "`r`n`r`n") + "`r`n`r`n"
        }
    }
}