# GenXdev.Coding.Git

## Overview

GenXdev.Coding.Git provides Git repository maintenance utilities — specifically
the ability to permanently purge files and folders from a repository's entire
history across all branches, rewriting the commit graph to remove sensitive or
unwanted data.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [PermanentlyDeleteGitFolders](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/PermanentlyDeleteGitFolders.md) | — | Purge folders from all branches and all commits in a Git repo |
| [Get-GitChangedFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GitChangedFiles.md) | `gitchanged` | List changed files in a Git repository |
| [New-GitCommit](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-GitCommit.md) | `commit` | Create and push a new git commit with all changes |

## How It All Comes Together

`PermanentlyDeleteGitFolders` removes specified directories from a Git
repository's entire history across all branches. Unlike `git rm`, which
only affects the current branch going forward, this rewrites the commit
history to purge the directories completely.

`Get-GitChangedFiles` (`gitchanged`) lists changed files in the current
repository. `New-GitCommit` (`commit`) stages all changes, creates a commit,
and pushes to the remote in a single command.

## See Also

- [GenXdev.Coding](README-GenXdev.Coding.md) — Refactoring and README management
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevcodinggit)
