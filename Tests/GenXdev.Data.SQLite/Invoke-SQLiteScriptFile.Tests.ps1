Pester\Describe 'Invoke-SQLiteScriptFile' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
        $script:databasePath = "$script:testRoot\ScriptFile_$([System.Guid]::NewGuid()).sqlite"

        $null = GenXdev\New-SQLiteDatabase -DatabaseFilePath $script:databasePath -WhatIf:$false
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Reports that no script files were provided' {
        { GenXdev\Invoke-SQLiteScriptFile -ErrorAction Stop } |
            Pester\Should -Throw -ExpectedMessage '*No script files were provided*'
    }

    Pester\It 'Reports a missing script file' {
        {
            GenXdev\Invoke-SQLiteScriptFile `
                -Name "$script:testRoot\missing.sql" `
                -DatabaseFilePath $script:databasePath -ErrorAction Stop
        } | Pester\Should -Throw -ExpectedMessage '*Cannot find script file*'
    }

    Pester\It 'Reports a directory passed as a script file' {
        {
            GenXdev\Invoke-SQLiteScriptFile -Name $script:testRoot `
                -DatabaseFilePath $script:databasePath -ErrorAction Stop
        } | Pester\Should -Throw -ExpectedMessage '*it is a directory*'
    }

    Pester\It 'Accepts FileInfo objects from the pipeline' {
        $fileInfo = [System.IO.FileInfo]::new("$script:testRoot\missing.sql")

        {
            $fileInfo | GenXdev\Invoke-SQLiteScriptFile `
                -DatabaseFilePath $script:databasePath -ErrorAction Stop
        } | Pester\Should -Throw -ExpectedMessage '*Cannot find script file*'
    }

    Pester\It 'Rejects input that is neither a name nor a FileInfo object' {
        {
            42 | GenXdev\Invoke-SQLiteScriptFile `
                -DatabaseFilePath $script:databasePath -ErrorAction Stop
        } | Pester\Should -Throw -ExpectedMessage '*file name or a FileInfo object*'
    }

    Pester\It 'Executes every batch of a script file' {
        $scriptFile = "$script:testRoot\batches_$([System.Guid]::NewGuid()).sql"

        # the last batch has no trailing GO
        $content = @"
CREATE TABLE Batches (Id INTEGER)
GO
INSERT INTO Batches (Id) VALUES (1)
GO
INSERT INTO Batches (Id) VALUES (2)
"@
        [System.IO.File]::WriteAllText(
            $scriptFile, $content, [System.Text.UTF8Encoding]::new($false))

        GenXdev\Invoke-SQLiteScriptFile -Name $scriptFile `
            -DatabaseFilePath $script:databasePath

        $result = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries 'SELECT COUNT(*) as RowCount FROM Batches'

        $result.RowCount | Pester\Should -Be 2

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries 'DROP TABLE Batches'
    }

    Pester\It 'Repeats a batch for the GO repeat count' {
        $scriptFile = "$script:testRoot\repeats_$([System.Guid]::NewGuid()).sql"

        $content = @"
CREATE TABLE Repeats (Id INTEGER)
GO
INSERT INTO Repeats (Id) VALUES (1)
GO 3
"@
        [System.IO.File]::WriteAllText(
            $scriptFile, $content, [System.Text.UTF8Encoding]::new($false))

        GenXdev\Invoke-SQLiteScriptFile -Name $scriptFile `
            -DatabaseFilePath $script:databasePath

        $result = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries 'SELECT COUNT(*) as RowCount FROM Repeats'

        $result.RowCount | Pester\Should -Be 3

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries 'DROP TABLE Repeats'
    }

    Pester\It 'Continues with the next batch when a batch fails' {
        $scriptFile = "$script:testRoot\failures_$([System.Guid]::NewGuid()).sql"

        $content = @"
CREATE TABLE Failures (Id INTEGER)
GO
SELECT * FROM NonExistentTable
GO
INSERT INTO Failures (Id) VALUES (7)
"@
        [System.IO.File]::WriteAllText(
            $scriptFile, $content, [System.Text.UTF8Encoding]::new($false))

        GenXdev\Invoke-SQLiteScriptFile -Name $scriptFile `
            -DatabaseFilePath $script:databasePath `
            -ErrorAction SilentlyContinue -ErrorVariable scriptErrors

        $scriptErrors.Count | Pester\Should -BeGreaterOrEqual 1

        $result = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries 'SELECT COUNT(*) as RowCount FROM Failures'

        $result.RowCount | Pester\Should -Be 1

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries 'DROP TABLE Failures'
    }

    Pester\It 'Executes script files in the order given' {
        $tableName = "Order_$([System.Guid]::NewGuid().ToString('N'))"
        $firstFile = "$script:testRoot\first_$([System.Guid]::NewGuid()).sql"
        $secondFile = "$script:testRoot\second_$([System.Guid]::NewGuid()).sql"

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "CREATE TABLE $tableName (Id INTEGER PRIMARY KEY, Name TEXT)"

        [System.IO.File]::WriteAllText(
            $firstFile,
            "INSERT INTO $tableName (Name) VALUES ('first')",
            [System.Text.UTF8Encoding]::new($false))

        [System.IO.File]::WriteAllText(
            $secondFile,
            "INSERT INTO $tableName (Name) VALUES ('second')",
            [System.Text.UTF8Encoding]::new($false))

        GenXdev\Invoke-SQLiteScriptFile -Name $secondFile, $firstFile `
            -DatabaseFilePath $script:databasePath

        $result = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "SELECT Name FROM $tableName ORDER BY Id"

        $result[0].Name | Pester\Should -Be 'second'
        $result[1].Name | Pester\Should -Be 'first'

        $null = GenXdev\Invoke-SQLiteQuery -DatabaseFilePath $script:databasePath `
            -Queries "DROP TABLE $tableName"
    }

    Pester\It 'Executes on a caller-owned connection' {
        $scriptFile = "$script:testRoot\connection_$([System.Guid]::NewGuid()).sql"

        $content = @"
CREATE TABLE ConnectionBatch (Id INTEGER)
GO
INSERT INTO ConnectionBatch (Id) VALUES (4)
"@
        [System.IO.File]::WriteAllText(
            $scriptFile, $content, [System.Text.UTF8Encoding]::new($false))

        $connection = GenXdev\Get-SQLiteConnection `
            -DatabaseFilePath $script:databasePath

        try {
            GenXdev\Invoke-SQLiteScriptFile -Name $scriptFile -Connection $connection

            $result = GenXdev\Invoke-SQLiteQuery -Connection $connection `
                -Queries 'SELECT COUNT(*) as RowCount FROM ConnectionBatch'

            $result.RowCount | Pester\Should -Be 1

            $null = GenXdev\Invoke-SQLiteQuery -Connection $connection `
                -Queries 'DROP TABLE ConnectionBatch'
        }
        finally {
            $connection.Close()
        }
    }

    Pester\It 'Reports progress for a parent activity' {
        $tableName = "Progress_$([System.Guid]::NewGuid().ToString('N'))"
        $scriptFile = "$script:testRoot\progress_$([System.Guid]::NewGuid()).sql"

        $content = @"
CREATE TABLE $tableName (Id INTEGER)
GO
INSERT INTO $tableName (Id) VALUES (1)
GO
INSERT INTO $tableName (Id) VALUES (2)
"@
        [System.IO.File]::WriteAllText(
            $scriptFile, $content, [System.Text.UTF8Encoding]::new($false))

        try {
            { GenXdev\Invoke-SQLiteScriptFile -Name $scriptFile `
                -DatabaseFilePath $script:databasePath `
                -ParentProgressId 1 } | Pester\Should -Not -Throw

            $result = GenXdev\Invoke-SQLiteQuery `
                -DatabaseFilePath $script:databasePath `
                -Queries "SELECT COUNT(*) as RowCount FROM $tableName"

            $result.RowCount | Pester\Should -Be 2
        }
        finally {
            $null = GenXdev\Invoke-SQLiteQuery `
                -DatabaseFilePath $script:databasePath `
                -Queries "DROP TABLE $tableName"
        }
    }
}
