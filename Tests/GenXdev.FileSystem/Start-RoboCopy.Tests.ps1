Pester\Describe 'Start-RoboCopy' {
    Pester\BeforeAll {
        $Script:testRoot = GenXdev\Expand-Path "$env:TEMP\GenXdev.FileSystem.Tests\" -CreateDirectory
        Microsoft.PowerShell.Management\Push-Location -LiteralPath ($Script:testRoot)
    }

    Pester\AfterAll {
        Microsoft.PowerShell.Management\Pop-Location
        GenXdev\Remove-AllItems -Confirm:$False  $Script:testRoot -DeleteFolder
    }

    Pester\BeforeEach {
        $Script:source = "$Script:testRoot\source"
        $Script:dest = "$Script:testRoot\dest"
        Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path $Script:source, $Script:dest -Force

        1..3 | Microsoft.PowerShell.Core\ForEach-Object {
            "test$_" | Microsoft.PowerShell.Utility\Out-File "$Script:source\file$_.txt"
        }
    }

    Pester\AfterEach {
        Microsoft.PowerShell.Management\Remove-Item -LiteralPath $Script:source, $Script:dest -Recurse -Force
    }

    Pester\It 'Copies files between folders' {
        GenXdev\Start-RoboCopy -Source $Script:source -DestinationDirectory $Script:dest
        $destFiles = Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath $Script:dest -File
        $destFiles.Count | Pester\Should -Be 3
    }

    Pester\It 'Moves files when specified' {
        GenXdev\Start-RoboCopy -Source $Script:source -DestinationDirectory $Script:dest -Move
        $sourceFiles = Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath $Script:source -File
        $sourceFiles.Count | Pester\Should -Be 0
        $destFiles = Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath $Script:dest -File
        $destFiles.Count | Pester\Should -Be 3
    }

    Pester\It 'Mirrors directory structure' {
        Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path "$Script:source\subfolder" -Force
        'subtest' | Microsoft.PowerShell.Utility\Out-File "$Script:source\subfolder\subfile.txt"

        GenXdev\Start-RoboCopy -Source $Script:source -DestinationDirectory $Script:dest -Mirror
        Microsoft.PowerShell.Management\Test-Path -LiteralPath "$Script:dest\subfolder\subfile.txt" | Pester\Should -Be $true
    }

    Pester\It 'Skips files larger then MaxFileSize bytes' {
        Microsoft.PowerShell.Management\Remove-Item -LiteralPath "$Script:source\file1.txt", "$Script:source\file2.txt", "$Script:source\file3.txt" -Force
        [IO.File]::WriteAllBytes("$Script:source\10bytes.bin", [byte[]]::new(10))
        [IO.File]::WriteAllBytes("$Script:source\2000bytes.bin", [byte[]]::new(2000))

        GenXdev\Start-RoboCopy -Source $Script:source -DestinationDirectory $Script:dest -MaxFileSize 100

        Microsoft.PowerShell.Management\Test-Path -LiteralPath "$Script:dest\10bytes.bin" | Pester\Should -Be $true
        Microsoft.PowerShell.Management\Test-Path -LiteralPath "$Script:dest\2000bytes.bin" | Pester\Should -Be $false
    }

    Pester\It 'Removes requested attributes from copied files' {
        GenXdev\Start-RoboCopy -Source $Script:source -DestinationDirectory $Script:dest -RemoveAttributesAfterCopy 'R'

        $destinationFile = Microsoft.PowerShell.Management\Get-Item -LiteralPath "$Script:dest\file1.txt"
        [bool]($destinationFile.Attributes -band [IO.FileAttributes]::ReadOnly) | Pester\Should -BeFalse
    }

    Pester\It 'Accepts valid MonitorMode run hours' {
        {
            GenXdev\Start-RoboCopy -Source $Script:source -DestinationDirectory $Script:dest `
                -MonitorModeRunHoursFrom 900 -MonitorModeRunHoursUntil 1730 -WhatIf
        } | Pester\Should -Not -Throw
    }

    Pester\It 'Rejects run hour minutes above 59' {
        {
            GenXdev\Start-RoboCopy -Source $Script:source -DestinationDirectory $Script:dest `
                -MonitorModeRunHoursFrom 960 -WhatIf
        } | Pester\Should -Throw -ExpectedMessage '*MonitorModeRunHoursFrom 0960*'

        {
            GenXdev\Start-RoboCopy -Source $Script:source -DestinationDirectory $Script:dest `
                -MonitorModeRunHoursUntil 967 -WhatIf
        } | Pester\Should -Throw -ExpectedMessage '*MonitorModeRunHoursUntil 0967*'
    }

    Pester\It 'Mirrors the destination when the source mask selects every file' {
        Microsoft.PowerShell.Management\Set-Content -LiteralPath "$Script:dest\extra.txt" -Value 'extra'

        GenXdev\Start-RoboCopy -Source "$Script:source\*" -DestinationDirectory $Script:dest -Mirror

        Microsoft.PowerShell.Management\Test-Path -LiteralPath "$Script:dest\file1.txt" | Pester\Should -Be $true
        Microsoft.PowerShell.Management\Test-Path -LiteralPath "$Script:dest\extra.txt" | Pester\Should -Be $false
    }

    Pester\It 'Does not delete from the destination when the source mask selects files' {
        Microsoft.PowerShell.Management\Set-Content -LiteralPath "$Script:dest\extra.txt" -Value 'extra'

        GenXdev\Start-RoboCopy -Source "$Script:source\*.txt" -DestinationDirectory $Script:dest `
            -Mirror -WarningAction SilentlyContinue

        Microsoft.PowerShell.Management\Test-Path -LiteralPath "$Script:dest\file1.txt" | Pester\Should -Be $true
        Microsoft.PowerShell.Management\Test-Path -LiteralPath "$Script:dest\extra.txt" | Pester\Should -Be $true
    }

    Pester\It 'Warns when -Mirror is skipped for a file mask' {
        GenXdev\Start-RoboCopy -Source "$Script:source\*.txt" -DestinationDirectory $Script:dest `
            -Mirror -WarningVariable mirrorWarning -WarningAction SilentlyContinue

        "$mirrorWarning" | Pester\Should -Match 'Mirror was skipped'
        "$mirrorWarning" | Pester\Should -Match 'MirrorWithSourceMask'
    }

    Pester\It 'Does not warn when -Mirror is applied' {
        GenXdev\Start-RoboCopy -Source "$Script:source\*" -DestinationDirectory $Script:dest `
            -Mirror -WarningVariable mirrorWarning -WarningAction SilentlyContinue

        "$mirrorWarning" | Pester\Should -BeNullOrEmpty
    }

    Pester\It 'Mirrors a file mask when -MirrorWithSourceMask is set' {
        Microsoft.PowerShell.Management\Set-Content -LiteralPath "$Script:dest\extra.txt" -Value 'extra'

        GenXdev\Start-RoboCopy -Source "$Script:source\*.txt" -DestinationDirectory $Script:dest `
            -Mirror -MirrorWithSourceMask -WarningVariable mirrorWarning -WarningAction SilentlyContinue

        Microsoft.PowerShell.Management\Test-Path -LiteralPath "$Script:dest\extra.txt" | Pester\Should -Be $false
        "$mirrorWarning" | Pester\Should -BeNullOrEmpty
    }

    Pester\It 'Does not warn when -Override supplies the mirror switch' {
        Microsoft.PowerShell.Management\Set-Content -LiteralPath "$Script:dest\extra.txt" -Value 'extra'

        GenXdev\Start-RoboCopy -Source "$Script:source\*.txt" -DestinationDirectory $Script:dest `
            -Mirror -Override '/MIR' -WarningVariable mirrorWarning -WarningAction SilentlyContinue

        Microsoft.PowerShell.Management\Test-Path -LiteralPath "$Script:dest\extra.txt" | Pester\Should -Be $false
        "$mirrorWarning" | Pester\Should -BeNullOrEmpty
    }
}