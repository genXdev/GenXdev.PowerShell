Pester\Describe 'Get-SQLServerTableColumnData' {

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
        $script:TestTableName = 'TestColumnTable_' + (Microsoft.PowerShell.Utility\Get-Random)
        . "$PSScriptRoot\SqlServerTestHelpers.ps1"

        # run against $env:GENXDEV_SQL_TEST_CONNECTIONSTRING, or the local default
        $script:TestConfiguration = Get-SqlServerTestConfiguration
        $script:TestServer = $script:TestConfiguration.Server
        $script:TestConnectionString = $script:TestConfiguration.ConnectionString
        $script:CanUseServerParameter = $script:TestConfiguration.CanUseServerParameter

        # Check if SQL Server is available
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

        if ($script:SqlServerAvailable) {
            $setupQueries = @(
                "CREATE TABLE tempdb.dbo.${script:TestTableName} (Id int, Name nvarchar(50))",
                "INSERT INTO tempdb.dbo.${script:TestTableName} (Id, Name) VALUES (1, 'Alpha')",
                "INSERT INTO tempdb.dbo.${script:TestTableName} (Id, Name) VALUES (2, 'Beta')",
                "INSERT INTO tempdb.dbo.${script:TestTableName} (Id, Name) VALUES (3, 'Gamma')",
                "INSERT INTO tempdb.dbo.${script:TestTableName} (Id, Name) VALUES (4, 'Delta')"
            )

            foreach ($query in $setupQueries) {
                $null = GenXdev\Invoke-SQLServerQuery `
                    -ConnectionString $script:TestConnectionString -Queries $query
            }
        }
    }

    Pester\AfterAll {
        if ($script:SqlServerAvailable) {
            try {
                $null = GenXdev\Invoke-SQLServerQuery `
                    -ConnectionString $script:TestConnectionString `
                    -Queries "IF OBJECT_ID('tempdb.dbo.${script:TestTableName}') IS NOT NULL DROP TABLE tempdb.dbo.${script:TestTableName}"
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Could not clean up test table: $_"
            }
        }
    }

    Pester\It 'Should retrieve column data using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $data = GenXdev\Get-SQLServerTableColumnData -DatabaseName 'tempdb' `
            -Server $script:TestServer -TableName $script:TestTableName `
            -ColumnName 'Name' -Count -1

        $data | Pester\Should -Not -BeNullOrEmpty
        $data.Count | Pester\Should -Be 4
        $data.Name | Pester\Should -Contain 'Gamma'
    }

    Pester\It 'Should limit results when Count is specified' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $data = GenXdev\Get-SQLServerTableColumnData -DatabaseName 'tempdb' `
            -Server $script:TestServer -TableName $script:TestTableName `
            -ColumnName 'Name' -Count 2

        $data.Count | Pester\Should -Be 2
    }

    Pester\It 'Should retrieve column data using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $data = GenXdev\Get-SQLServerTableColumnData `
            -ConnectionString $script:TestConnectionString `
            -TableName $script:TestTableName -ColumnName 'Id' -Count -1

        $data.Count | Pester\Should -Be 4
        $data.Id | Pester\Should -Contain 1
    }
}
