###############################################################################
# Unit tests for Get-ModuleCmdletMetaData
# Tests module-wide metadata retrieval with SubModuleName + CmdletType
###############################################################################

Pester\BeforeDiscovery {
    $null = Microsoft.PowerShell.Core\Get-Module -Name GenXdev -ListAvailable
}

Pester\BeforeAll {
    # GenXdev module auto-loads via GenXdev.psd1
}

Pester\Describe 'Get-ModuleCmdletMetaData — PSScriptAnalyzer' {

    Pester\It 'should pass PSScriptAnalyzer rules' {

        $scriptPath = GenXdev\Expand-Path (
            "$PSScriptRoot\..\..\Functions\GenXdev.Coding.PowerShell." +
            'Modules\Get-ModuleCmdletMetaData.ps1')

        $analyzerResults = GenXdev\Invoke-GenXdevScriptAnalyzer `
            -ScriptFilePath $scriptPath

        [string] $message = ''
        $analyzerResults | Microsoft.PowerShell.Core\ForEach-Object {
            $message = $message + @"
--------------------------------------------------
Rule: $($_.RuleName)
Description: $($_.Description)
Message: $($_.Message)
`r`n
"@
        }

        $analyzerResults.Count | Pester\Should -Be 0 -Because @"
The following PSScriptAnalyzer rules are being violated:
$message
"@
    }
}

Pester\Describe 'Get-ModuleCmdletMetaData — returns all cmdlets in module' {

    Pester\BeforeAll {
        $Script:allResults = @(GenXdev\Get-ModuleCmdletMetaData -ModuleName 'GenXdev')
    }

    Pester\It 'returns an array of hashtables with required keys' {

        $results = $Script:allResults

        $results | Pester\Should -Not -BeNullOrEmpty
        $results.Count | Pester\Should -BeGreaterThan 10

        foreach ($r in $results) {
            $r.ContainsKey('CmdletName') | Pester\Should -Be $true
            $r.ContainsKey('SubModuleName') | Pester\Should -Be $true
            $r.ContainsKey('CmdletType') | Pester\Should -Be $true
        }
    }
}

Pester\Describe 'Get-ModuleCmdletMetaData — C# cmdlet (Find-Item)' {

    Pester\BeforeAll {
        $Script:allResults = @(GenXdev\Get-ModuleCmdletMetaData -ModuleName 'GenXdev')
    }

    Pester\It 'adds SubModuleName property from .NET namespace' {

        $results = $Script:allResults
        $meta = @($results |
            Microsoft.PowerShell.Core\Where-Object {
                $_.CmdletName -eq 'Find-Item'
            })[0]

        $meta | Pester\Should -Not -BeNullOrEmpty
        $meta['SubModuleName'] | Pester\Should -BeLike 'GenXdev.*'
    }

    Pester\It 'adds CmdletType = "Cmdlet" for compiled cmdlets' {

        $results = $Script:allResults
        $meta = @($results |
            Microsoft.PowerShell.Core\Where-Object {
                $_.CmdletName -eq 'Find-Item'
            })[0]

        $meta | Pester\Should -Not -BeNullOrEmpty
        $meta['CmdletType'] | Pester\Should -Be 'Cmdlet'
    }

    Pester\It 'preserves all Get-CmdletMetaData top-level keys' {

        $results = $Script:allResults
        $meta = @($results |
            Microsoft.PowerShell.Core\Where-Object {
                $_.CmdletName -eq 'Find-Item'
            })[0]

        $meta | Pester\Should -Not -BeNullOrEmpty
        $meta.ContainsKey('Definition') | Pester\Should -Be $true
        $meta.ContainsKey('Synopsis') | Pester\Should -Be $true
        $meta.ContainsKey('Description') | Pester\Should -Be $true
        $meta.ContainsKey('Examples') | Pester\Should -Be $true
        $meta.ContainsKey('Aliases') | Pester\Should -Be $true
        $meta.ContainsKey('Parameters') | Pester\Should -Be $true
        $meta.ContainsKey('OutputType') | Pester\Should -Be $true
        $meta.ContainsKey('License') | Pester\Should -Be $true
    }

    Pester\It 'contains GPLv3 license text' {

        $results = $Script:allResults
        $meta = @($results |
            Microsoft.PowerShell.Core\Where-Object { $_.CmdletName -eq 'Find-Item' })[0]

        $meta.License | Pester\Should -Not -BeNullOrEmpty
        $meta.License | Pester\Should -BeLike '*GNU GENERAL PUBLIC LICENSE*'
    }

    Pester\It 'preserves cmdlet aliases from base metadata' {

        $results = $Script:allResults
        $meta = @($results |
            Microsoft.PowerShell.Core\Where-Object {
                $_.CmdletName -eq 'Find-Item'
            })[0]

        $meta | Pester\Should -Not -BeNullOrEmpty
        $meta.Aliases | Pester\Should -Not -BeNullOrEmpty
        $meta.Aliases | Pester\Should -Contain 'l'
    }

    Pester\It 'preserves parameter metadata correctly' {

        $results = $Script:allResults
        $meta = @($results |
            Microsoft.PowerShell.Core\Where-Object {
                $_.CmdletName -eq 'Find-Item'
            })[0]

        $meta | Pester\Should -Not -BeNullOrEmpty
        $meta.Parameters | Pester\Should -Not -BeNullOrEmpty
        $meta.Parameters.Count | Pester\Should -BeGreaterThan 0

        $nameParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Name' }

        $nameParam | Pester\Should -Not -BeNullOrEmpty
        $nameParam.ParameterType | Pester\Should -Not -BeNullOrEmpty
    }
}

Pester\Describe 'Get-ModuleCmdletMetaData — script cmdlets' {

    Pester\BeforeAll {
        $Script:allResults = @(GenXdev\Get-ModuleCmdletMetaData -ModuleName 'GenXdev')
    }

    Pester\It 'adds CmdletType = "Function" for script cmdlets' {

        $results = $Script:allResults
        $functions = @($results |
            Microsoft.PowerShell.Core\Where-Object {
                $_.CmdletType -eq 'Function'
            })

        $functions.Count | Pester\Should -BeGreaterThan 0
    }

    Pester\It 'resolves SubModuleName for all results' {

        $results = $Script:allResults

        foreach ($r in $results) {
            $r['SubModuleName'] | Pester\Should -Not -BeNullOrEmpty
        }
    }
}

Pester\Describe 'Get-ModuleCmdletMetaData — error handling' {

    Pester\It 'errors for non-existent module' {

        $results = GenXdev\Get-ModuleCmdletMetaData `
            -ModuleName 'NonExistentModuleXYZ123' `
            -ErrorVariable errors 2>&1 |
            Microsoft.PowerShell.Core\Where-Object { $_ -is [string] }

        $results | Pester\Should -BeNullOrEmpty
        $errors.Count | Pester\Should -BeGreaterThan 0
    }
}

Pester\Describe 'Get-ModuleCmdletMetaData — pass-through parameters' {

    Pester\BeforeAll {
        $Script:allResultsWithSkip = @(GenXdev\Get-ModuleCmdletMetaData `
            -ModuleName 'GenXdev' -SkipTranslation)
        $Script:allResultsWithLang = @(GenXdev\Get-ModuleCmdletMetaData `
            -ModuleName 'GenXdev' -Language 'en-US')
    }

    Pester\It 'accepts -SkipTranslation without error' {

        $results = $Script:allResultsWithSkip

        $results | Pester\Should -Not -BeNullOrEmpty
        $results.Count | Pester\Should -BeGreaterThan 0
    }

    Pester\It 'accepts -Language en-US without error' {

        $results = $Script:allResultsWithLang

        $results | Pester\Should -Not -BeNullOrEmpty
        $results.Count | Pester\Should -BeGreaterThan 0
    }
}
