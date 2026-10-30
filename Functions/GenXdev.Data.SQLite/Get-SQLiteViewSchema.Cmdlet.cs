using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Retrieves the SQL schema definition for a SQLite view.

.DESCRIPTION
This command queries the SQLite system tables to extract the SQL definition of a
specified view. It supports connecting via either a connection string or direct
database file path and returns the complete SQL schema that defines the
requested view as a hashtable with a sql property.

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
The connection string used to connect to the SQLite database.

.PARAMETER DatabaseFilePath
The full path to the SQLite database file.

.PARAMETER ViewName
The name of the view whose schema definition should be retrieved.

.EXAMPLE
```powershell
Get-SQLiteViewSchema -DatabaseFilePath ""C:\Databases\MyApp.sqlite"" `
    -ViewName ""CustomerOrders""
```

Returns the SQL definition of the CustomerOrders view.

.EXAMPLE
```powershell
Get-SQLiteViewSchema `
    -ConnectionString ""Data Source=C:\Databases\MyApp.sqlite"" `
    -ViewName ""CustomerOrders""
```

Returns the definition using a custom connection string.
")]
    [Cmdlet(verbName:"Get", "SQLiteViewSchema", DefaultParameterSetName = "DatabaseFilePath")]
    [OutputType(typeof(Hashtable))]
    public class GetSqliteViewSchemaCommand : PSGenXdevCmdlet
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
        /// Process record - retrieves the view definition.
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Retrieving schema for view: " + ViewName);

            string query =
                $"SELECT sql FROM sqlite_master WHERE name = '{ViewName}'";

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
