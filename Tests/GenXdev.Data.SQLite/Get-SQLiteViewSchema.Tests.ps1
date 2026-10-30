Pester\Describe 'Get-SQLiteViewSchema' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\ViewSchema_$([System.Guid]::NewGuid()).sqlite"
        $script:tableName = 'ViewSchemaTable_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:viewName = 'ViewSchemaView_' + (Microsoft.PowerShell.Utility\Get-Random)

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE TABLE $($script:tableName) (Id INTEGER PRIMARY KEY, Name TEXT)"

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE VIEW $($script:viewName) AS SELECT Id, Name FROM $($script:tableName)"
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Returns the view definition using a database file path' {
        $schema = GenXdev\Get-SQLiteViewSchema -DatabaseFilePath $script:databasePath `
            -ViewName $script:viewName

        $schema | Pester\Should -Not -BeNullOrEmpty
        $schema.sql | Pester\Should -Match 'CREATE VIEW'
        $schema.sql | Pester\Should -Match $script:tableName
    }

    Pester\It 'Returns the view definition using a connection string' {
        $schema = GenXdev\Get-SQLiteViewSchema `
            -ConnectionString "Data Source=$script:databasePath" `
            -ViewName $script:viewName

        $schema.sql | Pester\Should -Match 'CREATE VIEW'
    }

    Pester\It 'Returns nothing for a missing view' {
        $schema = GenXdev\Get-SQLiteViewSchema -DatabaseFilePath $script:databasePath `
            -ViewName "MissingView_$([System.Guid]::NewGuid())"

        $schema | Pester\Should -BeNullOrEmpty
    }
}
