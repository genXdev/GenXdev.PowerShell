Pester\Describe 'Invoke-SQLiteQuery' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\Query_$([System.Guid]::NewGuid()).sqlite"

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE TABLE Users (Id INTEGER PRIMARY KEY, Name TEXT, Email TEXT)"

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "INSERT INTO Users (Name, Email) VALUES ('John Doe', 'john@example.com')"

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "INSERT INTO Users (Name, Email) VALUES ('Jane Smith', 'jane@example.com')"
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Executes a simple SELECT query' {
        $result = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries 'SELECT COUNT(*) as UserCount FROM Users'

        $result | Pester\Should -Not -BeNullOrEmpty
        $result.UserCount | Pester\Should -Be 2
    }

    Pester\It 'Executes a query using a connection string' {
        $connectionString = "Data Source=$script:databasePath"
        $result = GenXdev\Invoke-SQLiteQuery -ConnectionString $connectionString `
            -Queries 'SELECT COUNT(*) as UserCount FROM Users'

        $result.UserCount | Pester\Should -Be 2
    }

    Pester\It 'Executes parameterized queries' {
        $result = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries 'SELECT Name FROM Users WHERE Name = @name' `
            -SqlParameters @{ "name" = "John Doe" }

        $result.Name | Pester\Should -Be 'John Doe'
    }

    Pester\It 'Executes on a caller-owned connection' {
        $connection = GenXdev\Get-SQLiteConnection `
            -DatabaseFilePath $script:databasePath

        try {
            $null = GenXdev\Invoke-SQLiteQuery -Connection $connection `
                -Queries "INSERT INTO Users (Name) VALUES ('ConnectionTest')"

            $result = GenXdev\Invoke-SQLiteQuery -Connection $connection `
                -Queries "SELECT COUNT(*) as RowCount FROM Users WHERE Name = 'ConnectionTest'"

            $result.RowCount | Pester\Should -Be 1
        }
        finally {
            $connection.Close()
        }
    }

    Pester\It 'Uses $PSDefaultParameterValues when no database is given' {
        $PSDefaultParameterValues['Invoke-SQLiteQuery:DatabaseFilePath'] =
            $script:databasePath

        try {
            $result = GenXdev\Invoke-SQLiteQuery `
                -Queries ("SELECT COUNT(*) as UserCount FROM Users " +
                    "WHERE Name IN ('John Doe', 'Jane Smith')")

            $result.UserCount | Pester\Should -Be 2
        }
        finally {
            $PSDefaultParameterValues.Remove('Invoke-SQLiteQuery:DatabaseFilePath')
        }
    }

    Pester\It 'Runs in autocommit mode when IsolationLevel is NoTransaction' {
        {
            GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
                -Queries 'BEGIN; ROLLBACK'
        } | Pester\Should -Throw

        {
            GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
                -IsolationLevel NoTransaction -Queries 'BEGIN; ROLLBACK'
        } | Pester\Should -Not -Throw
    }

    Pester\It 'Reports query errors' {
        {
            GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
                -Queries 'SELECT * FROM NonExistentTable'
        } | Pester\Should -Throw
    }

    Pester\It 'Commits a caller-owned transaction' {
        $transaction = GenXdev\Get-SQLiteTransaction -DatabaseFilePath $script:databasePath

        try {
            $null = GenXdev\Invoke-SQLiteQuery -Transaction $transaction `
                -Queries "INSERT INTO Users (Name) VALUES ('CommitTest')"

            { $transaction.Commit() } | Pester\Should -Not -Throw

            $result = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
                -Queries "SELECT COUNT(*) as RowCount FROM Users WHERE Name = 'CommitTest'"

            $result.RowCount | Pester\Should -Be 1
        }
        finally {
            $transactionConnection = $transaction.Connection
            if ($null -ne $transactionConnection) { $transactionConnection.Close() }
        }
    }
}
