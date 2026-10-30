Pester\Describe 'Get-SQLiteTables' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\Tables_$([System.Guid]::NewGuid()).sqlite"
        $script:prefix = 'TestTable_' + (Microsoft.PowerShell.Utility\Get-Random) + '_'

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false

        $script:firstTable = $script:prefix + 'First'
        $script:secondTable = $script:prefix + 'Second'

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE TABLE $($script:firstTable) (Id INTEGER PRIMARY KEY, Name TEXT)"
        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE TABLE $($script:secondTable) (Id INTEGER PRIMARY KEY, Value INTEGER)"
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Lists tables using a database file path' {
        $tables = GenXdev\Get-SQLiteTables -DatabaseFilePath $script:databasePath

        $tables | Pester\Should -Not -BeNullOrEmpty

        $names = $tables | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $names | Pester\Should -Contain $script:firstTable
        $names | Pester\Should -Contain $script:secondTable
    }

    Pester\It 'Lists tables using a connection string' {
        $tables = GenXdev\Get-SQLiteTables `
            -ConnectionString "Data Source=$script:databasePath"

        $names = $tables | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $names | Pester\Should -Contain $script:firstTable
        $names | Pester\Should -Contain $script:secondTable
    }
}
