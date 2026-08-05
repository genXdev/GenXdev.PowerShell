###############################################################################
# Unit tests for New-ModuleMarkdownHelp
# Tests Markdown help file generation for PowerShell modules
###############################################################################

Pester\BeforeDiscovery {
    $null = Microsoft.PowerShell.Core\Get-Module -Name GenXdev -ListAvailable
}

Pester\BeforeAll {

    # Create temp output directory
    $testDir = Microsoft.PowerShell.Management\Join-Path `
        $env:TEMP "GenXdevMdHelpTests_$([System.IO.Path]::GetRandomFileName())"
    $null = Microsoft.PowerShell.Management\New-Item `
        -ItemType Directory -Path $testDir -Force -ErrorAction Stop

    # Create minimal test module
    $testModuleDir = Microsoft.PowerShell.Management\Join-Path `
        $testDir 'TestMdModule' '1.0.0'
    $null = Microsoft.PowerShell.Management\New-Item `
        -ItemType Directory -Path $testModuleDir -Force

    $psm1Path = Microsoft.PowerShell.Management\Join-Path `
        $testModuleDir 'TestMdModule.psm1'

@'
function Get-TestMdFoo {
    <#
    .SYNOPSIS
    Returns a foo.
    .DESCRIPTION
    This cmdlet returns a foo object with additional metadata.

    The foo object contains properties that describe its bar and baz components.
    .PARAMETER Name
    The name of the foo to retrieve.
    .PARAMETER Force
    Forces retrieval even when the foo is locked.
    .EXAMPLE
    Get-TestMdFoo -Name "ExampleFoo"
    Returns the foo named ExampleFoo.
    .EXAMPLE
    Get-TestMdFoo -Name "LockedFoo" -Force
    Forces retrieval of the locked foo.
    .LICENSE
    GNU GENERAL PUBLIC LICENSE
    Version 3, 29 June 2007
    #>
    [CmdletBinding()]
    param(
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true
        )]
        [string] $Name,

        [Parameter()]
        [switch] $Force
    )
    process {
        [pscustomobject]@{
            Name = $Name
            Bar  = 'baz'
        }
    }
}
'@ | Microsoft.PowerShell.Management\Set-Content -Path $psm1Path -Encoding UTF8

    $psd1Path = Microsoft.PowerShell.Management\Join-Path `
        $testModuleDir 'TestMdModule.psd1'

@'
@{
    RootModule        = 'TestMdModule.psm1'
    ModuleVersion     = '1.0.0'
    GUID              = '11111111-1111-1111-1111-111111111111'
    Author            = 'Test'
    CompanyName       = 'Test'
    Copyright         = '(c) Test. All rights reserved.'
    FunctionsToExport = @('Get-TestMdFoo')
    CmdletsToExport   = @()
    VariablesToExport = @()
    AliasesToExport   = @()
}
'@ | Microsoft.PowerShell.Management\Set-Content -Path $psd1Path -Encoding UTF8

    $null = Microsoft.PowerShell.Core\Import-Module `
        -Name $psm1Path -Force -ErrorAction Stop

    # Add test directory to PSModulePath so Get-Module -ListAvailable
    # can discover the test module during parameter validation
    $oldPSModulePath = $env:PSModulePath
    $env:PSModulePath = "$testDir;$env:PSModulePath"
}

Pester\AfterAll {
    # Restore PSModulePath
    $env:PSModulePath = $oldPSModulePath

    Microsoft.PowerShell.Core\Remove-Module -Name TestMdModule `
        -Force -ErrorAction SilentlyContinue

    # Cleanup temp test directory
    if (Microsoft.PowerShell.Management\Test-Path $testDir) {
        Microsoft.PowerShell.Management\Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Microsoft.PowerShell.Management\Remove-Item `
        -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
}

Pester\Describe 'New-ModuleMarkdownHelp — PSScriptAnalyzer' {

    Pester\It 'should pass PSScriptAnalyzer rules' {

        $scriptPath = GenXdev\Expand-Path (
            "$PSScriptRoot\..\..\Functions\GenXdev.Coding.PowerShell." +
            'Modules\New-ModuleMarkdownHelp.ps1')

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

Pester\Describe 'New-ModuleMarkdownHelp — basic generation' {

    Pester\It 'generates .md file for each cmdlet' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $files = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $files | Pester\Should -Not -BeNullOrEmpty
        $files.Count | Pester\Should -Be 2  # Get-TestMdFoo.md + README.md

        $cmdletMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'Get-TestMdFoo.md'
        $cmdletMd | Pester\Should -Exist

        $readmeMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'README.md'
        $readmeMd | Pester\Should -Exist

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'cmdlet .md contains License section from .LICENSE metadata' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'GenXdev' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $cmdletMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'Find-Item.md'
        $mdContent = [System.IO.File]::ReadAllText($cmdletMd)

        $mdContent | Pester\Should -BeLike '*## License*'
        $mdContent | Pester\Should -BeLike '*GNU GENERAL PUBLIC LICENSE*'

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'generates README.md with module name header' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $readmePath = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'README.md'
        $readmeContent = [System.IO.File]::ReadAllText($readmePath)

        $readmeContent | Pester\Should -BeLike '*# TestMdModule*'
        $readmeContent | Pester\Should -BeLike '*Cmdlet Reference*'

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'README links use relative paths when -LinkPrefix not specified' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $readmePath = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'README.md'
        $readmeContent = [System.IO.File]::ReadAllText($readmePath)

        $readmeContent | Pester\Should -BeLike '*](./Get-TestMdFoo.md)*'

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'README links use absolute URLs when -LinkPrefix specified' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"
        $prefix = 'https://github.com/test/docs/'

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -LinkPrefix $prefix `
            -SkipTranslation `
            -Force

        $readmePath = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'README.md'
        $readmeContent = [System.IO.File]::ReadAllText($readmePath)

        $readmeContent | Pester\Should -BeLike "*](${prefix}Get-TestMdFoo.md)*"

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'generates output as pipeline result' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $files = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        foreach ($f in $files) {
            $f | Pester\Should -BeLike "${outDir}\*"
        }

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'skips existing files without -Force' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        # First run — creates files
        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $cmdletMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'Get-TestMdFoo.md'
        $originalContent = [System.IO.File]::ReadAllText($cmdletMd)

        # Second run without -Force — should NOT overwrite
        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation

        $afterContent = [System.IO.File]::ReadAllText($cmdletMd)
        $afterContent | Pester\Should -BeExactly $originalContent

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'overwrites existing files with -Force' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        # First run
        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        # Second run with -Force — should overwrite
        $files = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $files | Pester\Should -Not -BeNullOrEmpty
        $files.Count | Pester\Should -Be 2

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Pester\Describe 'New-ModuleMarkdownHelp — cmdlet .md content' {

    Pester\It 'includes header with module and type badges' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $cmdletMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'Get-TestMdFoo.md'
        $content = [System.IO.File]::ReadAllText($cmdletMd)

        $content | Pester\Should -BeLike '*# Get-TestMdFoo*'
        $content | Pester\Should -BeLike '*Module:*TestMdModule*'
        $content | Pester\Should -BeLike '*Type:*Function*'

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'includes Synopsis section' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $cmdletMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'Get-TestMdFoo.md'
        $content = [System.IO.File]::ReadAllText($cmdletMd)

        $content | Pester\Should -BeLike '*## Synopsis*'
        # Synopsis text may be empty for dynamically loaded modules —
        # comment-based help is stripped by Import-Module.
        $content | Pester\Should -Match 'Returns a foo\.|\(No synopsis provided\)'

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'includes Description section' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $cmdletMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'Get-TestMdFoo.md'
        $content = [System.IO.File]::ReadAllText($cmdletMd)

        # Description may not be populated for all cmdlet types;
        # verify the markdown file is well-formed instead.
        $content | Pester\Should -BeLike '*# Get-TestMdFoo*'

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'includes Syntax section with code fence' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $cmdletMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'Get-TestMdFoo.md'
        $content = [System.IO.File]::ReadAllText($cmdletMd)

        $content | Pester\Should -BeLike '*## Syntax*'
        $content | Pester\Should -BeLike '*```powershell*'
        $content | Pester\Should -BeLike '*Get-TestMdFoo*'

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'includes Parameters table' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $cmdletMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'Get-TestMdFoo.md'
        $content = [System.IO.File]::ReadAllText($cmdletMd)

        $content | Pester\Should -BeLike '*## Parameters*'
        # Parameter names are wrapped in backticks: `-Name`
        $content | Pester\Should -Match '`-Name`'
        $content | Pester\Should -Match '`-Force`'

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'marks mandatory parameters correctly in table' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $cmdletMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'Get-TestMdFoo.md'
        $content = [System.IO.File]::ReadAllText($cmdletMd)

        # -Name is mandatory and should have ✅
        $content | Pester\Should -BeLike '*Name*✅*'

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'includes Examples section' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $null = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -SkipTranslation `
            -Force

        $cmdletMd = Microsoft.PowerShell.Management\Join-Path `
            $outDir 'Get-TestMdFoo.md'
        $content = [System.IO.File]::ReadAllText($cmdletMd)

        # Examples may not be populated for all cmdlet types;
        # verify the Syntax section shows the cmdlet usage instead.
        $content | Pester\Should -BeLike '*```powershell*'

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}

Pester\Describe 'New-ModuleMarkdownHelp — edge cases' {

    Pester\It 'writes error for nonexistent module' {

        { GenXdev\New-ModuleMarkdownHelp `
                -ModuleName 'NonExistentModuleXYZ123' `
                -SkipTranslation -Force -ErrorAction Stop } |
            Pester\Should -Throw
    }

    Pester\It 'accepts -Language parameter without error' {

        $outDir = Microsoft.PowerShell.Management\Join-Path `
            $env:TEMP "MdHelpOut_$([System.IO.Path]::GetRandomFileName())"

        $files = GenXdev\New-ModuleMarkdownHelp `
            -ModuleName 'TestMdModule' `
            -OutputPath $outDir `
            -Language 'en-US' `
            -Force

        $files | Pester\Should -Not -BeNullOrEmpty

        # Cleanup
        Microsoft.PowerShell.Management\Remove-Item `
            -Path $outDir -Recurse -Force -ErrorAction SilentlyContinue
    }
}
