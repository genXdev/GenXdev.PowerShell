Pester\Describe 'Get-SQLServerTransaction' {

    Pester\BeforeDiscovery {

        # -Skip is evaluated during discovery, so the flags it gates on
        # must be computed here rather than in BeforeAll
        . "$PSScriptRoot\SqlServerTestHelpers.ps1"

        $script:TestConfiguration = Get-SqlServerTestConfiguration
        $script:TestServer = $script:TestConfiguration.Server
        $script:TestConnectionString = $script:TestConfiguration.ConnectionString
        $script:CanUseServerParameter = $script:TestConfiguration.CanUseServerParameter

        $script:SqlServerAvailable = $false
        try {
            $null = GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString -Queries 'SELECT 1'
            $script:SqlServerAvailable = $true
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Warning (
                'SQL Server not available - skipping database tests: ' +
                $_.Exception.Message)
        }
    }

    Pester\BeforeAll {
        Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
        $script:TestTableName = 'TransactionTest_' + (Microsoft.PowerShell.Utility\Get-Random)
        . "$PSScriptRoot\SqlServerTestHelpers.ps1"

        # run against $env:GENXDEV_SQL_TEST_CONNECTIONSTRING, or the local default
        $script:TestConfiguration = Get-SqlServerTestConfiguration
        $script:TestServer = $script:TestConfiguration.Server
        $script:TestConnectionString = $script:TestConfiguration.ConnectionString
        $script:CanUseServerParameter = $script:TestConfiguration.CanUseServerParameter

        # Check if SQL Server is available
        $script:SqlServerAvailable = $false
        try {
            GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString -Queries "SELECT 1"
            $script:SqlServerAvailable = $true
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Warning (
                'SQL Server not available - skipping database tests: ' +
                $_.Exception.Message)
        }

        if ($script:SqlServerAvailable) {
            # Create test table in tempdb
            $createTableQuery = @"
CREATE TABLE tempdb.dbo.${script:TestTableName} (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Value nvarchar(50)
)
"@
            GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString -Queries $createTableQuery
        }
    }

    Pester\AfterAll {
        # Clean-up
        if ($script:SqlServerAvailable) {
            try {
                $dropQuery = "IF OBJECT_ID('tempdb.dbo.${script:TestTableName}') IS NOT NULL DROP TABLE tempdb.dbo.${script:TestTableName}"
                GenXdev\Invoke-SQLServerQuery `
                    -ConnectionString $script:TestConnectionString -Queries $dropQuery
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Could not clean up test table: $_"
            }
        }
    }

    Pester\It 'Should create transaction using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $transaction = GenXdev\Get-SQLServerTransaction -DatabaseName 'tempdb' -Server $script:TestServer
        try {
            $transaction | Pester\Should -Not -BeNullOrEmpty
            $transaction.Connection.State | Pester\Should -Be 'Open'
            $transaction.GetType().Name | Pester\Should -Match 'SqlTransaction'
        }
        finally {
            $transactionConnection = $transaction.Connection
            if ($null -ne $transactionConnection) {
                if ($transactionConnection.State -eq 'Open') { $transaction.Rollback() }
                $transactionConnection.Close()
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
            $transactionConnection = $transaction.Connection
            if ($null -ne $transactionConnection) {
                if ($transactionConnection.State -eq 'Open') { $transaction.Rollback() }
                $transactionConnection.Close()
            }
        }
    }

    Pester\It 'Should allow committing transactions' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
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
            $transactionConnection = $transaction.Connection
            if ($null -ne $transactionConnection) { $transactionConnection.Close() }
        }
    }
}