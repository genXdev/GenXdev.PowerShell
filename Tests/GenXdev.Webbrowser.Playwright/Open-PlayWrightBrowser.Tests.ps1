###############################################################################
# Part of PowerShell module : GenXdev.Webbrowser.Playwright
# Original cmdlet filename  : Open-PlayWrightBrowser.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.34.0
###############################################################################

Pester\BeforeAll {
    function script:CleanupBrowser {
        param($BrowserType = 'ChromiumNormal')

        if ($Global:GenXdevPlaywright -and $Global:GenXdevPlaywright.ContainsKey($BrowserType)) {
            try {
                $s = $Global:GenXdevPlaywright[$BrowserType]
                if ($s.Context) { $s.Context.CloseAsync().GetAwaiter().GetResult() }
                if ($s.Browser) { $s.Browser.CloseAsync().GetAwaiter().GetResult() }
            }
            catch { }
            $Global:GenXdevPlaywright.Remove($BrowserType)
        }
    }
}

Pester\AfterAll {
    # cleanup: close any Playwright browsers left running
    try {
        if (-not $Global:GenXdevPlaywright) { return }
        foreach ($key in @($Global:GenXdevPlaywright.Keys)) {
            try {
                $state = $Global:GenXdevPlaywright[$key]
                if ($state.Context) {
                    $state.Context.CloseAsync().GetAwaiter().GetResult()
                }
                if ($state.Browser) {
                    $state.Browser.CloseAsync().GetAwaiter().GetResult()
                }
            }
            catch { }
            $Global:GenXdevPlaywright.Remove($key)
        }
    }
    catch { }
}

Pester\Describe "Open-PlayWrightBrowser" {

    Pester\It "launches headed (visible window) without -Headless" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -BrowserType ChromiumPlaywright `
            -AutoConsentAllPackages

        $state | Pester\Should -Not -BeNullOrEmpty
        $state.Browser.IsConnected | Pester\Should -Be $true
        $state.Page | Pester\Should -Not -BeNullOrEmpty
        $state.Context | Pester\Should -Not -BeNullOrEmpty
        $state.Playwright | Pester\Should -Not -BeNullOrEmpty

        # verify a visible window exists: ms-playwright processes with
        # non-zero MainWindowHandle
        $visibleProcs = @(Microsoft.PowerShell.Management\Get-Process -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\Where-Object { $_.Path -like '*\ms-playwright\*' -and
                $_.MainWindowHandle -ne 0 })

        $visibleProcs.Count | Pester\Should -BeGreaterThan 0 -Because (
            'headed mode should create at least one visible window'
        )

        script:CleanupBrowser ChromiumPlaywright
    }

    Pester\It "returns a Page that can execute JavaScript" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $result = $state.Page.EvaluateAsync('1 + 2', @()).GetAwaiter().GetResult()
        $result.GetInt32() | Pester\Should -Be 3

        script:CleanupBrowser
    }

    Pester\It "headless mode has no visible window" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Headless -Force `
            -BrowserType ChromiumPlaywright `
            -AutoConsentAllPackages

        $state | Pester\Should -Not -BeNullOrEmpty
        $state.Browser.IsConnected | Pester\Should -Be $true

        # headless processes should have MainWindowHandle = 0
        $procs = @(Microsoft.PowerShell.Management\Get-Process -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\Where-Object { $_.Path -like '*\ms-playwright\*' })

        $procs.Count | Pester\Should -BeGreaterThan 0

        foreach ($proc in $procs) {
            $proc.MainWindowHandle | Pester\Should -Be 0 -Because (
                'headless mode should not create visible windows'
            )
        }

        script:CleanupBrowser ChromiumPlaywright
    }

    Pester\It "-Headless:`$false shows a window" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Headless:$false -Force `
            -BrowserType ChromiumPlaywright `
            -AutoConsentAllPackages

        $state | Pester\Should -Not -BeNullOrEmpty

        # verify a visible window exists
        $visibleProcs = @(Microsoft.PowerShell.Management\Get-Process -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\Where-Object { $_.Path -like '*\ms-playwright\*' -and
                $_.MainWindowHandle -ne 0 })

        $visibleProcs.Count | Pester\Should -BeGreaterThan 0

        script:CleanupBrowser ChromiumPlaywright
    }

    Pester\It "browser starts at about:blank" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $state.Page.Url | Pester\Should -Be 'about:blank'

        script:CleanupBrowser
    }

    Pester\It "stores state in Global:GenXdevPlaywright" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $Global:GenXdevPlaywright['ChromiumNormal'] |
            Pester\Should -Not -BeNullOrEmpty
        $Global:GenXdevPlaywright['ChromiumNormal'].Page |
            Pester\Should -Not -BeNullOrEmpty
        $Global:GenXdevPlaywright['ChromiumNormal'].Browser.IsConnected |
            Pester\Should -Be $true

        script:CleanupBrowser
    }

    Pester\It "sets legacy Global:playwrightController for backward compat" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $Global:playwrightController |
            Pester\Should -Not -BeNullOrEmpty
        $Global:playwrightController.Url |
            Pester\Should -Be 'about:blank'

        script:CleanupBrowser
    }

    Pester\It "defaults to ChromiumNormal BrowserType" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $Global:GenXdevPlaywright.ContainsKey('ChromiumNormal') |
            Pester\Should -Be $true
        $state.Browser.BrowserType.Name |
            Pester\Should -Be 'Chromium'

        script:CleanupBrowser
    }

    Pester\It "accepts explicit -BrowserType ChromiumNormal" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -BrowserType ChromiumNormal -Force `
            -AutoConsentAllPackages

        $state.Browser.IsConnected | Pester\Should -Be $true
        $Global:GenXdevPlaywright.ContainsKey('ChromiumNormal') |
            Pester\Should -Be $true

        script:CleanupBrowser
    }

    Pester\It "reuses existing browser when already running" {
        script:CleanupBrowser

        $state1 = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        # second call without -Force should return the same browser
        $state2 = GenXdev\Open-PlayWrightBrowser `
            -AutoConsentAllPackages

        $state2 | Pester\Should -Not -BeNullOrEmpty
        $state2.Browser.IsConnected | Pester\Should -Be $true
        # same page reference (reused)
        $state2.Page.Url | Pester\Should -Be 'about:blank'

        script:CleanupBrowser
    }

    Pester\It "-Force restarts an existing browser" {
        script:CleanupBrowser

        $state1 = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages
        $firstPage = $state1.Page

        $state2 = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $state2 | Pester\Should -Not -BeNullOrEmpty
        $state2.Browser.IsConnected | Pester\Should -Be $true
        # different page after force restart
        $state2.Page | Pester\Should -Not -Be $firstPage

        script:CleanupBrowser
    }


    Pester\It "can navigate to a URL via Page.GotoAsync" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $null = $state.Page.GotoAsync('about:blank#test').GetAwaiter().GetResult()
        $state.Page.Url | Pester\Should -Be 'about:blank#test'

        script:CleanupBrowser
    }
}
