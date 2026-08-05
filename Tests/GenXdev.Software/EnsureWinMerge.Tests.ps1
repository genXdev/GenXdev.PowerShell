###############################################################################
# Part of PowerShell module : GenXdev.Software
# Original cmdlet filename  : EnsureWinMerge.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.33.0
###############################################################################

Pester\BeforeAll {
}

Pester\Describe "EnsureWinMerge" {

    Pester\It "Should install successfully" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        {
            GenXdev\EnsureWinMerge -AutoConsent -SessionOnly `
                -ErrorAction Stop
        } | Pester\Should -Not -Throw
    }
}
