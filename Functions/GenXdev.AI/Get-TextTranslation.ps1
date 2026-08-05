###############################################################################
<#
.SYNOPSIS
Translates text to another language using AI.

.DESCRIPTION
This function translates input text into a specified target language using AI
models. It can accept input directly through parameters, from the pipeline, or
from the system clipboard. The function preserves formatting and style while
translating.

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
The text to translate. Accepts pipeline input. If not provided, reads from system
clipboard.

.PARAMETER Language
Target language for translation. Supports 140+ languages including major world
languages and variants.

.PARAMETER Instructions
Additional instructions to guide the AI model in translation style and context.

.PARAMETER NoDefaultInstructions
When specified, skips the default translation rules and uses only the
caller-provided instructions. Use this when you have custom translation
instructions that should not be combined with the built-in format preservation
rules.

.PARAMETER Temperature
Controls response randomness (0.0-1.0). Lower values are more deterministic.

.PARAMETER LLMQueryType
The type of LLM query to perform for AI operations.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER PromptForSettings
When specified, launches an interactive prompt to configure the LLM settings.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SetClipboard
Copy the translated text to clipboard.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
Get-TextTranslation -Text "Hello world" -Language "French" -Model "qwen"

.EXAMPLE
"Bonjour" | translate -Language "English"
#>
function Get-TextTranslation {

    [CmdletBinding()]
    [OutputType([System.String])]
    [Alias('translate')]
    param (
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            ValueFromPipeline = $true,
            HelpMessage = 'The text to translate'
        )]
        [ValidateNotNull()]
        [string] $Text,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('Additional instructions to guide the AI model in ' +
                'translation style and context')
        )]
        [string] $Instructions,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip the default translation rules and use only ' +
                'the caller-provided instructions. Use this when you have ' +
                'custom translation instructions that should not be combined ' +
                'with the built-in format preservation rules.')
        )]
        [switch] $NoDefaultInstructions,
        ###########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'Array of file paths to attach'
        )]
        [string[]] $Attachments = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Image detail level'
        )]
        [ValidateSet('low', 'medium', 'high')]
        [string] $ImageDetail = 'low',
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of function definitions'
        )]
        [hashtable[]] $Functions = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Array of PowerShell command definitions to use ' +
                'as tools')
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Array of command names that don't require " +
                'confirmation')
        )]
        [Alias('NoConfirmationFor')]
        [string[]]
        $NoConfirmationToolFunctionNames = @(),
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
        [string] $LLMQueryType = 'TextTranslation',
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
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Copy the enhanced text to clipboard'
        )]
        [switch]$SetClipboard,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $DontAddThoughtsToHistory,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Continue from last conversation'
        )]
        [switch] $ContinueLast,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI responses'
        )]
        [switch] $Speak,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable text-to-speech for AI thought responses'
        )]
        [switch] $SpeakThoughts,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Don't store session in session cache"
        )]
        [switch] $NoSessionCaching,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Allow the use of default AI tools during processing'
        )]
        [switch] $AllowDefaultTools,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for ' +
                'AI preferences')
        )]
        [switch] $ClearSession,
        ###########################################################################
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
            HelpMessage = 'Temperature for audio response randomness (passed to LLM)'
        )]
        [double] $AudioTemperature,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response generation (passed to LLM)'
        )]
        [double] $TemperatureResponse,
        ###############################################################################
        [ValidateSet(
            'ar-SA',
            'bg-BG',
            'bn-IN',
            'ca-ES',
            'cs-CZ',
            'da-DK',
            'de-DE',
            'el-GR',
            'en-US',
            'es-ES',
            'et-EE',
            'fi-FI',
            'fr-FR',
            'gu-IN',
            'he-IL',
            'hi-IN',
            'hr-HR',
            'hu-HU',
            'id-ID',
            'it-IT',
            'ja-JP',
            'kn-IN',
            'ko-KR',
            'lt-LT',
            'lv-LV',
            'ml-IN',
            'mr-IN',
            'ms-MY',
            'nb-NO',
            'nl-NL',
            'pa-IN',
            'pl-PL',
            'pt-BR',
            'ro-RO',
            'ru-RU',
            'sk-SK',
            'sl-SI',
            'sr-RS',
            'sv-SE',
            'ta-IN',
            'te-IN',
            'th-TH',
            'tr-TR',
            'uk-UA',
            'vi-VN',
            'zh-Hans-CN'
        )]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'BCP 47 language tag for translation (e.g., nl-NL, de-DE, en-US)'
        )]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Number of CPU threads to use (passed to LLM)'
        )]
        [int] $CpuThreads,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Regular expression to suppress output (passed to LLM)'
        )]
        [string] $SuppressRegex,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio context size for processing (passed to LLM)'
        )]
        [int] $AudioContextSize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Silence threshold for audio detection (passed to LLM)'
        )]
        [double] $SilenceThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Length penalty for sequence generation (passed to LLM)'
        )]
        [double] $LengthPenalty,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Entropy threshold for output filtering (passed to LLM)'
        )]
        [double] $EntropyThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Log probability threshold for output filtering (passed to LLM)'
        )]
        [double] $LogProbThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'No speech threshold for audio detection (passed to LLM)'
        )]
        [double] $NoSpeechThreshold,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output (passed to LLM)'
        )]
        [switch] $DontSpeak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable speech output for thoughts (passed to LLM)'
        )]
        [switch] $DontSpeakThoughts,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable VOX (voice activation) (passed to LLM)'
        )]
        [switch] $NoVOX,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use desktop audio capture (passed to LLM)'
        )]
        [switch] $UseDesktopAudioCapture,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable context usage (passed to LLM)'
        )]
        [switch] $NoContext,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable beam search sampling strategy (passed to LLM)'
        )]
        [switch] $WithBeamSearchSamplingStrategy,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Return only responses (passed to LLM)'
        )]
        [switch] $OnlyResponses,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Output only markup blocks (passed to LLM)'
        )]
        [switch] $OutputMarkdownBlocksOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter for markup block types (passed to LLM)'
        )]
        [string[]] $MarkupBlocksTypeFilter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip the translation cache; always call the LLM API'
        )]
        [switch] $NoCache,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear the entire translation cache for all languages'
        )]
        [switch] $ClearCache
        ###############################################################################
    )

    begin {

        # Clear cache if requested
        if ($ClearCache) {
            GenXdev\Merge-TranslationCache -ClearCache
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Translation cache cleared.')
            return
        }

        # Load or create in-memory cache (reads per-language files from
        # disk once; subsequent calls return the module-scoped reference)
        $translationCache = if (-not $NoCache) {
            GenXdev\Merge-TranslationCache -GetCache
        }
        else {
            @{}
        }

        # Use $Language directly as BCP 47 code (e.g., 'nl-NL', 'en-US').
        # Default to 'English' if no language specified.
        $language = if ($Language) { $Language } else { 'English' }

        # resolve BCP 47 code to full display name for the LLM prompt
        # (e.g., 'zh-Hans-CN' -> 'Chinese (Simplified, China)')
        $languageDisplayName = if ($language -eq 'English') {
            'English'
        }
        else {
            try {
                [System.Globalization.CultureInfo]::new($language).EnglishName
            }
            catch {
                $language
            }
        }

        # ensure the language key exists in cache
        if (-not $translationCache.ContainsKey($language)) {
            $translationCache[$language] = @{}
        }

        # output verbose information about the translation process
        Microsoft.PowerShell.Utility\Write-Verbose ('Starting translation ' +
            "process to target language: $language")
    }

    process {

        # -- Check translation cache first
        if (-not $NoCache -and $Text) {
            $langCache = $translationCache[$language]
            if ($langCache.ContainsKey($Text)) {
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Translation cache hit for language '${language}'.")
                $cached = $langCache[$Text]
                # trim trailing whitespace/newlines from cached values
                # (old LLM responses may have polluted the cache with \r\n)
                if ($cached -is [string]) {
                    $cached = $cached.TrimEnd()
                    $langCache[$Text] = $cached
                }
                return $cached
            }
        }

        # construct translation instructions
        if ($NoDefaultInstructions) {
            # Caller takes full responsibility for instructions.
            $translationInstructions = if ($Instructions) {
                $Instructions
            }
            else { '' }
        }
        else {
            # Default behavior: combine built-in rules with optional caller
            # instructions for smart format preservation.
            $userInstructions = if ($Instructions) {
                "`nAdditional user instructions: $Instructions"
            }
            else { '' }
            $translationInstructions = (
                "Translate the following text into ${languageDisplayName}. " +
                'You MUST translate ALL human-readable text. ' +
                'Do NOT return the input unchanged. ' +
                'Return ONLY the translated text with no explanations, ' +
                'no JSON wrappers, and no system prompts.' +
                "`n`nIMPORTANT TRANSLATION RULES:" +
                "`n1. If the input contains code, markup, or structured " +
                'data, preserve all syntax, structure, and technical ' +
                'elements like programming keywords, tags, or data format ' +
                'specific elements.' +
                "`n2. Only translate human-readable text portions like " +
                'comments, string values, documentation, or natural ' +
                'language content.' +
                "`n3. Maintain exact formatting, indentation, and line " +
                'breaks.' +
                "`n4. Never translate identifiers, function names, " +
                'variables, or technical keywords.' +
                $userInstructions)
        }

        # output verbose information about translation preparation
        Microsoft.PowerShell.Utility\Write-Verbose 'Preparing translation request'

        # copy matching parameters for invocation
        $invocationParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Invoke-LLMTextTransformation' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        # output verbose information about llm invocation
        Microsoft.PowerShell.Utility\Write-Verbose 'Invoking LLM translation'

        # perform the translation using the llm text transformation function
        $result = GenXdev\Invoke-LLMTextTransformation @invocationParams `
            -Instructions $translationInstructions -ErrorAction Continue

        # trim trailing whitespace/newlines from LLM response
        # use -replace for reliability across PSObject/string types
        $result = [string]$result
        $result = $result -replace '[\r\n\s]+$', ''

        # if LLM returned the input unchanged (no API key, error, etc.),
        # treat as failure and return null rather than echoing back
        if ($result.Length -gt 0 -and $Text -and
            $result -eq $Text.TrimEnd()) {
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Translation returned input unchanged; ' +
                'likely no LLM API key configured.')
            return $null
        }

        # -- Store in translation cache (batched: persists every 100
        #    mutations per language via Merge-TranslationCache)
        # validate translation before caching to avoid storing garbage
        $cacheValid = $true
        if ([string]::IsNullOrWhiteSpace($result)) {
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Skipping cache: translation result is empty.')
            $cacheValid = $false
        }
        elseif ($result -eq $Text) {
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Skipping cache: translation returned input unchanged.')
            $cacheValid = $false
        }
        elseif ($result -match '"json_schema"|"response_format"') {
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Skipping cache: translation appears to contain ' +
                'system prompt leakage.')
            $cacheValid = $false
        }
        if (-not $NoCache -and $Text -and $result -and $cacheValid) {
            GenXdev\Merge-TranslationCache `
                -Language $language `
                -Key $Text `
                -Value $result
        }

        return $result
    }

    end {
    }
}
###############################################################################