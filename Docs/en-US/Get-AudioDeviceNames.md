# Get-AudioDeviceNames

> **SubModule:** GenXdev.Hardware | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Retrieves the names of available audio devices for microphone or desktop audio capture.

## Description

Enumerates audio devices that can be used with other cmdlets that accept an AudioDevice parameter. It supports both microphone devices and desktop audio capture devices.


## Syntax

```powershell
Get-AudioDeviceNames [-Passthru] [-UseDesktopAudioCapture] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-UseDesktopAudioCapture` | SwitchParameter | ☐ | Whether to list desktop audio capture devices<br>instead of microphone devices |
| `-Passthru` | SwitchParameter | ☐ | Returns detailed device objects instead of<br>just names |

## Examples

### Examples 1

```powershell
Get-AudioDeviceNames
```

Retrieves a list of available microphone device names.

### Examples 2

```powershell
Get-AudioDeviceNames -UseDesktopAudioCapture
```

Retrieves a list of available desktop audio capture device names.

### Examples 3

```powershell
Get-AudioDeviceNames -Passthru
```

Retrieves detailed objects containing information about microphone devices.

## Parameter Details

### `-UseDesktopAudioCapture`

> Whether to list desktop audio capture devices instead of microphone devices

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Passthru`

> Returns detailed device objects instead of just names

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-CpuCore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CpuCore.md)
- [Get-HasCapableGpu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-HasCapableGpu.md)
- [Get-MonitorCount](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MonitorCount.md)
- [Get-NumberOfCpuCores](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-NumberOfCpuCores.md)
- [Out-Serial](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Out-Serial.md)
- [Test-CpuAvx](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-CpuAvx.md)
