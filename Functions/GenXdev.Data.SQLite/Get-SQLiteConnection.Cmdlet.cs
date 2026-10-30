using System.Data.SQLite;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Opens a SQLite connection that the caller owns.

.DESCRIPTION
Opens a SQLite connection and returns it, leaving the caller responsible for
closing it. No transaction is started, so the connection runs in autocommit mode
and keeps one session across every command executed on it. Hand it to
Invoke-SQLiteQuery or Invoke-SQLiteScriptFile with -Connection to keep session
state such as temporary tables and PRAGMA settings alive across calls.

Opening a connection to a database file that does not exist creates it.

Connection priority: ConnectionString > DatabaseFilePath.

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

.PARAMETER DatabaseFilePath
The path to the SQLite database file. Will be converted to a connection string.

.PARAMETER ConnectionString
The SQLite connection string for database access.

.EXAMPLE
```powershell
$connection = Get-SQLiteConnection -DatabaseFilePath ""C:\data.db""
try {
    Invoke-SQLiteQuery -Connection $connection -Queries ""SELECT * FROM Users""
}
finally {
    $connection.Close()
}
```

Keeps one session across every query executed on the connection.

.EXAMPLE
```powershell
Get-SQLiteConnection -ConnectionString ""Data Source=C:\data.db""
```

Opens a connection from a connection string.
")]
    [Cmdlet(verbName:"Get", "SQLiteConnection")]
    [OutputType(typeof(SQLiteConnection))]
    public class GetSqliteConnectionCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The path to the SQLite database file.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = false,
            HelpMessage = "The path to the SQLite database file.")]
        [ValidateNotNullOrEmpty]
        [Alias("dbpath", "indexpath")]
        public string DatabaseFilePath { get; set; }

        /// <summary>
        /// The connection string to the SQLite database.
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = false,
            HelpMessage = "The connection string to the SQLite database.")]
        public string ConnectionString { get; set; }

        /// <summary>
        /// Process record - opens the connection and hands it to the caller.
        /// </summary>
        protected override void ProcessRecord()
        {
            if (!ApplyDefaultParameterValues(nameof(DatabaseFilePath)))
            {
                ApplyDefaultParameterValues(nameof(ConnectionString));
            }

            string connectionString;

            if (!string.IsNullOrWhiteSpace(ConnectionString))
            {
                connectionString = ConnectionString;
            }
            else if (!string.IsNullOrWhiteSpace(DatabaseFilePath))
            {
                connectionString = SQLiteConnectionString.Build(
                    null,
                    ExpandPath(DatabaseFilePath));
            }
            else
            {
                ThrowTerminatingError(new ErrorRecord(
                    new InvalidOperationException(
                        "You must provide either a ConnectionString or " +
                        "DatabaseFilePath parameter."),
                    "GetSQLiteConnectionError",
                    ErrorCategory.InvalidArgument,
                    null));

                return;
            }

            WriteVerbose(
                $"Will open connection with connection string: {connectionString}");

            SQLiteConnection connection = new(connectionString);
            connection.Open();

            WriteVerbose("SQLite connection opened, the caller owns it");

            WriteObject(connection);
        }
    }
}
