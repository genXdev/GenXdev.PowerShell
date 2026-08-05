using System.Management.Automation;

namespace GenXdev.Data.Preferences
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves a preference value from the GenXdev preferences store.
.DESCRIPTION
* Implements a five-tier preference retrieval system:
  session, local prefs, local defaults, OneDrive, then fallback default.
* First checks the session for a preference value.
* If not found, checks the local preferences store.
* If not found, checks the local defaults store.
* If not found, checks OneDrive shared defaults.
* If still not found, returns the provided default value.

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
Get-GenXdevPreference -Name ""Theme"" -DefaultValue ""Dark""
```

Retrieves the ""Theme"" preference with fallback to default ""Dark"".
.EXAMPLE
```powershell
getPreference ""Theme"" ""Dark""
```

Uses the alias and positional parameters.
")]
    [Cmdlet(VerbsCommon.Get, "GenXdevPreference")]
    [Alias("getPreference")]
    [OutputType(typeof(string))]
    public class GetGenXdevPreferenceCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The name of the preference to retrieve
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The name of the preference to retrieve"
        )]
        [ValidateNotNullOrEmpty]
        [Alias("PreferenceName")]
        public string Name { get; set; }

        /// <summary>
        /// The default value if preference is not found
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The default value if preference is not found"
        )]
        [AllowNull]
        [AllowEmptyString]
        [Alias("DefaultPreference")]
        public string DefaultValue { get; set; }

        /// <summary>
        /// Database path for preference data files
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for preference data files"
        )]
        [Alias("DatabasePath")]
        public string PreferencesDatabasePath { get; set; }

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
        /// Dont use alternative settings stored in session for Data preferences like
        /// Language, Database paths, etc
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Dont use alternative settings stored in session for Data preferences like Language, Database paths, etc"
        )]
        [Alias("FromPreferences")]
        public SwitchParameter SkipSession { get; set; }

        protected override void BeginProcessing()
        {
        }

        protected override void ProcessRecord()
        {
            WriteObject(GetGenXdevPreference(Name, DefaultValue, PreferencesDatabasePath, SessionOnly.ToBool(), ClearSession.ToBool(), SkipSession.ToBool()));
        }

        protected override void EndProcessing()
        {
        }
    }
}