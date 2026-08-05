# Test-CpuAvx

> **SubModule:** GenXdev.Hardware | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Tests whether the CPU supports AVX and AVX2 instruction sets.

## Description

* Checks if the processor supports AVX and AVX2 instruction sets using
  Windows API (kernel32.dll IsProcessorFeaturePresent).
* Returns an object with AVX and AVX2 boolean properties.
* Useful for determining hardware compatibility for AI/ML workloads.


## Syntax

```powershell
Test-CpuAvx [<CommonParameters>]
```

## Examples

### Examples 1

```powershell
Test-CpuAvx
```

Checks CPU instruction set support and returns AVX/AVX2 availability.

## Related Links

- [Get-AudioDeviceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AudioDeviceNames.md)
- [Get-CpuCore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CpuCore.md)
- [Get-HasCapableGpu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-HasCapableGpu.md)
- [Get-MonitorCount](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MonitorCount.md)
- [Get-NumberOfCpuCores](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-NumberOfCpuCores.md)
- [Out-Serial](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Out-Serial.md)
