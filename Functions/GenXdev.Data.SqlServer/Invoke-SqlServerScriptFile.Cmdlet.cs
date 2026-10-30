using Microsoft.Data.SqlClient;
using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Executes SQL script files against a SQL Server database, batch by batch.

.DESCRIPTION
Reads one or more SQL script files and executes them in order, splitting every
file into batches on the GO batch separator, the same way SQL Server Management
Studio does. A GO line always terminates the current batch, and repeats it with
an optional repeat count, as in 'GO 5'.

Every batch of a file is executed on one shared connection, so session state
survives a GO exactly as it does in SQL Server Management Studio: USE, temp
tables and SET options stay in effect for the rest of the file. Batches run in
autocommit mode, unless a Transaction is provided by the caller.

Failures are reported through the effective error action: an explicitly bound
-ErrorAction wins, otherwise $ErrorActionPreference decides. When the effective
action is not Stop, the failing batch is reported and the next batch is
executed.

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

.PARAMETER Name
One or more SQL script files to execute, in the order given. Relative paths are
resolved against the current directory, and a search mask such as *.sql is
expanded against the file system.

.PARAMETER InputObject
SQL script files accepted from the pipeline, as file names or as FileInfo
objects. This parameter set is mutually exclusive with Name.

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
An existing open SqlConnection to execute every batch on. The caller owns the
connection, so it is never closed here. Takes priority over ConnectionString and
DatabaseName/Server.

.PARAMETER ConnectionString
The SQL Server connection string for database access. Used if no Transaction or
Connection is provided.

.PARAMETER SqlParameters
Optional parameters for the queries as hashtables. Format: @{""param""=""value""}
Every batch is executed as its own query, so the first parameter set applies to
every batch.

.PARAMETER TimeoutSeconds
Command timeout in seconds for every batch. Default is 3600, 0 waits
indefinitely.

.PARAMETER ParentProgressId
The activity identifier of the caller's parent progress record. The command
writes one progress record per script file with this identifier as its parent,
and a completed child record for every batch, so a build system can show nested
progress.

.EXAMPLE
```powershell
Invoke-SQLServerScriptFile -Name '.\deploy.sql' -Server 'localhost' `
    -DatabaseName 'MyDB'
```

Executes every batch of deploy.sql against MyDB on localhost.

.EXAMPLE
```powershell
Get-ChildItem -Path '.\migrations' -Filter '*.sql' |
    Invoke-SQLServerScriptFile -DatabaseName 'MyDB' -ErrorAction Continue
```

Executes every migration script in name order, reporting failures and
continuing with the next batch.
")]
    [Cmdlet(verbName:"Invoke", "SQLServerScriptFile", DefaultParameterSetName = "ByName")]
    [OutputType(typeof(Hashtable))]
    public partial class InvokeSqlServerScriptFileCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// One or more SQL script files to execute, in the order given.
        /// </summary>
        [Parameter(
            ParameterSetName = "ByName",
            Position = 0,
            Mandatory = false,
            HelpMessage = "One or more SQL script files to execute")]
        [Alias("like", "Path", "LiteralPath", "SearchMask", "Include")]
        [ValidateNotNullOrEmpty]
        [SupportsWildcards]
        public string[] Name { get; set; }

        /// <summary>
        /// SQL script files accepted from the pipeline, as file names or as
        /// FileInfo objects.
        /// </summary>
        [Parameter(
            ParameterSetName = "ByPipeline",
            Mandatory = false,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "SQL script files to execute, as names or FileInfo objects")]
        [Alias("FullName", "Input")]
        [SupportsWildcards]
        public object InputObject { get; set; }

        /// <summary>
        /// The name of the SQL Server database to connect to.
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = false,
            HelpMessage = "The name of the SQL Server database.")]
        [ValidateNotNullOrEmpty]
        public string DatabaseName { get; set; } = "tempDb";

        /// <summary>
        /// The SQL Server instance name.
        /// </summary>
        [Parameter(
            Position = 2,
            Mandatory = false,
            HelpMessage = "The SQL Server instance name.")]
        public string Server { get; set; } = ".";

        /// <summary>
        /// An existing SQL Server transaction to use for the batches.
        /// </summary>
        [Parameter(
            Position = 3,
            Mandatory = false,
            HelpMessage = "An existing SQL Server transaction to use for the batches.")]
        public SqlTransaction Transaction { get; set; }

        /// <summary>
        /// An existing open SqlConnection to execute every batch on.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "An existing open SqlConnection to execute all batches on.")]
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
        /// Query parameters as hashtables. The first parameter set applies to
        /// every batch.
        /// </summary>
        [Parameter(
            Position = 5,
            Mandatory = false,
            HelpMessage = "Query parameters as hashtables.")]
        [Alias("data", "parameters", "args")]
        public Hashtable[] SqlParameters { get; set; }

        /// <summary>
        /// Command timeout in seconds for every batch.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Command timeout in seconds for every query. Default is 30, 0 waits indefinitely.")]
        [Alias("timeout", "maxseconds")]
        [ValidateRange(0, int.MaxValue)]
        public int TimeoutSeconds { get; set; } = 3600;

        /// <summary>
        /// The activity identifier of the caller's parent progress record.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "The activity identifier of the parent progress record.")]
        [ValidateRange(-1, int.MaxValue)]
        public int ParentProgressId { get; set; } = -1;

        /// <summary>
        /// Begin processing - resolves the script files given by name.
        /// </summary>
        protected override void BeginProcessing()
        {
            if (Name == null) return;

            receivedInput = true;

            foreach (string nameValue in Name)
            {
                AddScriptFilePaths(nameValue);
            }
        }

        /// <summary>
        /// Process record - collects the script files piped in.
        /// </summary>
        protected override void ProcessRecord()
        {
            if (InputObject == null) return;

            receivedInput = true;

            AddScriptFilePaths(InputObject);
        }

        /// <summary>
        /// End processing - executes every collected script file in order.
        /// </summary>
        protected override void EndProcessing()
        {
            if (scriptFilePaths.Count == 0)
            {
                if (!receivedInput)
                {
                    WriteFailure(
                        "No script files were provided. Pass -Name or pipe " +
                        "file names or FileInfo objects.",
                        null);
                }

                return;
            }

            // one connection for every batch, unless the caller brought one
            SqlConnection ownedConnection = null;
            SqlConnection connection = null;
            SqlTransaction transaction = null;

            try
            {
                if (Transaction != null)
                {
                    transaction = Transaction;
                    connection = Transaction.Connection;
                }
                else if (Connection != null)
                {
                    connection = Connection;
                }
                else
                {
                    try
                    {
                        ownedConnection = OpenConnection();
                        connection = ownedConnection;
                    }
                    catch (Exception exception)
                    {
                        WriteFailure(
                            "Cannot open the SQL Server connection: " +
                            exception.Message,
                            null,
                            exception);

                        return;
                    }
                }

                if (connection == null)
                {
                    WriteFailure(
                        "The provided transaction no longer has a connection.",
                        null);

                    return;
                }

                // forward informational messages, such as PRINT output
                SqlInfoMessageEventHandler infoMessageHandler = (sender, arguments) =>
                    WriteInformation(arguments.Message, []);

                connection.InfoMessage += infoMessageHandler;

                try
                {
                    using (SqlCommand command = PrepareCommand(connection, transaction))
                    {
                        foreach (string scriptFilePath in scriptFilePaths)
                        {
                            InvokeScriptFile(scriptFilePath, command);
                        }
                    }
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
