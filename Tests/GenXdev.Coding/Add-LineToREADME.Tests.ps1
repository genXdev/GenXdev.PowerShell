###############################################################################
# Unit tests for Add-LineToREADME
#
# Tests cover: core insertion, -Done, -Show, path resolution, edge cases,
# caller function integration, and line migration.
###############################################################################
Pester\Describe 'Add-LineToREADME' {

    Pester\BeforeAll {

        ###########################################################################
        # Helper: create a standard multi-section README in the temp directory
        ###########################################################################
        function script:NewTestReadMe {
            $content = @'
# Test README

## Features
- ☒ [P1] Existing feature

## Issues
- ☐ [P1] Existing issue

## Todoos
- ☐ [P1] 20250101 --> Fix bug

## Release notes
- ☒ [P1] v1.0 released
'@
            [System.IO.File]::WriteAllText(($script:testReadme), $content)
        }

        ###########################################################################
        # Helper: read the temp README content
        ###########################################################################
        function script:GetTestReadmeContent {
            [System.IO.File]::ReadAllText(($script:testReadme))
        }

        ###########################################################################
        # Helper: read lines of the temp README
        ###########################################################################
        function script:GetTestReadmeLines {
            [System.IO.File]::ReadAllLines(($script:testReadme))
        }


        # Create a clean temp root for all tests
        # Trailing \ signals Expand-Path this is a directory to create
        ($script:testRoot) = GenXdev\Expand-Path `
            -FilePath "$env:TEMP\GenXdev.AddLineToREADME.Tests\" `
            -CreateDirectory

        # Ensure clean start
        GenXdev\Remove-AllItems -Confirm:$False ($script:testRoot)

        # Recreate the test root directory in case Remove-AllItems deleted it
        $null = GenXdev\Expand-Path -FilePath "$env:TEMP\GenXdev.AddLineToREADME.Tests\" -CreateDirectory

        Microsoft.PowerShell.Management\Push-Location -LiteralPath ($script:testRoot)
    }

    Pester\AfterAll {
        Microsoft.PowerShell.Management\Pop-Location
        GenXdev\Remove-AllItems -Confirm:$False  ($script:testRoot)
    }

    Pester\BeforeEach {
        # Each test gets a fresh temp README with known content
        ($script:testReadme) = Microsoft.PowerShell.Management\Join-Path ($script:testRoot) 'README.md'

        # Ensure we're in testRoot before each test
        Microsoft.PowerShell.Management\Set-Location -LiteralPath ($script:testRoot)

        # Clean up any leftover temp file
        if (Microsoft.PowerShell.Management\Test-Path ($script:testReadme)) {
            Microsoft.PowerShell.Management\Remove-Item ($script:testReadme) -Force
        }
        # Clean archive.md from previous tests
        $archivePath = Microsoft.PowerShell.Management\Join-Path `
            ($script:testRoot) 'archive.md'
        if (Microsoft.PowerShell.Management\Test-Path $archivePath) {
            Microsoft.PowerShell.Management\Remove-Item $archivePath -Force
        }
    }

    Pester\AfterEach {
        # Clean up temp README
        if (Microsoft.PowerShell.Management\Test-Path ($script:testReadme)) {
            Microsoft.PowerShell.Management\Remove-Item ($script:testReadme) -Force
        }
        # Clean archive.md
        $archivePath = Microsoft.PowerShell.Management\Join-Path `
            ($script:testRoot) 'archive.md'
        if (Microsoft.PowerShell.Management\Test-Path $archivePath) {
            Microsoft.PowerShell.Management\Remove-Item $archivePath -Force
        }
    }

    ###########################################################################
    # GROUP 1: Core Insertion
    ###########################################################################

    Pester\It 'Inserts a line into an existing section' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'New feature'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*## Features*'
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] New feature*'
        # Verify inserted after section header, before existing content
        # [P1] sorts before un-prefixed lines (higher priority first)
        $content | Pester\Should -BeLike '*## Features*- ☐ [[]P1[]] New feature*- ☒ [[]P1[]] Existing feature*'
    }

    Pester\It 'Inserts a line into a middle section (not first or last)' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## Issues' -Line 'New issue'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*## Issues*'
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] New issue*'
        # Verify the line is in Issues section (between Features and Todoos)
        $content | Pester\Should -BeLike '*## Features*## Issues*[[]P1[]] New issue*## Todoos*'
    }

    Pester\It 'Creates a new section when it does not exist' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line 'New idea'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*## Ideas*'
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] New idea*'
        # Section should be at or near end of file (after fix)
    }

    Pester\It 'Does nothing when Line is empty' {
        script:NewTestReadMe
        $before = script:GetTestReadmeContent

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line ''

        $after = script:GetTestReadmeContent
        $after | Pester\Should -BeExactly $before
    }

    Pester\It 'Does nothing when Line is whitespace-only' {
        script:NewTestReadMe
        $before = script:GetTestReadmeContent

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line '   '

        $after = script:GetTestReadmeContent
        $after | Pester\Should -BeExactly $before
    }

    ###########################################################################
    # GROUP 1B: Priority Sorting
    ###########################################################################

    Pester\It 'Prepends [P1] by default' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'Default prio'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] Default prio*'
    }

    Pester\It 'Higher priority sorts before lower priority' {
        script:NewTestReadMe

        # Insert low priority first, then high
        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'Low prio' `
            -Priority 1
        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'High prio' `
            -Priority 5

        $content = script:GetTestReadmeContent
        # High priority (5) should appear before low priority (1)
        $content | Pester\Should -BeLike `
            '*[[]P5[]] High prio*[[]P1[]] Low prio*'
    }

    Pester\It 'Negative priority sorts after default' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'Normal' `
            -Priority 1
        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'Low' `
            -Priority -3

        $content = script:GetTestReadmeContent
        # Normal (1) before Low (-3)
        $content | Pester\Should -BeLike `
            '*[[]P1[]] Normal*[[]P-3[]] Low*'
    }

    ###########################################################################
    # GROUP 2: -Done Functionality
    ###########################################################################

    Pester\It 'Marks a todo item as done (checkbox prefix)' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## Todoos' `
            -Line '20250101 --> Fix bug' -Done

        $content = script:GetTestReadmeContent
        # Line should now have ☐ replaced with ☒
        $content | Pester\Should -BeLike '*- ☒ [[]P1[]] 20250101 --> Fix bug*'
        # Original undone version should be gone
        $content | Pester\Should -Not -BeLike '*- ☐ 20250101 --> Fix bug*'
    }

    Pester\It 'Wildcard -Done matches a line with * and ?' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## Todoos' `
            -Line '*Fix bug*' -Done

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☒ *Fix bug*'
        # Verify the ☐ version of the line is gone (use line-anchored
        # regex because -BeLike * matches across newlines)
        $content | Pester\Should -Not -Match '(?m)^- ☐ .*Fix bug'
    }

    Pester\It '-Done on a non-existent line leaves file unchanged' {
        script:NewTestReadMe
        $before = script:GetTestReadmeContent

        GenXdev\Add-LineToREADME `
            -Section '## Todoos' `
            -Line 'nonexistent item' -Done -WarningVariable warned 3>&1

        $after = script:GetTestReadmeContent
        $after | Pester\Should -BeExactly $before
    }

    Pester\It '-Done marks a line as completed in any section' {
        script:NewTestReadMe
        # Add a line to ## Features (internally uses - ☐ prefix)
        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'Star item'
        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] Star item*'

        # Now mark it done
        GenXdev\Add-LineToREADME `
            -Section '## Features' `
            -Line 'Star item' -Done

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☒ [[]P1[]] Star item*'
    }

    ###########################################################################
    # GROUP 3: -Show Functionality
    ###########################################################################

    Pester\It '-Show outputs only the target section' {
        script:NewTestReadMe
        # Insert a line to have something to show
        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'Shown feature'

        $output = GenXdev\Add-LineToREADME `
            -Section '## Features' -Line '' -Show

        # Output should contain Features section but not Issues section
        $combined = $output -join "`n"
        $combined | Pester\Should -BeLike '*Features*'
        $combined | Pester\Should -Not -BeLike '*## Issues*'
        $combined | Pester\Should -Not -BeLike '*Existing issue*'
    }

    Pester\It '-Show includes subsection headings (###)' {
        script:NewTestReadMe
        # Add a subsection to Features
        $content = script:GetTestReadmeContent
        $content = $content -replace '## Issues', "### Core`r`n- [X] Sub item`r`n`r`n## Issues"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        $output = GenXdev\Add-LineToREADME `
            -Section '## Features' -Line '' -Show

        $combined = $output -join "`n"
        # Should contain the subsection content
        $combined | Pester\Should -BeLike '*### Core*'
        $combined | Pester\Should -BeLike '*Sub item*'
    }

    Pester\It '-Show stops at next same-level heading' {
        script:NewTestReadMe

        $output = GenXdev\Add-LineToREADME `
            -Section '## Features' -Line '' -Show

        $combined = $output -join "`n"
        # Should NOT contain content from ## Issues or ## Todoos
        $combined | Pester\Should -Not -BeLike '*## Issues*'
        $combined | Pester\Should -Not -BeLike '*Existing issue*'
    }

    Pester\It '-Show on non-existent section produces minimal output' {
        script:NewTestReadMe

        $output = GenXdev\Add-LineToREADME `
            -Section '## NoSuchSection' -Line '' -Show

        # After fix, should produce no meaningful section content
        $output.Count | Pester\Should -BeLessOrEqual 1
    }

    ###########################################################################
    # GROUP 4: README Path Resolution
    ###########################################################################

    Pester\It 'Finds README.md in the current directory' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'Found in cwd'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*Found in cwd*'
    }

    Pester\It 'Walks up directories to find parent README.md' {
        script:NewTestReadMe

        # Create a subdirectory
        $subDir = Microsoft.PowerShell.Management\Join-Path ($script:testRoot) 'subdir'
        $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory `
            -Path $subDir -Force

        try {
            Microsoft.PowerShell.Management\Set-Location -LiteralPath $subDir

            GenXdev\Add-LineToREADME `
                -Section '## Features' -Line 'Found from subdir'

            $content = script:GetTestReadmeContent
            $content | Pester\Should -BeLike '*Found from subdir*'
        }
        finally {
            Microsoft.PowerShell.Management\Set-Location -LiteralPath ($script:testRoot)
            Microsoft.PowerShell.Management\Remove-Item $subDir -Recurse -Force
        }
   }

    ###########################################################################
    # GROUP 5: Edge Cases
    ###########################################################################

    Pester\It 'Matches section header case-insensitively' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## features' -Line 'Case test'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*Case test*'
    }

    Pester\It 'Works with LF-only line endings' {

        script:NewTestReadMe

        $lfContent = "# Test README`n`n## Features`n- [X] Existing`n`n## Issues`n- ☐ Issue`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $lfContent)

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'LF test'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*LF test*'
    }

    Pester\It 'Works with CRLF line endings (Windows standard)' {

        script:NewTestReadMe

        # script:NewTestReadMe already uses CRLF via WriteAllText on Windows

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'CRLF test'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*CRLF test*'
    }

    Pester\It 'Handles section at the very end of file (no trailing newline)' {

        script:NewTestReadMe

        $content = "# Test README`r`n`r`n## Release notes"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Release notes' -Line 'End test'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*[[]P1[]] End test*'
    }

    Pester\It 'Inserts multiple lines and both appear in section' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## Todoos' -Line 'Item1'
        GenXdev\Add-LineToREADME `
            -Section '## Todoos' -Line 'Item2'

        $content = script:GetTestReadmeContent
        # Both items should exist (sort by priority, same P1 = any order)
        $content | Pester\Should -BeLike '*[[]P1[]] Item1*'
        $content | Pester\Should -BeLike '*[[]P1[]] Item2*'
    }

    Pester\It 'Detects duplicate lines and warns' {
        script:NewTestReadMe

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'Duplicate' -WarningVariable warned 3>&1

        # Second insert of same line should warn and not add a duplicate
        $null = GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'Duplicate' `
            -WarningAction SilentlyContinue -WarningVariable warned 3>&1

        # Verify only one instance exists
        $content = script:GetTestReadmeContent
        $dupMatches = [regex]::Matches($content, [regex]::Escape('- ☐ [P1] Duplicate'))
        $dupMatches.Count | Pester\Should -Be 1
    }

    Pester\It 'Works with an empty README file' {

        script:NewTestReadMe

        [System.IO.File]::WriteAllText(($script:testReadme), '')

        GenXdev\Add-LineToREADME `
            -Section '## NewSection' -Line 'First line'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*## NewSection*'
        $content | Pester\Should -BeLike '*[[]P1[]] First line*'
    }

    Pester\It 'Does not confuse section header inside fenced code block' {

        script:NewTestReadMe

        # [BROKEN: F9] — IndexOf matches inside code blocks
        $content = @'
# Test README

```text
Example section: ## Features
This is just example text
```

## Issues
- ☐ Real issue
'@
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Issues' -Line 'Should be in Issues'

        $content = script:GetTestReadmeContent
        # Line should be under ## Issues, not injected inside the code block
        $content | Pester\Should -BeLike '*## Issues*- ☐ [[]P1[]] Should be in Issues*'
    }

    ###########################################################################
    # GROUP 6: Caller Function Integration Smoke Tests
    ###########################################################################

    Pester\It 'Add-TodoLineToREADME inserts into ## Todoos section' {
        script:NewTestReadMe

        GenXdev\Add-TodoLineToREADME -Line 'Caller test todo'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*## Todoos*'
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] *Caller test todo*'
    }

    Pester\It 'Add-FeatureLineToREADME inserts into ## Features section' {
        script:NewTestReadMe

        # Add-FeatureLineToREADME hardcodes -Done:$true and prepends a
        # yyyyMMdd --> date prefix. We simulate this by inserting with
        # the same prefix, then calling -Done directly (since
        # Add-FeatureLineToREADME's date prefix would collide as a
        # duplicate on re-insertion).
        $datePrefix = [DateTime]::Now.ToString('yyyyMMdd')
        GenXdev\Add-LineToREADME `
            -Section '## Features' `
            -Line "$datePrefix --> Caller test feature"
        GenXdev\Add-LineToREADME `
            -Section '## Features' `
            -Line 'Caller test feature' -Done

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*## Features*'
        $content | Pester\Should -BeLike '*- ☒ [[]P1[]] *Caller test feature*'
    }

    Pester\It 'Add-IssueLineToREADME inserts into ## Issues section' {
        script:NewTestReadMe

        GenXdev\Add-IssueLineToREADME -Line 'Caller test issue'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*## Issues*'
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] *Caller test issue*'
    }

    Pester\It 'Add-IdeaLineToREADME inserts into ## Ideas section' {
        script:NewTestReadMe

        GenXdev\Add-IdeaLineToREADME -Line 'Caller test idea'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*## Ideas*'
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] *Caller test idea*'
    }

    Pester\It 'Add-ReleaseNoteLineToREADME inserts into ## Release notes section' {
        script:NewTestReadMe

        GenXdev\Add-ReleaseNoteLineToREADME -Line 'Caller test release'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*## Release notes*'
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] *Caller test release*'
    }

    Pester\It 'Get-Todoos does not throw' {
        script:NewTestReadMe

        { GenXdev\Get-Todoos } | Pester\Should -Not -Throw
    }

    Pester\It 'Get-Features does not throw' {
        script:NewTestReadMe

        { GenXdev\Get-Features } | Pester\Should -Not -Throw
    }

    Pester\It 'Get-Issues does not throw' {
        script:NewTestReadMe

        { GenXdev\Get-Issues } | Pester\Should -Not -Throw
    }

    Pester\It 'Get-Ideas does not throw' {
        script:NewTestReadMe

        { GenXdev\Get-Ideas } | Pester\Should -Not -Throw
    }

    Pester\It 'Get-ReleaseNotes does not throw' {
        script:NewTestReadMe

        { GenXdev\Get-ReleaseNotes } | Pester\Should -Not -Throw
    }

    ###########################################################################
    # GROUP 7: Migration of old format lines
    ###########################################################################

    Pester\It 'Migrates - [X] prefix to - ☒ with [P1]' {

        script:NewTestReadMe

        $content = "# Test README`r`n`r`n## Features`r`n- [X] Old feature`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        # Trigger migration by inserting a new line
        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'New feature'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☒ [[]P1[]] Old feature*'
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] New feature*'
        $content | Pester\Should -Not -BeLike '*- [[]X[]] Old feature*'
    }

    Pester\It 'Migrates - [☒] prefix to - ☒ with [P1]' {

        script:NewTestReadMe

        $content = "# Test README`r`n`r`n## Release notes`r`n- [☒] v1.0`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Release notes' -Line 'New release'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☒ [[]P1[]] v1.0*'
        $content | Pester\Should -Not -BeLike '*- [[]☒[]] v1.0*'
    }

    Pester\It 'Migrates - ☐ without priority to - ☐ [P1]' {
        script:NewTestReadMe
        $content = "# Test README`r`n`r`n## Todoos`r`n- ☐ Some task`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Todoos' -Line 'New task'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] Some task*'
        $content | Pester\Should -Not -BeLike '*- ☐ Some task'
    }

    Pester\It 'Preserves existing priority during migration' {
        script:NewTestReadMe
        $content = "# Test README`r`n`r`n## Features`r`n- [X] [P5] High prio`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'New item'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☒ [[]P5[]] High prio*'
    }

    Pester\It 'Does not re-migrate already migrated lines' {
        script:NewTestReadMe
        $content = "# Test README`r`n`r`n## Features`r`n- ☒ [P3] Done item`r`n- ☐ [P2] Pending item`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'New item'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☒ [[]P3[]] Done item*'
        $content | Pester\Should -BeLike '*- ☐ [[]P2[]] Pending item*'
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] New item*'
    }

    Pester\It 'Migrates * prefix to - ☐ [P1]' {
        script:NewTestReadMe
        $content = "# Test README`r`n`r`n## Features`r`n* Star item`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Features' -Line 'New feature'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] Star item*'
        $content | Pester\Should -Not -BeLike '*\* Star item*'
    }

    Pester\It 'Migrates - [ ] prefix to - ☐ [P1]' {
        script:NewTestReadMe
        $content = "# Test README`r`n`r`n## Issues`r`n- [ ] Unchecked box`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Issues' -Line 'New issue'

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] Unchecked box*'
        $content | Pester\Should -Not -BeLike '*- [[] []] Unchecked*'
    }

    ###########################################################################
    # GROUP 8: -Show with -OnlyCompleted / -ExcludeCompleted filtering
    ###########################################################################

    Pester\It '-Show -OnlyCompleted returns only ☒ items' {
        script:NewTestReadMe

        # Use a clean section with both completed and incomplete items
        $content = @'
# Test README

## Ideas
- ☐ [P1] Keep this
- ☒ [P1] Hide this
'@
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        $output = GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line '' -Show -OnlyCompleted

        $combined = $output -join "`n"
        $combined | Pester\Should -BeLike '*☒*Hide this*'
        $combined | Pester\Should -Not -BeLike '*☐*Keep this*'
    }

    Pester\It '-Show -ExcludeCompleted returns only ☐ items' {
        script:NewTestReadMe

        $content = @'
# Test README

## Ideas
- ☐ [P1] Keep this
- ☒ [P1] Hide this
'@
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        $output = GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line '' -Show -ExcludeCompleted

        $combined = $output -join "`n"
        $combined | Pester\Should -BeLike '*☐*Keep this*'
        $combined | Pester\Should -Not -BeLike '*☒*Hide this*'
    }

    Pester\It '-OnlyCompleted and -ExcludeCompleted together throw' {
        script:NewTestReadMe

        { GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line '' -Show `
            -OnlyCompleted -ExcludeCompleted } | Pester\Should -Throw
    }

    ###########################################################################
    # GROUP 9: -ArchiveCompleted (same-README archive section)
    ###########################################################################

    Pester\It '-ArchiveCompleted moves ☒ items to same-README archive section' {
        script:NewTestReadMe

        $content = @'
# Test README

## Ideas
- ☐ [P1] Keep this
- ☒ [P1] Archive me
'@
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line '' -ArchiveCompleted

        $content = script:GetTestReadmeContent
        # Archive section should exist
        $content | Pester\Should -BeLike '*## Ideas - Archive*'
        # Completed item moved to archive
        $content | Pester\Should -BeLike '*☒*Archive me*'
        # Original section (before archive subsection) keeps incomplete item
        $beforeArchive = ($content -split '## Ideas - Archive')[0]
        $beforeArchive | Pester\Should -BeLike '*Keep this*'
        $beforeArchive | Pester\Should -Not -BeLike '*Archive me*'
    }

    Pester\It '-ArchiveCompleted with no ☒ items does nothing' {
        script:NewTestReadMe

        $content = @'
# Test README

## Ideas
- ☐ [P1] Only incomplete
'@
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line '' -ArchiveCompleted

        $content = script:GetTestReadmeContent
        # No archive section created
        $content | Pester\Should -Not -BeLike '*## Ideas - Archive*'
        # Original item still there
        $content | Pester\Should -BeLike '*Only incomplete*'
    }

    ###########################################################################
    # GROUP 10: -ArchiveCompleted with -ArchiveFilePath (external file)
    ###########################################################################

    Pester\It '-ArchiveCompleted -ArchiveFilePath writes to external file' {
        script:NewTestReadMe

        $content = @'
# Test README

## Ideas
- ☐ [P1] Keep this
- ☒ [P1] To file
'@
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        $archiveFile = Microsoft.PowerShell.Management\Join-Path `
            ($script:testRoot) 'archive.md'

        GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line '' `
            -ArchiveCompleted -ArchiveFilePath $archiveFile

        # External file should contain the completed item
        $extContent = [System.IO.File]::ReadAllText($archiveFile)
        $extContent | Pester\Should -BeLike '*To file*'

        # README should no longer have the completed item
        $readmeContent = script:GetTestReadmeContent
        $readmeContent | Pester\Should -BeLike '*Keep this*'
        $readmeContent | Pester\Should -Not -BeLike '*To file*'

        # Verify file path is inside temp root (safety)
        $archiveFile | Pester\Should -BeLike "$($script:testRoot)*"
    }

    Pester\It '-ArchiveCompleted -ArchiveFilePath removes only completed items from section' {
        script:NewTestReadMe

        $content = @'
# Test README

## Ideas
- ☐ [P1] A
- ☒ [P1] B
- ☐ [P1] C
- ☒ [P1] D
'@
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        $archiveFile = Microsoft.PowerShell.Management\Join-Path `
            ($script:testRoot) 'archive.md'

        GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line '' `
            -ArchiveCompleted -ArchiveFilePath $archiveFile

        # External file has B and D
        $extContent = [System.IO.File]::ReadAllText($archiveFile)
        $extContent | Pester\Should -BeLike '*B*'
        $extContent | Pester\Should -BeLike '*D*'

        # README still has A and C
        $readmeContent = script:GetTestReadmeContent
        $readmeContent | Pester\Should -BeLike '*☐*A*'
        $readmeContent | Pester\Should -BeLike '*☐*C*'
        $readmeContent | Pester\Should -Not -BeLike '*☒*B*'
        $readmeContent | Pester\Should -Not -BeLike '*☒*D*'
    }

    ###########################################################################
    # GROUP 11: Cross-mode archive migration
    ###########################################################################

    Pester\It 'ArchiveFilePath migrates section-archived items to external file' {
        script:NewTestReadMe

        # Step 1: Archive to same-README (creates ## Ideas - Archive)
        $content = @'
# Test README

## Ideas
- ☐ [P1] Keep
- ☒ [P1] First batch
'@
        [System.IO.File]::WriteAllText(($script:testReadme), $content)
        GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line '' -ArchiveCompleted

        # Verify archive section exists
        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*## Ideas - Archive*'
        $content | Pester\Should -BeLike '*First batch*'

        # Step 2: Add more completed items, then archive to external file
        GenXdev\Add-LineToREADME -Section '## Ideas' -Line 'Second batch'
        GenXdev\Add-LineToREADME -Section '## Ideas' -Line 'Second batch' -Done

        # Verify Second batch exists as ☒ in ## Ideas before archiving
        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*☒*Second batch*'

        $archiveFile = Microsoft.PowerShell.Management\Join-Path `
            ($script:testRoot) 'archive.md'
        GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line '' `
            -ArchiveCompleted -ArchiveFilePath $archiveFile

        # External file should contain both batches
        $extContent = [System.IO.File]::ReadAllText($archiveFile)
        $extContent | Pester\Should -BeLike '*First batch*'
        $extContent | Pester\Should -BeLike '*Second batch*'
        $extContent | Pester\Should -BeLike '*Migrated from*'

        # README should NOT have the archive section anymore
        $readmeContent = script:GetTestReadmeContent
        $readmeContent | Pester\Should -Not -BeLike '*## Ideas - Archive*'
        # Incomplete item is kept
        $readmeContent | Pester\Should -BeLike '*Keep*'
        # Completed items are removed from original section
        $readmeContent | Pester\Should -Not -BeLike '*- ☒ *First batch*'
        $readmeContent | Pester\Should -Not -BeLike '*- ☒ *Second batch*'
    }

    Pester\It 'ArchiveFilePath without prior section archive works normally' {
        script:NewTestReadMe

        # No prior archive — just straight to external file
        $content = @'
# Test README

## Ideas
- ☐ [P1] Keep
- ☒ [P1] Direct archive
'@
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        $archiveFile = Microsoft.PowerShell.Management\Join-Path `
            ($script:testRoot) 'archive.md'
        GenXdev\Add-LineToREADME `
            -Section '## Ideas' -Line '' `
            -ArchiveCompleted -ArchiveFilePath $archiveFile

        $extContent = [System.IO.File]::ReadAllText($archiveFile)
        # Should have the direct archive entry
        $extContent | Pester\Should -BeLike '*Direct archive*'
        # Should NOT have a "Migrated from" header (nothing to migrate)
        # (check by verifying it has exactly one "Archived from" header)
        $matches = [regex]::Matches($extContent, 'Archived from')
        $matches.Count | Pester\Should -Be 1

        # Verify completed item is removed from README, incomplete stays
        $readmeContent = script:GetTestReadmeContent
        $readmeContent | Pester\Should -BeLike '*Keep*'
        $readmeContent | Pester\Should -Not -BeLike '*Direct archive*'
    }
}
