Pester\Describe 'Write-JsonFileAtomic' {

    Pester\BeforeAll {
        $Script:testRoot = GenXdev\Expand-Path `
            "$($env:TEMP)\GenXdev.JsonFile.Tests\" -CreateDirectory
        Microsoft.PowerShell.Management\Push-Location `
            -LiteralPath ($Script:testRoot)
    }

    Pester\AfterAll {
        GenXdev\Remove-AllItems -Confirm:$False  $Script:testRoot -DeleteFolder
    }

    Pester\BeforeEach {
        $Script:testFile = "$Script:testRoot\json-atomic-test.json"
        if (Microsoft.PowerShell.Management\Test-Path ($Script:testFile)) {
            Microsoft.PowerShell.Management\Remove-Item ($Script:testFile) -Force
        }
    }

    Pester\It 'Writes a Hashtable as indented JSON' {
        GenXdev\Write-JsonFileAtomic -FilePath ($Script:testFile) `
            -Data @{ name = 'test'; value = 42 }
        $Script:testFile | Pester\Should -Exist
        $result = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath ($Script:testFile) -Raw |
            Microsoft.PowerShell.Utility\ConvertFrom-Json
        $result.name | Pester\Should -Be 'test'
        $result.value | Pester\Should -Be 42
    }

    Pester\It 'Writes a PSCustomObject as JSON' {
        $obj = [PSCustomObject]@{
            Name   = 'Test'
            Age    = 30
            Active = $true
        }
        GenXdev\Write-JsonFileAtomic -FilePath ($Script:testFile) -Data $obj
        $result = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath ($Script:testFile) -Raw |
            Microsoft.PowerShell.Utility\ConvertFrom-Json
        $result.Name | Pester\Should -Be 'Test'
        $result.Age | Pester\Should -Be 30
        $result.Active | Pester\Should -BeTrue
    }

    Pester\It 'Writes nested objects with depth control' {
        $nested = [PSCustomObject]@{
            Level1 = [PSCustomObject]@{
                Level2 = [PSCustomObject]@{
                    Value = 'deep'
                }
            }
        }
        GenXdev\Write-JsonFileAtomic -FilePath ($Script:testFile) `
            -Data $nested -Depth 10
        $result = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath ($Script:testFile) -Raw |
            Microsoft.PowerShell.Utility\ConvertFrom-Json
        $result.Level1.Level2.Value | Pester\Should -Be 'deep'
    }

    Pester\It 'Produces Compress JSON with -Compress' {
        GenXdev\Write-JsonFileAtomic -FilePath ($Script:testFile) `
            -Data @{ a = 1; b = 2 } -Compress
        $raw = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath ($Script:testFile) -Raw
        # Compress JSON has no line breaks
        $raw -match '\r?\n' | Pester\Should -BeFalse
        $result = $raw | Microsoft.PowerShell.Utility\ConvertFrom-Json
        $result.a | Pester\Should -Be 1
        $result.b | Pester\Should -Be 2
    }

    Pester\It 'Debounce coalesces rapid writes to last object' {
        1..30 | Microsoft.PowerShell.Core\ForEach-Object {
            GenXdev\Write-JsonFileAtomic -FilePath ($Script:testFile) `
                -Data @{ iteration = $_; ts = Microsoft.PowerShell.Utility\Get-Date } `
                -DebounceMs 5000
        }
        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 7
        $result = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath ($Script:testFile) -Raw |
            Microsoft.PowerShell.Utility\ConvertFrom-Json
        $result.iteration | Pester\Should -Be 30
    }

    Pester\It 'Retries with MaxRetries and RetryDelayMs' {
        GenXdev\Write-JsonFileAtomic -FilePath ($Script:testFile) `
            -Data @{ status = 'ok' } -MaxRetries 10 -RetryDelayMs 100
        $result = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath ($Script:testFile) -Raw |
            Microsoft.PowerShell.Utility\ConvertFrom-Json
        $result.status | Pester\Should -Be 'ok'
    }

    Pester\It 'Handles empty hashtable' {
        GenXdev\Write-JsonFileAtomic -FilePath ($Script:testFile) -Data @{ }
        $raw = Microsoft.PowerShell.Management\Get-Content `
            -LiteralPath ($Script:testFile) -Raw
        # Empty hashtable serializes to {}
        $raw -replace '\s' | Pester\Should -Be '{}'
    }
}
