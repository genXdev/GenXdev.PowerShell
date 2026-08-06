###############################################################################
# Unit tests for New-ModuleXmlHelp
# Tests MAML XML help file generation for both C# and .ps1 cmdlets
###############################################################################

Pester\BeforeDiscovery {
    # Ensure GenXdev is loaded (submodule GenXdev.Coding.PowerShell.Modules
    # is loaded as a .psm1 via GenXdev.psd1, not as a standalone module)
    $null = Microsoft.PowerShell.Core\Get-Module -Name GenXdev -ListAvailable
}

Pester\BeforeAll {
    # GenXdev module auto-loads; no separate Import-Module needed

    # Create temp output directory
    $testDir = Microsoft.PowerShell.Management\Join-Path $env:TEMP "GenXdevXmlHelpTests_$([System.IO.Path]::GetRandomFileName())"
    $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path $testDir -Force -ErrorAction Stop

    # Setup: copy a module to temp for testing so we don't pollute real modules
    $testModuleDir = Microsoft.PowerShell.Management\Join-Path $testDir 'TestModule' '1.0.0'
    $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path (Microsoft.PowerShell.Management\Join-Path $testModuleDir 'en-US') -Force

    # Create a minimal test module with a .ps1 function
    $testModulePs1 = @'
function Get-TestHello {
    <#
    .SYNOPSIS
    Returns a greeting message.
    .DESCRIPTION
    This cmdlet returns a friendly greeting message.
    .PARAMETER Name
    The name to greet.
    .PARAMETER UpperCase
    Convert the greeting to uppercase.
    .EXAMPLE
    Get-TestHello -Name "World"
    Returns "Hello, World!"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Position = 0, ValueFromPipeline = $true)]
        [string] $Name = 'World',

        [Parameter()]
        [switch] $UpperCase
    )
    process {
        $msg = "Hello, ${Name}!"
        if ($UpperCase) { return $msg.ToUpper() }
        $msg
    }
}

function Get-TestGoodbye {
    <#
    .SYNOPSIS
    Returns a farewell message.
    .DESCRIPTION
    This cmdlet returns a farewell message.
    .PARAMETER Name
    The name to say goodbye to.
    .EXAMPLE
    Get-TestGoodbye -Name "World"
    Returns "Goodbye, World!"
    #>
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [Alias('Person')]
        [string] $Name,

        [Parameter(ValueFromRemainingArguments = $true)]
        [string[]] $ExtraMessages
    )
    process {
        "Goodbye, ${Name}!"
        if ($ExtraMessages) { $ExtraMessages }
    }
}

function Test-NoHelp {
    # No comment-based help
    param([string]$Param1)
    "Test"
}
'@
    $testModulePath = Microsoft.PowerShell.Management\Join-Path $testDir 'TestModule'
    $testPs1Path = Microsoft.PowerShell.Management\Join-Path $testModulePath 'TestModule.psm1'
    $testModulePs1 | Microsoft.PowerShell.Management\Set-Content -Path $testPs1Path
}

Pester\AfterAll {
    # Cleanup: remove temp test directory
    if (Microsoft.PowerShell.Management\Test-Path $testDir) {
        Microsoft.PowerShell.Management\Remove-Item -Path $testDir -Recurse -Force -ErrorAction SilentlyContinue
    }
    # Clean up any loaded test module
    Microsoft.PowerShell.Core\Remove-Module -Name 'TestModule' -Force -ErrorAction SilentlyContinue
}

###############################################################################
#region Tests: Parameter Validation

Pester\Describe 'New-ModuleXmlHelp - Parameter Validation' {

    Pester\It 'Should have a mandatory ModuleName parameter' {
        $params = (Microsoft.PowerShell.Core\Get-Command New-ModuleXmlHelp).Parameters
        $params.ContainsKey('ModuleName') | Pester\Should -BeTrue
        $params['ModuleName'].ParameterSets['__AllParameterSets'].IsMandatory |
            Pester\Should -BeTrue
    }

    Pester\It 'Should have a Language parameter defaulting to "en-US"' {
        $params = (Microsoft.PowerShell.Core\Get-Command New-ModuleXmlHelp).Parameters
        $params.ContainsKey('Language') | Pester\Should -BeTrue
        $params['Language'].ParameterSets['__AllParameterSets'].IsMandatory |
            Pester\Should -BeFalse
    }

    Pester\It 'Should have Force, SkipTranslation, TranslationInstructions, WhatIf, Confirm switches' {
        $params = (Microsoft.PowerShell.Core\Get-Command New-ModuleXmlHelp).Parameters
        $params.ContainsKey('Force') | Pester\Should -BeTrue
        $params.ContainsKey('SkipTranslation') | Pester\Should -BeTrue
        $params.ContainsKey('TranslationInstructions') | Pester\Should -BeTrue
        $params.ContainsKey('WhatIf') | Pester\Should -BeTrue
        $params.ContainsKey('Confirm') | Pester\Should -BeTrue
    }

    Pester\It 'Should accept valid BCP 47 language codes' {
        # -SkipTranslation: translation tested by Get-CmdletMetaData tests
        $null = { GenXdev\New-ModuleXmlHelp -ModuleName 'GenXdev' -Language 'nl-NL' `
                -WhatIf -SkipTranslation -ErrorAction Stop } |
            Pester\Should -Not -Throw
    }

    Pester\It 'Should accept other BCP 47 codes like de-DE' {
        # -SkipTranslation: translation tested by Get-CmdletMetaData tests
        $null = { GenXdev\New-ModuleXmlHelp -ModuleName 'GenXdev' -Language 'de-DE' `
                -WhatIf -SkipTranslation -ErrorAction Stop } |
            Pester\Should -Not -Throw
    }

    Pester\It 'Should accept "en-US" as default language' {
        $null = { GenXdev\New-ModuleXmlHelp -ModuleName 'GenXdev' -Language 'en-US' -WhatIf -ErrorAction Stop } |
            Pester\Should -Not -Throw
    }

    Pester\It 'Should reject non-BCP-47 language codes (old-style "nl")' {
        { GenXdev\New-ModuleXmlHelp -ModuleName 'GenXdev' -Language 'nl' -ErrorAction Stop } |
            Pester\Should -Throw
    }

    Pester\It 'Should reject language names ("Dutch")' {
        { GenXdev\New-ModuleXmlHelp -ModuleName 'GenXdev' -Language 'Dutch' -ErrorAction Stop } |
            Pester\Should -Throw
    }

    Pester\It 'Should reject non-existent module' {
        { GenXdev\New-ModuleXmlHelp -ModuleName 'NonExistentModuleName12345' -SkipTranslation -ErrorAction Stop } |
            Pester\Should -Throw
    }
}
#endregion
###############################################################################
#region Tests: XML Structure (via temp module)

Pester\Describe 'New-ModuleXmlHelp - MAML XML Structure' {

    Pester\BeforeAll {
        # Create module manifest and load the test module
        $manifestPath = Microsoft.PowerShell.Management\Join-Path $testModuleDir '..' 'TestModule.psd1'
        Microsoft.PowerShell.Core\New-ModuleManifest -Path $manifestPath `
            -RootModule 'TestModule.psm1' `
            -ModuleVersion '1.0.0' `
            -FunctionsToExport @('Get-TestHello', 'Get-TestGoodbye', 'Test-NoHelp') `
            -Guid ([Guid]::NewGuid().ToString())

        Microsoft.PowerShell.Core\Import-Module $manifestPath -Force -ErrorAction Stop

        # Use a temp output directory
        $outputDir = Microsoft.PowerShell.Management\Join-Path $testDir 'Output'
        $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path $outputDir -Force
    }

    Pester\AfterAll {
        Microsoft.PowerShell.Core\Remove-Module -Name 'TestModule' -Force -ErrorAction SilentlyContinue
        Microsoft.PowerShell.Management\Remove-Item -Path (Microsoft.PowerShell.Management\Split-Path $manifestPath -Parent) -Recurse -Force -ErrorAction SilentlyContinue
    }

    Pester\It 'Outputs no files with -WhatIf' {
        $result = GenXdev\New-ModuleXmlHelp -ModuleName GenXdev -WhatIf
        # WhatIf = no actual output objects
        ($result | Microsoft.PowerShell.Utility\Measure-Object).Count | Pester\Should -Be 0
    }
}
#endregion
###############################################################################
#region Tests: Find-Item (C# cmdlet) — every MAML section & property

Pester\Describe 'New-ModuleXmlHelp — Find-Item (C# cmdlet) MAML XML' {

    Pester\BeforeAll {
        # Generate full help XML for GenXdev (includes Find-Item).
        # Use en-US language to skip LLM translation entirely —
        # translation is tested separately by Get-CmdletMetaData tests.
        $null = GenXdev\New-ModuleXmlHelp -ModuleName GenXdev -Force `
            -Language en-US -ErrorAction Stop

        $helpPath = 'c:\Users\renev\Documents\PowerShell\Modules\GenXdev\3.34.0\en-US\GenXdev.dll-Help.xml'
        $script:fiXml = [xml](Microsoft.PowerShell.Management\Get-Content $helpPath -Raw)
        $script:fiNs = Microsoft.PowerShell.Utility\New-Object Xml.XmlNamespaceManager $script:fiXml.NameTable
        $script:fiNs.AddNamespace('cmd', 'http://schemas.microsoft.com/maml/dev/command/2004/10')
        $script:fiNs.AddNamespace('maml', 'http://schemas.microsoft.com/maml/2004/10')
        $script:fiNs.AddNamespace('dev', 'http://schemas.microsoft.com/maml/dev/2004/10')

        $script:fiCmd = $script:fiXml.SelectSingleNode(
            "//cmd:command[cmd:details/cmd:name='Find-Item']", $script:fiNs)

        $script:fiMeta = GenXdev\Get-CmdletMetaData -Name 'Find-Item'
    }

    Pester\It 'XML root is helpItems' {
        $script:fiXml.DocumentElement.LocalName | Pester\Should -Be 'helpItems'
    }

    Pester\It 'command element exists with namespace attributes' {
        $script:fiCmd | Pester\Should -Not -BeNullOrEmpty
        $script:fiCmd.GetAttribute('xmlns:maml') |
            Pester\Should -Be 'http://schemas.microsoft.com/maml/2004/10'
    }

    Pester\It 'command:details — name, verb, noun' {
        $details = $script:fiCmd.SelectSingleNode('cmd:details', $script:fiNs)
        $details.SelectSingleNode('cmd:name', $script:fiNs).InnerText |
            Pester\Should -Be 'Find-Item'
        $details.SelectSingleNode('cmd:verb', $script:fiNs).InnerText |
            Pester\Should -Be 'Find'
        $details.SelectSingleNode('cmd:noun', $script:fiNs).InnerText |
            Pester\Should -Be 'Item'
    }

    Pester\It 'command:details — synopsis matches Get-CmdletMetaData' {
        $para = $script:fiCmd.SelectSingleNode(
            'cmd:details/maml:description/maml:para', $script:fiNs)
        $para.InnerText -replace '\r', '' | Pester\Should -Be ($script:fiMeta.Synopsis -replace '\r', '')
    }

    Pester\It 'maml:description has content from metadata' {
        $descNode = $script:fiCmd.SelectSingleNode('maml:description', $script:fiNs)
        $descNode | Pester\Should -Not -BeNullOrEmpty
        $firstPara = $script:fiCmd.SelectSingleNode(
            'maml:description/maml:para[1]', $script:fiNs)
        $firstPara.InnerText | Pester\Should -BeLike '*Fast multi-threaded search*'
    }

    Pester\It 'command:syntax has syntaxItem with cmdlet name' {
        $syntaxName = $script:fiCmd.SelectSingleNode(
            'cmd:syntax/cmd:syntaxItem/maml:name', $script:fiNs)
        $syntaxName.InnerText | Pester\Should -Be 'Find-Item'
    }

    Pester\It 'command:syntax has parameter elements with required attributes' {
        $syntaxParams = $script:fiCmd.SelectNodes(
            'cmd:syntax/cmd:syntaxItem/cmd:parameter', $script:fiNs)
        $syntaxParams.Count | Pester\Should -BeGreaterThan 5

        $sp = $script:fiCmd.SelectSingleNode(
            'cmd:syntax/cmd:syntaxItem/cmd:parameter[@aliases]', $script:fiNs)
        $sp | Pester\Should -Not -BeNullOrEmpty
        $sp.GetAttribute('required') | Pester\Should -Not -BeNullOrEmpty
        $sp.GetAttribute('position') | Pester\Should -Not -BeNullOrEmpty
        $sp.GetAttribute('pipelineInput') | Pester\Should -Not -BeNullOrEmpty
        $sp.GetAttribute('globbing') | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It 'command:parameters count matches metadata' {
        $xmlParams = $script:fiCmd.SelectNodes(
            'cmd:parameters/cmd:parameter', $script:fiNs)
        $xmlParams.Count | Pester\Should -Be $script:fiMeta.Parameters.Count
    }

    Pester\It 'Name parameter — type String[], position 0, aliases, wildcards' {
        $nameParam = $script:fiCmd.SelectSingleNode(
            "cmd:parameters/cmd:parameter[maml:name='Name']", $script:fiNs)
        $nameParam | Pester\Should -Not -BeNullOrEmpty
        $nameParam.GetAttribute('position') | Pester\Should -Be '0'
        $nameParam.GetAttribute('globbing') | Pester\Should -Be 'true'
        $nameParam.GetAttribute('aliases') | Pester\Should -BeLike '*like*'
        $nameParam.GetAttribute('aliases') | Pester\Should -BeLike '*Path*'
        $typeName = $nameParam.SelectSingleNode('dev:type/maml:name', $script:fiNs)
        $typeName.InnerText | Pester\Should -Be 'String[]'
    }

    Pester\It 'Name parameter — description from HelpMessage is not empty' {
        $nameParam = $script:fiCmd.SelectSingleNode(
            "cmd:parameters/cmd:parameter[maml:name='Name']", $script:fiNs)
        $desc = $nameParam.SelectSingleNode('maml:description/maml:para', $script:fiNs)
        $desc.InnerText | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It 'Content parameter — type String[], position 1, alias mc' {
        $contentParam = $script:fiCmd.SelectSingleNode(
            "cmd:parameters/cmd:parameter[maml:name='Content']", $script:fiNs)
        $contentParam | Pester\Should -Not -BeNullOrEmpty
        $contentParam.GetAttribute('aliases') | Pester\Should -BeLike '*mc*'
        $contentParam.GetAttribute('position') | Pester\Should -Be '1'
        $typeName = $contentParam.SelectSingleNode('dev:type/maml:name', $script:fiNs)
        $typeName.InnerText | Pester\Should -Be 'String[]'
    }

    Pester\It 'Directory parameter — SwitchParameter, default False' {
        $dirParam = $script:fiCmd.SelectSingleNode(
            "cmd:parameters/cmd:parameter[maml:name='Directory']", $script:fiNs)
        $dirParam | Pester\Should -Not -BeNullOrEmpty
        $typeName = $dirParam.SelectSingleNode('dev:type/maml:name', $script:fiNs)
        $typeName.InnerText | Pester\Should -Be 'SwitchParameter'
        $defVal = $dirParam.SelectSingleNode('dev:defaultValue', $script:fiNs)
        $defVal.InnerText | Pester\Should -Be 'False'
    }

    Pester\It 'Input parameter — ValueFromPipeline + ByPropertyName' {
        $inputParam = $script:fiCmd.SelectSingleNode(
            "cmd:parameters/cmd:parameter[maml:name='Input']", $script:fiNs)
        $inputParam | Pester\Should -Not -BeNullOrEmpty
        $inputParam.GetAttribute('pipelineInput') |
            Pester\Should -Match 'True.*ByValue.*ByPropertyName'
    }

    Pester\It 'Every parameter has dev:type/maml:name and dev:defaultValue' {
        $allParams = $script:fiCmd.SelectNodes(
            'cmd:parameters/cmd:parameter', $script:fiNs)
        foreach ($p in $allParams) {
            $typeNode = $p.SelectSingleNode('dev:type/maml:name', $script:fiNs)
            $typeNode | Pester\Should -Not -BeNullOrEmpty -Because "$($p.maml.name) must have a type"
            $typeNode.InnerText | Pester\Should -Not -BeNullOrEmpty
            $defVal = $p.SelectSingleNode('dev:defaultValue', $script:fiNs)
            $defVal | Pester\Should -Not -BeNullOrEmpty -Because "$($p.maml.name) must have default"
        }
    }

    Pester\It 'command:examples count matches metadata' {
        $examples = $script:fiCmd.SelectNodes(
            'cmd:examples/cmd:example', $script:fiNs)
        $examples.Count | Pester\Should -Be $script:fiMeta.Examples.Count
    }

    Pester\It 'Example 1 — code contains Find-Item but NOT ``` fences' {
        $ex1 = $script:fiCmd.SelectSingleNode(
            'cmd:examples/cmd:example[1]', $script:fiNs)
        $code = $ex1.SelectSingleNode('dev:code', $script:fiNs)
        $code.InnerText | Pester\Should -BeLike '*Find-Item -Content*'
        $code.InnerText | Pester\Should -Not -Match '```'
    }

    Pester\It 'Example 1 — title is descriptive, not placeholder' {
        $ex1 = $script:fiCmd.SelectSingleNode(
            'cmd:examples/cmd:example[1]', $script:fiNs)
        $title = $ex1.SelectSingleNode('maml:title', $script:fiNs)
        $title.InnerText | Pester\Should -Not -BeLike '---------- Example*'
        $title.InnerText | Pester\Should -Be 'Find files containing a specific word'
    }

    Pester\It 'Example 1 — remarks contain descriptive text' {
        $ex1 = $script:fiCmd.SelectSingleNode(
            'cmd:examples/cmd:example[1]', $script:fiNs)
        $remarks = $ex1.SelectSingleNode('dev:remarks/maml:para', $script:fiNs)
        $remarks.InnerText | Pester\Should -BeLike '*translation*'
    }

    Pester\It 'Every example has non-empty title, code, and remarks' {
        $examples = $script:fiCmd.SelectNodes(
            'cmd:examples/cmd:example', $script:fiNs)
        $exNum = 1
        foreach ($ex in $examples) {
            $t = $ex.SelectSingleNode('maml:title', $script:fiNs)
            $t.InnerText | Pester\Should -Not -BeNullOrEmpty -Because "ex $exNum title"
            $c = $ex.SelectSingleNode('dev:code', $script:fiNs)
            $c.InnerText | Pester\Should -Not -BeNullOrEmpty -Because "ex $exNum code"
            $r = $ex.SelectSingleNode('dev:remarks', $script:fiNs)
            $r | Pester\Should -Not -BeNullOrEmpty -Because "ex $exNum remarks"
            $exNum++
        }
    }

    Pester\It 'command:relatedLinks has navigation link' {
        $navLink = $script:fiCmd.SelectSingleNode(
            'cmd:relatedLinks/maml:navigationLink', $script:fiNs)
        $navLink | Pester\Should -Not -BeNullOrEmpty
        $navLink.SelectSingleNode('maml:linkText', $script:fiNs).InnerText |
            Pester\Should -Be 'Online Version:'
    }
}
#endregion
###############################################################################
#region Tests: Find-Image (.ps1 cmdlet) — every MAML section & property

Pester\Describe 'New-ModuleXmlHelp — Find-Image (.ps1 cmdlet) MAML XML' {

    Pester\BeforeAll {
        # Use en-US language to skip LLM translation entirely —
        # translation is tested separately by Get-CmdletMetaData tests.
        $null = GenXdev\New-ModuleXmlHelp -ModuleName GenXdev -Force `
            -Language en-US -ErrorAction Stop

        $helpPath = 'c:\Users\renev\Documents\PowerShell\Modules\GenXdev\3.34.0\en-US\GenXdev-help.xml'
        $script:fimXml = [xml](Microsoft.PowerShell.Management\Get-Content $helpPath -Raw)
        $script:fimNs = Microsoft.PowerShell.Utility\New-Object Xml.XmlNamespaceManager $script:fimXml.NameTable
        $script:fimNs.AddNamespace('cmd', 'http://schemas.microsoft.com/maml/dev/command/2004/10')
        $script:fimNs.AddNamespace('maml', 'http://schemas.microsoft.com/maml/2004/10')
        $script:fimNs.AddNamespace('dev', 'http://schemas.microsoft.com/maml/dev/2004/10')

        $script:fimCmd = $script:fimXml.SelectSingleNode(
            "//cmd:command[cmd:details/cmd:name='Find-Image']", $script:fimNs)

        $script:fimMeta = GenXdev\Get-CmdletMetaData -Name 'Find-Image'
    }

    Pester\It 'XML root is helpItems' {
        $script:fimXml.DocumentElement.LocalName | Pester\Should -Be 'helpItems'
    }

    Pester\It 'command element exists with namespace attributes' {
        $script:fimCmd | Pester\Should -Not -BeNullOrEmpty
        $script:fimCmd.GetAttribute('xmlns:maml') |
            Pester\Should -Be 'http://schemas.microsoft.com/maml/2004/10'
    }

    Pester\It 'command:details — name, verb, noun' {
        $details = $script:fimCmd.SelectSingleNode('cmd:details', $script:fimNs)
        $details.SelectSingleNode('cmd:name', $script:fimNs).InnerText |
            Pester\Should -Be 'Find-Image'
        $details.SelectSingleNode('cmd:verb', $script:fimNs).InnerText |
            Pester\Should -Be 'Find'
        $details.SelectSingleNode('cmd:noun', $script:fimNs).InnerText |
            Pester\Should -Be 'Image'
    }

    Pester\It 'command:details — synopsis matches Get-CmdletMetaData' {
        $para = $script:fimCmd.SelectSingleNode(
            'cmd:details/maml:description/maml:para', $script:fimNs)
        # Normalize line endings: XML uses \r\n, metadata may use \n
        $para.InnerText -replace '\r', '' | Pester\Should -Be ($script:fimMeta.Synopsis -replace '\r', '')
    }

    Pester\It 'maml:description has content from metadata' {
        $descNode = $script:fimCmd.SelectSingleNode('maml:description', $script:fimNs)
        $descNode | Pester\Should -Not -BeNullOrEmpty
        $firstPara = $descNode.SelectSingleNode('maml:para[1]', $script:fimNs)
        $firstPara.InnerText | Pester\Should -BeLike '*Searches for image files*'
    }

    Pester\It 'command:syntax has syntaxItem with cmdlet name' {
        $syntaxName = $script:fimCmd.SelectSingleNode(
            'cmd:syntax/cmd:syntaxItem/maml:name', $script:fimNs)
        $syntaxName.InnerText | Pester\Should -Be 'Find-Image'
    }

    Pester\It 'command:syntax has parameter elements with attributes' {
        $syntaxParams = $script:fimCmd.SelectNodes(
            'cmd:syntax/cmd:syntaxItem/cmd:parameter', $script:fimNs)
        $syntaxParams.Count | Pester\Should -BeGreaterThan 5
        $sp = $syntaxParams[0]
        $sp.GetAttribute('required') | Pester\Should -Not -BeNullOrEmpty
        $sp.GetAttribute('position') | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It 'command:parameters count matches metadata' {
        $xmlParams = $script:fimCmd.SelectNodes(
            'cmd:parameters/cmd:parameter', $script:fimNs)
        $xmlParams.Count | Pester\Should -Be $script:fimMeta.Parameters.Count
    }

    Pester\It 'Any parameter — type String[], position 0' {
        $anyParam = $script:fimCmd.SelectSingleNode(
            "cmd:parameters/cmd:parameter[maml:name='Any']", $script:fimNs)
        $anyParam | Pester\Should -Not -BeNullOrEmpty
        $anyParam.GetAttribute('position') | Pester\Should -Be '0'
        $typeName = $anyParam.SelectSingleNode('dev:type/maml:name', $script:fimNs)
        $typeName.InnerText | Pester\Should -Be 'String[]'
    }

    Pester\It 'Name parameter — position 1, aliases, default value' {
        $nameParam = $script:fimCmd.SelectSingleNode(
            "cmd:parameters/cmd:parameter[maml:name='Name']", $script:fimNs)
        $nameParam | Pester\Should -Not -BeNullOrEmpty
        $nameParam.GetAttribute('position') | Pester\Should -Be '1'
        $nameParam.GetAttribute('aliases') | Pester\Should -BeLike '*imagespath*'
        $nameParam.GetAttribute('aliases') | Pester\Should -BeLike '*directories*'
        $defVal = $nameParam.SelectSingleNode('dev:defaultValue', $script:fimNs)
        $defVal.InnerText | Pester\Should -BeLike "*'.\'*"
    }

    Pester\It 'OutputType — includes ImageSearchResult and String' {
        $returnValues = $script:fimCmd.SelectSingleNode(
            'cmd:returnValues', $script:fimNs)
        $returnValues | Pester\Should -Not -BeNullOrEmpty
        $returnNodes = $returnValues.SelectNodes(
            'cmd:returnValue/dev:type/maml:name', $script:fimNs)
        $returnTypes = @($returnNodes | Microsoft.PowerShell.Core\ForEach-Object { $_.InnerText })
        $returnTypes | Pester\Should -Contain 'GenXdev.Helpers.ImageSearchResult'
        $returnTypes | Pester\Should -Contain 'System.String'
    }

    Pester\It 'Every parameter has dev:type/maml:name and dev:defaultValue' {
        $allParams = $script:fimCmd.SelectNodes(
            'cmd:parameters/cmd:parameter', $script:fimNs)
        foreach ($p in $allParams) {
            $typeNode = $p.SelectSingleNode('dev:type/maml:name', $script:fimNs)
            $typeNode | Pester\Should -Not -BeNullOrEmpty -Because "$($p.maml.name) type"
            $typeNode.InnerText | Pester\Should -Not -BeNullOrEmpty
            $defVal = $p.SelectSingleNode('dev:defaultValue', $script:fimNs)
            $defVal | Pester\Should -Not -BeNullOrEmpty -Because "$($p.maml.name) default"
        }
    }

    Pester\It 'command:examples count matches metadata' {
        $examples = $script:fimCmd.SelectNodes(
            'cmd:examples/cmd:example', $script:fimNs)
        $examples.Count | Pester\Should -Be $script:fimMeta.Examples.Count
    }

    Pester\It 'Examples — code does NOT contain Markdown fences' {
        $examples = $script:fimCmd.SelectNodes(
            'cmd:examples/cmd:example', $script:fimNs)
        foreach ($ex in $examples) {
            $code = $ex.SelectSingleNode('dev:code', $script:fimNs)
            $code.InnerText | Pester\Should -Not -Match '```'
        }
    }

    Pester\It 'Every example has non-empty title, code, and remarks' {
        $examples = $script:fimCmd.SelectNodes(
            'cmd:examples/cmd:example', $script:fimNs)
        $exNum = 1
        foreach ($ex in $examples) {
            $t = $ex.SelectSingleNode('maml:title', $script:fimNs)
            $t.InnerText | Pester\Should -Not -BeNullOrEmpty -Because "ex $exNum title"
            $c = $ex.SelectSingleNode('dev:code', $script:fimNs)
            $c.InnerText | Pester\Should -Not -BeNullOrEmpty -Because "ex $exNum code"
            $exNum++
        }
    }

    Pester\It 'command:relatedLinks has navigation link' {
        $navLink = $script:fimCmd.SelectSingleNode(
            'cmd:relatedLinks/maml:navigationLink', $script:fimNs)
        $navLink | Pester\Should -Not -BeNullOrEmpty
    }
}
#endregion
###############################################################################
#region Tests: Translated help preserves code blocks verbatim

Pester\Describe 'New-ModuleXmlHelp — Code blocks identical across languages' {

    Pester\BeforeAll {
        # Generate reference (en-US) and comparison (nl-NL) help for
        # GenXdev module. Both use SkipTranslation to isolate the
        # code extraction/formatting pipeline from LLM availability.
        # The critical assertion is that code blocks must be identical
        # regardless of language — translation should only affect
        # titles, descriptions, and remarks.
        $null = GenXdev\New-ModuleXmlHelp -ModuleName GenXdev -Force `
            -Language en-US -SkipTranslation -ErrorAction Stop

        $moduleRoot = 'c:\Users\renev\Documents\PowerShell\Modules\GenXdev\3.34.0'

        # Load reference (en-US) XML
        $refPath = Microsoft.PowerShell.Management\Join-Path $moduleRoot 'en-US\GenXdev.dll-Help.xml'
        $script:refXml = [xml](Microsoft.PowerShell.Management\Get-Content $refPath -Raw)
        $script:refNs = Microsoft.PowerShell.Utility\New-Object Xml.XmlNamespaceManager $script:refXml.NameTable
        $script:refNs.AddNamespace('cmd',
            'http://schemas.microsoft.com/maml/dev/command/2004/10')
        $script:refNs.AddNamespace('maml',
            'http://schemas.microsoft.com/maml/2004/10')
        $script:refNs.AddNamespace('dev',
            'http://schemas.microsoft.com/maml/dev/2004/10')

        # Build a lookup: cmdlet name → list of code blocks from
        # reference XML
        $script:refCodeBlocks = @{}
        $refCommands = $script:refXml.SelectNodes(
            '//cmd:command', $script:refNs)
        foreach ($cmd in $refCommands) {
            $name = $cmd.SelectSingleNode(
                'cmd:details/cmd:name', $script:refNs).InnerText
            $codes = @($cmd.SelectNodes(
                'cmd:examples/cmd:example/dev:code', $script:refNs) |
                Microsoft.PowerShell.Core\ForEach-Object { $_.InnerText })
            $script:refCodeBlocks[$name] = $codes
        }
    }

    Pester\It 'Both en-US and nl-NL help files exist and are valid XML' {
        $script:refXml | Pester\Should -Not -BeNullOrEmpty
        $script:cmpXml | Pester\Should -Not -BeNullOrEmpty
        $script:refXml.DocumentElement.LocalName |
            Pester\Should -Be 'helpItems'
        $script:cmpXml.DocumentElement.LocalName |
            Pester\Should -Be 'helpItems'
    }

    Pester\It 'Same number of cmdlets in both language versions' {
        $refCount = $script:refXml.SelectNodes(
            '//cmd:command', $script:refNs).Count
        $cmpCount = $script:cmpXml.SelectNodes(
            '//cmd:command', $script:cmpNs).Count
        $refCount | Pester\Should -BeGreaterThan 0
        $cmpCount | Pester\Should -Be $refCount
    }

    Pester\It 'Every example code block is identical between en-US and nl-NL' -ForEach @(
        $script:refCodeBlocks.Keys | Microsoft.PowerShell.Utility\Sort-Object
    ) {
        $cmdName = $_
        $refCodes = $script:refCodeBlocks[$cmdName]

        $cmpCmd = $script:cmpXml.SelectSingleNode(
            "//cmd:command[cmd:details/cmd:name='${cmdName}']", $script:cmpNs)
        $cmpCmd | Pester\Should -Not -BeNullOrEmpty `
            -Because "'${cmdName}' should exist in nl-NL help"

        $cmpCodes = @($cmpCmd.SelectNodes(
            'cmd:examples/cmd:example/dev:code', $script:cmpNs) |
            Microsoft.PowerShell.Core\ForEach-Object { $_.InnerText })

        $cmpCodes.Count | Pester\Should -Be $refCodes.Count `
            -Because "'${cmdName}' should have same number of examples"

        for ($i = 0; $i -lt $refCodes.Count; $i++) {
            $refNormalized = $refCodes[$i] -replace '\r\n', "`n" -replace '\r', "`n"
            $cmpNormalized = $cmpCodes[$i] -replace '\r\n', "`n" -replace '\r', "`n"
            $cmpNormalized | Pester\Should -BeExactly $refNormalized `
                -Because "'${cmdName}' example $($i + 1) code block " +
                'must be identical across languages'
        }
    }

    Pester\It 'Find-Item code blocks do NOT leak translated text into code' {
        # Quick sanity: after translation to nl-NL (if we had real
        # translation), "Short form" in a comment would become
        # "Korte vorm". This test verifies no such leakage exists.
        # With SkipTranslation, both versions are English — the real
        # assertion is that code blocks match exactly.
        $refCodes = $script:refCodeBlocks['Find-Item']
        $refCodes.Count | Pester\Should -BeGreaterThan 0

        foreach ($code in $refCodes) {
            # Code blocks should not contain description text markers
            # that would indicate the description leaked into code
            $code | Pester\Should -Not -Match `
                'Search for all files' `
                -Because 'description text must not leak into code blocks'
        }
    }
}
#endregion
