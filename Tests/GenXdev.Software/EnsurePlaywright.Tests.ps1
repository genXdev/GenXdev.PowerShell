###############################################################################
# Part of PowerShell module : GenXdev.Webbrowser.Playwright
# Original cmdlet filename  : EnsurePlaywright.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.34.0
###############################################################################

Pester\BeforeAll {
}

Pester\Describe "EnsurePlaywright" {

    Pester\It "Should be defined as a function" {
        Microsoft.PowerShell.Core\Get-Command EnsurePlaywright `
            -ErrorAction SilentlyContinue |
            Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It "Should accept AutoConsent switch parameter" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        $cmd = Microsoft.PowerShell.Core\Get-Command EnsurePlaywright
        $cmd.Parameters['AutoConsent'] |
            Pester\Should -Not -BeNullOrEmpty
        $cmd.Parameters['AutoConsent'].ParameterType.Name |
            Pester\Should -Be 'SwitchParameter'
    }

    Pester\It "Should accept AutoConsentAllPackages switch parameter" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        $cmd = Microsoft.PowerShell.Core\Get-Command EnsurePlaywright
        $cmd.Parameters['AutoConsentAllPackages'] |
            Pester\Should -Not -BeNullOrEmpty
        $cmd.Parameters['AutoConsentAllPackages'].ParameterType.Name |
            Pester\Should -Be 'SwitchParameter'
    }

    Pester\It "Should be idempotent — calling twice should not throw" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        # This test verifies idempotency: calling EnsurePlaywright multiple
        # times should succeed without errors because it skips already-loaded
        # assemblies and already-installed browser binaries.
        # Use AutoConsentAllPackages to auto-consent
        # and set the persistent preference, bypassing the interactive prompt.
        {
            GenXdev\EnsurePlaywright -AutoConsent -SessionOnly `
                -ErrorAction Stop
            GenXdev\EnsurePlaywright -AutoConsent -SessionOnly `
                -ErrorAction Stop
        } | Pester\Should -Not -Throw
    }

    Pester\It "Should have Microsoft.Playwright assembly loaded after execution" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        # After EnsurePlaywright runs, the Microsoft.Playwright assembly
        # should be present in the current AppDomain.
        GenXdev\EnsurePlaywright -AutoConsent -SessionOnly `
            -ErrorAction Stop

        $assembly = [System.AppDomain]::CurrentDomain.GetAssemblies() |
            Microsoft.PowerShell.Core\Where-Object {
                $PSItem.GetName().Name -eq 'Microsoft.Playwright'
            }

        $assembly | Pester\Should -Not -BeNullOrEmpty
    }
}
