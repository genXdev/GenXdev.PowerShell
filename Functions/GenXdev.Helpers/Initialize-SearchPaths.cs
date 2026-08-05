using System.Management.Automation;

namespace GenXdev.Helpers
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Initializes and configures system search paths for package management.
.DESCRIPTION
* Builds a comprehensive list of search paths by combining default system
  locations, chocolatey paths, development tool paths, and custom package
  paths.
* Updates the system's PATH environment variable with these consolidated
  paths.

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
Initialize-SearchPaths
```

Initializes search paths using the default workspace folder.
.EXAMPLE
```powershell
Initialize-SearchPaths -WorkspaceFolder ""C:\workspace""
```

Initializes search paths using a specific workspace folder.
")]
    [Cmdlet("Initialize", "SearchPaths")]
    [OutputType(typeof(void))]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseSingularNouns", "")]
    public class InitializeSearchPathsCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The workspace folder path to use for node modules and PowerShell paths.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            HelpMessage = "The workspace folder path to use for node modules and PowerShell paths.")]
        public string WorkspaceFolder { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Initializing search paths collection");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Set default WorkspaceFolder if not provided
            if (string.IsNullOrEmpty(WorkspaceFolder))
            {
                var moduleBase = this.MyInvocation.MyCommand.Module.ModuleBase;
                WorkspaceFolder = Path.GetFullPath(Path.Combine(moduleBase, "..", "..", ".."));
            }

            // Create a new list to store unique search paths
            var searchPaths = new List<string>();

            // Add system and development tool paths
            var defaultPaths = new[]
            {
                ExpandPath("${env:ProgramData}\\chocolatey\\bin\\"),
                ExpandPath($"{WorkspaceFolder}\\node_modules\\.bin"),
                ExpandPath($"{WorkspaceFolder}\\scripts"),
                ExpandPath("${env:ProgramFiles}\\Git\\cmd"),
                ExpandPath("${env:ProgramFiles}\\nodejs"),
                ExpandPath("${env:ProgramFiles}\\Google\\Chrome\\Application"),
                ExpandPath("${env:ProgramFiles}\\Microsoft VS Code\\bin"),
                ExpandPath("${env:LOCALAPPDATA}Programs\\Microsoft VS Code Insiders"),
                ExpandPath("${env:ProgramFiles}\\dotnet")
            };

            foreach (var path in defaultPaths)
            {
                searchPaths.Add(path);
            }

            // Add paths from GenXdev packages
            var genXdevPackages = GetGenXdevPackages();
            foreach (var package in genXdevPackages)
            {
                var searchPathProperty = package.Properties["searchpath"];
                if (searchPathProperty != null && searchPathProperty.Value != null)
                {
                    var searchPath = searchPathProperty.Value.ToString();
                    if (!string.IsNullOrWhiteSpace(searchPath))
                    {
                        // Escape special characters in path
                        var escapedPath = searchPath.Replace("`", "``").Replace("\"", "`\"");
                        // Evaluate any variables in the path
                        var evaluatedPath = InvokeCommand.InvokeScript($"Invoke-Expression \"{escapedPath}\"").FirstOrDefault()?.ToString() ?? escapedPath;
                        // Convert to full path
                        var fullPath = ExpandPath(evaluatedPath);
                        searchPaths.Add(fullPath);
                    }
                }
            }

            // Process existing PATH entries
            WriteVerbose("Processing existing PATH environment entries");
            var existingPath = System.Environment.GetEnvironmentVariable("Path") ?? "";
            var existingPaths = existingPath.Split(new[] { ';' }, StringSplitOptions.RemoveEmptyEntries);

            foreach (var path in existingPaths)
            {
                if (!string.IsNullOrWhiteSpace(path))
                {
                    try
                    {
                        // Convert to full path
                        var fullPath = ExpandPath(path);
                        // Add path if not already present
                        if (!searchPaths.Contains(fullPath))
                        {
                            searchPaths.Add(fullPath);
                        }
                    }
                    catch (Exception ex)
                    {
                        WriteInformation(new InformationRecord($"Could not parse path: {ex.Message}", "PathParseError"));
                    }
                }
            }

            // Update system PATH with consolidated search paths
            WriteVerbose("Updating system PATH environment variable");
            var newPath = string.Join(";", searchPaths);
            System.Environment.SetEnvironmentVariable("Path", newPath);

            // Also update PowerShell session PATH variable
            var scriptBlock = ScriptBlock.Create("param($path) $Env:Path = $path");
            scriptBlock.Invoke(newPath);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }

        /// <summary>
        /// Gets the GenXdevPackages variable from PowerShell session
        /// </summary>
        private IEnumerable<PSObject> GetGenXdevPackages()
        {
            var result = InvokeCommand.InvokeScript("$GenXdevPackages");
            return result.Select(r => r as PSObject).Where(r => r != null);
        }
    }
}