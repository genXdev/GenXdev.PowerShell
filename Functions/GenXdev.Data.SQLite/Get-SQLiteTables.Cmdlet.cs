using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves a list of table names from a SQLite database.

.DESCRIPTION
Queries the sqlite_master system table to retrieve all user-defined table names
from a SQLite database. Supports connecting via either a direct connection string
or a database file path. Every table is returned as a hashtable with a name
property.

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
The full connection string to connect to the SQLite database. Should include the
Data Source and Version parameters at minimum.

.PARAMETER DatabaseFilePath
The full filesystem path to the SQLite database file. The command will create
an appropriate connection string internally.

.EXAMPLE
```powershell
Get-SQLiteTables -DatabaseFilePath ""C:\Databases\Inventory.sqlite""
```

Returns all table names from the specified database file.

.EXAMPLE
```powershell
Get-SQLiteTables -ConnectionString ""Data Source=C:\DB\Users.sqlite;Version=3;""
```

Returns all table names using a custom connection string.
")]
    [Cmdlet(verbName:"Get", "SQLiteTables", DefaultParameterSetName = "DatabaseFilePath")]
    [OutputType(typeof(Hashtable))]
    public class GetSqliteTablesCommand : PSGenXdevCmdlet
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
        [ValidateNotNullOrEmpty]
        public string DatabaseFilePath { get; set; }

        /// <summary>
        /// Process record - retrieves the table names.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Starting SQLite table name retrieval operation");

            Hashtable parameters = CopyIdenticalParamValues("Invoke-SQLiteQuery");
            parameters["Queries"] =
                "SELECT name FROM sqlite_master WHERE type='table'";

            foreach (Hashtable record in InvokeCmdlet<Hashtable>(
                "Invoke-SQLiteQuery",
                parameters))
            {
                WriteObject(record);
            }
        }
    }
}
