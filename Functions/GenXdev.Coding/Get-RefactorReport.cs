using System.Collections;
using System.Management.Automation;

namespace GenXdev.Coding
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Generates a detailed report of refactoring operations and their status.
.DESCRIPTION
Analyzes and reports on the progress of refactoring operations by examining their current state, completion status, and affected functions. Provides output in either structured hashtable format or human-readable aligned text columns. The report includes refactor name, prompt key, priority, status, function count and completion percentage.

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
Get-RefactorReport -Name ""DatabaseRefactor"" -AsText
```

Generates a text report for refactors matching ""DatabaseRefactor"".

.EXAMPLE
```powershell
refactorreport ""*""
```

Generates hashtable report for all refactors using alias.
")]
    [Cmdlet(VerbsCommon.Get, "RefactorReport")]
    [Alias("refactorreport")]
    [OutputType(typeof(Hashtable))]
    [OutputType(typeof(string))]
    public class GetRefactorReportCommand : PSGenXdevCmdlet
    {
        private bool headerOutput = false;

        private string textHeader = null;

        /// <summary>
        /// The name pattern to filter refactors. Supports wildcards. Multiple names can be
        /// specified. Default value is "*" to display all refactors.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = false,
            HelpMessage = "The name of the refactor, accepts wildcards",
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true)]
        [ValidateNotNullOrEmpty]
        [SupportsWildcards]
        public string[] Name { get; set; } = new string[] { "*" };

        /// <summary>
        /// Specifies the path to the preferences database file.
        /// </summary>
        [Alias("DatabasePath")]
        [Parameter(
            Mandatory = false,
            HelpMessage = "Specifies the path to the preferences database file.")]
        public string PreferencesDatabasePath { get; set; }

        /// <summary>
        /// If set, only use the session cache for refactor data.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "If set, only use the session cache for refactor data.")]
        public SwitchParameter SessionOnly { get; set; }

        /// <summary>
        /// If set, clear the session cache before running.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "If set, clear the session cache before running.")]
        public SwitchParameter ClearSession { get; set; }

        /// <summary>
        /// If set, skip loading session cache.
        /// </summary>
        [Alias("FromPreferences")]
        [Parameter(
            Mandatory = false,
            HelpMessage = "If set, skip loading session cache.")]
        public SwitchParameter SkipSession { get; set; }

        /// <summary>
        /// Output report in text format instead of Hashtable
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Output report in text format instead of Hashtable")]
        public SwitchParameter AsText { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Initialize text output header if AsText parameter is specified
            WriteVerbose("Starting refactor report generation for pattern: " + string.Join(" ", Name));

            if (AsText.ToBool())
            {
                // Create aligned column headers with proper spacing
                textHeader = string.Join(" ", new string[]
                {
                    "Name".PadRight(10),
                    "PromptKey".PadRight(10),
                    "Prio".PadRight(4),
                    "Status".PadRight(10),
                    "Num".PadRight(4),
                    "%"
                });
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Output header and separator for text format
            if (AsText.ToBool() && textHeader != null && !headerOutput)
            {
                WriteObject(textHeader);
                WriteObject(new string('-', textHeader.Length));
                headerOutput = true;
            }

            // Process each matching refactor
            var getRefactorScript = ScriptBlock.Create(@"
param($Name, $PreferencesDatabasePath, $SessionOnly, $ClearSession, $SkipSession)
GenXdev\Get-Refactor -Name $Name -PreferencesDatabasePath $PreferencesDatabasePath -SessionOnly:$SessionOnly -ClearSession:$ClearSession -SkipSession:$SkipSession
");
            var results = getRefactorScript.Invoke(Name, PreferencesDatabasePath, SessionOnly.ToBool(), ClearSession.ToBool(), SkipSession.ToBool());

            foreach (var result in results)
            {
                var psObject = (PSObject)result;

                // Calculate total functions affected by this refactor
                var selected = ((ArrayList)((PSObject)psObject.Properties["State"].Value).Properties["Selected"].Value).Count;
                var refactored = ((ArrayList)((PSObject)psObject.Properties["State"].Value).Properties["Refactored"].Value).Count;
                var unselected = ((ArrayList)((PSObject)psObject.Properties["State"].Value).Properties["Unselected"].Value).Count;
                var totalFunctions = selected + refactored + unselected;

                WriteVerbose("Processing refactor: " + (string)psObject.Properties["Name"].Value + " with " + totalFunctions + " items");

                if (AsText.ToBool())
                {
                    // Format text output with truncated columns
                    var name = ((string)psObject.Properties["Name"].Value).Substring(0,
                        Math.Min(10, ((string)psObject.Properties["Name"].Value).Length));
                    var promptKey = ((string)((PSObject)psObject.Properties["RefactorSettings"].Value).Properties["PromptKey"].Value).Substring(0,
                        Math.Min(10, ((string)((PSObject)psObject.Properties["RefactorSettings"].Value).Properties["PromptKey"].Value).Length));
                    var status = ((string)((PSObject)psObject.Properties["State"].Value).Properties["Status"].Value).Substring(0,
                        Math.Min(10, ((string)((PSObject)psObject.Properties["State"].Value).Properties["Status"].Value).Length));
                    var percent = ((double)((PSObject)psObject.Properties["State"].Value).Properties["PercentageComplete"].Value).ToString().Substring(0,
                        Math.Min(4, ((double)((PSObject)psObject.Properties["State"].Value).Properties["PercentageComplete"].Value).ToString().Length));

                    // Output formatted text row
                    var output = string.Format("{0} {1} {2} {3} {4} {5}%",
                        name.PadRight(10),
                        promptKey.PadRight(10),
                        ((int)psObject.Properties["Priority"].Value).ToString().PadRight(4),
                        status.PadRight(10),
                        totalFunctions.ToString().PadRight(4),
                        percent);
                    WriteObject(output);
                }
                else
                {
                    // Return hashtable with refactor details
                    var hashtable = new Hashtable
                    {
                        { "Name", psObject.Properties["Name"].Value },
                        { "PromptKey", ((PSObject)psObject.Properties["RefactorSettings"].Value).Properties["PromptKey"].Value },
                        { "Priority", psObject.Properties["Priority"].Value },
                        { "Status", ((PSObject)psObject.Properties["State"].Value).Properties["Status"].Value },
                        { "FunctionCount", totalFunctions },
                        { "PercentageComplete", ((PSObject)psObject.Properties["State"].Value).Properties["PercentageComplete"].Value }
                    };
                    WriteObject(hashtable);
                }
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            WriteVerbose("Completed refactor report generation");
        }
    }
}