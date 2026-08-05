###############################################################################
<#
.SYNOPSIS
Evaluates a statement using AI to determine if it's true or false.

.DESCRIPTION
This function uses AI models to evaluate statements and determine their truth
value. It can accept input directly through parameters, from the pipeline, or
from the system clipboard. The function returns a boolean result along with
confidence level and reasoning from the AI model.

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

.PARAMETER Text
The statement to evaluate. If not provided, the function will read from the
system clipboard.

.PARAMETER Instructions
Instructions to guide the AI model in evaluating the statement. By default, it
will determine if the statement is true or false.

.PARAMETER Attachments
Array of file paths to attach to the AI query for additional context.

.PARAMETER SetClipboard
When specified, copies the result back to the system clipboard after processing.

.PARAMETER Temperature
Temperature for response randomness (0.0-1.0). Controls creativity vs
determinism in AI responses.

.PARAMETER ImageDetail
Image detail level for visual processing. Valid values are low, medium, or high.

.PARAMETER IncludeThoughts
Include model's thoughts in output for debugging and transparency.

.PARAMETER DontAddThoughtsToHistory
Prevent model thoughts from being added to conversation history.

.PARAMETER ContinueLast
Continue from last conversation instead of starting fresh.

.PARAMETER Functions
Array of function definitions for AI tool use capabilities.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions to use as tools in AI operations.

.PARAMETER NoConfirmationToolFunctionNames
Array of command names that don't require confirmation before execution.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought responses.

.PARAMETER NoSessionCaching
Don't store session in session cache for privacy or debugging.

.PARAMETER AllowDefaultTools
Allow the AI to use default tools and capabilities.

.PARAMETER LLMQueryType
The type of LLM query to optimize for specific use cases.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER PromptForSettings
When specified, launches an interactive prompt to configure the LLM settings

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
Invoke-LLMBooleanEvaluation -Text "The Earth is flat" -Model "gpt-4"

.EXAMPLE
"Humans need oxygen to survive" | Invoke-LLMBooleanEvaluation

.EXAMPLE
equalstrue "2 + 2 = 4"
###############################################################################>
function Invoke-LLMBooleanEvaluation {

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    [Alias('equalstrue')]
    param (
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = 'The statement to evaluate'
        )]
        [string] $Text,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('Instructions for the AI model on how to evaluate ' +
                'the statement')
        )]
        [string] $Instructions = '',
        ###############################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'Array of file paths to attach'
        )]
        [string[]] $Attachments = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Image detail level'
        )]
        [ValidateSet('low', 'medium', 'high')]
        [string] $ImageDetail = 'low',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of function definitions'
        )]
        [hashtable[]] $Functions = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Array of PowerShell command definitions to use ' +
                'as tools')
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]] $ExposedCmdLets = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Array of command names that don't require " +
                'confirmation')
        )]
        [Alias('NoConfirmationFor')]
        [string[]] $NoConfirmationToolFunctionNames = @(),
        ###############################################################################
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
        [string] $LLMQueryType = 'Knowledge',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The model identifier or pattern to use for AI ' +
                'operations')
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI operations'
        )]
        [string] $ApiKey,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Launch interactive prompt to configure LLM settings')
        )]
        [switch] $PromptForSettings,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Indicates that LLM has no support for JSON schemas'
        )]
        [switch] $NoSupportForJsonSchema,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Copy the result to clipboard'
        )]
        [switch] $SetClipboard,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $IncludeThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't add model thoughts to conversation history"
        )]
        [switch] $DontAddThoughtsToHistory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Continue from last conversation'
        )]
        [switch] $ContinueLast,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI responses'
        )]
        [switch] $Speak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI thought responses'
        )]
        [switch] $SpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow AI to use default tools and capabilities'
        )]
        [switch] $AllowDefaultTools,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'AI preferences')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session ' +
                'for AI preferences')
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences ' +
                'without affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only markup blocks in the output'
        )]
        [switch] $OutputMarkdownBlocksOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter for specific types of markup blocks'
        )]
        [string[]] $MarkupBlocksTypeFilter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for audio response randomness'
        )]
        [double] $AudioTemperature,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response generation'
        )]
        [double] $TemperatureResponse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Language code or name for the response'
        )]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of CPU threads to use for processing'
        )]
        [int] $CpuThreads,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regular expression to suppress from output'
        )]
        [string] $SuppressRegex,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio context size for processing'
        )]
        [int] $AudioContextSize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Silence threshold for audio detection'
        )]
        [double] $SilenceThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty for sequence generation'
        )]
        [double] $LengthPenalty,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold for output filtering'
        )]
        [double] $EntropyThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold for output filtering'
        )]
        [double] $LogProbThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold for audio detection'
        )]
        [double] $NoSpeechThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output'
        )]
        [switch] $DontSpeak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output for thoughts'
        )]
        [switch] $DontSpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable VOX (voice activation)'
        )]
        [switch] $NoVOX,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use desktop audio capture for input'
        )]
        [switch] $UseDesktopAudioCapture,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not use context in the query'
        )]
        [switch] $NoContext,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use beam search sampling strategy'
        )]
        [switch] $WithBeamSearchSamplingStrategy,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only responses from the model'
        )]
        [switch] $OnlyResponses,
        ###############################################################################
        [int] $MaxToolcallBackLength
        ###############################################################################
    )

    begin {

        # prepend evaluation instructions to user instructions
        $Instructions = @"
Evaluate if the following statement is true or false.
Respond with a JSON object containing 'result' (boolean), 'confidence' (0.0 - 1.0) and 'reason' (string).
The returned 'reason' should explain as short as possible, why the statement was evaluated as true or false.
Only pure facts should have high confidence.
$Instructions
"@

        # define response format schema for boolean evaluation
        $responseSchema = @{
            type        = 'json_schema'
            json_schema = @{
                name   = 'boolean_evaluation_response'
                strict = 'true'
                schema = @{
                    type       = 'object'
                    properties = @{
                        result     = @{
                            type        = 'boolean'
                            description = ('The evaluation result: true if ' +
                                "the statement is true, false if it's false")
                        }
                        confidence = @{
                            type        = 'number'
                            minimum     = 0
                            maximum     = 1
                            description = ('Confidence level in the ' +
                                'evaluation (0-1)')
                        }
                        reason     = @{
                            type        = 'string'
                            description = ('Explanation for why the statement ' +
                                'was evaluated as true or false')
                        }
                    }
                    required   = @('result', 'confidence', 'reason')
                }
            }
        } |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

        # log initialization information
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Starting boolean evaluation with model: $Model"
        )

        # initialize result variables
        $script:result = $false
        $response = $null
    }


    process {

        # check if we should read from clipboard
        $isClipboardSource = [string]::IsNullOrWhiteSpace($Text)

        if ($isClipboardSource) {

            # log clipboard reading operation
            Microsoft.PowerShell.Utility\Write-Verbose (
                'No direct text input, reading from clipboard'
            )

            # get text from system clipboard
            $Text = Microsoft.PowerShell.Management\Get-Clipboard

            if ([string]::IsNullOrWhiteSpace($Text)) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'No text found in the clipboard.'
                )
                return
            }
        }

        try {

            # log processing start
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Processing statement for evaluation'
            )

            # copy parameters from current function to invoke-llmquery
            $invocationParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Invoke-LLMQuery'

            # configure query parameters for boolean evaluation
            $invocationParams.Query = $Text
            $invocationParams.Instructions = $Instructions
            $invocationParams.IncludeThoughts = $false
            $invocationParams.ResponseFormat = $responseSchema
            $invocationParams.Temperature = $Temperature

            if ($AllowDefaultTools) {

                # enable text prompt mode for tool usage
                $invocationParams.ChatMode = 'textprompt'
                $invocationParams.ChatOnce = $true
            }

            # get evaluation result from ai model
            $response = GenXdev\Invoke-LLMQuery @invocationParams |
                Microsoft.PowerShell.Utility\ConvertFrom-Json

            # extract boolean result from response
            $script:result = [bool]$response.result

            # create summary for verbose output
            $summary = ("`r`n`"$Text`"`r`n`r`nevaluates to be: " +
                "$($response.result)`r`nconfidence: $($response.confidence) " +
                "confidence.`r`nReason: $($response.reason)`r`n")

            # log evaluation summary
            Microsoft.PowerShell.Utility\Write-Verbose $summary
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to evaluate statement with AI model: $_"
            )
        }
    }

    end {

        if ($null -ne $response) {

            if ($SetClipboard) {

                # log clipboard operation
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Copying result to clipboard'
                )

                if ($IncludeThoughts) {

                    # create detailed summary with thoughts
                    $summary = ("`r`n`"$Text`"`r`n`r`nevaluates to be: " +
                        "$($response.result)`r`nconfidence: " +
                        "$($response.confidence) confidence.`r`nReason: " +
                        "$($response.reason)`r`n")

                    # copy summary to clipboard instead of piping
                    $null = Microsoft.PowerShell.Management\Set-Clipboard `
                        -Value $summary
                }
                else {

                    # copy boolean result to clipboard
                    $null = Microsoft.PowerShell.Management\Set-Clipboard `
                        -Value $script:result
                }
            }
        }

        # return the boolean result
        $script:result
    }
}
###############################################################################