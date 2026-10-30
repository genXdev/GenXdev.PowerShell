using System.Data.SQLite;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Creates and returns a SQLite transaction object for batch operations.

.DESCRIPTION
Creates a SQLite database connection and transaction object that can be used
for batch operations. The caller is responsible for committing or rolling back
the transaction. The connection is returned inside the transaction, so the
caller owns it and must close it.

When DatabaseFilePath is used, the database file is created unless
CreateDatabaseIfNotExists is false.
Connection priority: Connection > ConnectionString > DatabaseFilePath.

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
An existing open SQLiteConnection to begin the transaction on, as returned by
Get-SQLiteConnection. The caller owns the connection, so it is neither opened
nor closed here.

.PARAMETER ConnectionString
The SQLite connection string for database access.

.PARAMETER DatabaseFilePath
The file path to the SQLite database. Will be converted to a connection string.

.PARAMETER IsolationLevel
Transaction isolation level. Defaults to ReadCommitted.

.PARAMETER CreateDatabaseIfNotExists
Whether to create the database file if it does not exist. Defaults to true.

.EXAMPLE
```powershell
$transaction = Get-SQLiteTransaction -DatabaseFilePath ""C:\data.db""
try {
    Invoke-SQLiteQuery -Transaction $transaction `
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

.EXAMPLE
```powershell
Get-SQLiteTransaction -ConnectionString ""Data Source=C:\data.db""
```

Starts a transaction on an existing database file.
")]
    [Cmdlet(verbName:"Get", "SQLiteTransaction", DefaultParameterSetName = "DatabaseFilePath")]
    [OutputType(typeof(SQLiteTransaction))]
    [Alias("getsqltx", "newsqltx")]
    public partial class GetSqliteTransactionCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// An existing open SQLiteConnection to begin the transaction on.
        /// </summary>
        [Parameter(
            Mandatory = true,
            ParameterSetName = "Connection",
            HelpMessage = "An existing open SQLiteConnection to begin the transaction on.")]
        public SQLiteConnection Connection { get; set; }

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
        /// The isolation level the transaction is started with.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Transaction isolation level.")]
        [ValidateSet("ReadCommitted", "ReadUncommitted", "RepeatableRead",
            "Serializable", "Snapshot", "Chaos")]
        public string IsolationLevel { get; set; } = "ReadCommitted";

        /// <summary>
        /// Whether to create the database file if it does not exist.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Whether to create the database file if it does not exist.")]
        public bool CreateDatabaseIfNotExists { get; set; } = true;

        /// <summary>
        /// Process record - starts the transaction and hands it to the caller.
        /// </summary>
        protected override void ProcessRecord()
        {
            // only a connection opened here is closed here on failure
            bool ownsConnection = ParameterSetName != "Connection";

            string connectionString = ownsConnection ?
                ResolveConnectionString() :
                null;

            WriteVerbose(ownsConnection ?
                $"Creating SQLite transaction with connection string: {connectionString}" :
                "Starting a transaction on the provided connection");

            SQLiteConnection connection = null;

            try
            {
                connection = ownsConnection ?
                    new SQLiteConnection(connectionString) :
                    Connection;

                if (ownsConnection)
                {
                    connection.Open();

                    WriteVerbose("SQLite connection opened successfully");
                }

                SQLiteTransaction transaction =
                    (SQLiteTransaction)connection.BeginTransaction(
                        Enum.Parse<System.Data.IsolationLevel>(IsolationLevel, true));

                WriteVerbose($"Transaction started with {IsolationLevel} " +
                    "isolation level");

                WriteObject(transaction);
            }
            catch
            {
                if (ownsConnection &&
                    connection?.State == System.Data.ConnectionState.Open)
                {
                    connection.Close();
                }

                throw;
            }
        }
    }
}
