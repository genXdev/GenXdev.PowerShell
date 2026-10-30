Pester\Describe 'Invoke-SQLServerQuery' {

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
        $script:TestTableName = 'TestUsers_' + (Microsoft.PowerShell.Utility\Get-Random)
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
    Name nvarchar(100) NOT NULL,
    Email nvarchar(255),
    Active bit DEFAULT 1
)
"@
            GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString -Queries $createTableQuery

            # Insert test data
            $insertQuery = "INSERT INTO tempdb.dbo.${script:TestTableName} (Name, Email, Active) VALUES (@name, @email, @active)"
            GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString `
                -Queries $insertQuery -SqlParameters @{
                "name" = "John Doe"
                "email" = "john@example.com"
                "active" = $true
            }
            GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString `
                -Queries $insertQuery -SqlParameters @{
                "name" = "Jane Smith"
                "email" = "jane@example.com"
                "active" = $false
            }
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

    Pester\It 'Should execute simple SELECT query using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $result = GenXdev\Invoke-SQLServerQuery `
            -ConnectionString $script:TestConnectionString `
            -Queries "SELECT COUNT(*) as UserCount FROM ${script:TestTableName}"
        $result | Pester\Should -Not -BeNullOrEmpty
        $result.UserCount | Pester\Should -Be 2
    }

    Pester\It 'Should use $PSDefaultParameterValues when no connection is given' -Skip:(-not $script:SqlServerAvailable) {
        $PSDefaultParameterValues['Invoke-SQLServerQuery:ConnectionString'] =
            $script:TestConnectionString

        try {
            $result = GenXdev\Invoke-SQLServerQuery -Queries 'SELECT 7 as [Ok]'
            $result.Ok | Pester\Should -Be 7
        }
        finally {
            $PSDefaultParameterValues.Remove('Invoke-SQLServerQuery:ConnectionString')
        }
    }

    Pester\It 'Should run in autocommit mode when IsolationLevel is NoTransaction' -Skip:(-not $script:SqlServerAvailable) {
        $default = GenXdev\Invoke-SQLServerQuery `
            -ConnectionString $script:TestConnectionString `
            -Queries 'SELECT @@TRANCOUNT as [TranCount]'

        $autocommit = GenXdev\Invoke-SQLServerQuery `
            -ConnectionString $script:TestConnectionString `
            -IsolationLevel NoTransaction `
            -Queries 'SELECT @@TRANCOUNT as [TranCount]'

        $default.TranCount | Pester\Should -Be 1
        $autocommit.TranCount | Pester\Should -Be 0
    }

    Pester\It 'Should let DatabaseName override the connection string database' -Skip:(-not $script:SqlServerAvailable) {
        $result = GenXdev\Invoke-SQLServerQuery `
            -ConnectionString $script:TestConnectionString `
            -DatabaseName 'master' `
            -Queries "SELECT DB_NAME() as [DatabaseName]"

        $result.DatabaseName | Pester\Should -Be 'master'
    }

    Pester\It 'Should execute query using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $result = GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries "SELECT Name FROM ${script:TestTableName} WHERE Active = 1"
        $result | Pester\Should -Not -BeNullOrEmpty
        $result.Name | Pester\Should -Contain "John Doe"
    }

    Pester\It 'Should execute parameterized queries' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $result = GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries "SELECT * FROM ${script:TestTableName} WHERE Active = @active" -SqlParameters @{"active" = $true}
        $result | Pester\Should -Not -BeNullOrEmpty
        $result.Name | Pester\Should -Be "John Doe"
    }

    Pester\It 'Should handle query errors properly' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        { GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries "SELECT * FROM NonExistentTable" } | Pester\Should -Throw
    }
}