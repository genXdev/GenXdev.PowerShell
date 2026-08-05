# Get-NumberOfCpuCores

> **SubModule:** GenXdev.Hardware | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Calculates and returns the total number of logical CPU cores in the system.

## Description

Queries the system hardware through Windows Management Instrumentation (WMI) to determine the total number of logical CPU cores. The cmdlet accounts for hyperthreading by multiplying the physical core count by 2. This information is useful for optimizing parallel processing tasks and understanding system capabilities.


## Syntax

```powershell
Get-NumberOfCpuCores [<CommonParameters>]
```

## Examples

### Examples 1

```powershell
$cores = Get-NumberOfCpuCores
Write-Host "System has $cores logical CPU cores available"
```

Retrieves the total number of logical CPU cores available on the system.

## Related Links

- [Get-AudioDeviceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AudioDeviceNames.md)
- [Get-CpuCore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CpuCore.md)
- [Get-HasCapableGpu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-HasCapableGpu.md)
- [Get-MonitorCount](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MonitorCount.md)
- [Out-Serial](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Out-Serial.md)
- [Test-CpuAvx](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-CpuAvx.md)
