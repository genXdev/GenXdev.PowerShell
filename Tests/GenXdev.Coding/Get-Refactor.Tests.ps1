###############################################################################
Pester\Describe 'Get-Refactor' {

    Pester\It 'should pass PSScriptAnalyzer rules' {

        # get the script path for analysis
        $scriptPath = GenXdev\Expand-Path "$PSScriptRoot\..\..\Functions\GenXdev.Coding\Get-Refactor.ps1"

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
"@
    }

    Pester\It 'should return default refactors after EnsureDefaultGenXdevRefactors' {

        # Ensure default refactors are created (without -Force to test normal operation)
        $null = GenXdev\EnsureDefaultGenXdevRefactors

        # Get all refactors
        $allRefactors = GenXdev\Get-Refactor

        # Expected default refactor names
        $expectedRefactorNames = @(
            'Documentation',
            'DocumentationCSharp',
            'MissingDocumentation',
            'MissingDocumentationCSharp',
            'ConvertToCSharp',
            'AddInstallationConsentPrompt'
        )

        # Verify that all expected refactors exist
        foreach ($expectedName in $expectedRefactorNames) {
            $refactorExists = $allRefactors | Microsoft.PowerShell.Core\Where-Object { $_.Name -eq $expectedName }
            $refactorExists | Pester\Should -Not -BeNullOrEmpty -Because "Default refactor '$expectedName' should exist after EnsureDefaultGenXdevRefactors"
        }

        # Verify that refactors are sorted by Priority descending
        $priorities = $allRefactors | Microsoft.PowerShell.Core\ForEach-Object { $_.Priority }
        $sortedPriorities = $priorities | Microsoft.PowerShell.Utility\Sort-Object -Descending
        $priorities | Pester\Should -Be $sortedPriorities -Because "Refactors should be sorted by Priority in descending order"
    }

    Pester\It 'should filter refactors by name pattern' {

        # Ensure default refactors exist
        $null = GenXdev\EnsureDefaultGenXdevRefactors

        # Test wildcard pattern
        $docRefactors = "Documentation*" | GenXdev\Get-Refactor
        $docRefactors.Count | Pester\Should -BeGreaterThan 0 -Because "Should find refactors matching 'Documentation*' pattern"

        # Verify all returned refactors match the pattern
        foreach ($refactor in $docRefactors) {
            $refactor.Name | Pester\Should -BeLike "Documentation*" -Because "All returned refactors should match the name pattern"
        }

        # Test exact match
        $specificRefactor = "ConvertToCSharp" | GenXdev\Get-Refactor
        $specificRefactor | Pester\Should -Not -BeNullOrEmpty -Because "Should find exact refactor name match"
        $specificRefactor.Name | Pester\Should -Be "ConvertToCSharp" -Because "Should return the exact refactor requested"
    }

    Pester\It 'should return refactor objects with correct properties' {

        # Ensure default refactors exist
        $null = GenXdev\EnsureDefaultGenXdevRefactors

        # Get a specific refactor
        $refactor = GenXdev\Get-Refactor -Name "ConvertToCSharp" | Microsoft.PowerShell.Utility\Select-Object -First 1

        # Verify the refactor has expected properties
        $refactor | Pester\Should -Not -BeNullOrEmpty -Because "Should return a refactor object"
        $refactor.Name | Pester\Should -Not -BeNullOrEmpty -Because "Refactor should have a Name property"
        $refactor.Priority | Pester\Should -Not -BeNullOrEmpty -Because "Refactor should have a Priority property"
        $refactor.State | Pester\Should -Not -BeNullOrEmpty -Because "Refactor should have a State property"
        $refactor.SelectionSettings | Pester\Should -Not -BeNullOrEmpty -Because "Refactor should have SelectionSettings property"
    }
}
###############################################################################