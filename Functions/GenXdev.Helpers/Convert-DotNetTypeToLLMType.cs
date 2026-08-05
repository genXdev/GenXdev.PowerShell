using System.Management.Automation;

namespace GenXdev.Helpers
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Converts .NET type names to LLM (Language Model) type names.
.DESCRIPTION
Takes a .NET type name as input and returns the corresponding simplified type name used in Language Models. It handles common .NET types and provides appropriate type mappings.

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
Convert-DotNetTypeToLLMType -DotNetType ""System.String""
```

Converts a System.String type to its LLM equivalent.
")]
    [Cmdlet(VerbsData.Convert, "DotNetTypeToLLMType")]
    [OutputType(typeof(string))]
    public class ConvertDotNetTypeToLLMTypeCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The .NET type name to convert to an LLM type name
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The .NET type name to convert to an LLM type name")]
        public string DotNetType { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose($"Converting .NET type '{DotNetType}' to LLM type");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Convert the .net type to a simplified llm type using a switch statement
            // Note: For MCP content types, arrays should be treated as objects since 'array' is not a valid MCP content type
            string result = DotNetType switch
            {
                "System.Management.Automation.SwitchParameter" => "boolean",
                "System.Management.Automation.PSObject" => "object",
                "System.String" => "string",
                "System.Int32" => "number",
                "System.Int64" => "number",
                "System.Double" => "number",
                "System.Boolean" => "boolean",
                "System.Object[]" => "object",
                "System.Collections.Generic.List`1" => "object",
                "System.Collections.Hashtable" => "object",
                "System.Collections.Generic.Dictionary`2" => "object",
                _ => "object"
            };

            WriteVerbose($"Converted '{DotNetType}' to '{result}'");

            WriteObject(result);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}