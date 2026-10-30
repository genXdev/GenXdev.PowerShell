Pester\Describe 'New-SQLiteDatabase' {

    Pester\BeforeAll {
        $script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.Data.SQLite.Tests\" -CreateDirectory
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$false $script:testRoot -DeleteFolder
    }

    Pester\It 'Creates a database file' {
        $databasePath = "$script:testRoot\New_$([System.Guid]::NewGuid()).sqlite"

        GenXdev\New-SQLiteDatabase -DatabaseFilePath $databasePath -WhatIf:$false

        Microsoft.PowerShell.Management\Test-Path -LiteralPath $databasePath |
            Pester\Should -BeTrue
    }

    Pester\It 'Creates the parent directory when it is missing' {
        $databasePath = "$script:testRoot\Missing_$([System.Guid]::NewGuid())\nested\Db.sqlite"

        GenXdev\New-SQLiteDatabase -DatabaseFilePath $databasePath -WhatIf:$false

        Microsoft.PowerShell.Management\Test-Path -LiteralPath $databasePath |
            Pester\Should -BeTrue
    }

    Pester\It 'Leaves an existing database file alone' {
        $databasePath = "$script:testRoot\Existing_$([System.Guid]::NewGuid()).sqlite"

        GenXdev\New-SQLiteDatabase -DatabaseFilePath $databasePath -WhatIf:$false
        $initialWrite = (Microsoft.PowerShell.Management\Get-Item -LiteralPath $databasePath).LastWriteTimeUtc

        { GenXdev\New-SQLiteDatabase -DatabaseFilePath $databasePath -WhatIf:$false } |
            Pester\Should -Not -Throw

        (Microsoft.PowerShell.Management\Get-Item -LiteralPath $databasePath).LastWriteTimeUtc |
            Pester\Should -Be $initialWrite
    }

    Pester\It 'Supports WhatIf without creating a file' {
        $databasePath = "$script:testRoot\WhatIf_$([System.Guid]::NewGuid()).sqlite"

        GenXdev\New-SQLiteDatabase -DatabaseFilePath $databasePath -WhatIf

        Microsoft.PowerShell.Management\Test-Path -LiteralPath $databasePath |
            Pester\Should -BeFalse
    }
}
