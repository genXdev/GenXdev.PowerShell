using System.Diagnostics;
using System.Management.Automation;
using System.Runtime.InteropServices;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves the process object of the window that currently has keyboard focus.
.DESCRIPTION
* This cmdlet uses Windows API calls through P/Invoke to identify and
  return the Process object associated with the currently focused window.
* It leverages the User32.dll functions GetForegroundWindow and
  GetWindowThreadProcessId to determine which window has focus and obtain
  its associated process ID.

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
$focusedProcess = Get-CurrentFocusedProcess
Write-Host ""Active window process: $($focusedProcess.ProcessName)""
```

Retrieves the process object for the window that currently has keyboard
focus.
")]
    [Cmdlet(VerbsCommon.Get, "CurrentFocusedProcess")]
    [OutputType(typeof(System.Diagnostics.Process))]
    public class GetCurrentFocusedProcessCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// P/Invoke declarations for Windows API functions
        /// </summary>
        private static class User32
        {
            [DllImport("user32.dll")]
            public static extern IntPtr GetForegroundWindow();

            [DllImport("user32.dll")]
            public static extern int GetWindowThreadProcessId(IntPtr hWnd, out int processId);
        }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Get the handle to the currently active window
            WriteVerbose("Attempting to get foreground window handle");
            IntPtr foregroundWindow = User32.GetForegroundWindow();

            // Retrieve the process id associated with the window handle
            WriteVerbose("Getting process ID from window handle");
            int processId = 0;
            User32.GetWindowThreadProcessId(foregroundWindow, out processId);

            // Verify we got a valid process id
            if (processId != 0)
            {
                // Attempt to get the process object using the process id
                WriteVerbose($"Retrieving process object for ID: {processId}");
                try
                {
                    Process process = Process.GetProcessById(processId);

                    // Return the process if found
                    WriteVerbose($"Successfully found process: {process.ProcessName}");
                    WriteObject(process);
                    return;
                }
                catch (ArgumentException)
                {
                    // Process not found
                }
                catch (Exception ex)
                {
                    WriteWarning($"Error retrieving process: {ex.Message}");
                    return;
                }
            }

            WriteWarning("Could not retrieve process for the focused window");
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}