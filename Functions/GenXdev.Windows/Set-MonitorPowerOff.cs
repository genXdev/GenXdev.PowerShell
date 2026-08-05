using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Turns off power to all connected monitors.
.DESCRIPTION
Uses Windows API calls to send a power-off signal to all connected monitors. This is equivalent to pressing the physical power button on your monitors. The monitors will enter power saving mode but can be awakened by moving the mouse or pressing a key.

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
Set-MonitorPowerOff
```

Turns off all connected monitors.

.EXAMPLE
```powershell
poweroff
```

Turns off all connected monitors using the alias.
")]
    [Cmdlet(VerbsCommon.Set, "MonitorPowerOff")]
    [Alias("poweroff")]
    public class SetMonitorPowerOffCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Preparing to turn off monitor(s)...");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Wait briefly to allow any pending screen operations to complete
            System.Threading.Thread.Sleep(2000);

            // Check if we should proceed with turning off the monitors
            if (ShouldProcess("All Monitors", "Turn Off"))
            {
                // Invoke windows power management api to trigger monitor power-off
                GenXdev.Helpers.WindowObj.SleepMonitor();
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