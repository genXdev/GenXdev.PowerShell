using System.Runtime.InteropServices;
using System.Text.RegularExpressions;

namespace GenXdev.Helpers
{
    public static class FileSystem
    {
        [Flags]
        internal enum MoveFileFlags
        {
            None = 0,
            ReplaceExisting = 1,
            CopyAllowed = 2,
            DelayUntilReboot = 4,
            WriteThrough = 8,
            CreateHardlink = 16,
            FailIfNotTrackable = 32,
        }

        internal static class NativeMethods
        {
            [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
            public static extern bool MoveFileEx(
                string lpExistingFileName,
                string lpNewFileName,
                MoveFileFlags dwFlags);
        }

        public static bool FileNameFitsMask(string filename, string filemask)
        {
            filename = Path.GetFileName(filename);
            try
            {
                Regex mask = new Regex(filemask.Replace(".", "[.]").Replace("*", ".*").Replace("?", "."));

                return mask.IsMatch(filename);
            }
            catch
            {
                return false;
            }
        }

        public static bool ForciblyMoveFile(ref string sourceFilePath, string targetFilePath, bool deleteDirIfEmpty)
        {
            if (ForciblyMoveFile(sourceFilePath, targetFilePath, deleteDirIfEmpty))
            {
                sourceFilePath = targetFilePath;
                return true;
            }

            return false;
        }

        public static bool ForciblyMoveFile(string sourceFilePath, string targetFilePath, bool deleteDirIfEmpty)
        {
            ForciblyPrepareTargetFilePath(targetFilePath);

            try
            {
                try
                {
                    File.Move(sourceFilePath, targetFilePath);
                    return true;
                }
                catch
                {
                    // TakeOwnership(sourceFilePath);
                }

                ForciblyPrepareTargetFilePath(targetFilePath);
                File.Move(sourceFilePath, targetFilePath);

                return true;
            }
            catch
            {
                return false;
            }
            finally
            {
                if (deleteDirIfEmpty)
                {
                    DeleteDirectoryIfEmpty(sourceFilePath);
                }
            }
        }

        public static void ForciblyPrepareTargetFilePath(string targetFilePath, bool deleteIfExists = true)
        {
            // create directory?
            ForciblyPrepareTargetDirectory(Path.GetDirectoryName(targetFilePath));

            // delete?
            if (deleteIfExists && File.Exists(targetFilePath))
            {
                try
                {
                    ForciblyDeleteFile(targetFilePath, false);
                }
                catch { }
            }
        }

        public static void ForciblyPrepareTargetDirectory(string targetDirectory)
        {
            if (String.IsNullOrWhiteSpace(targetDirectory))
                return;
            if (!Directory.Exists(targetDirectory))
            {
                try
                {
                    Directory.CreateDirectory(targetDirectory);
                }
                catch { }
            }
            else
            {
                // TakeOwnership(targetDirectory);
            }
        }

        public static string GetTempFileName(string directory = null)
        {
            if (String.IsNullOrWhiteSpace(directory))
            {
                directory = Path.GetTempPath();
            }

            var result = Path.Combine(directory, "." + Path.GetRandomFileName() + ".tmp");

            ForciblyPrepareTargetFilePath(result);

            return result;
        }

        public static FileStream GetTempFileStream(FileOptions fileOptions = FileOptions.None, string directory = null)
        {
            var filePath = GetTempFileName(directory);
            var fileInfo = new FileInfo(filePath);
            var stream =
                new FileStream(
                    filePath,
                    FileMode.Create,
                    FileAccess.Write,
                    FileShare.None,
                    4096,
                    fileOptions
                );

            if ((fileOptions & (FileOptions.DeleteOnClose | FileOptions.RandomAccess)) == (FileOptions.DeleteOnClose | FileOptions.RandomAccess))
            {
                // Set the Attribute property of this file to Temporary. 
                // Although this is not completely necessary, the .NET Framework is able 
                // to optimize the use of Temporary files by keeping them cached in memory.
                fileInfo.Attributes = FileAttributes.Temporary;
            }

            return stream;
        }

        [System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Globalization", "CA2101:SpecifyMarshalingForPInvokeStringArguments", MessageId = "0"), System.Diagnostics.CodeAnalysis.SuppressMessage("Microsoft.Design", "CA1060:MovePInvokesToNativeMethodsClass"), DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool GetDiskFreeSpaceEx(string lpDirectoryName,
       out ulong lpFreeBytesAvailable,
       out ulong lpTotalNumberOfBytes,
       out ulong lpTotalNumberOfFreeBytes);

        public static bool DriveFreeBytes(string folderName, out ulong freespace)
        {
            freespace = 0;
            if (string.IsNullOrEmpty(folderName))
            {
                throw new ArgumentNullException("folderName");
            }

            if (!folderName.EndsWith("\\"))
            {
                folderName += '\\';
            }

            ulong free = 0, dummy1 = 0, dummy2 = 0;

            if (GetDiskFreeSpaceEx(folderName, out free, out dummy1, out dummy2))
            {
                freespace = free;
                return true;
            }
            else
            {
                return false;
            }
        }

        public static void ForciblyDeleteAllEmptySubDirectories(string rootDirectory)
        {
            try
            {
                if (Directory.Exists(rootDirectory))
                    foreach (var directory in Directory.GetDirectories(rootDirectory, "*", SearchOption.TopDirectoryOnly))
                    {
                        ForciblyDeleteAllEmptySubDirectories(directory);

                        try
                        {
                            Directory.Delete(directory, false);
                        }
                        catch
                        {
                            // not empty
                        }
                    }
            }
            catch
            {
                // ignore
            }
        }

        public static bool ForciblyDeleteFile(string filepath, bool DeleteDirIfEmpty)
        {
            if (!File.Exists(filepath))
                return true;

            try
            {
                try
                {
                    File.Delete(filepath);

                    return true;
                }
                catch
                {
                   // // TakeOwnership(filepath);
                }

                try
                {
                    File.Delete(filepath);

                    return true;
                }
                catch
                {
                }


                try
                {
                    if (filepath.ToLowerInvariant().EndsWith(".deleted_-"))
                    {
                        var parts = filepath.Split('.').ToList<string>();

                        parts.RemoveAt(parts.Count - 1);
                        parts.RemoveAt(parts.Count - 1);

                        filepath = string.Join(".", parts.ToArray<string>());
                    }

                    var destination = filepath + "." +
                        Guid.NewGuid().ToString().Replace("-", "").ToLowerInvariant() +
                        ".deleted_-";

                    if (ForciblyMoveFile(filepath, destination, false))
                    {
                        NativeMethods.MoveFileEx(destination, null, MoveFileFlags.DelayUntilReboot);
                    }

                    if (!File.Exists(filepath))
                        return true;
                }
                catch
                {
                }

                return !File.Exists(filepath);
            }
            catch
            {
                return !File.Exists(filepath);
            }
            finally
            {
                if (DeleteDirIfEmpty)
                {
                    var dir = Path.GetDirectoryName(filepath);

                    ForciblyDeleteDirIfEmpty(dir);
                }
            }
        }

        public static void ForciblyDeleteDirIfEmpty(string dir)
        {
            ForciblyDeleteAllEmptySubDirectories(dir);

            DeleteDirectoryIfEmpty(dir);
        }

        public static void DeleteDirectoryIfEmpty(string path)
        {
            try
            {
                if (File.Exists(path))
                {
                    path = Path.GetDirectoryName(path);
                }

                if (Directory.Exists(path))
                {
                    Directory.Delete(path);
                }
            }
            catch { }
        }


        public static bool FileIsInUse(string fullPath)
        {
            if (!File.Exists(fullPath))
                return false;

            if (Directory.Exists(fullPath))
                return false;

            try
            {
                (new FileStream(fullPath, FileMode.Open, FileAccess.ReadWrite, FileShare.None)).Close();

                return false;
            }
            catch
            {
                return true;
            }
        }

        public static bool FileNameFitsMasks(string filename, string[] filemasks)
        {
            foreach (var mask in filemasks)
                if (FileNameFitsMask(filename, mask))
                    return true;

            return false;
        }

        public static bool ForciblyDeleteDirectory(string path)
        {
            if (!Directory.Exists(path))
                return true;

            try
            {
                try
                {
                    Directory.Delete(path, true);
                }
                catch
                {
                    // TakeOwnership(path);
                }

                Directory.Delete(path, true);

                return true;
            }
            catch
            {
                return false;
            }
        }
    }
}
