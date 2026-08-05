# Get-CpuCore

> **SubModule:** GenXdev.Hardware | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Calculates and returns the total number of logical CPU cores in the system.

## Description

Queries the system hardware through Windows Management Instrumentation (WMI) to determine the total number of logical CPU cores. The function accounts for hyperthreading by multiplying the physical core count by 2.


## Syntax

```powershell
Get-CpuCore [<CommonParameters>]
```

## Examples

### Examples 1

```powershell
Get-CpuCore
```

Gets the total number of logical CPU cores.

## Related Links

- [Get-AudioDeviceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AudioDeviceNames.md)
- [Get-HasCapableGpu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-HasCapableGpu.md)
- [Get-MonitorCount](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MonitorCount.md)
- [Get-NumberOfCpuCores](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-NumberOfCpuCores.md)
- [Out-Serial](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Out-Serial.md)
- [Test-CpuAvx](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-CpuAvx.md)
