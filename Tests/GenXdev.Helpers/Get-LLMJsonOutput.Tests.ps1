Pester\Describe 'Get-LLMJsonOutput' {

    Pester\It 'Should return clean JSON unchanged' {
        $inputStr = '{"name":"test","value":42}'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '{"name":"test","value":42}'
    }

    Pester\It 'Should strip markdown fences from JSON object' {
        $jsonFence = '```json'
        $fence = '```'
        $inputStr = "${jsonFence}`n{`"result`": `"hello`"}`n${fence}"
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '{"result": "hello"}'
    }

    Pester\It 'Should extract JSON object from surrounding commentary' {
        $inputStr = 'Here is the answer: {"key": "value"} Hope that helps.'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '{"key": "value"}'
    }

    Pester\It 'Should extract JSON array from surrounding text' {
        $inputStr = 'Results: ["a", "b", "c"] done.'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '["a", "b", "c"]'
    }

    Pester\It 'Should extract nested JSON object' {
        $inputStr = 'Output: {"outer":{"inner":{"key":"val"}}} end'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '{"outer":{"inner":{"key":"val"}}}'
    }

    Pester\It 'Should use schema to guide object extraction' {
        $schema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'response'
                strict = $true
                schema = @{
                    type       = 'object'
                    properties = @{
                        explanation      = @{ type = 'string' }
                        suggestedCmdline = @{ type = 'string' }
                    }
                    required   = @('explanation', 'suggestedCmdline')
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress

        $inputStr = 'Some text here {"explanation":"do stuff","suggestedCmdline":"Get-Process"} trailing'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr -ResponseFormat $schema
        $result | Pester\Should -BeExactly '{"explanation":"do stuff","suggestedCmdline":"Get-Process"}'
    }

    Pester\It 'Should use schema to guide array extraction' {
        $schema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'response'
                strict = $true
                schema = @{
                    type  = 'array'
                    items = @{ type = 'string' }
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress

        $inputStr = 'List: ["item1", "item2"] end'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr -ResponseFormat $schema
        $result | Pester\Should -BeExactly '["item1", "item2"]'
    }

    Pester\It 'Should extract quoted string via heuristic' {
        $inputStr = 'The value is "extracted-string" in the middle'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '"extracted-string"'
    }

    Pester\It 'Should extract number via heuristic' {
        $inputStr = 'The count is 42 items total.'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '42'
    }

    Pester\It 'Should extract negative number' {
        $inputStr = 'Temperature is -15.5 degrees'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '-15.5'
    }

    Pester\It 'Should extract boolean true' {
        $inputStr = 'enabled: true, configured: yes'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly 'true'
    }

    Pester\It 'Should extract boolean false' {
        $inputStr = 'The flag is false in the config'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly 'false'
    }

    Pester\It 'Should extract date-time via schema' {
        $schema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'response'
                strict = $true
                schema = @{
                    type   = 'string'
                    format = 'date-time'
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress

        $inputStr = 'Timestamp: 2026-07-20T14:30:00Z some text'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr -ResponseFormat $schema
        $result | Pester\Should -BeExactly '"2026-07-20T14:30:00Z"'
    }

    Pester\It 'Should return original text if no JSON found' {
        $inputStr = 'This is just plain text with nothing structured.'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly 'This is just plain text with nothing structured.'
    }

    Pester\It 'Should handle JSON with markdown fences and surrounding text' {
        $jsonFence = '```json'
        $fence = '```'
        $inputStr = "Sure! here's the command:`n${jsonFence}`n{`"explanation`": `"list files`", `"suggestedCmdline`": `"Get-ChildItem`"}`n${fence}"
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '{"explanation": "list files", "suggestedCmdline": "Get-ChildItem"}'
    }

    Pester\It 'Should prefer object over array when both present' {
        $inputStr = 'Array first: [1,2,3] then object: {"a":1}'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '{"a":1}'
    }

    Pester\It 'Should handle scientific notation number' {
        $inputStr = 'Result: 1.5e10 units'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '1.5e10'
    }

    Pester\It 'Should extract number when schema type is integer' {
        $schema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'response'
                strict = $true
                schema = @{
                    type = 'integer'
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress

        $inputStr = 'Count: 99 results'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr -ResponseFormat $schema
        $result | Pester\Should -BeExactly '99'
    }

    Pester\It 'Should extract boolean via schema' {
        $schema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'response'
                strict = $true
                schema = @{
                    type = 'boolean'
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress

        $inputStr = 'Success: true, everything worked.'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr -ResponseFormat $schema
        $result | Pester\Should -BeExactly 'true'
    }

    Pester\It 'Should handle empty object' {
        $inputStr = 'Data: {} end'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '{}'
    }

    Pester\It 'Should handle empty array' {
        $inputStr = 'List: [] done'
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr
        $result | Pester\Should -BeExactly '[]'
    }

    Pester\It 'Should strip markdown fences when schema is provided' {
        $schema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'response'
                strict = $true
                schema = @{
                    type       = 'object'
                    properties = @{
                        explanation      = @{ type = 'string' }
                        suggestedCmdline = @{ type = 'string' }
                    }
                    required   = @('explanation', 'suggestedCmdline')
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress

        $jsonFence = '```json'
        $fence = '```'
        $inputStr = "${jsonFence}`n{`"explanation`": `"list files`", `"suggestedCmdline`": `"Get-ChildItem`"}`n${fence}"
        $result = GenXdev\Get-LLMJsonOutput -Text $inputStr -ResponseFormat $schema
        $result | Pester\Should -BeExactly '{"explanation": "list files", "suggestedCmdline": "Get-ChildItem"}'
    }

}
