using System.Management.Automation;

namespace GenXdev.Data.KeyValueStore
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Removes a key from a local key-value store.
.DESCRIPTION
This function marks a specified key as deleted in a named local key-value
store. The key's value is preserved with a deletion timestamp for audit
purposes.

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
Remove-KeyFromStore -StoreName ""MyStore"" -KeyName ""MyKey""
```

Remove the key ""MyKey"" from the store ""MyStore"".

.EXAMPLE
```powershell
removekey ""MyStore"" ""MyKey""
```

Remove a key using the alias.
")]
    [Cmdlet(VerbsCommon.Remove, "KeyFromStore", SupportsShouldProcess = true)]
    [Alias("removekey")]
    public class RemoveKeyFromStoreCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Name of the store
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Name of the store")]
        public string StoreName { get; set; }

        /// <summary>
        /// Key to be deleted
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Key to be deleted")]
        public string KeyName { get; set; }

        /// <summary>
        /// Database path for key-value store data files
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for key-value store data files")]
        public string DatabasePath { get; set; }

        // Private fields for processing
        private string lastModifiedBy;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose($"Preparing to remove key '{KeyName}' from store '{StoreName}'");

            // Get current user info for audit trail
            string computerName = Environment.GetEnvironmentVariable("COMPUTERNAME");
            string userName = Environment.GetEnvironmentVariable("USERNAME");
            lastModifiedBy = $"{computerName}\\{userName}";
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Check if user wants to proceed with deletion
            if (ShouldProcess(
                $"Key '{KeyName}' in store '{StoreName}'",
                "Mark as deleted"))
            {
                RemoveKeyFromStore(StoreName, KeyName, DatabasePath);
            }
        }        /// <summary>
                 /// End processing - cleanup logic
                 /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}