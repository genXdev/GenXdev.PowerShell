# Set-MonitorPowerOff

> **SubModule:** GenXdev.Windows | **Type:** Cmdlet | **Aliases:** `poweroff`

## Synopsis

> Turns off power to all connected monitors.

## Description

Uses Windows API calls to send a power-off signal to all connected monitors. This is equivalent to pressing the physical power button on your monitors. The monitors will enter power saving mode but can be awakened by moving the mouse or pressing a key.


## Syntax

```powershell
Set-MonitorPowerOff [<CommonParameters>]
```

## Examples

### Examples 1

```powershell
Set-MonitorPowerOff
```

Turns off all connected monitors.

### Examples 2

```powershell
poweroff
```

Turns off all connected monitors using the alias.

## Related Links

- [CurrentUserHasElevatedRights](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/CurrentUserHasElevatedRights.md)
- [Enable-Screensaver](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Enable-Screensaver.md)
- [Get-ActiveUser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ActiveUser.md)
- [Get-ChildProcesses](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ChildProcesses.md)
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
