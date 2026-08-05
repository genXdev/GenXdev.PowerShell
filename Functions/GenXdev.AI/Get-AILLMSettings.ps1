<#
.SYNOPSIS
Gets the LLM settings for AI operations in GenXdev.AI.

.DESCRIPTION
This function retrieves the LLM (Large Language Model) settings used by the
GenXdev.AI module for various AI operations. Settings are retrieved from
session variables, persistent preferences, or default settings JSON file, in
that order of precedence.

If no settings are found for the requested LLMQueryType, the function
automatically checks whether another LLMQueryType has been manually configured
and falls back to those settings. If no type has ever been configured and the
session is interactive, the user is prompted to select a default provider or
enter settings manually. In non-interactive sessions (e.g., SSH remoting), an
error is thrown with instructions for configuring settings.

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

.PARAMETER LLMQueryType
The type of LLM query to get settings for. This determines which default
settings to use when no custom settings are found. Valid values include
SimpleIntelligence, Knowledge, Pictures, TextTranslation, Coding, and ToolUse.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER NoSupportForJsonSchema
When specified, indicates that the endpoint does not support json_schema
response format. This enables fallback behavior using prompt-based instructions.

.PARAMETER NoSupportForImageUpload
When specified, indicates that the endpoint does not support image upload
functionality.

.PARAMETER NoSupportForToolCalls
When specified, indicates that the endpoint does not support tool calling
functionality.

.PARAMETER PromptForSettings
When specified, launches an interactive prompt to configure the LLM settings

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear the session setting (Global variable) before retrieving.

.PARAMETER SkipSession
When specified, skips session settings and retrieves only from persistent
preferences or defaults. This is useful when you want to ignore any temporary
session-level overrides.

.EXAMPLE
Get-AILLMSettings

Gets the LLM settings for SimpleIntelligence query type (default).

.EXAMPLE
Get-AILLMSettings -LLMQueryType "Coding"

Gets the LLM settings for Coding query type.

.EXAMPLE
Get-AILLMSettings -SkipSession

Gets the LLM settings from preferences or defaults only, ignoring session
settings.

.EXAMPLE
Get-AILLMSettings "Knowledge"

#>
################################################################################
function Get-AILLMSettings {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [OutputType([hashtable])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The type of LLM query to get settings for'
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
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
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
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the endpoint does not support json_schema response format'
        )]
        [switch] $NoSupportForJsonSchema,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the endpoint does not support image upload functionality'
        )]
        [switch] $NoSupportForImageUpload,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether the endpoint does not support tool calling functionality'
        )]
        [switch] $NoSupportForToolCalls,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear the session setting (Global variable) before retrieving'
        )]
        [switch] $ClearSession,
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
            HelpMessage = ('Skip session settings and get from preferences ' +
                'or defaults only')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Launch interactive prompt to configure LLM settings')
        )]
        [switch] $PromptForSettings,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Suppress auto-prompt when ApiKey is missing. ' +
                'Used internally to prevent recursion during display.')
        )]
        [switch] $SuppressAutoPrompt,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force non-interactive mode — forwards to ' +
                'Invoke-AILLMSettingsPrompt when -PromptForSettings is used')
        )]
        [switch] $NonInteractive
        ###############################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose '=== Get-AILLMSettings Started ==='
        Microsoft.PowerShell.Utility\Write-Verbose "LLMQueryType: $LLMQueryType"
        Microsoft.PowerShell.Utility\Write-Verbose "SessionOnly: $SessionOnly"
        Microsoft.PowerShell.Utility\Write-Verbose "SkipSession: $SkipSession"
        Microsoft.PowerShell.Utility\Write-Verbose "ClearSession: $ClearSession"


        if ($PromptForSettings) {

            Microsoft.PowerShell.Utility\Write-Verbose 'PromptForSettings: True'
            $promptParams = GenXdev\Copy-IdenticalParamValues -BoundParameters $PSBoundParameters -FunctionName 'GenXdev\Invoke-AILLMSettingsPrompt'
            GenXdev\Invoke-AILLMSettingsPrompt @promptParams
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose 'PromptForSettings: False'
        }

        # log provided parameter values
        $providedParams = @()
        if ($PSBoundParameters.ContainsKey('Model')) { $providedParams += "Model=$Model" }
        if ($PSBoundParameters.ContainsKey('ApiEndpoint')) { $providedParams += "ApiEndpoint=$ApiEndpoint" }
        if ($PSBoundParameters.ContainsKey('ApiKey')) { $providedParams += 'ApiKey=(redacted)' }
        if ($PSBoundParameters.ContainsKey('NoSupportForJsonSchema')) { $providedParams += "NoSupportForJsonSchema=$NoSupportForJsonSchema" }
        if ($PSBoundParameters.ContainsKey('NoSupportForImageUpload')) { $providedParams += "NoSupportForImageUpload=$NoSupportForImageUpload" }
        if ($PSBoundParameters.ContainsKey('NoSupportForToolCalls')) { $providedParams += "NoSupportForToolCalls=$NoSupportForToolCalls" }

        if ($providedParams.Count -gt 0) {
            Microsoft.PowerShell.Utility\Write-Verbose "Provided parameters: $($providedParams -join ', ')"
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose 'No explicit parameter values provided'
        }

        # handle clearing session variables first if requested
        if ($ClearSession) {

            # clear all global session variables for llm settings
            # These variables are used dynamically via Get-Variable, so suppress PSScriptAnalyzer warnings

            Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_Model') -Value $null -Scope Global

            Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_ApiEndpoint') -Value $null -Scope Global

            Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_ApiKey') -Value $null -Scope Global

            Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_NoSupportForJsonSchema') -Value $null -Scope Global

            Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_NoSupportForImageUpload') -Value $null -Scope Global

            Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_NoSupportForToolCalls') -Value $null -Scope Global

            # inform user that session variables have been cleared
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Cleared session LLM settings for all properties'
            )
        }

        # initialize the result hashtable with all possible setting properties
        $result = @{
            Model                     = $null
            ApiEndpoint               = $null
            ApiKey                    = $null
            NoSupportForJsonSchema    = $null
            NoSupportForImageUpload   = $null
            NoSupportForToolCalls     = $null
        }

        # build splatted params for Get-GenXdevPreference to forward
        # PreferencesDatabasePath, SessionOnly, SkipSession etc.
        $getPrefParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-GenXdevPreference'

        # internal helper: finds any LLMQueryType that has been manually configured
        function Get-AnyConfiguredLLMQueryType {
            param(
                [string]$PreferencesDatabasePath
            )
            $allTypes = @(
                'SimpleIntelligence',
                'Knowledge',
                'Pictures',
                'TextTranslation',
                'Coding',
                'ToolUse'
            )
            foreach ($type in $allTypes) {
                $key = "AILLMSettings_${type}_ManuallyConfigured"
                try {
                    $isConfigured = GenXdev\Get-GenXdevPreference @getPrefParams `
                        -Name $key `
                        -ErrorAction SilentlyContinue
                    if ($isConfigured -eq $true -or $isConfigured -eq 'True') {
                        Microsoft.PowerShell.Utility\Write-Verbose "Found manually configured type: ${type}"
                        return $type
                    }
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Verbose "Error checking ${type}: $($_.Exception.Message)"
                }
            }
            Microsoft.PowerShell.Utility\Write-Verbose 'No manually configured LLMQueryType found'
            return $null
        }
    }

    process {

        # define helper function to retrieve individual setting values
        function Get-SettingValue {

            param(
                [string]$propertyName,
                [object]$parameterValue,
                [bool]$parameterExplicitlyProvided,
                [string]$llmQueryType,
                [switch]$sessionOnly,
                [switch]$skipSession,
                [hashtable]$defaultConfig
            )

            # check if parameter was explicitly provided and has a meaningful value
            if ($parameterExplicitlyProvided) {
                # for string parameters, check if the value is meaningful (not null/empty/whitespace)
                $isStringParam = $propertyName -in @('Model', 'ApiEndpoint', 'ApiKey')
                if ($isStringParam) {
                    if (-not [String]::IsNullOrWhiteSpace($parameterValue)) {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Using explicitly provided parameter value: $parameterValue"
                        return $parameterValue
                    } else {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Parameter explicitly provided but is null/empty, checking other sources..."
                    }
                } else {
                    # for numeric parameters, check if not null and not zero
                    if ($null -ne $parameterValue -and $parameterValue -ne 0) {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Using explicitly provided parameter value: $parameterValue"
                        return $parameterValue
                    } else {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Parameter explicitly provided but is null/zero, checking other sources..."
                    }
                }
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] No parameter value provided, checking other sources..."
            }

            # check session variables unless SkipSession is specified
            if (-not $skipSession) {

                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Checking session variables..."

                # construct session variable name
                $sessionVarName = "AILLMSettings_$($llmQueryType)_$propertyName"

                # attempt to retrieve session variable value
                if (Microsoft.PowerShell.Utility\Get-Variable `
                        -Name $sessionVarName `
                        -Scope Global `
                        -ErrorAction SilentlyContinue) {

                    # get the actual variable value
                    $sessionValue = (Microsoft.PowerShell.Utility\Get-Variable `
                            -Name $sessionVarName `
                            -Scope Global).Value

                    # return session value if it exists and is not empty
                    if ($null -ne $sessionValue -and $sessionValue -ne '') {
                        # Normalize NoSupportFor* switch values: legacy
                        # session variables may hold "True"/"False" strings.
                        if ($propertyName -like 'NoSupportFor*' -and
                            $sessionValue -is [string]) {
                            $sessionValue = $sessionValue -eq 'True'
                        }
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Found session value: $sessionValue"
                        return $sessionValue
                    } else {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Session variable exists but is null/empty"
                    }
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] No session variable found: $sessionVarName"
                }
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Skipping session variables (SkipSession=true)"
            }

            # return null if SessionOnly is specified and no session value found
            if ($sessionOnly) {
                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] SessionOnly=true and no session value found, returning null"
                return $null
            }

            # check preference storage unless SessionOnly is specified
            if (-not $sessionOnly) {

                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Checking preference storage..."

                try {
                    # construct preference key using query type and property name
                    $preferenceKey = "AILLMSettings_$($llmQueryType)_$propertyName"

                    # attempt to retrieve preference value
                    $preferenceValue = GenXdev\Get-GenXdevPreference @getPrefParams `
                        -Name $preferenceKey `
                        -ErrorAction SilentlyContinue

                    # return preference value if it exists and is not empty
                    if ($null -ne $preferenceValue -and $preferenceValue -ne '') {
                        # Normalize NoSupportFor* switch values: legacy
                        # preferences may have stored "True"/"False" as
                        # strings (from when these were [string] params).
                        if ($propertyName -like 'NoSupportFor*' -and
                            $preferenceValue -is [string]) {
                            $preferenceValue = $preferenceValue -eq 'True'
                        }
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Found preference value: $preferenceValue"
                        return $preferenceValue
                    } else {
                        Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] No preference value found for key: $preferenceKey"
                    }
                }
                catch {
                    # preference not found, continue to defaults
                    Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Error accessing preferences: $($_.Exception.Message)"
                }

                # use the auto-selected default configuration if available
                if ($null -ne $defaultConfig -and $defaultConfig.ContainsKey($propertyName)) {
                    $finalValue = $defaultConfig[$propertyName]
                    Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Found in auto-selected default configuration: $finalValue"
                    return $finalValue
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Property not found in auto-selected default configuration"
                }
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] Skipping defaults (SessionOnly=true)"
            }

            Microsoft.PowerShell.Utility\Write-Verbose "[$propertyName] No value found from any source, returning null"
            return $null
        }

        # retrieve each setting value using the helper function or from defaults

        # create parameter hashtable for Get-AIDefaultLLMSettings
        $defaultSettingsParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-AIDefaultLLMSettings'
        # -DefaultValues (Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        Microsoft.PowerShell.Utility\Write-Verbose '=== Using Get-AIDefaultLLMSettings for auto-selection ==='

        $defaultConfig = GenXdev\Get-AIDefaultLLMSettings @defaultSettingsParams

        if ($defaultConfig) {
            # Check if it's an array or a single hashtable
            if ($defaultConfig -is [array] -and $defaultConfig.Count -gt 0) {
                # for Pictures, prefer a provider that supports image upload
                if ($LLMQueryType -eq 'Pictures') {
                    $selectedDefaultConfig = $null
                    foreach ($candidate in $defaultConfig) {
                        $ht = $candidate | GenXdev\ConvertTo-HashTable
                        if ($ht.NoSupportForImageUpload -ne $true) {
                            $selectedDefaultConfig = $ht
                            Microsoft.PowerShell.Utility\Write-Verbose 'Auto-selected default configuration with image upload support'
                            break
                        }
                    }
                    if ($null -eq $selectedDefaultConfig) {
                        # fallback to first if none supports images
                        $selectedDefaultConfig = $defaultConfig[0] | GenXdev\ConvertTo-HashTable
                        Microsoft.PowerShell.Utility\Write-Verbose 'No image-upload-capable provider found, using first available'
                    }
                } else {
                    $selectedDefaultConfig = $defaultConfig[0] | GenXdev\ConvertTo-HashTable
                    Microsoft.PowerShell.Utility\Write-Verbose 'Auto-selected default configuration found (from array)'
                }
            } elseif ($defaultConfig -is [hashtable]) {
                # Single hashtable returned
                $selectedDefaultConfig = $defaultConfig
                Microsoft.PowerShell.Utility\Write-Verbose 'Auto-selected default configuration found (single hashtable)'
            } else {
                $selectedDefaultConfig = $null
                Microsoft.PowerShell.Utility\Write-Verbose "Default configuration has unexpected type: $($defaultConfig.GetType().FullName)"
            }
        } else {
            $selectedDefaultConfig = $null
            Microsoft.PowerShell.Utility\Write-Verbose 'No suitable default configuration found'
        }

        # Debug: Log the structure of the selected default configuration
        if ($null -ne $selectedDefaultConfig) {
            Microsoft.PowerShell.Utility\Write-Verbose '=== DEBUG: Selected Default Configuration ==='
            if ($selectedDefaultConfig -is [hashtable]) {
                Microsoft.PowerShell.Utility\Write-Verbose "Configuration is a hashtable with keys: $($selectedDefaultConfig.Keys -join ', ')"
                foreach ($key in $selectedDefaultConfig.Keys) {
                    $value = if ($null -eq $selectedDefaultConfig[$key]) { '(null)' } else { $selectedDefaultConfig[$key] }
                    Microsoft.PowerShell.Utility\Write-Verbose "  $key = $value"
                }
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose "Configuration type: $($selectedDefaultConfig.GetType().FullName)"
            }
            Microsoft.PowerShell.Utility\Write-Verbose '=== END DEBUG ==='
        }

        # for each property, use the priority: parameter > session > preferences > auto-selected default
        foreach ($propertyName in @('Model', 'ApiEndpoint', 'ApiKey', 'NoSupportForJsonSchema', 'NoSupportForImageUpload', 'NoSupportForToolCalls')) {

            $parameterValue = $null
            $parameterExplicitlyProvided = $false
            switch ($propertyName) {
                'Model' {
                    $parameterValue = $Model
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('Model')
                }
                'ApiEndpoint' {
                    $parameterValue = $ApiEndpoint
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('ApiEndpoint')
                }
                'ApiKey' {
                    $parameterValue = $ApiKey
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('ApiKey')
                }
                'NoSupportForJsonSchema' {
                    $parameterValue = $NoSupportForJsonSchema
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('NoSupportForJsonSchema')
                }
                'NoSupportForImageUpload' {
                    $parameterValue = $NoSupportForImageUpload
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('NoSupportForImageUpload')
                }
                'NoSupportForToolCalls' {
                    $parameterValue = $NoSupportForToolCalls
                    $parameterExplicitlyProvided = $PSBoundParameters.ContainsKey('NoSupportForToolCalls')
                }
            }

            # get the final value using priority logic
            $finalValue = Get-SettingValue `
                -propertyName $propertyName `
                -parameterValue $parameterValue `
                -parameterExplicitlyProvided $parameterExplicitlyProvided `
                -llmQueryType $LLMQueryType `
                -sessionOnly:$SessionOnly `
                -skipSession:$SkipSession `
                -defaultConfig $selectedDefaultConfig

            $result[$propertyName] = $finalValue
        }

        # check if ApiKey is missing — either nothing configured, or defaults
        # gave model/endpoint but no key to actually make API calls
        $missingKey = ($null -eq $result.ApiKey)

        if ($missingKey -and -not $SessionOnly -and -not $SkipSession -and -not $SuppressAutoPrompt) {
            # try cross-type fallback whenever ApiKey is missing
            Microsoft.PowerShell.Utility\Write-Verbose 'ApiKey missing, checking cross-type fallback...'

            $configuredType = Get-AnyConfiguredLLMQueryType `
                -PreferencesDatabasePath $PreferencesDatabasePath

            if ($null -ne $configuredType) {
                Microsoft.PowerShell.Utility\Write-Verbose "Falling back to configured type: ${configuredType}"
                $fallbackParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\Get-AILLMSettings'
                $result = GenXdev\Get-AILLMSettings @fallbackParams `
                    -LLMQueryType $configuredType
            }

            # if ApiKey is still null after potential fallback, try interactive
            if (($null -eq $result.ApiKey) -and [Environment]::UserInteractive) {
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'No ApiKey configured, delegating to Set-AILLMSettings -PromptForSettings...'
                )

                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType $LLMQueryType `
                    -PreferencesDatabasePath $PreferencesDatabasePath

                # re-resolve settings now that they've been saved
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Re-resolving settings after interactive setup...'
                )
                $reResolveParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\Get-AILLMSettings'
                $result = GenXdev\Get-AILLMSettings @reResolveParams
            }
            elseif ($null -eq $result.ApiKey) {
                # non-interactive session with no settings — throw clear error
                throw ('No LLM settings have been configured. Run ' +
                    'Set-AILLMSettings -LLMQueryType "SimpleIntelligence" ' +
                    '-ApiEndpoint "<endpoint>" -ApiKey "<key>" ' +
                    '-Model "<model>" to configure, or run ' +
                    'Get-AILLMSettings interactively for guided setup.')
            }
        }
    }

    end {

        # log final result summary
        Microsoft.PowerShell.Utility\Write-Verbose '=== Final LLM Settings Summary ==='
        Microsoft.PowerShell.Utility\Write-Verbose "LLMQueryType: $LLMQueryType"
        foreach ($key in $result.Keys) {
            $value = if ($null -eq $result[$key]) { '(null)' } else { $result[$key] }
            Microsoft.PowerShell.Utility\Write-Verbose "$key = $value"
        }
        Microsoft.PowerShell.Utility\Write-Verbose '=== End Summary ==='
        # return the completed settings hashtable to the caller
        return $result
    }
}
################################################################################