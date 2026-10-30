using Microsoft.Data.SqlClient;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{
    /// <summary>
    /// Builds the connection string the SQL Server cmdlets connect with.
    /// </summary>
    internal static class SqlServerConnectionString
    {
        /// <summary>
        /// The parameter whose value replaces the database of a caller's
        /// connection string.
        /// </summary>
        private const string DatabaseNameParameter = "DatabaseName";

        /// <summary>
        /// Returns a trusted local connection string for Server and
        /// DatabaseName when the caller gave no connection string, otherwise
        /// the caller's own connection string with its database replaced when
        /// DatabaseName was explicitly provided.
        /// </summary>
        /// <param name="Command">The command the parameters were bound to.</param>
        /// <param name="ConnectionString">The caller's connection string.</param>
        /// <param name="Server">The SQL Server instance name.</param>
        /// <param name="DatabaseName">The name of the SQL Server database.</param>
        /// <returns>The connection string to connect with.</returns>
        internal static string Build(PSCmdlet Command, string ConnectionString,
            string Server, string DatabaseName)
        {
            if (string.IsNullOrWhiteSpace(ConnectionString))
            {
                return $"Server={Server};Database={DatabaseName};" +
                    "Integrated Security=true;TrustServerCertificate=true";
            }

            if (!Command.MyInvocation.BoundParameters.ContainsKey(
                DatabaseNameParameter))
            {
                return ConnectionString;
            }

            SqlConnectionStringBuilder builder = new(ConnectionString)
            {
                InitialCatalog = DatabaseName
            };

            return builder.ConnectionString;
        }
    }
}
