Pester\Describe 'Invoke-SQLServerQuery' {

    Pester\BeforeAll {
        Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
        $script:TestTableName = 'TestUsers_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:TestServer = '.'

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
    Name nvarchar(100) NOT NULL,
    Email nvarchar(255),
    Active bit DEFAULT 1
)
"@
            GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $createTableQuery

            # Insert test data
            $insertQuery = "INSERT INTO tempdb.dbo.${script:TestTableName} (Name, Email, Active) VALUES (@name, @email, @active)"
            GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $insertQuery -SqlParameters @{
                "name" = "John Doe"
                "email" = "john@example.com"
                "active" = $true
            }
            GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $insertQuery -SqlParameters @{
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
                GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $dropQuery
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Could not clean up test table: $_"
            }
        }
    }

    Pester\It 'Should execute simple SELECT query using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $connString = "Server=$script:TestServer;Database=tempdb;Integrated Security=true;TrustServerCertificate=true"
        $result = GenXdev\Invoke-SQLServerQuery -ConnectionString $connString -Queries "SELECT COUNT(*) as UserCount FROM ${script:TestTableName}"
        $result | Pester\Should -Not -BeNullOrEmpty
        $result.UserCount | Pester\Should -Be 2
    }

    Pester\It 'Should execute query using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable) {
        $result = GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries "SELECT Name FROM ${script:TestTableName} WHERE Active = 1"
        $result | Pester\Should -Not -BeNullOrEmpty
        $result.Name | Pester\Should -Contain "John Doe"
    }

    Pester\It 'Should execute parameterized queries' -Skip:(-not $script:SqlServerAvailable) {
        $result = GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries "SELECT * FROM ${script:TestTableName} WHERE Active = @active" -SqlParameters @{"active" = $true}
        $result | Pester\Should -Not -BeNullOrEmpty
        $result.Name | Pester\Should -Be "John Doe"
    }

    Pester\It 'Should handle query errors properly' -Skip:(-not $script:SqlServerAvailable) {
        { GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries "SELECT * FROM NonExistentTable" } | Pester\Should -Throw
    }
}