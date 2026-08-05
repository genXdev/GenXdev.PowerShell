using System.Management.Automation;
using System.Text.RegularExpressions;

namespace GenXdev.Queries
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Parses strings for any valid URI.
.DESCRIPTION
* Extracts all valid URIs from input text, supporting standard and custom URI
  schemes like http:, https:, ftp:, magnet:, about:, etc.
* Returns Uri objects for each valid URI found.

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
ConvertTo-Uris -Text ""Check out https://github.com and about:config""
```

Parses the provided text string for URIs and returns Uri objects.
.EXAMPLE
```powershell
""Visit http://example.com"" | ConvertTo-Uris
```

Pipes a text string to the cmdlet for URI parsing.
")]
    [Cmdlet(VerbsData.ConvertTo, "Uris")]
    [OutputType(typeof(Uri))]
    public class ConvertToUrisCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// One or more text strings that may contain URIs to parse
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 0,
            ValueFromPipeline = true,
            HelpMessage = "Text input that may contain URIs"
        )]
        [ValidateNotNull()]
        public string[] Text { get; set; }

        private Regex uriRegex;

        /// <summary>
        /// Initialize URI parsing
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Initializing URI parsing");

            // Regex pattern to match URIs with various schemes
            uriRegex = new Regex(@"(?<scheme>[A-Za-z][A-Za-z0-9+\.\-]*):[^\s""]+");
        }

        /// <summary>
        /// Process each input text line
        /// </summary>
        protected override void ProcessRecord()
        {
            if (Text == null)
            {
                return;
            }

            // Process each input text line
            foreach (var line in Text)
            {
                // Get first 30 chars of line for logging
                var previewText = line.Length > 30 ? line.Substring(0, 30) : line;

                WriteVerbose($"Processing text line: {previewText}...");

                // Find all URI matches in the current line
                var uriMatches = uriRegex.Matches(line);

                foreach (Match match in uriMatches)
                {
                    try
                    {
                        // Attempt to create Uri object from match
                        var uri = new Uri(match.Value);

                        WriteObject(uri);
                    }
                    catch
                    {
                        // Skip invalid URIs silently
                        WriteVerbose($"Invalid URI found: {match.Value}");
                    }
                }
            }
        }

        /// <summary>
        /// End processing
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}