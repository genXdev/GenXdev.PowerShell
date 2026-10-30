Pester\Describe 'Get-SQLServerViews' {

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
        $script:TestViewPrefix = 'TestView_' + (Microsoft.PowerShell.Utility\Get-Random) + '_'
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
            $script:TestView1Name = $script:TestViewPrefix + 'FirstView'
            $script:TestView2Name = $script:TestViewPrefix + 'SecondView'

            $createQueries = @(
                "CREATE VIEW dbo.${script:TestView1Name} AS SELECT 1 AS Value",
                "CREATE VIEW dbo.${script:TestView2Name} AS SELECT 2 AS Value"
            )

            foreach ($query in $createQueries) {
                $null = GenXdev\Invoke-SQLServerQuery `
                    -ConnectionString $script:TestConnectionString -Queries $query
            }
        }
    }

    Pester\AfterAll {
        if ($script:SqlServerAvailable) {
            try {
                $dropQueries = @(
                    "IF OBJECT_ID('tempdb.dbo.${script:TestView1Name}') IS NOT NULL DROP VIEW dbo.${script:TestView1Name}",
                    "IF OBJECT_ID('tempdb.dbo.${script:TestView2Name}') IS NOT NULL DROP VIEW dbo.${script:TestView2Name}"
                )

                foreach ($query in $dropQueries) {
                    $null = GenXdev\Invoke-SQLServerQuery `
                        -ConnectionString $script:TestConnectionString -Queries $query
                }
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Could not clean up test views: $_"
            }
        }
    }

    Pester\It 'Should list all views using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $views = GenXdev\Get-SQLServerViews -DatabaseName 'tempdb' `
            -Server $script:TestServer

        $views | Pester\Should -Not -BeNullOrEmpty

        $viewNames = $views | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $viewNames | Pester\Should -Contain $script:TestView1Name
        $viewNames | Pester\Should -Contain $script:TestView2Name
    }

    Pester\It 'Should list all views using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $views = GenXdev\Get-SQLServerViews `
            -ConnectionString $script:TestConnectionString

        $viewNames = $views | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $viewNames | Pester\Should -Contain $script:TestView1Name
        $viewNames | Pester\Should -Contain $script:TestView2Name
    }

    Pester\It 'Should return views in sorted order' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $views = GenXdev\Get-SQLServerViews -DatabaseName 'tempdb' `
            -Server $script:TestServer

        $viewNames = $views | Microsoft.PowerShell.Core\ForEach-Object { $_.name }
        $sortedNames = $viewNames | Microsoft.PowerShell.Utility\Sort-Object

        $viewNames | Pester\Should -Be $sortedNames
    }
}
