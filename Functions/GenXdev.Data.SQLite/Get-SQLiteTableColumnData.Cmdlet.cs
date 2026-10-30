using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves data from a specific column in a SQLite database table.

.DESCRIPTION
This command provides a convenient way to extract data from a single column in a
SQLite database table. It supports two connection methods: direct database file
path or connection string. The command includes options to limit the number of
returned records. Every row is returned as a hashtable keyed by column name.

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
The connection string to connect to the SQLite database.

.PARAMETER DatabaseFilePath
The file path to the SQLite database file.

.PARAMETER TableName
The name of the table from which to retrieve the column data.

.PARAMETER ColumnName
The name of the column whose data should be retrieved.

.PARAMETER Count
The maximum number of records to return. Default is 100. Use -1 to return all
records without limit.

.EXAMPLE
```powershell
Get-SQLiteTableColumnData -DatabaseFilePath ""C:\MyDb.sqlite"" `
    -TableName ""Employees"" -ColumnName ""Email"" -Count 10
```

Returns the Email value of at most 10 employees.

.EXAMPLE
```powershell
Get-SQLiteTableColumnData -DatabaseFilePath ""C:\MyDb.sqlite"" `
    -TableName ""Employees"" -ColumnName ""Email"" -Count -1
```

Returns the Email value of every employee.
")]
    [Cmdlet(verbName:"Get", "SQLiteTableColumnData", DefaultParameterSetName = "DatabaseFilePath")]
    [OutputType(typeof(Hashtable))]
    public class GetSqliteTableColumnDataCommand : PSGenXdevCmdlet
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
        public string DatabaseFilePath { get; set; }

        /// <summary>
        /// The name of the table to query.
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = true,
            HelpMessage = "The name of the table to query")]
        [ValidateNotNullOrEmpty]
        public string TableName { get; set; }

        /// <summary>
        /// The name of the column to retrieve.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = true,
            HelpMessage = "The name of the column to retrieve")]
        [ValidateNotNullOrEmpty]
        public string ColumnName { get; set; }

        /// <summary>
        /// Number of records to return. -1 returns all.
        /// </summary>
        [Parameter(
            Position = 3,
            Mandatory = false,
            HelpMessage = "Number of records to return. Default 100. Use -1 for all")]
        public int Count { get; set; } = 100;

        /// <summary>
        /// Process record - retrieves the column values.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Starting data retrieval for column '" + ColumnName +
                "' from table '" + TableName + "'");

            string query = Count == -1 ?
                $"SELECT {ColumnName} FROM {TableName}" :
                $"SELECT {ColumnName} FROM {TableName} LIMIT {Count}";

            WriteVerbose($"Executing SQL query: {query}");

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
