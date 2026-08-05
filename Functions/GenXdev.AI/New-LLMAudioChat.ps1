###############################################################################
<#
.SYNOPSIS
Creates an interactive audio chat session with an LLM model.

.DESCRIPTION
Initiates a voice-based conversation with a language model, supporting audio
input and output. The function handles audio recording, transcription, model
queries, and text-to-speech responses. Supports multiple language models and
various configuration options including window management, GPU acceleration,
and advanced audio processing features.

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
Initial text query to send to the model. Can be empty to start with voice
input.

.PARAMETER Instructions
System instructions/prompt to guide the model's behavior.

.PARAMETER Attachments
Array of file paths to attach to the conversation for context.

.PARAMETER AudioTemperature
Temperature setting for audio input recognition. Range: 0.0-1.0. Default: 0.0

.PARAMETER Temperature
Temperature for response randomness. Range: 0.0-1.0. Default: 0.2

.PARAMETER TemperatureResponse
Temperature for controlling response randomness. Range: 0.0-1.0. Default: 0.01

.PARAMETER LanguageIn
Language to detect in audio input. Default: "English"

.PARAMETER CpuThreads
Number of CPU threads to use. 0=auto. Default: 0

.PARAMETER SuppressRegex
Regex pattern to suppress tokens from output.

.PARAMETER AudioContextSize
Size of the audio context window.

.PARAMETER SilenceThreshold
Silence detect threshold (0..32767 defaults to 30)

.PARAMETER LengthPenalty
Penalty factor for response length. Range: 0-1

.PARAMETER EntropyThreshold
Threshold for entropy in responses. Range: 0-1

.PARAMETER LogProbThreshold
Threshold for log probability in responses. Range: 0-1

.PARAMETER NoSpeechThreshold
Threshold for no-speech detection. Range: 0-1. Default: 0.1

.PARAMETER LLMQueryType
The type of LLM query

.PARAMETER Model
The model identifier or pattern to use for AI operations

.PARAMETER ImageDetail
Image detail level setting. Options: "low", "medium", "high". Default: "low"

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER PromptForSettings
When specified, launches an interactive prompt to configure the LLM settings

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations

.PARAMETER ResponseFormat
A JSON schema for the requested output format

.PARAMETER MarkupBlocksTypeFilter
Will only output markup blocks of the specified types

.PARAMETER PreferencesDatabasePath
Database path for preference data files

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions available as tools to the model.

.PARAMETER IncludeThoughts
Switch to include model's thought process in output.

.PARAMETER DontAddThoughtsToHistory
Switch to include model's thoughts in output

.PARAMETER ContinueLast
Switch to continue from last conversation context.

.PARAMETER DontSpeak
Switch to disable text-to-speech for AI responses.

.PARAMETER DontSpeakThoughts
Switch to disable text-to-speech for AI thought responses.

.PARAMETER NoVOX
Switch to disable silence detection for automatic recording stop.

.PARAMETER UseDesktopAudioCapture
Switch to use desktop audio capture instead of microphone input.

.PARAMETER NoContext
Switch to disable context usage in conversation.

.PARAMETER WithBeamSearchSamplingStrategy
Switch to enable beam search sampling strategy.

.PARAMETER OnlyResponses
Switch to suppress recognized text in output.

.PARAMETER NoSessionCaching
Switch to disable session caching.

.PARAMETER OutputMarkdownBlocksOnly
Will only output markup block responses

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session

.EXAMPLE
New-LLMAudioChat -Query "Tell me about PowerShell" `
    -Model "qwen2.5-14b-instruct" `
    -Temperature 0.7

.EXAMPLE
llmaudiochat "What's the weather?" -DontSpeak
#>
###############################################################################
function New-LLMAudioChat {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('llmaudiochat')]

    param(
        #######################################################################
        [Parameter(
            ValueFromPipeline = $true,
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Initial query text to send to the model'
        )]
        [AllowEmptyString()]
        [string] $Query = '',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
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
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whisper model type to use, defaults to LargeV3Turbo'
        )]
        [ValidateSet('Tiny', 'TinyEn', 'Base', 'BaseEn', 'Small', 'SmallEn', 'Medium', 'MediumEn', 'LargeV1', 'LargeV2', 'LargeV3', 'LargeV3Turbo')]
        [string] $ModelType = 'SmallEn',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for audio input recognition (0.0-1.0)'
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $AudioTemperature = 0.5,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The temperature parameter for controlling the ' +
                'randomness of the response.')
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $TemperatureResponse = 0.01,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sets the language to detect'
        )]
        [Alias('Language')]
        [ValidateSet(
            'Afrikaans',
            'Akan',
            'Albanian',
            'Amharic',
            'Arabic',
            'Armenian',
            'Azerbaijani',
            'Basque',
            'Belarusian',
            'Bemba',
            'Bengali',
            'Bihari',
            'Bork, bork, bork!',
            'Bosnian',
            'Breton',
            'Bulgarian',
            'Cambodian',
            'Catalan',
            'Cherokee',
            'Chichewa',
            'Chinese (Simplified)',
            'Chinese (Traditional)',
            'Corsican',
            'Croatian',
            'Czech',
            'Danish',
            'Dutch',
            'Elmer Fudd',
            'English',
            'Esperanto',
            'Estonian',
            'Ewe',
            'Faroese',
            'Filipino',
            'Finnish',
            'French',
            'Frisian',
            'Ga',
            'Galician',
            'Georgian',
            'German',
            'Greek',
            'Guarani',
            'Gujarati',
            'Hacker',
            'Haitian Creole',
            'Hausa',
            'Hawaiian',
            'Hebrew',
            'Hindi',
            'Hungarian',
            'Icelandic',
            'Igbo',
            'Indonesian',
            'Interlingua',
            'Irish',
            'Italian',
            'Japanese',
            'Javanese',
            'Kannada',
            'Kazakh',
            'Kinyarwanda',
            'Kirundi',
            'Klingon',
            'Kongo',
            'Korean',
            'Krio (Sierra Leone)',
            'Kurdish',
            'Kurdish (Soranî)',
            'Kyrgyz',
            'Laothian',
            'Latin',
            'Latvian',
            'Lingala',
            'Lithuanian',
            'Lozi',
            'Luganda',
            'Luo',
            'Macedonian',
            'Malagasy',
            'Malay',
            'Malayalam',
            'Maltese',
            'Maori',
            'Marathi',
            'Mauritian Creole',
            'Moldavian',
            'Mongolian',
            'Montenegrin',
            'Nepali',
            'Nigerian Pidgin',
            'Northern Sotho',
            'Norwegian',
            'Norwegian (Nynorsk)',
            'Occitan',
            'Oriya',
            'Oromo',
            'Pashto',
            'Persian',
            'Pirate',
            'Polish',
            'Portuguese (Brazil)',
            'Portuguese (Portugal)',
            'Punjabi',
            'Quechua',
            'Romanian',
            'Romansh',
            'Runyakitara',
            'Russian',
            'Scots Gaelic',
            'Serbian',
            'Serbo-Croatian',
            'Sesotho',
            'Setswana',
            'Seychellois Creole',
            'Shona',
            'Sindhi',
            'Sinhalese',
            'Slovak',
            'Slovenian',
            'Somali',
            'Spanish',
            'Spanish (Latin American)',
            'Sundanese',
            'Swahili',
            'Swedish',
            'Tajik',
            'Tamil',
            'Tatar',
            'Telugu',
            'Thai',
            'Tigrinya',
            'Tonga',
            'Tshiluba',
            'Tumbuka',
            'Turkish',
            'Turkmen',
            'Twi',
            'Uighur',
            'Ukrainian',
            'Urdu',
            'Uzbek',
            'Vietnamese',
            'Welsh',
            'Wolof',
            'Xhosa',
            'Yiddish',
            'Yoruba',
            'Zulu'
        )]
        [string] $LanguageIn,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Number of CPU threads to use, defaults to 0 ' +
                '(auto)')
        )]
        [int] $CpuThreads = 0,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regex to suppress tokens from the output'
        )]
        [string] $SuppressRegex = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Size of the audio context'
        )]
        [int] $AudioContextSize,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Silence detect threshold (0..32767 defaults ' +
                'to 30)')
        )]
        [ValidateRange(0, 32767)]
        [int] $SilenceThreshold = 30,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty'
        )]
        [ValidateRange(0, 1)]
        [float] $LengthPenalty,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold'
        )]
        [ValidateRange(0, 1)]
        [float] $EntropyThreshold,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold'
        )]
        [ValidateRange(0, 1)]
        [float] $LogProbThreshold,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold'
        )]
        [ValidateRange(0, 1)]
        [float] $NoSpeechThreshold,
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
            HelpMessage = ('The model identifier or pattern to use for AI ' +
                'operations')
        )]
        [string] $Model,
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
            HelpMessage = ('A JSON schema for the requested output format')
        )]
        [string] $ResponseFormat = $null,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will only output markup blocks of the ' +
                'specified types')
        )]
        [ValidateNotNull()]
        [string[]] $MarkupBlocksTypeFilter = @(
            'json',
            'powershell',
            'C#',
            'python',
            'javascript',
            'typescript',
            'html',
            'css',
            'yaml',
            'xml',
            'bash'
        ),
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
            HelpMessage = ('Array of PowerShell command definitions to use ' +
                'as tools')
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'ScriptBlock array of tool functions to expose to the LLM (pass-through to Invoke-LLMQuery)'
        )]
        [ScriptBlock[]] $Functions,
        ###############################################################################
        [Alias('NoConfirmationFor')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of tool function names that do not require confirmation (pass-through to Invoke-LLMQuery)'
        )]
        [string[]] $NoConfirmationToolFunctionNames,
        ###############################################################################
        [Alias('chat')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Chat mode for LLM query (pass-through to Invoke-LLMQuery)'
        )]
        [string] $ChatMode,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum tool call back length (pass-through to Invoke-LLMQuery)'
        )]
        [int] $MaxToolcallBackLength,
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
            HelpMessage = 'Disable text-to-speech for AI responses'
        )]
        [switch] $DontSpeak,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable text-to-speech for AI thought responses'
        )]
        [switch] $DontSpeakThoughts,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Don't use silence detection to automatically " +
                'stop recording.')
        )]
        [switch] $NoVOX,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Whether to use desktop audio capture instead ' +
                'of microphone input')
        )]
        [switch] $UseDesktopAudioCapture,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio device name or GUID (supports wildcards, picks first match)'
        )]
        [string] $AudioDevice,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Use both desktop and recording device"
        )]
        [switch] $UseDesktopAndRecordingDevice,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't use context"
        )]
        [switch] $NoContext,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use beam search sampling strategy'
        )]
        [switch] $WithBeamSearchSamplingStrategy,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Whether to suppress reconized text in the ' +
                'output')
        )]
        [switch] $OnlyResponses,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will only output markup block responses'
        )]
        [switch] $OutputMarkdownBlocksOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session ' +
                'for AI preferences')
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session ' +
                'for AI preferences')
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences ' +
                'without affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
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

        # initialize stopping flag for chat loop
        $stopping = $false

        Microsoft.PowerShell.Utility\Write-Verbose (
            'Starting new audio LLM chat session')

        # handle exposed cmdlets configuration
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Configuring exposed cmdlets...')

        if ($null -eq $ExposedCmdLets) {

            # check if continuing last session with cached cmdlets
            if ($ContinueLast -and $Global:LLMGlobalExposedCmdlets) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Using existing exposed cmdlets from last session')

                $ExposedCmdLets = $Global:LLMGlobalExposedCmdlets
            }
            else {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Initializing default exposed cmdlets')

                # initialize default allowed PowerShell cmdlets
                $ExposedCmdLets = @(
                    @{
                        Name          = 'Get-ChildItem'
                        AllowedParams = @(
                            'Path=string',
                            'Recurse=boolean',
                            'Filter=array',
                            'Include=array',
                            'Exclude=array',
                            'Force'
                        )
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 3
                    },
                    @{
                        Name          = 'Find-Item'
                        AllowedParams = @('SearchMask', 'Pattern', 'PassThru')
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 3
                    },
                    @{
                        Name          = 'Get-Content'
                        AllowedParams = @('Path=string')
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 2
                    },
                    @{
                        Name          = 'Approve-NewTextFileContent'
                        AllowedParams = @('ContentPath', 'NewContent')
                        OutputText    = $false
                        Confirm       = $true
                        JsonDepth     = 2
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
                        Name          = 'Invoke-RestMethod'
                        AllowedParams = @(
                            'Uri=string',
                            'Method=string',
                            'Body',
                            'ContentType=string',
                            'Method=string',
                            'UserAgent=string'
                        )
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    },
                    @{
                        Name       = 'UTCNow'
                        OutputText = $true
                        Confirm    = $false
                    },
                    @{
                        Name          = 'Invoke-LLMQuery'
                        AllowedParams = @(
                            'Query',
                            'Model',
                            'Instructions',
                            'Attachments',
                            'IncludeThoughts'
                        )
                        ForcedParams  = @(
                            @{
                                Name  = 'NoSessionCaching';
                                Value = $true
                            }
                        )
                        OutputText    = $false
                        Confirm       = $false
                        JsonDepth     = 99
                    }
                )
            }
        }

        # cache exposed cmdlets if session caching is enabled
        if (-not $NoSessionCaching) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Caching exposed cmdlets for future sessions')

            $Global:LLMGlobalExposedCmdlets = $ExposedCmdLets
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Successfully initialized with $($ExposedCmdLets.Count) " +
            'exposed cmdlets')

        # ensure required parameters are properly set
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Validating and setting required parameters')

        # ensure required parameters exist
        if (-not $PSBoundParameters.ContainsKey('Model')) {

            $null = $PSBoundParameters.Add('Model', $Model)
        }
        # ensure continue last parameter is available
        if (-not $PSBoundParameters.ContainsKey('ContinueLast')) {

            $null = $PSBoundParameters.Add('ContinueLast', $ContinueLast)
        }

        # remove chat once parameter if present
        if ($PSBoundParameters.ContainsKey('ChatOnce')) {

            $null = $PSBoundParameters.Remove('ChatOnce')
        }

        if ($PSBoundParameters.ContainsKey('PromptForSettings')) {

            $null = $PSBoundParameters.Remove('PromptForSettings')
        }

        # ensure exposed cmdlets parameter is available
        if (-not $PSBoundParameters.ContainsKey('ExposedCmdLets')) {

            $null = $PSBoundParameters.Add('ExposedCmdLets', $ExposedCmdLets);
        }

        # track if we had an initial query
        $hadAQuery = -not [string]::IsNullOrEmpty($Query)
    }

    process {

        # set recognized text to initial query value
        [string] $recognizedText = $Query

        # main chat loop - continue until user stops
        while (-not $stopping) {

            # handle initial query vs subsequent voice input
            if ($hadAQuery) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing initial query: $Query")

                # check if we should process the initial query
                if ($PSCmdlet.ShouldProcess(
                        "Process initial query: $Query",
                        'Process Query',
                        'New-LLMAudioChat')) {

                    $hadAQuery = $false
                    $Query = [string]::Empty

                    # remove query parameter to prevent reuse
                    if ($PSBoundParameters.ContainsKey('Query')) {

                        $null = $PSBoundParameters.Remove('Query')
                    }
                }
            }
            else {

                # display appropriate message based on VOX setting
                if ($NoVOX) {
                    Microsoft.PowerShell.Utility\Write-Host (
                        'Press any key to start recording or Q to quit')

                    # wait for key press when VOX is disabled
                    $keyPressed = [Console]::ReadKey($true)
                    if ($keyPressed.Key -eq [ConsoleKey]::Q) {
                        # Q pressed - wait for potential second Q
                        Microsoft.PowerShell.Utility\Write-Host 'Q pressed - press Q again within 1000ms to quit...'

                        $startTime = Microsoft.PowerShell.Utility\Get-Date
                        $waitForSecondQ = $true

                        while ($waitForSecondQ -and ((Microsoft.PowerShell.Utility\Get-Date) - $startTime).TotalMilliseconds -lt 1000) {
                            if ([Console]::KeyAvailable) {
                                $secondKey = [Console]::ReadKey($true)
                                if ($secondKey.Key -eq [ConsoleKey]::Q) {
                                    Microsoft.PowerShell.Utility\Write-Host 'Double Q detected - exiting audio chat'
                                    $stopping = $true
                                    while ([Console]::KeyAvailable) { [Console]::ReadKey($true) | Microsoft.PowerShell.Core\Out-Null }
                                    return
                                }
                                else {
                                    $waitForSecondQ = $false
                                    break
                                }
                            }
                            Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 10
                        }

                        if ($waitForSecondQ) {
                            Microsoft.PowerShell.Utility\Write-Host 'No second Q detected - continuing to recording'
                        }
                    }
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Host (
                        'Start speaking (voice activated) or press Q twice to quit')

                    # brief check for immediate Q press to quit before starting VOX
                    if ([Console]::KeyAvailable) {
                        $keyPressed = [Console]::ReadKey($true)
                        if ($keyPressed.Key -eq [ConsoleKey]::Q) {
                            # Q pressed - wait for potential second Q
                            Microsoft.PowerShell.Utility\Write-Host 'Q pressed - press Q again within 1000ms to quit...'

                            $startTime = Microsoft.PowerShell.Utility\Get-Date
                            $waitForSecondQ = $true

                            while ($waitForSecondQ -and ((Microsoft.PowerShell.Utility\Get-Date) - $startTime).TotalMilliseconds -lt 1000) {
                                if ([Console]::KeyAvailable) {
                                    $secondKey = [Console]::ReadKey($true)
                                    if ($secondKey.Key -eq [ConsoleKey]::Q) {
                                        Microsoft.PowerShell.Utility\Write-Host 'Double Q detected - exiting audio chat'
                                        $stopping = $true
                                        while ([Console]::KeyAvailable) { [Console]::ReadKey($true) | Microsoft.PowerShell.Core\Out-Null }
                                        return
                                    }
                                    else {
                                        $waitForSecondQ = $false
                                        break
                                    }
                                }
                                Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 10
                            }

                            if ($waitForSecondQ) {
                                Microsoft.PowerShell.Utility\Write-Host 'No second Q detected - continuing to recording'
                            }
                        }
                    }
                }

                try {

                    # prepare audio transcription parameters
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Preparing audio transcription parameters')

                    $audioParams = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'GenXdev\Start-AudioTranscription' `
                        -DefaultValues `
                    (Microsoft.PowerShell.Utility\Get-Variable `
                            -Scope Local `
                            -ErrorAction SilentlyContinue)

                    # configure and execute audio recording
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Configuring audio settings')

                    $audioParams.VOX = -not $NoVOX
                    $audioParams.Temperature = $AudioTemperature

                    # process text input or start recording
                    $recognizedText = $Query ? $Query.Trim() : [string]::Empty

                    # start audio recording if no text input provided
                    if ([string]::IsNullOrWhiteSpace($recognizedText)) {

                        Microsoft.PowerShell.Utility\Write-Verbose (
                            'Starting audio recording session')

                        $recognizedText = GenXdev\Start-AudioTranscription @audioParams
                    }
                }
                catch {

                    # handle audio recording errors
                    if ("$PSItem" -notlike '*aborted*') {

                        Microsoft.PowerShell.Utility\Write-Error $PSItem
                    }

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Audio transcription failed or was aborted')

                    $Query = [string]::Empty
                    $recognizedText = [string]::Empty
                    continue
                }
            }

            # process recognized input if not empty
            if (-not [string]::IsNullOrWhiteSpace($recognizedText)) {

                $question = $recognizedText

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing recognized input: $question")

                # prepare llm query parameters
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Preparing LLM parameters')

                $invokeLLMQueryParams = `
                    GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\New-LLMTextChat' `
                    -DefaultValues `
                (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue)

                # configure and execute LLM query
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Configuring LLM query parameters')

                $invokeLLMQueryParams.Query = $question
                $invokeLLMQueryParams.Speak = -not $DontSpeak
                $invokeLLMQueryParams.SpeakThoughts = -not $DontSpeakThoughts
                $invokeLLMQueryParams.ChatOnce = $true

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Executing LLM query')

                # execute the llm query if user confirms
                if ($PSCmdlet.ShouldProcess(
                        "Execute LLM query: $question",
                        'Query LLM',
                        'New-LLMAudioChat')) {

                    # capture and display the LLM response in cyan
                    $response = GenXdev\New-LLMTextChat @invokeLLMQueryParams

                    if (-not [string]::IsNullOrWhiteSpace($response)) {
                        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan $response
                    }
                }

                Microsoft.PowerShell.Utility\Write-Host (
                    'Press any key to interrupt and start recording or Q to quit')
            }
            else {

                Microsoft.PowerShell.Utility\Write-Host (
                    "Too short or only silence recorded`r`n")
            }

            # monitor for key presses during speech output
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Monitoring for key presses during speech output')

            $continueWaiting = $true

            while ($continueWaiting -and (GenXdev\Get-IsSpeaking)) {

                # check for available key presses
                while ([Console]::KeyAvailable) {

                    $key = [Console]::ReadKey().Key
                    [System.Console]::Write("`e[1G`e[2K")

                    # quit if q key pressed
                    if ($key -eq [ConsoleKey]::Q) {

                        GenXdev\Stop-TextToSpeech

                        Microsoft.PowerShell.Utility\Write-Host 'Q pressed - press Q again within 1000ms to quit or any other key to continue...'

                        # wait 200ms for potential second Q press
                        $qPressTime = Microsoft.PowerShell.Utility\Get-Date
                        $waitingForSecondQ = $true

                        while ($waitingForSecondQ -and ((Microsoft.PowerShell.Utility\Get-Date) - $qPressTime).TotalMilliseconds -lt 1000) {
                            if ([Console]::KeyAvailable) {
                                $secondKey = [Console]::ReadKey($true)
                                if ($secondKey.Key -eq [ConsoleKey]::Q) {
                                    # double Q pressed - exit completely
                                    Microsoft.PowerShell.Utility\Write-Host 'Double Q detected - exiting audio chat'
                                    Microsoft.PowerShell.Utility\Write-Host '---------------'
                                    $continueWaiting = $false
                                    $stopping = $true
                                    while ([Console]::KeyAvailable) { [Console]::ReadKey($true) | Microsoft.PowerShell.Core\Out-Null }
                                    return
                                }
                                else {
                                    # other key pressed - just continue current loop iteration
                                    Microsoft.PowerShell.Utility\Write-Host 'Continuing...'
                                    $waitingForSecondQ = $false
                                    $continueWaiting = $false
                                    break
                                }
                            }
                            Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 10
                        }

                        # if we reach here without second Q, just continue the current loop iteration
                        if ($waitingForSecondQ) {
                            Microsoft.PowerShell.Utility\Write-Host 'No second Q detected - continuing...'
                        }

                        Microsoft.PowerShell.Utility\Write-Host '---------------'
                        $continueWaiting = $false
                        break
                    }
                    else {

                        $continueWaiting = $false
                        break
                    }
                }

                # wait briefly before checking again
                $null = Microsoft.PowerShell.Utility\Start-Sleep `
                    -Milliseconds 100
            }

            # clear previous prompt
            [System.Console]::Write("`e[1A`e[2K")

            # stop text to speech and show separator
            GenXdev\Stop-TextToSpeech

            Microsoft.PowerShell.Utility\Write-Host '---------------'
        }
    }

    end {

        Microsoft.PowerShell.Utility\Write-Verbose (
            'Audio chat session completed')
    }
}
###############################################################################