Pester\Describe 'Get-SQLiteConnection' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\Connection_$([System.Guid]::NewGuid()).sqlite"

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Returns an open connection using DatabaseFilePath' {
        $connection = GenXdev\Get-SQLiteConnection `
            -DatabaseFilePath $script:databasePath

        try {
            $connection | Pester\Should -Not -BeNullOrEmpty
            $connection.GetType().Name | Pester\Should -Be 'SQLiteConnection'
            $connection.State | Pester\Should -Be 'Open'
        }
        finally {
            $connection.Close()
        }
    }

    Pester\It 'Prefers the connection string over DatabaseFilePath' {
        $unusedPath = "$script:testRoot\Unused_$([System.Guid]::NewGuid()).sqlite"

        $connection = GenXdev\Get-SQLiteConnection `
            -DatabaseFilePath $unusedPath `
            -ConnectionString "Data Source=$script:databasePath"

        try {
            $connection.ConnectionString | Pester\Should -BeLike "*$script:databasePath*"
            Microsoft.PowerShell.Management\Test-Path -LiteralPath $unusedPath |
                Pester\Should -BeFalse
        }
        finally {
            $connection.Close()
        }
    }

    Pester\It 'Keeps one session across queries' {
        $connection = GenXdev\Get-SQLiteConnection `
            -DatabaseFilePath $script:databasePath

        try {
            $null = GenXdev\Invoke-SQLiteQuery -Connection $connection `
                -Queries 'CREATE TEMP TABLE SessionState (Id INTEGER)'
            $null = GenXdev\Invoke-SQLiteQuery -Connection $connection `
                -Queries 'INSERT INTO SessionState (Id) VALUES (1)'

            $result = GenXdev\Invoke-SQLiteQuery -Connection $connection `
                -Queries 'SELECT COUNT(*) AS RowCount FROM SessionState'

            $result.RowCount | Pester\Should -Be 1
        }
        finally {
            $connection.Close()
        }
    }

    Pester\It 'Reports when no connection source is provided' {
        { GenXdev\Get-SQLiteConnection } |
            Pester\Should -Throw -ExpectedMessage '*ConnectionString or DatabaseFilePath*'
    }
}
