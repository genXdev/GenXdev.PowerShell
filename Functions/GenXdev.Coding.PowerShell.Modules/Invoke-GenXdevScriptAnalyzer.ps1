# Don't remove this line [dontrefactor]
###############################################################################
<#
.SYNOPSIS
Invokes PowerShell Script Analyzer to analyze PowerShell scripts for compliance
and best practices.

.DESCRIPTION
This function provides a wrapper around PSScriptAnalyzer to analyze PowerShell
scripts for compliance issues, best practices violations, and potential bugs.
It supports both file-based analysis and string-based script analysis with
customizable rules and settings.

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

.PARAMETER ScriptFilePath
Specifies the path to the script file to analyze. This parameter is mandatory
when using the Path parameter set.

.PARAMETER ScriptDefinition
Specifies the script definition as a string to analyze. This parameter is
mandatory when using the Script parameter set.

.PARAMETER EnableExit
Specifies that the tool should exit on error during analysis.

.PARAMETER Fix
Enables automatic fixing of violations where possible.

.PARAMETER Recurse
Recursively processes files in subdirectories when analyzing a directory path.

.PARAMETER ReportSummary
Reports a summary after analysis showing the total number of issues found.

.EXAMPLE
Invoke-GenXdevScriptAnalyzer -Path "C:\Scripts\MyScript.ps1"

.EXAMPLE
Invoke-GenXdevScriptAnalyzer -ScriptDefinition "Get-Process | Where-Object {$_.Name -eq 'notepad'}"

.EXAMPLE
Invoke-GenXdevScriptAnalyzer -Path "C:\Scripts\" -Recurse -Fix
#>
function Invoke-GenXdevScriptAnalyzer {

    [CmdletBinding(DefaultParameterSetName = 'Path')]
    param (
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'Path',
            HelpMessage = 'Specifies the path to the script file.'
        )]
        [Alias('Path', 'FullName')]
        [string] $ScriptFilePath,
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            ParameterSetName = 'Script',
            HelpMessage = 'Specifies the script definition as a string.'
        )]
        [string] $ScriptDefinition,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specifies that the tool should exit on error.'
        )]
        [switch] $EnableExit,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enables automatic fixing of violations.'
        )]
        [switch] $Fix,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Recursively process files.'
        )]
        [switch] $Recurse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Reports a summary after analysis.'
        )]
        [switch] $ReportSummary
        #
    )

    begin {

        # check if psscriptanalyzer module is loaded
        $loaded = Microsoft.PowerShell.Core\Get-Module -Name PSScriptAnalyzer -ErrorAction SilentlyContinue

        if (-not $loaded) {

            # define the folder path for psscriptanalyzer installation
            $folder = GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\PSScriptAnalyzer\1.24.0\"

            if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $folder)) {

                # install psscriptanalyzer module if folder does not exist
                $null = PowerShellGet\Install-Module -Name PSScriptAnalyzer -RequiredVersion 1.24.0 -Scope CurrentUser -Force
            }

            # import the psscriptanalyzer module
            $null = Microsoft.PowerShell.Core\Import-Module PSScriptAnalyzer
        }

        # load script analyzer settings from configuration file
        $settingsPath = "$($MyInvocation.MyCommand.Module.ModuleBase)\PSScriptAnalyzerSettings.psd1"

        $settings = Microsoft.PowerShell.Utility\Invoke-Expression `
        ([System.IO.File]::ReadAllText($settingsPath))

        # output verbose information about loaded settings
        Microsoft.PowerShell.Utility\Write-Verbose `
            "Loaded PSScriptAnalyzer settings from: $settingsPath"
    }

    process {

        try {

            # initialize invocation parameters variable
            $invocationParams = $null

            # check which parameter set is being used
            if ($PSCmdlet.ParameterSetName -eq 'Path') {

                # configure parameters for path-based analysis
                $invocationParams = @{
                    Path                  = $ScriptFilePath
                    IncludeRule           = $settings.IncludeRules
                    ExcludeRule           = $settings.ExcludeRules
                    CustomRulePath        = $settings.CustomRulePath
                    IncludeDefaultRules   = $settings.IncludeDefaultRules
                    RecurseCustomRulePath = $settings.RecurseCustomRulePath
                    Recurse               = [bool]$Recurse
                    Fix                   = [bool]$Fix
                    EnableExit            = [bool]$EnableExit
                    ReportSummary         = [bool]$ReportSummary
                    Severity              = 'Warning'
                }

                # output verbose information about path analysis
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Analyzing script file: $ScriptFilePath"
            }
            else {

                # configure parameters for script definition analysis
                $invocationParams = @{
                    ScriptDefinition      = $ScriptDefinition
                    IncludeRule           = $settings.IncludeRules
                    ExcludeRule           = $settings.ExcludeRules
                    CustomRulePath        = $settings.CustomRulePath
                    IncludeDefaultRules   = $settings.IncludeDefaultRules
                    RecurseCustomRulePath = $settings.RecurseCustomRulePath
                    Recurse               = [bool]$Recurse
                    Fix                   = [bool]$Fix
                    EnableExit            = [bool]$EnableExit
                    ReportSummary         = [bool]$ReportSummary
                    Severity              = 'Warning'
                }

                # output verbose information about script definition analysis
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Analyzing script definition content'
            }

            # set retry count for handling transient errors
            [int] $retries = 3;

            while ($retries-- -gt 0) {

                try {

                    # invoke script analyzer with configured parameters
                    $results = @(PSScriptAnalyzer\Invoke-ScriptAnalyzer @invocationParams -Verbose:$false)

                    # output verbose information about analysis results
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Analysis completed with $($results.Count) results"

                    break;
                }
                catch {

                    # output warning for script analyzer errors
                    Microsoft.PowerShell.Utility\Write-Warning `
                        "ScriptAnalyzer error: $($_.Exception.Message)"

                    if ($retries -eq 1) {

                        return
                    }

                    Microsoft.PowerShell.Utility\Start-Sleep 1
                }
            }

            # check if results were returned
            if ($results -and ($results.Length -gt 0)) {

                # process each result to enhance with additional information
                $results |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        # convert result to hashtable for easier manipulation
                        $resultHashTable = $_ |
                            GenXdev\ConvertTo-HashTable

                            # get the rule details safely
                            $ruleDetails = PSScriptAnalyzer\Get-ScriptAnalyzerRule `
                                -Name $resultHashTable.RuleName

                            # add rule description with null check
                            $resultHashTable['Description'] = `
                                if ($ruleDetails -and $ruleDetails.Description) {

                                $ruleDetails.Description
                            }
                            else {

                                'No description available'
                            }

                            # output the enhanced result
                            Microsoft.PowerShell.Utility\Write-Output $resultHashTable
                        }
            }
        }
        catch {

            # create error output for general exceptions
            $errorResult = @{
                Message     = $_.Exception.Message
                RuleName    = ($null -eq $ScriptFilePath ? '?' : `
                        [System.IO.Path]::GetFileNameWithoutExtension($ScriptFilePath)) + `
                    ' @ Invocation in Invoke-GenXdevScriptAnalyzer'
                Description = 'An error occurred while invoking the Script Analyzer.'
            }

            # output the error result
            Microsoft.PowerShell.Utility\Write-Output $errorResult
        }
    }

    end {
    }
}
#################################################################################