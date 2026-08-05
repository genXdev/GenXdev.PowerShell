Pester\Describe 'Write-FileAtomic' {

    Pester\BeforeAll {
        $Script:testRoot = GenXdev\Expand-Path `
            "$env:TEMP\GenXdev.FileSystem.Tests\" -CreateDirectory
        Microsoft.PowerShell.Management\Push-Location `
            -LiteralPath ($Script:testRoot)
    }

    Pester\AfterAll {
        Microsoft.PowerShell.Management\Pop-Location
        GenXdev\Remove-AllItems -Confirm:$False  $Script:testRoot -DeleteFolder
    }

    Pester\BeforeEach {
        $Script:testFile = "$Script:testRoot\debounce-test.bin"
        if (Microsoft.PowerShell.Management\Test-Path $Script:testFile) {
            Microsoft.PowerShell.Management\Remove-Item $Script:testFile -Force
        }
    }

    Pester\It 'Writes byte array atomically' {
        $bytes = [System.Text.Encoding]::UTF8.GetBytes('hello-genxdev')
        GenXdev\Write-FileAtomic -FilePath $Script:testFile -Data $bytes
        $result = [System.IO.File]::ReadAllBytes($Script:testFile)
        [System.Text.Encoding]::UTF8.GetString($result) |
            Pester\Should -Be 'hello-genxdev'
    }

    Pester\It 'Debounce: only the last write within 5 seconds hits disk, content is 100' {
        1..100 | Microsoft.PowerShell.Core\ForEach-Object {
            GenXdev\Write-FileAtomic -FilePath $Script:testFile `
                -Data ([System.BitConverter]::GetBytes($_)) `
                -DebounceMs 5000
        }
        # Wait for the debounce timer to fire + write to complete
        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 7

        $result = [System.IO.File]::ReadAllBytes($Script:testFile)
        [System.BitConverter]::ToInt32($result, 0) |
            Pester\Should -Be 100
    }

    Pester\It 'Retries on failure with MaxRetries and RetryDelayMs' {
        GenXdev\Write-FileAtomic -FilePath $Script:testFile `
            -Data ([byte[]]@(0xDE, 0xAD)) `
            -MaxRetries 10 -RetryDelayMs 100
        $result = [System.IO.File]::ReadAllBytes($Script:testFile)
        $result[0] | Pester\Should -Be 0xDE
        $result[1] | Pester\Should -Be 0xAD
    }

    Pester\It 'Auto-creates parent directories' {
        $deepFile = "$Script:testRoot\deep\nested\dirs\auto-create.bin"
        $bytes = [byte[]]@(1, 2, 3)
        GenXdev\Write-FileAtomic -FilePath $deepFile -Data $bytes
        $deepFile | Pester\Should -Exist
        $result = [System.IO.File]::ReadAllBytes($deepFile)
        $result.Length | Pester\Should -Be 3
    }

    Pester\It 'Handles empty byte array' {
        $bytes = [byte[]]@()
        GenXdev\Write-FileAtomic -FilePath $Script:testFile -Data $bytes
        $result = [System.IO.File]::ReadAllBytes($Script:testFile)
        $result.Length | Pester\Should -Be 0
    }

    Pester\It 'Handles large data (1MB+)' {
        $bytes = [byte[]]::new(1048576)
        # Fill with a pattern
        for ($i = 0; $i -lt $bytes.Length; $i++) {
            $bytes[$i] = [byte]($i % 256)
        }
        GenXdev\Write-FileAtomic -FilePath $Script:testFile -Data $bytes
        $result = [System.IO.File]::ReadAllBytes($Script:testFile)
        $result.Length | Pester\Should -Be 1048576
        $result[0] | Pester\Should -Be 0
        $result[255] | Pester\Should -Be 255
    }

    Pester\It 'Overwrites existing file content completely' {
        # First write
        $firstBytes = [byte[]]@(1, 2, 3, 4, 5, 6, 7, 8)
        GenXdev\Write-FileAtomic -FilePath $Script:testFile -Data $firstBytes
        # Overwrite with shorter content
        $bytes = [byte[]]@(0xA, 0xB)
        GenXdev\Write-FileAtomic -FilePath $Script:testFile -Data $bytes
        $result = [System.IO.File]::ReadAllBytes($Script:testFile)
        $result.Length | Pester\Should -Be 2
        $result[0] | Pester\Should -Be 0xA
        $result[1] | Pester\Should -Be 0xB
    }
}