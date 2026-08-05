Pester\Describe 'Get-SQLServerTableSchema' {

    Pester\BeforeAll {
        Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
        $script:TestTableName = 'TestSchemaTable_' + (Microsoft.PowerShell.Utility\Get-Random)
        $script:TestServer = '.'
        $script:TestConnectionString = "Server=$script:TestServer;Database=tempdb;Integrated Security=true;TrustServerCertificate=true"

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
            GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $createTableQuery
        }
    }

    Pester\AfterAll {
        # Clean-up
        if ($script:SqlServerAvailable) {
            try {
                $dropQuery = "IF OBJECT_ID('tempdb.dbo.${script:TestTableName}') IS NOT NULL DROP TABLE tempdb.dbo.${script:TestTableName}"
                GenXdev\Invoke-SQLServerQuery -DatabaseName 'tempdb' -Server $script:TestServer -Queries $dropQuery
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

    Pester\It 'Should retrieve table schema using DatabaseName parameter' -Skip:(-not $script:SqlServerAvailable) {
        $schema = GenXdev\Get-SQLServerTableSchema -DatabaseName 'tempdb' -Server $script:TestServer -TableName $script:TestTableName
        $schema | Pester\Should -Not -BeNullOrEmpty
        $schema.Count | Pester\Should -BeGreaterThan 0
    }

    Pester\It 'Should include column data types' -Skip:(-not $script:SqlServerAvailable) {
        $schema = GenXdev\Get-SQLServerTableSchema -ConnectionString $script:TestConnectionString -TableName $script:TestTableName

        # Check specific data types
        $nameColumn = $schema | Microsoft.PowerShell.Utility\Where-Object { $_.COLUMN_NAME -eq "Name" }
        $nameColumn.DATA_TYPE | Pester\Should -Be "nvarchar"

        $ageColumn = $schema | Microsoft.PowerShell.Utility\Where-Object { $_.COLUMN_NAME -eq "Age" }
        $ageColumn.DATA_TYPE | Pester\Should -Be "int"

        $salaryColumn = $schema | Microsoft.PowerShell.Utility\Where-Object { $_.COLUMN_NAME -eq "Salary" }
        $salaryColumn.DATA_TYPE | Pester\Should -Be "decimal"
    }
}