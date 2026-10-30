using Microsoft.Data.SqlClient;
using System.Collections;
using System.Management.Automation;

namespace GenXdev.Data.SqlServer
{
    public partial class InvokeSqlServerQueryCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Queries to execute, in the exact order they were provided.
        /// </summary>
        private readonly List<string> queries = new();

        /// <summary>
        /// Executes every query and reports every row it returns.
        /// </summary>
        /// <param name="Connection">The connection to execute on.</param>
        /// <param name="Transaction">The transaction to enlist commands in.</param>
        private void ExecuteQueries(SqlConnection Connection,
            SqlTransaction Transaction)
        {
            for (int index = 0; index < queries.Count; index++)
            {
                WriteVerbose($"Executing query {index + 1} of {queries.Count}");

                using SqlCommand command = Connection.CreateCommand();
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
                            entry.Value ?? DBNull.Value);
                    }
                }

                using SqlDataReader reader = command.ExecuteReader();

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
