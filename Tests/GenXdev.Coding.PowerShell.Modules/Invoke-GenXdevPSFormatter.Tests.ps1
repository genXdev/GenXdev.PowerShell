###############################################################################
Pester\Describe 'Invoke-GenXdevPSFormatter' {

    Pester\It 'should pass PSScriptAnalyzer rules' {

        # get the script path for analysis
        $scriptPath = GenXdev\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.Coding.PowerShell.Modules\Invoke-GenXdevPSFormatter.ps1"

        # run analyzer with explicit settings
        $analyzerResults = GenXdev\Invoke-GenXdevScriptAnalyzer `
            -ScriptFilePath $scriptPath

        [string] $message = ''
        $analyzerResults | Microsoft.PowerShell.Core\ForEach-Object {

            $message = $message + @"
--------------------------------------------------
Rule: $($_.RuleName)`
Description: $($_.Description)
Message: $($_.Message)
`r`n
"@
        }

        $analyzerResults.Count | Pester\Should -Be 0 -Because @"
The following PSScriptAnalyzer rules are being violated:
$message
"@;
    }

    Pester\It 'should apply PSScriptAnalyzer formatting rules' {

        # Create a temporary PowerShell script file with inconsistent formatting
        $tempFile = [System.IO.Path]::GetTempFileName() + '.ps1'

        try {
            # Write script with inconsistent indentation and spacing
            [IO.File]::WriteAllText($tempFile, @'
function test{
$a=1+2
if($true){
Write-Verbose "test"
}
}
'@)

            # Run formatter
            GenXdev\Invoke-GenXdevPSFormatter -Path $tempFile

            # Read the content and check for proper formatting
            $content = [IO.File]::ReadAllText($tempFile)

            # Check that the formatter made some changes (PSScriptAnalyzer should format this)
            $originalContent = @'
function test{
$a=1+2
if($true){
Write-Verbose "test"
}
}
'@

            # The formatted content should be different from the original
            $content | Pester\Should -Not -Be $originalContent -Because 'PSScriptAnalyzer should apply formatting rules'
        }
        finally {
            # Clean up
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $tempFile) {
                Microsoft.PowerShell.Management\Remove-Item -LiteralPath $tempFile -Force
            }
        }
    }
}
###############################################################################
