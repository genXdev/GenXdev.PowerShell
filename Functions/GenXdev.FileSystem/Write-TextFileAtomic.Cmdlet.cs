using System.Management.Automation;
using System.Text;

namespace GenXdev.FileSystem
{

    [Cmdlet(VerbsCommunications.Write, "TextFileAtomic")]
    [System.ComponentModel.Description(@"
.SYNOPSIS
Writes text to a file atomically to prevent corruption.

.DESCRIPTION
* Atomic write: uses a temp-file + rename strategy to ensure the target
  file is never left in a corrupted state if the process is interrupted.
* Retry logic: retries the write up to MaxRetries times with a delay of
  RetryDelayMs milliseconds between attempts.
* Encoding support: accepts a System.Text.Encoding parameter to control
  the output encoding. Defaults to UTF-8.
* Debounce support: when DebounceMs > 0, rapid consecutive writes to
  the same file are coalesced — only the last payload is written once
  the file hasn't been touched for DebounceMs ms.
* Directory creation: creates parent directories automatically if they
  don't exist.

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

.PARAMETER FilePath
The path to the file to write.

.PARAMETER Data
The text content to write to the file.

.PARAMETER MaxRetries
The maximum number of retry attempts for the atomic write operation.

.PARAMETER RetryDelayMs
The delay in milliseconds between retry attempts.

.PARAMETER Encoding
The text encoding to use when writing the file. Default is UTF-8.

.PARAMETER DebounceMs
If greater than 0, debounce writes to this file. Rapid consecutive
calls within DebounceMs milliseconds reset the timer; the actual write
fires once the file hasn't been touched for DebounceMs ms. Default is
0 (disabled). Use this to batch rapid updates from loops or events.

.EXAMPLE
```powershell
Write-TextFileAtomic -FilePath ""config.txt"" -Data ""hello world""
```

Writes a string to config.txt using UTF-8 encoding atomically.

.EXAMPLE
```powershell
# Debounce: only the LAST log line within 2 seconds hits disk
Get-Content server.log -Tail 50 | ForEach-Object {
    Write-TextFileAtomic -FilePath ""filtered.log"" -Data $_ `
        -DebounceMs 2000
}
Start-Sleep -Seconds 3
```

Pipes 50 lines rapidly; only the final line is persisted after a
2-second quiet period.

.EXAMPLE
```powershell
Write-TextFileAtomic -FilePath ""data.csv"" -Data $csv `
    -Encoding ([System.Text.Encoding]::ASCII)
```

Writes a string to data.csv using ASCII encoding atomically.

.EXAMPLE
```powershell
# Debounce with custom retry: coalesce UI state saves
$watcher = Start-ThreadJob -ScriptBlock {
    param($path)
    while ($true) {
        Write-TextFileAtomic -FilePath $path `
            -Data (Get-Date -Format 'yyyy-MM-dd HH:mm:ss') `
            -DebounceMs 1000 -MaxRetries 3
        Start-Sleep -Milliseconds 100
    }
} -ArgumentList ""timestamp.txt""
```

A background job writes timestamps every 100ms but debounce coalesces
them — only one write per second actually hits disk.
")]
    public partial class WriteTextFileAtomicCommand : PSGenXdevCmdlet
    {

        /// <summary>
        /// The path to the file to write.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The path to the file to write.")]
        [ValidateNotNullOrEmpty]
        public string FilePath { get; set; }

        /// <summary>
        /// The text content to write to the file.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = "The text content to write to the file.")]
        public string Data { get; set; } = "";

        /// <summary>
        /// The maximum number of retry attempts for the atomic write
        /// operation. Default is 4.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "The maximum number of retry attempts for " +
                "the atomic write operation. Default is 4.")]
        public int MaxRetries { get; set; } = 4;

        /// <summary>
        /// The delay in milliseconds between retry attempts. Default
        /// is 200.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "The delay in milliseconds between retry " +
                "attempts. Default is 200.")]
        public int RetryDelayMs { get; set; } = 200;

        /// <summary>
        /// The text encoding to use when writing the file. Default
        /// is UTF-8.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "The text encoding to use when writing " +
                "the file. Default is UTF-8.")]
        public Encoding Encoding { get; set; } = Encoding.UTF8;

        /// <summary>
        /// If greater than 0, debounce writes to this file. Default
        /// is 0 (disabled).
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "If greater than 0, debounce writes to " +
                "this file. Default is 0 (disabled).")]
        public int DebounceMs { get; set; } = 0;

        /// <summary>
        /// Process record — resolve the file path and delegate to
        /// base class which handles encoding and debounce routing
        /// internally.
        /// </summary>
        protected override void ProcessRecord()
        {
            string resolvedPath = ExpandPath(FilePath,
                CreateDirectory: true);

            WriteTextFileAtomic(resolvedPath, Data, MaxRetries,
                RetryDelayMs, DebounceMs, Encoding);
        }
    }
}
