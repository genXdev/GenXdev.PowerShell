# Get-HasCapableGpu

> **SubModule:** GenXdev.Hardware | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Determines if a CUDA-capable GPU with sufficient memory is present.

## Description

Checks the system for CUDA-compatible GPUs with at least 4GB of video RAM. It uses Windows Management Instrumentation (WMI) to query installed video controllers and verify their memory capacity. This check is essential for AI workloads that require significant GPU memory.


## Syntax

```powershell
Get-HasCapableGpu [<CommonParameters>]
```

## Examples

### Examples 1

```powershell
$hasGpu = Get-HasCapableGpu
Write-Host "System has capable GPU: $hasGpu"
```

Checks if the system has a CUDA-capable GPU with sufficient memory.

## Related Links

- [Get-AudioDeviceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AudioDeviceNames.md)
- [Get-CpuCore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CpuCore.md)
- [Get-MonitorCount](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MonitorCount.md)
- [Get-NumberOfCpuCores](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-NumberOfCpuCores.md)
- [Out-Serial](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Out-Serial.md)
- [Test-CpuAvx](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-CpuAvx.md)
