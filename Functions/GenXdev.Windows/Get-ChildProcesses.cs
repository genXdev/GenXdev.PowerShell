using System.Diagnostics;
using System.Management;
using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves all processes that are descendants of the current PowerShell
process.
.DESCRIPTION
* Examines all running processes and identifies those that have the current
  PowerShell process as an ancestor in their parent process chain.
* This includes both direct child processes and their descendants
  (grandchildren, etc.).

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
Get-ChildProcesses
```

Get all child processes of the current PowerShell session.
.EXAMPLE
```powershell
Get-ChildProcesses -Verbose
```

Get child processes with verbose output showing detailed process detection
information.
")]
    [Cmdlet(VerbsCommon.Get, "ChildProcesses")]
    [OutputType(typeof(Process))]
    public class GetChildProcessesCommand : PSGenXdevCmdlet
    {
        private int currentProcessId;
        private Dictionary<int, int> parentMap;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // log start of process detection
            WriteVerbose("Starting child process detection...");

            // store current powershell process id for parent chain comparison
            currentProcessId = Process.GetCurrentProcess().Id;
            WriteVerbose($"Current process ID: {currentProcessId}");

            // build parent process map for efficient lookups
            parentMap = new Dictionary<int, int>();
            ManagementObjectSearcher searcher = new ManagementObjectSearcher("SELECT ProcessId, ParentProcessId FROM Win32_Process");
            foreach (ManagementObject obj in searcher.Get())
            {
                int pid = Convert.ToInt32(obj["ProcessId"]);
                int parentId = Convert.ToInt32(obj["ParentProcessId"]);
                parentMap[pid] = parentId;
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // get all processes currently running on the system
            Process[] allProcesses = Process.GetProcesses();
            WriteVerbose($"Retrieved {allProcesses.Length} total processes");

            // filter processes by checking if current process is in their parent chain
            foreach (Process process in allProcesses)
            {
                if (IsDescendant(process.Id, currentProcessId))
                {
                    WriteVerbose($"Found child process: {process.ProcessName} ID: {process.Id}");
                    WriteObject(process);
                }
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            WriteVerbose("Completed child process detection");
        }

        /// <summary>
        /// Check if a process is a descendant of the specified ancestor by traversing the parent chain
        /// </summary>
        /// <param name="processId">The process ID to check</param>
        /// <param name="ancestorId">The ancestor process ID to look for</param>
        /// <returns>True if the process is a descendant, false otherwise</returns>
        private bool IsDescendant(int processId, int ancestorId)
        {
            // traverse up the parent chain until we find our process or hit top
            while (processId != 0 && parentMap.ContainsKey(processId))
            {
                if (processId == ancestorId)
                {
                    return true;
                }
                processId = parentMap[processId];
            }
            return false;
        }
    }
}