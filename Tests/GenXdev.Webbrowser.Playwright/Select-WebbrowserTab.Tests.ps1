###############################################################################
# Part of PowerShell module : GenXdev.Webbrowser
# Original cmdlet filename  : Select-WebbrowserTab.Tests.ps1
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

Pester\Describe "Select-WebbrowserTab" {

    Pester\It "shows tab list when called without parameters after opening a browser" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $result = GenXdev\Select-WebbrowserTab

        # should return tab list (array)
        $result | Pester\Should -Not -BeNullOrEmpty
        @($result).Count | Pester\Should -BeGreaterThan 0 -Because (
            'browser has at least one tab'
        )
        $result[0].Url | Pester\Should -Be 'about:blank'

        script:CleanupBrowser
    }

    Pester\It "selects tab by -Id 0 and updates Global:playwrightController" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $page = GenXdev\Select-WebbrowserTab -Id 0

        $page | Pester\Should -Not -BeNullOrEmpty
        $page.Url | Pester\Should -Be 'about:blank'

        # backward compat globals should be set
        $Global:playwrightController | Pester\Should -Not -BeNullOrEmpty
        $Global:playwrightController.Url | Pester\Should -Be 'about:blank'
        $Global:chromeSession | Pester\Should -Not -BeNullOrEmpty
        $Global:chromeSession.url | Pester\Should -Be 'about:blank'

        script:CleanupBrowser
    }

    Pester\It "selects tab by -Name pattern" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        # navigate to a unique URL
        $null = $state.Page.GotoAsync(
            'https://example.com/test123'
        ).GetAwaiter().GetResult()

        $page = GenXdev\Select-WebbrowserTab -Name 'test123'

        $page | Pester\Should -Not -BeNullOrEmpty
        $page.Url | Pester\Should -Match 'test123'

        script:CleanupBrowser
    }

    Pester\It "selects tab by -ByReference" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $null = $state.Page.GotoAsync(
            'https://example.com/byref-test'
        ).GetAwaiter().GetResult()

        $page = GenXdev\Select-WebbrowserTab -ByReference $state.Page

        $page | Pester\Should -Not -BeNullOrEmpty
        $page.Url | Pester\Should -Match 'byref-test'

        script:CleanupBrowser
    }

    Pester\It "warns when no browser is running" {
        # ensure no browsers
        if ($Global:GenXdevPlaywright) {
            foreach ($key in @($Global:GenXdevPlaywright.Keys)) {
                try {
                    $s = $Global:GenXdevPlaywright[$key]
                    if ($s.Context) { $s.Context.CloseAsync().GetAwaiter().GetResult() }
                    if ($s.Browser) { $s.Browser.CloseAsync().GetAwaiter().GetResult() }
                }
                catch { }
                $Global:GenXdevPlaywright.Remove($key)
            }
        }

        $result = GenXdev\Select-WebbrowserTab -WarningAction SilentlyContinue
        $result | Pester\Should -BeNullOrEmpty
    }

    Pester\It "warns when -Id references nonexistent tab" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $result = GenXdev\Select-WebbrowserTab -Id 999 -WarningAction SilentlyContinue
        $result | Pester\Should -BeNullOrEmpty

        script:CleanupBrowser
    }

    Pester\It "warns when -Name has no match" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        $result = GenXdev\Select-WebbrowserTab -Name 'nonexistent-url-zzz999' `
            -WarningAction SilentlyContinue
        $result | Pester\Should -BeNullOrEmpty

        script:CleanupBrowser
    }

    Pester\It "filters tabs by -BrowserType ChromiumNormal" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -BrowserType ChromiumNormal -Force `
            -AutoConsentAllPackages

        $result = GenXdev\Select-WebbrowserTab -Chromium
        @($result).Count | Pester\Should -BeGreaterThan 0
        $result[0].BrowserType | Pester\Should -Be 'ChromiumNormal'

        script:CleanupBrowser
    }

    Pester\It "shows multiple tabs when multiple pages are open" {
        script:CleanupBrowser

        $state = GenXdev\Open-PlayWrightBrowser -Force `
            -AutoConsentAllPackages

        # open a second page in the same context
        $page2 = $state.Context.NewPageAsync().GetAwaiter().GetResult()
        $null = $page2.GotoAsync('https://example.com/page2').
            GetAwaiter().GetResult()

        $result = GenXdev\Select-WebbrowserTab
        @($result).Count | Pester\Should -BeGreaterOrEqual 2 -Because (
            'two pages should be open'
        )

        # select the second tab by URL
        $selected = GenXdev\Select-WebbrowserTab -Name 'page2'
        $selected.Url | Pester\Should -Match 'page2'
        $Global:playwrightController.Url | Pester\Should -Match 'page2'

        script:CleanupBrowser
    }
}
