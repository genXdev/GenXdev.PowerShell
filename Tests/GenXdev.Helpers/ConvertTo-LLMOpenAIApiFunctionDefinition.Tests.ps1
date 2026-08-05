Pester\Describe 'ConvertTo-LLMOpenAIApiFunctionDefinition' {

    Pester\It 'Should check my sanity' {

        $number = 123;

        $callback = {

            param($a, $b, $c)

            return (@($a, $b, $c, $number) | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -WarningAction SilentlyContinue)

        }.GetNewClosure();

        $callback.getType().FullName | Pester\Should -BeExactly 'System.Management.Automation.ScriptBlock'

        $params = @{
            c = 3
            a = 1
        }

        $params.getType().FullName | Pester\Should -BeExactly 'System.Collections.Hashtable'

        $result = & $callback @params

        $result | Pester\Should -Be (@(1, $null, 3, $number) | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -WarningAction SilentlyContinue)
    }

    Pester\It 'Should invoke function properly' {

        $converted = GenXdev\ConvertTo-LLMOpenAIApiFunctionDefinition `
            -ExposedCmdLets @(
            @{
                Name          = 'Get-ChildItem'
                AllowedParams = @('Path=string')
                Confirm       = $false
            }
        )

        $functionDefinition = $converted.function

        $functionDefinition | Pester\Should -Not -Be $null

        $callback = $functionDefinition.callback;

        $callback | Pester\Should -BeOfType [System.Management.Automation.CommandInfo]

        # Convert dictionary to proper parameter hashtable
        $params = @{'Path' = "$PSScriptRoot" }

        Microsoft.PowerShell.Utility\Write-Verbose "Final parameter hashtable: $($params | Microsoft.PowerShell.Utility\ConvertTo-Json -WarningAction SilentlyContinue)"

        # Use $functionDefinition instead of undefined $matchedFunc
        $callbackResult = & $callback @params | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -WarningAction SilentlyContinue
        $callbackResult | Pester\Should -BeLike '*ConvertTo-LLMOpenAIApiFunctionDefinition.Tests.ps1*'
    }

    Pester\Context 'Parameter alias matching' {

        Pester\It 'Should match AllowedParams by parameter alias (Get-ChildItem PSPath)' {
            # Get-ChildItem -Path has alias 'PSPath'
            $converted = GenXdev\ConvertTo-LLMOpenAIApiFunctionDefinition `
                -ExposedCmdLets @(
                @{
                    Name          = 'Get-ChildItem'
                    AllowedParams = @('PSPath=string')
                    Confirm       = $false
                }
            )

            $funcDef = $converted.function
            $funcDef | Pester\Should -Not -Be $null

            # The parameters property should use the real parameter name
            # 'LiteralPath', not the alias 'PSPath'.
            # (Both Path and LiteralPath share the PSPath alias;
            #  Get-CmdletMetaData returns LiteralPath first.)
            $props = $funcDef.parameters.properties
            $props | Pester\Should -Not -Be $null
            $props.Keys | Pester\Should -Not -Contain 'PSPath'
            # 'LiteralPath' matches first; 'Path' is also valid
            ($props.Keys -contains 'Path' -or
                $props.Keys -contains 'LiteralPath') |
                Pester\Should -BeTrue
            $props.LiteralPath.type | Pester\Should -Be 'array'
            $props.LiteralPath.items.type | Pester\Should -Be 'string'
        }

        Pester\It 'Should match Find-Item AllowedParams by alias (SearchMask, Pattern)' {
            # Exact definition from New-LLMTextChat (llmchat)
            # SearchMask -> Name parameter alias
            # Pattern -> Content parameter alias
            $converted = GenXdev\ConvertTo-LLMOpenAIApiFunctionDefinition `
                -ExposedCmdLets @(
                @{
                    Name          = 'GenXdev\Find-Item'
                    AllowedParams = @('SearchMask', 'Pattern')
                    OutputText    = $false
                    Confirm       = $false
                    JsonDepth     = 3
                }
            )

            $funcDef = $converted.function
            $funcDef | Pester\Should -Not -Be $null

            # Verify top-level structure (type is at outer level, not
            # inside the 'function' sub-hashtable)
            $converted.type | Pester\Should -Be 'function'
            $funcDef.name | Pester\Should -Be 'Find-Item'
            $funcDef.description | Pester\Should -Not -BeNullOrEmpty

            # Verify parameters structure
            $params = $funcDef.parameters
            $params.type | Pester\Should -Be 'object'

            # Properties should NOT be empty (regression test for alias bug)
            $props = $params.properties
            $props | Pester\Should -Not -Be $null
            $props | Pester\Should -BeOfType [System.Collections.Hashtable]
            $props.Count | Pester\Should -BeGreaterThan 0

            # SearchMask alias -> Name parameter
            $props.Keys | Pester\Should -Contain 'Name'
            $props.Name.type | Pester\Should -Be 'array'
            $props.Name.items.type | Pester\Should -Be 'string'

            # Pattern alias -> Content parameter
            $props.Keys | Pester\Should -Contain 'Content'
            $props.Content.type | Pester\Should -Be 'array'
            $props.Content.items.type | Pester\Should -Be 'string'

            # Callback should be present (CommandInfo)
            $funcDef.callback | Pester\Should -BeOfType `
                [System.Management.Automation.CommandInfo]

            # Required list should be empty (both params are non-mandatory)
            $params.required.Count | Pester\Should -Be 0
        }

        Pester\It 'Should produce non-empty properties when matching by alias' {
            # Regression test: before the alias fix, AllowedParams
            # using aliases would produce empty properties: {}
            $converted = GenXdev\ConvertTo-LLMOpenAIApiFunctionDefinition `
                -ExposedCmdLets @(
                @{
                    Name          = 'Get-ChildItem'
                    AllowedParams = @('PSPath=string')
                    Confirm       = $false
                }
            )

            $props = $converted.function.parameters.properties
            $props.Count | Pester\Should -BeGreaterThan 0
        }
    }
}