using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves the complete schema information from a SQLite database.

.DESCRIPTION
This command queries the sqlite_master table to obtain the complete schema
definition of a SQLite database, including tables, views, indexes and triggers.
It accepts either a connection string or a direct path to the database file.
Every object is returned as a hashtable.

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
The SQLite connection string that specifies the database location and any
additional connection parameters.

.PARAMETER DatabaseFilePath
The direct filesystem path to the SQLite database file.

.EXAMPLE
```powershell
Get-SQLiteSchema -DatabaseFilePath ""C:\Databases\inventory.db""
```

Lists every schema object in the database.

.EXAMPLE
```powershell
Get-SQLiteSchema -ConnectionString ""Data Source=C:\Databases\inventory.db;Version=3;""
```

Lists the schema objects using a custom connection string.
")]
    [Cmdlet(verbName:"Get", "SQLiteSchema", DefaultParameterSetName = "DatabaseFilePath")]
    [OutputType(typeof(Hashtable))]
    public class GetSqliteSchemaCommand : PSGenXdevCmdlet
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
        /// Process record - retrieves the schema objects.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose($"Using parameter set: {ParameterSetName}");

            Hashtable parameters = CopyIdenticalParamValues("Invoke-SQLiteQuery");
            parameters["Queries"] = "SELECT * FROM sqlite_master";

            foreach (Hashtable record in InvokeCmdlet<Hashtable>(
                "Invoke-SQLiteQuery",
                parameters))
            {
                WriteObject(record);
            }
        }
    }
}
