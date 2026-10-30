Pester\Describe 'Get-SQLServerConnection' {

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
    }

    Pester\It 'Should return an open connection using DatabaseName and Server' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $connection = GenXdev\Get-SQLServerConnection -DatabaseName 'tempdb' `
            -Server $script:TestServer

        try {
            $connection | Pester\Should -Not -BeNullOrEmpty
            $connection.GetType().Name | Pester\Should -Be 'SqlConnection'
            $connection.State | Pester\Should -Be 'Open'
            $connection.Database | Pester\Should -Be 'tempdb'
        }
        finally {
            $connection.Close()
        }
    }

    Pester\It 'Should let DatabaseName override the connection string database' -Skip:(-not $script:SqlServerAvailable) {
        $connection = GenXdev\Get-SQLServerConnection -DatabaseName 'master' `
            -Server $script:TestServer -ConnectionString $script:TestConnectionString

        try {
            $connection.Database | Pester\Should -Be 'master'
        }
        finally {
            $connection.Close()
        }
    }

    Pester\It 'Should keep one session across queries' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $connection = GenXdev\Get-SQLServerConnection -DatabaseName 'tempdb' `
            -Server $script:TestServer

        try {
            $null = GenXdev\Invoke-SQLServerQuery -Connection $connection `
                -Queries 'CREATE TABLE #SessionState (Id int)'
            $null = GenXdev\Invoke-SQLServerQuery -Connection $connection `
                -Queries 'INSERT INTO #SessionState (Id) VALUES (1)'

            $result = GenXdev\Invoke-SQLServerQuery -Connection $connection `
                -Queries 'SELECT COUNT(*) AS RowCount FROM #SessionState'

            $result.RowCount | Pester\Should -Be 1
        }
        finally {
            $connection.Close()
        }
    }
}
