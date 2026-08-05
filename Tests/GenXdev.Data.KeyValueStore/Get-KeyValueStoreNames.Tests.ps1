
Pester\Describe 'Get-KeyValueStoreNames' {

    Pester\BeforeAll {
        try {
            Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
            GenXdev\Remove-KeyValueStore -StoreName 'Store1'
            GenXdev\Remove-KeyValueStore -StoreName 'Store2'

            # Setup test stores
            GenXdev\Set-ValueByKeyInStore -StoreName 'Store1' -KeyName 'Key1' -Value 'Value1'
            GenXdev\Set-ValueByKeyInStore -StoreName 'Store2' -KeyName 'Key2' -Value 'Value2'
        }
        catch {
            throw
        }
    }

    Pester\AfterAll {
        # Clean-up
        GenXdev\Remove-KeyValueStore -StoreName 'Store1'
        GenXdev\Remove-KeyValueStore -StoreName 'Store2'
    }

    Pester\It 'Should list all stores' {
        $stores = GenXdev\Get-KeyValueStoreNames
        $stores | Pester\Should -Contain 'Store1'
        $stores | Pester\Should -Contain 'Store2'
    }
}