using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves column data from a SQLite view with optional record limiting.

.DESCRIPTION
Executes a SELECT query against a specified SQLite view to retrieve data from a
single column. Supports connecting via either a connection string or database
file path. Allows limiting the number of returned records or retrieving all
records. Every row is returned as a hashtable keyed by column name.

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
The SQLite database connection string.

.PARAMETER DatabaseFilePath
The full path to the SQLite database file.

.PARAMETER ViewName
The name of the SQLite view to query data from.

.PARAMETER ColumnName
The name of the column within the view to retrieve data from.

.PARAMETER Count
The maximum number of records to return. Use -1 to return all records. Defaults
to 100 if not specified.

.EXAMPLE
```powershell
Get-SQLiteViewColumnData -DatabaseFilePath ""C:\MyDB.sqlite"" `
    -ViewName ""CustomersView"" -ColumnName ""Email"" -Count 50
```

Returns the Email value of at most 50 rows in the view.

.EXAMPLE
```powershell
Get-SQLiteViewColumnData -DatabaseFilePath ""C:\MyDB.sqlite"" `
    -ViewName ""CustomersView"" -ColumnName ""Email"" -Count -1
```

Returns the Email value of every row in the view.
")]
    [Cmdlet(verbName:"Get", "SQLiteViewColumnData", DefaultParameterSetName = "DatabaseFilePath")]
    [OutputType(typeof(Hashtable))]
    public class GetSqliteViewColumnDataCommand : PSGenXdevCmdlet
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
        [Alias("dbpath", "indexpath")]
        public string DatabaseFilePath { get; set; }

        /// <summary>
        /// The name of the view.
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = true,
            HelpMessage = "The name of the view.")]
        public string ViewName { get; set; }

        /// <summary>
        /// The name of the column.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = true,
            HelpMessage = "The name of the column.")]
        public string ColumnName { get; set; }

        /// <summary>
        /// Number of records to return. -1 returns all.
        /// </summary>
        [Parameter(
            Position = 3,
            Mandatory = false,
            HelpMessage = "The number of records to return. Default is 100. -1 for all.")]
        public int Count { get; set; } = 100;

        /// <summary>
        /// Process record - retrieves the view column values.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Starting Get-SQLiteViewColumnData for view '" +
                ViewName + "'");

            string query = Count == -1 ?
                $"SELECT {ColumnName} FROM {ViewName}" :
                $"SELECT {ColumnName} FROM {ViewName} LIMIT {Count}";

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
