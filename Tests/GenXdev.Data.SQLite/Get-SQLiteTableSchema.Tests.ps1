Pester\Describe 'Get-SQLiteTableSchema' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\TableSchema_$([System.Guid]::NewGuid()).sqlite"
        $script:tableName = 'SchemaTable_' + (Microsoft.PowerShell.Utility\Get-Random)

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE TABLE $($script:tableName) (Id INTEGER PRIMARY KEY, Name TEXT NOT NULL, Amount REAL)"
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Returns the table columns' {
        $schema = GenXdev\Get-SQLiteTableSchema -DatabaseFilePath $script:databasePath `
            -TableName $script:tableName

        $schema | Pester\Should -Not -BeNullOrEmpty

        $names = $schema | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $names | Pester\Should -Contain 'Id'
        $names | Pester\Should -Contain 'Name'
        $names | Pester\Should -Contain 'Amount'
    }

    Pester\It 'Includes column types and nullability' {
        $schema = GenXdev\Get-SQLiteTableSchema -DatabaseFilePath $script:databasePath `
            -TableName $script:tableName

        $nameColumn = $schema | Microsoft.PowerShell.Core\Where-Object {
            $_.name -eq 'Name'
        }

        $nameColumn.type | Pester\Should -Be 'TEXT'
        $nameColumn.notnull | Pester\Should -Be 1
    }

    Pester\It 'Returns the schema using a connection string' {
        $schema = GenXdev\Get-SQLiteTableSchema `
            -ConnectionString "Data Source=$script:databasePath" `
            -TableName $script:tableName

        $schema.Count | Pester\Should -Be 3
    }
}
