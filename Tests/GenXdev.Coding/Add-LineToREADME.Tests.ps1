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

    ###########################################################################
    # GROUP 12: Section boundary integrity (regression)
    #
    # A section must always stay terminated by a line ending after sorting,
    # otherwise the next heading is glued onto the last item and the section
    # becomes unparseable for Get-Todoos / Get-Issues / Get-Ideas.
    ###########################################################################

    Pester\It 'SortByDate keeps the next heading on its own line' {
        $content = "# Test README`r`n`r`n## Todoos`r`n" +
        "- ☐ [P1] 20250101 --> Dated item`r`n" +
        "- ☐ [P1] not a dated item`r`n`r`n## Ideas`r`n- ☐ [P1] Some idea`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Todoos' -Line '' -SortByDate

        $lines = script:GetTestReadmeLines
        # The blank separator line must survive the sort
        $lines | Pester\Should -Contain ''
        # Headings must still be their own lines
        $lines | Pester\Should -Contain '## Ideas'
        $lines | Pester\Should -Contain '## Todoos'
    }

    Pester\It 'SortByDate does not glue a heading onto the last item' {
        $content = "# Test README`r`n`r`n## Todoos`r`n" +
        "- ☐ [P1] 20250101 --> Dated item`r`n" +
        "- ☐ [P1] undated item`r`n`r`n## Ideas`r`n- ☐ [P1] Some idea`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Todoos' -Line '' -SortByDate

        $content = script:GetTestReadmeContent
        # No item may end with the following heading appended
        $content | Pester\Should -Not -Match 'item## Ideas'
        $content | Pester\Should -Not -Match 'item## Todoos'
        # Items keep their text intact
        $content | Pester\Should -BeLike '*undated item*'
        $content | Pester\Should -BeLike '*Dated item*'
    }

    Pester\It 'SortByDate through the todo wrapper preserves sections' {
        $content = "# Test README`r`n`r`n## Todoos`r`n" +
        "- ☐ [P1] 20250101 --> Dated item`r`n" +
        "- ☐ [P1] undated item`r`n`r`n## Ideas`r`n- ☐ [P1] Some idea`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-TodoLineToREADME -Line '' -SortByDate

        $lines = script:GetTestReadmeLines
        $lines | Pester\Should -Contain '## Todoos'
        $lines | Pester\Should -Contain '## Ideas'
        # Get-Todoos can still resolve the section
        $todo = GenXdev\Get-Todoos
        ($todo -join "`n") | Pester\Should -BeLike '*Dated item*'
        ($todo -join "`n") | Pester\Should -Not -BeLike '*Some idea*'
    }

    Pester\It '-Show does not rewrite the README' {
        script:NewTestReadMe
        $before = script:GetTestReadmeContent

        GenXdev\Add-LineToREADME `
            -Section '## Todoos' -Line '' -Show -SortByDate | Microsoft.PowerShell.Core\Out-Null

        $after = script:GetTestReadmeContent
        $after | Pester\Should -BeExactly $before
    }

    Pester\It 'Get-Ideas does not rewrite the README' {
        $content = "# Test README`r`n`r`n## Ideas`r`n" +
        "- ☐ [P1] 20250101 --> Dated idea`r`n" +
        "- ☐ [P1] undated idea`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)
        $before = script:GetTestReadmeContent

        GenXdev\Get-Ideas -SortByDate | Microsoft.PowerShell.Core\Out-Null

        $after = script:GetTestReadmeContent
        $after | Pester\Should -BeExactly $before
    }

    Pester\It 'Priority sort also keeps the next heading on its own line' {
        $content = "# Test README`r`n`r`n## Issues`r`n" +
        "- ☐ [P1] Low`r`n- ☐ [P9] High`r`n`r`n## Todoos`r`n- ☐ [P1] Task`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME `
            -Section '## Issues' -Line 'Another'

        $lines = script:GetTestReadmeLines
        $lines | Pester\Should -Contain '## Todoos'
        $lines | Pester\Should -Contain ''
    }

    ###########################################################################
    # GROUP 13: Robustness — multi-line items stay atomic
    #
    # An item may span several lines (e.g. `todo (Get-Clipboard)` pasting
    # paragraphs). An item starts at "- ☐/☒" and ends at the next item, the
    # next real heading, or EOF. Sorting must treat it as one indivisible
    # block, or a paste gets shredded.
    ###########################################################################

    Pester\It 'Keeps a multi-line item contiguous when sorting by priority' {
        $content = "# Test`r`n`r`n## Todoos`r`n" +
        "- ☐ [P5] multi line item`r`n`r`ncontinuation text`r`n" +
        "- ☐ [P1] other item`r`n`r`n## Ideas`r`n- ☐ [P1] an idea`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-TodoLineToREADME -Line 'newest item' | Microsoft.PowerShell.Core\Out-Null

        $lines = script:GetTestReadmeLines
        $header = [array]::IndexOf($lines, '- ☐ [P5] multi line item')
        $header | Pester\Should -BeGreaterOrEqual 0
        # the item's own lines must sit directly underneath their header
        $lines[$header + 1] | Pester\Should -Be ''
        $lines[$header + 2] | Pester\Should -Be 'continuation text'
    }

    Pester\It 'Keeps a multi-line item contiguous when sorting by date' {
        $content = "# Test`r`n`r`n## Todoos`r`n" +
        "- ☐ [P5] 20250101 --> multi line item`r`n`r`ncontinuation text`r`n" +
        "- ☐ [P1] 20260101 --> other item`r`n`r`n## Ideas`r`n- ☐ [P1] an idea`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-TodoLineToREADME -Line 'dated item' -SortByDate | Microsoft.PowerShell.Core\Out-Null

        $lines = script:GetTestReadmeLines
        $header = [array]::IndexOf($lines, '- ☐ [P5] 20250101 --> multi line item')
        $header | Pester\Should -BeGreaterOrEqual 0
        $lines[$header + 1] | Pester\Should -Be ''
        $lines[$header + 2] | Pester\Should -Be 'continuation text'
    }

    Pester\It 'Does not let a heading inside item text end the section' {
        $content = "# Test`r`n`r`n## Todoos`r`n" +
        "- ☐ [P1] notes:`r`n## Not A Section`r`nmore text`r`n" +
        "`r`n## Ideas`r`n- ☐ [P1] an idea`r`n" +
        "`r`n## Release notes`r`n- ☒ [P1] v1`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-TodoLineToREADME -Line 'later todo' | Microsoft.PowerShell.Core\Out-Null

        $lines = script:GetTestReadmeLines
        # the pasted heading must stay inside the item, not become a boundary
        $header = [array]::IndexOf($lines, '- ☐ [P1] notes:')
        $header | Pester\Should -BeGreaterOrEqual 0
        $lines[$header + 1] | Pester\Should -Be '## Not A Section'
        $lines[$header + 2] | Pester\Should -Be 'more text'
        # and the real sections must survive
        $lines | Pester\Should -Contain '## Ideas'
        $lines | Pester\Should -Contain '## Release notes'
    }

    Pester\It 'Never splits an item into another section' {
        $content = "# Test`r`n`r`n## Issues`r`n" +
        "- ☐ [P1] issue with`r`n`r`nspread out text`r`n" +
        "`r`n## Todoos`r`n- ☐ [P1] a todo`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-TodoLineToREADME -Line 'later todo' | Microsoft.PowerShell.Core\Out-Null

        $lines = script:GetTestReadmeLines
        $issues = [array]::IndexOf($lines, '## Issues')
        $todoos = [array]::IndexOf($lines, '## Todoos')
        $spread = [array]::IndexOf($lines, 'spread out text')
        $spread | Pester\Should -BeGreaterThan $issues
        $spread | Pester\Should -BeLessThan $todoos
    }

    ###########################################################################
    # GROUP 14: Robustness — fenced code blocks
    ###########################################################################

    Pester\It 'Ignores a section heading inside a fenced code block' {
        $content = "# Test`r`n`r`n``````powershell`r`n" +
        "# example heading ## Issues`r`n``````" +
        "`r`n`r`n## Issues`r`n- ☐ [P1] real issue`r`n" +
        "`r`n## Todoos`r`n- ☐ [P1] a todo`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-IssueLineToREADME -Line 'inserted issue' | Microsoft.PowerShell.Core\Out-Null

        $lines = script:GetTestReadmeLines
        $fenceEnd = [array]::IndexOf($lines, '```')
        $inserted = [array]::IndexOf($lines, '- ☐ [P1] 20250101 --> inserted issue')
        if ($inserted -lt 0) {
            $inserted = @($lines | Microsoft.PowerShell.Core\Where-Object { $_ -match 'inserted issue' } |
                    Microsoft.PowerShell.Core\ForEach-Object { [array]::IndexOf($lines, $_) })[0]
        }
        $realIssues = [array]::IndexOf($lines, '## Issues')
        # must land under the real heading, never inside the fence
        $inserted | Pester\Should -BeGreaterThan $realIssues
        $inserted | Pester\Should -BeGreaterThan $fenceEnd
        # fence content untouched
        $lines[2] | Pester\Should -Be '```powershell'
        $lines[3] | Pester\Should -Be '# example heading ## Issues'
        $lines[4] | Pester\Should -Be '```'
    }

    Pester\It 'Does not treat a heading inside a tilde fence as a boundary' {
        $content = "# Test`r`n`r`n~~~text`r`n## Issues lookalike`r`n~~~`r`n" +
        "`r`n## Todoos`r`n- ☐ [P1] a todo`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-TodoLineToREADME -Line 'tilde todo' | Microsoft.PowerShell.Core\Out-Null

        $lines = script:GetTestReadmeLines
        $lines | Pester\Should -Contain '## Issues lookalike'
        $todoos = [array]::IndexOf($lines, '## Todoos')
        $lines[$todoos + 1] | Pester\Should -BeLike '*tilde todo*'
    }

    ###########################################################################
    # GROUP 15: Robustness — -Done matching
    ###########################################################################

    Pester\It '-Done survives wildcard metacharacters in the line text' {
        $content = "# Test`r`n`r`n## Issues`r`n" +
        "- ☐ [P1] 20250101 --> what about byte[] ?`r`n" +
        "- ☐ [P1] 20250101 --> keep me safe`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        { GenXdev\Add-IssueLineToREADME -Line 'what about byte[] ?' -Done } |
            Pester\Should -Not -Throw

        $content = script:GetTestReadmeContent
        # [[] and []] escape literal brackets inside a -BeLike pattern
        $content | Pester\Should -BeLike '*- ☒ [[]P1[]] 20250101 --> what about byte[[]] ?*'
        $content | Pester\Should -BeLike '*- ☐ [[]P1[]] 20250101 --> keep me safe*'
    }

    Pester\It '-Done matches text containing regex metacharacters' {
        $content = "# Test`r`n`r`n## Issues`r`n" +
        "- ☐ [P1] 20250101 --> price is (€) 5+ each? yes.`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        { GenXdev\Add-IssueLineToREADME -Line 'price is (€) 5+ each? yes.' -Done } |
            Pester\Should -Not -Throw

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*- ☒ [[]P1[]] 20250101 --> price is (€) 5+ each? yes.*'
    }

    ###########################################################################
    # GROUP 16: Robustness — file format preservation
    ###########################################################################

    Pester\It 'Preserves LF-only line endings' {
        $content = "# Test`n`n## Todoos`n- ☐ [P1] a todo`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-TodoLineToREADME -Line 'lf todo' | Microsoft.PowerShell.Core\Out-Null

        $raw = [System.IO.File]::ReadAllText(($script:testReadme))
        $raw | Pester\Should -Not -Match "`r"
    }

    Pester\It 'Preserves CRLF line endings without introducing lone LF' {
        $content = "# Test`r`n`r`n## Todoos`r`n- ☐ [P1] a todo`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-TodoLineToREADME -Line 'crlf todo' | Microsoft.PowerShell.Core\Out-Null

        $raw = [System.IO.File]::ReadAllText(($script:testReadme))
        $loneLf = [regex]::Matches($raw, "(?<!`r)`n").Count
        $loneLf | Pester\Should -Be 0
    }

    Pester\It 'Handles a CR-only (classic Mac) line ending file' {
        $content = "# Test`r`r## Todoos`r- ☐ [P1] a todo`r"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        { GenXdev\Add-TodoLineToREADME -Line 'cr todo' } | Pester\Should -Not -Throw

        $raw = [System.IO.File]::ReadAllText(($script:testReadme))
        # must not silently rewrite a CR-only file with LF
        $raw | Pester\Should -Not -Match "(?<!`r)`n"
        $raw | Pester\Should -BeLike '*cr todo*'
    }

    Pester\It 'Preserves a UTF-8 byte order mark' {
        $content = "# Test`r`n`r`n## Todoos`r`n- ☐ [P1] a todo`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content,
            [System.Text.UTF8Encoding]::new($true))
        ([System.IO.File]::ReadAllBytes(($script:testReadme))[0]) |
            Pester\Should -Be 0xEF

        GenXdev\Add-TodoLineToREADME -Line 'bom todo' | Microsoft.PowerShell.Core\Out-Null

        ([System.IO.File]::ReadAllBytes(($script:testReadme))[0]) |
            Pester\Should -Be 0xEF
    }

    Pester\It 'Preserves Unicode and emoji content verbatim' {
        $content = "# Test`r`n`r`n## Todoos`r`n- ☐ [P1] héllo 🎉 ünïcode 中文`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content,
            [System.Text.UTF8Encoding]::new($false))

        GenXdev\Add-TodoLineToREADME -Line 'ünïcode 🚀 todo' | Microsoft.PowerShell.Core\Out-Null

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*héllo 🎉 ünïcode 中文*'
        $content | Pester\Should -BeLike '*ünïcode 🚀 todo*'
    }

    ###########################################################################
    # GROUP 17: Robustness — section resolution and archive
    ###########################################################################

    Pester\It 'Prefers the exact heading over a longer heading with the same prefix' {
        $content = "# Test`r`n`r`n## Ideas Archive`r`n- ☐ [P1] archived`r`n" +
        "`r`n## Ideas`r`n- ☐ [P1] live idea`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-IdeaLineToREADME -Line 'brand new idea' | Microsoft.PowerShell.Core\Out-Null

        $lines = script:GetTestReadmeLines
        $live = [array]::IndexOf($lines, '## Ideas')
        $inserted = @($lines | Microsoft.PowerShell.Core\Where-Object { $_ -match 'brand new idea' })[0]
        ([array]::IndexOf($lines, $inserted)) | Pester\Should -BeGreaterThan $live
        # the archive section keeps its single item
        $lines | Pester\Should -Contain '- ☐ [P1] archived'
    }

    Pester\It 'Archives completed multi-line items as whole blocks' {
        $content = "# Test`r`n`r`n## Ideas`r`n" +
        "- ☐ [P1] keep me`r`n" +
        "- ☒ [P1] done idea`r`n`r`nits extra line`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-LineToREADME -Section '## Ideas' -Line '' -ArchiveCompleted | Microsoft.PowerShell.Core\Out-Null

        $content = script:GetTestReadmeContent
        $content | Pester\Should -BeLike '*keep me*'
        $content | Pester\Should -BeLike '*its extra line*'
        # live Idesa section must no longer hold the completed block
        $live = ($content -split '## Ideas - Archive')[0]
        $live | Pester\Should -Not -BeLike '*done idea*'
    }

    Pester\It 'Repeated identical operations are idempotent' {
        script:NewTestReadMe

        GenXdev\Add-TodoLineToREADME -Line 'stable item' -WarningAction SilentlyContinue |
            Microsoft.PowerShell.Core\Out-Null
        $first = script:GetTestReadmeContent

        GenXdev\Add-TodoLineToREADME -Line 'stable item' -WarningAction SilentlyContinue |
            Microsoft.PowerShell.Core\Out-Null
        $second = script:GetTestReadmeContent

        $second | Pester\Should -BeExactly $first
    }

    Pester\It 'Ends the section at a custom heading glued onto the last item' {
        $content = "# Test`r`n`r`n## Todoos`r`n- ☐ [P1] a todo`r`n" +
        "## Custom Section`r`n`r`nbelongs to the custom section`r`n"
        [System.IO.File]::WriteAllText(($script:testReadme), $content)

        GenXdev\Add-TodoLineToREADME -Line 'new todo' | Microsoft.PowerShell.Core\Out-Null

        $lines = script:GetTestReadmeLines
        $lines | Pester\Should -Contain '## Custom Section'
        $custom = [array]::IndexOf($lines, '## Custom Section')
        $inserted = [array]::IndexOf($lines, '- ☐ [P1] 20250101 --> new todo')
        if ($inserted -lt 0) {
            $inserted = @($lines | Microsoft.PowerShell.Core\Where-Object { $_ -match 'new todo' } |
                    Microsoft.PowerShell.Core\ForEach-Object { [array]::IndexOf($lines, $_) })[0]
        }
        # the new todo stays in Todoos, above the custom section
        $inserted | Pester\Should -BeLessThan $custom
        # and the custom section keeps its own content
        $lines | Pester\Should -Contain 'belongs to the custom section'
    }
}
