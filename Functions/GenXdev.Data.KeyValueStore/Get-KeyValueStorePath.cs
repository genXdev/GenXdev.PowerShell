using System.Management.Automation;

namespace GenXdev.Data.KeyValueStore
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets the file path for a local key-value store.
.DESCRIPTION
* Constructs the file path for a key-value store based on the store name
  and base directory. All stores use the ""Local"" prefix.

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
Get-KeyValueStorePath -StoreName ""MyStore""
```

Get the file path for a local key-value store.
")]
    [Cmdlet(VerbsCommon.Get, "KeyValueStorePath")]
    [OutputType(typeof(string))]
    public class GetKeyValueStorePath : PSGenXdevCmdlet
    {
        /// <summary>
        /// The name of the key-value store.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The name of the key-value store"
        )]
        [ValidateNotNullOrEmpty]
        public string StoreName { get; set; }

        /// <summary>
        /// The base directory path for store files.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "The base directory path for store files"
        )]
        public string BasePath { get; set; }

        /// <summary>
        /// Begin processing - initialize cmdlet.
        /// </summary>
        protected override void BeginProcessing()
        {
            BasePath = BasePath == null ? GetGenXdevAppDataPath("KeyValueStore") : BasePath;
            WriteVerbose($"Constructing store file path for store '{StoreName}'");
        }

        /// <summary>
        /// Process each input object.
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                BasePath = ExpandPath(BasePath);
                string path = GetKeyValueStorePath("Local", StoreName, BasePath);
                WriteObject(path);
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "Get-KeyValueStorePathError",
                    ErrorCategory.InvalidOperation,
                    this
                ));
            }
        }

        /// <summary>
        /// End processing - cleanup if needed.
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}