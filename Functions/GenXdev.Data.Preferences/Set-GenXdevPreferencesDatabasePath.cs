using System.Management.Automation;

namespace GenXdev.Data.Preferences
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Sets the database path for preferences used in GenXdev.Data operations.
.DESCRIPTION
* Configures the global database path used by the GenXdev.Data module for
  various preference storage and data operations.
* Settings are stored in the current session (using Global variables) and
  can be cleared from the session (using -ClearSession).

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
Set-GenXdevPreferencesDatabasePath -PreferencesDatabasePath ""C:\Data\Preferences.db""
```

Sets the database path in the current session (Global variable).
.EXAMPLE
```powershell
Set-GenXdevPreferencesDatabasePath ""C:\MyPreferences.db""
```

Sets the database path using positional parameter.
.EXAMPLE
```powershell
Set-GenXdevPreferencesDatabasePath ""C:\TempPrefs.db"" -SessionOnly
```

Sets the path only for the current session without persisting.
.EXAMPLE
```powershell
Set-GenXdevPreferencesDatabasePath -ClearSession
```

Clears the Global variable for the database path.
")]
    [Cmdlet(VerbsCommon.Set, "GenXdevPreferencesDatabasePath")]
    public class SetGenXdevPreferencesDatabasePathCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// A database path where preference data files are located
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            HelpMessage = "A database path where preference data files are located"
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
        [Alias("FromPreferences")]
        public SwitchParameter SkipSession { get; set; }

        /// <summary>
        /// When specified, stores the setting only in the current session (Global
        /// variable) without persisting to preferences
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "When specified, stores the setting only in the current session (Global variable) without persisting to preferences"
        )]
        public SwitchParameter SessionOnly { get; set; }

        /// <summary>
        /// When specified, clears only the session setting (Global variable) without
        /// affecting persistent preferences
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "When specified, clears only the session setting (Global variable) without affecting persistent preferences"
        )]
        public SwitchParameter ClearSession { get; set; }

        /// <summary>
        /// Begin processing - validate parameters and expand path if needed
        /// </summary>
        protected override void BeginProcessing()
        {
            if ((!ClearSession.ToBool()) &&
                string.IsNullOrWhiteSpace(PreferencesDatabasePath))
            {
                var errorRecord = new ErrorRecord(
                    new ArgumentException("PreferencesDatabasePath parameter is required when not using -ClearSession"),
                    "MissingPreferencesDatabasePath",
                    ErrorCategory.InvalidArgument,
                    null);
                ThrowTerminatingError(errorRecord);
            }
        }

        /// <summary>
        /// Process record - handle clearing or setting the global variable
        /// </summary>
        protected override void ProcessRecord()
        {
            SetPreferencesDatabasePath(PreferencesDatabasePath, SkipSession.ToBool(), SessionOnly.ToBool(), ClearSession.ToBool());
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}