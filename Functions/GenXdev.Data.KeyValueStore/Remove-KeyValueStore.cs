using System.Management.Automation;

namespace GenXdev.Data.KeyValueStore
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Removes a local key-value store.
.DESCRIPTION
This function deletes a specified key-value store by physically removing
its JSON file from disk.

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
Remove-KeyValueStore -StoreName ""MyStore""
```

Remove a local key-value store named ""MyStore"".
")]
    [Cmdlet(VerbsCommon.Remove, "KeyValueStore")]
    [OutputType(typeof(void))]
    public class RemoveKeyValueStoreCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Name of the store to delete
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Name of the store to delete")]
        [ValidateNotNullOrEmpty]
        public string StoreName { get; set; }

        /// <summary>
        /// Database path for key-value store data files
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for key-value store data files")]
        public string DatabasePath { get; set; }

        private string basePath;

        /// <summary>
        /// Begin processing - determine base directory path
        /// </summary>
        protected override void BeginProcessing()
        {
            // Determine base directory path using provided path or default location
            if (string.IsNullOrWhiteSpace(DatabasePath))
            {
                // Build default path to local application data folder
                basePath = GetGenXdevAppDataPath("KeyValueStore");
            }
            else
            {
                // Use provided base path
                basePath = DatabasePath;
            }

            // Output verbose information about store directory location
            WriteVerbose($"Using KeyValueStore directory: {basePath}");
        }

        /// <summary>
        /// Process record - remove the key-value store
        /// </summary>
        protected override void ProcessRecord()
        {
            // Verify user consent
            if (ShouldProcess(StoreName, "Delete store file"))
            {
                RemoveKeyValueStore(StoreName, DatabasePath);
            }
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}