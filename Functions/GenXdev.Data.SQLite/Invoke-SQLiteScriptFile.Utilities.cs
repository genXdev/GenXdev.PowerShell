using System.Collections;
using System.Data.SQLite;
using System.Management.Automation;

namespace GenXdev.Data.SQLite
{
    public partial class InvokeSqliteScriptFileCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Script files to execute, in the exact order they were provided.
        /// </summary>
        private readonly List<string> scriptFilePaths = new();

        /// <summary>
        /// Whether the caller provided any input at all.
        /// </summary>
        private bool receivedInput = false;

        /// <summary>
        /// Reports a failure through the effective error action policy.
        /// </summary>
        /// <param name="Message">The failure message.</param>
        /// <param name="TargetObject">The object the failure is about.</param>
        /// <param name="InnerException">The exception that caused the failure.</param>
        private void WriteFailure(string Message, object TargetObject,
            Exception InnerException = null)
        {
            Exception exception = InnerException == null ?
                new InvalidOperationException(Message) :
                new InvalidOperationException(Message, InnerException);

            WriteError(new ErrorRecord(
                exception,
                "InvokeSQLiteScriptFileError",
                ErrorCategory.InvalidOperation,
                TargetObject));
        }

        /// <summary>
        /// Creates the command every batch is executed with, including the
        /// parameters that apply to every batch.
        /// </summary>
        /// <param name="Connection">The connection to create the command on.</param>
        /// <param name="Transaction">The transaction to enlist the command in.</param>
        /// <returns>The prepared SQLiteCommand.</returns>
        private SQLiteCommand PrepareCommand(SQLiteConnection Connection,
            SQLiteTransaction Transaction)
        {
            SQLiteCommand command = (SQLiteCommand)Connection.CreateCommand();
            command.Transaction = Transaction;
            command.CommandTimeout = TimeoutSeconds;

            // the first parameter set applies to every batch
            Hashtable data = SqlParameters != null && SqlParameters.Length > 0 ?
                SqlParameters[0] :
                null;

            if (data == null) return command;

            foreach (DictionaryEntry entry in data)
            {
                command.Parameters.AddWithValue(
                    "@" + entry.Key,
                    entry.Value);
            }

            return command;
        }

        /// <summary>
        /// Appends the script file a single input value refers to.
        /// </summary>
        /// <param name="Value">A file name, FileInfo object or wildcard mask.</param>
        private void AddScriptFilePaths(object Value)
        {
            if (Value == null) return;

            if (Value is PSObject psObject) Value = psObject.BaseObject;

            if (Value is FileInfo fileInfo)
            {
                if (!File.Exists(fileInfo.FullName))
                {
                    WriteFailure(
                        $"Cannot find script file '{fileInfo.FullName}'.",
                        Value);

                    return;
                }

                scriptFilePaths.Add(fileInfo.FullName);
                return;
            }

            if (Value is not string text)
            {
                WriteFailure("Script file input must be a file name or " +
                    $"a FileInfo object, not {Value.GetType().FullName}.", Value);

                return;
            }

            if (string.IsNullOrWhiteSpace(text)) return;

            string resolvedPath = ExpandPath(text);

            // expand a search mask against the file system
            if (resolvedPath.IndexOfAny(WildcardChars) >= 0)
            {
                if (!AddWildcardMatches(resolvedPath))
                {
                    WriteFailure($"No script files match '{text}'.", text);
                }

                return;
            }

            if (File.Exists(resolvedPath))
            {
                scriptFilePaths.Add(resolvedPath);
                return;
            }

            if (Directory.Exists(resolvedPath))
            {
                WriteFailure($"Cannot execute '{text}': it is a directory, " +
                    "not a script file.", text);

                return;
            }

            WriteFailure($"Cannot find script file '{text}'.", text);
        }

        /// <summary>
        /// Wildcard characters that turn an input into a search mask.
        /// </summary>
        private static readonly char[] WildcardChars = ['*', '?'];

        /// <summary>
        /// Expands a full path that contains wildcards to the files it matches.
        /// </summary>
        /// <param name="FullPath">The full path, with optional wildcards.</param>
        /// <returns>True when at least one file matched.</returns>
        private bool AddWildcardMatches(string FullPath)
        {
            int firstWildcard = FullPath.IndexOfAny(WildcardChars);
            int lastSeparator = FullPath.LastIndexOf('\\', firstWildcard);

            string baseDirectory = lastSeparator < 0 ?
                SessionState.Path.CurrentLocation.ProviderPath :
                FullPath.Substring(0, lastSeparator + 1);

            string mask = lastSeparator < 0 ?
                FullPath :
                FullPath.Substring(lastSeparator + 1);

            List<string> directories = new() { baseDirectory };
            List<string> matchedFiles = new();

            string[] segments = mask.Split(
                '\\',
                StringSplitOptions.RemoveEmptyEntries);

            for (int segmentIndex = 0;
                segmentIndex < segments.Length && directories.Count > 0;
                segmentIndex++)
            {
                bool isLastSegment = segmentIndex == segments.Length - 1;

                WildcardPattern wildcard = new(
                    segments[segmentIndex],
                    WildcardOptions.IgnoreCase | WildcardOptions.CultureInvariant);

                List<string> nextDirectories = new();

                foreach (string directory in directories)
                {
                    try
                    {
                        if (isLastSegment)
                        {
                            foreach (string file in
                                Directory.EnumerateFiles(directory))
                            {
                                if (wildcard.IsMatch(System.IO.Path.GetFileName(file)))
                                {
                                    matchedFiles.Add(file);
                                }
                            }
                        }
                        else
                        {
                            foreach (string child in
                                Directory.EnumerateDirectories(directory))
                            {
                                if (wildcard.IsMatch(
                                    System.IO.Path.GetFileName(child)))
                                {
                                    nextDirectories.Add(child);
                                }
                            }
                        }
                    }
                    catch (Exception exception) when (
                        exception is IOException or UnauthorizedAccessException)
                    {
                    }
                }

                directories = nextDirectories;
            }

            matchedFiles.Sort((left, right) => StringComparer.CurrentCultureIgnoreCase.Compare(
                System.IO.Path.GetFileName(left),
                System.IO.Path.GetFileName(right)));

            foreach (string matchedFile in matchedFiles)
            {
                scriptFilePaths.Add(matchedFile);
            }

            return matchedFiles.Count > 0;
        }

        /// <summary>
        /// Executes every batch of one script file in order, reporting one
        /// progress record for the file and a child record for every batch.
        /// </summary>
        /// <param name="ScriptFilePath">The script file to execute.</param>
        /// <param name="Command">The command every batch is executed with.</param>
        private void InvokeScriptFile(string ScriptFilePath, SQLiteCommand Command)
        {
            int totalSections;

            try
            {
                totalSections =
                    SqlScriptBatchReader.CountBatches(ScriptFilePath);
            }
            catch (SqlScriptBatchReader.InvalidRepeatCountException exception)
            {
                ThrowTerminatingError(new ErrorRecord(
                    exception,
                    "InvokeSQLiteScriptFileError",
                    ErrorCategory.InvalidOperation,
                    ScriptFilePath));

                return;
            }
            catch (Exception exception)
                when (exception is IOException or UnauthorizedAccessException)
            {
                WriteFailure(
                    $"Cannot read script file '{ScriptFilePath}': " +
                    exception.Message,
                    ScriptFilePath,
                    exception);

                return;
            }

            ScriptFileProgress progress = totalSections > 0 ?
                new ScriptFileProgress(
                    ScriptFilePath,
                    totalSections,
                    ParentProgressId) :
                null;

            if (progress != null) WriteProgress(progress.StartFile());

            int batchNumber = 0;

            try
            {
                foreach (SqlScriptBatchReader.Batch batch in
                    SqlScriptBatchReader.ReadBatches(ScriptFilePath))
                {
                    for (int repeat = 0; repeat < batch.RepeatCount; repeat++)
                    {
                        batchNumber++;

                        if (progress != null)
                        {
                            WriteProgress(progress.StartSection(batchNumber));
                        }

                        try
                        {
                            ExecuteBatch(
                                Command,
                                ScriptFilePath,
                                batchNumber,
                                batch.Text);
                        }
                        finally
                        {
                            if (progress != null)
                            {
                                WriteProgress(
                                    progress.CompleteSection(batchNumber));

                                WriteProgress(progress.UpdateFile());
                            }
                        }
                    }
                }
            }
            catch (SqlScriptBatchReader.InvalidRepeatCountException exception)
            {
                ThrowTerminatingError(new ErrorRecord(
                    exception,
                    "InvokeSQLiteScriptFileError",
                    ErrorCategory.InvalidOperation,
                    ScriptFilePath));
            }
            catch (Exception exception)
                when (exception is IOException or UnauthorizedAccessException)
            {
                WriteFailure(
                    $"Cannot read script file '{ScriptFilePath}': " +
                    exception.Message,
                    ScriptFilePath,
                    exception);
            }
            finally
            {
                if (progress != null) WriteProgress(progress.CompleteFile());
            }
        }

        /// <summary>
        /// Executes one batch and reports every row it returns.
        /// </summary>
        /// <param name="Command">The command to execute with.</param>
        /// <param name="ScriptFilePath">The script file the batch came from.</param>
        /// <param name="BatchNumber">The batch number within the file.</param>
        /// <param name="BatchText">The batch text.</param>
        private void ExecuteBatch(SQLiteCommand Command, string ScriptFilePath,
            int BatchNumber, string BatchText)
        {
            WriteVerbose($"Executing {ScriptFilePath} batch {BatchNumber}");

            Command.CommandText = BatchText;

            try
            {
                using SQLiteDataReader reader =
                    (SQLiteDataReader)Command.ExecuteReader();

                while (reader.Read())
                {
                    Hashtable record = new(reader.FieldCount);

                    for (int index = 0; index < reader.FieldCount; index++)
                    {
                        record[reader.GetName(index)] = reader.GetValue(index);
                    }

                    WriteObject(record);
                }
            }
            catch (Exception exception)
            {
                WriteFailure(
                    $"Script file '{ScriptFilePath}' batch {BatchNumber} " +
                    $"failed: {exception.Message}",
                    ScriptFilePath,
                    exception);
            }
        }
    }
}
