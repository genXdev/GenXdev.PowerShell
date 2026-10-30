using System.Collections;
using System.Data.SQLite;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{
    public partial class InvokeSqliteQueryCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Queries to execute, in the exact order they were provided.
        /// </summary>
        private readonly List<string> queries = new();

        /// <summary>
        /// Creates the error record a failure is reported with.
        /// </summary>
        /// <param name="Message">The failure message.</param>
        /// <param name="TargetObject">The object the failure is about.</param>
        /// <returns>The error record.</returns>
        private static ErrorRecord NewFailure(string Message, object TargetObject)
        {
            return new ErrorRecord(
                new InvalidOperationException(Message),
                "InvokeSQLiteQueryError",
                ErrorCategory.InvalidOperation,
                TargetObject);
        }

        /// <summary>
        /// Executes every query and reports every row it returns.
        /// </summary>
        /// <param name="Connection">The connection to execute on.</param>
        /// <param name="Transaction">The transaction to enlist commands in.</param>
        private void ExecuteQueries(SQLiteConnection Connection,
            SQLiteTransaction Transaction)
        {
            for (int index = 0; index < queries.Count; index++)
            {
                WriteVerbose($"Executing query {index + 1} of {queries.Count}");

                using SQLiteCommand command =
                    (SQLiteCommand)Connection.CreateCommand();
                command.CommandText = queries[index];
                command.Transaction = Transaction;
                command.CommandTimeout = TimeoutSeconds;

                // the n-th parameter set belongs to the n-th query
                Hashtable data = SqlParameters != null &&
                    index < SqlParameters.Length ?
                    SqlParameters[index] :
                    null;

                if (data != null)
                {
                    foreach (DictionaryEntry entry in data)
                    {
                        command.Parameters.AddWithValue(
                            "@" + entry.Key,
                            entry.Value);
                    }
                }

                using SQLiteDataReader reader =
                    (SQLiteDataReader)command.ExecuteReader();

                while (reader.Read())
                {
                    Hashtable record = new(reader.FieldCount);

                    for (int column = 0; column < reader.FieldCount; column++)
                    {
                        record[reader.GetName(column)] = reader.GetValue(column);
                    }

                    WriteObject(record);
                }
            }
        }
    }
}
