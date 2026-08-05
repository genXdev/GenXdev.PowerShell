
PESTER\Describe "Base class helpers" {

    Pester\It "Should detect Pester" {

        [PSGenXdevCmdlet]::IsRunningUnderPester() | PESTER\Should -BeExactly $true
    }
}