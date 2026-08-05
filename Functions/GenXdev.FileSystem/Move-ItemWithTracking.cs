using System.Management.Automation;
using System.Runtime.InteropServices;

namespace GenXdev.FileSystem
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Moves files and directories while preserving filesystem links and
references.
.DESCRIPTION
* Uses the Windows MoveFileEx API to move files and directories with link
  tracking enabled, ensuring filesystem references are maintained.
* If the source path is under Git control, it attempts to use git mv to
  track the rename in Git.
* Falls back to MoveFileEx if Git is not available or git mv fails.

.LICENSE
Copyright (C) 2026 René Vaessen / GenXdev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>.

.EXAMPLE
```powershell
Move-ItemWithTracking -Path ""C:\temp\oldfile.txt"" -Destination ""D:\newfile.txt""
```

Moves a file while preserving filesystem links and Git tracking.
.EXAMPLE
```powershell
""C:\temp\olddir"" | Move-ItemWithTracking -Destination ""D:\newdir"" -Force
```

Moves a directory, overwriting destination if it exists.
")]
    [Cmdlet(VerbsCommon.Move, "ItemWithTracking")]
    [OutputType(typeof(bool))]
    public partial class MoveItemWithTrackingCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The source path of the file or directory to move
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Source path of file/directory to move")]
        [ValidateNotNullOrEmpty]
        [Alias("FullName")]
        public string Path { get; set; }

        /// <summary>
        /// The target path where the file or directory should be moved to
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Destination path to move to")]
        [ValidateNotNullOrEmpty]
        public string Destination { get; set; }

        /// <summary>
        /// Allows overwriting an existing file or directory at the destination
        /// </summary>
        [Parameter(
            HelpMessage = "Overwrite destination if it exists")]
        public SwitchParameter Force { get; set; }

        // P/Invoke declaration for MoveFileEx
        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        private static extern bool MoveFileEx(
            string lpExistingFileName,
            string lpNewFileName,
            int dwFlags);

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // No initialization needed beyond P/Invoke declaration
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                // Convert relative paths to absolute filesystem paths
                string fullSourcePath = ExpandPath(Path);
                string fullDestPath = ExpandPath(Destination);

                // Verify the source path exists before attempting move
                if (File.Exists(fullSourcePath) || Directory.Exists(fullSourcePath))
                {
                    // Check if user wants to proceed with the operation
                    if (ShouldProcess(fullSourcePath, $"Move to {fullDestPath}"))
                    {
                        // Check if git is available
                        bool gitAvailable = IsGitAvailable();

                        if (gitAvailable)
                        {
                            // Check if the source path is under Git control
                            if (IsGitRepository(fullSourcePath))
                            {
                                WriteVerbose("Source path is under Git control, attempting git mv");

                                // Attempt git mv
                                if (TryGitMove(fullSourcePath, fullDestPath, Force.ToBool()))
                                {
                                    WriteVerbose("Git mv completed successfully");

                                    // Verify the move occurred
                                    if (!File.Exists(fullSourcePath) && !Directory.Exists(fullSourcePath) &&
                                        (File.Exists(fullDestPath) || Directory.Exists(fullDestPath)))
                                    {
                                        WriteObject(true);
                                        return;
                                    }
                                    else
                                    {
                                        WriteVerbose("Git mv reported success but move not confirmed, falling back to MoveFileEx");
                                    }
                                }
                                else
                                {
                                    WriteVerbose("Git mv failed, falling back to MoveFileEx");
                                }
                            }
                        }

                        // Fallback to MoveFileEx logic
                        WriteVerbose($"Moving {fullSourcePath} to {fullDestPath} using MoveFileEx");

                        // Configure move operation flags
                        const int MOVEFILE_WRITE_THROUGH = 0x8;
                        const int MOVEFILE_REPLACE_EXISTING = 0x1;

                        int flags = MOVEFILE_WRITE_THROUGH;
                        if (Force.ToBool())
                        {
                            flags |= MOVEFILE_REPLACE_EXISTING;
                        }

                        bool result = MoveFileEx(fullSourcePath, fullDestPath, flags);

                        if (!result)
                        {
                            // Get detailed error information on failure
                            int errorCode = Marshal.GetLastWin32Error();
                            throw new InvalidOperationException($"Move failed from '{fullSourcePath}' to '{fullDestPath}'. Error: {errorCode}");
                        }

                        WriteVerbose("Move completed successfully with link tracking");
                        WriteObject(true);
                    }
                    else
                    {
                        WriteObject(false);
                    }
                }
                else
                {
                    WriteWarning($"Source path not found: {fullSourcePath}");
                    WriteObject(false);
                }
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(ex, "MoveItemWithTrackingError", ErrorCategory.InvalidOperation, null));
                WriteObject(false);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }

        /// <summary>
        /// Check if git command is available
        /// </summary>
        private bool IsGitAvailable()
        {
            return InvokeScript<bool>("if (gcm git -erroraction SilentlyContinue) { $true } else { $false }");
        }

        /// <summary>
        /// Check if the path is inside a Git repository
        /// </summary>
        private bool IsGitRepository(string path)
        {
            string sourceDir = System.IO.Path.GetDirectoryName(path);

            try
            {
                string script = $@"
                param ($sourceDir)
Push-Location $sourceDir
$result = git.exe rev-parse --is-inside-work-tree 2>$null
$LASTEXITCODE -eq 0 -and $result.Trim() -eq 'true'
Pop-Location
";
                return InvokeScript<bool>(script, new object[] { sourceDir });
            }
            catch
            {
                return false;
            }
        }

        /// <summary>
        /// Attempt to move using git mv
        /// </summary>
        private bool TryGitMove(string sourcePath, string destPath, bool force)
        {
            try
            {
                string script = "param($sourcePath, $destPath, $force) git.exe mv \"$(if ($force) { '-f' } else { '' })\" $sourcePath $destPath";
                InvokeScript<string>(script, new object[] { sourcePath, destPath, force });
                return !System.IO.File.Exists(sourcePath) && !System.IO.Directory.Exists(sourcePath) &&
                    (System.IO.File.Exists(destPath) || System.IO.Directory.Exists(destPath));
            }
            catch
            {
                return false;
            }
        }
    }
}