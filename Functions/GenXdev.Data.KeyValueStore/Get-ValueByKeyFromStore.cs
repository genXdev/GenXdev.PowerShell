using System.Management.Automation;

namespace GenXdev.Data.KeyValueStore
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves a value from a local JSON-based key-value store.
.DESCRIPTION
* Retrieves a value for a specified key from a JSON file-based key-value
  store.
* Supports optional default values when the key is not found.

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
Get-ValueByKeyFromStore -StoreName ""AppSettings"" -KeyName ""Theme"" -DefaultValue ""Dark""
```

Retrieves the ""Theme"" value from ""AppSettings"", returning ""Dark"" if not
found.
.EXAMPLE
```powershell
getvalue AppSettings Theme
```

Uses the 'getvalue' alias to retrieve a value.
")]
    [Cmdlet(VerbsCommon.Get, "ValueByKeyFromStore")]
    [Alias("getvalue")]
    [OutputType(typeof(string))]
    public class GetValueByKeyFromStoreCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The name of the key-value store to query
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Name of the store to retrieve the key from"
        )]
        public string StoreName { get; set; }

        /// <summary>
        /// The key whose value should be retrieved
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Key to retrieve from the specified store"
        )]
        public string KeyName { get; set; }

        /// <summary>
        /// Optional default value to return if the key is not found
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "A optional default value"
        )]
        public string DefaultValue { get; set; }

        /// <summary>
        /// Database path for key-value store data files
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for key-value store data files"
        )]
        public string DatabasePath { get; set; }

        /// <summary>
        /// Process the request to retrieve the value
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteObject(GetValueByKeyFromStore(StoreName, KeyName, DefaultValue, DatabasePath));
        }
    }
}