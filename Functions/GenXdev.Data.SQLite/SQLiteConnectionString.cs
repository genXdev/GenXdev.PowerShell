namespace GenXdev.Data.SQLite
{
    /// <summary>
    /// Builds the connection string the SQLite cmdlets connect with.
    /// </summary>
    internal static class SQLiteConnectionString
    {
        /// <summary>
        /// Returns the caller's connection string when one is given, otherwise
        /// a connection string for DatabaseFilePath.
        /// </summary>
        /// <param name="ConnectionString">The caller's connection string.</param>
        /// <param name="DatabaseFilePath">The expanded database file path.</param>
        /// <returns>The connection string to connect with.</returns>
        internal static string Build(string ConnectionString,
            string DatabaseFilePath)
        {
            return string.IsNullOrWhiteSpace(ConnectionString) ?
                $"Data Source={DatabaseFilePath}" :
                ConnectionString;
        }
    }
}
