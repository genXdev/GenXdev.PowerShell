###############################################################################
<#
.SYNOPSIS
Evaluates source files for refactoring eligibility using LLM analysis.

.DESCRIPTION
Uses Language Learning Model (LLM) analysis to determine if a source code file
should be selected for refactoring based on specified criteria. The function
processes the file content through an LLM query and returns a boolean response.

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

.PARAMETER RefactorDefinition
A RefactorDefinition object containing the LLM configuration and selection
criteria settings used to evaluate the source file.

.PARAMETER Path
The full filesystem path to the source code file that needs to be evaluated
for potential refactoring.

.EXAMPLE
Test-RefactorLLMSelection -RefactorDefinition $refDef -Path "C:\source.ps1"

.EXAMPLE
$def | Test-RefactorLLMSelection -Path source.ps1
#>
function Test-RefactorLLMSelection {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The refactor definition containing LLM settings'
        )]
        [ValidateNotNull()]
        [GenXdev.Helpers.RefactorDefinition] $RefactorDefinition,
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = 'The path to the source file to evaluate'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [string] $Path
        ########################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose "Starting refactor selection analysis for: $Path"

        # extract the selection criteria prompt from the refactor settings
        $prompt = $RefactorDefinition.SelectionSettings.LLM.Prompt
    }


    process {

        # validate that the target file exists before processing
        if (-not [System.IO.File]::Exists($Path)) {
            throw "The file '$Path' does not exist"
        }

        # ensure we have valid selection criteria
        if ([string]::IsNullOrWhiteSpace($prompt)) {
            throw 'The prompt is empty'
        }

        # prepare the llm query parameters by matching available parameters
        $invocationParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters ($RefactorDefinition.SelectionSettings.LLM | GenXdev\ConvertTo-HashTable) `
            -FunctionName 'GenXdev\Invoke-LLMBooleanEvaluation' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -Name * `
                -ErrorAction SilentlyContinue)

        # construct the complete instruction set for the llm query
        $invocationParams.Instructions = @"
You are a helpfull assistant, the user wants your help to find a true or false answer.
The answer is wheter to select the source code file provided for refactoring.
The user will provide the criteria for the selection.
Your job is to judge the source code file based on the criteria
and return the answer as a boolean value.

The source code file's content will now follow:

$([System.IO.File]::ReadAllText($Path))
"@

        # configure the remaining required llm query parameters
        $invocationParams.Text = $prompt

        Microsoft.PowerShell.Utility\Write-Verbose 'Invoking LLM analysis with selection criteria'

        # execute the llm query and convert response to boolean
        return (GenXdev\Invoke-LLMBooleanEvaluation @invocationParams -ErrorAction SilentlyContinue -TTLSeconds 120 -LLMQueryType Coding)
    }

    end {
    }
}