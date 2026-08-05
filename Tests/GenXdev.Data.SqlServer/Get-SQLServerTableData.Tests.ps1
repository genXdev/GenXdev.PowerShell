Pester\Describe 'Get-SQLServerTableData' {

    Pester\BeforeAll {
        Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
        $script:TestTableName = 'TestDataTable_' + (Microsoft.PowerShell.Utility\Get-Random)
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
            # Create test table with data in tempdb
            $setupQueries = @(
                @"
CREATE TABLE tempdb.dbo.${script:TestTableName} (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Name nvarchar(50),
    Category nvarchar(20),
    Value int
)
"@,
                "INSERT INTO tempdb.dbo.${script:TestTableName} (Name, Category, Value) VALUES ('Item1', 'CategoryA', 100)",
                "INSERT INTO tempdb.dbo.${script:TestTableName} (Name, Category, Value) VALUES ('Item2', 'CategoryB', 200)",
                "INSERT INTO tempdb.dbo.${script:TestTableName} (Name, Category, Value) VALUES ('Item3', 'CategoryA', 300)",
                "INSERT INTO tempdb.dbo.${script:TestTableName} (Name, Category, Value) VALUES ('Item4', 'CategoryC', 400)",
                "INSERT INTO tempdb.dbo.${script:TestTableName} (Name, Category, Value) VALUES ('Item5', 'CategoryB', 500)"
            )

            foreach ($query in $setupQueries) {
                GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $query
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

    Pester\It 'Should retrieve table data using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $connString = "Server=$script:TestServer;Database=tempdb;Integrated Security=true;TrustServerCertificate=true"
        $data = GenXdev\Get-SQLServerTableData -ConnectionString $connString -TableName $script:TestTableName
        $data | Pester\Should -Not -BeNullOrEmpty
        $data.Count | Pester\Should -Be 5
    }

    Pester\It 'Should retrieve table data using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable) {
        $data = GenXdev\Get-SQLServerTableData -DatabaseName 'tempdb' -Server $script:TestServer -TableName $script:TestTableName
        $data | Pester\Should -Not -BeNullOrEmpty
        $data.Count | Pester\Should -Be 5
    }

    Pester\It 'Should limit results when Count parameter is specified' -Skip:(-not $script:SqlServerAvailable) {
        $data = GenXdev\Get-SQLServerTableData -DatabaseName 'tempdb' -Server $script:TestServer -TableName $script:TestTableName -Count 3
        $data | Pester\Should -Not -BeNullOrEmpty
        $data.Count | Pester\Should -Be 3
    }
}