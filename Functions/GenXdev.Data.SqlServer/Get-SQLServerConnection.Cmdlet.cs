using Microsoft.Data.SqlClient;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Opens a SQL Server connection that the caller owns.

.DESCRIPTION
Opens a SQL Server connection and returns it, leaving the caller responsible for
closing it. No transaction is started, so the connection runs in autocommit mode
and keeps one session across every command executed on it. Hand it to
Invoke-SQLServerQuery or Invoke-SQLServerScriptFile with -Connection to keep
session state such as USE, temp tables and SET options alive across calls.

Connection priority: ConnectionString > DatabaseName (requires Server). An
explicitly provided DatabaseName replaces the database of the ConnectionString.

When no connection parameter is bound, the command uses the values
$PSDefaultParameterValues holds for it in the caller's scope.

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

.PARAMETER DatabaseName
The name of the SQL Server database to connect to. Requires Server parameter
when no ConnectionString is provided. When explicitly provided, it replaces the
database named in the ConnectionString.

.PARAMETER Server
The SQL Server instance name. Used with DatabaseName to create connection string.

.PARAMETER ConnectionString
The SQL Server connection string for database access.

.EXAMPLE
```powershell
$connection = Get-SQLServerConnection -Server ""localhost"" -DatabaseName ""MyDB""
try {
    Invoke-SQLServerQuery -Connection $connection -Queries ""SELECT * FROM Users""
}
finally {
    $connection.Close()
}
```

Keeps one session across every query executed on the connection.

.EXAMPLE
```powershell
Get-SQLServerConnection `
    -ConnectionString ""Server=localhost;Database=MyDB;Integrated Security=true""
```

Opens a connection from a connection string.
")]
    [Cmdlet(verbName:"Get", "SQLServerConnection")]
    [OutputType(typeof(SqlConnection))]
    [Alias("getsqlconnection", "newsqlconnection")]
    public class GetSqlServerConnectionCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The name of the SQL Server database to connect to.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = false,
            HelpMessage = "The name of the SQL Server database.")]
        [ValidateNotNullOrEmpty]
        public string DatabaseName { get; set; } = "master";

        /// <summary>
        /// The SQL Server instance name.
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = false,
            HelpMessage = "The SQL Server instance name.")]
        public string Server { get; set; } = ".";

        /// <summary>
        /// The connection string to the SQL database.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = false,
            HelpMessage = "The connection string to the SQL database.")]
        public string ConnectionString { get; set; }

        /// <summary>
        /// Process record - opens the connection and hands it to the caller.
        /// </summary>
        protected override void ProcessRecord()
        {
            ApplyDefaultParameterValues(nameof(DatabaseName));

            if (!ApplyDefaultParameterValues(nameof(Server)))
            {
                ApplyDefaultParameterValues(nameof(ConnectionString));
            }

            string connectionString = SqlServerConnectionString.Build(
                this,
                ConnectionString,
                Server,
                DatabaseName);

            WriteVerbose(
                $"Will open connection with connection string: {connectionString}");

            SqlConnection connection = new(connectionString);
            connection.Open();

            WriteVerbose("SQL Server connection opened, the caller owns it");

            WriteObject(connection);
        }
    }
}
