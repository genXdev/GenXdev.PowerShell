# Backup-READMESections

> **SubModule:** GenXdev.Coding | **Type:** Function | **Aliases:** `archive-readme-sections`

## Synopsis

> Archives completed items from all README sections to an external file.

## Description

Moves all completed (☒) items from all tracked README sections (Todoos,
Issues, Ideas, Features, and Release notes) to an external archive file.
Delegates to the individual Backup-Completed* cmdlets for each section.


## Syntax

```powershell
Backup-READMESections -Path <String> [-UseHomeREADME] [-UseOneDriveREADME] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Path` | String | ✅ | The file path where completed items from all<br>sections will be archived to |
| `-UseHomeREADME` | SwitchParameter | ☐ | Use README in PowerShell profile directory |
| `-UseOneDriveREADME` | SwitchParameter | ☐ | Use README in OneDrive directory |

## Examples

### Backup-READMESections -Path "C:\temp\full-archive.md"

```powershell
Backup-READMESections -Path "C:\temp\full-archive.md"
```

### archive-readme-sections -Path ".\archive.md" -UseHomeREADME

```powershell
archive-readme-sections -Path ".\archive.md" -UseHomeREADME
```

## Parameter Details

### `-Path <String>`

> The file path where completed items from all sections will be archived to

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
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

## Related Links

- [Add-FeatureLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-FeatureLineToREADME.md)
- [Add-IdeaLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-IdeaLineToREADME.md)
- [Add-IssueLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-IssueLineToREADME.md)
- [Add-LineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-LineToREADME.md)
- [Add-ReleaseNoteLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-ReleaseNoteLineToREADME.md)
- [Add-TodoLineToREADME](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-TodoLineToREADME.md)
- [Backup-CompletedFeatures](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedFeatures.md)
- [Backup-CompletedIdeas](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedIdeas.md)
- [Backup-CompletedIssues](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedIssues.md)
- [Backup-CompletedReleaseNotes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedReleaseNotes.md)
- [Backup-CompletedTodoos](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Backup-CompletedTodoos.md)
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
