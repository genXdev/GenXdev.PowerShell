using System.Management.Automation;

namespace GenXdev.Helpers
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Removes comments from JSON content.
.DESCRIPTION
* Processes JSON content and removes both single-line and multi-line
  comments while preserving the JSON structure.
* Useful for cleaning up JSON files that contain documentation comments
  before parsing.
* Supports both single-line comments (//) and multi-line comments (/* */).

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
$jsonContent = @'
{
    // This is a comment
    ""name"": ""test"", /* inline comment */
    ""value"": 123
}
'@ -split ""`n""
Remove-JSONComments -Json $jsonContent
```

Removes comments from JSON content stored in a variable.
.EXAMPLE
```powershell
$jsonContent | Remove-JSONComments
```

Processes JSON content from the pipeline.
")]
    [Cmdlet(VerbsCommon.Remove, "JSONComments")]
    [OutputType(typeof(string))]
    public class RemoveJSONCommentsCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The JSON content to process as a string array. Each element represents a line of JSON content.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "JSON content to process as string array"
        )]
        public string Json { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting JSON comment removal process");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Remove comments from json using the helper class
            WriteObject(Serialization.RemoveJSONComments(Json));
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            WriteVerbose("Completed JSON comment removal process");
        }
    }
}