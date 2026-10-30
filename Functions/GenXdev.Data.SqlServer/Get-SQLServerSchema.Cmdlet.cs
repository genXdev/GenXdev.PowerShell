using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves the complete schema information from a SQL Server database.

.DESCRIPTION
This command queries SQL Server system tables to obtain the complete schema
definition of a SQL Server database, including tables, views, stored procedures
and functions. It accepts either a connection string or database name with
server parameters. Every object is returned as a hashtable with object_type,
name, schema_id and object_id.

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
The SQL Server connection string that specifies the database location and any
additional connection parameters.

.PARAMETER DatabaseName
The name of the SQL Server database.

.PARAMETER Server
The SQL Server instance name. Defaults to 'localhost'.

.EXAMPLE
```powershell
Get-SQLServerSchema -DatabaseName ""inventory"" -Server ""localhost""
```

Lists every table, view, procedure and function in the database.

.EXAMPLE
```powershell
Get-SQLServerSchema `
    -ConnectionString ""Server=localhost;Database=inventory;Integrated Security=true;""
```

Lists the schema objects using a custom connection string.
")]
    [Cmdlet(verbName:"Get", "SQLServerSchema", DefaultParameterSetName = "DatabaseName")]
    [OutputType(typeof(Hashtable))]
    public class GetSqlServerSchemaCommand : PSGenXdevCmdlet
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
        /// Process record - retrieves the schema objects.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose($"Using parameter set: {ParameterSetName}");

            Hashtable parameters = CopyIdenticalParamValues("Invoke-SQLServerQuery");
            parameters["Queries"] = new string[] {
                "SELECT 'TABLE' as object_type, name, schema_id, object_id " +
                    "FROM sys.tables ORDER BY name",
                "SELECT 'VIEW' as object_type, name, schema_id, object_id " +
                    "FROM sys.views ORDER BY name",
                "SELECT 'PROCEDURE' as object_type, name, schema_id, object_id " +
                    "FROM sys.procedures ORDER BY name",
                "SELECT 'FUNCTION' as object_type, name, schema_id, object_id " +
                    "FROM sys.objects WHERE type IN ('FN','IF','TF') ORDER BY name" };

            foreach (Hashtable record in InvokeCmdlet<Hashtable>(
                "Invoke-SQLServerQuery",
                parameters))
            {
                WriteObject(record);
            }
        }
    }
}
