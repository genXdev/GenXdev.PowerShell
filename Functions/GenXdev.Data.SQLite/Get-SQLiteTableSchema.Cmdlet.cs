using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves the schema information for a specified SQLite table.

.DESCRIPTION
This command queries the SQLite database to get detailed schema information for
a specified table. It uses the SQLite PRAGMA table_info command to return column
definitions including names, types, nullable status, and default values. Every
column is returned as a hashtable.

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
The SQLite connection string in the format:
Data Source=path_to_database_file

.PARAMETER DatabaseFilePath
The direct file path to the SQLite database file. This is converted internally
to a connection string.

.PARAMETER TableName
The name of the table for which to retrieve schema information.

.EXAMPLE
```powershell
Get-SQLiteTableSchema -DatabaseFilePath ""C:\Databases\mydb.sqlite"" `
    -TableName ""Users""
```

Returns the column definitions of the Users table.

.EXAMPLE
```powershell
Get-SQLiteTableSchema `
    -ConnectionString ""Data Source=C:\Databases\mydb.sqlite"" `
    -TableName ""Products""
```

Returns the column definitions using a custom connection string.
")]
    [Cmdlet(verbName:"Get", "SQLiteTableSchema", DefaultParameterSetName = "DatabaseFilePath")]
    [OutputType(typeof(Hashtable))]
    public class GetSqliteTableSchemaCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The connection string to the SQLite database.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "ConnectionString",
            HelpMessage = "The connection string to the SQLite database")]
        [ValidateNotNullOrEmpty]
        public string ConnectionString { get; set; }

        /// <summary>
        /// The path to the SQLite database file.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "DatabaseFilePath",
            HelpMessage = "The path to the SQLite database file")]
        [ValidateNotNullOrEmpty]
        [Alias("dbpath", "indexpath")]
        public string DatabaseFilePath { get; set; }

        /// <summary>
        /// The name of the table.
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = true,
            HelpMessage = "The name of the table")]
        [ValidateNotNullOrEmpty]
        public string TableName { get; set; }

        /// <summary>
        /// Process record - retrieves the table column definitions.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Preparing to retrieve schema for table '" + TableName + "'");

            Hashtable parameters = CopyIdenticalParamValues("Invoke-SQLiteQuery");
            parameters["Queries"] = $"PRAGMA table_info({TableName})";

            WriteVerbose("Executing schema query against SQLite database");

            foreach (Hashtable record in InvokeCmdlet<Hashtable>(
                "Invoke-SQLiteQuery",
                parameters))
            {
                WriteObject(record);
            }
        }
    }
}
