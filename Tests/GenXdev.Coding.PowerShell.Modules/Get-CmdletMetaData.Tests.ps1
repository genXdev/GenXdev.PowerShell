###############################################################################
# Unit tests for Get-CmdletMetaData
# Tests per-cmdlet metadata retrieval for C# and .ps1 cmdlets
###############################################################################

Pester\Describe 'Get-CmdletMetaData — C# cmdlet (Find-Item)' {

    Pester\It 'returns a hashtable with all expected top-level keys' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $meta | Pester\Should -Not -BeNullOrEmpty
        $meta -is [System.Collections.Hashtable] | Pester\Should -Be $true
        $meta.ContainsKey('Definition') | Pester\Should -Be $true
        $meta.ContainsKey('Synopsis') | Pester\Should -Be $true
        $meta.ContainsKey('Description') | Pester\Should -Be $true
        $meta.ContainsKey('Examples') | Pester\Should -Be $true
        $meta.ContainsKey('Aliases') | Pester\Should -Be $true
        $meta.ContainsKey('Parameters') | Pester\Should -Be $true
        $meta.ContainsKey('OutputType') | Pester\Should -Be $true
        $meta.ContainsKey('License') | Pester\Should -Be $true
    }

    Pester\It 'license contains GPLv3 text' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $meta.License | Pester\Should -Not -BeNullOrEmpty
        $meta.License | Pester\Should -BeLike '*GNU GENERAL PUBLIC LICENSE*'
    }

    Pester\It 'detects cmdlet-level aliases' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $meta.Aliases | Pester\Should -Not -BeNullOrEmpty -Because 'Find-Item has [Alias("l")]'
        $meta.Aliases | Pester\Should -Contain 'l'
    }

    Pester\It 'returns correct Synopsis from [Description] attribute' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $meta.Synopsis | Pester\Should -Not -BeNullOrEmpty
        $meta.Synopsis | Pester\Should -BeLike '*Search for files*'
    }

    Pester\It 'returns correct Description from [Description] attribute' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $meta.Description | Pester\Should -Not -BeNullOrEmpty
        $meta.Description | Pester\Should -BeLike '*Fast multi-threaded search*'
    }

    Pester\It 'returns Examples from [Description] attribute' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $meta.Examples | Pester\Should -Not -BeNullOrEmpty
        $meta.Examples.Count | Pester\Should -BeGreaterThan 0
    }

    Pester\It 'returns empty OutputType when no [OutputType] attribute on C# class' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        # Find-Item has no [OutputType] attribute on the C# class
        $meta.OutputType.Count | Pester\Should -Be 0
    }

    Pester\It 'extracts all parameter objects' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $meta.Parameters | Pester\Should -Not -BeNullOrEmpty
        $meta.Parameters.Count | Pester\Should -BeGreaterThan 5
    }

    Pester\It 'includes ParameterType on every parameter' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        foreach ($p in $meta.Parameters) {
            $p.PSObject.Properties.Name | Pester\Should -Contain 'ParameterType'
            $p.ParameterType | Pester\Should -Not -BeNullOrEmpty
        }
    }

    Pester\It 'resolves parameter aliases correctly (Name param)' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $nameParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Name' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $nameParam | Pester\Should -Not -BeNullOrEmpty
        $nameParam.Aliases | Pester\Should -Contain 'like'
        $nameParam.Aliases | Pester\Should -Contain 'Path'
        $nameParam.Aliases | Pester\Should -Contain 'LiteralPath'
        $nameParam.SupportsWildcards | Pester\Should -Be $true
        $nameParam.ParameterType | Pester\Should -Be 'System.String[]'
    }

    Pester\It 'resolves DefaultValue for C# string[] with initializer (uninitialized instance — field init not available)' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $contentParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Content' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $contentParam | Pester\Should -Not -BeNullOrEmpty
        # NOTE: C# field initializers like = new string[1] { ".*" } run in
        # the constructor. FormatterServices.GetUninitializedObject skips
        # constructors, so field-initialized defaults are $null here.
        # [DefaultValueAttribute] or SwitchParameter defaults still work.
        $contentParam.DefaultValue | Pester\Should -Be $null -Because 'Field initializers are not accessible without running the constructor'
    }

    Pester\It 'resolves SwitchParameter default to $false' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $dirParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Directory' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $dirParam | Pester\Should -Not -BeNullOrEmpty
        $dirParam.ParameterType | Pester\Should -Be 'System.Management.Automation.SwitchParameter'
        $dirParam.DefaultValue | Pester\Should -Be $false
    }

    Pester\It 'resolves Position correctly (Name = 0, Content = 1)' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $nameParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Name' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $contentParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Content' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $nameParam.Position | Pester\Should -Be '0'
        $contentParam.Position | Pester\Should -Be '1'
    }

    Pester\It 'resolves Mandatory / ValueFromPipeline correctly' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'

        $inputParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Input' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $inputParam | Pester\Should -Not -BeNullOrEmpty
        $inputParam.Mandatory | Pester\Should -Be $false
        $inputParam.ValueFromPipeline | Pester\Should -Be $true
        $inputParam.ValueFromPipelineByPropertyName | Pester\Should -Be $true
    }
}

###############################################################################
Pester\Describe 'Get-CmdletMetaData — .ps1 script cmdlet (Find-Image)' {

    Pester\It 'returns a hashtable with all expected top-level keys' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $meta | Pester\Should -Not -BeNullOrEmpty
        $meta -is [System.Collections.Hashtable] | Pester\Should -Be $true
        $meta.ContainsKey('Definition') | Pester\Should -Be $true
        $meta.ContainsKey('Synopsis') | Pester\Should -Be $true
        $meta.ContainsKey('Description') | Pester\Should -Be $true
        $meta.ContainsKey('Examples') | Pester\Should -Be $true
        $meta.ContainsKey('Aliases') | Pester\Should -Be $true
        $meta.ContainsKey('Parameters') | Pester\Should -Be $true
        $meta.ContainsKey('OutputType') | Pester\Should -Be $true
        $meta.ContainsKey('License') | Pester\Should -Be $true
    }

    Pester\It 'license contains GPLv3 text (.ps1 path)' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $meta.License | Pester\Should -Not -BeNullOrEmpty
        $meta.License | Pester\Should -BeLike '*GNU GENERAL PUBLIC LICENSE*'
    }

    Pester\It 'detects function-level aliases from [Alias()]' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $meta.Aliases | Pester\Should -Not -BeNullOrEmpty
        $meta.Aliases | Pester\Should -Contain 'findimages'
        $meta.Aliases | Pester\Should -Contain 'li'
    }

    Pester\It 'reads Synopsis from comment-based help' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $meta.Synopsis | Pester\Should -Not -BeNullOrEmpty
        $meta.Synopsis | Pester\Should -BeLike '*Searches for image files*'
    }

    Pester\It 'reads Description from comment-based help' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $meta.Description | Pester\Should -Not -BeNullOrEmpty
        $meta.Description | Pester\Should -BeLike '*Searches for image files*'
    }

    Pester\It 'reads Examples from comment-based help' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $meta.Examples | Pester\Should -Not -BeNullOrEmpty
        $meta.Examples.Count | Pester\Should -BeGreaterThan 0
    }

    Pester\It 'reads OutputType from [OutputType()] attribute on function' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $meta.OutputType | Pester\Should -Not -BeNullOrEmpty
        $meta.OutputType | Pester\Should -Contain 'GenXdev.Helpers.ImageSearchResult'
        $meta.OutputType | Pester\Should -Contain 'System.String'
    }

    Pester\It 'extracts all parameter objects' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $meta.Parameters | Pester\Should -Not -BeNullOrEmpty
        $meta.Parameters.Count | Pester\Should -BeGreaterThan 5
    }

    Pester\It 'includes ParameterType on every parameter' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        foreach ($p in $meta.Parameters) {
            $p.PSObject.Properties.Name | Pester\Should -Contain 'ParameterType'
            $p.ParameterType | Pester\Should -Not -BeNullOrEmpty
        }
    }

    Pester\It 'resolves parameter aliases correctly (Name param)' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $nameParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Name' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $nameParam | Pester\Should -Not -BeNullOrEmpty
        $nameParam.Aliases | Pester\Should -Contain 'imagespath'
        $nameParam.Aliases | Pester\Should -Contain 'directories'
        $nameParam.Aliases | Pester\Should -Contain 'imgdirs'
        $nameParam.Aliases | Pester\Should -Contain 'imagedirectory'
        $nameParam.Aliases | Pester\Should -Contain 'ImageDirectories'
    }

    Pester\It 'resolves ParameterType correctly (Name is System.String[])' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $nameParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Name' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $nameParam.ParameterType | Pester\Should -Be 'System.String[]'
    }

    Pester\It 'resolves DefaultValue from AST expression (Any = @())' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $anyParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Any' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $anyParam | Pester\Should -Not -BeNullOrEmpty
        $anyParam.DefaultValue | Pester\Should -Be '@()'
    }

    Pester\It 'resolves DefaultValue from AST expression (Name = @(''.\''))' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $nameParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Name' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $nameParam.DefaultValue | Pester\Should -Be "@('.\')"
    }

    Pester\It 'resolves Position correctly (Any = 0, Name = 1)' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $anyParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Any' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $nameParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Name' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $anyParam.Position | Pester\Should -Be '0'
        $nameParam.Position | Pester\Should -Be '1'
    }

    Pester\It 'resolves Mandatory correctly' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'

        $anyParam = $meta.Parameters |
            Microsoft.PowerShell.Core\Where-Object { $_.Name -eq 'Any' } |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        $anyParam.Mandatory | Pester\Should -Be $false
    }
}

###############################################################################
Pester\Describe 'Get-CmdletMetaData — edge cases' {

    Pester\It 'resolves cmdlet through alias (l -> Find-Item)' {

        $meta = GenXdev\Get-CmdletMetaData -Name 'l'

        $meta | Pester\Should -Not -BeNullOrEmpty
        $meta.Definition | Pester\Should -BeLike 'Find-Item*'
    }

    Pester\It 'returns empty synopsis for .ps1 cmdlet with no comment-based help' {

        # Create a temp function in global scope so Get-Command can find
        # it. Pester runs in a module scope, so the function must be
        # globally visible.
        Microsoft.PowerShell.Management\New-Item -Path 'function:global:Test-NoHelp' -Value {
            param([string]$Name)
            Microsoft.PowerShell.Utility\Write-Verbose $Name
        } -Force -ErrorAction SilentlyContinue | Microsoft.PowerShell.Core\Out-Null

        try {
            $meta = GenXdev\Get-CmdletMetaData -Name 'Test-NoHelp'
            $meta.Synopsis | Pester\Should -Be ''
            $meta.Description | Pester\Should -Be ''
            $meta.Examples.Count | Pester\Should -Be 0
            $meta.OutputType.Count | Pester\Should -Be 0
            $meta.Aliases.Count | Pester\Should -Be 0
        }
        finally {
            Microsoft.PowerShell.Management\Remove-Item -Path 'function:global:Test-NoHelp' -Force -ErrorAction SilentlyContinue
        }
    }
}
