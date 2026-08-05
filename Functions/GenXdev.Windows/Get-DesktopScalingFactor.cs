using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves the Windows display scaling factor (DPI setting) for a specified
monitor.
.DESCRIPTION
* Gets the current Windows display scaling factor configured for a monitor
  in the system.
* The scaling factor is expressed as a percentage where 100 represents
  standard scaling (96 DPI). Common values are 100, 125, 150, and 200.
* If no monitor is specified, returns the scaling factor for the primary
  display.

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
Get-DesktopScalingFactor -Monitor 0
```

Returns the scaling factor percentage for the primary monitor.
.EXAMPLE
```powershell
Get-DesktopScalingFactor 1
```

Returns the scaling factor percentage for the second monitor using positional
parameter.
")]
    [Cmdlet(VerbsCommon.Get, "DesktopScalingFactor")]
    [OutputType(typeof(System.Single))]
    public class GetDesktopScalingFactorCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Specifies the zero-based index of the monitor to check. The primary monitor is
        /// index 0, secondary monitor is 1, and so on. Valid values range from 0 to 99.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = false,
            HelpMessage = "The monitor index to check (0 = primary monitor)")]
        [ValidateRange(0, 99)]
        [Alias("m", "mon")]
        public int Monitor { get; set; } = 0;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Getting scaling factor for monitor index: " + Monitor);
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // invoke the native method to retrieve the current scaling factor
            // uses the GenXdev.Helpers.DesktopInfo class's static method
            var result = GenXdev.Helpers.DesktopInfo.getScalingFactor(Monitor);

            WriteObject(result);
        }
    }
}