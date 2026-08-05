# Get-MonitorCount

> **SubModule:** GenXdev.Hardware | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Gets the total number of display monitors connected to the system.

## Description

* Uses the Windows Presentation Foundation (WPF) Screen helper class to
  accurately determine the number of physical display monitors currently
  connected to the system.
* This includes both active and detected but disabled monitors.


## Syntax

```powershell
Get-MonitorCount [<CommonParameters>]
```

## Examples

### Examples 1

```powershell
Get-MonitorCount
```

Returns the total number of connected monitors (e.g. 2).

### Examples 2

```powershell
$screens = Get-MonitorCount -Verbose
```

Returns monitor count with verbose output showing detection process.

## Related Links

- [Get-AudioDeviceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AudioDeviceNames.md)
- [Get-CpuCore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CpuCore.md)
- [Get-HasCapableGpu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-HasCapableGpu.md)
- [Get-NumberOfCpuCores](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-NumberOfCpuCores.md)
- [Out-Serial](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Out-Serial.md)
- [Test-CpuAvx](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-CpuAvx.md)
