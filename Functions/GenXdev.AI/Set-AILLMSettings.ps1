###############################################################################
<#
.SYNOPSIS
Sets the LLM settings for AI operations in GenXdev.AI.

.DESCRIPTION
Configures the LLM (Large Language Model) settings used by the GenXdev.AI
module for various AI operations. Settings can be stored persistently in
preferences (default), only in the current session (using -SessionOnly), or
cleared from the session (using -ClearSession). The function validates that at
least one setting parameter is provided unless clearing session settings.

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
The type of LLM query to set settings for. This determines which configuration
to store or modify. Valid values are SimpleIntelligence, Knowledge, Pictures,
TextTranslation, Coding, and ToolUse.

.PARAMETER Model
The model identifier or pattern to use for AI operations.

.PARAMETER ApiEndpoint
The API endpoint URL for AI operations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER PromptForSettings
When specified, launches an interactive prompt to configure the LLM settings

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

.PARAMETER SessionOnly
When specified, stores the settings only in the current session (Global
variables) without persisting to preferences. Settings will be lost when the
session ends.

.PARAMETER ClearSession
When specified, clears only the session settings (Global variables) without
affecting persistent preferences.

.PARAMETER SkipSession
When specified, stores the settings only in persistent preferences without
affecting the current session settings.

.PARAMETER AllMachines
When specified, also writes the LLM settings to OneDrive for syncing across
multiple machines. This takes effect only for persistent storage (default
mode), not for -SessionOnly or -ClearSession operations.

.EXAMPLE
Set-AILLMSettings -LLMQueryType "Coding" -Model "*Qwen*14B*"

Sets the LLM settings for Coding query type persistently in preferences.

.EXAMPLE
Set-AILLMSettings -LLMQueryType "SimpleIntelligence" -Model "maziyarpanahi/llama-3-groq-8b-tool-use" -SessionOnly

Sets the LLM settings for SimpleIntelligence only for the current
session.

.EXAMPLE
Set-AILLMSettings -LLMQueryType "Pictures" -ClearSession

Clears the session LLM settings for Pictures query type without affecting
persistent preferences.

.EXAMPLE
Set-AILLMSettings "Coding" "*Qwen*14B*"

Sets the LLM settings for Coding query type using positional parameters.

.EXAMPLE
Set-AILLMSettings -LLMQueryType "SimpleIntelligence" -Model "gpt-4o" -ApiEndpoint "https://api.openai.com/v1/chat/completions" -ApiKey "sk-..." -AllMachines

Sets the LLM settings for SimpleIntelligence and syncs to OneDrive for
use across multiple machines.
#>

function Set-AILLMSettings {

    [CmdletBinding(SupportsShouldProcess)]
    [Alias('llmsettings')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
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
        [string] $LLMQueryType,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ###############################################################################
        [Parameter(
            Position = 8,
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
                'preferences')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
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
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Also write LLM settings to OneDrive for syncing ' +
                'across multiple machines')
        )]
        [switch] $AllMachines,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Launch interactive prompt to configure LLM settings')
        )]
        [switch] $PromptForSettings,
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

        # validate that at least one setting parameter is provided unless clearing
        # session or prompting
        if ((-not $ClearSession) -and (-not $PromptForSettings)) {

            # define all settable parameters for validation
            $settingParams = @(
                'Model',
                'ApiEndpoint',
                'ApiKey',
                'NoSupportForJsonSchema',
                'NoSupportForImageUpload',
                'NoSupportForToolCalls'
            )

            # filter to only parameters that were actually provided
            $providedSettings = $settingParams |
                Microsoft.PowerShell.Core\Where-Object {
                    $PSBoundParameters.ContainsKey($_)
                }

            # ensure at least one setting parameter was provided
            if ($providedSettings.Count -eq 0) {

                throw ('At least one LLM setting parameter must be provided ' +
                    'when not using -ClearSession')
            }
        }

        # validate parameter dependencies when not using session-only mode
        if ((-not $SessionOnly) -or ($SkipSession)) {

            # check if api endpoint is provided without api key
            if ($PSBoundParameters.ContainsKey('ApiEndpoint') -and
                -not $PSBoundParameters.ContainsKey('ApiKey')) {

                throw ('ApiKey must be provided when ApiEndpoint is ' +
                    'specified for persistent storage')
            }
        }

        # output informational message about the operation
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Setting LLM settings for query type: $LLMQueryType"
        )
    }

    process {

        # handle interactive prompt mode
        if ($PromptForSettings) {
            if (-not [Environment]::UserInteractive -or $NonInteractive) {
                throw 'Cannot prompt for settings in a non-interactive session'
            }

            # pass through all relevant parameters from the caller
            $promptParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Invoke-AILLMSettingsPrompt'
            GenXdev\Invoke-AILLMSettingsPrompt @promptParams
            return
        }

        # handle clearing session variables when requested
        if ($ClearSession) {

            # create descriptive message for whatif processing
            $clearMessage = 'Clear session LLM settings for all properties (Global variables)'

            # check if user confirmed the operation or whatif mode
            if ($PSCmdlet.ShouldProcess(
                    'GenXdev.AI Module Configuration',
                    $clearMessage
                )) {

                # clear individual session variables for each property
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_Model') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_ApiEndpoint') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_ApiKey') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_NoSupportForJsonSchema') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_NoSupportForImageUpload') -Value $null -Scope Global
                Microsoft.PowerShell.Utility\Set-Variable -Name ('AILLMSettings_' + $LLMQueryType + '_NoSupportForToolCalls') -Value $null -Scope Global

                # output confirmation of the clearing operation
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Cleared session LLM settings for all properties'
                )
            }
            return
        }

        # create hashtable to store only the provided settings
        $settings = @{}

        # define all possible setting parameters for iteration
        $settingParams = @(
            'Model',
            'ApiEndpoint',
            'ApiKey',
            'NoSupportForJsonSchema',
            'NoSupportForImageUpload',
            'NoSupportForToolCalls'
        )

        # iterate through all possible parameters and add provided ones to
        # settings
        $preferencesToRemove = @()
        foreach ($param in $settingParams) {

            # check if this parameter was actually provided by the user
            if ($PSBoundParameters.ContainsKey($param)) {

                # if SessionOnly, allow null values to clear individual session variables
                if ($SessionOnly) {
                    # add the parameter value to our settings hashtable (including null)
                    $settings[$param] = $PSBoundParameters[$param]
                }
                else {
                    # for persistent storage, handle null values by marking for deletion
                    if ($null -eq $PSBoundParameters[$param]) {
                        # mark this preference for deletion
                        $preferenceKey = "AILLMSettings_$($LLMQueryType)_$param"
                        $preferencesToRemove += $preferenceKey
                        Microsoft.PowerShell.Utility\Write-Verbose "Marking preference for deletion: $preferenceKey"
                    }
                    else {
                        # for string parameters, also check that they're not empty
                        $isStringParam = $param -in @('Model', 'ApiEndpoint', 'ApiKey')
                        if ($isStringParam -and [string]::IsNullOrWhiteSpace($PSBoundParameters[$param])) {
                            # mark empty string values for deletion too
                            $preferenceKey = "AILLMSettings_$($LLMQueryType)_$param"
                            $preferencesToRemove += $preferenceKey
                            Microsoft.PowerShell.Utility\Write-Verbose "Marking preference for deletion (empty string): $preferenceKey"
                        }
                        else {
                            # add the parameter value to our settings hashtable
                            $settings[$param] = $PSBoundParameters[$param]
                        }
                    }
                }
            }
        }

        # handle session-only storage when requested
        if ($SessionOnly) {

            # create human-readable description of settings for logging
            $settingsDescription = ($settings.GetEnumerator() |
                    Microsoft.PowerShell.Core\ForEach-Object {
                        "$($_.Key): $($_.Value)"
                    }) -join ', '

            # check if user confirmed the operation or whatif mode
            if ($PSCmdlet.ShouldProcess(
                    'GenXdev.AI Module Configuration',
                ("Set session-only LLM settings: [$settingsDescription]")
                )) {

                # set individual session variables for each provided setting
                foreach ($key in $settings.Keys) {
                    $sessionVarName = "AILLMSettings_$($LLMQueryType)_$key"
                    Microsoft.PowerShell.Utility\Set-Variable `
                        -Name $sessionVarName `
                        -Value $settings[$key] `
                        -Scope Global
                }

                # output confirmation of the session-only storage operation
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Set session-only LLM settings: [$settingsDescription]"
                )
            }
            return
        }

        # handle persistent storage (default behavior)
        # build splatted params to forward PreferencesDatabasePath,
        # SessionOnly, SkipSession etc. to preference cmdlets
        $setPrefParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Set-GenXdevPreference'
        $removePrefParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Remove-GenXdevPreference'

        # create human-readable description of settings for logging
        $settingsDescription = ($settings.GetEnumerator() |
                Microsoft.PowerShell.Core\ForEach-Object {
                    "$($_.Key): $($_.Value)"
                }) -join ', '

        # check if user confirmed the operation or whatif mode
        if ($PSCmdlet.ShouldProcess(
                'GenXdev.AI Module Configuration',
            ("Set LLM settings for ${LLMQueryType}: [$settingsDescription]")
            )) {

            # store each setting individually in preferences
            foreach ($key in $settings.Keys) {
                $preferenceKey = "AILLMSettings_$($LLMQueryType)_$key"
                $null = GenXdev\Set-GenXdevPreference @setPrefParams `
                    -Name $preferenceKey `
                    -Value $settings[$key] `
                    -AllMachines:$AllMachines
            }

            # mark this LLMQueryType as manually configured
            $configuredKey = "AILLMSettings_$($LLMQueryType)_ManuallyConfigured"
            $null = GenXdev\Set-GenXdevPreference @setPrefParams `
                -Name $configuredKey `
                -Value $true `
                -AllMachines:$AllMachines
            Microsoft.PowerShell.Utility\Write-Verbose "Marked ${LLMQueryType} as manually configured"

            # remove preferences that were marked for deletion (null values)
            foreach ($preferenceKey in $preferencesToRemove) {
                try {
                    $null = GenXdev\Remove-GenXdevPreference @removePrefParams `
                        -Name $preferenceKey `
                        -ErrorAction SilentlyContinue
                    Microsoft.PowerShell.Utility\Write-Verbose "Deleted preference: $preferenceKey"
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Verbose "Could not delete preference: $preferenceKey (may not exist)"
                }
            }

            # output confirmation of the persistent storage operation
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Set persistent LLM settings for ${LLMQueryType}: [$settingsDescription]"
            )
        }
    }

    end {
    }
}
###############################################################################