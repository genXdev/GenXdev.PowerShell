Pester\Describe 'Invoke-GenXdevScriptAnalyzer' {

    Pester\It "Should test availability of PSUseFullyQualifiedCmdletNames" {

        $rules = @(
            PSScriptAnalyzer\Get-ScriptAnalyzerRule |
                Microsoft.PowerShell.Core\Where-Object { $_ -like "*fullyq*" } |
                Microsoft.PowerShell.Core\ForEach-Object RuleName
        )

        $rules | Pester\Should -Contain "PSUseFullyQualifiedCmdletNames"
    }

    Pester\It "Should test PSUseFullyQualifiedCmdletNames" {
        # Arrange
        $scriptFolder = GenXdev\Expand-Path (
            [IO.Path]::GetTempPath() + "\tmp$([System.Guid]::NewGuid().ToString())\"
        )
        $scriptPath = GenXdev\Expand-Path "$scriptFolder\TestScript.ps1" -CreateDirectory

        try {

            [IO.File]::WriteAllText($scriptPath, @"
ls c:\
Get-Date
"@, [Text.Encoding]::UTF8)

            # Act
            $result = @(PSScriptAnalyzer\Invoke-ScriptAnalyzer `
                    -Path $scriptFolder `
                    -IncludeRule @("PSUseFullyQualifiedCmdletNames") `
                    -Severity Warning `
                    -Fix `
                    -Settings @{
                        Rules = @{
                            PSUseFullyQualifiedCmdletNames = @{
                                Enable = $true
                            }
                        }
                    }
            )

            # Assert
            $result.Count | Pester\Should -eq 0

            $scriptContent = [IO.File]::ReadAllText($scriptPath).Trim()

            $scriptContent | Pester\Should -Be @"
Microsoft.PowerShell.Management\Get-ChildItem c:\
Microsoft.PowerShell.Utility\Get-Date
"@
        }
        finally {

            Microsoft.PowerShell.Management\Remove-Item $scriptFolder -Recurse -Force
        }
    }
}