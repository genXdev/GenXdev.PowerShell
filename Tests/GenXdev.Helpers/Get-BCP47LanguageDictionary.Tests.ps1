###############################################################################
Pester\Describe 'Get-BCP47LanguageDictionary — BCP 47 language code lookup' {

    Pester\BeforeAll {
        $script:dict = GenXdev\Get-BCP47LanguageDictionary
    }

    Pester\It 'returns a non-empty hashtable' {
        $script:dict | Pester\Should -Not -BeNullOrEmpty
        $script:dict -is [System.Collections.IDictionary] |
            Pester\Should -Be $true
    }

    Pester\It 'contains at least 100 BCP 47 language codes' {
        $script:dict.Count | Pester\Should -BeGreaterOrEqual 100
    }

    Pester\It "key 'en-US' maps to 'en-US'" {
        $script:dict['en-US'] | Pester\Should -Be 'en-US'
    }

    Pester\It "key 'nl-NL' maps to 'nl-NL'" {
        $script:dict['nl-NL'] | Pester\Should -Be 'nl-NL'
    }

    Pester\It "key 'de-DE' maps to 'de-DE'" {
        $script:dict['de-DE'] | Pester\Should -Be 'de-DE'
    }

    Pester\It "key 'fr-FR' maps to 'fr-FR'" {
        $script:dict['fr-FR'] | Pester\Should -Be 'fr-FR'
    }

    Pester\It "key 'ja-JP' maps to 'ja-JP'" {
        $script:dict['ja-JP'] | Pester\Should -Be 'ja-JP'
    }

    Pester\It "key 'zh-Hans-CN' maps to 'zh-Hans-CN'" {
        $script:dict['zh-Hans-CN'] | Pester\Should -Be 'zh-Hans-CN'
    }

    Pester\It "key 'es-ES' maps to 'es-ES'" {
        $script:dict['es-ES'] | Pester\Should -Be 'es-ES'
    }

    Pester\It "key 'pt-BR' maps to 'pt-BR'" {
        $script:dict['pt-BR'] | Pester\Should -Be 'pt-BR'
    }

    Pester\It "key 'ar-SA' maps to 'ar-SA'" {
        $script:dict['ar-SA'] | Pester\Should -Be 'ar-SA'
    }

    Pester\It "key 'ru-RU' maps to 'ru-RU'" {
        $script:dict['ru-RU'] | Pester\Should -Be 'ru-RU'
    }

    Pester\It 'all BCP 47 keys follow format (language-REGION)' {
        # Only check keys that look like BCP 47 codes (skip display names
        # like "Afar (Djibouti)" which are also keys for reverse lookup).
        # BCP 47 allows optional script subtags (e.g., az-Cyrl-AZ).
        $bcpKeys = $script:dict.Keys |
            Microsoft.PowerShell.Core\Where-Object { $_ -match '^[a-zA-Z]{2,3}-' }
        foreach ($key in $bcpKeys) {
            $key | Pester\Should -Match '^[a-zA-Z]{2,3}(-[a-zA-Z0-9]{2,8})+$' `
                -Because "'${key}' should match lang-REGION pattern"
        }
    }

    Pester\It 'all values follow BCP 47 format' {
        foreach ($value in $script:dict.Values) {
            $value | Pester\Should -Match '^[a-zA-Z]{2,3}(-[a-zA-Z0-9]{2,8})+$' `
                -Because "'${value}' should match lang-REGION pattern"
        }
    }
}
