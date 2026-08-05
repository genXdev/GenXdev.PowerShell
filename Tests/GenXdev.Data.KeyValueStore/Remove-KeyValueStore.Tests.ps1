Pester\Describe 'Remove-KeyValueStore' {

    Pester\BeforeAll {
        GenXdev\Remove-KeyValueStore -StoreName 'TestStore'
    }
    Pester\AfterAll {
        GenXdev\Remove-KeyValueStore -StoreName 'TestStore'
    }

    Pester\It 'Should remove entire store' {
        GenXdev\Remove-KeyValueStore -StoreName 'TestStore'
        $keys = GenXdev\Get-StoreKeys -StoreName 'TestStore'
        $keys | Pester\Should -BeNullOrEmpty
    }
}