Pester\Describe 'Move-ToRecycleBin' {

    Pester\BeforeAll {
        $Script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.FileSystem.Tests\" -CreateDirectory
        Microsoft.PowerShell.Management\Set-Location -LiteralPath $Script:testRoot
        $Script:testFile = Microsoft.PowerShell.Management\Join-Path $Script:testRoot 'recycle-test.txt'
        Microsoft.PowerShell.Management\Set-Content -LiteralPath $Script:testFile -Value 'test content'
    }

    Pester\AfterAll {
        $Script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.FileSystem.Tests\" -CreateDirectory

        # cleanup test folder
        GenXdev\Remove-AllItems -Confirm:$False  $Script:testRoot -DeleteFolder
    }

    Pester\It 'Moves file to recycle bin' {

        GenXdev\Move-ToRecycleBin -Path $Script:testFile | Pester\Should -BeTrue
    }
}