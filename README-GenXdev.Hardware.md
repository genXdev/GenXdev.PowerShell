# GenXdev.Hardware

## Overview

GenXdev.Hardware provides general helper cmdlets for system hardware introspection —
CPU capabilities (core count, AVX support), GPU detection (CUDA capability and memory),
monitor count, audio device enumeration, and serial port output.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Get-NumberOfCpuCores](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-NumberOfCpuCores.md) | — | Get the total number of logical CPU cores |
| [Get-CpuCore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-CpuCore.md) | — | Get CPU core count (same, used as dependency target) |
| [Test-CpuAvx](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-CpuAvx.md) | — | Check if the CPU supports AVX and AVX2 instruction sets |
| [Get-HasCapableGpu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-HasCapableGpu.md) | — | Check for a CUDA-capable GPU with sufficient memory |
| [Get-MonitorCount](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MonitorCount.md) | — | Get the number of connected displays |
| [Get-AudioDeviceNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AudioDeviceNames.md) | — | List available microphone and desktop audio devices |
| [Out-Serial](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Out-Serial.md) | — | Send a string to a serial (COM) port |

## How It All Comes Together

`Get-NumberOfCpuCores` and `Get-CpuCore` return the number of logical CPU
cores. `Test-CpuAvx` checks whether the CPU supports AVX and AVX2
instruction sets. `Get-HasCapableGpu` checks for a CUDA-capable GPU with
sufficient memory. `Get-MonitorCount` returns the number of connected
displays. `Get-AudioDeviceNames` lists available microphone and desktop
audio devices.

`Out-Serial` sends a string to a serial (COM) port.

## See Also

- [GenXdev.Software](README-GenXdev.Software.md) — Tool installation (uses GPU detection)
- [GenXdev.Windows](README-GenXdev.Windows.md) — Window and monitor management
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevhardware)
