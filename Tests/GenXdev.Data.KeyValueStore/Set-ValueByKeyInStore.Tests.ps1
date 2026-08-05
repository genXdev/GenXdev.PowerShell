Pester\Describe 'Set-ValueByKeyInStore' {

    Pester\BeforeAll {
        Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
        GenXdev\Remove-KeyFromStore -StoreName 'TestStore' -KeyName 'TestKey'
    }

    Pester\AfterAll {
        GenXdev\Remove-KeyFromStore -StoreName 'TestStore' -KeyName 'TestKey'
    }

    Pester\It 'Should store a value successfully' {
        GenXdev\Set-ValueByKeyInStore -StoreName 'TestStore' -KeyName 'TestKey' -Value 'TestValue'
        $result = GenXdev\Get-ValueByKeyFromStore -StoreName 'TestStore' -KeyName 'TestKey'
        $result | Pester\Should -Be 'TestValue'
    }

    Pester\It 'Should update existing value' {
        GenXdev\Set-ValueByKeyInStore -StoreName 'TestStore' -KeyName 'TestKey' -Value 'Value1'
        GenXdev\Set-ValueByKeyInStore -StoreName 'TestStore' -KeyName 'TestKey' -Value 'Value2'
        $result = GenXdev\Get-ValueByKeyFromStore -StoreName 'TestStore' -KeyName 'TestKey'
        $result | Pester\Should -Be 'Value2'
    }

    Pester\It 'Should handle null values' {
        GenXdev\Set-ValueByKeyInStore -StoreName 'TestStore' -KeyName 'TestKey' -Value $null
        $result = GenXdev\Get-ValueByKeyFromStore -StoreName 'TestStore' -KeyName 'TestKey'
        $result | Pester\Should -BeNullOrEmpty
    }
}