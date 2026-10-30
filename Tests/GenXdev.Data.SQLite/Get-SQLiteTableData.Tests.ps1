Pester\Describe 'Get-SQLiteTableData' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\TableData_$([System.Guid]::NewGuid()).sqlite"
        $script:tableName = 'DataTable_' + (Microsoft.PowerShell.Utility\Get-Random)

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE TABLE $($script:tableName) (Id INTEGER PRIMARY KEY, Name TEXT, Value INTEGER)"

        foreach ($row in 1..5) {
            $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
                -Queries "INSERT INTO $($script:tableName) (Name, Value) VALUES ('Item$row', $($row * 100))"
        }
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Retrieves table data using a database file path' {
        $data = GenXdev\Get-SQLiteTableData -DatabaseFilePath $script:databasePath `
            -TableName $script:tableName -Count -1

        $data | Pester\Should -Not -BeNullOrEmpty
        $data.Count | Pester\Should -Be 5
        $data.Name | Pester\Should -Contain 'Item3'
    }

    Pester\It 'Retrieves table data using a connection string' {
        $data = GenXdev\Get-SQLiteTableData `
            -ConnectionString "Data Source=$script:databasePath" `
            -TableName $script:tableName -Count -1

        $data.Count | Pester\Should -Be 5
    }

    Pester\It 'Limits results when Count is specified' {
        $data = GenXdev\Get-SQLiteTableData -DatabaseFilePath $script:databasePath `
            -TableName $script:tableName -Count 3

        $data.Count | Pester\Should -Be 3
    }
}
