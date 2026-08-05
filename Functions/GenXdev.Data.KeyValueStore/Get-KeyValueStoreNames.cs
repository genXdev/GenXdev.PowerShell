using System.Management.Automation;

namespace GenXdev.Data.KeyValueStore
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves the names of available local key-value stores.
.DESCRIPTION
* Scans the key-value store directory for JSON files and extracts unique
  store names from local store files.

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
Get-KeyValueStoreNames
```

Retrieves all store names from the default location.
.EXAMPLE
```powershell
getstorenames -DatabasePath 'C:\MyStores'
```

Retrieves all store names from a custom database path using the alias.
")]
    [Cmdlet(VerbsCommon.Get, "KeyValueStoreNames")]
    [OutputType(typeof(string))]
    [Alias("getstorenames")]
    public class GetKeyValueStoreNamesCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Database path for key-value store data files.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for key-value store data files")]
        public string DatabasePath { get; set; }

        private string basePath;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Check if database path is provided, otherwise use default
            basePath = string.IsNullOrWhiteSpace(DatabasePath) ? GetGenXdevAppDataPath("KeyValueStore") : DatabasePath;

            // Output verbose message for store directory path
            WriteVerbose($"Using KeyValueStore directory: {basePath}");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            var names = GetKeyValueStoreNames(DatabasePath);
            foreach (var name in names)
            {
                WriteObject(name);
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