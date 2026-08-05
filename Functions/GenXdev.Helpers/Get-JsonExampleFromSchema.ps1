<###############################################################################
.SYNOPSIS
Generates a human-readable example JSON string from a JSON Schema definition.

.DESCRIPTION
Converts any JSON Schema (OpenAI json_schema format or raw schema) into a
compact example JSON string suitable for injecting into LLM system
instructions. Handles nested objects, arrays, scalar types, enums, unions,
oneOf/anyOf/allOf compositions, and format hints like date-time and email.

The function builds a PowerShell object tree by recursively walking the
schema, then serializes it to a compact JSON string via ConvertTo-Json.

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

.PARAMETER Schema
A JSON Schema definition. Accepts either a JSON string or a pre-parsed
PSCustomObject. Supports both the OpenAI json_schema wrapper format
({ json_schema: { schema: ... } }) and raw JSON Schema objects.

.EXAMPLE
$schema = '{ "type": "object", "properties": { "name": { "type": "string" } } }'
Get-JsonExampleFromSchema -Schema $schema

Generates: {"name":"..."}

.EXAMPLE
$openAiSchema = '{ "type": "json_schema", "json_schema": { "name": "response",
"strict": true, "schema": { "type": "object", "properties": {
"items": { "type": "array", "items": { "type": "object", "properties": {
"id": { "type": "integer" }, "label": { "type": "string" } } } } } } } }'
Get-JsonExampleFromSchema -Schema $openAiSchema

Generates: {"items":[{"id":0,"label":"..."}]}
#>
###############################################################################
function Get-JsonExampleFromSchema {

    [CmdletBinding()]
    [OutputType([string])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', '')]
    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'A JSON Schema definition (JSON string or ' +
                'PSCustomObject). Supports OpenAI json_schema wrapper ' +
                'format and raw JSON Schema objects.'
        )]
        [object] $Schema
        #######################################################################
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Starting JSON Schema to example conversion.')

        # Recursively build an example PowerShell value from a schema node.
        # Returns a PS value: hashtable (object), array, string, int, bool,
        # or $null.
        function BuildExample($node, [int] $depth = 0) {

            # Guard against runaway recursion
            if ($depth -gt 10) {
                return '...'
            }

            # Unwrap PSObject to its base object.
            # Guard: PSCustomObject inherits from PSObject and has
            # no meaningful BaseObject ($null), so only unwrap when
            # BaseObject is a concrete type.
            if ($node -is [System.Management.Automation.PSObject] -and
                $null -ne $node.BaseObject) {
                $node = $node.BaseObject
            }

            # Handle null / empty input
            if ($null -eq $node) {
                return @{ response = '...' }
            }

            # If it's a string, try to parse as JSON
            if ($node -is [string]) {
                $trimmed = $node.Trim()
                if ([string]::IsNullOrWhiteSpace($trimmed)) {
                    return '...'
                }
                try {
                    $node = $trimmed |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json
                }
                catch {
                    return '...'
                }
            }

            # Auto-detect OpenAI json_schema wrapper and unwrap it
            if ($node.json_schema -and $node.json_schema.schema) {
                $node = $node.json_schema.schema
            }

            # ── Type Dispatch ──────────────────────────────────────────

            # 1. enum — use the first enum value
            if ($node.enum) {
                $enums = @($node.enum)
                if ($enums.Count -gt 0) {
                    return $enums[0]
                }
            }

            # 2. const — use the const value directly
            if ($null -ne $node.const) {
                return $node.const
            }

            # 3. oneOf / anyOf — use the first schema option
            if ($node.oneOf) {
                $options = @($node.oneOf)
                if ($options.Count -gt 0) {
                    return BuildExample $options[0] ($depth + 1)
                }
            }
            if ($node.anyOf) {
                $options = @($node.anyOf)
                if ($options.Count -gt 0) {
                    return BuildExample $options[0] ($depth + 1)
                }
            }

            # 4. allOf — merge all sub-schemas into a single object
            if ($node.allOf) {
                $merged = [ordered]@{}
                foreach ($sub in @($node.allOf)) {
                    $subResult = BuildExample $sub ($depth + 1)
                    if ($subResult -is [hashtable]) {
                        foreach ($key in $subResult.Keys) {
                            $merged[$key] = $subResult[$key]
                        }
                    }
                }
                if ($merged.Count -gt 0) {
                    return $merged
                }
                # Fall through if allOf produced nothing
            }

            # 5. Resolve the effective type, handling union type arrays
            #    (e.g. ["string", "null"])
            $effectiveType = $node.type
            if ($effectiveType -is [array] -or
                $effectiveType -is [object[]]) {

                # Pick the first non-null type
                foreach ($t in $effectiveType) {
                    if ($t -ne 'null') {
                        $effectiveType = "$t"
                        break
                    }
                }
                # If all were null, keep it as null
                if ($effectiveType -is [array]) {
                    $effectiveType = 'null'
                }
            }

            # 6. object type (has properties or explicit type).
            # Use a helper to safely detect a real schema properties
            # collection, avoiding false positives from PSObject intrinsic
            # members when the node is a wrapped PSCustomObject.
            $hasRealProperties = _HasSchemaProperties $node
            if ($effectiveType -eq 'object' -or $hasRealProperties) {

                $result = [ordered]@{}
                if ($node.properties) {
                    $props = $node.properties
                    if ($props -is [System.Management.Automation.PSObject]) {
                        $props = $props.PSObject.Properties
                    }
                    if ($props -is [System.Collections.IDictionary]) {
                        foreach ($key in $props.Keys) {
                            $result["$key"] = BuildExample $props[$key] ($depth + 1)
                        }
                    }
                    else {
                        foreach ($prop in $props) {
                            $propName = if ($prop -is
                                [System.Management.Automation.PSPropertyInfo]) {
                                $prop.Name
                            }
                            else {
                                $prop.Key
                            }
                            $propValue = if ($prop -is
                                [System.Management.Automation.PSPropertyInfo]) {
                                $prop.Value
                            }
                            else {
                                $prop.Value
                            }
                            $result["$propName"] = BuildExample $propValue ($depth + 1)
                        }
                    }
                }
                return $result
            }

            # 7. array type
            if ($effectiveType -eq 'array') {
                # Comma prefix prevents PowerShell from unrolling the array
                # during function output. Without it, return @($x) unrolls
                # and the caller gets a single element, not an array.
                if ($node.items) {
                    return , @(BuildExample $node.items ($depth + 1))
                }
                return , @()
            }

            # 8. string type (with optional format hints)
            if ($effectiveType -eq 'string') {
                if ($node.format) {
                    switch -Regex ($node.format) {
                        '^date-time$' {
                            return '2024-01-15T10:30:00Z'
                        }
                        '^date$' {
                            return '2024-01-15'
                        }
                        '^email$' {
                            return 'user@example.com'
                        }
                        '^uri$|^url$' {
                            return 'https://example.com'
                        }
                        '^uuid$' {
                            return '550e8400-e29b-41d4-a716-446655440000'
                        }
                        '^ipv4$' {
                            return '192.168.1.1'
                        }
                        '^ipv6$' {
                            return '::1'
                        }
                        '^hostname$' {
                            return 'example.com'
                        }
                        '^json-pointer$' {
                            return '/path/to/property'
                        }
                        '^regex$' {
                            return '^[a-z]+$'
                        }
                        default {
                            if ($node.description) {
                                return "$($node.description)"
                            }
                            return '...'
                        }
                    }
                }
                if ($node.description) {
                    return "$($node.description)"
                }
                return '...'
            }

            # 9. number / integer
            if ($effectiveType -eq 'number' -or
                $effectiveType -eq 'integer') {

                if ($node.description) {
                    return "$($node.description)"
                }
                return 0
            }

            # 10. boolean
            if ($effectiveType -eq 'boolean') {
                return $true
            }

            # 11. null
            if ($effectiveType -eq 'null') {
                return $null
            }

            # 12. Fallback — unknown or missing type, return a default object
            if ($node.description) {
                return "$($node.description)"
            }
            return @{ response = '...' }
        }

        # Helper: returns $true when $node has a real schema properties
        # collection (a Hashtable with keys), avoiding false positives
        # from PSObject intrinsic ".Properties" member on PSCustomObjects.
        function _HasSchemaProperties($node) {
            if ($null -eq $node) { return $false }
            if ($node -is [System.Management.Automation.PSObject]) {
                $node = $node.BaseObject
            }
            # Only dictionary types can have .properties as a key lookup
            if ($node -isnot [System.Collections.IDictionary]) {
                return $false
            }
            $props = $node['properties']
            return ($props -is [System.Collections.IDictionary]) -and
                ($props.Keys.Count -gt 0)
        }

        # Serializes a schema node to JSON string and writes it to output.
        function ConvertAndEmit($schemaNode) {
            $exampleValue = BuildExample $schemaNode 0

            if ($exampleValue -is [string]) {
                $json = '"' + (
                    $exampleValue -replace '\\', '\\\\' -replace '"', '\\"'
                ) + '"'
            }
            elseif ($null -eq $exampleValue) {
                $json = 'null'
            }
            elseif ($exampleValue -is [bool]) {
                $json = if ($exampleValue) { 'true' } else { 'false' }
            }
            elseif ($exampleValue -is [int] -or
                $exampleValue -is [long] -or
                $exampleValue -is [double]) {
                $json = [string] $exampleValue
            }
            else {
                # Hashtable, array, or PSCustomObject — use ConvertTo-Json
                # with -InputObject to preserve array structure.
                $json = Microsoft.PowerShell.Utility\ConvertTo-Json `
                    -InputObject $exampleValue `
                    -Depth 20 -Compress `
                    -WarningAction SilentlyContinue `
                    -ErrorAction SilentlyContinue

                if ([string]::IsNullOrWhiteSpace($json)) {
                    $json = '{"response":"..."}'
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Generated schema example: $json")
            return $json
        }
    }

    end {
        if ($null -eq $Schema) {
            return '{"response":"..."}'
        }

        # Normalize: unwrap PSObject wrapping
        $schemaNode = $Schema
        if ($schemaNode -is [System.Management.Automation.PSObject]) {
            $base = $schemaNode.BaseObject
            if ($base -is [System.Collections.IDictionary]) {
                $schemaNode = $base
            }
        }

        try {
            ConvertAndEmit $schemaNode
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Schema example generation failed: $($_.Exception.Message)")
            '{"response":"..."}'
        }
    }
}
###############################################################################