###############################################################################
# Part of PowerShell module : GenXdev.Software
# Original cmdlet filename  : EnsurePython.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.34.0
###############################################################################

Pester\BeforeAll {
}

Pester\Describe "EnsurePython" {

    Pester\It "Should install successfully" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        {
            GenXdev\EnsurePython -AutoConsent -SessionOnly `
                -ErrorAction Stop
        } | Pester\Should -Not -Throw
    }
}
