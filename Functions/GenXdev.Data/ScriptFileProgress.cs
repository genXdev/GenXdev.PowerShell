using System.Management.Automation;

namespace GenXdev.Data
{
    /// <summary>
    /// Builds the progress records of one SQL script file: a record for the
    /// file and a child record for every batch it executes.
    /// </summary>
    internal sealed class ScriptFileProgress
    {
        /// <summary>
        /// Source of unique progress activity identifiers. Starts well above
        /// the identifiers build systems allocate, so the two never collide.
        /// </summary>
        private static int nextActivityId = int.MaxValue / 2;

        /// <summary>
        /// The file name the file record is labeled with.
        /// </summary>
        private readonly string fileName;

        /// <summary>
        /// The full path of the script file.
        /// </summary>
        private readonly string scriptFilePath;

        /// <summary>
        /// The number of batches the file executes.
        /// </summary>
        private readonly int totalSections;

        /// <summary>
        /// The activity identifier of the caller's parent progress record.
        /// </summary>
        private readonly int parentActivityId;

        /// <summary>
        /// The activity identifier of the file's own progress record.
        /// </summary>
        private readonly int fileActivityId;

        /// <summary>
        /// The activity identifiers of the batch progress records.
        /// </summary>
        private readonly Dictionary<int, int> sectionActivityIds = new();

        /// <summary>
        /// The number of batches that completed.
        /// </summary>
        private int completedSections;

        /// <summary>
        /// Creates the progress state of one script file.
        /// </summary>
        /// <param name="ScriptFilePath">The script file being executed.</param>
        /// <param name="TotalSections">The number of batches it executes.</param>
        /// <param name="ParentActivityId">The parent activity identifier.</param>
        internal ScriptFileProgress(string ScriptFilePath, int TotalSections,
            int ParentActivityId)
        {
            scriptFilePath = ScriptFilePath;
            fileName = Path.GetFileName(ScriptFilePath);
            totalSections = TotalSections;
            parentActivityId = ParentActivityId;
            fileActivityId = Interlocked.Increment(ref nextActivityId);
        }

        /// <summary>
        /// Creates the record that announces the file.
        /// </summary>
        /// <returns>The file progress record.</returns>
        internal ProgressRecord StartFile()
        {
            return FileRecord(0, $"Batch 0 of {totalSections}");
        }

        /// <summary>
        /// Creates the record that announces one batch.
        /// </summary>
        /// <param name="SectionNumber">The batch number within the file.</param>
        /// <returns>The batch progress record.</returns>
        internal ProgressRecord StartSection(int SectionNumber)
        {
            return new ProgressRecord(
                SectionActivityId(SectionNumber),
                $"Batch {SectionNumber} of {totalSections}",
                fileName)
            {
                ParentActivityId = fileActivityId,
                PercentComplete = 0
            };
        }

        /// <summary>
        /// Creates the record that completes one batch.
        /// </summary>
        /// <param name="SectionNumber">The batch number within the file.</param>
        /// <returns>The completed batch progress record.</returns>
        internal ProgressRecord CompleteSection(int SectionNumber)
        {
            completedSections++;

            return new ProgressRecord(
                SectionActivityId(SectionNumber),
                $"Batch {SectionNumber} of {totalSections}",
                fileName)
            {
                ParentActivityId = fileActivityId,
                PercentComplete = 100,
                RecordType = ProgressRecordType.Completed
            };
        }

        /// <summary>
        /// Creates the record that updates the file percentage.
        /// </summary>
        /// <returns>The updated file progress record.</returns>
        internal ProgressRecord UpdateFile()
        {
            return FileRecord(
                PercentComplete,
                $"Batch {completedSections} of {totalSections}");
        }

        /// <summary>
        /// Creates the record that completes the file.
        /// </summary>
        /// <returns>The completed file progress record.</returns>
        internal ProgressRecord CompleteFile()
        {
            ProgressRecord record = FileRecord(
                PercentComplete,
                $"Batch {completedSections} of {totalSections}");

            record.RecordType = ProgressRecordType.Completed;

            return record;
        }

        /// <summary>
        /// The percentage of the file that completed.
        /// </summary>
        private int PercentComplete =>
            totalSections <= 0 ?
                100 :
                Math.Min(100, (completedSections * 100) / totalSections);

        /// <summary>
        /// Creates a progress record for the file itself.
        /// </summary>
        /// <param name="PercentComplete">The percentage that completed.</param>
        /// <param name="CurrentOperation">The operation in progress.</param>
        /// <returns>The file progress record.</returns>
        private ProgressRecord FileRecord(int PercentComplete,
            string CurrentOperation)
        {
            return new ProgressRecord(fileActivityId, fileName, scriptFilePath)
            {
                ParentActivityId = parentActivityId,
                PercentComplete = PercentComplete,
                CurrentOperation = CurrentOperation
            };
        }

        /// <summary>
        /// Returns the activity identifier of one batch, creating it once.
        /// </summary>
        /// <param name="SectionNumber">The batch number within the file.</param>
        /// <returns>The batch activity identifier.</returns>
        private int SectionActivityId(int SectionNumber)
        {
            if (!sectionActivityIds.TryGetValue(SectionNumber, out int activityId))
            {
                activityId = Interlocked.Increment(ref nextActivityId);
                sectionActivityIds[SectionNumber] = activityId;
            }

            return activityId;
        }
    }
}
