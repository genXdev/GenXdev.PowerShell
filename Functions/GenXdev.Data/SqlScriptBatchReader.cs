using System.Text;

namespace GenXdev.Data
{
    /// <summary>
    /// Splits a SQL script file into batches on the GO batch separator, the
    /// same way SQL Server Management Studio does.
    /// </summary>
    internal static class SqlScriptBatchReader
    {
        /// <summary>
        /// Read buffer size for script files.
        /// </summary>
        private const int ScriptFileBufferSize = 65536;

        /// <summary>
        /// One batch of a script file and the number of times it runs.
        /// </summary>
        internal readonly struct Batch
        {
            /// <summary>
            /// Creates a batch.
            /// </summary>
            /// <param name="Text">The batch text.</param>
            /// <param name="RepeatCount">The number of times to repeat it.</param>
            internal Batch(string Text, int RepeatCount)
            {
                this.Text = Text;
                this.RepeatCount = RepeatCount;
            }

            /// <summary>
            /// The batch text.
            /// </summary>
            internal string Text { get; }

            /// <summary>
            /// The number of times the batch runs.
            /// </summary>
            internal int RepeatCount { get; }
        }

        /// <summary>
        /// A GO line repeats a batch a number of times that does not fit in an
        /// integer.
        /// </summary>
        internal sealed class InvalidRepeatCountException : InvalidOperationException
        {
            /// <summary>
            /// Creates the exception for a script file.
            /// </summary>
            /// <param name="ScriptFilePath">The script file the line came from.</param>
            internal InvalidRepeatCountException(string ScriptFilePath) :
                base($"Script file '{ScriptFilePath}' has a GO repeat count " +
                    "that is too large.")
            {
            }
        }

        /// <summary>
        /// Reads every batch of a script file in order, skipping batches that
        /// hold nothing but whitespace.
        /// </summary>
        /// <param name="ScriptFilePath">The script file to read.</param>
        /// <returns>The batches of the file, in order.</returns>
        internal static IEnumerable<Batch> ReadBatches(string ScriptFilePath)
        {
            using StreamReader reader = new(
                ScriptFilePath,
                Encoding.UTF8,
                true,
                ScriptFileBufferSize);

            StringBuilder text = new(65536);
            bool hasLine = false;
            string line;

            while ((line = reader.ReadLine()) != null)
            {
                if (!TryParseBatchSeparator(line, ScriptFilePath,
                    out int repeatCount))
                {
                    if (hasLine) text.Append(Environment.NewLine);

                    text.Append(line);
                    hasLine = true;
                    continue;
                }

                if (!hasLine) continue;

                string batchText = text.ToString();

                text.Clear();
                hasLine = false;

                if (!string.IsNullOrWhiteSpace(batchText))
                {
                    yield return new Batch(batchText, repeatCount);
                }
            }

            // a trailing flush terminates a batch the file left open
            if (!hasLine) yield break;

            string trailingBatchText = text.ToString();

            if (!string.IsNullOrWhiteSpace(trailingBatchText))
            {
                yield return new Batch(trailingBatchText, 1);
            }
        }

        /// <summary>
        /// Counts the batches a script file executes, including repeat counts.
        /// </summary>
        /// <param name="ScriptFilePath">The script file to count.</param>
        /// <returns>The number of batch executions.</returns>
        internal static int CountBatches(string ScriptFilePath)
        {
            int count = 0;

            foreach (Batch batch in ReadBatches(ScriptFilePath))
            {
                count += batch.RepeatCount;
            }

            return count;
        }

        /// <summary>
        /// Tests whether a line is a GO batch separator and parses its optional
        /// repeat count.
        /// </summary>
        /// <param name="Line">The line to test.</param>
        /// <param name="ScriptFilePath">The script file the line came from.</param>
        /// <param name="RepeatCount">The number of times to repeat the batch.</param>
        /// <returns>True when the line is a batch separator.</returns>
        private static bool TryParseBatchSeparator(string Line,
            string ScriptFilePath, out int RepeatCount)
        {
            RepeatCount = 1;

            ReadOnlySpan<char> trimmedLine = Line.AsSpan().Trim();

            if (trimmedLine.Length < 2) return false;

            if ((trimmedLine[0] != 'G' && trimmedLine[0] != 'g') ||
                (trimmedLine[1] != 'O' && trimmedLine[1] != 'o'))
            {
                return false;
            }

            if (trimmedLine.Length == 2) return true;

            if (!char.IsWhiteSpace(trimmedLine[2])) return false;

            int digitsStart = 2;

            while (digitsStart < trimmedLine.Length &&
                char.IsWhiteSpace(trimmedLine[digitsStart]))
            {
                digitsStart++;
            }

            if (digitsStart == trimmedLine.Length) return false;

            ReadOnlySpan<char> digits = trimmedLine.Slice(digitsStart);

            foreach (char character in digits)
            {
                if (character < '0' || character > '9') return false;
            }

            if (!int.TryParse(digits, out RepeatCount))
            {
                throw new InvalidRepeatCountException(ScriptFilePath);
            }

            return true;
        }
    }
}
