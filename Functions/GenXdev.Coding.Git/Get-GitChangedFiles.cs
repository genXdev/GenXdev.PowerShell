using System.Management.Automation;

namespace GenXdev.Coding.Git
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Get the list of changed files in a Git repository.
.DESCRIPTION
This function retrieves the list of files that have been changed in the current Git repository. It can be used to identify which files have been modified, added, or deleted. By default, returns relative paths with .\ prefix. Use -PassThru to get FileInfo objects.

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
Get-GitChangedFiles
```

Returns relative paths like .\Modules\GenXdev.AI\3.34.0\README.md

.EXAMPLE
```powershell
Get-GitChangedFiles -PassThru
```

Returns FileInfo objects for each changed file.
")]
    [Cmdlet(VerbsCommon.Get, "GitChangedFiles")]
    [OutputType(typeof(string), typeof(PSObject))]
    [Alias("gitchanged")]
    public class GetGitChangedFilesCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Returns FileInfo objects (like Get-ChildItem) instead of path strings.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Returns FileInfo objects (like Get-ChildItem) instead of path strings.")]
        public SwitchParameter PassThru { get; set; }

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
            // Ensure the current directory is a Git repository
            var isGitRepoResult = InvokeCommand.InvokeScript("git rev-parse --is-inside-work-tree");

            if (isGitRepoResult == null || !isGitRepoResult.Any() || !"true".Equals(isGitRepoResult.First().ToString().Trim(), StringComparison.OrdinalIgnoreCase))
            {
                WriteError(new ErrorRecord(
                    new InvalidOperationException("This command must be run inside a Git repository."),
                    "NotInGitRepository",
                    ErrorCategory.InvalidOperation,
                    null));
                return;
            }

            // Get the list of changed files
            var changedFilesResult = InvokeCommand.InvokeScript("git diff --name-only HEAD");

            if (changedFilesResult == null || !changedFilesResult.Any())
            {
                WriteObject("No changed files found.");
                return;
            }

            var changedFiles = changedFilesResult
                .Select(obj => obj.ToString().Trim())
                .Where(file => !string.IsNullOrEmpty(file))
                .ToList();

            foreach (var file in changedFiles)
            {
                if (PassThru)
                {
                    // Return FileInfo object like Get-ChildItem would
                    var fileExistsResult = InvokeCommand.InvokeScript($"Test-Path -LiteralPath '{file}'");

                    if (fileExistsResult != null && fileExistsResult.Any() && "True".Equals(fileExistsResult.First().ToString(), StringComparison.OrdinalIgnoreCase))
                    {
                        var fileInfoResult = InvokeCommand.InvokeScript($"Get-Item -LiteralPath '{file}'");
                        if (fileInfoResult != null && fileInfoResult.Any())
                        {
                            WriteObject(fileInfoResult.First());
                        }
                    }
                    else
                    {
                        // For deleted files, we can't get FileInfo, so return a custom object
                        var customObject = new PSObject();
                        customObject.Properties.Add(new PSNoteProperty("Name", Path.GetFileName(file)));
                        customObject.Properties.Add(new PSNoteProperty("FullName", null));
                        customObject.Properties.Add(new PSNoteProperty("RelativePath", file));
                        customObject.Properties.Add(new PSNoteProperty("Exists", false));
                        WriteObject(customObject);
                    }
                }
                else
                {
                    // Return relative path with .\ prefix
                    var relativePath = ".\\" + file.Replace('/', '\\');
                    WriteObject(relativePath);
                }
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