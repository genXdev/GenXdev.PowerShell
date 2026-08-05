###############################################################################
# Part of PowerShell module : GenXdev.Software
# Original cmdlet filename  : EnsureVSCode.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.33.0
###############################################################################

Pester\BeforeAll {
}

Pester\Describe "EnsureVSCode" {

    Pester\It "Should install successfully" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        {
            GenXdev\EnsureVSCode -AutoConsent -SessionOnly `
                -ErrorAction Stop
        } | Pester\Should -Not -Throw
    }
}
