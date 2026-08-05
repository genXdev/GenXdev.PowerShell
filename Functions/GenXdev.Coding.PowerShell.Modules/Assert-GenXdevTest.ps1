<#
.SYNOPSIS
Executesunit tests for GenXdev modules, sub-modules, or cmdlets
with intelligent debugging and AI-powered error resolution.

.DESCRIPTION
This function provides a testing framework for GenXdev modules,
offering multi-level test execution from entire modules down to individual
cmdlets. It integrates PSScriptAnalyzer for static code analysis, Pester for
unit testing, and PSScriptAnalyzer for static code analysis. The
function includes intelligent error handling with AI-powered resolution

capabilities and detailed progress reporting for development workflows.

.LICENSE
Copyright (C) 2026 René Vaessen / GenXdev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>.

.PARAMETER CmdletName
Search pattern to filter cmdlets for testing. Supports wildcards and allows
targeting specific cmdlets or groups of cmdlets matching the pattern.

.PARAMETER DefinitionMatches
Regular expression to match cmdlet definitions during the search process.
This allows for advanced filtering based on cmdlet implementation patterns.

.PARAMETER ModuleName
GenXdev module names to search and test. Must follow the pattern starting
with 'GenXdev' followed by optional sub-module components. Supports wildcards
for broad module selection.

.PARAMETER NoLocal
Skip searching in local module paths during cmdlet discovery. When specified,
only published module paths will be considered for testing.

.PARAMETER OnlyPublished
Limit search to published module paths only. This excludes local development
modules and focuses on officially published GenXdev modules.

.PARAMETER FromScripts
Search in script files instead of module files. This allows testing of
standalone PowerShell scripts within the GenXdev ecosystem.

.PARAMETER IncludeScripts
Include the scripts directory in addition to regular modules. This expands
the test scope to cover both modular and script-based functionality.

.PARAMETER OnlyReturnModuleNames
Return only unique module names instead of full cmdlet details. Useful for
discovery and inventory operations rather than detailed testing.

.PARAMETER ExactMatch
Require exact matches for cmdlet names rather than wildcard matching. This
provides precise targeting for specific cmdlet testing scenarios.

.PARAMETER Verbosity
Output detail level for test execution. Controls the amount of information
displayed during test runs, from minimal to diagnostic output.

.PARAMETER StackTraceVerbosity
Stack trace detail level for error reporting. Determines how much call stack
information is included when errors occur during testing.

.PARAMETER TestFailedAction
Action to take when a test fails. Options include interactive prompting,
automatic continuation, stopping execution, AI-powered resolution, error
logging, or exception throwing for integration scenarios.

.PARAMETER AllowLongRunningTests
Include unit tests that have long running durations in the test execution.
This enables testing including performance and integration tests.

.PARAMETER SkipModuleImports
Skip importing GenXdev modules before testing. This is useful when modules
are already loaded or when testing specific module loading scenarios.

.PARAMETER SkipPSAnalyzerTests
Skip invoking PSScriptAnalyzer tests during the test execution. This allows
focusing solely on functional testing when static analysis is not required.

.PARAMETER SkipPesterTests
Skip invoking Pester tests during the test execution. This allows focusing
solely on static analysis when functional testing is not required.

.EXAMPLE
Assert-GenXdevTest -ModuleName "GenXdev.AI"
Executes all tests for the GenXdev.AI module including PSScriptAnalyzer and
Pester tests.

.EXAMPLE
Assert-GenXdevTest -SubModuleName "GenXdev.Coding.PowerShell.Modules" `
    -TestFailedAction SolveWithAI
Tests the specified sub-module and uses AI to automatically resolve any
failures encountered during testing.

.EXAMPLE
Assert-GenXdevTest -CmdletName "Get-GenXDevCmdlet" -Verbosity Detailed
Tests the specific cmdlet with detailed output showing all test operations
and results.

.EXAMPLE
testcmdlet Assert-GenXdevTest
Uses the alias to test the current cmdlet with default settings.
#>
function Assert-GenXdevTest {

    [CmdletBinding(DefaultParameterSetName = "ModuleName")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSAvoidGlobalVars", "Global:AllowLongRunningTests")]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute("PSUseDeclaredVarsMoreThanAssignments", "")]
    [Alias("rungenxdevtests")]

    param (
        ###############################################################################
        [parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Search pattern to filter cmdlets'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Filter', 'CmdLet', 'Cmd', 'FunctionName', 'Name')]
        [SupportsWildcards()]
        [string] $CmdletName,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('Action to take when a test fails. Options: Ask, ' +
                'Continue, Stop, SolveWithAI, Write-Error, Throw')
        )]
        [ValidateSet('Ask', 'Continue', 'Stop', 'SolveWithAI', 'Write-Error', 'Throw')]
        [string] $TestFailedAction = 'Continue',
        ###############################################################################
        [parameter(
            Position = 2,
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Regular expression to match cmdlet definitions'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $DefinitionMatches,
        ###############################################################################
        [parameter(
            Position = 3,
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'GenXdev module names to search'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Module', 'BaseModuleName', 'SubModuleName')]
        [ValidatePattern('^(GenXdev|GenXde[v]\*|GenXdev(\.[\w\*\[\]\?]*)+)+$')]
        [SupportsWildcards()]
        [string[]] $ModuleName,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip searching in local module paths'
        )]
        [switch] $NoLocal,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only search in published module paths'
        )]
        [switch] $OnlyPublished,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Search in script files instead of modules'
        )]
        [switch] $FromScripts,
        ###############################################################################
        [Parameter(
            ParameterSetName = "ModuleName",
            Mandatory = $false,
            HelpMessage = ('Includes the scripts directory in addition to ' +
                'regular modules')
        )]
        [switch] $IncludeScripts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only return unique module names'
        )]
        [switch] $OnlyReturnModuleNames,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Require exact matches for cmdlet names'
        )]
        [switch] $ExactMatch,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Output detail level'
        )]
        [ValidateSet('None', 'Normal', 'Detailed', 'Diagnostic')]
        [string] $Verbosity = 'Detailed',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Stack trace detail level'
        )]
        [ValidateSet('None', 'FirstLine', 'Filtered', 'Full')]
        [string] $StackTraceVerbosity = 'FirstLine',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Also selects unit-tests that have long running durations'
        )]
        [switch] $AllowLongRunningTests,
        ###############################################################################
        [Parameter(
            ParameterSetName = "ModuleName",
            Mandatory = $false,
            HelpMessage = 'Skips importing GenXdev modules before testing'
        )]
        [switch] $SkipModuleImports,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skips invoking PSAnalyzer tests'
        )]
        [switch] $SkipPSAnalyzerTests,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skips invoking Pester tests'
        )]
        [switch] $SkipPesterTests,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to this installation type and set persistent flag..')
        )]
        [switch]$AutoConsent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installations. Useful for unattended or CI/CD scenarios.')
        )]
        [switch]$AutoConsentAllPackages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
    )

    begin {

        $ProgressPreference = $PSCmdlet.GetVariableValue('ProgressPreference')

        # store allow long running tests setting in global scope for test access
        $Global:AllowLongRunningTests = $AllowLongRunningTests -eq $true

        # ensure pester module is available for test execution
        $ensureParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\EnsurePester'
        GenXdev\EnsurePester @ensureParams

        # import GenXdev modules if testing modules and imports not skipped
        if ($ModuleName -and (-not $SkipModuleImports)) {

            # ensure all GenXdev modules are loaded for testing
            GenXdev\Import-GenXdevModules | Microsoft.PowerShell.Core\Out-Host
        }

        # output initialization message for test framework startup
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Initializing GenXdev test execution framework')

        # calculate root path for script location discovery
        $rootPath = GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\..\"

        # define script path for script-based testing scenarios
        $scriptPath = "$rootPath\Scripts"

        # store current location to restore after test completion
        $originalLocation = Microsoft.PowerShell.Management\Get-Location

        # initialize pester configuration with optimized settings for testing
        $config = Pester\New-PesterConfiguration

        # configure detailed verbosity when using non-continue failure actions
        if ((-not $PSBoundParameters.ContainsKey("Verbosity") -and
                ($TestFailedAction -ne "Continue"))) {

            $config.Output.Verbosity = 'Detailed'
        }

        # apply user-specified or default verbosity setting
        $config.Output.Verbosity = $Verbosity

        # configure full stack trace verbosity when not explicitly set
        if (-not $PSBoundParameters.ContainsKey("StackTraceVerbosity")) {

            $config.Output.StackTraceVerbosity = 'Full'
        }

        # apply user-specified or enhanced stack trace verbosity
        $config.Output.StackTraceVerbosity = $StackTraceVerbosity

        # enable pass-through results for programmatic access to test outcomes
        $config.Run.PassThru = $true

        # use ANSI rendering for enhanced console output formatting
        $config.Output.RenderMode = 'Ansi'

        # disable test result file generation for performance optimization
        $config.TestResult.Enabled = $false

        # output configuration confirmation for debugging purposes
        Microsoft.PowerShell.Utility\Write-Verbose (
            ("Test configuration initialized with verbosity: " +
            "$($config.Output.Verbosity)"))
    }

    process {

        # copy identical parameter values for cmdlet discovery function call
        $params = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-GenXdevCmdlet' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue
        )

        # discover cmdlets matching the specified criteria
        $cmdlets = GenXdev\Get-GenXdevCmdlet @params

        # verify we have cmdlets to test before proceeding
        if ($cmdlets.Count -eq 0) {

            # output warning when no test targets are found
            Microsoft.PowerShell.Utility\Write-Warning (
                'No test files found for the specified criteria')

            return
        }

        # output discovery results for debugging and progress tracking
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Found $($cmdlets.Count) scripts to test with ScriptAnalyzer")

        # initialize collection for script analyzer test results
        [System.Collections.Generic.List[object]] $scriptAnalyzerResults = @()

        # execute PSScriptAnalyzer tests unless explicitly skipped
        if (-not $SkipPSAnalyzerTests) {

            try {
                # iterate through each discovered cmdlet for analysis
                foreach ($nextCmdlet in $cmdlets) {

                    # skip internal cmdlets that start with underscore

                    if ($nextCmdlet.Name -like "_*") { continue }
                    if ($nextCmdlet.ScriptFilePath.EndsWith(".cs")) { continue }

                    Microsoft.PowerShell.Utility\Write-Progress `
                        -Activity "Analyzing $($nextCmdlet.Name)" `
                        -CurrentOperation "Processing $($nextCmdlet.Name)" `
                        -Status "'$([IO.Path]::GetFileName($nextCmdlet.ScriptFilePath))'"

                    # initialize loop control variables for retry logic
                    $stop = $false
                    $tfa = $TestFailedAction

                    # retry loop for handling test failures and AI resolution
                    while (-not $stop) {

                        try {
                            # extract script file path and function name for testing
                            $scriptFile = [string]$nextCmdlet.ScriptFilePath
                            $fn = $nextCmdlet.Name

                            if ([string]::IsNullOrWhiteSpace($scriptFile) -or (-not (Microsoft.PowerShell.Management\Test-Path -ErrorAction SilentlyContinue $scriptFile))) {

                                # output warning when script file path is empty
                                Microsoft.PowerShell.Utility\Write-Warning (
                                    "No script file found for cmdlet: $($nextCmdlet.Name)"
                                )
                                $stop = $true; continue;
                            }

                            # invoke script analyzer on the current script file
                            $analyzerResults = @(GenXdev\Invoke-GenXdevScriptAnalyzer `
                                    -Path $scriptFile)

                            # process script analyzer results if issues were found
                            if ($analyzerResults.Count -gt 0) {

                                # add analyzer results to the collection for reporting
                                $null = $scriptAnalyzerResults.Add(
                                    @{
                                        Path    = $scriptFile
                                        Results = $analyzerResults
                                    }
                                )

                                # format analyzer results for error reporting
                                $msg = ("Script analysis error during script analyzer " +
                                    "tests:`r`n" +
                                    "$($scriptAnalyzerResults[$scriptAnalyzerResults.Count-1].Results |
                                        Microsoft.PowerShell.Utility\Select-Object -Property RuleName, Line, Message -Unique |
                                        Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 5)"
                                )

                                # handle interactive failure action prompting
                                if ($tfa -eq 'Ask') {

                                    $tfatmp = $host.ui.PromptForChoice(
                                        'Make a choice',
                                        ("PSScriptAnalyzer detected " +
                                        "$($analyzerResults.Count) issues in: $scriptFile "),
                                        @('&Continue', '&Stop', 'Solve with &AI',
                                            '&Write-Error', '&Throw'),
                                        0
                                    )

                                    # convert choice index to action string
                                    $tfa = switch ($tfatmp) {
                                        0 { 'Continue' }
                                        1 { 'Stop' }
                                        2 { 'SolveWithAI' }
                                        3 { 'Write-Error' }
                                        4 { 'Throw' }
                                    }
                                }

                                $doContinue = $false;

                                # execute the selected failure action
                                switch ($tfa) {

                                    'Continue' {
                                        # log warning and exit retry loop
                                        Microsoft.PowerShell.Utility\Write-Warning (
                                            ("PSScriptAnalyzer detected " +
                                            "$($analyzerResults.Count) issues in: " +
                                            "$scriptFile ")
                                        )
                                        $stop = $true
                                        $doContinue = $true
                                    }

                                    'Stop' {
                                        # terminate test execution immediately
                                        return
                                    }

                                    'SolveWithAI' {
                                        # reset action to ask for next iteration
                                        $tfa = 'Ask'

                                        # invoke AI-powered refactoring to resolve issues
                                        GenXdev\Assert-RefactorFile `
                                            -RefactorSettings (
                                            [GenXdev.Helpers.RefactorSettings] @{
                                                Code      = $true
                                                PromptKey = "FailedScriptAnalyzerResults"
                                                Prompt    = $msg
                                            }
                                        ) `
                                            -Path $scriptFile

                                        $doContinue = $true
                                    }

                                    'Write-Error' {
                                        # log error with issue count
                                        Microsoft.PowerShell.Utility\Write-Error (
                                            ("PSScriptAnalyzer detected errors in: " +
                                            "$scriptFile " +
                                            "$($analyzerResults.Count) issues found")
                                        )
                                    }

                                    'Throw' {
                                        # create and throw detailed exception
                                        $exception = [System.InvalidOperationException]::new(
                                            ("PSScriptAnalyzer detected errors in: " +
                                            "$scriptFile " +
                                            "$($analyzerResults.Count) issues found")
                                        )
                                        $exception.Data.Add('ScriptPath', $_)
                                        $exception.Data.Add('IssueCount', $analyzerResults.Count)
                                        $exception.Data.Add('AnalyzerResults', $analyzerResults)
                                        throw $exception
                                    }
                                }

                                if ($doContinue) {

                                    continue;
                                }
                            }

                            # exit retry loop when no issues are found
                            $stop = $true
                            break
                        }
                        catch [System.InvalidOperationException] {

                            $exc = $_

                            # handle PSScriptAnalyzer exceptions that we specifically threw
                            if ($exc.Exception.Data.ContainsKey('AnalyzerResults')) {

                                # output structured error result for known analyzer exceptions
                                Microsoft.PowerShell.Utility\Write-Output @{
                                    Success               = $false
                                    ErrorMessage          = ("Unexpected error during script " +
                                        "analysis: " + @"
$($exc.Exception) $($exc.InvocationInfo.PositionMessage)
$($exc.InvocationInfo.Line)
$($exc.InvocationInfo.ScriptStackTrace)
"@)
                                    ScriptAnalyzerResults = $scriptAnalyzerResults
                                }

                                # re-throw our PSScriptAnalyzer exception
                                throw
                            }
                            else {
                                # output structured error result for other exceptions
                                Microsoft.PowerShell.Utility\Write-Output @{
                                    Success               = $false
                                    ErrorMessage          = ("Unexpected error during script " +
                                        "analysis: " + @"
$($exc.Exception) $($exc.InvocationInfo.PositionMessage)
$($exc.InvocationInfo.Line)
$($exc.InvocationInfo.ScriptStackTrace)
"@)
                                    ScriptAnalyzerResults = $scriptAnalyzerResults
                                }

                                # handle the exception based on test failed action
                                switch ($TestFailedAction) {

                                    'Continue' {
                                        # log warning with full exception details
                                        Microsoft.PowerShell.Utility\Write-Warning (
                                            "Script analysis error: " + @"
$($exc.Exception) $($exc.InvocationInfo.PositionMessage)
$($exc.InvocationInfo.Line)
$($exc.InvocationInfo.ScriptStackTrace)
"@)
                                    }

                                    'Stop' {
                                        # terminate test execution immediately
                                        return
                                    }

                                    'SolveWithAI' {
                                        # perform AI-powered refactoring on current file
                                        GenXdev\Assert-RefactorFile `
                                            -RefactorSettings (
                                            [GenXdev.Helpers.RefactorSettings] @{
                                                Code      = $true
                                                PromptKey = "FailedScriptAnalyzerResults"
                                                Prompt    = ("Script analysis error: " + @"
$($exc.Exception) $($PSItem.InvocationInfo.PositionMessage)
$($exc.InvocationInfo.Line)
$($exc.InvocationInfo.ScriptStackTrace)
"@)
                                            }
                                        ) `
                                            -Path $scriptFile

                                        # pause for user interaction and reload modules
                                        Microsoft.PowerShell.Utility\Read-Host -Prompt "Press Enter to continue"
                                        GenXdev\Import-GenXdevModules | Microsoft.PowerShell.Core\Out-Host
                                        GenXdev\Assert-GenXdevTest @PSBoundParameters
                                        return
                                    }

                                    'Write-Error' {
                                        # log error with exception message
                                        Microsoft.PowerShell.Utility\Write-Error (
                                            "Script analysis error: $($exc.Exception.Message)")
                                    }

                                    'Throw' {
                                        # re-throw the exception
                                        throw $exc
                                    }
                                }
                            }
                        }
                        catch {

                            $exc = $_

                            # output structured error result for unexpected exceptions
                            Microsoft.PowerShell.Utility\Write-Output @{
                                Success               = $false
                                ErrorMessage          = ("Unexpected error during script analysis: " +
                                    "$($exc.Exception.Message)")
                                ScriptAnalyzerResults = $scriptAnalyzerResults
                            }

                            # handle unexpected exceptions based on test failed action
                            switch ($TestFailedAction) {

                                'Continue' {
                                    # log warning with exception message
                                    Microsoft.PowerShell.Utility\Write-Warning (
                                        "Script analysis error: $($exc.Exception.Message)")
                                }

                                'Stop' {
                                    # terminate test execution immediately
                                    return
                                }

                                'SolveWithAI' {
                                    # perform AI-powered refactoring on current file
                                    GenXdev\Assert-RefactorFile `
                                        -RefactorSettings (
                                        [GenXdev.Helpers.RefactorSettings] @{
                                            Code      = $true
                                            PromptKey = "FailedScriptAnalyzerResults"
                                            Prompt    = ("Script analysis error during " +
                                                "script analyzer tests: " + @"
$($exc.Exception) $($exc.InvocationInfo.PositionMessage)
$($exc.InvocationInfo.Line)
$($exc.InvocationInfo.ScriptStackTrace)
"@)
                                        }
                                    ) `
                                        -Path $scriptFile

                                    # pause for user interaction and reload modules
                                    Microsoft.PowerShell.Utility\Read-Host -Prompt "Press Enter to continue"
                                    GenXdev\Import-GenXdevModules | Microsoft.PowerShell.Core\Out-Host
                                    GenXdev\Assert-GenXdevTest @PSBoundParameters
                                    return
                                }

                                'Write-Error' {
                                    # log error with full exception details
                                    Microsoft.PowerShell.Utility\Write-Error (
                                        ("Script analysis error during script " +
                                        "analyzer tests: " + @"
$($exc.Exception) $($exc.InvocationInfo.PositionMessage)
$($exc.InvocationInfo.Line)
$($exc.InvocationInfo.ScriptStackTrace)
"@)
                                    )
                                }

                                'Throw' {
                                    # re-throw the exception
                                    throw $exc
                                }
                            }
                        }
                    }
                }
            }
            finally {

                # process script analyzer results if issues were found
                if ($scriptAnalyzerResults.Count -gt 0) {


                    # handle stopping action for script analyzer failures
                    switch ($TestFailedAction) {

                        'Stop' {
                            # output final failure result with analyzer issues
                            Microsoft.PowerShell.Utility\Write-Output @{
                                Success               = $false
                                ErrorMessage          = ("$($scriptAnalyzerResults.Count) " +
                                    "script analyzer issues found")
                                ScriptAnalyzerResults = $scriptAnalyzerResults
                            }
                        }
                    }
                }
            }
        }

        # return early if Pester tests are skipped
        if ($SkipPesterTests) {

            # return result indicating PSScriptAnalyzer success and no Pester tests
            return @{
                Success         = ($scriptAnalyzerResults.Count -eq 0)
                TestResults     = $null
                AnalyzerResults = $scriptAnalyzerResults
            }
        }

        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "Analyzing $($nextCmdlet.Name)" `
            -Completed `
            -Status "Completed"

        # discover test containers for cmdlets with associated test files
        $testContainers = @($cmdlets |
                Microsoft.PowerShell.Core\Where-Object {
                    (-not [string]::IsNullOrWhiteSpace($_.ScriptTestFilePath)) -and
                    (Microsoft.PowerShell.Management\Test-Path `
                        -LiteralPath $_.ScriptTestFilePath)
                } |
                Microsoft.PowerShell.Core\ForEach-Object {
                    # create pester container for each valid test file
                    Pester\New-PesterContainer -Path $_.ScriptTestFilePath
                }
        )

        # verify we have test containers before proceeding with Pester execution
        if ($testContainers.Count -eq 0) {

            # output warning when no Pester test files are found
            Microsoft.PowerShell.Utility\Write-Warning (
                'No Pester test files found for the specified criteria')

            return
        }

        # output discovery results for debugging and progress tracking
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Found $($testContainers.Count) scripts to test with Pester")

        # configure pester to run our discovered test containers
        $config.Run.Container = $testContainers

        # execute the tests using pester with configured settings
        Microsoft.PowerShell.Utility\Write-Verbose 'Executing Pester tests'

        # run pester tests and capture results for processing
        $testResults = Pester\Invoke-Pester -Configuration $config

        # handle failed tests with debugging and AI resolution if requested
        if ($testResults.FailedCount -gt 0) {

            # initialize test failed action for interactive handling
            $tfa = $TestFailedAction

            # handle interactive failure action prompting for Pester failures
            if ($tfa -eq 'Ask') {

                $tfatmp = $host.ui.PromptForChoice(
                    'Make a choice',
                    ("Pester detected $($testResults.FailedCount) failed tests. " +
                    "What to do next?"),
                    @('&Continue', '&Stop', 'Solve with &AI', '&Write-Error', '&Throw'),
                    0
                )

                # convert choice index to action string
                $tfa = switch ($tfatmp) {
                    0 { 'Continue' }
                    1 { 'Stop' }
                    2 { 'SolveWithAI' }
                    3 { 'Write-Error' }
                    4 { 'Throw' }
                }
            }

            # execute the selected failure action for Pester test failures
            switch ($tfa) {

                'Throw' {
                    # output structured failure result for throwing exceptions
                    Microsoft.PowerShell.Utility\Write-Output @{
                        Success         = $false
                        ErrorMessage    = "$($testResults.FailedCount) test(s) failed"
                        TestResults     = $testResults
                        AnalyzerResults = $scriptAnalyzerResults
                    }

                    # create detailed exception with test failure information
                    $exception = [System.InvalidOperationException]::new(
                        ("Found issues in ${scriptFile}: " +
                        "$($analyzerResults.Count) issues found")
                    )
                    $exception.Data.Add('ScriptPath', $_)
                    $exception.Data.Add('IssueCount',
                        ($scriptAnalyzerResults.Count + $testResults.FailedCount))
                    $exception.Data.Add('AnalyzerResults', $scriptAnalyzerResults)
                    $exception.Data.Add('TestResults', $testResults)

                    throw $exception
                }

                'SolveWithAI' {
                    # reset action to ask for subsequent iterations
                    $tfa = "Ask"

                    # output progress information for AI-powered debugging
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        ("Processing $($testResults.FailedCount) failed test(s) " +
                        "for debugging")
                    )

                    # initialize collection for new test results after fixing
                    [System.Collections.Generic.List[object]] $newResults = @()

                    # iterate through each failed test for AI-powered resolution
                    foreach ($failedTest in $testResults.Failed) {

                        # extract cmdlet name from failed test path for debugging
                        $failedCmdletName = [System.IO.Path]::GetFileNameWithoutExtension(
                            $failedTest.ScriptBlock.File).Replace('.Tests', '')

                        # output warning for current failed test
                        Microsoft.PowerShell.Utility\Write-Warning (
                            "Test failed: $($failedTest.Name) in $failedCmdletName")

                        # determine if test is from scripts directory
                        $isFromScripts = (GenXdev\Expand-Path $failedTest.ScriptBlock.File).StartsWith("$scriptPath\")

                        # construct script file path based on test location
                        $testFilePath = $failedTest.ScriptBlock.File
                        $moduleName = [IO.Path]::GetFileName(
                            ([IO.Path]::GetDirectoryName(  # modules\modulename\
                                ([IO.Path]::GetDirectoryName(  # modules\modulename\version\
                                    ([IO.Path]::GetDirectoryName(  # modules\modulename\version\tests\
                                        ([IO.Path]::GetDirectoryName(  # modules\modulename\version\tests\submodule
                                            $testFilePath
                                        ))
                                    ))
                                ))
                            ))
                        );
                        # Ensure moduleName is a string
                        if ($moduleName -is [array]) {
                            $moduleName = $moduleName | Microsoft.PowerShell.Utility\Select-Object -First 1
                        }
                        Microsoft.PowerShell.Utility\Write-Verbose "failedTest.ScriptBlock.File: $($testFilePath)"
                        Microsoft.PowerShell.Utility\Write-Verbose "MODULE NAME: $moduleName"
                        $fullCmdletName = ([string]::IsNullOrWhiteSpace($moduleName) ? "" : "$moduleName\") + (
                            [IO.Path]::GetFileNameWithoutExtension($testFilePath).Replace('.Tests', '')
                        );
                        Microsoft.PowerShell.Utility\Write-Verbose "fullCmdletName: $fullCmdletName"
                        $scriptFilePath = [string](GenXdev\Get-GenXDevCmdlet $fullCmdletName).ScriptFilePath
                        if ([string]::IsNullOrWhiteSpace($scriptFilePath)) {
                            $scriptFilePath = $failedTest.ScriptBlock.File
                            Microsoft.PowerShell.Utility\Write-Warning (
                                "Cmdlet script not found for '$fullCmdletName', using test file: $scriptFilePath")
                        }
                        Microsoft.PowerShell.Utility\Write-Verbose "scriptFilePath: $scriptFilePath"

                        # open failed test in VS Code with Copilot integration
                        $failedTest.ScriptBlock.File | GenXdev\VsCode -Copilot

                        # initialize loop control for AI resolution attempts
                        $stopped = $false
                        $ft = $failedTest

                        # retry loop for AI-powered test failure resolution
                        while (-not $stopped) {

                            # invoke AI-powered refactoring to resolve test failure
                            GenXdev\Assert-RefactorFile `
                                -RefactorSettings (
                                [GenXdev.Helpers.RefactorSettings] @{
                                    Code      = $true
                                    PromptKey = "ResolveFailedTest"
                                    Prompt    = @"
Pester test failed for cmdlet: $fullCmdletName
Test Name: $($ft.Name)
Test File: $scriptFilePath
Error: $($ft.ErrorRecord.Exception.Message)

Failed Test Details:
$([PSCustomObject]@{Name=$ft.Name;Result=$ft.Result;Duration=$ft.Duration;StackTrace=$ft.ErrorRecord.Exception.StackTrace;ErrorRecord=$ft.ErrorRecord.ToString()} | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 5)

Please analyze this test failure and suggest code fixes to make the test pass.
"@
                                }
                            ) `
                                -Path $scriptFilePath

                            # prompt user for next action after AI resolution attempt
                            switch ($host.ui.PromptForChoice(
                                    'Make a choice',
                                    'What to do next?',
                                    @('&Stop', '&Test again', '&Continue'),
                                    1)
                            ) {
                                0 {
                                    # stop entire test execution
                                    return
                                }

                                1 {
                                    # re-run tests for the specific cmdlet
                                    $results = GenXdev\Assert-GenXdevTest `
                                        @PSBoundParameters `
                                        -CmdletName $failedCmdletName `
                                        -FromScripts:$isFromScripts `
                                        -TestFailedAction 'Stop' `
                                        -SkipModuleImports

                                    # check if tests now pass after AI resolution
                                    if ($results.FailedCount -eq 0) {

                                        # add successful results to new results collection
                                        $results.TestResults |
                                            Microsoft.PowerShell.Core\ForEach-Object {
                                                $null = $newResults.Add($_)
                                            }

                                        # exit retry loop for this test
                                        $stopped = $true
                                        break
                                    }
                                    else {
                                        # update failed test for next retry iteration
                                        $ft = $results.Failed[0]
                                    }
                                }

                                2 {
                                    # continue with the next failed test
                                    $stopped = $true
                                    break
                                }
                            }
                        }

                        # update test results if this test was successfully fixed
                        if ($newResults.Failed.Count -eq 0) {

                            # remove the fixed test from failed collection
                            $testResults.Failed = $testResults.Failed |
                                Microsoft.PowerShell.Core\Where-Object {
                                    $_ -ne $failedTest
                                }

                            # add new passing results to passed collection
                            $testResults.Passed += $newResults.Passed
                        }
                    }
                }
            }

            # output final test results with success indicators
            Microsoft.PowerShell.Utility\Write-Output @{
                Success         = (($testResults.Failed.Count + $scriptAnalyzerResults.Count) -eq 0)
                ErrorMessage    = ("$($testResults.FailedCount) test(s) failed, " +
                    "$($testResults.FailedCount - $testResults.Failed.Count) fixed")
                TestResults     = $testResults
                AnalyzerResults = $scriptAnalyzerResults
            }

            return
        }

        # output successful test results when no failures occurred
        Microsoft.PowerShell.Utility\Write-Output @{
            Success         = ($scriptAnalyzerResults.Count -eq 0)
            TestResults     = $testResults
            AnalyzerResults = $scriptAnalyzerResults
        }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Progress `
            -Activity "Analyzing $($nextCmdlet.Name)" `
            -Completed `
            -Status "Completed"

        # restore original location after test execution completion
        Microsoft.PowerShell.Management\Set-Location -LiteralPath $originalLocation
    }
}
################################################################################