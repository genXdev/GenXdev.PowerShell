using System.Management.Automation;

namespace GenXdev.Data.Preferences
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Removes a preference value from the GenXdev preferences store.
.DESCRIPTION
* Removes a preference value from the local store and optionally from the
  defaults store.
* Use -AllMachines to also remove the preference from OneDrive shared
  across all machines.

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
Remove-GenXdevPreference -Name ""Theme""
```

Removes the ""Theme"" preference from the local store only.
.EXAMPLE
```powershell
removePreference ""Theme"" -RemoveDefault -AllMachines
```

Removes ""Theme"" from local, defaults, and OneDrive.
")]
    [Cmdlet(VerbsCommon.Remove, "GenXdevPreference")]
    [Alias("removePreference")]
    public class RemoveGenXdevPreferenceCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The name of the preference to remove
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The name of the preference to remove"
        )]
        [ValidateNotNullOrEmpty]
        public string Name { get; set; }

        /// <summary>
        /// Switch to also remove the preference from defaults
        /// </summary>
        [Parameter(
            Mandatory = false,
            ParameterSetName = "All",
            HelpMessage = "Switch to also remove the preference from defaults"
        )]
        public SwitchParameter RemoveDefault { get; set; }

        /// <summary>
        /// Use alternative settings stored in session for Data preferences like Language,
        /// Database paths, etc
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Use alternative settings stored in session for Data preferences like Language, Database paths, etc"
        )]
        public SwitchParameter SessionOnly { get; set; }

        /// <summary>
        /// Clear the session setting (Global variable) before retrieving
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Clear the session setting (Global variable) before retrieving"
        )]
        public SwitchParameter ClearSession { get; set; }

        /// <summary>
        /// Database path for preference data files.
        /// Alias: DatabasePath
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for preference data files"
        )]
        [Alias("DatabasePath")]
        public string PreferencesDatabasePath { get; set; }

        /// <summary>
        /// Dont use alternative settings stored in session for Data preferences like
        /// Language, Database paths, etc
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Dont use alternative settings stored in session for Data preferences like Language, Database paths, etc"
        )]
        public SwitchParameter SkipSession { get; set; }

        /// <summary>
        /// Also remove the preference from OneDrive shared across all machines.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Also remove the preference from OneDrive shared across all machines"
        )]
        public SwitchParameter AllMachines { get; set; }

        protected override void BeginProcessing()
        {
        }

        protected override void ProcessRecord()
        {
            RemoveGenXdevPreference(Name, RemoveDefault.ToBool(), PreferencesDatabasePath, SessionOnly.ToBool(), ClearSession.ToBool(), SkipSession.ToBool(), AllMachines.ToBool());
        }

        protected override void EndProcessing()
        {
        }
    }
}