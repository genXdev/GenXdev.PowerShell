using System.Management.Automation;

namespace GenXdev.FileSystem
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Changes the current location to the parent directory and lists its contents.
.DESCRIPTION
* Navigates up one directory level in the file system hierarchy.
* Displays the contents of the new current directory.
* Provides a convenient '..' alias for quick directory navigation.

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
Set-LocationParent
```

Changes to the parent directory and lists its contents.
.EXAMPLE
```powershell
..
```

Uses the alias to change to the parent directory.
")]
    [Cmdlet(VerbsCommon.Set, "LocationParent", SupportsShouldProcess = true)]
    [Alias("..")]
    [OutputType(typeof(PSObject))]
    public class SetLocationParentCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Changing location to parent directory");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Get current location
            var currentLocation = SessionState.Path.CurrentLocation;
            // Check if we can move up before attempting
            var parent = Path.GetDirectoryName(currentLocation.Path);
            if (parent != null)
            {
                // Prepare target description for ShouldProcess
                var target = $"from '{currentLocation}' to '{parent}'";
                // Only navigate if ShouldProcess returns true
                if (ShouldProcess(target, "Change location"))
                {
                    // Navigate up one directory level
                    SessionState.Path.SetLocation("..");
                }
            }
            else
            {
                WriteVerbose("Cannot go up further - at root level");
            }
            // Show contents of the new current directory
            var results = InvokeCommand.InvokeScript("Get-ChildItem");
            WriteObject(results, true);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}