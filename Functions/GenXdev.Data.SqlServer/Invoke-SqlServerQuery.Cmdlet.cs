using Microsoft.Data.SqlClient;
using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Executes one or more SQL queries against a SQL Server database with transaction support.

.DESCRIPTION
Executes SQL queries against a SQL Server database with parameter support and
configurable transaction isolation. Can use an external transaction for batch
operations or create its own internal transaction. When using an external
transaction, the caller is responsible for committing/rolling back.
Connection priority: Transaction > Connection > ConnectionString > DatabaseName
(requires Server). An explicitly provided DatabaseName replaces the database of
the ConnectionString.

Every row of every result set is returned as a hashtable keyed by column name.

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

.PARAMETER Queries
One or more SQL queries to execute. Can be passed via pipeline.

.PARAMETER DatabaseName
The name of the SQL Server database to connect to. Requires Server parameter
when no ConnectionString is provided. When explicitly provided, it replaces the
database named in the ConnectionString.

.PARAMETER Server
The SQL Server instance name. Used with DatabaseName to create connection string.

.PARAMETER Transaction
An existing SQL Server transaction to use. When provided, the command will not
commit or rollback the transaction - that is the caller's responsibility.
Takes priority over Connection, ConnectionString and DatabaseName/Server.

.PARAMETER Connection
An existing open SqlConnection to execute on. The caller owns the connection, so
it is never closed here, and without a Transaction every query runs in
autocommit mode. Takes priority over ConnectionString and DatabaseName/Server.

.PARAMETER ConnectionString
The SQL Server connection string for database access. Used if no Transaction or
Connection is provided.

.PARAMETER SqlParameters
Optional parameters for the queries as hashtables. Format: @{""param""=""value""}
The n-th parameter set applies to the n-th query.

.PARAMETER IsolationLevel
Transaction isolation level. Defaults to ReadCommitted. Only used when creating
an internal transaction. Use NoTransaction to run the queries in autocommit
mode, for statements that SQL Server refuses inside a transaction, such as
BACKUP DATABASE. Ignored for a caller-provided Transaction.

.PARAMETER TimeoutSeconds
Command timeout in seconds for every query. Defaults to 3600. Use 0 to wait
indefinitely, or a larger value for long-running queries.

.EXAMPLE
```powershell
Invoke-SQLServerQuery -Server ""localhost"" -DatabaseName ""MyDB"" `
    -Queries ""SELECT * FROM Users""
```

Returns every user row as a hashtable.

.EXAMPLE
```powershell
$tx = Get-SQLServerTransaction -Server ""localhost"" -DatabaseName ""MyDB""
try {
    Invoke-SQLServerQuery -Transaction $tx `
        -Queries ""INSERT INTO Users VALUES (@name)"" `
        -SqlParameters @{""name""=""John""}
    $tx.Commit()
} catch {
    $tx.Rollback()
    throw
} finally {
    $tx.Connection.Close()
}
```

Runs a statement inside a transaction the caller owns.
")]
    [Cmdlet(verbName:"Invoke", "SQLServerQuery")]
    [OutputType(typeof(Hashtable))]
    public partial class InvokeSqlServerQueryCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// One or more SQL queries to execute.
        /// </summary>
        [Parameter(
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The query or queries to execute.")]
        [Alias("q", "Value", "Name", "Text", "Query")]
        public string[] Queries { get; set; }

        /// <summary>
        /// The name of the SQL Server database to connect to.
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = false,
            HelpMessage = "The name of the SQL Server database.")]
        [ValidateNotNullOrEmpty]
        public string DatabaseName { get; set; } = "master";

        /// <summary>
        /// The SQL Server instance name.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = false,
            HelpMessage = "The SQL Server instance name.")]
        public string Server { get; set; } = ".";

        /// <summary>
        /// An existing SQL Server transaction to use for the queries.
        /// </summary>
        [Parameter(
            Position = 3,
            Mandatory = false,
            HelpMessage = "An existing SQL Server transaction to use for the queries.")]
        public SqlTransaction Transaction { get; set; }

        /// <summary>
        /// An existing open SqlConnection to execute on.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "An existing open SqlConnection to execute on.")]
        public SqlConnection Connection { get; set; }

        /// <summary>
        /// The connection string to the SQL database.
        /// </summary>
        [Parameter(
            Position = 4,
            Mandatory = false,
            HelpMessage = "The connection string to the SQL database.")]
        public string ConnectionString { get; set; }

        /// <summary>
        /// Query parameters as hashtables, one set per query.
        /// </summary>
        [Parameter(
            Position = 5,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Query parameters as hashtables.")]
        [Alias("data", "parameters", "args")]
        public Hashtable[] SqlParameters { get; set; }

        /// <summary>
        /// The isolation level to use when an internal transaction is created.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "The isolation level to use, or NoTransaction for " +
                "autocommit mode. Default is ReadCommitted.")]
        [ValidateSet("ReadCommitted", "ReadUncommitted", "RepeatableRead",
            "Serializable", "Snapshot", "Chaos", "NoTransaction")]
        public string IsolationLevel { get; set; } = "ReadCommitted";

        /// <summary>
        /// Command timeout in seconds for every query.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Command timeout in seconds for every query. Default is 30, 0 waits indefinitely.")]
        [Alias("timeout", "maxseconds")]
        [ValidateRange(0, int.MaxValue)]
        public int TimeoutSeconds { get; set; } = 3600;

        /// <summary>
        /// Process record - collects the queries that were piped in.
        /// </summary>
        protected override void ProcessRecord()
        {
            if (Queries == null) return;

            foreach (string query in Queries)
            {
                if (query == null) continue;

                queries.Add(query);
            }
        }

        /// <summary>
        /// End processing - executes every collected query in order.
        /// </summary>
        protected override void EndProcessing()
        {
            if (queries.Count == 0)
            {
                ThrowTerminatingError(new ErrorRecord(
                    new InvalidOperationException(
                        "You must provide at least one query to execute."),
                    "InvokeSQLServerQueryError",
                    ErrorCategory.InvalidArgument,
                    null));
            }

            // only a connection opened here is closed here
            bool ownsConnection = Transaction == null && Connection == null;

            bool useInternalTransaction = !string.Equals(
                IsolationLevel, "NoTransaction", StringComparison.OrdinalIgnoreCase);

            SqlConnection ownedConnection = null;
            SqlConnection connection = null;
            SqlTransaction transaction = null;

            try
            {
                if (Transaction != null)
                {
                    transaction = Transaction;
                    connection = Transaction.Connection;

                    if (connection == null)
                    {
                        ThrowTerminatingError(new ErrorRecord(
                            new InvalidOperationException(
                                "The provided transaction no longer has a connection."),
                            "InvokeSQLServerQueryError",
                            ErrorCategory.InvalidOperation,
                            null));
                    }
                }
                else if (Connection != null)
                {
                    connection = Connection;
                }
                else
                {
                    ApplyDefaultParameterValues(nameof(DatabaseName));

                    if (!ApplyDefaultParameterValues(nameof(Server)))
                    {
                        ApplyDefaultParameterValues(nameof(ConnectionString));
                    }

                    connection = new SqlConnection(SqlServerConnectionString.Build(
                        this,
                        ConnectionString,
                        Server,
                        DatabaseName));

                    connection.Open();
                    ownedConnection = connection;

                    if (useInternalTransaction)
                    {
                        transaction = connection.BeginTransaction(
                            Enum.Parse<System.Data.IsolationLevel>(IsolationLevel, true));

                        WriteVerbose("Started internal transaction with " +
                            $"{IsolationLevel} isolation level");
                    }
                    else
                    {
                        WriteVerbose("Running in autocommit mode");
                    }
                }

                // forward informational messages, such as PRINT output
                SqlInfoMessageEventHandler infoMessageHandler = (sender, arguments) =>
                    WriteInformation(arguments.Message, []);

                connection.InfoMessage += infoMessageHandler;

                try
                {
                    ExecuteQueries(connection, transaction);

                    if (ownsConnection && transaction != null) transaction.Commit();
                }
                catch
                {
                    if (ownsConnection && transaction != null) transaction.Rollback();

                    throw;
                }
                finally
                {
                    connection.InfoMessage -= infoMessageHandler;
                }
            }
            finally
            {
                ownedConnection?.Close();
            }
        }
    }
}
