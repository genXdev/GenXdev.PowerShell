###############################################################################
<#
.SYNOPSIS
Starts an interactive text chat session with AI capabilities.

.DESCRIPTION
Initiates an interactive chat session with AI capabilities, allowing users to add
or remove PowerShell functions during the conversation and execute PowerShell
commands. This function provides a comprehensive interface for AI-powered
conversations with extensive tool integration and customization options.

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
Initial text to send to the model.

.PARAMETER Instructions
System instructions to provide context to the AI model.

.PARAMETER Attachments
Array of file paths to attach to the conversation.

.PARAMETER Temperature
Controls randomness in responses (0.0-1.0). Lower values are more deterministic.

.PARAMETER ImageDetail
Level of detail for image generation (low, medium, high).

.PARAMETER ResponseFormat
A JSON schema for the requested output format.

.PARAMETER LLMQueryType
The type of LLM query.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER PromptForSettings
When specified, launches an interactive prompt to configure the LLM settings.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions to use as tools.

.PARAMETER MarkupBlocksTypeFilter
Will only output markup blocks of the specified types.

.PARAMETER IncludeThoughts
Include model's thoughts in output.

.PARAMETER DontAddThoughtsToHistory
Include model's thoughts in output.

.PARAMETER ContinueLast
Continue from last conversation.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought responses.

.PARAMETER OutputMarkdownBlocksOnly
Will only output markup block responses.

.PARAMETER ChatOnce
Used internally, to only invoke chat mode once after the llm invocation.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
New-LLMTextChat -Model "qwen2.5-14b-instruct" -Temperature 0.7 `
    -Instructions "You are a helpful AI assistant"

.EXAMPLE
llmchat "Tell me a joke" -Speak -IncludeThoughts
#>
###############################################################################
# store exposed cmdlets at module level instead of global scope
$script:LLMExposedCmdlets = $null

###############################################################################
function New-LLMTextChat {

    [CmdletBinding(SupportsShouldProcess = $true, DefaultParameterSetName = 'Default')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('llmchat')]

    param(
        #######################################################################
        [Parameter(
            ParameterSetName = 'Default',
            ValueFromPipeline = $true,
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'Query text to send to the model'
        )]
        [AllowEmptyString()]
        [string] $Query = '',
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'System instructions for the model'
        )]
        [string] $Instructions,
        #######################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'Array of file paths to attach'
        )]
        [string[]] $Attachments = @(),
        #######################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Image detail level'
        )]
        [ValidateSet('low', 'medium', 'high')]
        [string] $ImageDetail = 'low',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'A JSON schema for the requested output format'
        )]
        [string] $ResponseFormat = $null,
        #######################################################################
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
        [string] $LLMQueryType = 'ToolUse',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        #######################################################################
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
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Shows tool chain invocations in console')
        )]
        [switch] $ShowToolChainInvocations,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of PowerShell command definitions to use as tools'
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will only output markup blocks of the specified types'
        )]
        [ValidateNotNull()]
        [string[]] $MarkupBlocksTypeFilter = @('json', 'powershell', 'C#', 'python', 'javascript', 'typescript', 'html', 'css', 'yaml', 'xml', 'bash'),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $IncludeThoughts,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $DontAddThoughtsToHistory,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Continue from last conversation'
        )]
        [switch] $ContinueLast,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI responses'
        )]
        [switch] $Speak,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI thought responses'
        )]
        [switch] $SpeakThoughts,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will only output markup block responses'
        )]
        [switch] $OutputMarkdownBlocksOnly,
        #######################################################################
        [Parameter(
            DontShow = $true,
            Mandatory = $false,
            HelpMessage = 'Used internally, to only invoke chat mode once after the llm invocation'
        )]
        [switch] $ChatOnce,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###################################################################
        [Alias('NoConfirmationFor')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Names of tool functions that should not require confirmation')]
        [string[]] $NoConfirmationToolFunctionNames,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum length for tool callback responses')]
        [int] $MaxToolcallBackLength,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for audio generation'
        )]
        $AudioTemperature,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response generation'
        )]
        $TemperatureResponse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Language for the model or output'
        )]
        $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of CPU threads to use'
        )]
        $CpuThreads,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regular expression to suppress output'
        )]
        $SuppressRegex,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio context size for processing'
        )]
        $AudioContextSize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Silence threshold for audio processing'
        )]
        $SilenceThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty for sequence generation'
        )]
        $LengthPenalty,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold for output filtering'
        )]
        $EntropyThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold for output filtering'
        )]
        $LogProbThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold for audio detection'
        )]
        $NoSpeechThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output'
        )]
        $DontSpeak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output for thoughts'
        )]
        $DontSpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable VOX (voice activation)'
        )]
        $NoVOX,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use desktop audio capture'
        )]
        $UseDesktopAudioCapture,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable context usage'
        )]
        $NoContext,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use beam search sampling strategy'
        )]
        $WithBeamSearchSamplingStrategy,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only responses'
        )]
        $OnlyResponses
        #######################################################################
    )

    begin {
        if ($PromptForSettings) {

            $settingsInvocationArguments = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Get-AILLMSettings' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)
            $settings = GenXdev\Get-AILLMSettings @settingsInvocationArguments
            $PromptForSettings = $false;
            $PSBoundParameters['PromptForSettings'] = $false
        }

        $QuietToolChainInvocations = -not $ShowToolChainInvocations

        # determine if instructions need updating
        $updateInstructions = [string]::IsNullOrWhiteSpace($Instructions)

        # initialize exposed cmdlets if not provided
        if ($null -eq $ExposedCmdLets) {

            # use cached cmdlets if continuing last session
            if ($ContinueLast -and ($script:LLMExposedCmdlets)) {

                $ExposedCmdLets = $script:LLMExposedCmdlets
            }
            else {

                # flag that instructions need updating
                $updateInstructions = $true

                # initialize default allowed PowerShell cmdlets
                $ExposedCmdLets = @(

                    @{
                        Name          = 'GenXdev\Find-Item'
                        AllowedParams = @('SearchMask', 'Pattern')
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 3
                    },
                    @{
                        Name          = 'Microsoft.PowerShell.Management\Get-Content'
                        AllowedParams = @('LiteralPath=string')
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 2
                    },
                    @{
                        Name          = 'CimCmdlets\Get-CimInstance'
                        AllowedParams = @('Query=string', 'ClassName=string')
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 5
                    },
                    @{
                        Name                                 = 'GenXdev\Approve-NewTextFileContent'
                        AllowedParams                        = @('ContentPath', 'NewContent')
                        OutputText                           = $false
                        Confirm                              = $true
                        JsonDepth                            = 2
                        DontShowDuringConfirmationParamNames = @('NewContent')
                    },
                    @{
                        Name          = 'Microsoft.PowerShell.Utility\Invoke-WebRequest'
                        AllowedParams = @(
                            'Uri=string',
                            'Method=string',
                            'Body',
                            'ContentType=string',
                            'Method=string',
                            'UserAgent=string'
                        )
                        OutputText    = $true
                        Confirm       = $false
                        JsonDepth     = 6
                    },
                    @{
                        Name          = 'Microsoft.PowerShell.Utility\Invoke-RestMethod'
                        AllowedParams = @('Uri=string', 'Method=string', 'Body', 'ContentType=string', 'Method=string', 'UserAgent=string')
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    },
                    @{
                        Name          = 'Microsoft.PowerShell.Utility\Invoke-Expression'
                        AllowedParams = @('Command=string')
                        Confirm       = $true
                        JsonDepth     = 40
                    },
                    @{
                        Name          = 'Microsoft.PowerShell.Management\Get-Clipboard'
                        AllowedParams = @()
                        OutputText    = $true
                        Confirm       = $false
                    },
                    @{
                        Name          = 'Microsoft.PowerShell.Management\Set-Clipboard'
                        AllowedParams = @('Value=string')
                        OutputText    = $true
                        Confirm       = $false
                    }
                );

                # convert cmdlets to function definition objects
                $functionInfoObj = (GenXdev\ConvertTo-LLMOpenAIApiFunctionDefinition -ExposedCmdLets:$ExposedCmdLets)

                # remove callback functions from each function definition
                $functionInfoObj |
                    Microsoft.PowerShell.Core\ForEach-Object {
                        $null = $_.function.Remove('callback')
                    }
            }
        }

        # update instructions with ai assistant context if needed
        if ($updateInstructions) {

            # ensure instructions string is not null
            if ([string]::IsNullOrWhiteSpace($Instructions)) {

                $Instructions = ''
            }

            # append comprehensive ai assistant instructions
            $Instructions = @"
$Instructions

**You are an interactive AI assistant. Your primary functions are to:**
1. **Ask and Answer Questions:** Engage with users to understand their queries and provide relevant responses.
2. **Invoke Tools:** Proactively suggest the use of tools or directly invoke them if you are confident they can accomplish a task.

**Key Guidelines:**
- **Tool Usage:** You don't need to use all available tool parameters, and some parameters might be mutually exclusive. Determine the best parameters to use based on the task at hand.
- **PowerShell Constraints:**
  - **Avoid PowerShell Features:** Do not rely on PowerShell features like expanding string embeddings (e.g., `$()`) or any similar methods. Invoke-Expression being the exception of course. Parameter checking is strict.
  - **No Variables/Expressions:** Do not use PowerShell variables or expressions under any circumstances.

**Multiple Tool Invocations:**
- Feel free to invoke multiple tools within a single response if necessary.

**Safety Measures:**
- Do not worry about potential harm when invoking these tools. They are either unable to make changes or will prompt the user to confirm any actions. Users are aware of the possible consequences due to the nature of the PowerShell environment and the ability to enforce confirmation for any exposed tool.
"@;

            # trim any excess whitespace from instructions
            $Instructions = $Instructions.Trim()
        }

        # cache exposed cmdlets if session caching is enabled
        if (-not $NoSessionCaching) {

            $script:LLMExposedCmdlets = $ExposedCmdLets
        }

        # output verbose message about initialized cmdlets
        Microsoft.PowerShell.Utility\Write-Verbose "Initialized with $($ExposedCmdLets.Count) exposed cmdlets"

        # clean up chatonce parameter from bound parameters
        if ($PSBoundParameters.ContainsKey('ChatOnce')) {

            $null = $PSBoundParameters.Remove('ChatOnce')
        }

        # ensure exposedcmdlets parameter is present in bound parameters
        if (-not $PSBoundParameters.ContainsKey('ExposedCmdLets')) {

            $null = $PSBoundParameters.Add('ExposedCmdLets', $ExposedCmdLets);
        }
    }


    process {

        # output verbose message about starting chat interaction
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting chat interaction loop'

        # helper function to display available tool functions
        function Show-ToolFunction {

            # internal function to extract cmdlet name from full name
            function FixName([string] $Name) {

                # find the backslash separator index
                $index = $Name.IndexOf('\')

                # return substring after backslash if found, otherwise return original
                if ($index -gt 0) {
                    return $Name.Substring($index + 1)
                }
                return $Name;
            }

            # internal function to build parameter string for display
            function GetParamString([object] $Cmdlet) {

                # return empty string if no allowed parameters
                if ($null -eq $Cmdlet.AllowedParams) { return '' }

                # extract parameter names from allowed parameters array
                $params = $Cmdlet.AllowedParams |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        $a = $_

                        # extract parameter name before equals sign if present
                        if ($a -match '^(.+?)=') {
                            $a = $matches[1]
                        }
                        $a
                    }

                # return formatted parameter list
                return "($(($params -join ',')))"
            }

            # display tool functions if any are available
            if ($ExposedCmdLets.Count -gt 0) {

                # output header message for active tool functions
                Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green `
                    "Tool functions now active ($($ExposedCmdLets.Count)) ->"

                # format and display each exposed cmdlet with parameters
                $( ($ExposedCmdLets |
                            Microsoft.PowerShell.Core\ForEach-Object {

                                # get simplified name and parameter string
                                $Name = FixName($_.Name)
                                $params = GetParamString($_)

                                # add asterisk for functions requiring confirmation
                                if ($_.Confirm) {
                                    "$Name$params"
                                }
                                else {
                                    "$Name*$params"
                                }
                            } |
                            Microsoft.PowerShell.Utility\Select-Object -Unique) -join ', ') |
                        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green
            }
        }

        # initialize chat state variable
        $script:isFirst = -not $ContinueLast

        # display available tools to user
        Show-ToolFunction

        # main chat loop initialization
        $shouldStop = $false

        # enter main chat interaction loop
        while (-not $shouldStop) {

            # initialize question variable
            $question = ''

            # get user input if not in chat-once mode and no query provided
            if (-not $ChatOnce -and [string]::IsNullOrWhiteSpace($Query)) {

                # display prompt character to user
                [Console]::Write('> ');

                # configure psreadline for history prediction
                try {
                    $null = PSReadLine\Set-PSReadLineOption -PredictionSource History
                }
                catch { }

                # read user input line using psreadline
                $question = PSReadLine\PSConsoleHostReadLine

                # ensure question is not null
                if ($null -eq $question) {
                    $question = [string]::Empty
                }

                if ([string]::IsNullOrWhiteSpace($question)) {

                    break;
                }
            }
            else {

                # use provided query if available
                if (-not [string]::IsNullOrWhiteSpace($Query)) {

                    # set question to query and clear query variable
                    $question = $Query
                    $Query = [string]::Empty

                    # echo the question to console
                    [Console]::WriteLine("> $question");
                }
            }

            # output verbose message about processing query
            Microsoft.PowerShell.Utility\Write-Verbose "Processing query: $question"

            # update bound parameters for llm invocation
            $PSBoundParameters['ContinueLast'] = (-not $script:isFirst);
            $PSBoundParameters['Query'] = $question;
            $PSBoundParameters['ExposedCmdLets'] = $ExposedCmdLets;

            $settingsInvocationArguments = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Get-AILLMSettings' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)
            $settings = GenXdev\Get-AILLMSettings @settingsInvocationArguments

            # copy parameters for llm query invocation
            $invocationArguments = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Invoke-LLMQuery' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            # ensure chatonce is disabled for recursive calls
            $invocationArguments.ChatOnce = $false
            $invocationArguments.ErrorAction = 'SilentlyContinue'

            # invoke llm query and process each result (suppress verbose output)
            @(GenXdev\Invoke-LLMQuery @invocationArguments) |
                Microsoft.PowerShell.Core\ForEach-Object {

                    # store current result
                    $result = $_

                    # skip empty or null results
                    if (($null -eq $result) -or ([string]::IsNullOrEmpty("$result".trim()))) {
                        return
                    }

                    # mark that this is no longer the first interaction
                    $script:isFirst = $false

                    # output result based on mode
                    if ($ChatOnce) {

                        # return result object for chat-once mode
                        Microsoft.PowerShell.Utility\Write-Output $result
                    }
                    else {

                        # display result as host output for interactive mode
                        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Yellow "$result"
                    }
                }

            # determine if chat loop should stop
            $shouldStop = $ChatOnce
        }
    }

    end {

        # output verbose message about chat session completion
        Microsoft.PowerShell.Utility\Write-Verbose 'Chat session completed, use -ContinueLast to continue the conversation'
    }
}
###############################################################################