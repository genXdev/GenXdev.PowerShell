Pester\Describe 'Set-GenXdevDefaultPreference' {

    Pester\BeforeAll {
        GenXdev\Remove-GenXdevPreference -Name 'TestDefault' -RemoveDefault
    }

    Pester\AfterAll {
        GenXdev\Remove-GenXdevPreference -Name 'TestDefault' -RemoveDefault
    }

    Pester\It 'Should store default preference value' {
        GenXdev\Set-GenXdevDefaultPreference -Name 'TestDefault' -Value 'DefaultValue'
        $result = GenXdev\Get-GenXdevPreference -Name 'TestDefault'
        $result | Pester\Should -Be 'DefaultValue'
    }

    Pester\It 'Should retrieve after being set' {
        GenXdev\Set-GenXdevDefaultPreference -Name 'TestDefault' -Value 'ChangedValue'
        $result = GenXdev\Get-GenXdevPreference -Name 'TestDefault'
        $result | Pester\Should -Be 'ChangedValue'
    }

    Pester\It 'Should handle null value by removing preference' {
        GenXdev\Set-GenXdevDefaultPreference -Name 'TestDefault' -Value 'DefaultValue'
        GenXdev\Set-GenXdevDefaultPreference -Name 'TestDefault' -Value $null
        $result = GenXdev\Get-GenXdevPreference -Name 'TestDefault'
        $result | Pester\Should -BeNullOrEmpty
    }

    Pester\It 'Should write default preference to OneDrive with -AllMachines' {
        $oneDrive = GenXdev\Get-KnownFolderPath OneDrive
        if (-not $oneDrive) {
            Pester\Set-ItResult -Skipped -Because 'OneDrive not available'
            return
        }
        $oneDriveFile = Microsoft.PowerShell.Management\Join-Path $oneDrive 'GenXdev\Defaults_Preferences.json'

        GenXdev\Set-GenXdevDefaultPreference -Name 'AllMachinesDefault' -Value 'ODDefault' -AllMachines

        # Verify OneDrive file was written
        $content = Microsoft.PowerShell.Management\Get-Content $oneDriveFile -Raw -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue
        $content.'AllMachinesDefault' | Pester\Should -Be 'ODDefault'

        # Clean up
        GenXdev\Remove-GenXdevPreference -Name 'AllMachinesDefault' -RemoveDefault
    }
}