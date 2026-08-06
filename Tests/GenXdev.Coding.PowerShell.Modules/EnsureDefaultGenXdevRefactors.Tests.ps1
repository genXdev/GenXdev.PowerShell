###############################################################################
# Part of PowerShell module : GenXdev.Coding.PowerShell.Modules
# Original cmdlet filename  : EnsureDefaultGenXdevRefactors.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.34.0
###############################################################################

Pester\BeforeAll {
}

Pester\Describe "EnsureDefaultGenXdevRefactors" {

    Pester\It "Should install successfully" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        {
            GenXdev\EnsureDefaultGenXdevRefactors -AutoConsent -SessionOnly `
                -ErrorAction Stop
        } | Pester\Should -Not -Throw
    }
}
