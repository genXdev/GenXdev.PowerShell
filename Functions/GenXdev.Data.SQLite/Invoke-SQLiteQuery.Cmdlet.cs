using System.Collections;
using System.Data.SQLite;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Executes one or more SQL queries against a SQLite database with transaction support.

.DESCRIPTION
Executes SQL queries against a SQLite database with parameter support and
configurable transaction isolation. Can use an external transaction for batch
operations or create its own internal transaction. When using an external
transaction, the caller is responsible for committing/rolling back.
Connection priority: Transaction > Connection > ConnectionString >
DatabaseFilePath.

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

.PARAMETER ConnectionString
The SQLite connection string for database access. Used if no Transaction is
provided.

.PARAMETER DatabaseFilePath
The file path to the SQLite database. Will be converted to a connection string.
Used if no Transaction or ConnectionString is provided.

.PARAMETER Transaction
An existing SQLite transaction to use. When provided, the command will not
commit or rollback the transaction - that is the caller's responsibility.
Takes priority over Connection, ConnectionString and DatabaseFilePath.

.PARAMETER Connection
An existing open SQLiteConnection to execute on. The caller owns the connection,
so it is never closed here, and without a Transaction every query runs in
autocommit mode. Takes priority over ConnectionString and DatabaseFilePath.

.PARAMETER Queries
One or more SQL queries to execute. Can be passed via pipeline.

.PARAMETER SqlParameters
Optional parameters for the queries as hashtables. Format: @{""param""=""value""}
The n-th parameter set applies to the n-th query.

.PARAMETER IsolationLevel
Transaction isolation level. Defaults to ReadCommitted. Only used when creating
an internal transaction. Use NoTransaction to run the queries in autocommit
mode. Ignored for a caller-provided Transaction.

.PARAMETER TimeoutSeconds
Command timeout in seconds for every query. Defaults to 3600. For SQLite this is
the time to wait for a locked database, not a total execution limit.

.EXAMPLE
```powershell
Invoke-SQLiteQuery -DatabaseFilePath ""C:\data.db"" `
    -Queries ""SELECT * FROM Users""
```

Returns every user row as a hashtable.

.EXAMPLE
```powershell
$tx = Get-SQLiteTransaction -DatabaseFilePath ""C:\data.db""
try {
    Invoke-SQLiteQuery -Transaction $tx `
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
    [Cmdlet(verbName:"Invoke", "SQLiteQuery")]
    [OutputType(typeof(Hashtable))]
    public partial class InvokeSqliteQueryCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The connection string to the SQLite database.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = false,
            HelpMessage = "The connection string to the SQLite database.")]
        public string ConnectionString { get; set; }

        /// <summary>
        /// The path to the SQLite database file.
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = false,
            HelpMessage = "The path to the SQLite database file.")]
        [ValidateNotNullOrEmpty]
        [Alias("dbpath", "indexpath")]
        public string DatabaseFilePath { get; set; }

        /// <summary>
        /// An existing SQLite transaction to use for the queries.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = false,
            HelpMessage = "An existing SQLite transaction to use for the queries.")]
        public SQLiteTransaction Transaction { get; set; }

        /// <summary>
        /// An existing open SQLiteConnection to execute on.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "An existing open SQLiteConnection to execute on.")]
        public SQLiteConnection Connection { get; set; }

        /// <summary>
        /// One or more SQL queries to execute.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 3,
            ValueFromRemainingArguments = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The query or queries to execute.")]
        [Alias("q", "Value", "Name", "Text", "Query")]
        public string[] Queries { get; set; }

        /// <summary>
        /// Query parameters as hashtables, one set per query.
        /// </summary>
        [Parameter(
            Position = 4,
            ValueFromRemainingArguments = true,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Query parameters as hashtables.")]
        [Alias("data", "parameters", "args")]
        public Hashtable[] SqlParameters { get; set; }

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
            SQLiteConnection ownedConnection = null;
            SQLiteConnection connection = null;
            SQLiteTransaction transaction = null;

            // only a transaction started here is committed or rolled back here
            bool ownsTransaction = Transaction == null && Connection == null;

            bool useInternalTransaction = !string.Equals(
                IsolationLevel, "NoTransaction", StringComparison.OrdinalIgnoreCase);

            try
            {
                if (Transaction != null)
                {
                    transaction = Transaction;
                    connection = (SQLiteConnection)Transaction.Connection;

                    if (connection == null)
                    {
                        ThrowTerminatingError(NewFailure(
                            "The provided transaction no longer has a connection.",
                            null));
                    }
                }
                else if (Connection != null)
                {
                    connection = Connection;
                }
                else
                {
                    if (!ApplyDefaultParameterValues(nameof(DatabaseFilePath)))
                    {
                        ApplyDefaultParameterValues(nameof(ConnectionString));
                    }

                    string connectionString = !string.IsNullOrWhiteSpace(ConnectionString) ?
                        ConnectionString :
                        !string.IsNullOrWhiteSpace(DatabaseFilePath) ?
                        SQLiteConnectionString.Build(
                            null,
                            ExpandPath(DatabaseFilePath)) :
                        null;

                    if (connectionString == null)
                    {
                        ThrowTerminatingError(NewFailure(
                            "You must provide either a Transaction, " +
                            "ConnectionString, or DatabaseFilePath parameter.",
                            null));
                    }

                    WriteVerbose("Will open internal connection with " +
                        $"connection string: {connectionString}");

                    connection = new SQLiteConnection(connectionString);
                    connection.Open();
                    ownedConnection = connection;

                    if (useInternalTransaction)
                    {
                        transaction = (SQLiteTransaction)connection.BeginTransaction(
                            Enum.Parse<System.Data.IsolationLevel>(IsolationLevel, true));

                        WriteVerbose("Started internal transaction with " +
                            $"{IsolationLevel} isolation");
                    }
                    else
                    {
                        WriteVerbose("Running in autocommit mode");
                    }
                }

                try
                {
                    ExecuteQueries(connection, transaction);

                    if (ownsTransaction && transaction != null) transaction.Commit();
                }
                catch
                {
                    if (ownsTransaction && transaction != null) transaction.Rollback();

                    throw;
                }
            }
            finally
            {
                if (ownedConnection != null)
                {
                    ownedConnection.Close();
                    WriteVerbose("Internal connection closed");
                }
            }
        }
    }
}
