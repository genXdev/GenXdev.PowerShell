###############################################################################
# Part of PowerShell module : GenXdev.AI
# Original cmdlet filename  : Set-AILLMSettings.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.33.0
###############################################################################

Pester\Describe 'Set-AILLMSettings' {

    Pester\BeforeAll {
        $allTypes = @(
            'SimpleIntelligence', 'Knowledge', 'Pictures',
            'TextTranslation', 'Coding', 'ToolUse'
        )
        $allProps = @(
            'Model', 'ApiEndpoint', 'ApiKey',
            'NoSupportForJsonSchema', 'NoSupportForImageUpload', 'NoSupportForToolCalls'
        )
        foreach ($t in $allTypes) {
            foreach ($p in $allProps) {
                $varName = "AILLMSettings_${t}_${p}"
                if (Microsoft.PowerShell.Utility\Get-Variable -Name $varName -Scope Global -ErrorAction SilentlyContinue) {
                    Microsoft.PowerShell.Utility\Set-Variable -Name $varName -Value $null -Scope Global
                }
            }
        }

        # Pre-configure one LLM type so Get-AILLMSettings cross-type
        # fallback resolves without firing the interactive prompt
        $null = GenXdev\Set-AILLMSettings -LLMQueryType 'Coding' `
            -Model 'test-bootstrap-model' `
            -ApiEndpoint 'https://test-bootstrap.example.com/v1' `
            -ApiKey 'sk-test-bootstrap'
    }

    Pester\AfterAll {
    }

    Pester\AfterEach {
        foreach ($t in $allTypes) {
            foreach ($p in $allProps) {
                $varName = "AILLMSettings_${t}_${p}"
                if (Microsoft.PowerShell.Utility\Get-Variable -Name $varName -Scope Global -ErrorAction SilentlyContinue) {
                    Microsoft.PowerShell.Utility\Set-Variable -Name $varName -Value $null -Scope Global
                }
            }
        }
    }

    Pester\It 'SessionOnly stores and retrieves settings from session' {
        GenXdev\Set-AILLMSettings -LLMQueryType SimpleIntelligence `
            -Model 'session-test-model' `
            -ApiEndpoint 'https://session.example.com/v1' `
            -ApiKey 'sk-session-key' `
            -SessionOnly

        $result = GenXdev\Get-AILLMSettings -LLMQueryType SimpleIntelligence

        $result.Model | Pester\Should -Be 'session-test-model'
        $result.ApiEndpoint | Pester\Should -Be 'https://session.example.com/v1'
        $result.ApiKey | Pester\Should -Be 'sk-session-key'
    }

    Pester\It 'SessionOnly does not persist to preferences' {
        GenXdev\Set-AILLMSettings -LLMQueryType Knowledge `
            -Model 'session-only-model' `
            -ApiEndpoint 'https://session-only.example.com/v1' `
            -ApiKey 'sk-session-only' `
            -SessionOnly

        # check prefs via SkipSession — should NOT find the
        # session-only model in the preferences DB
        $result = GenXdev\Get-AILLMSettings -LLMQueryType Knowledge -SkipSession

        $result.Model | Pester\Should -Not -Be 'session-only-model'
    }

    Pester\It 'Persistent storage is retrievable' {
        GenXdev\Set-AILLMSettings -LLMQueryType Coding `
            -Model 'persistent-model' `
            -ApiEndpoint 'https://persistent.example.com/v1' `
            -ApiKey 'sk-persistent-key' `
            -NoSupportForImageUpload

        $result = GenXdev\Get-AILLMSettings -LLMQueryType Coding

        $result.Model | Pester\Should -Be 'persistent-model'
        $result.ApiEndpoint | Pester\Should -Be 'https://persistent.example.com/v1'
        $result.ApiKey | Pester\Should -Be 'sk-persistent-key'
        $result.NoSupportForImageUpload | Pester\Should -BeTrue
    }

    Pester\It 'Sets ManuallyConfigured flag in temp database' {
        GenXdev\Set-AILLMSettings -LLMQueryType TextTranslation `
            -Model 'translation-model' `
            -ApiEndpoint 'https://translation.example.com/v1' `
            -ApiKey 'sk-translation-key'

        $isConfigured = GenXdev\Get-GenXdevPreference `
            -Name 'AILLMSettings_TextTranslation_ManuallyConfigured'

        # Get-GenXdevPreference may return string 'True' or boolean $true
        ($isConfigured -eq $true -or $isConfigured -eq 'True') | Pester\Should -BeTrue
    }

    Pester\It 'ClearSession removes session variables' {
        GenXdev\Set-AILLMSettings -LLMQueryType ToolUse `
            -Model 'before-clear' `
            -ApiEndpoint 'https://before-clear.example.com/v1' `
            -ApiKey 'sk-before-clear' `
            -SessionOnly

        GenXdev\Set-AILLMSettings -LLMQueryType ToolUse -ClearSession

        $result = GenXdev\Get-AILLMSettings -LLMQueryType ToolUse -SessionOnly

        $result.Model | Pester\Should -Be $null
        $result.ApiEndpoint | Pester\Should -Be $null
        $result.ApiKey | Pester\Should -Be $null
    }

    Pester\It 'Throws when no setting parameters are provided' {
        { GenXdev\Set-AILLMSettings -LLMQueryType SimpleIntelligence -ErrorAction Stop } |
            Pester\Should -Throw
    }

    Pester\It 'Throws when ApiEndpoint is provided without ApiKey in persistent mode' {
        { GenXdev\Set-AILLMSettings -LLMQueryType SimpleIntelligence `
                -ApiEndpoint 'https://no-key.example.com/v1' `
                -ErrorAction Stop } | Pester\Should -Throw
    }

    Pester\It 'Accepts all 6 LLMQueryType values without throwing' {
        $types = @(
            'SimpleIntelligence', 'Knowledge', 'Pictures',
            'TextTranslation', 'Coding', 'ToolUse'
        )
        foreach ($type in $types) {
            { GenXdev\Set-AILLMSettings -LLMQueryType $type `
                    -Model 'all-types-model' `
                    -ApiEndpoint 'https://all-types.example.com/v1' `
                    -ApiKey 'sk-all-types' `
                    -SessionOnly -ErrorAction Stop } |
                Pester\Should -Not -Throw
        }
    }

    Pester\It 'All switch parameters are stored and retrieved' {
        GenXdev\Set-AILLMSettings -LLMQueryType SimpleIntelligence `
            -Model 'switch-model' `
            -ApiEndpoint 'https://switch.example.com/v1' `
            -ApiKey 'sk-switch-key' `
            -NoSupportForJsonSchema `
            -NoSupportForImageUpload `
            -NoSupportForToolCalls `
            -SessionOnly

        $result = GenXdev\Get-AILLMSettings -LLMQueryType SimpleIntelligence

        $result.NoSupportForJsonSchema | Pester\Should -BeTrue
        $result.NoSupportForImageUpload | Pester\Should -BeTrue
        $result.NoSupportForToolCalls | Pester\Should -BeTrue
    }

    ###########################################################################
    Pester\It ('-PromptForSettings delegates to Invoke-AILLMSettingsPrompt ' + `
            'which throws in non-interactive session') {
        {
            GenXdev\Set-AILLMSettings -LLMQueryType 'Coding' `
                -PromptForSettings -NonInteractive -SessionOnly -ErrorAction Stop
        } | Pester\Should -Throw -ExpectedMessage '*non-interactive*'
    }
}
