Pester\Describe 'Start-GenXdevMCPServer stdio transport tests' {

    Pester\BeforeAll {
        # the stdio transport only exists towards a client that launched the server
        # itself, so these tests launch one and read what it answers
        $Script:probeDirectory = Microsoft.PowerShell.Management\Join-Path `
            ([System.IO.Path]::GetTempPath()) 'genxdev-mcp-stdio-tests'

        $null = [System.IO.Directory]::CreateDirectory($Script:probeDirectory)

        $Script:requestFile = Microsoft.PowerShell.Management\Join-Path `
            $Script:probeDirectory 'requests.jsonl'

        $Script:stdoutFile = Microsoft.PowerShell.Management\Join-Path `
            $Script:probeDirectory 'stdout.txt'

        $Script:stderrFile = Microsoft.PowerShell.Management\Join-Path `
            $Script:probeDirectory 'stderr.txt'

        # a version the server does not prefer, so an echo proves negotiation, a
        # notification that must stay unanswered, and an unknown method
        $Script:requestLines = @(
            '{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"protocolVersion":"2025-03-26","capabilities":{},"clientInfo":{"name":"pester","version":"1.0"}}}',
            '{"jsonrpc":"2.0","method":"notifications/initialized"}',
            '{"jsonrpc":"2.0","id":2,"method":"tools/list"}',
            '{"jsonrpc":"2.0","id":3,"method":"nonexistent/method"}'
        )

        [System.IO.File]::WriteAllLines($Script:requestFile, $Script:requestLines)

        # the server stops by itself once its input ends, which is what the client
        # closing the pipe looks like
        $Script:serverProcess = Microsoft.PowerShell.Management\Start-Process `
            -FilePath 'pwsh' `
            -ArgumentList @(
                '-NoProfile',
                '-NoLogo',
                '-MTA',
                '-Command',
                'Import-Module Genxdev -Force; Start-GenXdevMCPServer -Stdio'
            ) `
            -RedirectStandardInput $Script:requestFile `
            -RedirectStandardOutput $Script:stdoutFile `
            -RedirectStandardError $Script:stderrFile `
            -PassThru `
            -Wait

        $Script:stdoutLines = @([System.IO.File]::ReadAllLines($Script:stdoutFile))
        $Script:stderrText = [System.IO.File]::ReadAllText($Script:stderrFile)
    }

    Pester\AfterAll {
        Microsoft.PowerShell.Management\Remove-Item `
            -LiteralPath $Script:probeDirectory -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'Should stop when the client closes the connection' {
        $Script:serverProcess.ExitCode | Pester\Should -Be 0
    }

    Pester\It 'Should answer only the requests that carry an id' {
        # three requests with an id, one notification that is never answered
        $Script:stdoutLines.Count | Pester\Should -Be 3
    }

    Pester\It 'Should serialize every response on a single line' {
        $Script:stdoutLines | Microsoft.PowerShell.Core\ForEach-Object {

            { $_ | Microsoft.PowerShell.Utility\ConvertFrom-Json } |
                Pester\Should -Not -Throw
        }
    }

    Pester\It 'Should negotiate the protocol version the client asked for' {
        $initialize = $Script:stdoutLines[0] |
            Microsoft.PowerShell.Utility\ConvertFrom-Json

        $initialize.id | Pester\Should -Be 1
        $initialize.result.protocolVersion | Pester\Should -Be '2025-03-26'
    }

    Pester\It 'Should list the exposed cmdlets as tools' {
        $toolList = $Script:stdoutLines[1] |
            Microsoft.PowerShell.Utility\ConvertFrom-Json

        $toolList.id | Pester\Should -Be 2
        $toolList.result.tools.Count | Pester\Should -BeGreaterThan 0
        $toolList.result.tools[0].name | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It 'Should report an unknown method as an error' {
        $failure = $Script:stdoutLines[2] |
            Microsoft.PowerShell.Utility\ConvertFrom-Json

        $failure.id | Pester\Should -Be 3
        $failure.error.code | Pester\Should -Be -32601
    }

    Pester\It 'Should keep everything the cmdlets print off the protocol stream' {
        $Script:stderrText | Pester\Should -Match 'Serving the Model Context Protocol on stdin/stdout'

        # only protocol messages reach the client, never a banner or cmdlet output
        $Script:stdoutLines |
            Microsoft.PowerShell.Core\Where-Object { $_ -notmatch '^\{' } |
            Pester\Should -BeNullOrEmpty
    }
}
