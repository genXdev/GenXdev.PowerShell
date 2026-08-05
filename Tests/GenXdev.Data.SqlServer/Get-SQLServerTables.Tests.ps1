Pester\Describe 'Get-SQLServerTables' {

    Pester\BeforeAll {
        Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
        $script:TestTablePrefix = 'TestTable_' + (Microsoft.PowerShell.Utility\Get-Random) + '_'
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
            # Create test tables in tempdb
            $script:TestTable1Name = $script:TestTablePrefix + 'TestTable1'
            $script:TestTable2Name = $script:TestTablePrefix + 'TestTable2'
            $script:AnotherTableName = $script:TestTablePrefix + 'AnotherTable'

            $createQueries = @(
                "CREATE TABLE tempdb.dbo.${script:TestTable1Name} (Id int PRIMARY KEY, Name nvarchar(50))",
                "CREATE TABLE tempdb.dbo.${script:TestTable2Name} (Id int PRIMARY KEY, Description nvarchar(100))",
                "CREATE TABLE tempdb.dbo.${script:AnotherTableName} (Id int PRIMARY KEY, Value int)"
            )

            foreach ($query in $createQueries) {
                GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $query
            }
        }
    }

    Pester\AfterAll {
        # Clean-up
        if ($script:SqlServerAvailable) {
            try {
                $dropQueries = @(
                    "IF OBJECT_ID('tempdb.dbo.${script:TestTable1Name}') IS NOT NULL DROP TABLE tempdb.dbo.${script:TestTable1Name}",
                    "IF OBJECT_ID('tempdb.dbo.${script:TestTable2Name}') IS NOT NULL DROP TABLE tempdb.dbo.${script:TestTable2Name}",
                    "IF OBJECT_ID('tempdb.dbo.${script:AnotherTableName}') IS NOT NULL DROP TABLE tempdb.dbo.${script:AnotherTableName}"
                )
                foreach ($query in $dropQueries) {
                    GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $query
                }
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Could not clean up test tables: $_"
            }
        }
    }

    Pester\It 'Should list all tables using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $connString = "Server=$script:TestServer;Database=tempdb;Integrated Security=true;TrustServerCertificate=true"
        $tables = GenXdev\Get-SQLServerTables -ConnectionString $connString
        $tables | Pester\Should -Not -BeNullOrEmpty
        $tableNames = $tables | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $tableNames | Pester\Should -Contain $script:TestTable1Name
        $tableNames | Pester\Should -Contain $script:TestTable2Name
        $tableNames | Pester\Should -Contain $script:AnotherTableName
    }

    Pester\It 'Should list all tables using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable) {
        $tables = GenXdev\Get-SQLServerTables -DatabaseName 'tempdb' -Server $script:TestServer
        $tables | Pester\Should -Not -BeNullOrEmpty
        $tableNames = $tables | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $tableNames | Pester\Should -Contain $script:TestTable1Name
        $tableNames | Pester\Should -Contain $script:TestTable2Name
        $tableNames | Pester\Should -Contain $script:AnotherTableName
    }

    Pester\It 'Should return tables in sorted order' -Skip:(-not $script:SqlServerAvailable) {
        $tables = GenXdev\Get-SQLServerTables -DatabaseName 'tempdb' -Server $script:TestServer
        $tableNames = $tables | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $sortedNames = $tableNames | Microsoft.PowerShell.Utility\Sort-Object
        $tableNames | Pester\Should -Be $sortedNames
    }
}