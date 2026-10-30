Pester\Describe 'Get-SQLiteTableColumnData' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\ColumnData_$([System.Guid]::NewGuid()).sqlite"
        $script:tableName = 'ColumnTable_' + (Microsoft.PowerShell.Utility\Get-Random)

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE TABLE $($script:tableName) (Id INTEGER PRIMARY KEY, Name TEXT)"

        foreach ($name in 'Alpha', 'Beta', 'Gamma', 'Delta') {
            $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
                -Queries "INSERT INTO $($script:tableName) (Name) VALUES ('$name')"
        }
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Retrieves every column value with Count -1' {
        $data = GenXdev\Get-SQLiteTableColumnData `
            -DatabaseFilePath $script:databasePath `
            -TableName $script:tableName -ColumnName 'Name' -Count -1

        $data | Pester\Should -Not -BeNullOrEmpty
        $data.Count | Pester\Should -Be 4
        $data.Name | Pester\Should -Contain 'Gamma'
    }

    Pester\It 'Limits results when Count is specified' {
        $data = GenXdev\Get-SQLiteTableColumnData `
            -DatabaseFilePath $script:databasePath `
            -TableName $script:tableName -ColumnName 'Name' -Count 2

        $data.Count | Pester\Should -Be 2
    }

    Pester\It 'Retrieves column values using a connection string' {
        $data = GenXdev\Get-SQLiteTableColumnData `
            -ConnectionString "Data Source=$script:databasePath" `
            -TableName $script:tableName -ColumnName 'Id' -Count -1

        $data.Count | Pester\Should -Be 4
        $data.Id | Pester\Should -Contain 1
    }
}
