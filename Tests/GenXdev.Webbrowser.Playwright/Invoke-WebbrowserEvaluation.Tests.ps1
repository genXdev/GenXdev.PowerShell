###############################################################################
# Part of PowerShell module : GenXdev.Webbrowser
# Original cmdlet filename  : Invoke-WebbrowserEvaluation.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.34.0
###############################################################################

Pester\BeforeAll {
    # launch a headless Playwright browser so eval tests have a page
    try {
        $null = GenXdev\Open-PlayWrightBrowser `
            -BrowserType ChromiumNormal `
            -Headless `
            -Force `
            -AutoConsentAllPackages

        $null = GenXdev\Select-WebbrowserTab -BrowserType ChromiumNormal
    }
    catch {
        Microsoft.PowerShell.Utility\Write-Warning "Could not start headless browser: $_"
    }
}

Pester\AfterAll {
    # close the headless browser
    try {
        if ($Global:GenXdevPlaywright['ChromiumNormal']) {
            $null = $Global:GenXdevPlaywright['ChromiumNormal'].Browser.CloseAsync().GetAwaiter().GetResult()
            $Global:GenXdevPlaywright.Remove('ChromiumNormal')
        }
    }
    catch { }
}

Pester\Describe "Invoke-WebbrowserEvaluation" {

    Pester\It "evaluates simple arithmetic" {
        $result = GenXdev\Invoke-WebbrowserEvaluation 'return 1+1'
        $result | Pester\Should -Be 2
    }

    Pester\It "returns string results" {
        $result = GenXdev\Invoke-WebbrowserEvaluation "return 'hello ' + 'world'"
        $result | Pester\Should -Be 'hello world'
    }

    Pester\It "reads document.title" {
        $title = GenXdev\Invoke-WebbrowserEvaluation 'return document.title'
        $title | Pester\Should -BeOfType [string]
    }

    Pester\It "syncs output via `$Global:Data" {
        $Global:Data = @{}
        GenXdev\Invoke-WebbrowserEvaluation 'data.x = 42'
        $Global:Data.x | Pester\Should -Be 42
    }

    Pester\It "accepts pipeline input from Get-ChildItem" {
        $tempFile = [System.IO.Path]::GetTempFileName() + '.js'
        try {
            'return 1 + 2' | Microsoft.PowerShell.Management\Set-Content -Path $tempFile -Encoding UTF8
            $result = Microsoft.PowerShell.Management\Get-Item $tempFile | GenXdev\Invoke-WebbrowserEvaluation
            $result | Pester\Should -Be 3
        }
        finally {
            Microsoft.PowerShell.Management\Remove-Item $tempFile -ErrorAction SilentlyContinue
        }
    }

    Pester\It "handles promises with async/await" {
        $result = GenXdev\Invoke-WebbrowserEvaluation 'return await new Promise(r => setTimeout(() => r(99), 100))'
        $result | Pester\Should -Be 99
    }

    Pester\It "honors the Eval alias" {
        $result = GenXdev\Invoke-WebbrowserEvaluation 'return 40 + 2'
        $result | Pester\Should -Be 42
    }
}
