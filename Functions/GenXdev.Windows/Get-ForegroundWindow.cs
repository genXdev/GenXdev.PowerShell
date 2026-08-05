using System.Runtime.InteropServices;
using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets the handle of the currently active foreground window.
.DESCRIPTION
* This cmdlet retrieves the window handle (HWND) of the window that is
  currently in the foreground and has keyboard focus.
* It uses Windows API functions through P/Invoke to interact with the
  User32.dll library.

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
Get-ForegroundWindow
```

Retrieves and returns the IntPtr handle of the currently active window.
.EXAMPLE
```powershell
$windowHandle = Get-ForegroundWindow
Write-Host ""Active window handle: $windowHandle""
```

Stores the foreground window handle in a variable and displays it.
")]
    [Cmdlet(VerbsCommon.Get, "ForegroundWindow")]
    [OutputType(typeof(IntPtr))]
    public class GetForegroundWindowCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// P/Invoke declaration for GetForegroundWindow from user32.dll
        /// </summary>
        [DllImport("user32.dll")]
        private static extern IntPtr GetForegroundWindow();

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
            // Output verbose information about the operation being performed
            WriteVerbose("Attempting to get foreground window handle");

            // Call the Windows API to get the handle of the currently active window
            WriteObject(GetForegroundWindow());
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}