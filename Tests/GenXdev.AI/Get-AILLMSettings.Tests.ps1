###############################################################################
# Part of PowerShell module : GenXdev.AI
# Original cmdlet filename  : Get-AILLMSettings.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.33.0
###############################################################################

Pester\Describe 'Get-AILLMSettings' {

    Pester\BeforeAll {
        # ensure clean slate — clear any leftover session vars for all 6 types
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

        # create a temp empty preferences database to isolate tests
        # that need to bypass persistent preferences without relying
        # on mocking C# cmdlets (which fails for in-module calls)
        $Script:TempDbDir = [System.IO.Path]::Combine(
            $env:TEMP,
            [System.IO.Path]::GetRandomFileName()
        )
        $null = [System.IO.Directory]::CreateDirectory($Script:TempDbDir)
    }

    Pester\AfterAll {
        # clean up the temp preferences database directory
        if ($Script:TempDbDir -and [System.IO.Directory]::Exists($Script:TempDbDir)) {
            [System.IO.Directory]::Delete($Script:TempDbDir, $true)
        }
    }

    Pester\AfterEach {
        # clear any session vars set during a test
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
    }

    Pester\It 'Returns a hashtable' {
        $result = GenXdev\Get-AILLMSettings
        $result | Pester\Should -BeOfType [hashtable]
    }

    Pester\It 'Returns all 6 expected keys' {
        $result = GenXdev\Get-AILLMSettings
        $expectedKeys = @(
            'Model', 'ApiEndpoint', 'ApiKey',
            'NoSupportForJsonSchema', 'NoSupportForImageUpload', 'NoSupportForToolCalls'
        )
        foreach ($key in $expectedKeys) {
            $result.ContainsKey($key) | Pester\Should -BeTrue
        }
    }

    Pester\It 'SessionOnly returns null values when nothing is configured' {
        $result = GenXdev\Get-AILLMSettings -SessionOnly
        $result.Model | Pester\Should -Be $null
        $result.ApiEndpoint | Pester\Should -Be $null
        $result.ApiKey | Pester\Should -Be $null
    }

    Pester\It 'Explicit -Model parameter takes priority' {
        $result = GenXdev\Get-AILLMSettings -Model 'test-model-override'
        $result.Model | Pester\Should -Be 'test-model-override'
    }

    Pester\It 'Explicit -ApiEndpoint parameter takes priority' {
        $result = GenXdev\Get-AILLMSettings -ApiEndpoint 'https://test.example.com/v1'
        $result.ApiEndpoint | Pester\Should -Be 'https://test.example.com/v1'
    }

    Pester\It 'Explicit -ApiKey parameter takes priority' {
        $result = GenXdev\Get-AILLMSettings -ApiKey 'sk-test-key'
        $result.ApiKey | Pester\Should -Be 'sk-test-key'
    }

    Pester\It 'Session variables are retrieved when set' {
        Microsoft.PowerShell.Utility\Set-Variable `
            -Name 'AILLMSettings_SimpleIntelligence_Model' -Value 'session-model' -Scope Global
        Microsoft.PowerShell.Utility\Set-Variable `
            -Name 'AILLMSettings_SimpleIntelligence_ApiEndpoint' -Value 'https://session.example.com' -Scope Global
        Microsoft.PowerShell.Utility\Set-Variable `
            -Name 'AILLMSettings_SimpleIntelligence_ApiKey' -Value 'sk-session-key' -Scope Global

        $result = GenXdev\Get-AILLMSettings -LLMQueryType SimpleIntelligence

        $result.Model | Pester\Should -Be 'session-model'
        $result.ApiEndpoint | Pester\Should -Be 'https://session.example.com'
        $result.ApiKey | Pester\Should -Be 'sk-session-key'
    }

    Pester\It 'SkipSession ignores session variables' {
        Microsoft.PowerShell.Utility\Set-Variable `
            -Name 'AILLMSettings_SimpleIntelligence_Model' -Value 'session-model' -Scope Global

        # with SkipSession + SessionOnly, no defaults, no prefs — everything null
        $result = GenXdev\Get-AILLMSettings -SkipSession -SessionOnly
        $result.Model | Pester\Should -Be $null
    }

    Pester\It 'ClearSession clears session variables' {
        Microsoft.PowerShell.Utility\Set-Variable `
            -Name 'AILLMSettings_SimpleIntelligence_Model' -Value 'before-clear' -Scope Global

        $null = GenXdev\Get-AILLMSettings -ClearSession -SessionOnly

        $after = GenXdev\Get-AILLMSettings -SessionOnly
        $after.Model | Pester\Should -Be $null
    }

    Pester\It 'Pictures query type prefers image-capable provider in defaults' {
        # without -SessionOnly, falls through to defaults
        # Gemini 2.5 Flash has NoSupportForImageUpload = false, should be picked
        $result = GenXdev\Get-AILLMSettings -LLMQueryType Pictures `
            -SuppressAutoPrompt

        $result.Model | Pester\Should -Not -Be $null
        $result.ApiEndpoint | Pester\Should -Not -Be $null
        # first image-capable provider should be picked
        $result.NoSupportForImageUpload | Pester\Should -BeFalse
    }

    Pester\It 'Non-Pictures query type picks first default provider' {
        $result = GenXdev\Get-AILLMSettings -LLMQueryType SimpleIntelligence `
            -SuppressAutoPrompt

        $result.Model | Pester\Should -Not -Be $null
        $result.ApiEndpoint | Pester\Should -Not -Be $null
    }

    Pester\It 'Persistent settings are retrieved from temp database' {
        # store settings in the test DB
        $null = GenXdev\Set-AILLMSettings -LLMQueryType Coding `
            -Model 'test-db-model' `
            -ApiEndpoint 'https://test-db.example.com/v1' `
            -ApiKey 'sk-test-db-key'

        # retrieve with SkipSession so we only read from prefs/defaults
        $result = GenXdev\Get-AILLMSettings -LLMQueryType Coding

        $result.Model | Pester\Should -Be 'test-db-model'
        $result.ApiEndpoint | Pester\Should -Be 'https://test-db.example.com/v1'
        $result.ApiKey | Pester\Should -Be 'sk-test-db-key'
    }

    Pester\It 'Accepts all 6 LLMQueryType values without throwing' {
        $types = @(
            'SimpleIntelligence', 'Knowledge', 'Pictures',
            'TextTranslation', 'Coding', 'ToolUse'
        )
        foreach ($type in $types) {
            { GenXdev\Get-AILLMSettings -LLMQueryType $type -ErrorAction Stop } |
                Pester\Should -Not -Throw
        }
    }

    Pester\It 'Switch parameters are passed through correctly' {
        $result = GenXdev\Get-AILLMSettings `
            -NoSupportForJsonSchema `
            -NoSupportForImageUpload `
            -NoSupportForToolCalls

        $result.NoSupportForJsonSchema | Pester\Should -BeTrue
        $result.NoSupportForImageUpload | Pester\Should -BeTrue
        $result.NoSupportForToolCalls | Pester\Should -BeTrue
    }

    Pester\It 'Default provider null ApiKey stays null, not empty hashtable' {
        # Regression: ConvertTo-HashTable was turning JSON null into @{}
        # which made $allNull false, preventing interactive setup

        # use a temp empty preferences database to prevent real user
        # preferences from leaking into this test — only defaults
        # should be tested here. Mocking Get-GenXdevPreference does
        # not work here because it is a C# cmdlet in the same module.
        $result = GenXdev\Get-AILLMSettings `
            -LLMQueryType SimpleIntelligence `
            -SuppressAutoPrompt `
            -PreferencesDatabasePath $Script:TempDbDir

        # ApiKey should be $null (from JSON null), not an empty hashtable
        $result.ApiKey | Pester\Should -Be $null
        $result.Model | Pester\Should -Not -Be $null
        $result.ApiEndpoint | Pester\Should -Not -Be $null
    }

    Pester\It 'Default provider null values remain null for all null fields' {
        # SimpleIntelligence defaults have ApiKey: null,
        # NoSupportForJsonSchema: false, etc.

        # use a temp empty preferences database to prevent real user
        # preferences from leaking into this test — only defaults
        # should be tested here. Mocking Get-GenXdevPreference does
        # not work here because it is a C# cmdlet in the same module.
        $result = GenXdev\Get-AILLMSettings `
            -LLMQueryType SimpleIntelligence `
            -SuppressAutoPrompt `
            -PreferencesDatabasePath $Script:TempDbDir

        # Boolean false should stay false (not become $null)
        $result.NoSupportForJsonSchema | Pester\Should -BeFalse
        $result.NoSupportForImageUpload | Pester\Should -BeFalse
        $result.NoSupportForToolCalls | Pester\Should -BeFalse

        # Null should stay null (not empty hashtable)
        $result.ApiKey | Pester\Should -Be $null
    }

    Pester\It 'DeepSeek providers have NoSupportForJsonSchema = true' {
        # Canary: if this breaks, default-llmproviders.json was updated and
        # the JsonSchema support flag needs manual verification
        $defaults = GenXdev\Get-AIDefaultLLMSettings -LLMQueryType SimpleIntelligence
        $deepSeekModels = $defaults | Microsoft.PowerShell.Core\Where-Object { $_.Model -like 'deepseek*' }
        $deepSeekModels.Count | Pester\Should -BeGreaterThan 0
        foreach ($ds in $deepSeekModels) {
            $ds.NoSupportForJsonSchema | Pester\Should -BeTrue `
                -Because "DeepSeek $($ds.Model) — verify manually if this changed"
        }
    }

    Pester\It 'DeepSeek providers have NoSupportForImageUpload = true' {
        # Canary: if this breaks, default-llmproviders.json was updated and
        # the image support flag needs manual verification.
        # DeepSeek is absent from Pictures because it can't handle images,
        # so query SimpleIntelligence where it does appear.
        $defaults = GenXdev\Get-AIDefaultLLMSettings -LLMQueryType SimpleIntelligence
        $deepSeekModels = $defaults | Microsoft.PowerShell.Core\Where-Object { $_.Model -like 'deepseek*' }
        $deepSeekModels.Count | Pester\Should -BeGreaterThan 0
        foreach ($ds in $deepSeekModels) {
            $ds.NoSupportForImageUpload | Pester\Should -BeTrue `
                -Because "DeepSeek $($ds.Model) — verify manually if this changed"
        }
    }

    ###########################################################################
    Pester\It ('-PromptForSettings delegates to Invoke-AILLMSettingsPrompt ' + `
            'which throws in non-interactive session') {
        {
            GenXdev\Get-AILLMSettings -LLMQueryType 'Coding' `
                -PromptForSettings -NonInteractive -ErrorAction Stop
        } | Pester\Should -Throw -ExpectedMessage '*non-interactive*'
    }
}
###############################################################################
