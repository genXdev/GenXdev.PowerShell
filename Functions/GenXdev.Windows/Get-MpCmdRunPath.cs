using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets the path to the Windows Defender MpCmdRun.exe executable.
.DESCRIPTION
* Locates and returns the full path to the Windows Defender command-line
  utility (MpCmdRun.exe).
* The cmdlet checks the standard installation location in Program Files
  and provides appropriate error handling if the file is not found.

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
$defenderPath = Get-MpCmdRunPath
```

Retrieves the full path to the Windows Defender command-line tool.
")]
    [Cmdlet(VerbsCommon.Get, "MpCmdRunPath")]
    [OutputType(typeof(string))]
    public class GetMpCmdRunPathCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - construct the expected path for the Windows Defender command-line tool
        /// </summary>
        protected override void BeginProcessing()
        {
            // Construct the expected path for the Windows Defender command-line tool
            string mpCmdRunPath = Path.Combine(
                System.Environment.GetEnvironmentVariable("ProgramFiles"),
                "Windows Defender",
                "MpCmdRun.exe");

            // Log the path we're checking
            WriteVerbose($"Attempting to locate MpCmdRun.exe at: {mpCmdRunPath}");

            // Store the path for use in ProcessRecord
            this.mpCmdRunPath = mpCmdRunPath;
        }

        /// <summary>
        /// Process record - verify file existence and return path or error
        /// </summary>
        protected override void ProcessRecord()
        {
            // Verify file existence using optimized IO.File method
            if (File.Exists(this.mpCmdRunPath))
            {
                WriteVerbose("Successfully located MpCmdRun.exe");

                WriteObject(this.mpCmdRunPath);
            }
            else
            {
                // If executable not found, throw descriptive error
                string errorMsg = $"Windows Defender executable not found at: {this.mpCmdRunPath}";

                ErrorRecord errorRecord = new ErrorRecord(
                    new FileNotFoundException(errorMsg),
                    "MpCmdRunNotFound",
                    ErrorCategory.ObjectNotFound,
                    this.mpCmdRunPath);

                WriteError(errorRecord);
            }
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }

        /// <summary>
        /// Private field to store the constructed path
        /// </summary>
        private string mpCmdRunPath;
    }
}