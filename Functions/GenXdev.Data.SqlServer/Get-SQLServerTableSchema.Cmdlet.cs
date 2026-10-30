using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves the schema information for a specified SQL Server table.

.DESCRIPTION
This command queries the SQL Server database to get detailed schema information
for a specified table. It uses the SQL Server INFORMATION_SCHEMA.COLUMNS view to
return column definitions including names, types, nullable status, and default
values. Every column is returned as a hashtable.

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
The SQL Server connection string in the format:
Server=servername;Database=databasename;Integrated Security=true

.PARAMETER DatabaseName
The name of the SQL Server database.

.PARAMETER Server
The SQL Server instance name. Defaults to '.'.

.PARAMETER TableName
The name of the table for which to retrieve schema information.

.EXAMPLE
```powershell
Get-SQLServerTableSchema -DatabaseName ""mydb"" -Server ""localhost"" `
    -TableName ""Users""
```

Returns the column definitions of the Users table.

.EXAMPLE
```powershell
Get-SQLServerTableSchema `
    -ConnectionString ""Server=localhost;Database=mydb;Integrated Security=true"" `
    -TableName ""Products""
```

Returns the column definitions using a custom connection string.
")]
    [Cmdlet(verbName:"Get", "SQLServerTableSchema", DefaultParameterSetName = "DatabaseName")]
    [OutputType(typeof(Hashtable))]
    public class GetSqlServerTableSchemaCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The connection string to the SQL Server database.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "ConnectionString",
            HelpMessage = "The connection string to the SQL Server database")]
        [ValidateNotNullOrEmpty]
        public string ConnectionString { get; set; }

        /// <summary>
        /// The name of the SQL Server database.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "DatabaseName",
            HelpMessage = "The name of the SQL Server database")]
        [ValidateNotNullOrEmpty]
        public string DatabaseName { get; set; }

        /// <summary>
        /// The SQL Server instance name.
        /// </summary>
        [Parameter(
            Position = 1,
            ParameterSetName = "DatabaseName",
            HelpMessage = "The SQL Server instance name")]
        public string Server { get; set; } = ".";

        /// <summary>
        /// The name of the table.
        /// </summary>
        [Parameter(
            Position = 2,
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

            Hashtable parameters = CopyIdenticalParamValues("Invoke-SQLServerQuery");
            parameters["Queries"] = $@"
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '{TableName}'
ORDER BY ORDINAL_POSITION
";

            WriteVerbose("Executing schema query against SQL Server database");

            foreach (Hashtable record in InvokeCmdlet<Hashtable>(
                "Invoke-SQLServerQuery",
                parameters))
            {
                WriteObject(record);
            }
        }
    }
}
