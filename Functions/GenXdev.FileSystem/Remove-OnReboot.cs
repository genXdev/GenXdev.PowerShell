using System.Management.Automation;
using Microsoft.Win32;

namespace GenXdev.FileSystem
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Marks files or directories for deletion during the next system boot.
.DESCRIPTION
* Uses the Windows API to mark files for deletion on next boot.
* Handles locked files by first attempting to rename them to temporary
  names and tracks all moves to maintain file system integrity.
* If renaming fails, the -MarkInPlace parameter can be used to mark files
  in their original location.

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
Remove-OnReboot -Path ""C:\temp\locked-file.txt""
```

Marks a locked file for deletion during the next system boot.
.EXAMPLE
```powershell
""file1.txt"",""file2.txt"" | Remove-OnReboot -MarkInPlace
```

Marks multiple files for deletion, using MarkInPlace for any that can't be
renamed.
")]
    [Cmdlet(VerbsCommon.Remove, "OnReboot")]
    [OutputType(typeof(bool))]
    public class RemoveOnRebootCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// One or more file or directory paths to mark for deletion. Accepts pipeline input.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            HelpMessage = "Path(s) to files/directories to mark for deletion"
        )]
        [ValidateNotNullOrEmpty]
        [Alias("FullName")]
        public string[] Path { get; set; }

        /// <summary>
        /// If specified, marks files for deletion in their original location when renaming fails.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Marks files for deletion without renaming"
        )]
        public SwitchParameter MarkInPlace { get; set; }

        private List<string> pendingRenames;
        private int originalPendingCount;

        /// <summary>
        /// Initialize the cmdlet by retrieving existing pending file rename operations from the registry.
        /// </summary>
        protected override void BeginProcessing()
        {
            pendingRenames = new List<string>();

            // Retrieve existing pending file rename operations from registry
            try
            {
                using (var key = Registry.LocalMachine.OpenSubKey(@"SYSTEM\CurrentControlSet\Control\Session Manager"))
                {
                    if (key != null)
                    {
                        var value = key.GetValue("PendingFileRenameOperations") as string[];
                        if (value != null)
                        {
                            pendingRenames.AddRange(value);
                        }
                    }
                }
            }
            catch
            {
                // If we can't read existing operations, start with empty list
            }

            originalPendingCount = pendingRenames.Count;
        }

        /// <summary>
        /// Process each path in the pipeline, attempting to delete or mark for deletion on reboot.
        /// </summary>
        protected override void ProcessRecord()
        {
            foreach (var item in Path)
            {
                // Expand the path using base class method to maintain exact PowerShell path resolution behavior
                string fullPath = ExpandPath(item);

                // Check if the path exists
                bool exists = System.IO.File.Exists(fullPath) || System.IO.Directory.Exists(fullPath);

                if (!exists)
                {
                    WriteWarning($"Path not found: {fullPath}");
                    continue;
                }

                if (ShouldProcess(fullPath, "Mark for deletion on reboot"))
                {
                    try
                    {
                        // Attempt immediate deletion using .NET methods
                        if (System.IO.File.Exists(fullPath))
                        {
                            System.IO.File.Delete(fullPath);
                        }
                        else if (System.IO.Directory.Exists(fullPath))
                        {
                            System.IO.Directory.Delete(fullPath, true);
                        }
                        WriteVerbose($"Successfully deleted: {fullPath}");
                        continue;
                    }
                    catch
                    {
                        WriteVerbose("Direct deletion failed, attempting rename...");

                        try
                        {
                            // Create a hidden temporary file name
                            var dir = System.IO.Path.GetDirectoryName(fullPath);
                            var newName = "." + Guid.NewGuid().ToString();
                            var newPath = System.IO.Path.Combine(dir, newName);

                            // Rename the file using PowerShell Rename-Item
                            var renameScript = ScriptBlock.Create("param($oldPath, $newName) Microsoft.PowerShell.Management\\Rename-Item -LiteralPath $oldPath -NewName $newName -Force");
                            renameScript.Invoke(fullPath, newName);

                            // Set the renamed file as hidden and system
                            System.IO.File.SetAttributes(newPath, System.IO.File.GetAttributes(newPath) | System.IO.FileAttributes.Hidden | System.IO.FileAttributes.System);

                            WriteVerbose($"Renamed to hidden system file: {newPath}");

                            // Add to pending renames with Windows API path format
                            var sourcePath = "\\??\\" + newPath;
                            pendingRenames.Add(sourcePath);
                            pendingRenames.Add("");

                            WriteVerbose($"Marked for deletion on reboot: {newPath}");
                        }
                        catch (Exception ex)
                        {
                            if (MarkInPlace.ToBool())
                            {
                                WriteVerbose("Marking original file for deletion");
                                var sourcePath = "\\??\\" + fullPath;
                                pendingRenames.Add(sourcePath);
                                pendingRenames.Add("");
                            }
                            else
                            {
                                WriteError(new ErrorRecord(ex, "RenameFailed", ErrorCategory.InvalidOperation, fullPath));
                                continue;
                            }
                        }
                    }
                }
            }
        }

        /// <summary>
        /// Save any accumulated pending file operations to the registry and return success status.
        /// </summary>
        protected override void EndProcessing()
        {
            if (pendingRenames.Count > originalPendingCount)
            {
                try
                {
                    // Save pending operations to registry as MultiString value
                    Registry.SetValue(@"HKEY_LOCAL_MACHINE\SYSTEM\CurrentControlSet\Control\Session Manager", "PendingFileRenameOperations", pendingRenames.ToArray(), RegistryValueKind.MultiString);
                    WriteObject(true);
                }
                catch (Exception ex)
                {
                    WriteError(new ErrorRecord(ex, "RegistryWriteFailed", ErrorCategory.InvalidOperation, null));
                    WriteObject(false);
                }
            }
            else
            {
                WriteObject(true);
            }
        }
    }
}