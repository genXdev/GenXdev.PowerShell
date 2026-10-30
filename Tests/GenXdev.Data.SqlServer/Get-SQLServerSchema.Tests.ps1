Pester\Describe 'Get-SQLServerSchema' {

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
        $script:TestTableName = 'TestSchemaTable_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:TestViewName = 'TestSchemaView_' + (Microsoft.PowerShell.Utility\Get-Random)
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
            $null = GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString `
                -Queries "CREATE TABLE tempdb.dbo.${script:TestTableName} (Id int, Name nvarchar(50))"

            $null = GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString `
                -Queries "CREATE VIEW dbo.${script:TestViewName} AS SELECT Id, Name FROM tempdb.dbo.${script:TestTableName}"
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

    Pester\It 'Should list tables and views using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $schema = GenXdev\Get-SQLServerSchema -DatabaseName 'tempdb' `
            -Server $script:TestServer

        $schema | Pester\Should -Not -BeNullOrEmpty

        $tables = $schema | Microsoft.PowerShell.Core\Where-Object {
            $_.object_type -eq 'TABLE'
        }
        $views = $schema | Microsoft.PowerShell.Core\Where-Object {
            $_.object_type -eq 'VIEW'
        }

        $tables.name | Pester\Should -Contain $script:TestTableName
        $views.name | Pester\Should -Contain $script:TestViewName
    }

    Pester\It 'Should list schema objects using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $schema = GenXdev\Get-SQLServerSchema `
            -ConnectionString $script:TestConnectionString

        $schema | Pester\Should -Not -BeNullOrEmpty
        $schema.name | Pester\Should -Contain $script:TestTableName
        $schema.name | Pester\Should -Contain $script:TestViewName
    }

    Pester\It 'Should include object identifiers' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $schema = GenXdev\Get-SQLServerSchema -DatabaseName 'tempdb' `
            -Server $script:TestServer

        $table = $schema | Microsoft.PowerShell.Core\Where-Object {
            $_.name -eq $script:TestTableName -and $_.object_type -eq 'TABLE'
        }

        $table.object_id | Pester\Should -BeGreaterThan 0
        $table.schema_id | Pester\Should -Not -BeNullOrEmpty
    }
}
