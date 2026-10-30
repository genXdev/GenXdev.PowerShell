using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves a list of table names from a SQL Server database.

.DESCRIPTION
Queries the SQL Server system tables to retrieve all user-defined table names
from a SQL Server database. Supports connecting via either a direct connection
string or a database name with server parameters. Every table is returned as a
hashtable with a name property, sorted by name.

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
The full connection string to connect to the SQL Server database. Should include
the Server and Database parameters at minimum.

.PARAMETER DatabaseName
The name of the SQL Server database.

.PARAMETER Server
The SQL Server instance name. Defaults to '.'.

.EXAMPLE
```powershell
Get-SQLServerTables -DatabaseName ""Inventory"" -Server ""localhost""
```

Returns all table names from the specified database.

.EXAMPLE
```powershell
Get-SQLServerTables `
    -ConnectionString ""Server=localhost;Database=Users;Integrated Security=true;""
```

Returns all table names using a custom connection string.
")]
    [Cmdlet(verbName:"Get", "SQLServerTables", DefaultParameterSetName = "DatabaseName")]
    [OutputType(typeof(Hashtable))]
    public class GetSqlServerTablesCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The connection string to the SQL Server database.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "ConnectionString",
            HelpMessage = "The connection string to the SQL Server database.")]
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
        public string Server { get; set; } = ".";

        /// <summary>
        /// Process record - retrieves the table names.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Starting SQL table name retrieval operation");

            Hashtable parameters = CopyIdenticalParamValues("Invoke-SQLServerQuery");
            parameters["Queries"] = "SELECT name FROM sys.tables ORDER BY name";

            foreach (Hashtable record in InvokeCmdlet<Hashtable>(
                "Invoke-SQLServerQuery",
                parameters))
            {
                WriteObject(record);
            }
        }
    }
}
