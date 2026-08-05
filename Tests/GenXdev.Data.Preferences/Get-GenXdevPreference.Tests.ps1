Pester\Describe 'Get-GenXdevPreference' {

    Pester\BeforeAll {
        Microsoft.PowerShell.Utility\Write-Verbose 'Setting up test environment'
        GenXdev\Remove-GenXdevPreference -Name 'TestPref1' -RemoveDefault
        GenXdev\Remove-GenXdevPreference -Name 'TestPref2' -RemoveDefault
        GenXdev\Set-GenXdevPreference -Name 'TestPref1' -Value 'LocalValue'
        GenXdev\Set-GenXdevDefaultPreference -Name 'TestPref2' -Value 'DefaultValue'
    }

    Pester\AfterAll {
        # Clean-up
        GenXdev\Remove-GenXdevPreference -Name 'TestPref1' -RemoveDefault
        GenXdev\Remove-GenXdevPreference -Name 'TestPref2' -RemoveDefault
    }

    Pester\It 'Should retrieve local preference value (tier 1)' {
        $result = GenXdev\Get-GenXdevPreference -Name 'TestPref1'
        $result | Pester\Should -Be 'LocalValue'
    }

    Pester\It 'Should fall back to local defaults (tier 2)' {
        $result = GenXdev\Get-GenXdevPreference -Name 'TestPref2'
        $result | Pester\Should -Be 'DefaultValue'
    }

    Pester\It 'Should fall back to OneDrive defaults (tier 3)' {
        $oneDrive = GenXdev\Get-KnownFolderPath OneDrive
        if (-not $oneDrive) {
            Pester\Set-ItResult -Skipped -Because 'OneDrive not available'
            return
        }
        $oneDriveFile = Microsoft.PowerShell.Management\Join-Path $oneDrive 'GenXdev\Defaults_Preferences.json'

        # Write directly to OneDrive file
        $data = @{ 'ODLookupTest' = 'FromOneDrive' }
        $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory (Microsoft.PowerShell.Management\Split-Path $oneDriveFile) -Force -ErrorAction SilentlyContinue
        $data | Microsoft.PowerShell.Utility\ConvertTo-Json | Microsoft.PowerShell.Management\Set-Content $oneDriveFile -Force

        $result = GenXdev\Get-GenXdevPreference -Name 'ODLookupTest'
        $result | Pester\Should -Be 'FromOneDrive'

        # Clean up OneDrive file
        Microsoft.PowerShell.Management\Remove-Item $oneDriveFile -ErrorAction SilentlyContinue
    }

    Pester\It 'Should return specified default when preference not found anywhere (tier 4)' {
        $result = GenXdev\Get-GenXdevPreference -Name 'NonExistent' -DefaultValue 'Fallback'
        $result | Pester\Should -Be 'Fallback'
    }

    Pester\It 'Should handle null default value' {
        $result = GenXdev\Get-GenXdevPreference -Name 'NonExistent'
        $result | Pester\Should -BeNullOrEmpty
    }

    Pester\It 'Should work on a different preferences set when setting a different database path in session once' {

        $testFile = (GenXdev\Expand-Path ([IO.Path]::GetTempFileName()) -DeleteExistingFile -CreateDirectory)

        GenXdev\Set-GenXdevPreferencesDatabasePath $testFile -SessionOnly

        $result = GenXdev\Get-GenXdevPreference -Name 'TestPref1'
        $result | Pester\Should -Not -Be 'LocalValue'

        GenXdev\Set-GenXdevPreference -Name 'TestPref1' -Value 'DifferentValue'

        $result = GenXdev\Get-GenXdevPreference -Name 'TestPref1'
        $result | Pester\Should -Be 'DifferentValue'

        GenXdev\Set-GenXdevPreferencesDatabasePath -ClearSession

        $result = GenXdev\Get-GenXdevPreference -Name 'TestPref1'
        $result | Pester\Should -Be 'LocalValue'

        $result = GenXdev\Get-GenXdevPreference -Name 'TestPref2'
        $result | Pester\Should -Be 'DefaultValue'

        $result = GenXdev\Get-GenXdevPreference -Name 'NonExistent' -DefaultValue 'Fallback'
        $result | Pester\Should -Be 'Fallback'

        $result = GenXdev\Get-GenXdevPreference -Name 'NonExistent'
        $result | Pester\Should -BeNullOrEmpty
    }
}