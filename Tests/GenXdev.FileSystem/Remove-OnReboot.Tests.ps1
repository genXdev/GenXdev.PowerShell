Pester\Describe 'Remove-OnReboot' {

    Pester\BeforeAll {
        $testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.FileSystem.Tests\" -CreateDirectory
        Microsoft.PowerShell.Management\Set-Location -LiteralPath $testRoot
        $testFile = Microsoft.PowerShell.Management\Join-Path $testRoot 'reboot-delete.txt'
        Microsoft.PowerShell.Management\Set-Content -LiteralPath $testFile -Value 'test content'
    }

    Pester\AfterAll {
        $testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.FileSystem.Tests\" -CreateDirectory
        GenXdev\Remove-AllItems -Confirm:$False  $testRoot -DeleteFolder
    }

    Pester\It 'Marks file for deletion on reboot' {
        GenXdev\Remove-OnReboot -Path $testFile | Pester\Should -BeTrue
    }
}