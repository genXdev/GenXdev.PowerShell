Pester\Describe 'Get-SQLServerViewColumnData' {

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
        $script:TestTableName = 'TestViewColumnTable_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:TestViewName = 'TestViewColumn_' + (Microsoft.PowerShell.Utility\Get-Random)
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
                "CREATE VIEW dbo.${script:TestViewName} AS SELECT Id, Name FROM tempdb.dbo.${script:TestTableName}"
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
                    -Queries "IF OBJECT_ID('tempdb.dbo.${script:TestViewName}') IS NOT NULL DROP VIEW dbo.${script:TestViewName}"

                $null = GenXdev\Invoke-SQLServerQuery `
                    -ConnectionString $script:TestConnectionString `
                    -Queries "IF OBJECT_ID('tempdb.dbo.${script:TestTableName}') IS NOT NULL DROP TABLE tempdb.dbo.${script:TestTableName}"
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Could not clean up test objects: $_"
            }
        }
    }

    Pester\It 'Should retrieve all column values with Count -1' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $data = GenXdev\Get-SQLServerViewColumnData -DatabaseName 'tempdb' `
            -Server $script:TestServer -ViewName $script:TestViewName `
            -ColumnName 'Name' -Count -1

        $data | Pester\Should -Not -BeNullOrEmpty
        $data.Count | Pester\Should -Be 3
        $data.Name | Pester\Should -Contain 'Alpha'
    }

    Pester\It 'Should limit results when Count is specified' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $data = GenXdev\Get-SQLServerViewColumnData -DatabaseName 'tempdb' `
            -Server $script:TestServer -ViewName $script:TestViewName `
            -ColumnName 'Name' -Count 1

        @($data).Count | Pester\Should -Be 1
    }

    Pester\It 'Should retrieve column values using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $data = GenXdev\Get-SQLServerViewColumnData `
            -ConnectionString $script:TestConnectionString `
            -ViewName $script:TestViewName -ColumnName 'Id' -Count -1

        $data.Count | Pester\Should -Be 3
        $data.Id | Pester\Should -Contain 2
    }
}
