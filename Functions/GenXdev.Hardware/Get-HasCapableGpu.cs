using System.Management;
using System.Management.Automation;

namespace GenXdev.Hardware
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Determines if a CUDA-capable GPU with sufficient memory is present.
.DESCRIPTION
Checks the system for CUDA-compatible GPUs with at least 4GB of video RAM. It uses Windows Management Instrumentation (WMI) to query installed video controllers and verify their memory capacity. This check is essential for AI workloads that require significant GPU memory.

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
$hasGpu = Get-HasCapableGpu
Write-Host ""System has capable GPU: $hasGpu""
```

Checks if the system has a CUDA-capable GPU with sufficient memory.
")]
    [Cmdlet(VerbsCommon.Get, "HasCapableGpu")]
    [OutputType(typeof(bool))]
    public class GetHasCapableGpuCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting GPU capability verification");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Define minimum required GPU memory (4GB in bytes)
            ulong requiredMemory = 1024UL * 1024UL * 1024UL * 4UL;

            // Query system for video controllers meeting memory requirement
            using (var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_VideoController"))
            {
                var controllers = searcher.Get();
                int capableGpuCount = 0;

                foreach (ManagementObject controller in controllers)
                {
                    var adapterRam = controller["AdapterRAM"] as ulong?;
                    if (adapterRam.HasValue && adapterRam.Value >= requiredMemory)
                    {
                        capableGpuCount++;
                    }
                }

                // Output number of capable GPUs found for debugging
                WriteVerbose($"Detected {capableGpuCount} GPUs with 4GB+ RAM");

                // Return true if at least one capable GPU was found
                WriteObject(capableGpuCount > 0);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}