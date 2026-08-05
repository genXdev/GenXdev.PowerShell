using System.Runtime.InteropServices;
using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Brings the specified window to the foreground and makes it the active
window.
.DESCRIPTION
* Makes a window the foreground window using multiple Win32 API methods for
  maximum reliability.
* First attempts using SwitchToThisWindow API, then falls back to
  SetForegroundWindow if needed.

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
$hwnd = (Get-Process notepad).MainWindowHandle
Set-ForegroundWindow -WindowHandle $hwnd
```

Brings a Notepad window to the foreground using the window handle.
.EXAMPLE
```powershell
$hwnd = (Get-Process notepad).MainWindowHandle
Set-ForegroundWindow $hwnd
```

Uses positional parameter for concise syntax.
")]
    [Cmdlet(VerbsCommon.Set, "ForegroundWindow")]
    public class SetForegroundWindowCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// An IntPtr handle to the target window. This handle can be obtained from Windows
        /// API calls or PowerShell window management functions like Get-Process
        /// MainWindowHandle.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Window handle to set as foreground window")]
        public IntPtr WindowHandle { get; set; }

        /// <summary>
        /// P/Invoke declaration for SwitchToThisWindow API
        /// </summary>
        [DllImport("user32.dll")]
        private static extern void SwitchToThisWindow(IntPtr hWnd, bool fAltTab);

        /// <summary>
        /// P/Invoke declaration for SetForegroundWindow API
        /// </summary>
        [DllImport("user32.dll")]
        private static extern bool SetForegroundWindow(IntPtr hWnd);

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Log the activation attempt with the window handle
            WriteVerbose($"Attempting to set foreground window for handle: {WindowHandle}");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            if (ShouldProcess($"Window {WindowHandle}", "Set as foreground window"))
            {
                try
                {
                    // Try the preferred SwitchToThisWindow API first as it's more reliable
                    WriteVerbose("Attempting primary method: SwitchToThisWindow...");
                    SwitchToThisWindow(WindowHandle, false);
                }
                catch (Exception ex)
                {
                    // Log failure of primary activation method
                    WriteVerbose($"SwitchToThisWindow failed: {ex.Message}");
                }

                try
                {
                    // Attempt SetForegroundWindow as fallback if first method failed
                    WriteVerbose("Attempting fallback method: SetForegroundWindow...");
                    SetForegroundWindow(WindowHandle);
                }
                catch (Exception ex)
                {
                    // Log failure of backup activation method
                    WriteVerbose($"SetForegroundWindow failed: {ex.Message}");
                }
            }
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