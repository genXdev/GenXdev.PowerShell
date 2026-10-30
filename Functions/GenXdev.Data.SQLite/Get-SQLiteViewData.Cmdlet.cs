using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves data from a SQLite database view with optional record limiting.

.DESCRIPTION
Queries a SQLite database view using either a connection string or database file
path. The command supports limiting the number of returned records and provides
verbose output for tracking query execution. Every row is returned as a
hashtable keyed by column name.

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

.PARAMETER ViewName
The name of the view from which to retrieve data.

.PARAMETER Count
The maximum number of records to return. Use -1 to return all records.
Defaults to 100 if not specified.

.EXAMPLE
```powershell
Get-SQLiteViewData -DatabaseFilePath ""C:\MyDb.sqlite"" `
    -ViewName ""CustomerView"" -Count 50
```

Returns at most 50 rows from the view.

.EXAMPLE
```powershell
Get-SQLiteViewData -DatabaseFilePath ""C:\MyDb.sqlite"" `
    -ViewName ""CustomerView"" -Count -1
```

Returns every row from the view.
")]
    [Cmdlet(verbName:"Get", "SQLiteViewData", DefaultParameterSetName = "DatabaseFilePath")]
    [OutputType(typeof(Hashtable))]
    public class GetSqliteViewDataCommand : PSGenXdevCmdlet
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
        /// The name of the view to query.
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = true,
            HelpMessage = "The name of the view to query.")]
        [ValidateNotNullOrEmpty]
        public string ViewName { get; set; }

        /// <summary>
        /// Number of records to return. -1 returns all.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = false,
            HelpMessage = "Number of records to return. -1 for all records.")]
        [ValidateRange(-1, int.MaxValue)]
        public int Count { get; set; } = 100;

        /// <summary>
        /// Process record - retrieves the view rows.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Starting Get-SQLiteViewData for view: " + ViewName);

            string query = Count == -1 ?
                $"SELECT * FROM {ViewName}" :
                $"SELECT * FROM {ViewName} LIMIT {Count}";

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
