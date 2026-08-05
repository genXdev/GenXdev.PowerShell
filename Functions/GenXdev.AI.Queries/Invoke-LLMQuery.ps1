###############################################################################
<#
.SYNOPSIS
Sends queries to an OpenAI compatible Large Language Chat completion API and
processes responses.

.DESCRIPTION
This function sends queries to an OpenAI compatible Large Language Chat
completion API and processes responses. It supports text and image inputs,
handles tool function calls, and can operate in various chat modes including
text and audio.

The function provides comprehensive support for LLM interaction including:
- Text and image input processing
- Tool function calling and command execution
- Interactive chat modes (text and audio)
- Model initialization and configuration
- Response formatting and processing
- Session management and caching
- Window positioning and display control

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
The text query to send to the model. Can be empty for chat modes.

.PARAMETER Instructions
System instructions to provide context to the model.

.PARAMETER Attachments
Array of file paths to attach to the query. Supports images and text files.

.PARAMETER ResponseFormat
A JSON schema for the requested output format.

.PARAMETER Temperature
Controls response randomness (0.0-1.0). Lower values are more deterministic.

.PARAMETER Functions
Array of function definitions that the model can call.

.PARAMETER ExposedCmdLets
PowerShell commands to expose as tools to the model.

.PARAMETER NoConfirmationToolFunctionNames
Tool functions that don't require user confirmation.

.PARAMETER ImageDetail
Detail level for image processing (low/medium/high).

.PARAMETER IncludeThoughts
Include model's thought process in output.

.PARAMETER DontAddThoughtsToHistory
Exclude thought processes from conversation history.

.PARAMETER ContinueLast
Continue from the last conversation context.

.PARAMETER Speak
Enable text-to-speech for AI responses.

.PARAMETER SpeakThoughts
Enable text-to-speech for AI thought process.

.PARAMETER OutputMarkdownBlocksOnly
Only output markup block responses.

.PARAMETER MarkupBlocksTypeFilter
Only output markup blocks of the specified types.

.PARAMETER ChatMode
Enable interactive chat mode with specified input method.

.PARAMETER ChatOnce
Internal parameter to control chat mode invocation.

.PARAMETER NoSessionCaching
Don't store session in session cache.

.PARAMETER LLMQueryType
The type of LLM query to use for AI operations.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER PromptForSettings
When specified, launches an interactive prompt to configure the LLM settings

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
Invoke-LLMQuery -Query "What is 2+2?" -Model "qwen" -Temperature 0.7

Sends a simple mathematical query to the qwen model with specified temperature.

.EXAMPLE
qllm "What is 2+2?" -Model "qwen"

Uses the alias to send a query with default parameters.

.EXAMPLE
Invoke-LLMQuery -Query "Analyze this image" -Attachments @("image.jpg") -Model "qwen"

Sends a query with an image attachment for analysis.

.EXAMPLE
llm "Start a conversation" -ChatMode "textprompt" -Model "qwen"

Starts an interactive text chat session with the specified model.
#>
###############################################################################
function Invoke-LLMQuery {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('qllm', 'llm')]

    param(
        ###################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'Query text to send to the model'
        )]
        [AllowEmptyString()]
        [string] $Query = '',
        ###################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'System instructions for the model'
        )]
        [string] $Instructions,
        ###################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'Array of file paths to attach'
        )]
        [string[]] $Attachments = @(),
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'A JSON schema for the requested output format'
        )]
        [string] $ResponseFormat,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of function definitions'
        )]
        [hashtable[]] $Functions = @(),
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Array of PowerShell command definitions to use ' +
                'as tools')
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]] $ExposedCmdLets,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Tool functions that don't require user " +
                'confirmation')
        )]
        [Alias('NoConfirmationFor')]
        [string[]] $NoConfirmationToolFunctionNames = @(),
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Suppresses Write-Host output during ' +
                'intermediate tool chain invocations')
        )]
        [switch] $QuietToolChainInvocations,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Image detail level'
        )]
        [ValidateSet('low', 'medium', 'high')]
        [string] $ImageDetail = 'low',
        ###################################################################
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
        [string] $LLMQueryType = 'SimpleIntelligence',
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The model identifier or pattern to use for AI ' +
                'operations')
        )]
        [string] $Model,
        ###################################################################
        [int] $Gpu,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ###################################################################
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
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for audio generation randomness'
        )]
        [double] $AudioTemperature,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (audio chat)'
        )]
        [double] $TemperatureResponse,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Language code or name for audio chat'
        )]
        [string] $Language,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of CPU threads to use for audio chat'
        )]
        [int] $CpuThreads,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regular expression to suppress certain outputs in audio chat'
        )]
        [string] $SuppressRegex,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio context size for audio chat'
        )]
        [int] $AudioContextSize,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Silence threshold for audio chat'
        )]
        [double] $SilenceThreshold,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty for audio chat responses'
        )]
        [double] $LengthPenalty,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold for audio chat'
        )]
        [double] $EntropyThreshold,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold for audio chat'
        )]
        [double] $LogProbThreshold,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold for audio chat'
        )]
        [double] $NoSpeechThreshold,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not speak audio responses'
        )]
        [switch] $DontSpeak,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not speak audio thoughts'
        )]
        [switch] $DontSpeakThoughts,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable VOX (voice activation) for audio chat'
        )]
        [switch] $NoVOX,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use desktop audio capture for audio chat'
        )]
        [switch] $UseDesktopAudioCapture,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable context for audio chat'
        )]
        [switch] $NoContext,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use beam search sampling strategy for audio chat'
        )]
        [switch] $WithBeamSearchSamplingStrategy,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only responses (no intermediate output)'
        )]
        [switch] $OnlyResponses,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $IncludeThoughts,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Exclude thought processes from conversation ' +
                'history')
        )]
        [switch] $DontAddThoughtsToHistory,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Continue from last conversation'
        )]
        [switch] $ContinueLast,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI responses'
        )]
        [switch] $Speak,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI thought responses'
        )]
        [switch] $SpeakThoughts,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will only output markup block responses'
        )]
        [switch] $OutputMarkdownBlocksOnly,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Extracts the outermost JSON object or array ' +
                'from the response, discarding markdown fences and ' +
                'surrounding text. Automatically enabled when ' +
                '-ResponseFormat is set; use this switch to force it for ' +
                'plain-text calls expecting JSON output.')
        )]
        [switch] $FilterForJsonOutput,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will only output markup blocks of the ' +
                'specified types')
        )]
        [ValidateNotNull()]
        [string[]] $MarkupBlocksTypeFilter = @('json', 'powershell', 'C#',
            'python', 'javascript', 'typescript', 'html', 'css', 'yaml',
            'xml', 'bash'),
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable chat mode'
        )]
        [Alias('chat')]
        [ValidateSet('none', 'textprompt', 'default audioinput device',
            'desktop audio')]
        [string] $ChatMode,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Used internally, to only invoke chat mode once ' +
                'after the llm invocation')
        )]
        [switch] $ChatOnce,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'AI preferences')
        )]
        [switch] $SessionOnly,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session ' +
                'for AI preferences')
        )]
        [switch] $ClearSession,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences ' +
                'without affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum length of tool callback output in characters. Output exceeding this length will be trimmed with a warning message. Default is 100000 characters.'
        )]
        [int] $MaxToolcallBackLength = 100000
        ###################################################################
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

        # store PSBoundParameters to avoid nested function issues
        $myPSBoundParameters = $PSBoundParameters
        Microsoft.PowerShell.Utility\Write-Verbose "PSBoundParameters keys: $($myPSBoundParameters.Keys -join ', ')"
        Microsoft.PowerShell.Utility\Write-Verbose "PSBoundParameters MaxToolcallBackLength: $($myPSBoundParameters['MaxToolcallBackLength'])"

        # copy identical parameter values for llm configuration
        $llmConfigParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $myPSBoundParameters `
            -FunctionName 'GenXdev\Get-AILLMSettings' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local -ErrorAction SilentlyContinue)
        Microsoft.PowerShell.Utility\Write-Verbose "llmConfigParams keys: $($llmConfigParams.Keys -join ', ')"
        Microsoft.PowerShell.Utility\Write-Verbose "llmConfigParams MaxToolcallBackLength: $($llmConfigParams['MaxToolcallBackLength'])"

        # get the llm settings configuration
        $llmConfig = GenXdev\Get-AILLMSettings @llmConfigParams
        Microsoft.PowerShell.Utility\Write-Verbose "LLM Config keys: $($llmConfig.Keys -join ', ')"
        Microsoft.PowerShell.Utility\Write-Verbose "LLM Config MaxToolcallBackLength: $($llmConfig['MaxToolcallBackLength'])"

        # apply configuration settings to local variables
        foreach ($param in $llmConfig.Keys) {

            # check if variable exists in local scope and skip MaxToolcallBackLength to preserve user-specified value
            if (($null -ne $llmConfig[$param]) -and ($param -ne 'MaxToolcallBackLength') -and (
                    Microsoft.PowerShell.Utility\Get-Variable -Name $param `
                        -Scope Local -ErrorAction SilentlyContinue)) {

                Microsoft.PowerShell.Utility\Write-Verbose "Setting $param to $($llmConfig[$param])"
                # set the variable value from configuration
                Microsoft.PowerShell.Utility\Set-Variable -Name $param `
                    -Value $llmConfig[$param] -Scope Local -Force
            }
        }
        Microsoft.PowerShell.Utility\Write-Verbose "MaxToolcallBackLength after config override: $MaxToolcallBackLength"

        # output verbose information about starting llm interaction
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting LLM interaction...'
        Microsoft.PowerShell.Utility\Write-Verbose "MaxToolcallBackLength parameter value: $MaxToolcallBackLength"

        # Ensure MaxToolcallBackLength has a reasonable minimum value
        if ($MaxToolcallBackLength -le 1000) {
            Microsoft.PowerShell.Utility\Write-Verbose "MaxToolcallBackLength was $MaxToolcallBackLength, forcing to 100000"
            $MaxToolcallBackLength = 100000
        }

        # convert markup block types to lowercase for case-insensitive comparison
        $markupBlocksTypeFilter = $MarkupBlocksTypeFilter |
            Microsoft.PowerShell.Core\ForEach-Object { $_.ToLowerInvariant() }


        $Model = $llmConfig.Model

        Microsoft.PowerShell.Utility\Write-Progress -PercentComplete 0 `
            -Activity 'Invoking LLM Query' `
            -Status "Model: ${Model}"

        # handle chat mode parameter
        if ($myPSBoundParameters.ContainsKey('ChatMode')) {

            # remove chat mode parameter from bound parameters
            $null = $myPSBoundParameters.Remove('ChatMode')

            # return early if chat mode is not none or chat once is not set
            if (($ChatMode -ne 'none' -or $ChatOnce)) {
                return;
            }
        }

        # convert tool functions if needed or use cached ones for continue last conversation
        if ($ContinueLast -and (-not $ExposedCmdLets) -and `
                $Global:LLMGlobalExposedCmdlets -and `
                (-not $PSBoundParameters.ContainsKey('ExposedCmdLets'))) {

            # take exposed cmdlets from global cache
            $ExposedCmdLets = $Global:LLMGlobalExposedCmdlets
        }

        # check if user has provided exposed cmdlet definitions
        if ($ExposedCmdLets -and $ExposedCmdLets.Count -gt 0) {

            # set global cache if session caching is enabled
            if (-not $NoSessionCaching) {

                # store exposed cmdlets in global cache
                $Global:LLMGlobalExposedCmdlets = $ExposedCmdLets
            }

            # output verbose information about converting tool functions
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Converting tool functions to LLM OpenAI API format'

            # convert exposed cmdlets to function definitions
            $functions = GenXdev\ConvertTo-LLMOpenAIApiFunctionDefinition `
                -ExposedCmdLets $ExposedCmdLets
        }

        # create messages list for conversation context
        $messages = [System.Collections.Generic.List[PSCustomObject]] (

            # check if global chat history exists and user wants to continue last conversation
            (($null -ne $Global:LLMChatHistory) -and ($ContinueLast)) ?

            # take messages from global cache
            $Global:LLMChatHistory :

            # otherwise create new empty list
            @()
        )

        # update global chat history if session caching is enabled
        if (-not $NoSessionCaching) {

            # store messages in global chat history
            $Global:LLMChatHistory = $messages
        }

        # Determine whether JSON output is expected, before the
        # NoSupportForJsonSchema block may null $ResponseFormat.
        $expectJsonOutput =
        (-not [string]::IsNullOrWhiteSpace($ResponseFormat))

        # If the LLM lacks native json_schema support, generate a correct
        # example from the actual schema and inject it into the system
        # instructions. Null $ResponseFormat so the downstream
        # response_format payload field is skipped — the format is
        # already in the system prompt.
        if ($expectJsonOutput -and
            ($NoSupportForJsonSchema -or
            ($llmConfig.NoSupportForJsonSchema -eq $true))) {

            try {
                $example = GenXdev\Get-JsonExampleFromSchema `
                    -Schema $ResponseFormat

                $Instructions += @"

`n`n===== JSON OUTPUT FORMAT =====
Respond with ONLY valid JSON. No markdown fences, no commentary.
${example}
"@

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'LLM lacks native JSON schema support. ' +
                    'Injected schema-driven example into system instructions.')
            }
            catch {
                # Schema parse failed — use a simple fallback
                $Instructions += "`n`nRespond with ONLY valid JSON. No markdown fences, no commentary.`n"
            }

            # Null ResponseFormat so the downstream payload code
            # (which sets response_format) uses $expectJsonOutput as
            # guard instead.  Save the schema so Get-LLMJsonOutput
            # can still use it for guided extraction later.
            $responseSchema = $ResponseFormat
            $ResponseFormat = $null
        }

        # create system instruction message
        $newMessage = @{
            role    = 'system'
            content = $Instructions
        }

        # add system message if not already present to avoid duplicates
        $newMessageJson = $newMessage |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress `
                -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

        # initialize duplicate check flag
        $isDuplicate = $false

        # check for duplicate messages in existing history
        foreach ($msg in $messages) {

            # convert message to json for comparison
            if (($msg | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 `
                        -Compress -WarningAction SilentlyContinue `
                        -ErrorAction SilentlyContinue) -eq $newMessageJson) {

                # mark as duplicate
                $isDuplicate = $true
                break
            }
        }

        # add system message if not duplicate
        if (-not $isDuplicate) {

            # output verbose information about system instructions
            Microsoft.PowerShell.Utility\Write-Verbose `
                "System Instructions: $Instructions"

            # add system message to messages list
            $null = $messages.Add($newMessage)
        }

        # prepare api endpoint and headers
        $apiUrl = 'http://localhost:1234/v1/chat/completions'

        # use custom api endpoint if provided
        if (-not [string]::IsNullOrWhiteSpace($ApiEndpoint)) {

            # set api url to custom endpoint
            $apiUrl = $ApiEndpoint
        }

        # set up http headers including authorization if api key provided
        $headers = @{ 'Content-Type' = 'application/json' }

        # add authorization header if api key is provided
        if (-not [string]::IsNullOrWhiteSpace($ApiKey)) {

            # set bearer token authorization header
            $headers.'Authorization' = "Bearer $ApiKey"
        }

        # output verbose information about conversation initialization
        Microsoft.PowerShell.Utility\Write-Verbose `
            'Initialized conversation with system instructions'
    }

    process {

        # handle chat once mode for internal parameter control
        if ($ChatOnce) {

            # copy identical parameter values for text chat invocation
            $invocationArgs = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $myPSBoundParameters `
                -FunctionName 'GenXdev\New-LLMTextChat' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local -ErrorAction SilentlyContinue)

            # invoke text chat and return result
            return (GenXdev\New-LLMTextChat @invocationArgs)
        }

        # output verbose information about request parameters
        Microsoft.PowerShell.Utility\Write-Verbose 'Sending request to LLM with:'
        Microsoft.PowerShell.Utility\Write-Verbose "Model: $Model"
        Microsoft.PowerShell.Utility\Write-Verbose "Query: $Query"
        Microsoft.PowerShell.Utility\Write-Verbose "Temperature: $Temperature"

        # handle different chat modes
        switch ($ChatMode) {

            'textprompt' {

                # copy identical parameter values for text chat invocation
                $invocationArgs = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $myPSBoundParameters `
                    -FunctionName 'GenXdev\New-LLMTextChat' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local -ErrorAction SilentlyContinue)

                # invoke text chat and return result
                return (GenXdev\New-LLMTextChat @invocationArgs)
            }
            'default audioinput device' {

                # copy identical parameter values for audio chat invocation
                $invocationArgs = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $myPSBoundParameters `
                    -FunctionName 'GenXdev\New-LLMAudioChat' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local -ErrorAction SilentlyContinue)

                # invoke audio chat and return result
                return (GenXdev\New-LLMAudioChat @invocationArgs)
            }
            'desktop audio' {

                # enable desktop audio for audio chat
                $desktopAudio = $true

                # copy identical parameter values for audio chat invocation
                $invocationArgs = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $myPSBoundParameters `
                    -FunctionName 'GenXdev\New-LLMAudioChat' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local -ErrorAction SilentlyContinue)

                # invoke audio chat and return result
                return (GenXdev\New-LLMAudioChat @invocationArgs)
            }
        }

        # process attachments if provided
        foreach ($attachment in $Attachments) {

            # expand the file path to handle relative paths
            $filePath = GenXdev\Expand-Path $attachment

            # get file extension for mime type determination
            $fileExtension = [System.IO.Path]::GetExtension($filePath).ToLowerInvariant()

            # initialize mime type and text flag
            $mimeType = 'application/octet-stream'
            $isText = $false

            # determine mime type and text flag based on file extension
            switch ($fileExtension) {
                '.jpg' {
                    $mimeType = 'image/jpeg'
                    $isText = $false
                    break
                }
                '.jpg' {
                    $mimeType = 'image/jpeg'
                    $isText = $false
                    break
                }
                '.jpeg' {
                    $mimeType = 'image/jpeg'
                    $isText = $false
                    break
                }
                '.png' {
                    $mimeType = 'image/png'
                    $isText = $false
                    break
                }
                '.gif' {
                    $mimeType = 'image/gif'
                    $isText = $false
                    break
                }
                '.bmp' {
                    $mimeType = 'image/bmp'
                    $isText = $false
                    break
                }
                '.webp' {
                    $mimeType = 'image/webp'
                    $isText = $false
                    break
                }
                '.tiff' {
                    $mimeType = 'image/tiff'
                    $isText = $false
                    break
                }
                '.tif' {
                    $mimeType = 'image/tiff'
                    $isText = $false
                    break
                }
                '.png' {
                    $mimeType = 'image/png'
                    $isText = $false
                    break
                }
                '.gif' {
                    $mimeType = 'image/gif'
                    $isText = $false
                    break
                }
                '.bmp' {
                    $mimeType = 'image/bmp'
                    $isText = $false
                    break
                }
                '.tiff' {
                    $mimeType = 'image/tiff'
                    $isText = $false
                    break
                }
                '.mp4' {
                    $mimeType = 'video/mp4'
                    $isText = $false
                    break
                }
                '.avi' {
                    $mimeType = 'video/avi'
                    $isText = $false
                    break;
                }
                '.mov' {
                    $mimeType = 'video/quicktime'
                    $isText = $false
                    break;
                }
                '.webm' {
                    $mimeType = 'video/webm'
                    $isText = $false
                    break;
                }
                '.mkv' {
                    $mimeType = 'video/x-matroska'
                    $isText = $false
                    break;
                }
                '.flv' {
                    $mimeType = 'video/x-flv'
                    $isText = $false
                    break;
                }
                '.wmv' {
                    $mimeType = 'video/x-ms-wmv'
                    $isText = $false
                    break;
                }
                '.mpg' {
                    $mimeType = 'video/mpeg'
                    $isText = $false
                    break;
                }
                '.mpeg' {
                    $mimeType = 'video/mpeg'
                    $isText = $false
                    break;
                }
                '.3gp' {
                    $mimeType = 'video/3gpp'
                    $isText = $false
                    break;
                }
                '.3g2' {
                    $mimeType = 'video/3gpp2'
                    $isText = $false
                    break;
                }
                '.m4v' {
                    $mimeType = 'video/x-m4v'
                    $isText = $false
                    break;
                }
                '.webp' {
                    $mimeType = 'image/webp'
                    $isText = $false
                    break;
                }
                '.heic' {
                    $mimeType = 'image/heic'
                    $isText = $false
                    break;
                }
                '.heif' {
                    $mimeType = 'image/heif'
                    $isText = $false
                    break;
                }
                '.avif' {
                    $mimeType = 'image/avif'
                    $isText = $false
                    break;
                }
                '.jxl' {
                    $mimeType = 'image/jxl'
                    $isText = $false
                    break;
                }
                '.ps1' {
                    $mimeType = 'text/x-powershell'
                    $isText = $true
                    break;
                }
                '.psm1' {
                    $mimeType = 'text/x-powershell'
                    $isText = $true
                    break;
                }
                '.psd1' {
                    $mimeType = 'text/x-powershell'
                    $isText = $true
                    break;
                }
                '.sh' {
                    $mimeType = 'application/x-sh'
                    $isText = $true
                    break;
                }
                '.bat' {
                    $mimeType = 'application/x-msdos-program'
                    $isText = $true
                    break;
                }
                '.cmd' {
                    $mimeType = 'application/x-msdos-program'
                    $isText = $true
                    break;
                }
                '.py' {
                    $mimeType = 'text/x-python'
                    $isText = $true
                    break;
                }
                '.rb' {
                    $mimeType = 'application/x-ruby'
                    $isText = $true
                    break;
                }
                '.txt' {
                    $mimeType = 'text/plain'
                    $isText = $true
                    break;
                }
                '.pl' {
                    $mimeType = 'text/x-perl'
                    $isText = $true
                    break;
                }
                '.php' {
                    $mimeType = 'application/x-httpd-php'
                    $isText = $true
                    break;
                }
                '.pdf' {
                    $mimeType = 'application/pdf'
                    $isText = $false
                    break;
                }
                '.js' {
                    $mimeType = 'application/javascript'
                    $isText = $true
                    break;
                }
                '.ts' {
                    $mimeType = 'application/typescript'
                    $isText = $true
                    break;
                }
                '.java' {
                    $mimeType = 'text/x-java-source'
                    $isText = $true
                    break;
                }
                '.c' {
                    $mimeType = 'text/x-c'
                    $isText = $true
                    break;
                }
                '.cpp' {
                    $mimeType = 'text/x-c++src'
                    $isText = $true
                    break;
                }
                '.cs' {
                    $mimeType = 'text/x-csharp'
                    $isText = $true
                    break;
                }
                '.go' {
                    $mimeType = 'text/x-go'
                    $isText = $true
                    break;
                }
                '.rs' {
                    $mimeType = 'text/x-rustsrc'
                    $isText = $true
                    break;
                }
                '.swift' {
                    $mimeType = 'text/x-swift'
                    $isText = $true
                    break;
                }
                '.kt' {
                    $mimeType = 'text/x-kotlin'
                    $isText = $true
                    break;
                }
                '.scala' {
                    $mimeType = 'text/x-scala'
                    $isText = $true
                    break;
                }
                '.r' {
                    $mimeType = 'text/x-r'
                    $isText = $true
                    break;
                }
                '.sql' {
                    $mimeType = 'application/sql'
                    $isText = $true
                    break;
                }
                '.html' {
                    $mimeType = 'text/html'
                    $isText = $true
                    break;
                }
                '.css' {
                    $mimeType = 'text/css'
                    $isText = $true
                    break;
                }
                '.xml' {
                    $mimeType = 'application/xml'
                    $isText = $true
                    break;
                }
                '.json' {
                    $mimeType = 'application/json'
                    $isText = $true
                    break;
                }
                '.yaml' {
                    $mimeType = 'application/x-yaml'
                    $isText = $true
                    break;
                }
                '.md' {
                    $mimeType = 'text/markdown'
                    $isText = $true
                    break;
                }
                default {
                    $mimeType = 'image/jpeg'
                    $isText = $false
                    break;
                }
            }

            # internal function to get base64 encoded image data with optional scaling
            function getImageBase64Data($filePath, $ImageDetail) {

                # try to load image using system drawing
                $image = $null
                try {
                    $image = [System.Drawing.Image]::FromFile($filePath)
                }
                catch {
                    $image = $null
                }

                # if image loading failed, return raw file bytes as base64
                if ($null -eq $image) {
                    return [System.Convert]::ToBase64String([IO.File]::ReadAllBytes($filePath))
                }

                # get maximum dimension of the image
                $maxImageDimension = [Math]::Max($image.Width, $image.Height);
                $maxDimension = $maxImageDimension;

                # determine target dimension based on image detail level
                switch ($ImageDetail) {
                    'low' {
                        $maxDimension = 800;
                        break;
                    }
                    'medium' {
                        $maxDimension = 1600;
                        break;
                    }
                }

                # scale image if it exceeds the maximum dimension
                try {
                    if ($maxDimension -lt $maxImageDimension) {

                        # calculate new dimensions maintaining aspect ratio
                        $newWidth = $image.Width;
                        $newHeight = $image.Height;
                        if ($image.Width -gt $image.Height) {
                            $newWidth = $maxDimension
                            $newHeight = [math]::Round($image.Height * ($maxDimension / $image.Width))
                        }
                        else {
                            $newHeight = $maxDimension
                            $newWidth = [math]::Round($image.Width * ($maxDimension / $image.Height))
                        }

                        # create scaled bitmap and draw resized image
                        $scaledImage = Microsoft.PowerShell.Utility\New-Object System.Drawing.Bitmap $newWidth, $newHeight
                        $graphics = [System.Drawing.Graphics]::FromImage($scaledImage)
                        $graphics.DrawImage($image, 0, 0, $newWidth, $newHeight)
                        $graphics.Dispose();
                    }
                }
                catch {
                    # ignore scaling errors and use original image
                }

                # save image to memory stream and convert to base64
                $memoryStream = Microsoft.PowerShell.Utility\New-Object System.IO.MemoryStream
                $image.Save($memoryStream, $image.RawFormat)
                $imageData = $memoryStream.ToArray()
                $memoryStream.Close()
                $image.Dispose()
                return [System.Convert]::ToBase64String($imageData)
            }

            # get base64 encoded data for the attachment
            [string] $base64Data = getImageBase64Data $filePath $ImageDetail

            # handle text files differently than binary files
            if ($isText) {

                $newMessage = @{
                    role    = 'user'
                    content = $Query
                    file    = @{
                        name         = [IO.Path]::GetFileName($filePath)
                        content_type = $mimeType
                        bytes        = "data:$mimeType;base64,$base64Data"
                    }
                }
                $newMessageJson = $newMessage | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                $isDuplicate = $false
                foreach ($msg in $messages) {
                    if (($msg | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress) -eq $newMessageJson) {
                        $isDuplicate = $true
                        break
                    }
                }
                if (-not $isDuplicate) {

                    $null = $messages.Add($newMessage)
                }
            }
            else {

                $newMessage = @{
                    role    = 'user'
                    content = @(
                        @{
                            type      = 'image_url'
                            image_url = @{
                                url    = "data:$mimeType;base64,$base64Data"
                                detail = "$ImageDetail"
                            }
                        }
                    )
                }
                $newMessageJson = $newMessage | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
                $isDuplicate = $false
                foreach ($msg in $messages) {
                    if (($msg | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) -eq $newMessageJson) {
                        $isDuplicate = $true
                        break
                    }
                }
                if (-not $isDuplicate) {

                    $null = $messages.Add($newMessage)
                }
            }
        }

        # prepare api payload

        $payload = @{
            stream   = $false
            messages = $messages
        }

        if ($Temperature -ge 0) {

            $payload.temperature = $Temperature
        }
        if ($expectJsonOutput) {
            try {
                if ($NoSupportForJsonSchema -or ($llmConfig.NoSupportForJsonSchema -eq $true)) {
                    # json_object mode is widely supported (DeepSeek, etc.)
                    $payload.response_format = @{ type = 'json_object' }
                }
                else {
                    # Normal path: Use native JSON schema/object support
                    $payload.response_format = $ResponseFormat | Microsoft.PowerShell.Utility\ConvertFrom-Json
                }
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Verbose 'Invalid response format schema. Ignoring.'
            }
        }

        if (-not [string]::IsNullOrWhiteSpace($Model)) {

            $payload.model = $Model
        }

        if (($Functions -and $Functions.Count -gt 0) -or ($ExposedCmdLets -and $ExposedCmdLets.Count -gt 0)) {

            if ($llmConfig.NoSupportForToolCalls -eq $true) {
                $modelName = if ([string]::IsNullOrWhiteSpace($Model)) { 'the selected model' } else { $Model }
                $endpointName = if ([string]::IsNullOrWhiteSpace($ApiEndpoint)) { 'the selected endpoint' } else { $ApiEndpoint }
                throw "The selected LLM model/endpoint does not support tool calling. Remove tool-enabled functions or switch to a compatible model/endpoint. Model: $modelName. Endpoint: $endpointName"
            }

            # maintain array structure, create new array with required properties
            $functionsWithoutCallbacks = @(
                $Functions | Microsoft.PowerShell.Core\ForEach-Object {
                    $cleanProperties = @{}
                    foreach ($prop in $_.function.parameters.properties.GetEnumerator()) {
                        $cleanProp = @{}
                        foreach ($key in $prop.Value.Keys) {
                            if ($key -ne 'powershell_type') {
                                $cleanProp[$key] = $prop.Value[$key]
                            }
                        }
                        $cleanProperties[$prop.Key] = $cleanProp
                    }

                    [PSCustomObject] @{
                        type     = $_.type
                        function = [PSCustomObject] @{
                            name        = $_.function.name
                            description = $_.function.description
                            parameters  = @{
                                type       = 'object'
                                properties = [PSCustomObject] $cleanProperties
                                required   = $_.function.parameters.required
                            }
                        }
                    }
                }
            )

            $payload.tools = $functionsWithoutCallbacks
            $payload.function_call = 'auto'
        }

        if (-not [string]::IsNullOrWhiteSpace($Query)) {

            # add main query message
            $newMsg = @{
                role    = 'user'
                content = $Query;
            }

            $null = $messages.Add($newMsg)
        }

        # JSON schema fallback is now handled before the system message
        # is created (see begin block). If $ResponseFormat is still set
        # here, the LLM has native json_schema support — nothing to do.

        # convert payload to json
        $json = $payload | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 60 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue
        $bytes = [System.Text.Encoding]::UTF8.GetBytes($json)
        Microsoft.PowerShell.Utility\Write-Verbose "Querying LLM model '$Model' with parameters:"
        Microsoft.PowerShell.Utility\Write-Verbose $($payload | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 7 -WarningAction SilentlyContinue -ErrorAction SilentlyContinue)
        Microsoft.PowerShell.Utility\Write-Verbose "Request endpoint: $apiUrl"
        Microsoft.PowerShell.Utility\Write-Verbose "Request method: POST"
        Microsoft.PowerShell.Utility\Write-Verbose "Request timeout seconds: $TimeoutSeconds"
        Microsoft.PowerShell.Utility\Write-Verbose "Request message count: $($messages.Count)"
        Microsoft.PowerShell.Utility\Write-Verbose "Request includes tools: $($payload.ContainsKey('tools'))"
        Microsoft.PowerShell.Utility\Write-Verbose "Request has authorization header: $(-not [string]::IsNullOrWhiteSpace($ApiKey))"

        try {
            # send request with long timeouts
            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod -Uri $apiUrl `
                -Verbose:$false `
                -ProgressAction Continue `
                -Method Post `
                -Body $bytes `
                -Headers $headers `
                -OperationTimeoutSeconds $TimeoutSeconds `
                -ConnectionTimeoutSeconds $TimeoutSeconds

            Microsoft.PowerShell.Utility\Write-Verbose "REST call completed successfully. Response type: $($response.GetType().FullName)"
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose "Invoke-RestMethod failed. Exception: $($_.Exception.Message)"
            if ($null -ne $_.ErrorDetails) {
                Microsoft.PowerShell.Utility\Write-Verbose "Invoke-RestMethod error details: $($_.ErrorDetails | Microsoft.PowerShell.Utility\Out-String)"
            }

            # extract HTTP status code for helpful error messages
            $statusCode = $null
            try {
                $statusCode = $_.Exception.Response.StatusCode.value__
            } catch { }

            if ($null -ne $statusCode) {
                Microsoft.PowerShell.Utility\Write-Verbose "HTTP status code: ${statusCode}"

                switch ($statusCode) {
                    401 {
                        Microsoft.PowerShell.Utility\Write-Warning (
                            "LLM API returned 401 (Unauthorized). " +
                            "Your API key appears to be invalid. " +
                            "Reconfigure with: Set-AILLMSettings " +
                            "-PromptForSettings -LLMQueryType ${LLMQueryType}"
                        )
                    }
                    403 {
                        Microsoft.PowerShell.Utility\Write-Warning (
                            "LLM API returned 403 (Forbidden). " +
                            "Your account may lack permission " +
                            "for model '${Model}'. Verify your " +
                            "API key has access to this model."
                        )
                    }
                    429 {
                        Microsoft.PowerShell.Utility\Write-Warning (
                            "LLM API returned 429 (Too Many Requests). " +
                            "You've hit a rate limit. Wait a moment " +
                            "and try again, or check your usage quota."
                        )
                    }
                    default {
                        if ($statusCode -ge 400 -and $statusCode -lt 500) {
                            Microsoft.PowerShell.Utility\Write-Warning (
                                "LLM API returned HTTP ${statusCode}. " +
                                "There may be an issue with your request " +
                                "parameters or account configuration."
                            )
                        }
                    }
                }
            }

            throw
        }

        # First handle tool calls if present
        if ($response.choices -and ($response.choices[0].message.tool_calls)) {

            # Add assistant's tool calls to history
            $newMsg = $response.choices[0].message
            $newMsgJson = $newMsg | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue

            # Only add if it's not a duplicate of the last message
            if ($messages.Count -eq 0 -or
                ($messages[-1] | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress -WarningAction SilentlyContinue -ErrorAction SilentlyContinue) -ne $newMsgJson) {
                $messages.Add($newMsg) | Microsoft.PowerShell.Core\Out-Null
            }

            # Process all tool calls sequentially
            foreach ($toolCallCO in $response.choices[0].message.tool_calls) {

                $toolCall = $toolCallCO | GenXdev\ConvertTo-HashTable

                Microsoft.PowerShell.Utility\Write-Verbose "Tool call detected: $($toolCall.function.name)"

                # Format parameters as PowerShell command line style
                $foundArguments = ($toolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json)
                $paramLine = $toolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json |
                    Microsoft.PowerShell.Utility\Get-Member -MemberType NoteProperty |
                    Microsoft.PowerShell.Core\ForEach-Object {
                        $name = $_.Name
                        $value = $foundArguments.$name
                        "-$name $($value | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 3 -WarningAction SilentlyContinue)"
                    } | Microsoft.PowerShell.Utility\Join-String -Separator ' '

                Microsoft.PowerShell.Utility\Write-Progress -PercentComplete 50 `
                    -Activity 'Executing toolcall' `
                    -Status "$($toolCall.function.name) ${paramLine}"

                Microsoft.PowerShell.Utility\Write-Verbose "PS> $($toolCall.function.name) $paramLine"
                if (-not ($Verbose -or $VerbosePreference -eq 'Continue') -and
                    -not $QuietToolChainInvocations) {

                    Microsoft.PowerShell.Utility\Write-Host "PS> $($toolCall.function.name) $paramLine" -ForegroundColor Cyan
                }

                [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = GenXdev\Invoke-CommandFromToolCall `
                    -ToolCall:$toolCall `
                    -Functions:$Functions `
                    -ExposedCmdLets:$ExposedCmdLets `
                    -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames | Microsoft.PowerShell.Utility\Select-Object -First 1

                if ((-not ($Verbose -or $VerbosePreference -eq 'Continue')) -and
                    -not $QuietToolChainInvocations) {

                    Microsoft.PowerShell.Utility\Write-Host "$($invocationResult.Output | Microsoft.PowerShell.Core\ForEach-Object { if ($_ -is [string]) { $_ } else { $_ | Microsoft.PowerShell.Utility\Out-String } })" -ForegroundColor Green
                }

                Microsoft.PowerShell.Utility\Write-Verbose "Tool function result: $($invocationResult | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 3 -Compress)"

                if (-not $invocationResult.CommandExposed) {

                    # Add tool response to history
                    $null = $messages.Add(@{
                            role         = 'tool'
                            name         = $toolCall.function.name
                            content      = $invocationResult.Error ? $invocationResult.Error : $invocationResult.Reason
                            tool_call_id = $toolCall.id
                            id           = $toolCall.id
                            arguments    = $toolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json
                        })
                }
                else {
                    # Check if the cmdlet is configured to return text only
                    $isTextOnlyOutput = $invocationResult.ExposedCmdLet -and $invocationResult.ExposedCmdLet.OutputText -eq $true

                    if ($isTextOnlyOutput) {
                        # For text-only output, convert everything to string first using Out-String
                        Microsoft.PowerShell.Utility\Write-Verbose "Tool '$($toolCall.function.name)' raw output type: $($invocationResult.Output.GetType().FullName)"
                        Microsoft.PowerShell.Utility\Write-Verbose "Tool '$($toolCall.function.name)' raw output count: $(if ($invocationResult.Output -is [Array]) { $invocationResult.Output.Count } else { '1 (not array)' })"
                        $outputText = "$(($invocationResult.Output | Microsoft.PowerShell.Utility\Out-String))".Trim()
                        Microsoft.PowerShell.Utility\Write-Verbose "Tool '$($toolCall.function.name)' text output length: $($outputText.Length) characters (max: $MaxToolcallBackLength)"

                        if ($outputText.Length -gt $MaxToolcallBackLength) {
                            $originalLength = $outputText.Length
                            $trimMessage = "TRIMMED OUTPUT (check parameter use!) invalid json on purpose, AI Agent: don't retry same function without check parameters! >>"
                            $maxContentLength = $MaxToolcallBackLength - $trimMessage.Length

                            Microsoft.PowerShell.Utility\Write-Verbose "Tool '$($toolCall.function.name)' MaxToolcallBackLength: $MaxToolcallBackLength, trimMessage.Length: $($trimMessage.Length), maxContentLength: $maxContentLength"

                            # Handle output trimming with proper length validation
                            if ($maxContentLength -le 0) {
                                Microsoft.PowerShell.Utility\Write-Warning "MaxToolcallBackLength ($MaxToolcallBackLength) is too small for trim message ($($trimMessage.Length) chars)"
                                $outputText = "Output too large to display"
                            }
                            else {
                                $outputText = $trimMessage + $outputText.Substring(0, $maxContentLength)
                            }
                            Microsoft.PowerShell.Utility\Write-Verbose "Tool '$($toolCall.function.name)' output was trimmed from $originalLength to $($outputText.Length) characters"
                        }

                        # Add tool response to history
                        $null = $messages.Add(@{
                                role         = 'tool'
                                name         = $toolCall.function.name
                                content      = $outputText
                                content_type = $invocationResult.OutputType
                                tool_call_id = $toolCall.id
                                id           = $toolCall.id
                                arguments    = $toolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json
                            })
                    }
                    else {
                        # For structured output, serialize with smart depth reduction
                        try {
                            # Start with the specified depth and progressively reduce if too long
                            $targetDepth = $invocationResult.ExposedCmdLet.JsonDepth ?? 10
                            $parsedOutput = $null
                            $finalDepth = $targetDepth

                            # Try progressively smaller depths until it fits or we reach minimum depth of 2
                            $foundValidDepth = $false
                            while ($finalDepth -ge 2) {
                                $parsedOutput = $invocationResult.Output | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth $finalDepth -Compress -ErrorAction SilentlyContinue

                                if ($parsedOutput.Length -le $MaxToolcallBackLength) {
                                    # Found a depth that works
                                    $foundValidDepth = $true
                                    if ($finalDepth -lt $targetDepth) {
                                        Microsoft.PowerShell.Utility\Write-Verbose "Tool '$($toolCall.function.name)' JSON output depth reduced from $targetDepth to $finalDepth to fit within $MaxToolcallBackLength characters"
                                    }
                                    break
                                }
                                $finalDepth--
                            }

                            # If we found a depth that works, use it
                            if ($foundValidDepth) {
                                $content = $parsedOutput
                            }
                            else {
                                # If even depth 2 is too long, trim the output
                                $originalLength = $parsedOutput.Length
                                $trimMessage = "TRIMMED JSON OUTPUT (check parameter use!) incomplete json data, AI Agent: don't retry same function without checking parameters! >>"
                                $maxContentLength = $MaxToolcallBackLength - $trimMessage.Length
                                Microsoft.PowerShell.Utility\Write-Verbose "Tool '$($toolCall.function.name)' JSON MaxToolcallBackLength: $MaxToolcallBackLength, trimMessage.Length: $($trimMessage.Length), maxContentLength: $maxContentLength"

                                if ($maxContentLength -le 0) {
                                    Microsoft.PowerShell.Utility\Write-Warning "MaxToolcallBackLength ($MaxToolcallBackLength) is too small for JSON trim message ($($trimMessage.Length) chars)"
                                    $content = "JSON output too large to display"
                                }
                                else {
                                    $content = $trimMessage + $parsedOutput.Substring(0, $maxContentLength)
                                }
                                Microsoft.PowerShell.Utility\Write-Verbose "Tool '$($toolCall.function.name)' JSON output was trimmed from $originalLength to $($content.Length) characters (even at minimum depth 2)"
                            }
                        }
                        catch {
                            # If JSON conversion fails, fall back to text with trimming
                            $outputText = "$($invocationResult.Output)".Trim()
                            if ($outputText.Length -gt $MaxToolcallBackLength) {
                                $originalLength = $outputText.Length
                                $trimMessage = "TRIMMED OUTPUT (check parameter use!) invalid json on purpose, AI Agent: don't retry same function without check parameters! >>"
                                $maxContentLength = $MaxToolcallBackLength - $trimMessage.Length
                                Microsoft.PowerShell.Utility\Write-Verbose "Tool '$($toolCall.function.name)' fallback MaxToolcallBackLength: $MaxToolcallBackLength, trimMessage.Length: $($trimMessage.Length), maxContentLength: $maxContentLength"

                                if ($maxContentLength -le 0) {
                                    Microsoft.PowerShell.Utility\Write-Warning "MaxToolcallBackLength ($MaxToolcallBackLength) is too small for fallback trim message ($($trimMessage.Length) chars)"
                                    $outputText = "Fallback output too large to display"
                                }
                                else {
                                    $outputText = $trimMessage + $outputText.Substring(0, $maxContentLength)
                                }
                                Microsoft.PowerShell.Utility\Write-Verbose "Tool '$($toolCall.function.name)' fallback output was trimmed from $originalLength to $($outputText.Length) characters"
                            }
                            $content = $outputText
                        }

                        # Add tool response to history
                        $null = $messages.Add(@{
                                role         = 'tool'
                                name         = $toolCall.function.name
                                content      = $content
                                content_type = $invocationResult.OutputType
                                tool_call_id = $toolCall.id
                                id           = $toolCall.id
                                arguments    = $toolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json
                            })
                    }
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose 'Continuing conversation after tool responses'

            if (-not $myPSBoundParameters.ContainsKey('ContinueLast')) {

                $myPSBoundParameters.Add('ContinueLast', $true)
            }
            else {

                $myPSBoundParameters['ContinueLast'] = $true
            }

            if (-not $myPSBoundParameters.ContainsKey('Query')) {

                $myPSBoundParameters.Add('Query', '')
            }
            else {

                $myPSBoundParameters['Query'] = ''
            }

            GenXdev\Invoke-LLMQuery @myPSBoundParameters

            return;
        }

        # Handle regular message content if no tool calls
        [System.Collections.Generic.List[object]] $finalOutput = @()

        foreach ($msg in $response.choices.message) {

            $content = $msg.content

            # Extract and process embedded tool calls
            # Try multiple formats that LLMs might use for tool function calls

            # Format 1: <tool_call>{...}</tool_call>
            while ($content -match '<tool_call>\s*({[^}]+})\s*</tool_call>') {
                $toolCallJson = $matches[1]
                try {
                    # parse the json into a tool call object
                    $toolCall = $toolCallJson |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
                        GenXdev\ConvertTo-HashTable

                    # verify this has the expected properties for a function call
                    if ($toolCall.function -and $toolCall.function.name) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Tool call detected (Format 1): $($toolCall.function.name)"

                        # invoke the command from the tool call
                        [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = GenXdev\Invoke-CommandFromToolCall `
                            -ToolCall:$toolCall `
                            -Functions:$Functions `
                            -ExposedCmdLets:$ExposedCmdLets `
                            -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames |
                            Microsoft.PowerShell.Utility\Select-Object -First 1

                        # create replacement text with the function result
                        $replacement = "**Function Call Result:** $($invocationResult.Output)"

                        # replace the original tool call with the result
                        $content = $content.Replace($matches[0], $replacement)
                    }
                }
                catch {
                    # if we can't process it, replace with error message
                    $content = $content.Replace($matches[0], "Error processing tool call: $($_.Exception.Message)")
                }
            }

            # Format 2: [FUNCTION_CALL]{...}[/FUNCTION_CALL]
            while ($content -match '\[FUNCTION_CALL\]\s*({[^}]+})\s*\[/FUNCTION_CALL\]') {
                $toolCallJson = $matches[1]
                try {
                    # parse the json into a tool call object
                    $toolCall = $toolCallJson |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
                        GenXdev\ConvertTo-HashTable

                    # verify this has the expected properties for a function call
                    if ($toolCall.function -and $toolCall.function.name) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Tool call detected (Format 2): $($toolCall.function.name)"

                        # invoke the command from the tool call
                        [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = GenXdev\Invoke-CommandFromToolCall `
                            -ToolCall:$toolCall `
                            -Functions:$Functions `
                            -ExposedCmdLets:$ExposedCmdLets `
                            -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames |
                            Microsoft.PowerShell.Utility\Select-Object -First 1

                        # create replacement text with the function result
                        $replacement = "**Function Call Result:** $($invocationResult.Output)"

                        # replace the original tool call with the result
                        $content = $content.Replace($matches[0], $replacement)
                    }
                }
                catch {
                    # if we can't process it, replace with error message
                    $content = $content.Replace($matches[0], "Error processing tool call: $($_.Exception.Message)")
                }
            }

            # Format 3: <function>{...}</function>
            while ($content -match '<function>\s*({[^}]+})\s*</function>') {
                $toolCallJson = $matches[1]
                try {
                    # parse the json into a tool call object
                    $toolCall = $toolCallJson |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
                        GenXdev\ConvertTo-HashTable

                    # verify this has the expected properties for a function call
                    if ($toolCall.function -and $toolCall.function.name) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Tool call detected (Format 3): $($toolCall.function.name)"

                        # invoke the command from the tool call
                        [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = GenXdev\Invoke-CommandFromToolCall `
                            -ToolCall:$toolCall `
                            -Functions:$Functions `
                            -ExposedCmdLets:$ExposedCmdLets `
                            -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames |
                            Microsoft.PowerShell.Utility\Select-Object -First 1

                        # create replacement text with the function result
                        $replacement = "**Function Call Result:** $($invocationResult.Output)"

                        # replace the original tool call with the result
                        $content = $content.Replace($matches[0], $replacement)
                    }
                }
                catch {
                    # if we can't process it, replace with error message
                    $content = $content.Replace($matches[0], "Error processing tool call: $($_.Exception.Message)")
                }
            }

            # Format 4: Check for code blocks with function calls
            while ($content -match '```(?:json)?\s*({[\s\S]*?"function"[\s\S]*?})\s*```') {
                $potentialJson = $matches[1].Trim()
                try {
                    # Try to parse as a function call
                    $toolCall = $potentialJson |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue -WarningAction SilentlyContinue |
                        GenXdev\ConvertTo-HashTable

                    # Verify this is actually a function call with the expected properties
                    if ($toolCall.function -and $toolCall.function.name) {
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Tool call detected (Format 4): $($toolCall.function.name)")

                        # invoke the command from the tool call
                        [GenXdev.Helpers.ExposedToolCallInvocationResult] $invocationResult = GenXdev\Invoke-CommandFromToolCall `
                            -ToolCall:$toolCall `
                            -Functions:$Functions `
                            -ExposedCmdLets:$ExposedCmdLets `
                            -NoConfirmationToolFunctionNames:$NoConfirmationToolFunctionNames |
                            Microsoft.PowerShell.Utility\Select-Object -First 1

                        # create replacement text with the function result
                        $replacement = "**Function Call Result:** $($invocationResult.Output)"

                        # replace the original tool call with the result
                        $content = $content.Replace($matches[0], $replacement)
                    }
                }
                catch {
                    # not a valid function call, leave it as is
                    # only replace if we're sure it's a function call
                }
            }

            # update chat history with assistant's response
            # convert message to json and back to create a copy
            $messageForHistory = $msg |
                Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -WarningAction SilentlyContinue |
                Microsoft.PowerShell.Utility\ConvertFrom-Json -WarningAction SilentlyContinue

            # decide whether to include thoughts in history based on parameter
            $messageForHistory.content = $DontAddThoughtsToHistory ?
            [regex]::Replace($content, '<think>.*?</think>', '') :
            $content

            # add the message to conversation history
            $null = $messages.Add($messageForHistory)

            # process content if not empty
            if (-not [string]::IsNullOrWhiteSpace($content)) {

                # if including thoughts, add raw content to output
                if ($IncludeThoughts) {
                    $null = $finalOutput.Add($content)
                }

                # extract and process thought content between <think> tags
                $i = $content.IndexOf('<think>')
                if ($i -ge 0) {
                    # skip the opening tag
                    $i += 7
                    $i2 = $content.IndexOf('</think>')
                    if ($i2 -ge 0) {
                        # extract thought content between tags
                        $thoughts = $content.Substring($i, $i2 - $i)
                        Microsoft.PowerShell.Utility\Write-Verbose "LLM Thoughts: $thoughts"

                        # display thoughts if not including them in output
                        if (-not $IncludeThoughts) {
                            Microsoft.PowerShell.Utility\Write-Host $thoughts -ForegroundColor Yellow
                        }

                        # speak thoughts if enabled
                        if ($SpeakThoughts) {
                            $null = GenXdev\Start-TextToSpeech $thoughts
                        }
                    }
                }

                # Remove <think> patterns
                $cleaned = [regex]::Replace($content, '<think>.*?</think>', '')

                # Best-effort JSON extraction (when JSON schema was
                # requested or caller forced it via FilterForJsonOutput).
                # Skipped for plain-text responses to avoid corrupting
                # content.
                if ($expectJsonOutput -or $FilterForJsonOutput) {
                    $getJsonParams = @{
                        Text = $cleaned
                    }
                    if ($responseSchema) {
                        $getJsonParams.ResponseFormat = $responseSchema
                    }
                    $cleaned = GenXdev\Get-LLMJsonOutput @getJsonParams
                }

                Microsoft.PowerShell.Utility\Write-Verbose "LLM Response: $cleaned"

                if ($OutputMarkdownBlocksOnly) {

                    $null = $finalOutput.RemoveAt($finalOutput.Count - 1);

                    $cleaned = "`n$cleaned`n"
                    $i = $cleaned.IndexOf("`n``````");
                    while ($i -ge 0) {

                        $i += 4;
                        $i2 = $cleaned.IndexOf("`n", $i);
                        $name = $cleaned.Substring($i, $i2 - $i).Trim().ToLowerInvariant();

                        $i = $i2 + 1;
                        $i2 = $cleaned.IndexOf("`n``````", $i);
                        if ($i2 -ge 0) {

                            $codeBlock = $cleaned.Substring($i, $i2 - $i);
                            $codeBlock = $json.Trim();
                            if ($name -in $MarkupBlocksTypeFilter) {

                                $null = $finalOutput.Add($codeBlock);
                            }
                        }

                        $i = $cleaned.IndexOf("`n``````", $i2 + 4);
                    }
                }
                else {

                    $null = $finalOutput.Add($cleaned)

                    if ($Speak) {

                        $null = GenXdev\Start-TextToSpeech $cleaned
                    }
                }
            }
        }
        # output all collected results
        $finalOutput | Microsoft.PowerShell.Core\ForEach-Object {

            # write each output object to the pipeline
            Microsoft.PowerShell.Utility\Write-Output $_
        }

        # output verbose information about conversation history update
        Microsoft.PowerShell.Utility\Write-Verbose 'Conversation history updated'
    }

    end {
        Microsoft.PowerShell.Utility\Write-Progress -Completed `
            -Activity 'Invoking LLM Query' `
            -Status 'Completed'
    }
}
###############################################################################