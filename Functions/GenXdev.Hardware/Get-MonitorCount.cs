using System.Management.Automation;

namespace GenXdev.Hardware
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets the total number of display monitors connected to the system.
.DESCRIPTION
* Uses the Windows Presentation Foundation (WPF) Screen helper class to
  accurately determine the number of physical display monitors currently
  connected to the system.
* This includes both active and detected but disabled monitors.

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
Get-MonitorCount
```

Returns the total number of connected monitors (e.g. 2).
.EXAMPLE
```powershell
$screens = Get-MonitorCount -Verbose
```

Returns monitor count with verbose output showing detection process.
")]
    [Cmdlet(VerbsCommon.Get, "MonitorCount")]
    [OutputType(typeof(int))]
    public class GetMonitorCountCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting monitor detection using WpfScreenHelper.Screen");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Get the count of all connected screens using Windows Forms Screen class
            int screenCount = Screen.AllScreens.Length;

            WriteVerbose($"Detected {screenCount} physical monitor(s) connected");

            // Return the total number of monitors found
            WriteObject(screenCount);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}