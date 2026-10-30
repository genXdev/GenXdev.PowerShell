using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves data from a SQL database table with optional record limiting.

.DESCRIPTION
This command queries data from a SQL Server table using either a connection
string or a database name with server. It provides flexibility in connecting to
the database and controlling the amount of data retrieved through the Count
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
The connection string to the SQL Server database.

.PARAMETER DatabaseName
The name of the SQL Server database.

.PARAMETER Server
The SQL Server instance name. Defaults to 'localhost'.

.PARAMETER TableName
The name of the table to query data from. The table must exist in the database.

.PARAMETER Count
The maximum number of records to return. Default is 100. Use -1 to return all
records. Must be -1 or a positive integer.

.EXAMPLE
```powershell
Get-SQLServerTableData -DatabaseName ""tempdb"" -Server ""localhost"" `
    -TableName ""Employees"" -Count 50
```

Returns at most 50 rows from the Employees table.

.EXAMPLE
```powershell
Get-SQLServerTableData -DatabaseName ""tempdb"" -TableName ""Employees"" -Count -1
```

Returns every row from the Employees table.
")]
    [Cmdlet(verbName:"Get", "SQLServerTableData", DefaultParameterSetName = "DatabaseName")]
    [OutputType(typeof(Hashtable))]
    public class GetSqlServerTableDataCommand : PSGenXdevCmdlet
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
        /// The name of the table to query data from.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = true,
            HelpMessage = "The name of the table to query data from.")]
        [ValidateNotNullOrEmpty]
        public string TableName { get; set; }

        /// <summary>
        /// The maximum number of records to return. -1 returns all.
        /// </summary>
        [Parameter(
            Position = 3,
            Mandatory = false,
            HelpMessage = "The maximum number of records to return. -1 for all.")]
        [ValidateRange(-1, int.MaxValue)]
        public int Count { get; set; } = 100;

        /// <summary>
        /// Process record - retrieves the table rows.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Starting Get-SQLServerTableData for table: " + TableName);

            string query = Count == -1 ?
                $"SELECT * FROM {TableName}" :
                $"SELECT TOP ({Count}) * FROM {TableName}";

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
