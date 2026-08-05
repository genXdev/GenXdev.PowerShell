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

        # load readme content and detect line endings
        $readme = [IO.File]::ReadAllText($readmePath)
        $lineEnding = if ($readme.IndexOf("`r`n") -ge 0) { "`r`n" } else { "`n" }

        # Migrate existing lines to unified emoji prefix format
        # Converts old prefixes (- [X], - [☒], - [ ], * ) to - ☐ / - ☒
        # and adds [P1] priority if missing
        function MigrateReadmeLines([ref] $readmeRef, [string] $lf) {
            $knownSections = @(
                '## Features', '## Ideas', '## Issues',
                '## Todoos', '## Release notes'
            )
            $content = $readmeRef.Value
            $migrated = $false

            foreach ($sec in $knownSections) {
                $secStart = $content.IndexOf(
                    $sec,
                    [System.StringComparison]::OrdinalIgnoreCase
                )
                if ($secStart -lt 0) { continue }

                $secContentStart = $secStart + $sec.Length + $lf.Length
                # Guard: if section header is the last content without a
                # trailing newline, skip — nothing to migrate
                if ($secContentStart -ge $content.Length) { continue }

                $secLevel = ($sec -replace '^([#]+).*$', '$1').Length
                $rest = $content.Substring($secContentStart)
                $nextHd = [regex]::Match($rest, "(?m)^#{1,$secLevel}\s")
                $secEnd = if ($nextHd.Success) {
                    $secContentStart + $nextHd.Index
                } else { $content.Length }

                $secLines = $content.Substring(
                    $secContentStart,
                    $secEnd - $secContentStart
                ) -split $lf

                $newLines = [System.Collections.Generic.List[string]]::new()
                foreach ($ln in $secLines) {
                    if ([string]::IsNullOrWhiteSpace($ln)) {
                        $null = $newLines.Add($ln)
                        continue
                    }
                    # Already in new format? Skip
                    if ($ln -match '^- (☐|☒) \[P') {
                        $null = $newLines.Add($ln)
                        continue
                    }
                    # Extract existing priority if present
                    $existingPrio = if ($ln -match '\[P(-?\d+)\]') {
                        "[P$($matches[1])]"
                    } else { '[P1]' }
                    # Strip any existing prefix
                    $restText = $ln
                    # Old completed patterns
                    if ($ln -match '^- \[X\] ') {
                        $restText = $ln -replace '^- \[X\] ', ''
                        $restText = $restText -replace '\[P-?\d+\] ', ''
                        $ln = "- ☒ $existingPrio $restText"
                        $migrated = $true
                    }
                    elseif ($ln -match '^- \[☒\] ') {
                        $restText = $ln -replace '^- \[☒\] ', ''
                        $restText = $restText -replace '\[P-?\d+\] ', ''
                        $ln = "- ☒ $existingPrio $restText"
                        $migrated = $true
                    }
                    # Old uncompleted patterns
                    elseif ($ln -match '^- \[ \] ') {
                        $restText = $ln -replace '^- \[ \] ', ''
                        $restText = $restText -replace '\[P-?\d+\] ', ''
                        $ln = "- ☐ $existingPrio $restText"
                        $migrated = $true
                    }
                    elseif ($ln -match '^- ☐ ') {
                        $restText = $ln -replace '^- ☐ ', ''
                        $restText = $restText -replace '\[P-?\d+\] ', ''
                        $ln = "- ☐ $existingPrio $restText"
                        $migrated = $true
                    }
                    elseif ($ln -match '^\* ') {
                        $restText = $ln -replace '^\* ', ''
                        $restText = $restText -replace '\[P-?\d+\] ', ''
                        $ln = "- ☐ $existingPrio $restText"
                        $migrated = $true
                    }
                    $null = $newLines.Add($ln)
                }

                if ($migrated) {
                    $newSecContent = $newLines -join $lf
                    $content = $content.Substring(0, $secContentStart) +
                        $newSecContent +
                        $content.Substring($secEnd)
                }
            }
            $readmeRef.Value = $content
        }
        MigrateReadmeLines ([ref] $readme) $lineEnding

        # -OnlyCompleted and -ExcludeCompleted are mutually exclusive
        if ($OnlyCompleted -and $ExcludeCompleted) {
            throw '-OnlyCompleted and -ExcludeCompleted are mutually exclusive.' +
            ' Use one or neither.'
        }

        [int] $insertIndex = $readme.IndexOf(
            $Section,
            [System.StringComparison]::OrdinalIgnoreCase
        )

        # create section if it doesn't exist
        if ($insertIndex -lt 0) {
            $insertIndex = $readme.Length
            if ($readme.Length -gt 0 -and !$readme.EndsWith("$lineEnding$lineEnding")) {
                $readme += $lineEnding + $lineEnding
            }
            $readme += "$Section$lineEnding"
            $insertIndex = $readme.Length
        }
        else {
            $insertIndex += $Section.Length

            # If section has no trailing newline (e.g., at end of file),
            # append one so the insertion point stays within bounds
            if ($insertIndex -ge $readme.Length) {
                $readme += $lineEnding
                $insertIndex = $readme.Length
            }
            else {
                $insertIndex += $lineEnding.Length
            }
        }
    }

    process {

        if (![string]::IsNullOrWhiteSpace($Line)) {
            if ($Done) {
                # Find the section boundaries
                $sectionStart = $readme.IndexOf(
                    $Section,
                    [System.StringComparison]::OrdinalIgnoreCase
                )
                if ($sectionStart -ge 0) {
                    $sectionContentStart = $sectionStart +
                    $Section.Length + $lineEnding.Length
                    # Find next heading at same or higher level to
                    # determine section boundaries
                    $sectionLevel = ($Section -replace '^([#]+).*$', '$1').Length
                    $restOfFile = $readme.Substring($sectionContentStart)
                    $headingPattern = "(?m)^#{1,$sectionLevel}\s"
                    $nextHeading = [regex]::Match($restOfFile, $headingPattern)
                    $sectionEnd = if ($nextHeading.Success) {
                        $sectionContentStart + $nextHeading.Index
                    }
                    else {
                        $readme.Length
                    }
                    $sectionContent = $readme.Substring(
                        $sectionContentStart,
                        $sectionEnd - $sectionContentStart
                    )

                    # Find lines matching the wildcard pattern
                    $lines = $sectionContent -split $lineEnding
                    $found = $false
                    $matchCount = 0
                    # Build search pattern: - ☐ *<user's Line wildcard>
                    # Use * to match the [Px] priority & optional date prefix
                    $searchPattern = ('- ☐ *' + $Line)
                    for ($i = 0; $i -lt $lines.Count; $i++) {
                        if ($lines[$i] -like $searchPattern) {
                            $matchCount++
                            $found = $true
                            # Replace ☐ with ☒ to mark as done
                            $lines[$i] = $lines[$i].Replace('☐', '☒')
                        }
                    }

                    if (-not $found) {
                        Microsoft.PowerShell.Utility\Write-Warning ("No line matching '" +
                            $searchPattern + "' found in section '$Section'")
                    }
                    elseif ($matchCount -gt 1) {
                        Microsoft.PowerShell.Utility\Write-Warning ("$matchCount lines matched '" +
                            $searchPattern + "' in section '$Section'")
                    }

                    if ($found) {
                        $newSectionContent = $lines -join $lineEnding
                        $readme = $readme.Substring(0, $sectionContentStart) +
                        $newSectionContent +
                        $readme.Substring($sectionEnd)
                    }
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Warning `
                        "Section '$Section' not found for -Done operation"
                }
            }
            else {
                # Check for duplicate before inserting
                $sectionStart = $readme.IndexOf(
                    $Section,
                    [System.StringComparison]::OrdinalIgnoreCase
                )
                if ($sectionStart -ge 0) {
                    $sectionContentStart = $sectionStart +
                        $Section.Length + $lineEnding.Length
                    $sectionLevel = ($Section -replace '^([#]+).*$', '$1').Length
                    $rest = $readme.Substring($sectionContentStart)
                    $nextHeading = [regex]::Match(
                        $rest, "(?m)^#{1,$sectionLevel}\s")
                    $sectionEnd = if ($nextHeading.Success) {
                        $sectionContentStart + $nextHeading.Index
                    }
                    else { $readme.Length }
                    $sectionContent = $readme.Substring(
                        $sectionContentStart,
                        $sectionEnd - $sectionContentStart)
                    $dupLine = "- ☐ [P$Priority] $Line"
                    if ($sectionContent -split $lineEnding -ccontains $dupLine) {
                        Microsoft.PowerShell.Utility\Write-Warning ("Duplicate line '$Line' in " +
                            "section '$Section'")
                        return
                    }
                }

                # insert new line at section with priority prefix
                $insertedText = "- ☐ [P$Priority] $Line$lineEnding"
                $readme = $readme.Substring(0, $insertIndex) +
                $insertedText +
                $readme.Substring($insertIndex)
                # Track insert position for pipeline input ordering (F11 fix)
                $insertIndex += $insertedText.Length
            }
        }
    }

    end {
        # Archive completed items if requested
        if ($ArchiveCompleted) {
            $sectionStart = $readme.IndexOf(
                $Section,
                [System.StringComparison]::OrdinalIgnoreCase
            )
            if ($sectionStart -ge 0) {
                $sectionContentStart = $sectionStart +
                    $Section.Length + $lineEnding.Length
                $sectionLevel = ($Section -replace '^([#]+).*$', '$1').Length
                $restOfFile = $readme.Substring($sectionContentStart)
                $headingPattern = "(?m)^#{1,$sectionLevel}\s"
                $nextHeading = [regex]::Match($restOfFile, $headingPattern)
                $sectionEnd = if ($nextHeading.Success) {
                    $sectionContentStart + $nextHeading.Index
                }
                else { $readme.Length }
                $sectionContent = $readme.Substring(
                    $sectionContentStart,
                    $sectionEnd - $sectionContentStart
                )

                $lines = $sectionContent -split $lineEnding
                $completedLines = [System.Collections.Generic.List[string]]::new()
                $incompleteLines = [System.Collections.Generic.List[string]]::new()
                foreach ($ln in $lines) {
                    if ($ln -match '^\s*-\s*☒') {
                        $null = $completedLines.Add($ln)
                    }
                    else {
                        $null = $incompleteLines.Add($ln)
                    }
                }

                if ($completedLines.Count -eq 0) {
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "No completed items found in section '$Section'")
                }
                else {
                    $datePrefix = [DateTime]::Now.ToString('yyyyMMdd')

                    if ($ArchiveFilePath) {
                        # Archive to external file
                        $archivePath = GenXdev\Expand-Path `
                            -FilePath $ArchiveFilePath -CreateDirectory
                        $archiveHeader = "${lineEnding}### Archived from" +
                        " '$Section' on $datePrefix${lineEnding}"
                        $archiveContent = ($completedLines -join $lineEnding) +
                            $lineEnding
                        [System.IO.File]::AppendAllText(
                            $archivePath,
                            $archiveHeader + $archiveContent
                        )

                        # Remove completed lines from section
                        $newSectionContent = $incompleteLines -join $lineEnding
                        $readme = $readme.Substring(0, $sectionContentStart) +
                            $newSectionContent +
                            $readme.Substring($sectionEnd)

                        # Migrate previously archived items from same-README
                        # archive section (if any) to the external file, then
                        # remove the now-empty archive section.
                        $migrateSectionHeading = "$Section - Archive"
                        $prevArchiveIdx = $readme.IndexOf(
                            $migrateSectionHeading,
                            [System.StringComparison]::OrdinalIgnoreCase
                        )
                        if ($prevArchiveIdx -ge 0) {
                            $prevContentStart = $prevArchiveIdx +
                                $migrateSectionHeading.Length +
                                $lineEnding.Length
                            $prevSectionLevel =
                                ($Section -replace '^([#]+).*$', '$1').Length
                            $prevRest = $readme.Substring($prevContentStart)
                            $prevHeadingPat = "(?m)^#{1,$prevSectionLevel}\s"
                            $prevNext = [regex]::Match(
                                $prevRest, $prevHeadingPat)
                            $prevEnd = if ($prevNext.Success) {
                                $prevContentStart + $prevNext.Index
                            }
                            else { $readme.Length }

                            # Append previously archived items to
                            # the external file.
                            $prevContent = $readme.Substring(
                                $prevContentStart,
                                $prevEnd - $prevContentStart
                            ).TrimEnd()
                            if ($prevContent.Length -gt 0) {
                                $migrateHeader = "${lineEnding}### Migrated" +
                                " from '$migrateSectionHeading' on" +
                                " $datePrefix${lineEnding}"
                                [System.IO.File]::AppendAllText(
                                    $archivePath,
                                    $migrateHeader + $prevContent +
                                    $lineEnding
                                )
                            }

                            # Remove the archive section (heading +
                            # content) from the README.
                            $readme = $readme.Substring(0,
                                $prevArchiveIdx) +
                                $readme.Substring($prevEnd)
                        }
                    }
                    else {
                        # Move to same-README archive section
                        $archiveSection = "$Section - Archive"

                        # Remove completed lines from original section
                        $newSectionContent = $incompleteLines -join $lineEnding
                        $readme = $readme.Substring(0, $sectionContentStart) +
                            $newSectionContent +
                            $readme.Substring($sectionEnd)

                        # Find or create archive section
                        $archiveIndex = $readme.IndexOf(
                            $archiveSection,
                            [System.StringComparison]::OrdinalIgnoreCase
                        )
                        if ($archiveIndex -lt 0) {
                            if ($readme.Length -gt 0 -and
                                !$readme.EndsWith("$lineEnding$lineEnding")) {
                                $readme += $lineEnding + $lineEnding
                            }
                            $readme += "$archiveSection$lineEnding"
                            $archiveIndex = $readme.Length
                        }
                        else {
                            $archiveIndex += $archiveSection.Length +
                                $lineEnding.Length
                        }

                        # Prepend date to each archived line
                        $archivedLines = $completedLines | Microsoft.PowerShell.Core\ForEach-Object {
                            $_ -replace '^- (☒) ', "- `$1 $datePrefix --> "
                        }
                        $archiveInsert = ($archivedLines -join $lineEnding) +
                            $lineEnding
                        $readme = $readme.Substring(0, $archiveIndex) +
                            $archiveInsert +
                            $readme.Substring($archiveIndex)
                    }
                }
            }
        }

        # Sort lines within the section by [Px] priority (descending)
        # only do this for insert operations (not -Done), and only for
        # sections that currently exist
        if (!$Done -and $insertIndex -gt 0) {
            $sectionStart = $readme.IndexOf(
                $Section,
                [System.StringComparison]::OrdinalIgnoreCase
            )
            if ($sectionStart -ge 0) {
                $sectionContentStart = $sectionStart +
                    $Section.Length + $lineEnding.Length
                $sectionLevel = ($Section -replace '^([#]+).*$', '$1').Length
                $restOfFile = $readme.Substring($sectionContentStart)
                $headingPattern = "(?m)^#{1,$sectionLevel}\s"
                $nextHeading = [regex]::Match($restOfFile, $headingPattern)
                $sectionEnd = if ($nextHeading.Success) {
                        $sectionContentStart + $nextHeading.Index
                    } else {
                        $readme.Length
                    }
                $sectionContent = $readme.Substring(
                    $sectionContentStart,
                    $sectionEnd - $sectionContentStart
                )

                # Parse and sort lines
                $sectionLines = $sectionContent -split $lineEnding
                $sortedLines = if ($SortByDate) {
                    # Sort by date prefix (yyyyMMdd) — lines without
                    # a date go to the end (or beginning with -Ascending)
                    $sectionLines |
                        Microsoft.PowerShell.Utility\Sort-Object {
                            if ($_ -match '(\d{8})\s*-->') {
                                $matches[1]
                            } else {
                                if ($Ascending) { '00000000' } else { '99999999' }
                            }
                        } -Descending:(-not $Ascending) -Stable
                } else {
                    # Sort by [Px] priority
                    $sectionLines |
                        Microsoft.PowerShell.Utility\Sort-Object {
                            if ($_ -match '\[P(-?\d+)\]') {
                                [int]$matches[1]
                            } else { 0 }
                        } -Descending:(-not $Ascending) -Stable
                }

                $sortedContent = $sortedLines -join $lineEnding
                $readme = $readme.Substring(0, $sectionContentStart) +
                    $sortedContent +
                    $readme.Substring($sectionEnd)
            }
        }

        # save changes atomically to prevent corruption
        GenXdev\Write-TextFileAtomic -FilePath $readmePath -Data $readme

        # open in vscode if requested
        if ($Code) {
            GenXdev\VSCode $readmePath
        }

        # show modified section if requested
        if ($Show) {
            $sectionLines = [System.Collections.Generic.List[string]]::new()

            $inSection = $false
            foreach ($readmeLine in [IO.File]::ReadAllLines($readmePath)) {
                if ($readmeLine.StartsWith($Section)) {
                    $inSection = $true
                    continue
                }
                if ($inSection) {
                    $sectionLevel = ($Section -replace '^([#]+).*$', '$1').Length
                    if ($readmeLine.StartsWith('#')) {
                        $lineLevel = ($readmeLine -replace '^([#]+).*$', '$1').Length
                        if ($lineLevel -le $sectionLevel) {
                            break
                        }
                    }
                    $trimmed = $readmeLine.Trim("`r`n`t ")
                    if ($trimmed) {
                        $null = $sectionLines.Add($trimmed)
                    }
                }
            }

            # Filter by completion status if requested
            if ($OnlyCompleted) {
                $sectionLines = [System.Collections.Generic.List[string]](
                    @($sectionLines | Microsoft.PowerShell.Core\Where-Object { $_ -match '^\s*-\s*☒' })
                )
            }
            elseif ($ExcludeCompleted) {
                $sectionLines = [System.Collections.Generic.List[string]](
                    @($sectionLines | Microsoft.PowerShell.Core\Where-Object { $_ -match '^\s*-\s*☐' })
                )
            }

            # Sort the collected lines
            if ($SortByDate) {
                $sectionLines = [System.Collections.Generic.List[string]](
                    [System.Linq.Enumerable]::ToList(
                        [System.Linq.Enumerable]::OrderBy(
                            $sectionLines,
                            [System.Func[string,string]] {
                                param($ln)
                                if ($ln -match '(\d{8})\s*-->') {
                                    $matches[1]
                                } else {
                                    if ($Ascending) { '00000000' } else { '99999999' }
                                }
                            }
                        )
                    )
                )
                if (-not $Ascending) {
                    $sectionLines.Reverse()
                }
            } else {
                $sectionLines = [System.Collections.Generic.List[string]](
                    [System.Linq.Enumerable]::ToList(
                        [System.Linq.Enumerable]::OrderBy(
                            $sectionLines,
                            [System.Func[string,int]] {
                                param($ln)
                                if ($ln -match '\[P(-?\d+)\]') {
                                    [int]$matches[1]
                                } else { 0 }
                            }
                        )
                    )
                )
                if (-not $Ascending) {
                    $sectionLines.Reverse()
                }
            }

            # Apply -First limit (only to output, not file)
            if ($First -gt 0 -and $sectionLines.Count -gt $First) {
                $sectionLines = [System.Collections.Generic.List[string]](
                    $sectionLines.GetRange(0, $First)
                )
            }

            $ansiColorStart = [char]27 + '['
            $ansiColorYellow = "${ansiColorStart}33m"
            $ansiBackgroundColorBlue = "${ansiColorStart}44m"
            $ansiColorReset = "${ansiColorStart}0m"

            $sectionHeader = $Section.Trim("`r`n`t ")
            "$ansiBackgroundColorBlue${ansiColorYellow}${sectionHeader}${ansiColorReset}`r`n`r`n" +
                ($sectionLines -join "`r`n`r`n") + "`r`n`r`n"
        }
    }
}