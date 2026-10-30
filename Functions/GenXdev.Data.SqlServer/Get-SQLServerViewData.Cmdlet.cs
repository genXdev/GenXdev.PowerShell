using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves data from a SQL database view with optional record limiting.

.DESCRIPTION
Queries a SQL Server view using either a connection string or a database name
with server. The command supports limiting the number of returned records and
provides verbose output for tracking query execution. Every row is returned as
a hashtable keyed by column name.

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
The connection string to connect to the SQL database.

.PARAMETER DatabaseName
The name of the SQL Server database.

.PARAMETER Server
The SQL Server instance name. Defaults to 'localhost'.

.PARAMETER ViewName
The name of the view from which to retrieve data.

.PARAMETER Count
The maximum number of records to return. Use -1 to return all records.
Defaults to 100 if not specified.

.EXAMPLE
```powershell
Get-SQLServerViewData -DatabaseName ""tempdb"" `
    -ViewName ""CustomerView"" -Count 50
```

Returns at most 50 rows from the view.

.EXAMPLE
```powershell
Get-SQLServerViewData -DatabaseName ""tempdb"" `
    -ViewName ""CustomerView"" -Count -1
```

Returns every row from the view.
")]
    [Cmdlet(verbName:"Get", "SQLServerViewData", DefaultParameterSetName = "DatabaseName")]
    [OutputType(typeof(Hashtable))]
    public class GetSqlServerViewDataCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The connection string to the SQL Server database.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "ConnectionString",
            HelpMessage = "The connection string to the SQL Server database.")]
        [ValidateNotNullOrEmpty]
        public string ConnectionString { get; set; }

        /// <summary>
        /// The name of the SQL Server database.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "DatabaseName",
            HelpMessage = "The name of the SQL Server database.")]
        [ValidateNotNullOrEmpty]
        public string DatabaseName { get; set; }

        /// <summary>
        /// The SQL Server instance name.
        /// </summary>
        [Parameter(
            Position = 1,
            ParameterSetName = "DatabaseName",
            HelpMessage = "The SQL Server instance name.")]
        public string Server { get; set; } = "localhost";

        /// <summary>
        /// The name of the view to query.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = true,
            HelpMessage = "The name of the view to query.")]
        [ValidateNotNullOrEmpty]
        public string ViewName { get; set; }

        /// <summary>
        /// Number of records to return. -1 returns all.
        /// </summary>
        [Parameter(
            Position = 3,
            Mandatory = false,
            HelpMessage = "Number of records to return. -1 for all records.")]
        [ValidateRange(-1, int.MaxValue)]
        public int Count { get; set; } = 100;

        /// <summary>
        /// Process record - retrieves the view rows.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Starting Get-SQLServerViewData for view: " + ViewName);

            string query = Count == -1 ?
                $"SELECT * FROM {ViewName}" :
                $"SELECT TOP ({Count}) * FROM {ViewName}";

            WriteVerbose($"Executing query: {query}");

            Hashtable parameters = CopyIdenticalParamValues("Invoke-SQLServerQuery");
            parameters["Queries"] = query;

            foreach (Hashtable record in InvokeCmdlet<Hashtable>(
                "Invoke-SQLServerQuery",
                parameters))
            {
                WriteObject(record);
            }
        }
    }
}
