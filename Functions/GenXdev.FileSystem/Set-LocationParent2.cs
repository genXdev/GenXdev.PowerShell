using System.Management.Automation;

namespace GenXdev.FileSystem
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Navigates up two directory levels in the file system hierarchy.
.DESCRIPTION
* Changes the current working directory to the grandparent directory
  (two levels up).
* Displays the contents of the resulting directory.

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
Set-LocationParent2
```

Changes to the grandparent directory and displays its contents.
.EXAMPLE
```powershell
...
```

Uses the '...' alias for the same operation.
")]
    [Cmdlet(VerbsCommon.Set, "LocationParent2", SupportsShouldProcess = true)]
    [Alias("...")]
    [OutputType(typeof(PSObject))]
    public class SetLocationParent2Command : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Output verbose information about current location
            WriteVerbose("Current location: " + SessionState.Path.CurrentLocation.Path);
        }

        /// <summary>
        /// Process record - main cmdlet logic for navigating up directories
        /// </summary>
        protected override void ProcessRecord()
        {
            // Loop through two levels of navigation
            for (int i = 1; i <= 2; i++)
            {
                // Get the parent directory of current location
                var parentResult = InvokeCommand.InvokeScript(
                    "Microsoft.PowerShell.Management\\Split-Path -Path " +
                    "(Microsoft.PowerShell.Management\\Get-Location) -Parent");

                // Check if parent is null (at root level)
                if (parentResult.Count == 0 || parentResult[0] == null)
                {
                    // Write verbose message when cannot go up further
                    WriteVerbose("Cannot go up further - at root level");
                    break;
                }

                // Get the parent path as string
                string parentPath = parentResult[0].ToString();

                // Prepare target description for ShouldProcess
                string target = $"from '{SessionState.Path.CurrentLocation.Path}' to " +
                    $"'{parentPath}' (level {i} of 2)";

                // Only navigate if ShouldProcess returns true
                if (ShouldProcess(target, "Change location"))
                {
                    // Change to the parent directory
                    InvokeCommand.InvokeScript(
                        $"Microsoft.PowerShell.Management\\Set-Location -LiteralPath '{parentPath}'");
                }
                else
                {
                    // Exit the loop if user declined
                    break;
                }
            }

            // Check WhatIf preference
            bool whatIfPreference = (bool)(SessionState.PSVariable.GetValue("WhatIfPreference") ?? false);

            // Show contents of the new current directory if not in WhatIf mode and on FileSystem provider
            if (!whatIfPreference && SessionState.Path.CurrentLocation.Provider.Name == "FileSystem")
            {
                // Get child items and output them
                var childItems = InvokeCommand.InvokeScript("Microsoft.PowerShell.Management\\Get-ChildItem");
                WriteObject(childItems, true);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // Output verbose information about final directory location
            WriteVerbose("Navigation completed to: " + SessionState.Path.CurrentLocation.Path);
        }
    }
}