Pester\Describe 'Get-JsonExampleFromSchema' {

    Pester\It 'Should produce a flat object example' {
        $schema = @{
            type       = 'object'
            properties = [ordered]@{
                name = @{ type = 'string'; description = 'The user name' }
                age  = @{ type = 'integer' }
            }
        }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '{"name":"The user name","age":0}'
    }

    Pester\It 'Should unwrap OpenAI json_schema wrapper' {
        $openAiSchema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'response'
                strict = $true
                schema = @{
                    type       = 'object'
                    properties = @{
                        result = @{ type = 'string' }
                    }
                }
            }
        }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $openAiSchema
        $result | Pester\Should -BeExactly '{"result":"..."}'
    }

    Pester\It 'Should handle nested object with array of objects' {
        $schema = @{
            type       = 'object'
            properties = [ordered]@{
                items = @{
                    type  = 'array'
                    items = @{
                        type       = 'object'
                        properties = [ordered]@{
                            id    = @{ type = 'integer' }
                            label = @{ type = 'string' }
                        }
                    }
                }
            }
        }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '{"items":[{"id":0,"label":"..."}]}'
    }

    Pester\It 'Should handle top-level array schema' {
        $schema = @{
            type  = 'array'
            items = @{
                type       = 'object'
                properties = [ordered]@{
                    filename = @{ type = 'string' }
                    size     = @{ type = 'integer' }
                }
            }
        }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '[{"filename":"...","size":0}]'
    }

    Pester\It 'Should handle scalar string type' {
        $schema = @{ type = 'string' }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '"..."'
    }

    Pester\It 'Should handle scalar integer type' {
        $schema = @{ type = 'integer' }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '0'
    }

    Pester\It 'Should handle scalar boolean type' {
        $schema = @{ type = 'boolean' }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly 'true'
    }

    Pester\It 'Should handle enum values' {
        $schema = @{
            type = 'string'
            enum = @('low', 'medium', 'high')
        }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '"low"'
    }

    Pester\It 'Should handle date-time format hint' {
        $schema = @{
            type   = 'string'
            format = 'date-time'
        }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '"2024-01-15T10:30:00Z"'
    }

    Pester\It 'Should handle date format hint' {
        $schema = @{
            type   = 'string'
            format = 'date'
        }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '"2024-01-15"'
    }

    Pester\It 'Should handle email format hint' {
        $schema = @{
            type   = 'string'
            format = 'email'
        }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '"user@example.com"'
    }

    Pester\It 'Should handle oneOf by picking the first option' {
        $schema = @{
            oneOf = @(
                @{ type = 'string' }
                @{ type = 'integer' }
            )
        }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '"..."'
    }

    Pester\It 'Should handle union type like ["string","null"]' {
        $schema = @{
            type = @('string', 'null')
        }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '"..."'
    }

    Pester\It 'Should handle const value' {
        $schema = @{ const = 'fixed-value' }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '"fixed-value"'
    }

    Pester\It 'Should handle empty schema with fallback' {
        $result = GenXdev\Get-JsonExampleFromSchema -Schema @{}
        $result | Pester\Should -BeExactly '{"response":"..."}'
    }

    Pester\It 'Should handle null schema input' {
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $null
        $result | Pester\Should -BeExactly '{"response":"..."}'
    }

    Pester\It 'Should accept hashtable input' {
        $schema = @{ type = 'string' }
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $schema
        $result | Pester\Should -BeExactly '"..."'
    }

    Pester\It 'Should accept JSON string input' {
        $json = '{ "type": "boolean" }'
        $result = GenXdev\Get-JsonExampleFromSchema -Schema $json
        $result | Pester\Should -BeExactly 'true'
    }
}
