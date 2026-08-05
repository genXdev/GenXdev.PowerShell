using System.Diagnostics;
using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets window information for specified processes or window handles.
.DESCRIPTION
* Retrieves window information using process name, ID, or window handle.
* Returns WindowObj objects containing details about the main windows of
  matching processes.
* Supports wildcards when searching by process name.

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
Get-Window -ProcessName ""notepad""
```

Retrieves window information for all processes named ""notepad"".
.EXAMPLE
```powershell
Get-Window -ProcessId 1234
```

Retrieves window information for the process with ID 1234.
.EXAMPLE
```powershell
Get-Window -WindowHandle 45678
```

Retrieves window information for the window with handle 45678.
")]
    [Cmdlet(VerbsCommon.Get, "Window")]
    [OutputType(typeof(GenXdev.Helpers.WindowObj))]
    public class GetWindowCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Name of the process(es) to get window information for
        /// </summary>
        [Parameter(
            Position = 0,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Name of the process to get window information for"
        )]
        [ValidateNotNullOrEmpty]
        [Alias("Name")]
        [SupportsWildcards]
        public string ProcessName { get; set; }

        /// <summary>
        /// Process ID to get window information for
        /// </summary>
        [Parameter(
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "ID of the process to get window information for"
        )]
        [ValidateNotNull]
        [Alias("Id", "PID")]
        public int ProcessId { get; set; }

        /// <summary>
        /// Window handle to get information for
        /// </summary>
        [Parameter(
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Window handle to get information for"
        )]
        [ValidateNotNull]
        [Alias("Handle", "hWnd")]
        public long WindowHandle { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting Get-Window with ParameterSet: " + this.ParameterSetName);
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Diagnostic: Print all screens' DeviceName and WorkingArea
            try
            {
                var allScreens = WpfScreenHelper.Screen.AllScreens;
                foreach (var screen in allScreens)
                {
                    var wa = screen.WorkingArea;
                    var dev = screen.DeviceName;
                    WriteVerbose($"Screen: {dev}, WorkingArea: X={wa.X} Y={wa.Y} W={wa.Width} H={wa.Height}");
                }
            }
            catch
            {
            }

            // if window handle provided, get window info directly
            if (WindowHandle != 0)
            {
                WriteVerbose($"Getting window information for handle: {WindowHandle}");
                var results = GenXdev.Helpers.WindowObj.GetMainWindow((IntPtr)WindowHandle);
                foreach (var result in results)
                {
                    WriteObject(result);
                }
                return;
            }

            // if process id provided, get window info for that specific process
            if (ProcessId != 0)
            {
                WriteVerbose($"Getting window information for process ID: {ProcessId}");
                var process = Process.GetProcessById(ProcessId);
                if (process != null && process.MainWindowHandle != IntPtr.Zero)
                {
                    var results = GenXdev.Helpers.WindowObj.GetMainWindow(process);
                    foreach (var result in results)
                    {
                        WriteObject(result);
                    }
                }
                return;
            }

            // get window info for all processes matching the name pattern
            WriteVerbose($"Getting window information for process name: {ProcessName}");
            string processNamePattern = ProcessName;
            if (!processNamePattern.Contains('*') && !processNamePattern.Contains('?'))
            {
                processNamePattern = $"{processNamePattern}*";
            }

            // Use InvokeCommand to get processes with wildcard support
            var scriptBlock = ScriptBlock.Create("param($name) Microsoft.PowerShell.Management\\Get-Process $name -ErrorAction SilentlyContinue");
            var processResults = scriptBlock.Invoke(processNamePattern);

            foreach (var processResult in processResults)
            {
                dynamic process = processResult.BaseObject;
                if (process.MainWindowHandle != IntPtr.Zero)
                {
                    var results = GenXdev.Helpers.WindowObj.GetMainWindow(process);
                    foreach (var result in results)
                    {
                        WriteObject(result);
                    }
                }
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