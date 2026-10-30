using Microsoft.Data.SqlClient;
using System.Management.Automation;
using System.Text;
using System.Text.RegularExpressions;

namespace GenXdev.Data.SqlServer
{
    public partial class NewSqlServerDatabaseCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The database settings the deployment scripts create their databases
        /// with, applied once to a database this command just created.
        /// </summary>
        private static readonly string[] DatabaseSettings = {
            "SET COMPATIBILITY_LEVEL = 160",
            "SET ANSI_NULL_DEFAULT OFF",
            "SET ANSI_NULLS OFF",
            "SET ANSI_PADDING OFF",
            "SET ANSI_WARNINGS OFF",
            "SET ARITHABORT OFF",
            "SET AUTO_CLOSE OFF",
            "SET AUTO_SHRINK ON",
            "SET AUTO_CREATE_STATISTICS ON(INCREMENTAL = OFF)",
            "SET AUTO_UPDATE_STATISTICS ON",
            "SET CURSOR_CLOSE_ON_COMMIT OFF",
            "SET CURSOR_DEFAULT GLOBAL",
            "SET CONCAT_NULL_YIELDS_NULL OFF",
            "SET NUMERIC_ROUNDABORT OFF",
            "SET QUOTED_IDENTIFIER OFF",
            "SET RECURSIVE_TRIGGERS OFF",
            "SET DISABLE_BROKER",
            "SET AUTO_UPDATE_STATISTICS_ASYNC OFF",
            "SET DATE_CORRELATION_OPTIMIZATION OFF",
            "SET PARAMETERIZATION SIMPLE",
            "SET READ_COMMITTED_SNAPSHOT OFF",
            "SET READ_WRITE",
            "SET RECOVERY SIMPLE",
            "SET MULTI_USER",
            "SET PAGE_VERIFY CHECKSUM",
            "SET TARGET_RECOVERY_TIME = 60 SECONDS",
            "SET DELAYED_DURABILITY = DISABLED"
        };

        /// <summary>
        /// The database scoped configuration the deployment scripts create
        /// their databases with. Applies to the current database.
        /// </summary>
        private static readonly string[] ScopedConfigurationSettings = {
            "SET LEGACY_CARDINALITY_ESTIMATION = Off",
            "FOR SECONDARY SET LEGACY_CARDINALITY_ESTIMATION = Primary",
            "SET MAXDOP = 0",
            "FOR SECONDARY SET MAXDOP = PRIMARY",
            "SET PARAMETER_SNIFFING = On",
            "FOR SECONDARY SET PARAMETER_SNIFFING = Primary",
            "SET QUERY_OPTIMIZER_HOTFIXES = Off",
            "FOR SECONDARY SET QUERY_OPTIMIZER_HOTFIXES = Primary"
        };

        /// <summary>
        /// Executes one statement that returns no result set.
        /// </summary>
        /// <param name="Connection">The connection to execute on.</param>
        /// <param name="CommandText">The statement to execute.</param>
        private static void ExecuteCommand(SqlConnection Connection,
            string CommandText)
        {
            using SqlCommand command = Connection.CreateCommand();
            command.CommandText = CommandText;
            command.ExecuteNonQuery();
        }

        /// <summary>
        /// Tests whether the database already exists on the server.
        /// </summary>
        /// <param name="Connection">The master database connection.</param>
        /// <returns>True when the database exists.</returns>
        private bool DatabaseExists(SqlConnection Connection)
        {
            using SqlCommand command = Connection.CreateCommand();
            command.CommandText =
                "SELECT database_id FROM sys.databases WHERE name = @DatabaseName";
            command.Parameters.AddWithValue("@DatabaseName", DatabaseName);

            return command.ExecuteScalar() != null;
        }

        /// <summary>
        /// Applies the standard deployment database settings to the database
        /// this command created.
        /// </summary>
        /// <param name="Connection">The master database connection.</param>
        private void ApplyDatabaseSettings(SqlConnection Connection)
        {
            StringBuilder settings = new();

            foreach (string setting in DatabaseSettings)
            {
                settings.AppendLine($"ALTER DATABASE [{DatabaseName}] {setting};");
            }

            settings.AppendLine(
                $"ALTER DATABASE [{DatabaseName}] MODIFY FILEGROUP [PRIMARY] DEFAULT;");

            ExecuteCommand(Connection, settings.ToString());

            // database scoped configuration applies to the current database
            StringBuilder scopedConfiguration = new();

            foreach (string setting in ScopedConfigurationSettings)
            {
                scopedConfiguration.AppendLine(
                    $"ALTER DATABASE SCOPED CONFIGURATION {setting};");
            }

            Connection.ChangeDatabase(DatabaseName);

            try
            {
                ExecuteCommand(Connection, scopedConfiguration.ToString());
            }
            finally
            {
                Connection.ChangeDatabase("master");
            }
        }

        /// <summary>
        /// Builds the CREATE DATABASE statement, with explicit file locations
        /// when DataFilePath is provided.
        /// </summary>
        /// <returns>The CREATE DATABASE statement.</returns>
        private string BuildCreateQuery()
        {
            if (string.IsNullOrWhiteSpace(DataFilePath))
            {
                return $"CREATE DATABASE [{DatabaseName}]";
            }

            string fileBaseName = DatabaseName.Replace('-', '_').Replace(' ', '_');

            string logPath = string.IsNullOrWhiteSpace(LogFilePath) ?
                Regex.Replace(DataFilePath, "\\.mdf$", "_log.ldf",
                    RegexOptions.IgnoreCase) :
                LogFilePath;

            // the server cannot create the files in a missing directory
            string dataDirectory = System.IO.Path.GetDirectoryName(DataFilePath);
            if (!string.IsNullOrEmpty(dataDirectory))
            {
                Directory.CreateDirectory(dataDirectory);
            }

            string logDirectory = System.IO.Path.GetDirectoryName(logPath);
            if (!string.IsNullOrEmpty(logDirectory))
            {
                Directory.CreateDirectory(logDirectory);
            }

            return $@"CREATE DATABASE [{DatabaseName}]
ON PRIMARY (
    NAME = N'{fileBaseName}',
    FILENAME = N'{DataFilePath}',
    SIZE = 8MB,
    FILEGROWTH = 64MB
)
LOG ON (
    NAME = N'{fileBaseName}_log',
    FILENAME = N'{logPath}',
    SIZE = 8MB,
    FILEGROWTH = 64MB
)";
        }
    }
}
