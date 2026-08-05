Pester\Describe 'Expand-Path unit tests' {

    Pester\BeforeAll {

        # define test paths
        $Script:testPath = [IO.Path]::GetFullPath("$($Env:TEMP)")
        $Script:testFile = Microsoft.PowerShell.Management\Join-Path $Script:testPath 'test.txt'
    }

    Pester\It 'expands relative path to absolute path' {
        # arrange
        $relativePath = '.\test.txt'
        Microsoft.PowerShell.Management\Push-Location -LiteralPath $Script:testPath

        # act
        $result = GenXdev\Expand-Path $relativePath

        # assert
        $result | Pester\Should -Be "$((Microsoft.PowerShell.Management\Get-Location).Path)\test.txt"

        # cleanup
        Microsoft.PowerShell.Management\Pop-Location
    }

    Pester\It 'handles UNC paths' {
        # arrange
        $uncPath = '\\server\share\file.txt'

        # act
        $result = GenXdev\Expand-Path $uncPath

        # assert
        $result | Pester\Should -Be $uncPath
    }

    Pester\It 'preserves UNC paths exactly as provided' {
        # arrange
        $uncPath = '\\server\share\file.txt'

        # act
        $result = GenXdev\Expand-Path $uncPath

        # assert
        $result | Pester\Should -Be $uncPath
    }

    Pester\It 'preserves UNC paths with trailing slashes' {
        # arrange
        $uncPath = '\\webserver\sites\powershell.genxdev.net\'

        # act
        $result = GenXdev\Expand-Path $uncPath

        # assert
        $result | Pester\Should -Be '\\webserver\sites\powershell.genxdev.net'
        $result | Pester\Should -Not -Be 'e:\webserver\sites\powershell.genxdev.net'
        $result | Pester\Should -Match '^\\\\[^\\]+'
    }

    Pester\It 'resolves relative paths when current location is a UNC path' {
        # arrange
        $uncPath = "\\$($Env:COMPUTERNAME)\C$\Windows"

        # C$ admin share requires elevation; skip if not running as admin
        if (-not (Microsoft.PowerShell.Management\Test-Path $uncPath)) {
            Pester\Set-ItResult -Skipped -Because "UNC admin share not accessible (requires elevation)"
            return
        }

        Microsoft.PowerShell.Management\Push-Location -LiteralPath $uncPath
        try {
            # act
            $result = GenXdev\Expand-Path '.\System32'

            # assert — must resolve as UNC, not a mangled local path like
            # C:\...\Microsoft.PowerShell.Core\FileSystem::\\...
            $result | Pester\Should -Be "$uncPath\System32"
        }
        finally {
            # cleanup
            Microsoft.PowerShell.Management\Pop-Location
        }
    }

    Pester\It 'expands user home directory' {
        # arrange
        $homePath = '~/test.txt'

        # act
        $result = GenXdev\Expand-Path $homePath

        # assert
        $result | Pester\Should -Be (Microsoft.PowerShell.Management\Join-Path $HOME 'test.txt')
    }

    Pester\It 'tests -ForceDrive parameter' {

        $result = GenXdev\Expand-Path 'b:\movies\classics\*.mp4' -ForceDrive Z
        $result | Pester\Should -Be 'Z:\**\movies\classics\*.mp4'

        $result = GenXdev\Expand-Path '\movies\classics\*.mp4' -ForceDrive Z
        $result | Pester\Should -Be 'Z:\movies\classics\*.mp4'

        $result = GenXdev\Expand-Path '\\media\data\users\*' -ForceDrive Z
        $result | Pester\Should -Be 'Z:\**\data\users\*'

        $result = GenXdev\Expand-Path 'B:' -ForceDrive Z
        $result | Pester\Should -Be 'Z:\'

        $result = GenXdev\Expand-Path 'B:*.txt' -ForceDrive Z
        $result | Pester\Should -Be 'Z:\**\*.txt'

        $result = GenXdev\Expand-Path '\folder1\*.ps1' -ForceDrive Z
        $result | Pester\Should -Be 'Z:\folder1\*.ps1'

        $result = GenXdev\Expand-Path '.\folder1\*.ps1' -ForceDrive Z
        $result | Pester\Should -Be 'Z:\**\folder1\*.ps1'

        $result = GenXdev\Expand-Path 'folder1\*.ps1' -ForceDrive Z
        $result | Pester\Should -Be 'Z:\**\folder1\*.ps1'

        Microsoft.PowerShell.Management\Pop-Location
    }

    Pester\It 'creates directory when -CreateDirectory is specified' {
        # arrange — build a unique path that does not yet exist
        $newDir = Microsoft.PowerShell.Management\Join-Path `
            $Script:testPath "GenXdev.ExpandPath.CreateDirTest.$(Microsoft.PowerShell.Utility\New-Guid)"
        # belt-and-suspenders: delete if leftover from a previous failed run
        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $newDir) {
            Microsoft.PowerShell.Management\Remove-Item -LiteralPath $newDir `
                -Recurse -Force
        }

        try {
            # act — trailing \ signals "this is a directory"
            $result = GenXdev\Expand-Path -FilePath "$newDir\" -CreateDirectory

            # assert — directory must exist
            $result | Pester\Should -Be ([IO.Path]::TrimEndingDirectorySeparator($newDir))
            Microsoft.PowerShell.Management\Test-Path -LiteralPath $newDir `
                -PathType Container | Pester\Should -BeTrue
        }
        finally {
            # cleanup
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $newDir) {
                Microsoft.PowerShell.Management\Remove-Item -LiteralPath $newDir `
                    -Recurse -Force
            }
        }
    }

    Pester\It 'does not throw when directory already exists with -CreateDirectory' {
        # arrange — create a directory first, then call Expand-Path on it
        $existingDir = Microsoft.PowerShell.Management\Join-Path `
            $Script:testPath "GenXdev.ExpandPath.ExistingDir.$(Microsoft.PowerShell.Utility\New-Guid)"
        $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory `
            -Path $existingDir -Force

        try {
            # act — should succeed without error
            $result = GenXdev\Expand-Path -FilePath "$existingDir\" `
                -CreateDirectory

            # assert
            $result | Pester\Should -Be ([IO.Path]::TrimEndingDirectorySeparator($existingDir))
            Microsoft.PowerShell.Management\Test-Path -LiteralPath $existingDir `
                -PathType Container | Pester\Should -BeTrue
        }
        finally {
            # cleanup
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $existingDir) {
                Microsoft.PowerShell.Management\Remove-Item -LiteralPath $existingDir `
                    -Recurse -Force
            }
        }
    }
}
