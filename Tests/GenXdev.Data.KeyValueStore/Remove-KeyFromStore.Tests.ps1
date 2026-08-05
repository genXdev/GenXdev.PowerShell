Pester\Describe 'Remove-KeyFromStore' {

    Pester\BeforeAll {
        Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
        GenXdev\Remove-KeyFromStore -StoreName 'TestStore' -KeyName 'TestKey'
        GenXdev\Remove-KeyFromStore -StoreName 'TestStore' -KeyName 'NonExistingKey'
    }

    Pester\AfterAll {
        GenXdev\Remove-KeyFromStore -StoreName 'TestStore' -KeyName 'TestKey'
        GenXdev\Remove-KeyFromStore -StoreName 'TestStore' -KeyName 'NonExistingKey'
    }

    Pester\It 'Should remove existing key' {
        GenXdev\Remove-KeyFromStore -StoreName 'TestStore' -KeyName 'TestKey'
        $result = GenXdev\Get-ValueByKeyFromStore -StoreName 'TestStore' -KeyName 'TestKey'
        $result | Pester\Should -BeNullOrEmpty
    }

    Pester\It 'Should not error when removing non-existing key' {
        { GenXdev\Remove-KeyFromStore -StoreName 'TestStore' -KeyName 'NonExistingKey' } | Pester\Should -Not -Throw
    }
}