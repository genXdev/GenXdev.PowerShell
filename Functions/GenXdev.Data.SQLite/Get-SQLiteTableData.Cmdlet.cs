using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves data from a SQLite database table with optional record limiting.

.DESCRIPTION
This command queries data from a SQLite database table using either a connection
string or database file path. It provides flexibility in connecting to the
database and controlling the amount of data retrieved through the Count
parameter. Every row is returned as a hashtable keyed by column name.

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
Specifies the SQLite connection string in the format:
Data Source=path_to_database_file

.PARAMETER DatabaseFilePath
Specifies the full file system path to the SQLite database file.

.PARAMETER TableName
Specifies the name of the table to query data from. The table must exist in the
database.

.PARAMETER Count
Specifies the maximum number of records to return. Default is 100.
Use -1 to return all records. Must be -1 or a positive integer.

.EXAMPLE
```powershell
Get-SQLiteTableData -DatabaseFilePath ""C:\data\users.db"" `
    -TableName ""Employees"" -Count 50
```

Returns at most 50 rows from the Employees table.

.EXAMPLE
```powershell
Get-SQLiteTableData -DatabaseFilePath ""C:\data\users.db"" `
    -TableName ""Employees"" -Count -1
```

Returns every row from the Employees table.
")]
    [Cmdlet(verbName:"Get", "SQLiteTableData", DefaultParameterSetName = "DatabaseFilePath")]
    [OutputType(typeof(Hashtable))]
    public class GetSqliteTableDataCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The connection string to the SQLite database.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "ConnectionString",
            HelpMessage = "The connection string to the SQLite database.")]
        [ValidateNotNullOrEmpty]
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
        [Alias("dbpath", "indexpath")]
        public string DatabaseFilePath { get; set; }

        /// <summary>
        /// The name of the table to query data from.
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = true,
            HelpMessage = "The name of the table to query data from.")]
        [ValidateNotNullOrEmpty]
        public string TableName { get; set; }

        /// <summary>
        /// The maximum number of records to return. -1 returns all.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = false,
            HelpMessage = "The maximum number of records to return. -1 for all.")]
        [ValidateRange(-1, int.MaxValue)]
        public int Count { get; set; } = 100;

        /// <summary>
        /// Process record - retrieves the table rows.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Starting Get-SQLiteTableData for table: " + TableName);

            string query = Count == -1 ?
                $"SELECT * FROM {TableName}" :
                $"SELECT * FROM {TableName} LIMIT {Count}";

            WriteVerbose($"Executing query: {query}");

            Hashtable parameters = CopyIdenticalParamValues("Invoke-SQLiteQuery");
            parameters["Queries"] = query;

            foreach (Hashtable record in InvokeCmdlet<Hashtable>(
                "Invoke-SQLiteQuery",
                parameters))
            {
                WriteObject(record);
            }
        }
    }
}
