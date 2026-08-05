using System.Management;
using System.Management.Automation;

namespace GenXdev.Hardware
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates and returns the total number of logical CPU cores in the system.
.DESCRIPTION
Queries the system hardware through Windows Management Instrumentation (WMI) to determine the total number of logical CPU cores. The function accounts for hyperthreading by multiplying the physical core count by 2.

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
Get-CpuCore
```

Gets the total number of logical CPU cores.
")]
    [Cmdlet(VerbsCommon.Get, "CpuCore")]
    [OutputType(typeof(int))]
    public class GetCpuCoreCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Initialize counter for tracking total physical cores
        /// </summary>
        private int totalPhysicalCores = 0;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Initializing CPU core count calculation");
        }

        /// <summary>
        /// Process record - main cmdlet logic for calculating CPU cores
        /// </summary>
        protected override void ProcessRecord()
        {
            // Query physical processors through WMI
            var searcher = new ManagementObjectSearcher("SELECT * FROM Win32_Processor");
            var processors = searcher.Get();

            WriteVerbose($"Retrieved {processors.Count} physical processors");

            // Sum cores from each processor
            foreach (ManagementObject processor in processors)
            {
                int cores = (int)(uint)processor["NumberOfCores"];
                totalPhysicalCores += cores;
                WriteVerbose($"Added {cores} cores from processor");
            }

            // Account for hyperthreading
            int logicalCores = totalPhysicalCores * 2;
            WriteVerbose($"Final count: {logicalCores} logical cores");

            WriteObject(logicalCores);
        }

        /// <summary>
        /// End processing - cleanup logic (empty for this cmdlet)
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}