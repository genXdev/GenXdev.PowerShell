using System.Management.Automation;

namespace GenXdev.Data.Preferences
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets the configured database path for preference data files used in
GenXdev.Data operations.
.DESCRIPTION
* Retrieves the global database path used by the GenXdev.Data module for
  various preference storage and data operations.
* Checks Global variables first (unless SkipSession is specified), then
  falls back to persistent preferences, and finally uses system defaults.

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
Get-GenXdevPreferencesDatabasePath
```

Retrieves the database path from Global variables or preferences.
.EXAMPLE
```powershell
Get-GenXdevPreferencesDatabasePath -SkipSession
```

Skips the session variable and uses persistent preferences.
.EXAMPLE
```powershell
Get-GenXdevPreferencesDatabasePath -ClearSession
```

Clears the session setting before retrieving the path.
")]
    [Cmdlet(VerbsCommon.Get, "GenXdevPreferencesDatabasePath")]
    [OutputType(typeof(string))]
    public class GetGenXdevPreferencesDatabasePathCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Optional database path override
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            HelpMessage = "Optional database path override"
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
            WriteObject(GetPreferencesDatabasePath(PreferencesDatabasePath, SessionOnly.ToBool(), ClearSession.ToBool(), SkipSession.ToBool()));
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}