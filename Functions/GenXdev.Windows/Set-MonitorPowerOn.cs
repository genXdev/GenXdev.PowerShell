using System.Management.Automation;
using GenXdev.Helpers;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Turns the monitor power on.
.DESCRIPTION
Uses the Windows API through GenXdev.Helpers.WindowObj to wake up the monitor from sleep/power off state. This is useful for automation scripts that need to ensure the monitor is powered on.

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
Set-MonitorPowerOn
```

Turns the monitor power on.

.EXAMPLE
```powershell
wake-monitor
```

Turns the monitor power on using an alias.
")]
    [Cmdlet(VerbsCommon.Set, "MonitorPowerOn")]
    [Alias("wakemonitor", "monitoroff")]
    [OutputType(typeof(void))]
    public class SetMonitorPowerOnCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Attempting to wake monitor from sleep/power off state");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // only proceed if ShouldProcess approves the action
            if (ShouldProcess("Monitor", "Power On"))
            {
                // call the windows api through our helper class to wake the monitor
                WindowObj.WakeMonitor();
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