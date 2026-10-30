Pester\Describe 'Invoke-SQLServerScriptFile' {

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
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SqlServer.Tests\" -CreateDirectory
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

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$False $script:testRoot -DeleteFolder
    }

    Pester\It 'Reports that no script files were provided' {
        { GenXdev\Invoke-SQLServerScriptFile -ErrorAction Stop } |
            Pester\Should -Throw -ExpectedMessage '*No script files were provided*'
    }

    Pester\It 'Reports a missing script file when -ErrorAction is Stop' {
        {
            GenXdev\Invoke-SQLServerScriptFile `
                -Name "$script:testRoot\missing.sql" -ErrorAction Stop
        } | Pester\Should -Throw -ExpectedMessage '*Cannot find script file*'
    }

    Pester\It 'Stays silent for a missing script file when -ErrorAction is SilentlyContinue' {
        {
            GenXdev\Invoke-SQLServerScriptFile `
                -Name "$script:testRoot\missing.sql" -ErrorAction SilentlyContinue
        } | Pester\Should -Not -Throw
    }

    Pester\It 'Reports a directory passed as a script file' {
        {
            GenXdev\Invoke-SQLServerScriptFile -Name $script:testRoot `
                -ErrorAction Stop
        } | Pester\Should -Throw -ExpectedMessage '*it is a directory*'
    }

    Pester\It 'Uses $ErrorActionPreference when -ErrorAction is not bound' {
        $previousPreference = $ErrorActionPreference

        try {
            $ErrorActionPreference = 'Stop'
            {
                GenXdev\Invoke-SQLServerScriptFile `
                    -Name "$script:testRoot\missing.sql"
            } | Pester\Should -Throw -ExpectedMessage '*Cannot find script file*'
        }
        finally {
            $ErrorActionPreference = $previousPreference
        }
    }

    Pester\It 'Lets -ErrorAction override $ErrorActionPreference' {
        $previousPreference = $ErrorActionPreference

        try {
            $ErrorActionPreference = 'Stop'
            {
                GenXdev\Invoke-SQLServerScriptFile `
                    -Name "$script:testRoot\missing.sql" `
                    -ErrorAction SilentlyContinue
            } | Pester\Should -Not -Throw
        }
        finally {
            $ErrorActionPreference = $previousPreference
        }
    }

    Pester\It 'Accepts FileInfo objects from the pipeline' {
        $fileInfo = [System.IO.FileInfo]::new("$script:testRoot\missing.sql")

        { $fileInfo | GenXdev\Invoke-SQLServerScriptFile -ErrorAction Stop } |
            Pester\Should -Throw -ExpectedMessage '*Cannot find script file*'
    }

    Pester\It 'Rejects input that is neither a name nor a FileInfo object' {
        { 42 | GenXdev\Invoke-SQLServerScriptFile -ErrorAction Stop } |
            Pester\Should -Throw -ExpectedMessage '*file name or a FileInfo object*'
    }

    Pester\It 'Does not accept -Name together with pipeline input' {
        {
            "$script:testRoot\one.sql" | GenXdev\Invoke-SQLServerScriptFile `
                -Name "$script:testRoot\two.sql" -ErrorAction Stop
        } | Pester\Should -Throw
    }

    Pester\It 'Executes every batch of a script file' -Skip:(-not $script:SqlServerAvailable) {
        $script:tableName = 'TestBatches_' + (Microsoft.PowerShell.Utility\Get-Random)
        $scriptFile = "$script:testRoot\batches.sql"

        # the last batch has no trailing GO
        $content = @"
CREATE TABLE tempdb.dbo.$($script:tableName) (Id int)
GO
INSERT INTO tempdb.dbo.$($script:tableName) (Id) VALUES (1)
GO
INSERT INTO tempdb.dbo.$($script:tableName) (Id) VALUES (2)
"@
        [System.IO.File]::WriteAllText(
            $scriptFile, $content, [System.Text.UTF8Encoding]::new($false))

        try {
            GenXdev\Invoke-SQLServerScriptFile -Name $scriptFile `
                -ConnectionString $script:TestConnectionString

            $result = GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString `
                -Queries "SELECT COUNT(*) as [RowCount] FROM tempdb.dbo.$($script:tableName)"

            $result.RowCount | Pester\Should -Be 2
        }
        finally {
            GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString `
                -Queries ("IF OBJECT_ID('tempdb.dbo.$($script:tableName)') IS NOT NULL " +
                "DROP TABLE tempdb.dbo.$($script:tableName)")
        }
    }

    Pester\It 'Repeats a batch for the GO repeat count' -Skip:(-not $script:SqlServerAvailable) {
        $script:tableName = 'TestRepeats_' + (Microsoft.PowerShell.Utility\Get-Random)
        $scriptFile = "$script:testRoot\repeats.sql"

        $content = @"
CREATE TABLE tempdb.dbo.$($script:tableName) (Id int)
GO
INSERT INTO tempdb.dbo.$($script:tableName) (Id) VALUES (1)
GO 3
"@
        [System.IO.File]::WriteAllText(
            $scriptFile, $content, [System.Text.UTF8Encoding]::new($false))

        try {
            GenXdev\Invoke-SQLServerScriptFile -Name $scriptFile `
                -ConnectionString $script:TestConnectionString

            $result = GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString `
                -Queries "SELECT COUNT(*) as [RowCount] FROM tempdb.dbo.$($script:tableName)"

            $result.RowCount | Pester\Should -Be 3
        }
        finally {
            GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString `
                -Queries ("IF OBJECT_ID('tempdb.dbo.$($script:tableName)') IS NOT NULL " +
                "DROP TABLE tempdb.dbo.$($script:tableName)")
        }
    }

    Pester\It 'Continues with the next batch when a batch fails' -Skip:(-not $script:SqlServerAvailable) {
        $script:tableName = 'TestFailures_' + (Microsoft.PowerShell.Utility\Get-Random)
        $scriptFile = "$script:testRoot\failures.sql"

        $content = @"
CREATE TABLE tempdb.dbo.$($script:tableName) (Id int)
GO
SELECT * FROM tempdb.dbo.NonExistentTable
GO
INSERT INTO tempdb.dbo.$($script:tableName) (Id) VALUES (7)
"@
        [System.IO.File]::WriteAllText(
            $scriptFile, $content, [System.Text.UTF8Encoding]::new($false))

        try {
            GenXdev\Invoke-SQLServerScriptFile -Name $scriptFile `
                -ConnectionString $script:TestConnectionString `
                -ErrorAction SilentlyContinue -ErrorVariable scriptErrors

            $scriptErrors.Count | Pester\Should -BeGreaterOrEqual 1

            $result = GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString `
                -Queries "SELECT COUNT(*) as [RowCount] FROM tempdb.dbo.$($script:tableName)"

            $result.RowCount | Pester\Should -Be 1
        }
        finally {
            GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString `
                -Queries ("IF OBJECT_ID('tempdb.dbo.$($script:tableName)') IS NOT NULL " +
                "DROP TABLE tempdb.dbo.$($script:tableName)")
        }
    }

    Pester\It 'Executes script files in the order given' -Skip:(-not $script:SqlServerAvailable) {
        $script:tableName = 'TestOrder_' + (Microsoft.PowerShell.Utility\Get-Random)
        $firstFile = "$script:testRoot\first.sql"
        $secondFile = "$script:testRoot\second.sql"

        [System.IO.File]::WriteAllText(
            $firstFile,
            "INSERT INTO tempdb.dbo.$($script:tableName) (Name) VALUES ('first')",
            [System.Text.UTF8Encoding]::new($false))

        [System.IO.File]::WriteAllText(
            $secondFile,
            "INSERT INTO tempdb.dbo.$($script:tableName) (Name) VALUES ('second')",
            [System.Text.UTF8Encoding]::new($false))

        try {
            GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString `
                -Queries ("CREATE TABLE tempdb.dbo.$($script:tableName) " +
                '(Id int IDENTITY(1,1), Name nvarchar(50))')

            GenXdev\Invoke-SQLServerScriptFile -Name $secondFile, $firstFile `
                -ConnectionString $script:TestConnectionString

            $result = GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString `
                -Queries "SELECT Name FROM tempdb.dbo.$($script:tableName) ORDER BY Id"

            $result[0].Name | Pester\Should -Be 'second'
            $result[1].Name | Pester\Should -Be 'first'
        }
        finally {
            GenXdev\Invoke-SQLServerQuery -ConnectionString $script:TestConnectionString `
                -Queries ("IF OBJECT_ID('tempdb.dbo.$($script:tableName)') IS NOT NULL " +
                "DROP TABLE tempdb.dbo.$($script:tableName)")
        }
    }

    Pester\It 'Reports progress for a parent activity' -Skip:(-not $script:SqlServerAvailable) {
        $tableName = "Progress_$([System.Guid]::NewGuid().ToString('N'))"
        $scriptFile = "$script:testRoot\progress_$([System.Guid]::NewGuid()).sql"

        $content = @"
CREATE TABLE tempdb.dbo.$tableName (Id int)
GO
INSERT INTO tempdb.dbo.$tableName (Id) VALUES (1)
GO
INSERT INTO tempdb.dbo.$tableName (Id) VALUES (2)
"@
        [System.IO.File]::WriteAllText(
            $scriptFile, $content, [System.Text.UTF8Encoding]::new($false))

        try {
            { GenXdev\Invoke-SQLServerScriptFile -Name $scriptFile `
                -ConnectionString $script:TestConnectionString `
                -ParentProgressId 1 } | Pester\Should -Not -Throw

            $result = GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString `
                -Queries "SELECT COUNT(*) as [RowCount] FROM tempdb.dbo.$tableName"

            $result.RowCount | Pester\Should -Be 2
        }
        finally {
            $null = GenXdev\Invoke-SQLServerQuery `
                -ConnectionString $script:TestConnectionString `
                -Queries "IF OBJECT_ID('tempdb.dbo.$tableName') IS NOT NULL DROP TABLE tempdb.dbo.$tableName"
        }
    }
}
