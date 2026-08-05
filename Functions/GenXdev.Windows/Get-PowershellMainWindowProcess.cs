using System.Diagnostics;
using System.Management;
using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Returns the process object for the window hosting the PowerShell terminal.
.DESCRIPTION
* Traverses up the process tree starting from the current PowerShell
  process to locate the parent window responsible for hosting the terminal.
* If the immediate parent process doesn't have a main window handle, it
  searches for similar processes that do have main windows.
* Useful for identifying the actual terminal window process (like Windows
  Terminal, ConHost, etc.) that contains the PowerShell session.

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
$hostProcess = Get-PowershellMainWindowProcess
Write-Host ""PowerShell is hosted in: $($hostProcess.ProcessName)""
```

Returns the process hosting the current PowerShell session and displays its
name.
")]
    [Cmdlet(VerbsCommon.Get, "PowershellMainWindowProcess")]
    [OutputType(typeof(System.Diagnostics.Process))]
    public class GetPowershellMainWindowProcessCommand : PSGenXdevCmdlet
    {
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
            // Get reference to the powershell process currently executing this code
            Process currentProcess = Process.GetCurrentProcess();

            // Initialize parent tracking, starting with current process
            Process parentProcess = GetParentProcess(currentProcess);

            // Log the starting point of our search
            WriteVerbose($"Starting process tree traversal from: {currentProcess.ProcessName}");

            // Traverse up process tree until we find a window or hit the root
            while ((parentProcess != null) && (parentProcess.MainWindowHandle == IntPtr.Zero) &&
                (GetParentProcess(parentProcess) != null))
            {
                parentProcess = GetParentProcess(parentProcess);
                WriteVerbose($"Examining parent process: {parentProcess.ProcessName}");
            }

            // If parent has a main window, use that process
            if ((parentProcess != null) && (parentProcess.MainWindowHandle != IntPtr.Zero) && (parentProcess.ProcessName != "explorer"))
            {
                WriteVerbose($"Found parent with main window: {parentProcess.ProcessName}");
                WriteObject(parentProcess);
            }
            else
            {
                WriteObject(currentProcess);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }

        /// <summary>
        /// Gets the parent process of the specified process using WMI
        /// </summary>
        /// <param name="process">The process to find the parent of</param>
        /// <returns>The parent process, or null if not found</returns>
        private Process GetParentProcess(Process process)
        {
            try
            {
                using (var searcher = new ManagementObjectSearcher(
                    $"SELECT ParentProcessId FROM Win32_Process WHERE ProcessId = {process.Id}"))
                {
                    foreach (ManagementObject obj in searcher.Get())
                    {
                        int parentId = (int)(uint)obj["ParentProcessId"];
                        return Process.GetProcessById(parentId);
                    }
                }
            }
            catch
            {
                // Ignore exceptions to maintain compatibility
            }
            return null;
        }
    }
}