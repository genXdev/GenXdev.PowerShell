###############################################################################
Pester\Describe 'Get-GenXDevCmdlet — parameter and wildcard tests' {

    Pester\Context '-CmdletName parameter' {

        Pester\It 'finds a specific cmdlet by exact name with -ExactMatch' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -CmdletName 'Add-ArrayTemplate' -ExactMatch)
            $result.Count | Pester\Should -Be 1
            $result[0].Name | Pester\Should -Be 'Add-ArrayTemplate'
        }

        Pester\It 'finds cmdlets with wildcard (*) at end' {
            $result = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'Add-Array*')
            $result.Count | Pester\Should -BeGreaterOrEqual 1
            $result.Name | Pester\Should -Contain 'Add-ArrayTemplate'
        }

        Pester\It 'finds cmdlets with wildcard (*) at start' {
            $result = @(GenXdev\Get-GenXDevCmdlet -CmdletName '*-ArrayTemplate')
            $result.Count | Pester\Should -Be 1
            $result[0].Name | Pester\Should -Be 'Add-ArrayTemplate'
        }

        Pester\It 'finds cmdlets with wildcard (*) in middle' {
            $result = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'Add-*Template')
            $result.Count | Pester\Should -BeGreaterOrEqual 1
            $result.Name | Pester\Should -Contain 'Add-ArrayTemplate'
        }

        Pester\It 'matches aliases when searching by CmdletName' {
            $result = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'gcmds' `
                    -ExactMatch)
            $result.Count | Pester\Should -Be 1
            $result[0].Name | Pester\Should -Be 'Get-GenXDevCmdlet'
        }

        Pester\It 'returns empty for non-existent cmdlet name' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -CmdletName 'NonExistentCmdletXYZ123')
            $result.Count | Pester\Should -Be 0
        }
    }

    Pester\Context '-ExactMatch parameter' {

        Pester\It 'without -ExactMatch, wraps search term in wildcards' {
            # "ArrayTemplate" should become "*ArrayTemplate*" implicitly
            $result = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'ArrayTemplate')
            $result.Count | Pester\Should -BeGreaterOrEqual 1
            $result.Name | Pester\Should -Contain 'Add-ArrayTemplate'
        }

        Pester\It 'with -ExactMatch, only matches exact name' {
            $result = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'ArrayTemplate' `
                    -ExactMatch)
            $result.Count | Pester\Should -Be 0
        }
    }

    Pester\Context 'fully qualified cmdlet names (Module\CmdletName)' {

        Pester\It 'finds cmdlet with GenXdev\ prefix' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -CmdletName 'GenXdev\Find-Item' -ExactMatch)
            $result.Count | Pester\Should -Be 1
            $result[0].Name | Pester\Should -Be 'Find-Item'
            $result[0].BaseModule | Pester\Should -Be 'GenXdev'
        }

        Pester\It 'does NOT find cmdlet with sub-module qualifier (invalid per convention)' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -CmdletName 'GenXdev.Helpers\Get-GenXDevCmdlet' -ExactMatch)
            $result.Count | Pester\Should -Be 0
        }

        Pester\It 'bare name without qualifier still works' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -CmdletName 'Find-Item' -ExactMatch)
            $result.Count | Pester\Should -Be 1
            $result[0].Name | Pester\Should -Be 'Find-Item'
        }

        Pester\It 'returns empty for wrong module qualifier' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -CmdletName 'NonExistent\Find-Item' -ExactMatch)
            $result.Count | Pester\Should -Be 0
        }

        Pester\It 'returns empty for right module but wrong cmdlet name' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -CmdletName 'GenXdev\NonExistentCmdlet' -ExactMatch)
            $result.Count | Pester\Should -Be 0
        }

        Pester\It 'supports multiple patterns mixed qualified and bare' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -CmdletName 'GenXdev\Find-Item', 'Get-GenXDevCmdlet' `
                    -ExactMatch)
            $result.Count | Pester\Should -Be 2
            $result.Name | Pester\Should -Contain 'Find-Item'
            $result.Name | Pester\Should -Contain 'Get-GenXDevCmdlet'
        }
    }

    Pester\Context '-ModuleName parameter' {

        Pester\It 'filters to a specific sub-module' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -ModuleName 'GenXdev.Coding.Templating')
            $result.Count | Pester\Should -BeGreaterOrEqual 1
            ($result | Microsoft.PowerShell.Core\Where-Object {
                    $_.Name -eq 'Add-ArrayTemplate'
                }).Count | Pester\Should -Be 1
        }

        Pester\It 'supports wildcards in module name' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -ModuleName 'GenXdev.Coding.*')
            $result.Count | Pester\Should -BeGreaterOrEqual 1
        }

        Pester\It 'combines -ModuleName and -CmdletName filters' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -ModuleName 'GenXdev' `
                    -CmdletName 'Get-GenXDevCmdlet')
            $result.Count | Pester\Should -Be 1
            $result[0].Name | Pester\Should -Be 'Get-GenXDevCmdlet'
        }

        Pester\It 'combines -ModuleName wildcard and -CmdletName' {
            $result = @(GenXdev\Get-GenXDevCmdlet `
                    -ModuleName 'GenXdev' `
                    -CmdletName 'Get-GenXDevCmdlet')
            $result.Count | Pester\Should -Be 1
            $result[0].ModuleName | Pester\Should -BeLike 'GenXdev'
        }
    }

    Pester\Context '-NoLocal parameter' {

        Pester\It 'excludes GenXdev.Local modules' {
            $result = @(GenXdev\Get-GenXDevCmdlet -NoLocal `
                    -OnlyReturnModuleNames)
            $result | Pester\Should -Not -Contain 'GenXdev.Local'
        }

        Pester\It 'still includes GenXdev main module' {
            $result = @(GenXdev\Get-GenXDevCmdlet -NoLocal `
                    -OnlyReturnModuleNames)
            $result | Pester\Should -Contain 'GenXdev'
        }
    }

    Pester\Context '-OnlyReturnModuleNames parameter' {

        Pester\It 'returns string values, not GenXdevCmdletInfo objects' {
            $result = @(GenXdev\Get-GenXDevCmdlet -OnlyReturnModuleNames)
            $result.Count | Pester\Should -BeGreaterOrEqual 1
            $result[0] | Pester\Should -BeOfType ([string])
        }

        Pester\It 'returns unique module names' {
            $result = @(GenXdev\Get-GenXDevCmdlet -OnlyReturnModuleNames)
            $unique = @($result | Microsoft.PowerShell.Utility\Select-Object `
                    -Unique)
            $result.Count | Pester\Should -Be $unique.Count
        }

        Pester\It 'returns GenXdev as one of the module names' {
            $result = @(GenXdev\Get-GenXDevCmdlet -OnlyReturnModuleNames)
            $result | Pester\Should -Contain 'GenXdev'
        }
    }

    Pester\Context 'output type and structure' {

        Pester\It 'returns GenXdevCmdletInfo objects by default' {
            $result = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'Find-Item' `
                    -ExactMatch)
            $result[0] | Pester\Should -BeOfType (
                [GenXdev.Helpers.GenXdevCmdletInfo])
        }

        Pester\It 'GenXdevCmdletInfo has expected properties' {
            $result = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'Find-Item' `
                    -ExactMatch)
            $result[0].Name | Pester\Should -Not -BeNullOrEmpty
            $result[0].ModuleName | Pester\Should -Not -BeNullOrEmpty
            $result[0].BaseModule | Pester\Should -Not -BeNullOrEmpty
            $result[0].ScriptFilePath | Pester\Should -Exist
        }

        Pester\It 'all returned cmdlets have non-empty Name' {
            $result = @(GenXdev\Get-GenXDevCmdlet)
            $result.Count | Pester\Should -BeGreaterOrEqual 10
            $emptyNames = @($result |
                Microsoft.PowerShell.Core\Where-Object {
                    [string]::IsNullOrWhiteSpace($_.Name)
                })
            $emptyNames.Count | Pester\Should -Be 0
        }
    }

    Pester\Context 'cache behavior' {

        Pester\It 'consistently returns same results on repeated calls' {
            # The cache should produce identical results across calls
            $result1 = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'Find-Item' `
                    -ExactMatch)
            $result2 = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'Find-Item' `
                    -ExactMatch)
            $result1.Count | Pester\Should -Be $result2.Count
            $result1[0].Name | Pester\Should -Be $result2[0].Name
            $result1[0].ModuleName | Pester\Should -Be $result2[0].ModuleName
        }

        Pester\It 'cache survives across calls with different filters' {
            # Call with one filter, then another — first result should
            # still be correct after second call populates more cache
            $result1 = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'Find-Item' `
                    -ExactMatch)
            $result2 = @(GenXdev\Get-GenXDevCmdlet -CmdletName 'Get-GenXDevCmdlet' `
                    -ExactMatch)
            $result1.Count | Pester\Should -Be 1
            $result2.Count | Pester\Should -Be 1
        }
    }
}