using System.Management.Automation;

namespace GenXdev.Data.KeyValueStore
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Manages key-value pairs in a local JSON file-based store.
.DESCRIPTION
Provides persistent local storage for key-value pairs using JSON files.
Handles both insertion of new entries and updates to existing ones. This
function implements an upsert operation.

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
Set-ValueByKeyInStore -StoreName ""ConfigStore"" -KeyName ""ApiEndpoint"" `
    -Value ""https://api.example.com""
```

Set an API endpoint in the ConfigStore.

.EXAMPLE
```powershell
setvalue ConfigStore ApiEndpoint ""https://api.example.com""
```

Use the alias to set a value.
")]
    [Cmdlet(VerbsCommon.Set, "ValueByKeyInStore")]
    [Alias("setvalue")]
    public class SetValueByKeyInStoreCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The name of the store where the key-value pair will be saved.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Store name for the key-value pair"
        )]
        public string StoreName { get; set; }

        /// <summary>
        /// The unique identifier for the value within the specified store.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Name of the key to set or update"
        )]
        public string KeyName { get; set; }

        /// <summary>
        /// The data to be stored, associated with the specified key.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Value to be stored"
        )]
        public string Value { get; set; }

        /// <summary>
        /// Database path for key-value store data files.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for key-value store data files"
        )]
        public string DatabasePath { get; set; }

        private string basePath;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // use provided base path or default to local app data
            if (string.IsNullOrWhiteSpace(DatabasePath))
            {
                basePath = Path.Combine(
                    Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData),
                    "GenXdev.PowerShell",
                    "KeyValueStore"
                );
            }
            else
            {
                basePath = DatabasePath;
            }

            WriteVerbose("Using KeyValueStore directory: " + basePath);
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // only proceed if user confirms or -WhatIf is not used
            if (ShouldProcess(
                    "Store: " + StoreName + ", Key: " + KeyName,
                    "Set value to: " + Value))
            {
                SetValueByKeyInStore(StoreName, KeyName, Value, DatabasePath);
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