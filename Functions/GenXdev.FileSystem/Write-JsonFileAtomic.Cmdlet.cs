using System.Management.Automation;

namespace GenXdev.FileSystem
{

    [Cmdlet(VerbsCommunications.Write, "JsonFileAtomic")]
    [System.ComponentModel.Description(@"
.SYNOPSIS
Writes an object as JSON to a file atomically to prevent corruption.

.DESCRIPTION
* Atomic write: uses a temp-file + rename strategy to ensure the target
  file is never left in a corrupted state if the process is interrupted.
* Retry logic: retries the write up to MaxRetries times with a delay of
  RetryDelayMs milliseconds between attempts.
* Object support: accepts any object, not just Hashtable. Serializes
  via System.Text.Json with fallback to ConvertTo-Json for complex
  .NET types that can't be serialized natively.
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
The object to serialize as JSON and write to the file.

.PARAMETER MaxRetries
The maximum number of retry attempts for the atomic write operation.

.PARAMETER RetryDelayMs
The delay in milliseconds between retry attempts.

.PARAMETER DebounceMs
If greater than 0, debounce writes to this file. Rapid consecutive
calls within DebounceMs milliseconds reset the timer; the actual write
fires once the file hasn't been touched for DebounceMs ms. Default is
0 (disabled). Use this to batch rapid updates from loops or events.

.PARAMETER Depth
Specifies how many levels of contained objects are included in the JSON representation.
The value can be any number from `0` to `100`. The default value is `2`.
`ConvertTo-Json` emits a warning if the number of levels in an input object exceeds this number.

.PARAMETER Compress
Omits white space and indented formatting in the output string

.PARAMETER EnumsAsStrings
Provides an alternative serialization option that converts all enumerations to their string representation

.PARAMETER EscapeHandling
Controls how certain characters are escaped in the
resulting JSON output. By default, only control
characters (like newline) are escaped.

Acceptable values are:

- Default - Only control characters are escaped.
- EscapeNonAscii - All non-ASCII and control
characters are escaped.
- EscapeHtml - HTML (`<`, `>`, `&`, `'`, `""`) and control characters are escaped

.PARAMETER AsArray
Outputs the object in array brackets, even if the input is a single object.

.EXAMPLE
```powershell
$data = @{ Name = ""test""; Value = 42 }
Write-JsonFileAtomic -FilePath ""config.json"" -Data $data
```

Writes a Hashtable as indented JSON to config.json atomically.

.EXAMPLE
```powershell
Get-Process | Select-Object -First 5 |
    Write-JsonFileAtomic -FilePath ""processes.json"" -Compress
```

Writes process objects as Compress JSON atomically.
")]
    public partial class WriteJsonFileAtomicCommand : PSGenXdevCmdlet
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
        /// The object to serialize as JSON and write to the file.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = "The object to serialize as JSON and " +
                "write to the file.")]
        public object Data { get; set; } = null;

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
        /// The maximum depth for JSON serialization. Default is 30.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "The maximum depth for JSON serialization. " +
                "Default is 30.")]
        public int? Depth { get; set; }

        /// <summary>
        /// Write Compress JSON (no indentation/whitespace).
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Write Compress JSON " +
                "(no indentation/whitespace).")]
        public SwitchParameter Compress { get; set; }

        /// <summary>
        /// Outputs the object in array brackets, even if the input is a single object..
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Write Compress JSON " +
                "(no indentation/whitespace).")]
        public SwitchParameter AsArray { get; set; }

        /// <summary>
        /// Provides an alternative serialization option that converts all enumerations to their string representation.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Provides an alternative serialization option that converts all enumerations to their string representation.")]
        public SwitchParameter EnumsAsStrings { get; set; }


        /// <summary>
        /// Provides an alternative serialization option that converts all enumerations to their string representation.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Controls how certain characters are escaped in the resulting JSON output. By default, only control characters (like newline) are escaped.")]
        Newtonsoft.Json.StringEscapeHandling EscapeHandling { get; set; }

        /// <summary>
        /// Process record — resolve the file path and delegate to the
        /// base class WriteJsonAtomic method which handles
        /// serialization, debounce, and atomic write internally.
        /// </summary>
        protected override void ProcessRecord()
        {
            string resolvedPath = ExpandPath(FilePath,
                CreateDirectory: true);

            WriteJsonAtomic(resolvedPath, Data, MaxRetries,
                RetryDelayMs, DebounceMs,
                Depth,
                Compress.IsPresent ? Compress.ToBool() : null,
                EnumsAsStrings.IsPresent ? EnumsAsStrings.ToBool() : null,
                AsArray.IsPresent ? AsArray.ToBool() : null,
                EscapeHandling
            );
        }
    }
}
