using System.Management.Automation;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Scans files or directories for malware using Windows Defender.
.DESCRIPTION
* Performs a targeted scan of specified files or directories using Windows
  Defender's command-line interface (MpCmdRun.exe).
* Can scan in detection-only mode or with automatic threat remediation
  enabled.
* Returns true if no threats are detected, false if threats are found or
  the scan fails.

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
Test-PathUsingWindowsDefender -FilePath ""C:\Downloads\file.exe"" -Verbose
```

Scans the specified file and displays verbose output.
.EXAMPLE
```powershell
virusscan ""C:\Downloads\file.exe"" -EnableRemediation
```

Scans the file using the alias and enables remediation.
.EXAMPLE
```powershell
""C:\Downloads\file.exe"" | HasNoVirus
```

Pipes the file path to the cmdlet using an alias.
")]
    [Cmdlet(VerbsDiagnostic.Test, "PathUsingWindowsDefender")]
    [Alias("virusscan", "HasNoVirus")]
    [OutputType(typeof(bool))]
    public class TestPathUsingWindowsDefenderCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The full or relative path to the file or directory to be scanned
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "The path to the file or directory to be scanned")]
        [ValidateNotNullOrEmpty]
        public string FilePath { get; set; }

        /// <summary>
        /// Instructs Windows Defender to take action on threats
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Instructs Windows Defender to take action on threats")]
        public SwitchParameter EnableRemediation { get; set; }

        private string mpCmdRunPath;

        /// <summary>
        /// Begin processing - locate Windows Defender CLI
        /// </summary>
        protected override void BeginProcessing()
        {
            // Locate the windows defender command line utility
            var scriptBlock = ScriptBlock.Create("GenXdev\\Get-MpCmdRunPath");
            var results = InvokeCommand.InvokeScript(SessionState, scriptBlock);
            mpCmdRunPath = results[0]?.ToString();

            // Ensure the windows defender cli is available
            if (string.IsNullOrEmpty(mpCmdRunPath))
            {
                throw new InvalidOperationException("Windows Defender CLI (MpCmdRun.exe) not found");
            }
        }

        /// <summary>
        /// Process record - perform the scan
        /// </summary>
        protected override void ProcessRecord()
        {
            // Convert relative or shortened paths to full filesystem paths
            string expandedPath = ExpandPath(FilePath);

            // Verify the target exists before attempting to scan
            if (!File.Exists(expandedPath))
            {
                WriteError(new ErrorRecord(
                    new FileNotFoundException($"File or directory not found: {expandedPath}"),
                    "FileNotFound",
                    ErrorCategory.ObjectNotFound,
                    expandedPath));
                WriteObject(false);
                return;
            }

            // Log the initiation of the scan operation
            WriteVerbose($"Initiating Windows Defender scan of: {expandedPath}");

            // Construct the scan command parameters array
            var scanParamsList = new List<string>
            {
                "-Scan",
                "-ScanType",
                "3",
                "-File",
                $"\"{expandedPath}\""
            };

            // Add remediation flag based on user preference
            if (!EnableRemediation)
            {
                scanParamsList.Add("-DisableRemediation");
            }

            var scanParams = scanParamsList.ToArray();

            // Log the complete command being executed
            WriteVerbose($"Executing scan with parameters: {string.Join(" ", scanParams)}");

            // Execute the windows defender scan and capture output for verbose logging
            var scriptBlockScan = ScriptBlock.Create(@"
param($mpCmdRunPath, $scanParams)
& $mpCmdRunPath $scanParams | ForEach-Object { Write-Verbose $_ }
$LASTEXITCODE
");
            var scanResult = InvokeCommand.InvokeScript(SessionState, scriptBlockScan, mpCmdRunPath, scanParams);

            // Return scan result based on exit code: true = no threats, false = threats found
            WriteObject(scanResult[0]?.Equals(0) ?? false);
        }

        /// <summary>
        /// End processing - cleanup if needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}