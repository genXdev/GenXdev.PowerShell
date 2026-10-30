Pester\Describe 'Get-SQLServerViewSchema' {

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
        $script:TestTableName = 'TestViewSchemaTable_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:TestViewName = 'TestViewSchema_' + (Microsoft.PowerShell.Utility\Get-Random)
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

    Pester\It 'Should return the view definition using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $schema = GenXdev\Get-SQLServerViewSchema -DatabaseName 'tempdb' `
            -Server $script:TestServer -ViewName $script:TestViewName

        $schema | Pester\Should -Not -BeNullOrEmpty
        $schema.view_definition | Pester\Should -Match 'SELECT'
        $schema.view_definition | Pester\Should -Match $script:TestTableName
    }

    Pester\It 'Should return the view definition using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $schema = GenXdev\Get-SQLServerViewSchema `
            -ConnectionString $script:TestConnectionString `
            -ViewName $script:TestViewName

        $schema.view_definition | Pester\Should -Match 'SELECT'
    }

    Pester\It 'Should return no definition for a missing view' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $schema = GenXdev\Get-SQLServerViewSchema -DatabaseName 'tempdb' `
            -Server $script:TestServer `
            -ViewName "MissingView_$([System.Guid]::NewGuid())"

        ($null -eq $schema.view_definition -or
            $schema.view_definition -is [System.DBNull]) |
            Pester\Should -BeTrue
    }
}
