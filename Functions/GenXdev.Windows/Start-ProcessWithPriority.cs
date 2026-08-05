using System.Diagnostics;
using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Starts a process with a specified priority level.
.DESCRIPTION
* Launches an executable with a customizable priority level and provides
  options for waiting and process handling.
* Wraps Start-Process with additional functionality to control process
  priority and execution behavior.

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
Start-ProcessWithPriority -FilePath ""notepad.exe"" -Priority ""Low"" -NoWait
```

Starts Notepad with low priority and returns immediately.
.EXAMPLE
```powershell
nice notepad.exe -Priority High
```

Uses the 'nice' alias to start a process with high priority.
")]
    [Cmdlet(VerbsLifecycle.Start, "ProcessWithPriority")]
    [Alias("nice")]
    [OutputType(typeof(System.Diagnostics.Process))]
    public class StartProcessWithPriorityCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The path to the executable file to run
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Path to the executable to run")]
        [ValidateNotNullOrEmpty]
        public string FilePath { get; set; }

        /// <summary>
        /// Arguments to pass to the executable
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = "Arguments to pass to the executable")]
        public string[] ArgumentList { get; set; } = new string[0];

        /// <summary>
        /// Process priority level
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Process priority level")]
        [ValidateSet(
            "Idle",
            "BelowNormal",
            "Low",
            "Normal",
            "AboveNormal",
            "High",
            "RealTime")]
        public string Priority { get; set; } = "BelowNormal";

        /// <summary>
        /// Don't wait for process completion
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Don't wait for process completion")]
        public SwitchParameter NoWait { get; set; }

        /// <summary>
        /// Return the process object
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Return the process object")]
        public SwitchParameter PassThru { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Log the start of process execution with priority level
            WriteVerbose($"Starting process '{FilePath}' with priority '{Priority}'");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Check if the user wants to proceed with starting the process
            string processDescription = $"Start process '{FilePath}' with priority '{Priority}'";
            if (!ShouldProcess(processDescription))
            {
                return;
            }

            // Launch the process with specified parameters and capture its handle
            var startProcessScript = ScriptBlock.Create("param($FilePath, $ArgumentList) Start-Process -FilePath $FilePath -ArgumentList $ArgumentList -PassThru -NoNewWindow");
            var result = startProcessScript.Invoke(FilePath, ArgumentList);
            var process = (Process)((PSObject)result[0]).BaseObject;

            // Ensure the process started successfully
            if (process == null)
            {
                WriteWarning($"Failed to start process '{FilePath}'");
                return;
            }

            // Apply the requested priority level to the running process
            process.PriorityClass = (ProcessPriorityClass)System.Enum.Parse(typeof(ProcessPriorityClass), Priority);
            WriteVerbose($"Process started with ID: {process.Id}");

            // Return early if immediate execution is requested
            if (NoWait.ToBool())
            {
                WriteVerbose("Not waiting for process completion");
                if (PassThru.ToBool())
                {
                    WriteObject(process);
                }
                return;
            }

            // Block execution until the process completes
            WriteVerbose("Waiting for process to complete");
            process.WaitForExit();

            // Return process information if requested
            if (PassThru.ToBool())
            {
                WriteVerbose("Returning process object");
                WriteObject(process);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}