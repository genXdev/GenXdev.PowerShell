# Add-IssueLineToREADME

> **SubModule:** GenXdev.Coding | **Type:** Function | **Aliases:** `issue`

## Synopsis

> Adds an issue item to the README.md file.

## Description

Adds a timestamped issue to the "## Issues" section of a README.md file.
Can display the modified section and open in Visual Studio Code.


## Syntax

```powershell
Add-IssueLineToREADME [[-Line] <String>] [[-Priority] <Int32>] [-ArchiveCompleted] [-ArchiveFilePath <String>] [-Ascending] [-Code] [-Done] [-ExcludeCompleted] [-First <Int32>] [-OnlyCompleted] [-Show] [-SortByDate] [-UseHomeREADME] [-UseOneDriveREADME] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Line` | String | ☐ | The issue text to add |
| `-Done` | SwitchParameter | ☐ | Mark issue as completed |
| `-Code` | SwitchParameter | ☐ | Open README in Visual Studio Code |
| `-Show` | SwitchParameter | ☐ | Show the modified section |
| `-UseHomeREADME` | SwitchParameter | ☐ | Use README in PowerShell profile directory |
| `-UseOneDriveREADME` | SwitchParameter | ☐ | Use README in OneDrive directory |
| `-Priority` | Int32 | ☐ | Priority for sorting (higher = shown first,<br>default 1) |
| `-SortByDate` | SwitchParameter | ☐ | Sort lines by date (yyyyMMdd prefix) instead<br>of priority |
| `-Ascending` | SwitchParameter | ☐ | Reverse the sort order (ascending instead of<br>descending) |
| `-First` | Int32 | ☐ | Limit -Show output to the first N lines |
| `-OnlyCompleted` | SwitchParameter | ☐ | Show only completed (☒) items when used with<br>-Show |
| `-ExcludeCompleted` | SwitchParameter | ☐ | Exclude completed (☒) items when used with<br>-Show |
| `-ArchiveCompleted` | SwitchParameter | ☐ | Archive completed items from this section |
| `-ArchiveFilePath` | String | ☐ | File path for archiving completed items<br>externally |

## Examples

### Add-IssueLineToREADME -Line "Found critical bug" -Show -UseHomeREADME

```powershell
Add-IssueLineToREADME -Line "Found critical bug" -Show -UseHomeREADME
```

### issue "Server connection fails" -Show

```powershell
issue "Server connection fails" -Show
```

## Parameter Details

### `-Line <String>`

> The issue text to add

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `''` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Done`

> Mark issue as completed

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Code`

> Open README in Visual Studio Code

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Show`

> Show the modified section

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-UseHomeREADME`

> Use README in PowerShell profile directory

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-UseOneDriveREADME`

> Use README in OneDrive directory

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Priority <Int32>`

> Priority for sorting (higher = shown first, default 1)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SortByDate`

> Sort lines by date (yyyyMMdd prefix) instead of priority

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Ascending`

> Reverse the sort order (ascending instead of descending)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-First <Int32>`

> Limit -Show output to the first N lines

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-OnlyCompleted`

> Show only completed (☒) items when used with -Show

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ExcludeCompleted`

> Exclude completed (☒) items when used with -Show

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ArchiveCompleted`

> Archive completed items from this section

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ArchiveFilePath <String>`

> File path for archiving completed items externally

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Add-FeatureLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-FeatureLineToREADME.md)
- [Add-IdeaLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-IdeaLineToREADME.md)
- [Add-LineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-LineToREADME.md)
- [Add-ReleaseNoteLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-ReleaseNoteLineToREADME.md)
- [Add-TodoLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-TodoLineToREADME.md)
- [Backup-CompletedFeatures](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedFeatures.md)
- [Backup-CompletedIdeas](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedIdeas.md)
- [Backup-CompletedIssues](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedIssues.md)
- [Backup-CompletedReleaseNotes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedReleaseNotes.md)
- [Backup-CompletedTodoos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedTodoos.md)
- [Backup-READMESections](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-READMESections.md)
- [Get-Features](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Features.md)
- [Get-Ideas](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Ideas.md)
- [Get-Issues](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Issues.md)
- [Get-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Refactor.md)
- [Get-RefactorReport](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RefactorReport.md)
- [Get-ReleaseNotes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ReleaseNotes.md)
- [Get-Todoos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Todoos.md)
- [New-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-Refactor.md)
- [Open-SourceFileInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SourceFileInIde.md)
- [Publish-ReleaseNotesToManifest](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Publish-ReleaseNotesToManifest.md)
- [Remove-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-Refactor.md)
- [Start-NextRefactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-NextRefactor.md)
- [Update-Refactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-Refactor.md)
- [VSCode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/VSCode.md)
