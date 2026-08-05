using System.Management.Automation;

namespace GenXdev.Data.Preferences
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets all preference names from session storage and database stores.
.DESCRIPTION
* Retrieves a unique list of preference names by combining keys from
  session storage (global variables) and both the local and default
  preference stores.
* Respects session management parameters to control which sources are
  queried.

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
Get-GenXdevPreferenceNames -PreferencesDatabasePath ""C:\Data\prefs.db""
```

Returns a sorted array of unique preference names from session storage and
both stores using the specified database path.
.EXAMPLE
```powershell
getPreferenceNames -SessionOnly
```

Returns only preference names from session storage.
.EXAMPLE
```powershell
getPreferenceNames -SkipSession
```

Returns only preference names from database stores.
")]
    [Cmdlet(VerbsCommon.Get, "GenXdevPreferenceNames")]
    [Alias("getPreferenceNames")]
    [OutputType(typeof(string[]))]
    public class GetGenXdevPreferenceNamesCommand : PSGenXdevCmdlet
    {
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
        /// Database path for preference data files
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
        [Alias("FromPreferences")]
        public SwitchParameter SkipSession { get; set; }

        protected override void BeginProcessing()
        {
        }

        protected override void ProcessRecord()
        {
            var names = GetGenXdevPreferenceNames(PreferencesDatabasePath, SessionOnly.ToBool(), ClearSession.ToBool(), SkipSession.ToBool());
            foreach (var name in names)
            {
                WriteObject(name);
            }
        }

        protected override void EndProcessing()
        {
        }
    }
}