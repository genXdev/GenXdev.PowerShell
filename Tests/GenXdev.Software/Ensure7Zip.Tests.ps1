###############################################################################
# Part of PowerShell module : GenXdev.Software
# Original cmdlet filename  : Ensure7Zip.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.34.0
###############################################################################

Pester\BeforeAll {
}

Pester\Describe "Ensure7Zip" {

    Pester\It "Should install successfully" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        {
            GenXdev\Ensure7Zip -AutoConsent -SessionOnly `
                -ErrorAction Stop
        } | Pester\Should -Not -Throw
    }
}
