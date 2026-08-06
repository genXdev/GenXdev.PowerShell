###############################################################################
# Part of PowerShell module : GenXdev.Windows.WireGuard
# Original cmdlet filename  : EnsureWireGuard.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.34.0
###############################################################################

Pester\BeforeAll {
}

Pester\Describe "EnsureWireGuard" {

    Pester\It "Should install successfully" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        {
            GenXdev\EnsureWireGuard -AutoConsent -SessionOnly `
                -ErrorAction Stop
        } | Pester\Should -Not -Throw
    }
}
