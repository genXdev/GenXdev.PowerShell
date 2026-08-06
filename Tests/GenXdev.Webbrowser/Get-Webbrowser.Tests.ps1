###############################################################################
# Part of PowerShell module : GenXdev.Webbrowser
# Original cmdlet filename  : Get-Webbrowser.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.34.0
###############################################################################

Pester\BeforeAll {
}

Pester\Describe "Get-Webbrowser" {

    Pester\It "Should return Microsoft Edge with msedge.exe path" {
        $browsers = GenXdev\Get-Webbrowser
        $edgeBrowser = $browsers | Microsoft.PowerShell.Core\Where-Object { $_.Name -like "*Edge*" }

        $edgeBrowser | Pester\Should -Not -BeNullOrEmpty
        $edgeBrowser.Path | Pester\Should -Match "msedge\.exe"
    }
}
