using System.Collections;
using System.Diagnostics;
using System.Management.Automation;
using System.Text;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Starts a process with elevated administrator privileges.

.DESCRIPTION
Wraps the built-in Start-Process cmdlet with automatic elevation. When the
current session is not elevated, the command is delegated to a persistent
elevated helper process via named pipe, avoiding repeated UAC prompts after
the first elevation. When already elevated, delegates directly to
Start-Process.

All parameters except -Verb and -Credential are inherited from Start-Process.
The -Verb parameter is forced to 'RunAs'.

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

.PARAMETER Elevated
When true (default), the process is started with elevated privileges. Set to
false to delegate directly to Start-Process without elevation.
.EXAMPLE
Start-ProcessElevated -FilePath 'notepad.exe'
Launches Notepad with administrator privileges.
.EXAMPLE
Start-ProcessElevated -FilePath 'winget.exe' -ArgumentList 'install',
'SomePackage' -Wait
Installs a package via winget with admin rights and waits for completion.
")]
    [Cmdlet(VerbsLifecycle.Start, "ProcessElevated")]
    [OutputType(typeof(System.Diagnostics.Process))]
    public class StartProcessElevatedCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Path to the executable file. Identical to Start-Process -FilePath.
        /// </summary>
        [Alias("PSPath", "Path")]
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Path to the executable file")]
        [ValidateNotNullOrEmpty]
        public string FilePath { get; set; }

        /// <summary>
        /// Arguments to pass to the executable. Identical to Start-Process
        /// -ArgumentList.
        /// </summary>
        [Alias("Args")]
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = "Arguments to pass to the executable")]
        public string[] ArgumentList { get; set; } = Array.Empty<string>();

        /// <summary>
        /// Working directory for the new process. Identical to Start-Process
        /// -WorkingDirectory.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Working directory for the new process")]
        public string WorkingDirectory { get; set; }

        /// <summary>
        /// Wait for the process to exit before continuing. Identical to
        /// Start-Process -Wait.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Wait for the process to exit")]
        public SwitchParameter Wait { get; set; }

        /// <summary>
        /// Return the process object to the pipeline. Identical to
        /// Start-Process -PassThru.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Return the process object")]
        public SwitchParameter PassThru { get; set; }

        /// <summary>
        /// Run the process in the current console window. Identical to
        /// Start-Process -NoNewWindow.
        /// </summary>
        [Alias("nnw")]
        [Parameter(
            Mandatory = false,
            HelpMessage = "Run in the current console window")]
        public SwitchParameter NoNewWindow { get; set; }

        /// <summary>
        /// Window style for the new process. Identical to Start-Process
        /// -WindowStyle.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Window style for the new process")]
        [ValidateSet(
            "Normal", "Hidden", "Minimized", "Maximized")]
        public string WindowStyle { get; set; }

        /// <summary>
        /// Environment variables for the new process. Identical to
        /// Start-Process -Environment.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Environment variables for the new process")]
        public Hashtable Environment { get; set; }

        /// <summary>
        /// Redirect standard error to a file. Identical to Start-Process
        /// -RedirectStandardError.
        /// </summary>
        [Alias("RSE")]
        [Parameter(
            Mandatory = false,
            HelpMessage = "File to redirect standard error to")]
        public string RedirectStandardError { get; set; }

        /// <summary>
        /// Redirect standard input from a file. Identical to Start-Process
        /// -RedirectStandardInput.
        /// </summary>
        [Alias("RSI")]
        [Parameter(
            Mandatory = false,
            HelpMessage = "File to redirect standard input from")]
        public string RedirectStandardInput { get; set; }

        /// <summary>
        /// Redirect standard output to a file. Identical to Start-Process
        /// -RedirectStandardOutput.
        /// </summary>
        [Alias("RSO")]
        [Parameter(
            Mandatory = false,
            HelpMessage = "File to redirect standard output to")]
        public string RedirectStandardOutput { get; set; }

        /// <summary>
        /// Load the user's Windows profile. Identical to Start-Process
        /// -LoadUserProfile.
        /// </summary>
        [Alias("Lup")]
        [Parameter(
            Mandatory = false,
            HelpMessage = "Load the user's Windows profile")]
        public SwitchParameter LoadUserProfile { get; set; }

        /// <summary>
        /// Use a new environment for the process. Identical to Start-Process
        /// -UseNewEnvironment.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Use a new environment for the process")]
        public SwitchParameter UseNewEnvironment { get; set; }

        /// <summary>
        /// When true (default), starts the process with elevated privileges
        /// via -Verb RunAs. Set to false for normal unelevated execution.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Start with elevated privileges (default: true)")]
        public SwitchParameter Elevated { get; set; } =
            new SwitchParameter(true);

        // =================================================================
        // Processing
        // =================================================================

        /// <summary>
        /// Begin processing
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting process with elevation");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            if (!ShouldProcess("Start process with elevation"))
            {
                return;
            }

            // Copy all parameters matching Start-Process
            var startParams = CopyIdenticalParamValues("Microsoft.PowerShell.Management\\Start-Process");
            // Force -Verb RunAs when elevating
            startParams["Verb"] = "RunAs";

            // Check if we're already elevated
            bool isElevated = CheckIfElevated();

            // Already elevated or elevation not requested:
            // delegate directly to Start-Process
            if (isElevated || !Elevated.ToBool())
            {
                if (!Elevated.ToBool())
                {
                    // Remove forced RunAs — user wants normal execution
                    startParams.Remove("Verb");
                }

                WriteVerbose(
                    "Delegating directly to Start-Process");

                var directScript = ScriptBlock.Create(
                    "param($P) Microsoft.PowerShell.Management\\Start-Process @P");
                var results2 = directScript.Invoke(startParams);

                if (PassThru.ToBool() && results2.Count > 0)
                {
                    foreach (var r in results2)
                    {
                        WriteObject(r?.BaseObject);
                    }
                }
                return;
            }

            // Not elevated: send Start-Process command via pipe
            WriteVerbose(
                "Delegating to elevated helper via named pipe");

            // Serialize the hashtable to JSON for pipe transport
            string json = ConvertToJson(startParams);
            string encodedParams = Convert.ToBase64String(
                Encoding.UTF8.GetBytes(json));

            // Build the elevated ScriptBlock
            string scriptText =
                "$json=[System.Text.Encoding]::UTF8.GetString(" +
                "[System.Convert]::FromBase64String('" +
                encodedParams + "'));" +
                "$p=$json|ConvertFrom-Json -AsHashtable;" +
                "Start-Process @p";

            // Execute via the elevated helper pipe
            var invokeScript = ScriptBlock.Create(
                "param($S) GenXdev\\Invoke-CommandElevated " +
                "-ScriptBlock ([ScriptBlock]::Create($S))");
            var results = invokeScript.Invoke(scriptText);

            if (PassThru.ToBool() && results.Count > 0)
            {
                foreach (var r in results)
                {
                    // Try to resolve a PID into a Process object
                    if (r?.BaseObject is int pid ||
                        (r?.BaseObject is string s &&
                         int.TryParse(s, out pid)))
                    {
                        try
                        {
                            WriteObject(
                                Process.GetProcessById(pid));
                            continue;
                        }
                        catch { }
                    }
                    WriteObject(r?.BaseObject);
                }
            }
        }

        /// <summary>
        /// End processing
        /// </summary>
        protected override void EndProcessing()
        {
        }

        // =================================================================
        // Helpers
        // =================================================================

        /// <summary>
        /// Check if the current process is elevated
        /// </summary>
        private bool CheckIfElevated()
        {
            try
            {
                return InvokeScript<bool>(
                    "GenXdev\\CurrentUserHasElevatedRights");
            }
            catch
            {
                return false;
            }
        }
    }
}