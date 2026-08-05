###############################################################################
<#
.SYNOPSIS
Generates and executes PowerShell commands using AI assistance.

.DESCRIPTION
Uses AI models to generate PowerShell commands based on
natural language queries. The function can either send commands directly to
the PowerShell window or copy them to the clipboard. It leverages AI models
to interpret natural language and convert it into executable PowerShell
commands with comprehensive parameter support for various AI backends.

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

.PARAMETER Query
The natural language description of what you want to accomplish. The AI will
convert this into an appropriate PowerShell command.

.PARAMETER Instructions
Additional instructions for the AI model to customize command generation
behavior and provide context-specific guidance.

.PARAMETER Temperature
Controls the randomness in the AI's response generation. Values range from
0.0 (more focused/deterministic) to 1.0 (more creative/random).

.PARAMETER LLMQueryType
The type of LLM query to perform. Determines the AI model's behavior and
response style for different use cases.

.PARAMETER Model
The model identifier or pattern to use for AI operations. Can be a name or
partial path with support for pattern matching.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations when using external AI services.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER PromptForSettings
When specified, launches an interactive prompt to configure the LLM settings with external services.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations to prevent hanging requests.

.PARAMETER PreferencesDatabasePath
Database path for preference data files to store AI configuration settings.

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys to the PowerShell
window.

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on target window when sending keys to the PowerShell
window.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys to the PowerShell window.

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending keys to
the PowerShell window.

.PARAMETER Clipboard
When specified, copies the generated command to clipboard instead of
executing it directly.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences instead of
persistent configuration.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences and reset
to defaults.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session
state.

.EXAMPLE
Invoke-AIPowershellCommand -Query "list all running processes"

Generates a PowerShell command to list running processes

.EXAMPLE
hint "list files modified today"

Uses the alias to generate a command for finding files modified today.

.EXAMPLE
Invoke-AIPowershellCommand -Query "stop service" -Clipboard

Generates a command to stop a service and copies it to clipboard.
#>
function Invoke-AIPowershellCommand {

    [CmdletBinding()]
    [OutputType([void])]
    [Alias('hint')]
    param (
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The natural language query to generate a command for'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PowershellCmdline,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The type of LLM query'
        )]
        [ValidateSet(
            'SimpleIntelligence',
            'Knowledge',
            'Pictures',
            'TextTranslation',
            'Coding',
            'ToolUse'
        )]
        [string] $LLMQueryType = 'Coding',
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The model identifier or pattern to use for AI ' +
                'operations')
        )]
        [string] $Model,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI operations'
        )]
        [string] $ApiKey,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Launch interactive prompt to configure LLM settings')
        )]
        [switch] $PromptForSettings,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Indicates that LLM has no support for JSON schemas'
        )]
        [switch] $NoSupportForJsonSchema
    )

    begin {

        # read compact cmdlet index for AI candidate scanning (~2KB vs 2MB)
        $indexPath = "$($MyInvocation.MyCommand.Module.ModuleBase)\recommended-aitoolset-cmdlets.txt"
        $cmdletIndex = if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $indexPath) {
            Microsoft.PowerShell.Management\Get-Content -LiteralPath $indexPath -Raw -Encoding UTF8
        }
        else {
            ''
        }

        Microsoft.PowerShell.Utility\Write-Verbose ('Initializing AI command ' +
            'generation with tool-call workflow')

        # expose Get-Help as a tool function — LLM calls this to verify syntax
        $ExposedCmdLets = @(
            @{
                Name          = 'Microsoft.PowerShell.Core\Get-Help'
                Description   = ('Retrieves full help for a PowerShell cmdlet ' +
                    'including syntax, parameter names, types, and examples.')
                AllowedParams = @('Name=string')
                ForcedParams  = @(
                    @{ Name = 'Full'; Value = $true }
                )
                OutputText    = $true
                Confirm       = $false
            }
        )

        # Get-Help should never require user confirmation
        $NoConfirmationToolFunctionNames = @('Get-Help')

        # build instruction template
        $Instructions = @"

⛔ CRITICAL PROTOCOL — FOLLOW THESE STEPS IN ORDER ⛔

You are generating a PowerShell command to help the user. Follow these steps
exactly — do NOT skip ahead.

---

STEP 1 — IS IT A TYPO?

Only apply this step if the user's message LOOKS LIKE a PowerShell command
(contains a Verb-Noun pattern like "Get-Something" or has "-Parameter"
switches). If the user typed natural language like "find duplicate files",
skip to Step 2.

If it IS a command with an obvious typo or minor syntax error, fix ONLY the
typo and output the corrected command immediately. Do NOT search for
alternative cmdlets.

Examples:
- User types "Get-ChildIem" → fix to "Get-ChildItem"
- User types "Get-ChildItem -Recurse -Dept 3" → fix "-Dept" to "-Depth"
- User types "find duplicate files in this folder" → SKIP TO STEP 2

---

STEP 2 — SCAN FOR MATCHING CMDLETS:

Below is a list of available GenXdev cmdlets with their descriptions. Scan it
and identify 1-3 cmdlets that could solve the user's task.

$cmdletIndex

If a GenXdev cmdlet clearly fits, proceed to Step 3. If nothing matches,
proceed to Step 4.

---

STEP 3 — VERIFY PARAMETERS VIA Get-Help:

CALL the Get-Help tool on your chosen candidate(s). This is MANDATORY. You
do NOT know what parameters exist until you see the syntax block.

Rules:
- Every parameter name MUST appear in the Get-Help syntax block.
- For enum parameters showing {Value1 | Value2 | ...}, use EXACTLY one of
  those values. No approximations.
- If a parameter is NOT in the syntax block, it DOES NOT EXIST.
- Example: Open-MediaFile has -NoRecurse, NOT -Recurse. Do not assume.

After Get-Help returns, build the working command and output it.

---

STEP 4 — FALLBACK: GENERAL KNOWLEDGE:

No GenXdev cmdlet fits. Use your general PowerShell knowledge to suggest
the best standard PowerShell command for the task.

"@
        $ResponseFormat = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'text_transformation_response'
                strict = $true
                schema = @{
                    type       = 'object'
                    properties = @{
                        explanation      = @{
                            type        = 'string'
                            description = 'explanation what cmdline accomplises or what is improved to fix the error'
                        };
                        suggestedCmdline = @{
                            type        = 'string'
                            description = 'The transformed text output'
                        }
                    }
                    required   = @('explanation', 'suggestedCmdline')
                }
            }
        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        # copy matching parameters to invoke transformation function
        $invocationParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Invoke-LLMQuery' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local)

    }

    process {

        if (($PowershellCmdline.Trim() -eq "") -or (($PowershellCmdline.Trim() -eq "^U"))) {
            return;
        }

        # log the query being processed for debugging purposes
        Microsoft.PowerShell.Utility\Write-Verbose ('Generating PowerShell ' +
            "command for query: $PowershellCmdline")

        # invoke LLM with Get-Help exposed as a tool for parameter verification
        # suppress tool chain output — Get-Help noise is distracting here
        $command = GenXdev\Invoke-LLMQuery @invocationParams `
            -Query $PowershellCmdline `
            -Instructions $Instructions `
            -ResponseFormat $ResponseFormat `
            -ExposedCmdLets $ExposedCmdLets `
            -NoConfirmationToolFunctionNames $NoConfirmationToolFunctionNames `
            -Temperature 0.1 `
            -QuietToolChainInvocations

        # Invoke-LLMQuery already extracts clean JSON from the response
        # via IndexOf/LastIndexOf. Parse and validate the required fields.
        try {
            $result = $command |
                Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction Stop

            if ((-not $result) -or
                [string]::IsNullOrWhiteSpace($result.suggestedCmdline) -or
                [string]::IsNullOrWhiteSpace($result.explanation)) {

                throw "AI response missing required fields"
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "'$PowershellCmdline' could not be resolved using AI"
            return
        }

        # Extract actual string values from potentially nested
        # response objects. When the LLM doesn't support native JSON
        # schema, the example format may produce nested {response:
        # "..."} objects instead of flat strings.
        $explanation = if ($result.explanation.PSObject.Properties['response']) {
            $result.explanation.response
        }
        else {
            $result.explanation
        }
        $suggestedCmd = if ($result.suggestedCmdline.PSObject.Properties['response']) {
            $result.suggestedCmdline.response
        }
        else {
            $result.suggestedCmdline
        }

        if ([string]::IsNullOrWhiteSpace($suggestedCmd)) {
            Microsoft.PowerShell.Utility\Write-Warning 'AI did not return a valid command to execute.'
            return
        }

        $yellow = "`e[33m"
        $cyan = "`e[36m"
        $reset = "`e[0m"

        # show explanation and command to the user
        $userChoice = $host.ui.PromptForChoice(
            'Are you sure you want to perform this action?',
            @"
--
$yellow$suggestedCmd$reset
--
$cyan$explanation$reset
--
"@, @('&No', '&Yes'), 1);

        if ($userChoice -eq 0) {

            return
        }

        Microsoft.PowerShell.Utility\Invoke-Expression $suggestedCmd
    }

    end {
    }
    ###############################################################################
}