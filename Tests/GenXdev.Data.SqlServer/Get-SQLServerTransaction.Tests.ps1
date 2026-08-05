Pester\Describe 'Get-SQLServerTransaction' {

    Pester\BeforeAll {
        Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
        $script:TestTableName = 'TransactionTest_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:TestServer = '.'
        $script:TestConnectionString = "Server=$script:TestServer;Database=tempdb;Integrated Security=true;TrustServerCertificate=true"

        # Check if SQL Server is available
        $script:SqlServerAvailable = $false
        try {
            GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries "SELECT 1"
            $script:SqlServerAvailable = $true
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose "SQL Server not available - skipping tests"
        }

        if ($script:SqlServerAvailable) {
            # Create test table in tempdb
            $createTableQuery = @"
CREATE TABLE tempdb.dbo.${script:TestTableName} (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Value nvarchar(50)
)
"@
            GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $createTableQuery
        }
    }

    Pester\AfterAll {
        # Clean-up
        if ($script:SqlServerAvailable) {
            try {
                $dropQuery = "IF OBJECT_ID('tempdb.dbo.${script:TestTableName}') IS NOT NULL DROP TABLE tempdb.dbo.${script:TestTableName}"
                GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $dropQuery
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Could not clean up test table: $_"
            }
        }
    }

    Pester\It 'Should create transaction using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable) {
        $transaction = GenXdev\Get-SQLServerTransaction -DatabaseName 'tempdb' -Server $script:TestServer
        try {
            $transaction | Pester\Should -Not -BeNullOrEmpty
            $transaction.Connection.State | Pester\Should -Be 'Open'
            $transaction.GetType().Name | Pester\Should -Match 'SqlTransaction'
        }
        finally {
            if ($transaction -and $transaction.Connection.State -eq 'Open') {
                $transaction.Rollback()
                $transaction.Connection.Close()
            }
        }
    }

    Pester\It 'Should create transaction using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $transaction = GenXdev\Get-SQLServerTransaction -ConnectionString $script:TestConnectionString
        try {
            $transaction | Pester\Should -Not -BeNullOrEmpty
            $transaction.Connection.State | Pester\Should -Be 'Open'
        }
        finally {
            if ($transaction -and $transaction.Connection.State -eq 'Open') {
                $transaction.Rollback()
                $transaction.Connection.Close()
            }
        }
    }

    Pester\It 'Should allow committing transactions' -Skip:(-not $script:SqlServerAvailable) {
        $transaction = GenXdev\Get-SQLServerTransaction -DatabaseName 'tempdb' -Server $script:TestServer
        try {
            # Insert data within transaction
            GenXdev\Invoke-SQLServerQuery -Transaction $transaction -Queries "INSERT INTO ${script:TestTableName} (Value) VALUES ('CommitTest')"

            # Commit the transaction
            { $transaction.Commit() } | Pester\Should -Not -Throw

            # Verify data was committed
            $result = GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString -Queries "SELECT COUNT(*) as Count FROM ${script:TestTableName} WHERE Value = 'CommitTest'"
            $result.Count | Pester\Should -Be 1
        }
        finally {
            if ($transaction -and $transaction.Connection.State -eq 'Open') {
                $transaction.Connection.Close()
            }
        }
    }
}