using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Returns a window helper object for the PowerShell terminal's main window.
.DESCRIPTION
* Retrieves a WindowObj helper object that represents the main window of
  the current PowerShell host process.
* This allows manipulation and interaction with the terminal window itself.

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
Get-PowershellMainWindow
```

Retrieves the WindowObj for the current PowerShell terminal window.
")]
    [Cmdlet(VerbsCommon.Get, "PowershellMainWindow")]
    [OutputType(typeof(GenXdev.Helpers.WindowObj))]
    public class GetPowershellMainWindowCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting to locate PowerShell main window...");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteVerbose("Retrieving PowerShell host process...");

            var processResult = InvokeCommand.InvokeScript("GenXdev\\Get-PowershellMainWindowProcess");

            var process = processResult.Count > 0 ? processResult[0] : null;

            if (process == null || ((dynamic)process).MainWindowHandle == IntPtr.Zero)
            {
                WriteError(new ErrorRecord(
                    new Exception("Failed to retrieve a valid PowerShell process with a main window"),
                    "ProcessNotFound",
                    ErrorCategory.ObjectNotFound,
                    null));

                processResult = InvokeCommand.InvokeScript($"Microsoft.PowerShell.Management\\Get-Process -Id {System.Diagnostics.Process.GetCurrentProcess().Id}");

                process = processResult.Count > 0 ? processResult[0] : null;
            }

            WriteVerbose($"Found PowerShell host process with ID: {((dynamic)process).Id} ({((dynamic)process).ProcessName})");

            WriteVerbose("Attempting to get main window handle...");

            var realProcess = process?.BaseObject as System.Diagnostics.Process;
            GenXdev.Helpers.WindowObj mainWindow = null;

            if (realProcess != null)
            {
                var mainWindows = GenXdev.Helpers.WindowObj.GetMainWindow(realProcess);
                mainWindow = mainWindows.FirstOrDefault();
            }

            if (mainWindow == null)
            {
                return;
            }

            WriteVerbose($"Successfully retrieved main window handle: {((dynamic)mainWindow).Handle}\r\nTitle: {((dynamic)mainWindow).Title}");

            WriteObject(mainWindow);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}