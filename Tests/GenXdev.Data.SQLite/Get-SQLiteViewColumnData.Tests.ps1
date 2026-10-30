Pester\Describe 'Get-SQLiteViewColumnData' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\ViewColumn_$([System.Guid]::NewGuid()).sqlite"
        $script:tableName = 'ViewColumnTable_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:viewName = 'ViewColumnView_' + (Microsoft.PowerShell.Utility\Get-Random)

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE TABLE $($script:tableName) (Id INTEGER PRIMARY KEY, Name TEXT)"

        foreach ($name in 'Alpha', 'Beta', 'Gamma') {
            $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
                -Queries "INSERT INTO $($script:tableName) (Name) VALUES ('$name')"
        }

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE VIEW $($script:viewName) AS SELECT Id, Name FROM $($script:tableName)"
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Retrieves every column value with Count -1' {
        $data = GenXdev\Get-SQLiteViewColumnData `
            -DatabaseFilePath $script:databasePath `
            -ViewName $script:viewName -ColumnName 'Name' -Count -1

        $data | Pester\Should -Not -BeNullOrEmpty
        $data.Count | Pester\Should -Be 3
        $data.Name | Pester\Should -Contain 'Alpha'
    }

    Pester\It 'Limits results when Count is specified' {
        $data = GenXdev\Get-SQLiteViewColumnData `
            -DatabaseFilePath $script:databasePath `
            -ViewName $script:viewName -ColumnName 'Name' -Count 1

        @($data).Count | Pester\Should -Be 1
    }

    Pester\It 'Retrieves column values using a connection string' {
        $data = GenXdev\Get-SQLiteViewColumnData `
            -ConnectionString "Data Source=$script:databasePath" `
            -ViewName $script:viewName -ColumnName 'Id' -Count -1

        $data.Count | Pester\Should -Be 3
        $data.Id | Pester\Should -Contain 2
    }
}
