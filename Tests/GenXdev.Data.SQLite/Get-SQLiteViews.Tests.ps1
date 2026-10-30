Pester\Describe 'Get-SQLiteViews' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\Views_$([System.Guid]::NewGuid()).sqlite"
        $script:prefix = 'TestView_' + (Microsoft.PowerShell.Utility\Get-Random) + '_'

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false

        $script:firstView = $script:prefix + 'First'
        $script:secondView = $script:prefix + 'Second'

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE VIEW $($script:firstView) AS SELECT 1 AS Value"
        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE VIEW $($script:secondView) AS SELECT 2 AS Value"
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Lists views using a database file path' {
        $views = GenXdev\Get-SQLiteViews -DatabaseFilePath $script:databasePath

        $views | Pester\Should -Not -BeNullOrEmpty

        $names = $views | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $names | Pester\Should -Contain $script:firstView
        $names | Pester\Should -Contain $script:secondView
    }

    Pester\It 'Lists views using a connection string' {
        $views = GenXdev\Get-SQLiteViews `
            -ConnectionString "Data Source=$script:databasePath"

        $names = $views | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $names | Pester\Should -Contain $script:firstView
        $names | Pester\Should -Contain $script:secondView
    }
}
