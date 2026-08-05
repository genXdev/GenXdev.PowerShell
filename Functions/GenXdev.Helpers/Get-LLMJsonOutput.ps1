###############################################################################
<#
.SYNOPSIS
Extracts valid JSON from LLM response text using best-effort heuristics.

.DESCRIPTION
Takes raw LLM response text that may contain markdown fences, commentary, or
other non-JSON content and attempts to extract clean, valid JSON from it.
Uses a multi-step strategy: first strips markdown fences, then attempts to
parse the entire string as JSON, and if that fails, uses schema-guided
extraction followed by heuristic fallbacks.

The function handles:
- Markdown code fences (```json ... ```)
- JSON objects ({...}) and arrays ([...])
- Strings, numbers, booleans, and date-time values
- Schema-guided extraction using json_schema type hints

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

.PARAMETER Text
The raw text to extract JSON from. Typically an LLM response that may contain
markdown fences or surrounding commentary.

.PARAMETER ResponseFormat
Optional JSON schema string (OpenAI json_schema format) used to guide
extraction. When provided, the schema's type field is used to determine
which JSON structure to look for (object, array, string, number, boolean).

.EXAMPLE
Get-LLMJsonOutput -Text '```json
{"result": "hello"}
```'

Extracts: {"result": "hello"}

.EXAMPLE
$schema = '{"type":"json_schema","json_schema":{"name":"r","schema":{"type":"object"}}}'
Get-LLMJsonOutput -Text 'The answer is {"key": "value"}' -ResponseFormat $schema

Extracts: {"key": "value"}
#>
function Get-LLMJsonOutput {

    [CmdletBinding()]
    [OutputType([string])]
    param (
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The raw text to extract JSON from'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Text,
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('Optional JSON schema string to guide ' +
                'extraction (OpenAI json_schema format)')
        )]
        [string] $ResponseFormat
        #######################################################################
    )

    begin {
        $cleaned = $Text
    }

    process {

        # Strip markdown fences first (```json ... ```)
        $candidate = [regex]::Replace($cleaned,
            '```(?:json)?\s*([\s\S]*?)\s*```', '$1')
        if ($candidate -ne $cleaned) {
            $cleaned = $candidate
        }

        # Step 1: Try parsing the whole string as JSON
        try {
            $null = $cleaned |
                Microsoft.PowerShell.Utility\ConvertFrom-Json `
                    -ErrorAction Stop
            # Success — $cleaned is already valid JSON
        }
        catch {
            # Step 2: If we have a schema, use its type to guide
            # extraction; otherwise try heuristics.
            $extracted = $null
            if ($ResponseFormat) {
                try {
                    $schema = ($ResponseFormat |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json `
                            -ErrorAction Stop).json_schema.schema
                    switch ($schema.type) {
                        'object' {
                            $a = $cleaned.IndexOf('{')
                            $b = $cleaned.LastIndexOf('}')
                            if ($a -ge 0 -and $b -gt $a) {
                                $extracted = $cleaned.Substring(
                                    $a, ($b - $a) + 1)
                            }
                        }
                        'array' {
                            $a = $cleaned.IndexOf('[')
                            $b = $cleaned.LastIndexOf(']')
                            if ($a -ge 0 -and $b -gt $a) {
                                $extracted = $cleaned.Substring(
                                    $a, ($b - $a) + 1)
                            }
                        }
                        'string' {
                            # Check for date/time format hints
                            if ($schema.format -match
                                '^date(-time)?$') {
                                if ($cleaned -match
                                    '(\d{4}-\d{2}-\d{2}(?:T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})?)?)') {
                                    $extracted = '"' + $matches[1] + '"'
                                }
                            }
                            else {
                                $a = $cleaned.IndexOf('"')
                                $b = $cleaned.LastIndexOf('"')
                                if ($a -ge 0 -and $b -gt $a) {
                                    $extracted = $cleaned.Substring(
                                        $a, ($b - $a) + 1)
                                }
                            }
                        }
                        { $_ -in @('number', 'integer') } {
                            if ($cleaned -match
                                '(-?\d+\.?\d*(?:[eE][+-]?\d+)?)') {
                                $extracted = $matches[1]
                            }
                        }
                        'boolean' {
                            if ($cleaned -match '\b(true|false)\b') {
                                $extracted = $matches[1]
                            }
                        }
                    }
                }
                catch {
                    # Schema parse failed, fall through to heuristics
                }
            }
            # Step 3: No schema or schema didn't help — try
            # { } first, then [ ], then regex for string,
            # then regex for number.
            if (-not $extracted) {
                $a = $cleaned.IndexOf('{')
                $b = $cleaned.LastIndexOf('}')
                if ($a -ge 0 -and $b -gt $a) {
                    $extracted = $cleaned.Substring(
                        $a, ($b - $a) + 1)
                }
                else {
                    $a = $cleaned.IndexOf('[')
                    $b = $cleaned.LastIndexOf(']')
                    if ($a -ge 0 -and $b -gt $a) {
                        $extracted = $cleaned.Substring(
                            $a, ($b - $a) + 1)
                    }
                    elseif ($cleaned -match
                        '"((?:[^"\\]|\\.)*)"') {
                        $extracted = $matches[0]
                    }
                    elseif ($cleaned -match
                        '(\d{4}-\d{2}-\d{2}(?:T\d{2}:\d{2}:\d{2}(?:\.\d+)?(?:Z|[+-]\d{2}:\d{2})?)?)') {
                        $extracted = '"' + $matches[1] + '"'
                    }
                    elseif ($cleaned -match
                        '(-?\d+\.?\d*(?:[eE][+-]?\d+)?)') {
                        $extracted = $matches[1]
                    }
                    elseif ($cleaned -match
                        '\b(true|false)\b') {
                        $extracted = $matches[1]
                    }
                }
            }
            # Validate the extracted candidate
            if ($extracted) {
                try {
                    $null = $extracted |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json `
                            -ErrorAction Stop
                    $cleaned = $extracted
                }
                catch {
                    # Not valid, keep original $cleaned
                }
            }
        }

        # Return the cleaned JSON string
        Microsoft.PowerShell.Utility\Write-Output $cleaned
    }

    end {
    }
    ###########################################################################
}