using System.Management.Automation;

namespace GenXdev.Data.KeyValueStore
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves all key names for a given local key-value store.
.DESCRIPTION
* Queries the KeyValueStore JSON file to retrieve all active (non-deleted)
  keys for a specified store.

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
Get-StoreKeys -StoreName ""ApplicationSettings""
```

Retrieves all keys from the ApplicationSettings store.
.EXAMPLE
```powershell
getkeys AppSettings
```

Retrieves keys using the alias.
")]
    [Cmdlet(VerbsCommon.Get, "StoreKeys")]
    [Alias("getkeys")]
    [OutputType(typeof(string))]
    public class GetStoreKeysCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The name of the key-value store to query
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Name of the store whose keys should be retrieved")]
        [ValidateNotNullOrEmpty]
        public string StoreName { get; set; }

        /// <summary>
        /// Database path for key-value store data files
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for key-value store data files")]
        public string DatabasePath { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose($"Initializing Get-StoreKeys for store: {StoreName}");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            var keys = GetStoreKeys(StoreName, DatabasePath);
            foreach (var key in keys)
            {
                WriteObject(key);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}