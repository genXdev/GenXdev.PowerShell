Pester\Describe 'Get-SQLiteSchema' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\Schema_$([System.Guid]::NewGuid()).sqlite"
        $script:tableName = 'SchemaTable_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:viewName = 'SchemaView_' + (Microsoft.PowerShell.Utility\Get-Random)

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE TABLE $($script:tableName) (Id INTEGER PRIMARY KEY, Name TEXT)"

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE VIEW $($script:viewName) AS SELECT Id, Name FROM $($script:tableName)"
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Lists every schema object using a database file path' {
        $schema = GenXdev\Get-SQLiteSchema -DatabaseFilePath $script:databasePath

        $schema | Pester\Should -Not -BeNullOrEmpty

        $tables = $schema | Microsoft.PowerShell.Core\Where-Object {
            $_.type -eq 'table'
        }
        $views = $schema | Microsoft.PowerShell.Core\Where-Object {
            $_.type -eq 'view'
        }

        $tables.name | Pester\Should -Contain $script:tableName
        $views.name | Pester\Should -Contain $script:viewName
    }

    Pester\It 'Lists schema objects using a connection string' {
        $schema = GenXdev\Get-SQLiteSchema `
            -ConnectionString "Data Source=$script:databasePath"

        $schema.name | Pester\Should -Contain $script:tableName
        $schema.name | Pester\Should -Contain $script:viewName
    }

    Pester\It 'Includes the defining SQL' {
        $schema = GenXdev\Get-SQLiteSchema -DatabaseFilePath $script:databasePath

        $table = $schema | Microsoft.PowerShell.Core\Where-Object {
            $_.name -eq $script:tableName
        }

        $table.sql | Pester\Should -Match 'CREATE TABLE'
    }
}
