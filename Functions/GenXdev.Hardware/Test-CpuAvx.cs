using System.Management.Automation;
using System.Runtime.InteropServices;

namespace GenXdev.Hardware
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Tests whether the CPU supports AVX and AVX2 instruction sets.
.DESCRIPTION
* Checks if the processor supports AVX and AVX2 instruction sets using
  Windows API (kernel32.dll IsProcessorFeaturePresent).
* Returns an object with AVX and AVX2 boolean properties.
* Useful for determining hardware compatibility for AI/ML workloads.

.LICENSE
Copyright (C) 2026 René Vaessen / GenXdev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>.

.EXAMPLE
```powershell
Test-CpuAvx
```

Checks CPU instruction set support and returns AVX/AVX2 availability.
")]
    [Cmdlet(VerbsDiagnostic.Test, "CpuAvx")]
    public class TestCpuAvxCommand : Cmdlet
    {
        // Windows PF flags
        private const uint PF_AVX_INSTRUCTIONS_AVAILABLE = 12;
        private const uint PF_AVX2_INSTRUCTIONS_AVAILABLE = 13;

        [DllImport("kernel32.dll")]
        private static extern bool IsProcessorFeaturePresent(uint feature);

        protected override void ProcessRecord()
        {
            bool avx  = IsProcessorFeaturePresent(PF_AVX_INSTRUCTIONS_AVAILABLE);
            bool avx2 = IsProcessorFeaturePresent(PF_AVX2_INSTRUCTIONS_AVAILABLE);

            WriteObject(new
            {
                AVX  = avx,
                AVX2 = avx2
            });
        }
    }
}
