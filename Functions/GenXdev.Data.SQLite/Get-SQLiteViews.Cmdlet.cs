using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves a list of views from a SQLite database.

.DESCRIPTION
Gets all view names from the specified SQLite database file or connection
string. Every view is returned as a hashtable with a name property. The command
supports two parameter sets for flexibility: providing either a connection
string or a direct path to the database file.

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

.PARAMETER ConnectionString
The connection string to connect to the SQLite database. Use this when you need
to specify custom connection parameters.

.PARAMETER DatabaseFilePath
The full path to the SQLite database file. Use this for simple file-based
connections.

.EXAMPLE
```powershell
Get-SQLiteViews -DatabaseFilePath ""C:\Databases\MyDatabase.sqlite""
```

Returns every view name in the database.

.EXAMPLE
```powershell
Get-SQLiteViews -ConnectionString ""Data Source=C:\Databases\MyDatabase.sqlite;Version=3;""
```

Returns every view name using a custom connection string.
")]
    [Cmdlet(verbName:"Get", "SQLiteViews", DefaultParameterSetName = "DatabaseFilePath")]
    [OutputType(typeof(Hashtable))]
    public class GetSqliteViewsCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The connection string to the SQLite database.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "ConnectionString",
            HelpMessage = "The connection string to the SQLite database.")]
        public string ConnectionString { get; set; }

        /// <summary>
        /// The path to the SQLite database file.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "DatabaseFilePath",
            HelpMessage = "The path to the SQLite database file.")]
        public string DatabaseFilePath { get; set; }

        /// <summary>
        /// Process record - retrieves the view names.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Preparing to retrieve SQLite views...");

            Hashtable parameters = CopyIdenticalParamValues("Invoke-SQLiteQuery");
            parameters["Queries"] =
                "SELECT name FROM sqlite_master WHERE type='view'";

            foreach (Hashtable record in InvokeCmdlet<Hashtable>(
                "Invoke-SQLiteQuery",
                parameters))
            {
                WriteObject(record);
            }
        }
    }
}
