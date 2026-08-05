################################################################################
<#
.SYNOPSIS
Gets all available default LLM settings configurations for AI operations in
GenXdev.AI.

.DESCRIPTION
Retrieves the complete set of default Large Language Model (LLM) settings
configured for AI operations. Results can be filtered by query type, model
identifier, API endpoint, or API key. Supports both session-based and
persistent preference-based retrieval, with options to clear session state
or bypass it entirely to read directly from stored preferences.

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
Filter configurations by model identifier or pattern.

.PARAMETER ApiEndpoint
Filter configurations by API endpoint URL.

.PARAMETER ApiKey
Filter configurations by API key.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear the session setting (Global variable) before retrieving.

.PARAMETER SkipSession
When specified, skips session settings and retrieves only from persistent
preferences or defaults.

.EXAMPLE
Get-AIDefaultLLMSettings -LLMQueryType "Coding"

Gets all available default configurations for Coding query type.


#>
################################################################################
function Get-AIDefaultLLMSettings {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [OutputType([hashtable[]])]
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
            HelpMessage = 'Filter configurations by model identifier or pattern'
        )]
        [string] $Model,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter configurations by API endpoint URL'
        )]
        [string] $ApiEndpoint,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter configurations by API key'
        )]
        [string] $ApiKey,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Indicates that LLM has no support for JSON schemas'
        )]
        [switch] $NoSupportForJsonSchema,
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
        [switch] $SkipSession
        ###############################################################################
    )

    begin {

        # Initialize script-scoped cache once to avoid re-reading
        # default-llmproviders.json for every call (the file never
        # changes during a session).
        if (-not $script:DefaultsCache) {
            $script:DefaultsCache = @{}
        }

        # log provided parameter values for filtering
        $filterParams = @()
        if ($PSBoundParameters.ContainsKey('Model')) { $filterParams += "Model=$Model" }
        if ($PSBoundParameters.ContainsKey('ApiEndpoint')) { $filterParams += "ApiEndpoint=$ApiEndpoint" }
        if ($PSBoundParameters.ContainsKey('ApiKey')) { $filterParams += 'ApiKey=(redacted)' }
        if ($PSBoundParameters.ContainsKey('TimeoutSeconds')) { $filterParams += "TimeoutSeconds=$TimeoutSeconds" }

        if ($filterParams.Count -gt 0) {
            Microsoft.PowerShell.Utility\Write-Verbose "Filter parameters: $($filterParams -join ', ')"
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose 'No filter parameters provided'
        }

        # handle clearing session variables first if requested
        if ($ClearSession) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Clearing session variables (ClearSession=true)'
        }
    }

    process {

        # Return cached result if available — the JSON file never changes
        if ($script:DefaultsCache.ContainsKey($LLMQueryType)) {
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Returning cached defaults for: $LLMQueryType")
            return $script:DefaultsCache[$LLMQueryType]
        }

        try {
            Microsoft.PowerShell.Utility\Write-Verbose 'Loading defaults from JSON configuration...'

            # construct path to default settings JSON file
            $defaultsPath = Microsoft.PowerShell.Management\Join-Path `
                $MyInvocation.MyCommand.Module.ModuleBase 'default-llmproviders.json'

            Microsoft.PowerShell.Utility\Write-Verbose "JSON path: $defaultsPath"

            # read and parse JSON content
            $jsonContent = Microsoft.PowerShell.Management\Get-Content `
                -LiteralPath $defaultsPath `
                -Raw `
                -ErrorAction Stop

            # convert JSON to PowerShell object
            $defaultsJson = $jsonContent | `
                    Microsoft.PowerShell.Utility\ConvertFrom-Json `
                    -ErrorAction Stop

            Microsoft.PowerShell.Utility\Write-Verbose 'JSON loaded successfully'

            # extract configurations for the specified query type
            $defaultConfigs = $null
            if ($defaultsJson.PSObject.Properties.Name -contains $LLMQueryType) {

                $defaultConfigs = $defaultsJson.$LLMQueryType
                Microsoft.PowerShell.Utility\Write-Verbose "Found $($defaultConfigs.Count) default configurations for query type: $LLMQueryType"
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose "No configurations found for query type: $LLMQueryType"
                return [hashtable[]]@()
            }

            # return empty array if no configurations found
            if ($null -eq $defaultConfigs -or $defaultConfigs.Count -eq 0) {

                Microsoft.PowerShell.Utility\Write-Verbose 'No default configurations available'
                return [hashtable[]]@()
            }

            $result = ($defaultConfigs | GenXdev\ConvertTo-HashTable)
            $script:DefaultsCache[$LLMQueryType] = $result
            return $result
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose "Error loading default configurations: $($_.Exception.Message)"
            throw "Failed to load default LLM settings: $($_.Exception.Message)"
        }
    }

    end {
    }
}
################################################################################