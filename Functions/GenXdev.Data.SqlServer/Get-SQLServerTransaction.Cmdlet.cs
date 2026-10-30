using Microsoft.Data.SqlClient;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Creates and returns a SQL Server transaction object for batch operations.

.DESCRIPTION
Creates a SQL Server transaction object that can be used for batch operations.
The caller is responsible for committing or rolling back the transaction. When no
Connection is provided, a connection is opened for the transaction and returned
inside it, so the caller then owns that connection and must close it.
Connection priority: Connection > ConnectionString > DatabaseName (requires
Server).

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

.PARAMETER Connection
An existing open SqlConnection to begin the transaction on, as returned by
Get-SQLServerConnection. The caller owns the connection, so it is neither opened
nor closed here.

.PARAMETER ConnectionString
The SQL Server connection string for database access.

.PARAMETER DatabaseName
The name of the SQL Server database. Used with Server parameter to create
connection string.

.PARAMETER Server
The SQL Server instance name. Defaults to '.'.

.PARAMETER IsolationLevel
Transaction isolation level. Defaults to ReadCommitted.

.EXAMPLE
```powershell
$transaction = Get-SQLServerTransaction -Server ""localhost"" `
    -DatabaseName ""MyDatabase""
try {
    Invoke-SQLServerQuery -Transaction $transaction `
        -Queries ""INSERT INTO Users VALUES (@name)"" `
        -SqlParameters @{""name""=""John""}
    $transaction.Commit()
} catch {
    $transaction.Rollback()
    throw
} finally {
    $transaction.Connection.Close()
}
```

Runs statements inside a transaction the caller commits or rolls back.
")]
    [Cmdlet(verbName:"Get", "SQLServerTransaction", DefaultParameterSetName = "DatabaseName")]
    [OutputType(typeof(SqlTransaction))]
    [Alias("getsqltx", "newsqltx")]
    public class GetSqlServerTransactionCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// An existing open SqlConnection to begin the transaction on.
        /// </summary>
        [Parameter(
            Mandatory = true,
            ParameterSetName = "Connection",
            HelpMessage = "An existing open SqlConnection to begin the transaction on.")]
        public SqlConnection Connection { get; set; }

        /// <summary>
        /// The SQL Server connection string for database access.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ParameterSetName = "ConnectionString",
            HelpMessage = "The connection string to the SQL database.")]
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
            Mandatory = false,
            ParameterSetName = "DatabaseName",
            HelpMessage = "The SQL Server instance name.")]
        public string Server { get; set; } = ".";

        /// <summary>
        /// The isolation level the transaction is started with.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Transaction isolation level.")]
        [ValidateSet("ReadCommitted", "ReadUncommitted", "RepeatableRead",
            "Serializable", "Snapshot", "Chaos")]
        public string IsolationLevel { get; set; } = "ReadCommitted";

        /// <summary>
        /// Process record - starts the transaction and hands it to the caller.
        /// </summary>
        protected override void ProcessRecord()
        {
            // only a connection opened here is closed here on failure
            bool ownsConnection = ParameterSetName != "Connection";
            SqlConnection connection = null;

            try
            {
                connection = ownsConnection ?
                    new SqlConnection(SqlServerConnectionString.Build(
                        this,
                        ConnectionString,
                        Server,
                        DatabaseName)) :
                    Connection;

                if (ownsConnection) connection.Open();

                SqlTransaction transaction = connection.BeginTransaction(
                    Enum.Parse<System.Data.IsolationLevel>(IsolationLevel, true));

                WriteVerbose($"Transaction started with {IsolationLevel} " +
                    "isolation level");

                WriteObject(transaction);
            }
            catch
            {
                if (ownsConnection && connection?.State == System.Data.ConnectionState.Open)
                {
                    connection.Close();
                }

                throw;
            }
        }
    }
}
