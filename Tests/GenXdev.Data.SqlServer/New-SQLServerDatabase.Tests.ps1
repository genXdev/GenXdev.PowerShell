Pester\Describe 'New-SQLServerDatabase' {

    Pester\BeforeAll {
        Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
        $script:TestDatabaseName = 'GenXdevTest_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:TestServer = '.'

        # Check if SQL Server is available
        $script:SqlServerAvailable = $false
        try {
            GenXdev\Invoke-SQLServerQuery -DatabaseName 'master' -Server $script:TestServer -Queries "SELECT 1"
            $script:SqlServerAvailable = $true
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose "SQL Server not available - skipping tests"
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

    Pester\It 'Should create a new database' -Skip:(-not $script:SqlServerAvailable) {
        $null = GenXdev\New-SQLServerDatabase -DatabaseName $script:TestDatabaseName -Server $script:TestServer -WhatIf:$false

        # Verify database was created
        $checkQuery = "SELECT database_id FROM sys.databases WHERE name = '$script:TestDatabaseName'"
        $result = GenXdev\Invoke-SQLServerQuery -DatabaseName 'master' -Server $script:TestServer -Queries $checkQuery
        $result | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It 'Should support WhatIf parameter' -Skip:(-not $script:SqlServerAvailable) {
        $null = { GenXdev\New-SQLServerDatabase -DatabaseName 'TestWhatIf' -Server $script:TestServer -WhatIf } | Pester\Should -Not -Throw
    }
}