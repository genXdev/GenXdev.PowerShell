# GenXdev.Coding

## Overview

GenXdev.Coding provides AI-powered code refactoring workflows and structured
README management. The refactoring engine lets you define sets of files that
need transformation, use LLM analysis to select candidates, and work through
them one at a time with AI assistance. The README management cmdlets maintain
timestamped, prioritized sections for features, ideas, issues, todos, and
release notes in your project documentation.

## Features

* AI-Powered Code Refactoring
    * Create and manage refactoring tasks with `New-Refactor`
      and `Update-Refactor`
    * Use LLM-based selection to identify files needing refactoring
    * Continue refactoring sessions with `Start-NextRefactor`
    * Prioritize refactoring tasks for optimal workflow
    * Manage all refactors with `Update-Refactor`
    * Generate detailed refactoring reports with `Get-RefactorReport`

* Documentation Management
    * Track features, ideas, issues, and todos in README files
    * Add timestamped entries with priorities for issues, ideas, features, todos and release notes
    * Merge release notes into module definition
    * View and manage documentation sections with dedicated cmdlets
    * Generate and maintain module documentation automatically with support for AI translations

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [New-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-Refactor.md) | `newrefactor` | Create a named refactoring set with file selection and AI prompt |
| [Start-NextRefactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-NextRefactor.md) | `nextrefactor` | Continue working through the next file in a refactor set |
| [Update-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-Refactor.md) | `updaterefactor` | Manage refactor sets — add/remove files, change prompts, reorder |
| [Get-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Refactor.md) | `refactors` | List and filter refactor definitions |
| [Get-RefactorReport](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RefactorReport.md) | `refactorreport` | Generate a status overview of all refactoring work |
| [Add-FeatureLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-FeatureLineToREADME.md) | `feature` | Add a timestamped feature entry to README |
| [Add-IssueLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-IssueLineToREADME.md) | `issue` | Add a timestamped issue entry to README |
| [Add-TodoLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-TodoLineToREADME.md) | `todo` | Add a timestamped todo entry to README |
| [Add-ReleaseNoteLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-ReleaseNoteLineToREADME.md) | `releasenote` | Add a timestamped release note to README |
| [Backup-CompletedTodoos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedTodoos.md) | `archive-todoos` | Archive completed todo items to an external file |
| [Backup-CompletedIssues](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedIssues.md) | `archive-issues` | Archive completed issue items to an external file |
| [Backup-CompletedIdeas](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedIdeas.md) | `archive-ideas` | Archive completed idea items to an external file |
| [Backup-CompletedFeatures](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedFeatures.md) | `archive-features` | Archive completed feature items to an external file |
| [Backup-CompletedReleaseNotes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedReleaseNotes.md) | `archive-releasenotes` | Archive completed release note items to an external file |
| [Backup-READMESections](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-READMESections.md) | `archive-readme-sections` | Archive completed items from all README sections at once |
| [Publish-ReleaseNotesToManifest](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Publish-ReleaseNotesToManifest.md) | `pubrelnotes` | Merge completed release notes into the module manifest |
| [Open-SourceFileInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SourceFileInIde.md) | `editcode` | Open a file in VS Code or Visual Studio |
| [VSCode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/VSCode.md) | — | Quick-open files in VS Code |

## How It All Comes Together

Refactoring follows a step-by-step workflow. You create a named refactor set
with `New-Refactor`, specifying a file scope and an AI prompt that describes
the transformation. `Start-NextRefactor` (`nextrefactor`) opens the next file
in your IDE. You make the change, then run `nextrefactor` again to advance.
`Update-Refactor` lets you adjust the set as you go, and `Get-RefactorReport`
shows progress across all active refactors. Completed refactors can be
removed with `Remove-Refactor`.

The README management cmdlets maintain structured sections in markdown files.
`feature`, `issue`, `todo`, `idea`, and `releasenote` each add a timestamped,
prioritized entry to the corresponding section of a README. `features`,
`issues`, `todoos`, `ideas`, and `releasenotes` display the entries.
`archive-todoos`, `archive-issues`, `archive-ideas`, `archive-features`, and
`archive-releasenotes` move completed (☒) items to an external archive file,
keeping the README clean. `archive-readme-sections` runs all five at once.
`Publish-ReleaseNotesToManifest` (`pubrelnotes`) merges completed release notes
into the module manifest.

`Open-SourceFileInIde` (`editcode`) and `VSCode` open files in VS Code or
Visual Studio.

## See Also

- [GenXdev.Coding.PowerShell.Modules](README-GenXdev.Coding.PowerShell.Modules.md) — Module development tooling
- [GenXdev.Coding.Git](README-GenXdev.Coding.Git.md) — Git history rewriting
- [GenXdev.Coding.Templating](README-GenXdev.Coding.Templating.md) — String templating
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevcoding)
