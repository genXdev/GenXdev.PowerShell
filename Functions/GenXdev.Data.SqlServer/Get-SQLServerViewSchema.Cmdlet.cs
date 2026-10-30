using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves the SQL schema definition for a SQL Server view.

.DESCRIPTION
This command queries the SQL Server system tables to extract the SQL definition
of a specified view. It supports connecting via either a connection string or a
database name with server and returns the complete SQL schema that defines the
requested view as a hashtable with a view_definition property.

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
The connection string used to connect to the SQL Server database.

.PARAMETER DatabaseName
The name of the SQL Server database.

.PARAMETER Server
The SQL Server instance name. Defaults to 'localhost'.

.PARAMETER ViewName
The name of the view whose schema definition should be retrieved.

.EXAMPLE
```powershell
Get-SQLServerViewSchema -DatabaseName ""MyApp"" -Server ""localhost"" `
    -ViewName ""CustomerOrders""
```

Returns the SQL definition of the CustomerOrders view.

.EXAMPLE
```powershell
Get-SQLServerViewSchema `
    -ConnectionString ""Server=localhost;Database=MyApp;Integrated Security=true"" `
    -ViewName ""CustomerOrders""
```

Returns the definition using a custom connection string.
")]
    [Cmdlet(verbName:"Get", "SQLServerViewSchema", DefaultParameterSetName = "DatabaseName")]
    [OutputType(typeof(Hashtable))]
    public class GetSqlServerViewSchemaCommand : PSGenXdevCmdlet
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
        public string Server { get; set; } = "localhost";

        /// <summary>
        /// The name of the view.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = true,
            HelpMessage = "The name of the view.")]
        public string ViewName { get; set; }

        /// <summary>
        /// Process record - retrieves the view definition.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Retrieving schema for view: " + ViewName);

            string query =
                $"SELECT OBJECT_DEFINITION(OBJECT_ID('{ViewName}')) AS view_definition";

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
