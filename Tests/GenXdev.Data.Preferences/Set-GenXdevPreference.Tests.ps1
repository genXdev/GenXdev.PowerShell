Pester\Describe 'Set-GenXdevPreference' {

    Pester\BeforeAll {

        GenXdev\Remove-GenXdevPreference -Name 'Theme' -RemoveDefault
    }

    Pester\AfterAll {
        GenXdev\Remove-GenXdevPreference -Name 'Theme' -RemoveDefault
    }

    Pester\It 'Should store preference value locally' {
        GenXdev\Set-GenXdevPreference -Name 'Theme' -Value 'Dark'
        $result = GenXdev\Get-GenXdevPreference -Name 'Theme'
        $result | Pester\Should -Be 'Dark'
    }

    Pester\It 'Should update existing preference' {
        GenXdev\Set-GenXdevPreference -Name 'Theme' -Value 'Light'
        GenXdev\Set-GenXdevPreference -Name 'Theme' -Value 'Dark'
        $result = GenXdev\Get-GenXdevPreference -Name 'Theme'
        $result | Pester\Should -Be 'Dark'
    }

    Pester\It 'Should remove preference when value is null' {
        GenXdev\Set-GenXdevPreference -Name 'Theme' -Value 'Dark'
        GenXdev\Set-GenXdevPreference -Name 'Theme' -Value $null
        $result = GenXdev\Get-GenXdevPreference -Name 'Theme' -DefaultValue 'Default'
        $result | Pester\Should -Be 'Default'
    }

    Pester\It 'Should write preference to OneDrive with -AllMachines' {
        $oneDrive = GenXdev\Get-KnownFolderPath OneDrive
        if (-not $oneDrive) {
            Pester\Set-ItResult -Skipped -Because 'OneDrive not available'
            return
        }
        $oneDriveFile = Microsoft.PowerShell.Management\Join-Path $oneDrive 'GenXdev\Defaults_Preferences.json'

        # Clean up any previous test data
        GenXdev\Set-GenXdevPreference -Name 'AllMachinesTest' -Value 'OneDriveValue' -AllMachines

        # Verify OneDrive file was written
        $content = Microsoft.PowerShell.Management\Get-Content $oneDriveFile -Raw -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue
        $content.'AllMachinesTest' | Pester\Should -Be 'OneDriveValue'

        # Clean up
        GenXdev\Remove-GenXdevPreference -Name 'AllMachinesTest' -RemoveDefault
    }

    Pester\It 'Should fail when -SessionOnly and -AllMachines are both used' {
        # -SessionOnly wins, -AllMachines is ignored
        GenXdev\Set-GenXdevPreference -Name 'Theme' -Value 'SessionWins' -SessionOnly -AllMachines
        $result = GenXdev\Get-GenXdevPreference -Name 'Theme'
        $result | Pester\Should -Be 'SessionWins'
    }

    Pester\It 'Should retrieve preference using case-insensitive key lookup' {
        # Set with mixed case, retrieve with different casing
        $name = 'CaseInsensitiveTest_' + [System.Guid]::NewGuid().ToString('N').Substring(0, 8)
        GenXdev\Set-GenXdevPreference -Name $name -Value 'FoundMe'

        # Retrieve with same casing (baseline)
        $result = GenXdev\Get-GenXdevPreference -Name $name
        $result | Pester\Should -Be 'FoundMe'

        # Retrieve with different casing — should still find it
        $result = GenXdev\Get-GenXdevPreference -Name $name.ToUpper()
        $result | Pester\Should -Be 'FoundMe'

        $result = GenXdev\Get-GenXdevPreference -Name $name.ToLower()
        $result | Pester\Should -Be 'FoundMe'

        # Remove via different casing — should work
        GenXdev\Remove-GenXdevPreference -Name $name.ToUpper()

        # Verify it's actually gone
        $result = GenXdev\Get-GenXdevPreference -Name $name -DefaultValue 'Gone'
        $result | Pester\Should -Be 'Gone'
    }
}