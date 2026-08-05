Pester\Describe 'Write-TextFileAtomic' {

    Pester\BeforeAll {
        $Script:testRoot = GenXdev\Expand-Path `
            "$env:TEMP\GenXdev.TextFile.Tests\" -CreateDirectory
        Microsoft.PowerShell.Management\Push-Location `
            -LiteralPath ($Script:testRoot)
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$False  $Script:testRoot -DeleteFolder
    }

    Pester\BeforeEach {
        $Script:testFile = "$Script:testRoot\text-atomic-test.txt"
        if (Microsoft.PowerShell.Management\Test-Path $Script:testFile) {
            Microsoft.PowerShell.Management\Remove-Item $Script:testFile -Force
        }
    }

    Pester\It 'Writes UTF-8 text atomically' {
        GenXdev\Write-TextFileAtomic -FilePath $Script:testFile `
            -Data 'hello world from GenXdev'
        $Script:testFile | Pester\Should -Exist
        $result = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath $Script:testFile -Raw
        $result | Pester\Should -Be 'hello world from GenXdev'
    }

    Pester\It 'Debounce coalesces rapid writes to last text' {
        1..50 | Microsoft.PowerShell.Core\ForEach-Object {
            GenXdev\Write-TextFileAtomic -FilePath $Script:testFile `
                -Data "iteration $_" -DebounceMs 5000
        }
        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 7
        $result = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath $Script:testFile -Raw
        $result | Pester\Should -Be 'iteration 50'
    }

    Pester\It 'Handles empty string' {
        GenXdev\Write-TextFileAtomic -FilePath $Script:testFile -Data ''
        $result = [System.IO.File]::ReadAllBytes($Script:testFile)
        $result.Length | Pester\Should -Be 0
    }

    Pester\It 'Handles special characters and emoji' {
        $text = '😀 café résumé — em dash "quotes" ümlaut'
        GenXdev\Write-TextFileAtomic -FilePath $Script:testFile -Data $text
        $result = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath $Script:testFile -Raw
        $result | Pester\Should -Be $text
    }
}
