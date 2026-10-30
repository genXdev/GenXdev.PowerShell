Pester\Describe 'Get-SQLServerTableSchema' {

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
        $script:TestTableName = 'TestSchemaTable_' + (Microsoft.PowerShell.Utility\Get-Random)
        . "$PSScriptRoot\SqlServerTestHelpers.ps1"

        # run against $env:GENXDEV_SQL_TEST_CONNECTIONSTRING, or the local default
        $script:TestConfiguration = Get-SqlServerTestConfiguration
        $script:TestServer = $script:TestConfiguration.Server
        $script:TestConnectionString = $script:TestConfiguration.ConnectionString
        $script:CanUseServerParameter = $script:TestConfiguration.CanUseServerParameter

        # Check if SQL Server is available
        $script:SqlServerAvailable = $false
        try {
            GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString -Queries "SELECT 1"
            $script:SqlServerAvailable = $true
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Warning (
                'SQL Server not available - skipping database tests: ' +
                $_.Exception.Message)
        }

        if ($script:SqlServerAvailable) {
            # Create test table with various column types in tempdb
            $createTableQuery = @"
CREATE TABLE tempdb.dbo.${script:TestTableName} (
    Id int IDENTITY(1,1) PRIMARY KEY,
    Name nvarchar(100) NOT NULL,
    Email nvarchar(255),
    Age int,
    Salary decimal(10,2),
    IsActive bit DEFAULT 1,
    CreatedDate datetime2 DEFAULT GETDATE()
)
"@
            GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString -Queries $createTableQuery
        }
    }

    Pester\AfterAll {
        # Clean-up
        if ($script:SqlServerAvailable) {
            try {
                $dropQuery = "IF OBJECT_ID('tempdb.dbo.${script:TestTableName}') IS NOT NULL DROP TABLE tempdb.dbo.${script:TestTableName}"
                GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString -Queries $dropQuery
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Could not clean up test table: $_"
            }
        }
    }

    Pester\It 'Should retrieve table schema using connection string' -Skip:(-not $script:SqlServerAvailable) {
        $schema = GenXdev\Get-SQLServerTableSchema -ConnectionString $script:TestConnectionString -TableName $script:TestTableName
        $schema | Pester\Should -Not -BeNullOrEmpty

        # Check that we got the expected columns
        $columnNames = $schema | Microsoft.PowerShell.Core\ForEach-Object { $_.COLUMN_NAME }
        $columnNames | Pester\Should -Contain "Id"
        $columnNames | Pester\Should -Contain "Name"
        $columnNames | Pester\Should -Contain "Email"
        $columnNames | Pester\Should -Contain "Age"
        $columnNames | Pester\Should -Contain "Salary"
        $columnNames | Pester\Should -Contain "IsActive"
        $columnNames | Pester\Should -Contain "CreatedDate"
    }

    Pester\It 'Should retrieve table schema using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable -or -not $script:CanUseServerParameter) {
        $schema = GenXdev\Get-SQLServerTableSchema -DatabaseName 'tempdb' -Server $script:TestServer -TableName $script:TestTableName
        $schema | Pester\Should -Not -BeNullOrEmpty
        $schema.Count | Pester\Should -BeGreaterThan 0
    }

    Pester\It 'Should include column data types' -Skip:(-not $script:SqlServerAvailable) {
        $schema = GenXdev\Get-SQLServerTableSchema -ConnectionString $script:TestConnectionString -TableName $script:TestTableName

        # Check specific data types
        $nameColumn = $schema | Microsoft.PowerShell.Core\Where-Object { $_.COLUMN_NAME -eq "Name" }
        $nameColumn.DATA_TYPE | Pester\Should -Be "nvarchar"

        $ageColumn = $schema | Microsoft.PowerShell.Core\Where-Object { $_.COLUMN_NAME -eq "Age" }
        $ageColumn.DATA_TYPE | Pester\Should -Be "int"

        $salaryColumn = $schema | Microsoft.PowerShell.Core\Where-Object { $_.COLUMN_NAME -eq "Salary" }
        $salaryColumn.DATA_TYPE | Pester\Should -Be "decimal"
    }
}