###############################################################################
# Part of PowerShell module : GenXdev.Coding.PowerShell.Modules
# Original cmdlet filename  : EnsureCopilotKeyboardShortCut.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.33.0
###############################################################################

Pester\BeforeAll {
}

Pester\Describe "EnsureCopilotKeyboardShortCut" {

    Pester\It "Should install successfully" -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {
        {
            GenXdev\EnsureCopilotKeyboardShortCut -AutoConsent -SessionOnly `
                -ErrorAction Stop
        } | Pester\Should -Not -Throw
    }
}
