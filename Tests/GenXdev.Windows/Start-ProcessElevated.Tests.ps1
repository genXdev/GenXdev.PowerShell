###############################################################################
# Part of PowerShell module : GenXdev.Windows
# Original cmdlet filename  : Start-ProcessElevated.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.34.0
###############################################################################

Pester\BeforeAll {
}

Pester\Describe "Start-ProcessElevated" {

    Pester\It "Starts a process with elevation" `
        -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {

        {
            GenXdev\Start-ProcessElevated `
                -FilePath 'cmd.exe' `
                -ArgumentList '/c', 'exit', '0' `
                -Wait `
                -NoNewWindow `
                -ErrorAction Stop
        } | Pester\Should -Not -Throw
    }

    Pester\It "Delegates to Start-Process when -Elevated:`$false" `
        -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {

        {
            GenXdev\Start-ProcessElevated `
                -FilePath 'cmd.exe' `
                -ArgumentList '/c', 'exit', '0' `
                -Wait `
                -NoNewWindow `
                -Elevated:$false `
                -ErrorAction Stop
        } | Pester\Should -Not -Throw
    }

    Pester\It "Respects -Wait by blocking until process exits" `
        -Skip:(-not ($Global:AllowLongRunningTests -eq $true)) {

        $stopwatch = [System.Diagnostics.Stopwatch]::StartNew()
        GenXdev\Start-ProcessElevated `
            -FilePath 'cmd.exe' `
            -ArgumentList '/c', 'timeout', '/t', '1', '/nobreak' `
            -Wait `
            -NoNewWindow `
            -Elevated:$false `
            -ErrorAction Stop
        $stopwatch.Stop()

        # Should have waited at least ~1 second
        $stopwatch.Elapsed.TotalSeconds |
            Pester\Should -BeGreaterThan 0.5
    }
}