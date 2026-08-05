# Pop-Window

> **SubModule:** GenXdev.Windows | **Type:** Function | **Aliases:** `popw`

## Synopsis

> Pops the last active window helper from the stack with optional modifications.

## Description

Pops a window helper from the stack and optionally applies window transformations.
If the stack is empty or contains invalid windows, returns the currently focused
window. This function allows you to manipulate windows that were previously saved
with Push-Window, applying various positioning, sizing, and visual effects.


## Syntax

```powershell
Pop-Window [-AlwaysOnTop] [-Bottom] [-Centered] [-FadeIn] [-Focus] -Height <Int32> [-Hide] [-Left] [-Maximize] [-Minimize] [-Monitor <Int32>] [-NoBorders] [-Opacity <Byte>] [-Restore] [-Right] [-Show] [-ShowWindow] [-Top] -Width <Int32> [<CommonParameters>]

Pop-Window [-AlwaysOnTop] [-Bottom] [-Centered] [-FadeIn] [-Focus] [-Hide] [-Left] [-Maximize] [-Minimize] [-Monitor <Int32>] [-NoBorders] [-Opacity <Byte>] [-Restore] [-Right] [-Show] [-ShowWindow] [-Top] -X <Int32> -Y <Int32> [<CommonParameters>]

Pop-Window [-AlwaysOnTop] [-Bottom] [-Centered] [-FadeIn] [-Focus] [-Hide] [-Left] [-Maximize] [-Minimize] [-Monitor <Int32>] [-NoBorders] [-Opacity <Byte>] [-Restore] [-Right] [-Show] [-ShowWindow] [-Top] [<CommonParameters>]

Pop-Window [-NoModify] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Maximize` | SwitchParameter | ☐ | The `-Maximize` parameter. |
| `-Minimize` | SwitchParameter | ☐ | The `-Minimize` parameter. |
| `-Restore` | SwitchParameter | ☐ | The `-Restore` parameter. |
| `-Hide` | SwitchParameter | ☐ | The `-Hide` parameter. |
| `-Show` | SwitchParameter | ☐ | The `-Show` parameter. |
| `-NoBorders` | SwitchParameter | ☐ | The `-NoBorders` parameter. |
| `-AlwaysOnTop` | SwitchParameter | ☐ | The `-AlwaysOnTop` parameter. |
| `-Opacity` | Byte | ☐ | The `-Opacity` parameter. |
| `-X` | Int32 | ✅ | The `-X` parameter. |
| `-Y` | Int32 | ✅ | The `-Y` parameter. |
| `-Width` | Int32 | ✅ | The `-Width` parameter. |
| `-Height` | Int32 | ✅ | The `-Height` parameter. |
| `-Focus` | SwitchParameter | ☐ | The `-Focus` parameter. |
| `-FadeIn` | SwitchParameter | ☐ | The `-FadeIn` parameter. |
| `-NoModify` | SwitchParameter | ☐ | The `-NoModify` parameter. |
| `-Left` | SwitchParameter | ☐ | The `-Left` parameter. |
| `-Right` | SwitchParameter | ☐ | The `-Right` parameter. |
| `-Top` | SwitchParameter | ☐ | The `-Top` parameter. |
| `-Bottom` | SwitchParameter | ☐ | The `-Bottom` parameter. |
| `-Centered` | SwitchParameter | ☐ | The `-Centered` parameter. |
| `-ShowWindow` | SwitchParameter | ☐ | The `-ShowWindow` parameter. |
| `-Monitor` | Int32 | ☐ | The `-Monitor` parameter. |

## Examples

### Pop-Window -Maximize -Focus Pops the last window from the stack, maximizes it and gives it focus.

```powershell
Pop-Window -Maximize -Focus
Pops the last window from the stack, maximizes it and gives it focus.
```

### Pop-Window -X 100 -Y 100 -Width 800 -Height 600 -AlwaysOnTop Pops the last window, positions it at coordinates (100,100), resizes it to 800x600, and sets it to always stay on top.

```powershell
Pop-Window -X 100 -Y 100 -Width 800 -Height 600 -AlwaysOnTop
Pops the last window, positions it at coordinates (100,100),
resizes it to 800x600, and sets it to always stay on top.
```

### popw -Left -Focus Pops the last window, positions it on the left half of the screen, and gives it focus using the alias.

```powershell
popw -Left -Focus
Pops the last window, positions it on the left half of the screen,
and gives it focus using the alias.
```

### Pop-Window -Monitor 1 -Maximize Pops the last window, moves it to the first monitor, and maximizes it.

```powershell
Pop-Window -Monitor 1 -Maximize
Pops the last window, moves it to the first monitor, and maximizes it.
```

### Pop-Window -Monitor -2 -Fullscreen Pops the last window, moves it to the secondary monitor, and makes it fullscreen. ##############################################################################

```powershell
Pop-Window -Monitor -2 -Fullscreen
Pops the last window, moves it to the secondary monitor, and makes it fullscreen.
##############################################################################
```

## Parameter Details

### `-Maximize`

> The `-Maximize` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Minimize`

> The `-Minimize` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Restore`

> The `-Restore` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Hide`

> The `-Hide` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Show`

> The `-Show` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-NoBorders`

> The `-NoBorders` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nb` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-AlwaysOnTop`

> The `-AlwaysOnTop` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Opacity <Byte>`

> The `-Opacity` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-X <Int32>`

> The `-X` parameter.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | Named |
| **Default value** | `-999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Position |

<hr/>

### `-Y <Int32>`

> The `-Y` parameter.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | Named |
| **Default value** | `-999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Position |

<hr/>

### `-Width <Int32>`

> The `-Width` parameter.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Height <Int32>`

> The `-Height` parameter.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Focus`

> The `-Focus` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-FadeIn`

> The `-FadeIn` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-NoModify`

> The `-NoModify` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | NoModify |

<hr/>

### `-Left`

> The `-Left` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Right`

> The `-Right` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Top`

> The `-Top` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Bottom`

> The `-Bottom` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Centered`

> The `-Centered` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-ShowWindow`

> The `-ShowWindow` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `sw` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

### `-Monitor <Int32>`

> The `-Monitor` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `m`, `mon` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Dimensions |

<hr/>

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
