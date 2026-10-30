using System.Management.Automation;

namespace GenXdev.Data.SQLite
{
    public partial class GetSqliteTransactionCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Resolves the connection string from the selected parameter set.
        /// </summary>
        /// <returns>The connection string to connect with.</returns>
        private string ResolveConnectionString()
        {
            if (ParameterSetName != "DatabaseFilePath")
            {
                return ConnectionString;
            }

            string expandedPath = ExpandPath(DatabaseFilePath);

            if (!CreateDatabaseIfNotExists && !File.Exists(expandedPath))
            {
                ThrowTerminatingError(new ErrorRecord(
                    new FileNotFoundException(
                        $"Database file '{expandedPath}' does not exist.",
                        expandedPath),
                    "GetSQLiteTransactionError",
                    ErrorCategory.ObjectNotFound,
                    expandedPath));
            }

            WriteVerbose($"Using database file: {expandedPath}");

            return SQLiteConnectionString.Build(null, expandedPath);
        }
    }
}
