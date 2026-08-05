# GenXdev.Windows

## Overview

GenXdev.Windows provides comprehensive Windows system control — window
management (get, set position, push/pop stack, foreground control), input
simulation (keystroke injection, clipboard file operations), system
administration (elevated commands, Windows Update, screensaver, environment
refresh), monitor control (power on/off, screenshots, DPI scaling), and
access to Windows known folders and taskbar settings.

## Features

* Allow resizing/repositioning/closing of Windows
* Get-Window will return a windows helper that allows you to manipulate the window
* Read/write access to Windows special folder locations

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Get-Window](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Window.md) | — | Get window handles and info for processes |
| [Get-WindowPosition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WindowPosition.md) | `gwp` | Get the position, size, and state of windows |
| [Set-WindowPosition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WindowPosition.md) | `wp` | Position and resize windows on any monitor |
| [Set-WindowPositionForSecondary](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WindowPositionForSecondary.md) | `wps` | Position a window on a secondary monitor |
| [Push-Window](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Push-Window.md) | `pushw` | Save current window position to a stack |
| [Pop-Window](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Pop-Window.md) | `popw` | Restore a window position from the stack |
| [Send-Key](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Send-Key.md) | `sendkeys`, `invokekeys` | Simulate keystrokes to any window |
| [Set-ClipboardFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ClipboardFiles.md) | `setclipfiles`, `scbf` | Set files to the clipboard for copy/paste |
| [Get-ClipboardFiles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ClipboardFiles.md) | `getclipfiles`, `gcbf` | Get files from the clipboard |
| [Get-KnownFolderPath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KnownFolderPath.md) | `folder` | Get the path of any Windows known folder |
| [Set-KnownFolderPath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-KnownFolderPath.md) | — | Redirect a Windows known folder to a new location |
| [Invoke-CommandElevated](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-CommandElevated.md) | — | Run code as administrator |
| [Invoke-WindowsUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WindowsUpdate.md) | `updatewindows` | Check for and install Windows updates |
| [Enable-Screensaver](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Enable-Screensaver.md) | — | Start the configured screensaver |
| [Set-TaskbarAlignment](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-TaskbarAlignment.md) | — | Set taskbar to left or center (Windows 11) |
| [Set-MonitorPowerOff](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-MonitorPowerOff.md) | `poweroff` | Turn off all monitors |
| [Set-MonitorPowerOn](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-MonitorPowerOn.md) | `wakemonitor`, `monitoroff` | Wake the monitors |
| [Send-WakeOnLan](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Send-WakeOnLan.md) | — | Send a Wake-on-LAN magic packet |
| [Show-ExceptionPanel](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-ExceptionPanel.md) | — | Display an exception in a Spectre.Console panel |
| [Update-Environment](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-Environment.md) | — | Refresh environment variables in the current session |

## How It All Comes Together

Window management: `Get-Window` gets window handles and info for processes.
`Get-WindowPosition` (`gwp`) gets window position, size, and state.
`Set-WindowPosition` (`wp`) positions and resizes windows on any monitor.
`Set-WindowPositionForSecondary` (`wps`) positions a window on a secondary
monitor. `Push-Window` (`pushw`) saves the current window position to a
stack. `Pop-Window` (`popw`) restores a window position from the stack.

Input: `Send-Key` (`sendkeys`, `invokekeys`) simulates keystrokes to a
window. `Set-ClipboardFiles` (`setclipfiles`, `scbf`) sets files to the
Windows clipboard. `Get-ClipboardFiles` (`getclipfiles`, `gcbf`) gets files
from the clipboard.

System: `Invoke-CommandElevated` runs code in an elevated PowerShell
session. `Invoke-WindowsUpdate` (`updatewindows`) checks for and installs
Windows updates. `Enable-Screensaver` starts the screensaver.
`Set-TaskbarAlignment` configures taskbar alignment. `Update-Environment`
refreshes environment variables. `Show-ExceptionPanel` displays an exception
in a Spectre.Console panel.

Known folders: `Get-KnownFolderPath` (`folder`) gets the path of a Windows
known folder. `Set-KnownFolderPath` redirects a known folder to a new
location.

Monitor: `Set-MonitorPowerOff` (`poweroff`) turns off monitors.
`Set-MonitorPowerOn` (`wakemonitor`, `monitoroff`) wakes monitors.
`Send-WakeOnLan` sends a Wake-on-LAN magic packet.

## See Also

- [GenXdev.Webbrowser](README-GenXdev.Webbrowser.md) — Browser window positioning
- [GenXdev.Console](README-GenXdev.Console.md) — Monitor configuration for browser placement
- [GenXdev.Hardware](README-GenXdev.Hardware.md) — Hardware detection (monitor count, etc.)
- [GenXdev.Windows.WireGuard](README-GenXdev.Windows.WireGuard.md) — WireGuard VPN management
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevwindows)
