# Get-ChildProcesses

> **SubModule:** GenXdev.Windows | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Retrieves all processes that are descendants of the current PowerShell
process.

## Description

* Examines all running processes and identifies those that have the current
  PowerShell process as an ancestor in their parent process chain.
* This includes both direct child processes and their descendants
  (grandchildren, etc.).


## Syntax

```powershell
Get-ChildProcesses [<CommonParameters>]
```

## Examples

### Examples 1

```powershell
Get-ChildProcesses
```

Get all child processes of the current PowerShell session.

### Examples 2

```powershell
Get-ChildProcesses -Verbose
```

Get child processes with verbose output showing detailed process detection
information.

## Related Links

- [CurrentUserHasElevatedRights](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/CurrentUserHasElevatedRights.md)
- [Enable-Screensaver](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Enable-Screensaver.md)
- [Get-ActiveUser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ActiveUser.md)
- [Get-ClipboardFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ClipboardFiles.md)
- [Get-CurrentFocusedProcess](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CurrentFocusedProcess.md)
- [Get-DesktopScalingFactor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DesktopScalingFactor.md)
- [Get-ForegroundWindow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ForegroundWindow.md)
- [Get-KnownFolderPath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KnownFolderPath.md)
- [Get-MpCmdRunPath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MpCmdRunPath.md)
- [Get-PowershellMainWindow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PowershellMainWindow.md)
- [Get-PowershellMainWindowProcess](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PowershellMainWindowProcess.md)
- [Get-Window](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Window.md)
- [Get-WindowPosition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WindowPosition.md)
- [Initialize-ScheduledTaskScripts](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Initialize-ScheduledTaskScripts.md)
- [Invoke-CommandElevated](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-CommandElevated.md)
- [Invoke-WindowsUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WindowsUpdate.md)
- [Pop-Window](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Pop-Window.md)
- [Push-Window](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Push-Window.md)
- [Save-DesktopScreenShot](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Save-DesktopScreenShot.md)
- [Send-Key](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Send-Key.md)
- [Send-WakeOnLan](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Send-WakeOnLan.md)
- [Set-ClipboardFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ClipboardFiles.md)
- [Set-ForegroundWindow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ForegroundWindow.md)
- [Set-KnownFolderPath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-KnownFolderPath.md)
- [Set-MonitorPowerOff](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-MonitorPowerOff.md)
- [Set-MonitorPowerOn](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-MonitorPowerOn.md)
- [Set-TaskbarAlignment](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-TaskbarAlignment.md)
- [Set-WindowPosition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WindowPosition.md)
- [Set-WindowPositionForSecondary](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WindowPositionForSecondary.md)
- [Set-WindowsWallpaper](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WindowsWallpaper.md)
- [Show-ExceptionPanel](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-ExceptionPanel.md)
- [Start-ProcessElevated](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-ProcessElevated.md)
- [Start-ProcessWithPriority](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-ProcessWithPriority.md)
- [Test-PathUsingWindowsDefender](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-PathUsingWindowsDefender.md)
- [Update-Environment](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-Environment.md)
