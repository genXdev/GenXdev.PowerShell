using System.Management.Automation;

namespace GenXdev.FileSystem
{

    [Cmdlet(VerbsCommunications.Write, "FileAtomic")]
    [System.ComponentModel.Description(@"
.SYNOPSIS
Writes bytes to a file atomically to prevent corruption.

.DESCRIPTION
* Atomic write: uses a temp-file + rename strategy to ensure the target
  file is never left in a corrupted state if the process is interrupted.
* Retry logic: retries the write up to MaxRetries times with a delay of
  RetryDelayMs milliseconds between attempts.
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
The byte array to write to the file.

.PARAMETER MaxRetries
The maximum number of retry attempts for the atomic write operation.

.PARAMETER RetryDelayMs
The delay in milliseconds between retry attempts.

.PARAMETER DebounceMs
If greater than 0, debounce writes to this file. Rapid consecutive
calls within DebounceMs milliseconds reset the timer; the actual write
fires once the file hasn't been touched for DebounceMs ms. Default is
0 (disabled). Use this to batch rapid updates from loops or events.

.EXAMPLE
```powershell
Write-FileAtomic -FilePath ""data.bin"" -Data $bytes
```

Writes a byte array to data.bin atomically with default retry settings.

.EXAMPLE
```powershell
# Debounce: only the LAST write within 5 seconds actually hits disk
1..100 | ForEach-Object {
    Write-FileAtomic -FilePath ""state.bin"" -Data $_ `
        -DebounceMs 5000
}
Start-Sleep -Seconds 6
```

Rapidly writes 100 times but only the final payload (100) is persisted
to disk after a 5-second quiet period.

.EXAMPLE
```powershell
Write-FileAtomic -FilePath ""cache.dat"" -Data $buffer `
    -MaxRetries 10 -RetryDelayMs 500
```

Writes with custom retry: up to 10 attempts with 500ms between each.
")]
    public partial class WriteFileAtomicCommand : PSGenXdevCmdlet
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
        /// The byte array to write to the file.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = "The byte array to write to the file.")]
        public byte[] Data { get; set; } = new byte[0];

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
        /// base class which handles debounce routing internally.
        /// </summary>
        protected override void ProcessRecord()
        {
            string resolvedPath = ExpandPath(FilePath,
                CreateDirectory: true);

            WriteFileAtomic(resolvedPath, Data, MaxRetries,
                RetryDelayMs, DebounceMs);
        }
    }
}
