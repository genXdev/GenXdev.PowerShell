Pester\Describe 'Get-SQLiteTransaction' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\Transaction_$([System.Guid]::NewGuid()).sqlite"

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Starts a transaction on a database file' {
        $transaction = GenXdev\Get-SQLiteTransaction `
            -DatabaseFilePath $script:databasePath

        try {
            $transaction | Pester\Should -Not -BeNullOrEmpty
            $transaction.Connection.State | Pester\Should -Be 'Open'
            $transaction.GetType().Name | Pester\Should -Match 'SQLiteTransaction'
        }
        finally {
            $transactionConnection = $transaction.Connection
            $transaction.Rollback()
            $transactionConnection.Close()
        }
    }

    Pester\It 'Starts a transaction from a connection string' {
        $transaction = GenXdev\Get-SQLiteTransaction `
            -ConnectionString "Data Source=$script:databasePath"

        try {
            $transaction.Connection.State | Pester\Should -Be 'Open'
        }
        finally {
            $transactionConnection = $transaction.Connection
            $transaction.Rollback()
            $transactionConnection.Close()
        }
    }

    Pester\It 'Creates the database file when it is missing' {
        $newPath = "$script:testRoot\Created_$([System.Guid]::NewGuid()).sqlite"

        $transaction = GenXdev\Get-SQLiteTransaction -DatabaseFilePath $newPath

        try {
            Microsoft.PowerShell.Management\Test-Path -LiteralPath $newPath |
                Pester\Should -BeTrue
        }
        finally {
            $transactionConnection = $transaction.Connection
            $transaction.Rollback()
            $transactionConnection.Close()
        }
    }

    Pester\It 'Starts a transaction on a provided connection' {
        $connection = GenXdev\Get-SQLiteConnection `
            -DatabaseFilePath $script:databasePath

        try {
            $transaction = GenXdev\Get-SQLiteTransaction -Connection $connection

            $transaction | Pester\Should -Not -BeNullOrEmpty
            $transaction.Connection.State | Pester\Should -Be 'Open'

            $null = GenXdev\Invoke-SQLiteQuery -Transaction $transaction `
                -Queries 'CREATE TABLE TxConnection (Id INTEGER)'
            $null = GenXdev\Invoke-SQLiteQuery -Transaction $transaction `
                -Queries 'INSERT INTO TxConnection (Id) VALUES (9)'

            $transaction.Rollback()

            {
                GenXdev\Invoke-SQLiteQuery -Connection $connection `
                    -Queries 'SELECT COUNT(*) FROM TxConnection'
            } | Pester\Should -Throw
        }
        finally {
            $connection.Close()
        }
    }

    Pester\It 'Reports a missing database file when creation is disabled' {
        $missingPath = "$script:testRoot\Missing_$([System.Guid]::NewGuid()).sqlite"

        {
            GenXdev\Get-SQLiteTransaction -DatabaseFilePath $missingPath `
                -CreateDatabaseIfNotExists $false
        } | Pester\Should -Throw -ExpectedMessage '*does not exist*'
    }
}
