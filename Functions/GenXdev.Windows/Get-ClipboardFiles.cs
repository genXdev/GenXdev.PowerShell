using System.Diagnostics;
using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets files from the Windows clipboard that were set for file operations
like copy/paste.
.DESCRIPTION
* This function retrieves file paths from the Windows clipboard that were
  previously set for file operations.
* It handles both STA and MTA threading modes automatically, ensuring
  compatibility across different PowerShell execution contexts.
* The function validates file existence and returns only existing
  files/directories as objects similar to Get-ChildItem or Get-Item output.

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
Get-ClipboardFiles
```

Get all files currently in the clipboard as file system objects.
.EXAMPLE
```powershell
$clipboardFiles = Get-ClipboardFiles
$clipboardFiles | ForEach-Object { Write-Host $_.FullName }
```

Get clipboard files and display their full paths.
.EXAMPLE
```powershell
Get-ClipboardFiles | Where-Object { $_.Extension -eq '.txt' }
```

Get only text files from the clipboard.
")]
    [Cmdlet(VerbsCommon.Get, "ClipboardFiles")]
    [Alias("getclipfiles", "gcbf")]
    [OutputType(typeof(PSObject))]
    public class GetClipboardFilesCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Get current thread apartment state for clipboard compatibility
            var apartmentState = System.Threading.Thread.CurrentThread.GetApartmentState();

            // Initialize collection for file paths
            var clipboardFilePaths = new List<string>();

            // Check if running in single-threaded apartment mode
            if (apartmentState == System.Threading.ApartmentState.STA)
            {
                // Output verbose information about direct clipboard operation
                WriteVerbose("Getting clipboard files directly in STA mode");

                try
                {
                    // Get file drop list from clipboard in STA mode
                    var fileDropList = Clipboard.GetFileDropList();

                    if (fileDropList != null)
                    {
                        foreach (string file in fileDropList)
                        {
                            clipboardFilePaths.Add(file);
                        }
                    }
                }
                catch
                {
                    // Output verbose information if clipboard doesn't contain files
                    WriteVerbose("No file drop list found in clipboard or clipboard access failed");
                    return;
                }
            }
            else
            {
                // Output verbose information about STA subprocess requirement
                WriteVerbose("Current thread is MTA mode, launching STA subprocess for clipboard operation");

                // Create a temporary file to receive the JSON data
                var tempFile = Path.GetTempFileName();

                // Define the PowerShell command to execute in STA mode
                var command = "Add-Type -AssemblyName System.Windows.Forms;" +
                              "try {" +
                              "$fileDropList = [System.Windows.Forms.Clipboard]::GetFileDropList();" +
                              "if ($null -ne $fileDropList) {" +
                              "$paths = $fileDropList | ForEach-Object { $_ };" +
                              "$paths | ConvertTo-Json -Compress | Out-File '" + tempFile.Replace("'", "''") + "';" +
                              "} else { '[]' | Out-File '" + tempFile.Replace("'", "''") + "'; }" +
                              "} catch { '[]' | Out-File '" + tempFile.Replace("'", "''") + "'; }";

                try
                {
                    // Output verbose information about subprocess execution
                    WriteVerbose("Executing STA subprocess for clipboard operation");

                    // Prepare arguments for PowerShell subprocess
                    var pwshArgs = new[]
                    {
                        "-STA",
                        "-NoProfile",
                        "-Command",
                        command
                    };

                    // Start PowerShell subprocess in STA mode and wait for completion
                    var process = Process.Start(new ProcessStartInfo
                    {
                        FileName = "pwsh",
                        Arguments = string.Join(" ", pwshArgs),
                        UseShellExecute = false,
                        CreateNoWindow = true
                    });
                    process.WaitForExit();

                    // Read the result from temp file
                    if (File.Exists(tempFile))
                    {
                        var jsonContent = File.ReadAllText(tempFile);
                        if (!string.IsNullOrWhiteSpace(jsonContent))
                        {
                            var paths = System.Text.Json.JsonSerializer.Deserialize<string[]>(jsonContent);
                            if (paths != null)
                            {
                                clipboardFilePaths.AddRange(paths);
                            }
                        }
                        File.Delete(tempFile);
                    }
                }
                catch
                {
                    // Cleanup temp file in case of error
                    if (File.Exists(tempFile))
                    {
                        File.Delete(tempFile);
                    }

                    // Output error if subprocess execution fails
                    WriteError(new ErrorRecord(
                        new Exception("Error invoking pwsh"),
                        "ClipboardAccessError",
                        ErrorCategory.NotSpecified,
                        null));
                    return;
                }
            }

            // Exit early if no file paths retrieved
            if (clipboardFilePaths == null || clipboardFilePaths.Count == 0)
            {
                return;
            }

            var done = new HashSet<string>();
            // Validate each file path and collect only existing files/directories
            foreach (var filePath in clipboardFilePaths)
            {
                // Expand the file path to absolute path
                string path = ExpandPath(filePath);

                if (done.Contains(path))
                {
                    // Skip if this path has already been processed
                    continue;
                }

                // Mark this path as processed
                done.Add(path);

                // Check if file exists and return as file system object
                if (File.Exists(path))
                {
                    // Return file object similar to Get-Item
                    var getItemScript = ScriptBlock.Create("param($p) Get-Item -LiteralPath $p");
                    var result = getItemScript.Invoke(path);
                    WriteObject(result[0]);
                    continue;
                }

                if (Directory.Exists(path))
                {
                    // Return directory object similar to Get-Item
                    var getItemScript = ScriptBlock.Create("param($p) Get-Item -LiteralPath $p");
                    var result = getItemScript.Invoke(path);
                    WriteObject(result[0]);
                    continue;
                }
            }

            // Output verbose information about results
            if (clipboardFilePaths.Count > 0)
            {
                WriteVerbose($"Retrieved {clipboardFilePaths.Count} valid file/directory objects from clipboard");
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}