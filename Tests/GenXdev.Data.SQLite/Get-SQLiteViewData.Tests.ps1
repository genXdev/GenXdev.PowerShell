Pester\Describe 'Get-SQLiteViewData' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\ViewData_$([System.Guid]::NewGuid()).sqlite"
        $script:tableName = 'ViewDataTable_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:viewName = 'ViewDataView_' + (Microsoft.PowerShell.Utility\Get-Random)

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

    Pester\It 'Retrieves every view row with Count -1' {
        $data = GenXdev\Get-SQLiteViewData -DatabaseFilePath $script:databasePath `
            -ViewName $script:viewName -Count -1

        $data | Pester\Should -Not -BeNullOrEmpty
        $data.Count | Pester\Should -Be 3
        $data.Name | Pester\Should -Contain 'Beta'
    }

    Pester\It 'Limits results when Count is specified' {
        $data = GenXdev\Get-SQLiteViewData -DatabaseFilePath $script:databasePath `
            -ViewName $script:viewName -Count 2

        $data.Count | Pester\Should -Be 2
    }

    Pester\It 'Retrieves view data using a connection string' {
        $data = GenXdev\Get-SQLiteViewData `
            -ConnectionString "Data Source=$script:databasePath" `
            -ViewName $script:viewName -Count -1

        $data.Count | Pester\Should -Be 3
    }
}
