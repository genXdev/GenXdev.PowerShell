Pester\Describe 'New-SQLServerDatabase' {

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
        $script:TestDatabaseName = 'GenXdevTest_' + (Microsoft.PowerShell.Utility\Get-Random)
        . "$PSScriptRoot\SqlServerTestHelpers.ps1"

        # run against $env:GENXDEV_SQL_TEST_CONNECTIONSTRING, or the local default
        $script:TestConfiguration = Get-SqlServerTestConfiguration
        $script:TestServer = $script:TestConfiguration.Server
        $script:TestConnectionString = $script:TestConfiguration.ConnectionString
        $script:CanUseServerParameter = $script:TestConfiguration.CanUseServerParameter

        # Check if SQL Server is available
        $script:SqlServerAvailable = $false
        try {
            GenXdev\Invoke-SQLServerQuery -DatabaseName 'master' -Server $script:TestServer -Queries "SELECT 1"
            $script:SqlServerAvailable = $true
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Warning (
                'SQL Server not available - skipping database tests: ' +
                $_.Exception.Message)
        }
    }

    Pester\AfterAll {
        # Clean-up
        if ($script:SqlServerAvailable) {
            try {
                $dropQuery = "IF EXISTS (SELECT name FROM sys.databases WHERE name = '$script:TestDatabaseName') DROP DATABASE [$script:TestDatabaseName]"
                GenXdev\Invoke-SQLServerQuery -DatabaseName 'master' -Server $script:TestServer -Queries $dropQuery
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Could not clean up test database: $_"
            }
        }
    }

    Pester\It 'Should create a new database' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $null = GenXdev\New-SQLServerDatabase -DatabaseName $script:TestDatabaseName -Server $script:TestServer -WhatIf:$false

        # Verify database was created
        $checkQuery = "SELECT database_id FROM sys.databases WHERE name = '$script:TestDatabaseName'"
        $result = GenXdev\Invoke-SQLServerQuery -DatabaseName 'master' -Server $script:TestServer -Queries $checkQuery
        $result | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It 'Should support WhatIf parameter' -Skip:(-not $script:SqlServerAvailable) {
        $null = { GenXdev\New-SQLServerDatabase -DatabaseName 'TestWhatIf' -Server $script:TestServer -WhatIf } | Pester\Should -Not -Throw
    }

    Pester\It 'Should apply the standard database settings' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $databaseName = 'GenXdevSettings_' + (Microsoft.PowerShell.Utility\Get-Random)

        try {
            $null = GenXdev\New-SQLServerDatabase -DatabaseName $databaseName `
                -Server $script:TestServer -WhatIf:$false

            $result = GenXdev\Invoke-SQLServerQuery -DatabaseName 'master' `
                -Server $script:TestServer `
                -Queries "SELECT recovery_model_desc, compatibility_level, page_verify_option_desc FROM sys.databases WHERE name = '$databaseName'"

            $result.recovery_model_desc | Pester\Should -Be 'SIMPLE'
            $result.page_verify_option_desc | Pester\Should -Be 'CHECKSUM'
        }
        finally {
            $dropQuery = "IF EXISTS (SELECT name FROM sys.databases WHERE name = '$databaseName') DROP DATABASE [$databaseName]"
            $null = GenXdev\Invoke-SQLServerQuery -DatabaseName 'master' `
                -Server $script:TestServer -Queries $dropQuery
        }
    }
}