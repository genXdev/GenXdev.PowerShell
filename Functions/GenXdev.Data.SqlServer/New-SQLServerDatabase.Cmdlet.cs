using Microsoft.Data.SqlClient;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Creates a new SQL Server database.

.DESCRIPTION
Creates a new SQL Server database with the specified name on the specified
server. Requires appropriate permissions to create databases on the target SQL
Server instance. If the database already exists, the operation is skipped.
Supports file-based database creation with explicit .mdf/.ldf paths.

A new database gets the same settings the deployment scripts use: compatibility
level 160, SIMPLE recovery, checksum page verification, simple parameterization,
a 60 second target recovery time, and the matching database scoped
configuration.

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
The name of the SQL Server database to create. Must be a valid SQL Server
database name.

.PARAMETER Server
The SQL Server instance name where the database should be created. Defaults to
'.' (local instance).

.PARAMETER ConnectionString
Retained for parameter-set compatibility. Creating a database requires a
database name, so this parameter set reports an error instead of connecting.

.PARAMETER DataFilePath
Optional path for the database data file (.mdf). When specified, creates a
file-based database at this location instead of using default SQL Server paths.

.PARAMETER LogFilePath
Optional path for the database log file (.ldf). If not specified but
DataFilePath is provided, defaults to same directory with _log.ldf suffix.

.PARAMETER DetachAfterCreation
Detach the database after creation. Typically used with DataFilePath to create
a portable database file that can be attached via connection string.

.EXAMPLE
```powershell
New-SQLServerDatabase -DatabaseName ""MyNewDatabase"" -Server ""localhost""
```

Creates MyNewDatabase on the local instance.

.EXAMPLE
```powershell
New-SQLServerDatabase -DatabaseName ""ImageIndex"" `
    -DataFilePath ""C:\Data\ImageIndex.mdf"" -DetachAfterCreation
```

Creates a portable file-based database and detaches it again.
")]
    [Cmdlet(
        verbName:"New",
        "SQLServerDatabase",
        SupportsShouldProcess = true,
        DefaultParameterSetName = "DatabaseName")]
    [Alias("nsqldb")]
    public partial class NewSqlServerDatabaseCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The name of the SQL Server database to create.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ParameterSetName = "DatabaseName",
            HelpMessage = "The name of the SQL Server database to create")]
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
        /// The connection string to connect to SQL Server.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ParameterSetName = "ConnectionString",
            HelpMessage = "The connection string to connect to SQL Server")]
        public string ConnectionString { get; set; }

        /// <summary>
        /// Optional data file path (.mdf) for file-based database creation.
        /// </summary>
        [Parameter(
            Mandatory = false,
            ParameterSetName = "DatabaseName",
            HelpMessage = "Optional data file path (.mdf) for file-based database creation.")]
        public string DataFilePath { get; set; }

        /// <summary>
        /// Optional log file path (.ldf) for file-based database creation.
        /// </summary>
        [Parameter(
            Mandatory = false,
            ParameterSetName = "DatabaseName",
            HelpMessage = "Optional log file path (.ldf) for file-based database creation.")]
        public string LogFilePath { get; set; }

        /// <summary>
        /// Detach database after creation (for file-based databases).
        /// </summary>
        [Parameter(
            Mandatory = false,
            ParameterSetName = "DatabaseName",
            HelpMessage = "Detach database after creation (for file-based databases).")]
        public SwitchParameter DetachAfterCreation { get; set; }

        /// <summary>
        /// Process record - creates the database when it does not exist yet.
        /// </summary>
        protected override void ProcessRecord()
        {
            if (ParameterSetName == "ConnectionString")
            {
                ThrowTerminatingError(new ErrorRecord(
                    new InvalidOperationException(
                        "A database name is required to create a database. " +
                        "Use -DatabaseName with -Server."),
                    "NewSQLServerDatabaseError",
                    ErrorCategory.InvalidArgument,
                    null));
            }

            string target = $"{DatabaseName} on {Server}";

            if (!ShouldProcess(target, "Create SQL Server database")) return;

            SqlConnection connection = null;

            try
            {
                connection = new SqlConnection(SqlServerConnectionString.Build(
                    this,
                    null,
                    Server,
                    "master"));

                connection.Open();

                if (DatabaseExists(connection))
                {
                    WriteVerbose("Database '" + DatabaseName +
                        "' already exists on server '" + Server + "'");

                    return;
                }

                ExecuteCommand(connection, BuildCreateQuery());

                WriteVerbose("Successfully created database '" + DatabaseName +
                    "' on server '" + Server + "'");

                ApplyDatabaseSettings(connection);

                WriteVerbose("Applied the standard database settings to '" +
                    DatabaseName + "'");

                if (DetachAfterCreation)
                {
                    ExecuteCommand(connection,
                        $"EXEC sp_detach_db @dbname = N'{DatabaseName}'");

                    WriteVerbose("Detached database '" + DatabaseName +
                        "' from server '" + Server + "'");
                }
            }
            catch (Exception exception)
            {
                ThrowTerminatingError(new ErrorRecord(
                    new InvalidOperationException(
                        $"Failed to create database. Error: {exception.Message}",
                        exception),
                    "NewSQLServerDatabaseError",
                    ErrorCategory.InvalidOperation,
                    DatabaseName));
            }
            finally
            {
                connection?.Close();
            }
        }
    }
}
