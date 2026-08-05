Pester\Describe 'Remove-AllItems -Confirm:$False ' {

    Pester\BeforeAll {
        $Script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.FileSystem.Tests\" -CreateDirectory
        Microsoft.PowerShell.Management\Push-Location -LiteralPath $testRoot
    }

    Pester\AfterAll {
        # Pop back from the test directory before cleanup to avoid
        # "process cannot access" errors when deleting the current directory
        Microsoft.PowerShell.Management\Pop-Location

        $Script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.FileSystem.Tests\" -CreateDirectory

        # cleanup test folder
        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $testRoot) {
            $null = GenXdev\Remove-AllItems -Confirm:$False  $testRoot -DeleteFolder
        }
    }

    Pester\BeforeEach {
        # setup test folder structure
        $testPath = "$testRoot\delete_test"
        Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path $testPath -Force
        Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path "$testPath\subdir" -Force
        'test1' | Microsoft.PowerShell.Utility\Out-File "$testPath\file1.txt"
        'test2' | Microsoft.PowerShell.Utility\Out-File "$testPath\subdir\file2.txt"
    }

    Pester\It 'Removes all files and subdirectories' {
        $null = GenXdev\Remove-AllItems -Confirm:$False  -Path $testPath
        $remaining = @(Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath $testPath -Recurse -ErrorAction SilentlyContinue)
        $remaining.Count | Pester\Should -Be 0
    }

    Pester\It 'Removes root folder when specified' {
        $null = GenXdev\Remove-AllItems -Confirm:$False  -Path $testPath -DeleteFolder
        Microsoft.PowerShell.Management\Test-Path -LiteralPath $testPath | Pester\Should -Be $false
    }

    Pester\It 'Shows what-if output without deleting' {
        $null = GenXdev\Remove-AllItems -Confirm:$False  -Path $testPath -WhatIf
        Microsoft.PowerShell.Management\Test-Path -LiteralPath $testPath | Pester\Should -Be $true
        $items = @(Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath $testPath -Recurse -ErrorAction SilentlyContinue)
        $items.Count | Pester\Should -BeGreaterThan 0
    }
}