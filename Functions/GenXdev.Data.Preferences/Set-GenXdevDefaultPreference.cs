using System.Management.Automation;

namespace GenXdev.Data.Preferences
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Sets a default preference value in the GenXdev preferences store.
.DESCRIPTION
* Manages default preferences in the GenXdev local defaults store.
* Handles storing values, removing preferences when values are empty.
* Use -AllMachines to also write the default to OneDrive for sharing
  across machines.

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
Set-GenXdevDefaultPreference -Name ""Theme"" -Value ""Dark""
```

Sets the default theme preference to ""Dark"" locally.
.EXAMPLE
```powershell
setPreferenceDefault ""EmailNotifications"" ""Disabled"" -AllMachines
```

Uses the alias with -AllMachines to share across machines.
")]
    [Cmdlet(VerbsCommon.Set, "GenXdevDefaultPreference")]
    [Alias("setPreferenceDefault")]
    public class SetGenXdevDefaultPreferenceCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The name of the preference to set in defaults
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The name of the preference to set in defaults"
        )]
        [ValidateNotNullOrEmpty]
        [Alias("PreferenceName")]
        public string Name { get; set; }

        /// <summary>
        /// The value to store for the preference
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The value to store for the preference"
        )]
        [AllowNull]
        [AllowEmptyString]
        [Alias("PreferenceValue")]
        public string Value { get; set; }

        /// <summary>
        /// Database path for preference data files
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Database path for preference data files"
        )]
        [Alias("DatabasePath")]
        public string PreferencesDatabasePath { get; set; }

        /// <summary>
        /// Use alternative settings stored in session for Data preferences like Language, Database paths, etc
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
        /// Dont use alternative settings stored in session for Data preferences like Language, Database paths, etc
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Dont use alternative settings stored in session for Data preferences like Language, Database paths, etc"
        )]
        [Alias("FromPreferences")]
        public SwitchParameter SkipSession { get; set; }

        /// <summary>
        /// Also write the default preference to OneDrive for sharing across all machines.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Also write the default preference to OneDrive for sharing across all machines"
        )]
        public SwitchParameter AllMachines { get; set; }

        protected override void BeginProcessing()
        {
        }

        protected override void ProcessRecord()
        {
            SetGenXdevDefaultPreference(Name, Value, PreferencesDatabasePath, SessionOnly.ToBool(), ClearSession.ToBool(), SkipSession.ToBool(), AllMachines.ToBool());
        }

        protected override void EndProcessing()
        {
        }
    }
}