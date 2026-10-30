using System.Data.SQLite;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Creates a new SQLite database file.

.DESCRIPTION
Creates a new SQLite database file at the specified path if it does not already
exist. The command ensures the target directory exists and creates a valid
SQLite database by establishing and closing a connection.

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
The full path where the SQLite database file should be created. If the directory
path does not exist, it will be created automatically.

.EXAMPLE
```powershell
New-SQLiteDatabase -DatabaseFilePath ""C:\Databases\MyNewDb.sqlite""
```

Creates a new empty database file, and its directory when needed.
")]
    [Cmdlet(verbName:"New", "SQLiteDatabase", SupportsShouldProcess = true)]
    [Alias("nsqldb")]
    public class NewSqliteDatabaseCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The path to the SQLite database file.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The path to the SQLite database file")]
        public string DatabaseFilePath { get; set; }

        /// <summary>
        /// The expanded database file path.
        /// </summary>
        private string expandedPath;

        /// <summary>
        /// Begin processing - resolves the path and creates its directory.
        /// </summary>
        protected override void BeginProcessing()
        {
            expandedPath = ExpandPath(DatabaseFilePath, CreateDirectory: true);
        }

        /// <summary>
        /// Process record - creates the database file when it is missing.
        /// </summary>
        protected override void ProcessRecord()
        {
            if (File.Exists(expandedPath))
            {
                WriteVerbose("Database file already exists at " + expandedPath);
                return;
            }

            if (!ShouldProcess(expandedPath, "Create SQLite database")) return;

            try
            {
                using SQLiteConnection connection = new(
                    SQLiteConnectionString.Build(null, expandedPath));

                connection.Open();

                WriteVerbose("Successfully created database at " + expandedPath);
            }
            catch (Exception exception)
            {
                ThrowTerminatingError(new ErrorRecord(
                    new InvalidOperationException(
                        $"Failed to create database at {expandedPath}. " +
                        $"Error: {exception.Message}",
                        exception),
                    "NewSQLiteDatabaseError",
                    ErrorCategory.InvalidOperation,
                    expandedPath));
            }
        }
    }
}
