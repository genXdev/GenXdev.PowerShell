###############################################################################
<#
.SYNOPSIS
Launches an interactive Spectre.Console prompt to configure LLM settings.

.DESCRIPTION
Provides an interactive terminal UI using Spectre.Console SelectionPrompt
(arrow keys + mouse) to guide the user through LLM provider configuration.
The user can pick a default provider (requiring only an API key) or enter all
settings manually. API keys are stored per provider family (e.g. "DeepSeek")
with user-given names like "Work" or "Personal", and are reused across query
types.

When -LLMQueryType is omitted, a type-selection menu is shown first with an
"ALL" option to configure all query types at once or in sequence.

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
The type of LLM query to configure. Valid values are SimpleIntelligence,
Knowledge, Pictures, TextTranslation, Coding, and ToolUse. If omitted, an
interactive type-selection menu is displayed.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear the session setting (Global variable) before saving.

.PARAMETER SkipSession
When specified, skips session settings and writes only to persistent
preferences or defaults.

.PARAMETER AllMachines
Also write LLM settings to OneDrive for syncing across multiple machines.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.EXAMPLE
Invoke-AILLMSettingsPrompt -LLMQueryType "ToolUse"

Launches interactive setup for the ToolUse query type.

.EXAMPLE
Invoke-AILLMSettingsPrompt

Shows a type-selection menu, then launches interactive setup.

.EXAMPLE
Invoke-AILLMSettingsPrompt "Coding" -PreferencesDatabasePath "C:\custom\prefs"

Launches interactive setup for Coding with a custom preferences database.
#>
###############################################################################
function Invoke-AILLMSettingsPrompt {

    [CmdletBinding(SupportsShouldProcess)]
    [Alias('llmset', 'promptllmsettings')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The type of LLM query to configure (menu shown if ' +
                'omitted)'
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
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'AI preferences')
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear the session setting (Global variable) ' +
                'before saving')
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('When specified, skips session settings and ' +
                'writes only to persistent preferences or defaults')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Also write LLM settings to OneDrive for syncing ' +
                'across multiple machines')
        )]
        [switch] $AllMachines,
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
            HelpMessage = ('Force non-interactive mode. Used for testing ' +
                'to verify guard clause behavior.')
        )]
        [switch] $NonInteractive
        #######################################################################
    )

    begin {
        if (-not [Environment]::UserInteractive -or $NonInteractive) {
            throw 'Cannot prompt for settings in a non-interactive session'
        }

        $allValidTypes = @(
            'SimpleIntelligence',
            'Knowledge',
            'Pictures',
            'TextTranslation',
            'Coding',
            'ToolUse'
        )

        # capture caller's bound parameters
        $callerParams = $PSBoundParameters

        $cancelMessage = 'User cancelled LLMSettings prompt'

        #######################################################################
        # Helper: build a SelectionPrompt with choices + Cancel + optional Back
        #######################################################################
        function NewSelectionMenu {
            param(
                [string] $Title,
                [string[]] $Choices,
                [string[]] $HighlightedChoices = @(),
                [bool] $ShowCancel = $true,
                [bool] $ShowBack = $false,
                [string] $BackLabel = '.. Back'
            )

            $prompt = Microsoft.PowerShell.Utility\New-Object Spectre.Console.SelectionPrompt[string] `
                -ArgumentList ([System.StringComparer]::OrdinalIgnoreCase)
            $prompt.Title = $Title

            # Use plain strings only — Spectre.Console.Markup objects display
            # as their type name in SelectionPrompt<string> (CLR .ToString()),
            # and inline markup tags like [red] interact badly with the
            # prompt's own ANSI escape codes, corrupting adjacent characters.
            foreach ($choice in $Choices) {
                if ($choice -in $HighlightedChoices) {
                    # Prepend a marker so highlighted items stand out
                    $null = $prompt.AddChoice("> ${choice}")
                } else {
                    $null = $prompt.AddChoice($choice)
                }
            }

            if ($ShowBack) {
                $null = $prompt.AddChoice($BackLabel)
            }

            if ($ShowCancel) {
                $null = $prompt.AddChoice('.. Cancel')
            }

            return $prompt
        }

        #######################################################################
        # Helper: show a SelectionPrompt and get the chosen value
        #######################################################################
        function InvokeSelectionMenu {
            param(
                [Spectre.Console.SelectionPrompt[string]] $Prompt,
                [hashtable] $LabelToValue = @{}
            )

            $chosen = GenXdev\Invoke-SpectrePrompt -Prompt $Prompt

            # Guard: Invoke-SpectrePrompt may return $null when called
            # from a non-interactive context or when mock setup fails.
            if ($null -eq $chosen) {
                throw $cancelMessage
            }

            $plain = if ($chosen -is [string] -and $chosen.StartsWith('> ')) {
                $chosen.Substring(2)
            } else {
                $chosen
            }

            if ($plain -eq '.. Cancel' -or $plain -eq 'Cancel') {
                throw $cancelMessage
            }

            if ($plain -eq '.. Back' -or $plain -eq 'Back') {
                return [PSCustomObject]@{ IsBack = $true; Value = $null }
            }

            if ($LabelToValue.ContainsKey($plain)) {
                return [PSCustomObject]@{
                    IsBack = $false; Value = $LabelToValue[$plain]
                }
            }

            return [PSCustomObject]@{ IsBack = $false; Value = $plain }
        }

        #######################################################################
        # Helper: get saved API keys for a provider family, with their names
        #######################################################################
        function GetSavedProviderKeys {
            param(
                [string] $Provider
            )

            $prefix = "AILLMProviderApiKey_${Provider}_"
            $keys = @()

            # build splatted params for Get-GenXdevPreference to forward
            # PreferencesDatabasePath, SessionOnly, SkipSession etc.
            $getPrefParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $callerParams `
                -FunctionName 'Get-GenXdevPreference'

            # build splatted params for Get-GenXdevPreferenceNames
            $getNamesParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $callerParams `
                -FunctionName 'Get-GenXdevPreferenceNames'

            try {
                # discover saved key names dynamically matching this provider prefix
                $allNames = @(GenXdev\Get-GenXdevPreferenceNames @getNamesParams)
                $matchingNames = $allNames | Microsoft.PowerShell.Core\Where-Object {
                    $_.StartsWith($prefix, [StringComparison]::OrdinalIgnoreCase)
                }

                foreach ($fullKey in $matchingNames) {
                    $name = $fullKey.Substring($prefix.Length)
                    if ([string]::IsNullOrEmpty($name)) { continue }

                    $val = GenXdev\Get-GenXdevPreference @getPrefParams `
                        -Name $fullKey `
                        -ErrorAction SilentlyContinue
                    if ($val) {
                        $maskedLen = [Math]::Min(4, $val.Length)
                        $keys += @{
                            Display = "${name} ($($val.Substring(0, $maskedLen))****)"
                            Name      = $name
                            Key       = $val
                            PreferenceKey = $fullKey
                        }
                    }
                }
            } catch {
                Microsoft.PowerShell.Utility\Write-Verbose "Error scanning provider keys: $($_.Exception.Message)"
            }

            return $keys
        }

        #######################################################################
        # Helper: save an API key under a provider family + user name
        #######################################################################
        function SaveProviderKey {
            param(
                [string] $Provider,
                [string] $KeyName,
                [string] $ApiKey
            )

            $prefKey = "AILLMProviderApiKey_${Provider}_${KeyName}"

            # forward caller's PreferencesDatabasePath, SessionOnly etc.
            $setPrefParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $callerParams `
                -FunctionName 'Set-GenXdevPreference'
            GenXdev\Set-GenXdevPreference @setPrefParams `
                -Name $prefKey `
                -Value $ApiKey
        }

        #######################################################################
        # Helper: render a summary table of what's currently configured
        #######################################################################
        function ShowCurrentSettings {
            GenXdev\Write-SpectreLine
            GenXdev\Write-SpectreMarkupLine -Message `
                '[grey]Current settings:[/]'
            GenXdev\Write-SpectreLine

            # Pad plain text first, then wrap in markup — PowerShell's -f
            # operator counts markup tags as characters, which breaks
            # column alignment when Spectre.Console strips them at render.
            $typeWidth = ($allValidTypes |
                Microsoft.PowerShell.Core\ForEach-Object { $_.Length } |
                Microsoft.PowerShell.Utility\Measure-Object -Maximum).Maximum
            $typeWidth = [Math]::Max($typeWidth, 4)
            $modelWidth = 36

            $hdrType = 'Type'.PadRight($typeWidth)
            $hdrModel = 'Model'.PadRight($modelWidth)
            GenXdev\Write-SpectreMarkupLine -Message `
                "  [grey]${hdrType}[/]  [grey]${hdrModel}[/]  [grey]Key[/]"

            # Pre-read the key-value preference stores ONCE to avoid
            # ~186 JSON file reads (6 types x 6 props x ~3 stores/prop).
            # Both stores live under %LOCALAPPDATA%\GenXdev.PowerShell\
            # KeyValueStore\ and use the "Local_<StoreName>.json" pattern.
            $storeBase = Microsoft.PowerShell.Management\Join-Path `
                ([Environment]::GetEnvironmentVariable('LOCALAPPDATA')) `
                'GenXdev.PowerShell\KeyValueStore'

            $prefStore = $null
            $prefStorePath = Microsoft.PowerShell.Management\Join-Path `
                $storeBase 'Local_GenXdev.PowerShell.Preferences.json'
            if (Microsoft.PowerShell.Management\Test-Path `
                    -LiteralPath $prefStorePath) {
                try {
                    $prefStore = Microsoft.PowerShell.Management\Get-Content `
                        -LiteralPath $prefStorePath -Raw -ErrorAction Stop |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json `
                        -ErrorAction Stop
                } catch { }
            }

            $defStore = $null
            $defStorePath = Microsoft.PowerShell.Management\Join-Path `
                $storeBase 'Local_GenXdev.PowerShell.Defaults.json'
            if (Microsoft.PowerShell.Management\Test-Path `
                    -LiteralPath $defStorePath) {
                try {
                    $defStore = Microsoft.PowerShell.Management\Get-Content `
                        -LiteralPath $defStorePath -Raw -ErrorAction Stop |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json `
                        -ErrorAction Stop
                } catch { }
            }

            # Build a flat hashtable of all AILLMSettings_* key → value
            # (keys are stored lowercase in the preference store).
            # Each store entry is either {value: "...", deletedDate: null}
            # (new format) or a plain string (legacy format).
            $aiPrefs = @{}
            foreach ($store in @($prefStore, $defStore)) {
                if ($null -eq $store) { continue }
                foreach ($prop in $store.PSObject.Properties) {
                    if (-not $prop.Name.StartsWith('AILLMSettings_',
                            [StringComparison]::OrdinalIgnoreCase)) {
                        continue
                    }
                    $entry = $prop.Value
                    $val = $null
                    if ($entry -is [System.Management.Automation.PSCustomObject]) {
                        if ($entry.PSObject.Properties['deletedDate'] -and
                            $entry.deletedDate) { continue }
                        if ($entry.PSObject.Properties['value']) {
                            $val = $entry.value
                        } else {
                            $val = $entry.ToString()
                        }
                    } else {
                        $val = $entry.ToString()
                    }
                    if ($null -ne $val) {
                        $aiPrefs[$prop.Name.ToLowerInvariant()] = $val
                    }
                }
            }

            # Pre-warm the defaults cache for all 6 types so only one
            # Get-AIDefaultLLMSettings call is needed per type (cached
            # after the first call due to $script:DefaultsCache).
            $defParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $callerParams `
                -FunctionName 'Get-AIDefaultLLMSettings'
            $cachedDefaults = @{}
            foreach ($showType in $allValidTypes) {
                $defParams['LLMQueryType'] = $showType
                $cachedDefaults[$showType] = @(
                    GenXdev\Get-AIDefaultLLMSettings @defParams)
            }

            foreach ($showType in $allValidTypes) {
                $typeLower = $showType.ToLowerInvariant()

                # Model: preferences first, then cached defaults
                $modelLookup = "aillmsettings_${typeLower}_model"
                $model = $aiPrefs[$modelLookup]
                if (-not $model) {
                    $defs = $cachedDefaults[$showType]
                    $model = if ($defs.Count -gt 0 -and $defs[0].Model) {
                        $defs[0].Model
                    } else { '-' }
                }

                # ApiKey: check if configured
                $keyLookup = "aillmsettings_${typeLower}_apikey"
                $keyStatus = if ($aiPrefs[$keyLookup]) {
                    '[green]configured[/]'
                } else {
                    '[grey]-[/]'
                }

                $tPadded = $showType.PadRight($typeWidth)
                $mPadded = $model.PadRight($modelWidth)
                GenXdev\Write-SpectreMarkupLine -Message `
                    "  [cyan]${tPadded}[/]  ${mPadded}  ${keyStatus}"
            }
            GenXdev\Write-SpectreLine
        }

        #######################################################################
        # Helper: render a summary table of what was just configured
        #######################################################################
        function ShowConfiguredSummary {
            param(
                [hashtable[]] $ConfiguredItems
            )

            GenXdev\Write-SpectreLine
            GenXdev\Write-SpectreMarkupLine -Message `
                '[green]=== Configuration Complete ===[/]'
            GenXdev\Write-SpectreLine

            # Pad plain text first, then wrap in markup to avoid alignment
            # drift from invisible markup characters (same rationale as
            # ShowCurrentSettings above).
            $typeWidth = 22
            $provWidth = 15
            $modelWidth = 30

            $hdrType = 'Query Type'.PadRight($typeWidth)
            $hdrProv = 'Provider'.PadRight($provWidth)
            $hdrModel = 'Model'.PadRight($modelWidth)
            GenXdev\Write-SpectreMarkupLine -Message `
                "  [grey]${hdrType}[/]  [grey]${hdrProv}[/]  [grey]${hdrModel}[/]  [grey]Key[/]"

            foreach ($item in $ConfiguredItems) {
                $tPadded = $item.Type.PadRight($typeWidth)
                $pPadded = $item.Provider.PadRight($provWidth)
                $mPadded = $item.Model.PadRight($modelWidth)
                GenXdev\Write-SpectreMarkupLine -Message `
                    "  [cyan]${tPadded}[/]  ${pPadded}  ${mPadded}  $($item.KeyName)"
            }

            GenXdev\Write-SpectreLine
            GenXdev\Write-SpectreMarkupLine -Message `
                '[grey]Tip: Change anytime with[/] [yellow]llmset[/]'
        }

        #######################################################################
        # Helper: configure a single query type interactively
        # Returns a hashtable with Type, Provider, Model, KeyName on success,
        # or $null if skipped.
        #######################################################################
        function ConfigureSingleType {
            param(
                [string] $Type,
                [int] $CurrentIndex,
                [int] $TotalCount,
                [bool] $AllowSkip = $false
            )
            $header = if ($TotalCount -gt 1) {
                "[cyan]=== Configuring '${Type}' (${CurrentIndex}/${TotalCount}) ===[/]"
            } else {
                "[cyan]=== GenXdev LLM Configuration ===[/]`n[yellow]Configuring '${Type}' query type[/]"
            }

            GenXdev\Write-SpectreLine
            GenXdev\Write-SpectreMarkupLine -Message $header
            GenXdev\Write-SpectreLine

            # Step 1: pick mode — provider / manual / skip / cancel
            $modeChoices = [System.Collections.Generic.List[string]]::new()
            $modeChoices.Add('Pick a default provider (API key only)')
            $modeChoices.Add('Enter all settings manually')
            if ($AllowSkip) {
                $modeChoices.Add('.. Skip this type (keep current settings)')
            }
            $modeMenu = NewSelectionMenu `
                -Title 'How would you like to configure this type?' `
                -Choices $modeChoices.ToArray() `
                -ShowBack $false `
                -ShowCancel $true

            $modeResult = InvokeSelectionMenu -Prompt $modeMenu
            if ($modeResult.IsBack) { return $null }

            $modeChosen = $modeResult.Value.ToString()

            if ($modeChosen -like '*Skip*') {
                GenXdev\Write-SpectreMarkupLine -Message `
                    "[grey]Skipped '${Type}'[/]"
                return $null
            }

            $isPickProvider = $modeChosen -like '*default provider*'

            if ($isPickProvider) {
                return (ConfigureViaProviderPick -Type $Type)
            } else {
                return (ConfigureViaManualEntry -Type $Type)
            }
        }

        #######################################################################
        # Sub-helper: pick from default providers
        #######################################################################
        function ConfigureViaProviderPick {
            param([string] $Type)

            $defaultParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $callerParams `
                -FunctionName 'Get-AIDefaultLLMSettings'
            $defaultParams['LLMQueryType'] = $Type
            $providers = @(GenXdev\Get-AIDefaultLLMSettings @defaultParams)

            if ($providers.Count -eq 0) {
                throw "No default LLM providers found for type '${Type}'"
            }

            $displayNames = [System.Collections.Generic.List[string]]::new()
            $providerMap = @{}
            foreach ($p in $providers) {
                $ht = if ($p -is [hashtable]) {
                    $p
                } else {
                    $p | GenXdev\ConvertTo-HashTable
                }

                $dn = if ($ht.ContainsKey('DisplayName') -and $ht.DisplayName) {
                    $ht.DisplayName
                } else {
                    "$($ht.Model) @ $($ht.ApiEndpoint)"
                }

                # grey out providers incompatible with this query type
                if ($Type -eq 'Pictures' -and
                    $ht.NoSupportForImageUpload -eq $true) {
                    $dn = "[grey]${dn} (no image support)[/]"
                }
                if ($Type -eq 'ToolUse' -and
                    $ht.NoSupportForToolCalls -eq $true) {
                    $dn = "[grey]${dn} (no tool support)[/]"
                }

                $displayNames.Add($dn)
                # use the plain name (without markup) as the map key
                $plainDn = $dn -replace '\[/?[^\]]+\]', ''
                $providerMap[$plainDn] = $ht
            }

            GenXdev\Write-SpectreMarkupLine -Message `
                '[green]Available providers:[/]'
            $providerMenu = NewSelectionMenu `
                -Title 'Select a provider:' `
                -Choices $displayNames.ToArray() `
                -ShowBack $true `
                -ShowCancel $true

            $providerResult = InvokeSelectionMenu -Prompt $providerMenu `
                -LabelToValue $providerMap
            if ($providerResult.IsBack) {
                # go back to mode selection — recurse into ConfigureSingleType
                return (ConfigureSingleType -Type $Type -CurrentIndex 1 `
                        -TotalCount 1 -AllowSkip $false)
            }

            $selectedProvider = $providerResult.Value

            # determine the provider family
            $providerFamily = if ($selectedProvider.ContainsKey('Provider') -and
                $selectedProvider.Provider) {
                $selectedProvider.Provider
            } else {
                # fallback: derive from endpoint if Provider field missing
                if ($selectedProvider.ApiEndpoint -like '*googleapis*') {
                    'Google'
                } elseif ($selectedProvider.ApiEndpoint -like '*deepseek*') {
                    'DeepSeek'
                } elseif ($selectedProvider.ApiEndpoint -like '*openai*') {
                    'OpenAI'
                } else {
                    'Custom'
                }
            }

            # look for saved keys for this provider family
            $savedKeys = GetSavedProviderKeys -Provider $providerFamily

            $apiKey = $null
            $keyName = $null

            if ($savedKeys.Count -gt 0) {
                # build a menu of saved keys + "enter new"
                $keyChoices = [System.Collections.Generic.List[string]]::new()
                $keyMap = @{}
                foreach ($sk in $savedKeys) {
                    $keyChoices.Add("Use saved key: $($sk.Display)")
                    $keyMap["Use saved key: $($sk.Display)"] = $sk
                }
                $keyChoices.Add('Enter a new API key')

                $keyMenu = NewSelectionMenu `
                    -Title 'Select an API key:' `
                    -Choices $keyChoices.ToArray() `
                    -ShowBack $true `
                    -ShowCancel $true

                $keyResult = InvokeSelectionMenu -Prompt $keyMenu
                if ($keyResult.IsBack) {
                    return (ConfigureViaProviderPick -Type $Type)
                }

                $keyChosen = $keyResult.Value.ToString()

                if ($keyChosen -like '*Use saved key:*') {
                    $selectedKey = $keyMap[$keyChosen]
                    $apiKey = $selectedKey.Key
                    $keyName = $selectedKey.Name
                } else {
                    # enter new key
                    $keyName = GenXdev\Invoke-SpectreAsk -Message `
                        'Give this key a name (e.g. Work, Personal):'
                    if ([string]::IsNullOrWhiteSpace($keyName)) {
                        $keyName = 'Default'
                    }
                    $apiKey = GenXdev\Invoke-SpectreAsk -Message `
                        'Enter your API key:'
                    if ([string]::IsNullOrWhiteSpace($apiKey)) {
                        throw 'API key cannot be empty'
                    }
                }
            } else {
                # no saved keys — enter new with a name
                GenXdev\Write-SpectreLine
                $keyName = GenXdev\Invoke-SpectreAsk -Message `
                    'Give this key a name (e.g. Work, Personal):'
                if ([string]::IsNullOrWhiteSpace($keyName)) {
                    $keyName = 'Default'
                }
                $apiKey = GenXdev\Invoke-SpectreAsk -Message `
                    'Enter your API key:'
                if ([string]::IsNullOrWhiteSpace($apiKey)) {
                    throw 'API key cannot be empty'
                }
            }

            # save the key under provider family
            SaveProviderKey -Provider $providerFamily `
                -KeyName $keyName -ApiKey $apiKey

            # save settings via Set-AILLMSettings
            $setParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $callerParams `
                -FunctionName 'Set-AILLMSettings'
            $setParams['LLMQueryType'] = $Type
            $setParams['Model'] = $selectedProvider.Model
            $setParams['ApiEndpoint'] = $selectedProvider.ApiEndpoint
            $setParams['ApiKey'] = $apiKey
            $setParams['NoSupportForJsonSchema'] = `
                $selectedProvider.NoSupportForJsonSchema -eq $true
            $setParams['NoSupportForImageUpload'] = `
                $selectedProvider.NoSupportForImageUpload -eq $true
            $setParams['NoSupportForToolCalls'] = `
                $selectedProvider.NoSupportForToolCalls -eq $true
            GenXdev\Set-AILLMSettings @setParams

            return @{
                Type     = $Type
                Provider = $providerFamily
                Model    = $selectedProvider.Model
                KeyName  = $keyName
            }
        }

        #######################################################################
        # Sub-helper: manual entry
        #######################################################################
        function ConfigureViaManualEntry {
            param([string] $Type)

            GenXdev\Write-SpectreMarkupLine -Message `
                '[grey]Common endpoints:[/]'

            # dynamically resolve unique endpoints from defaults;
            # silently skip hints if the JSON can't be loaded
            try {
                $epDefaultsParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $callerParams `
                    -FunctionName 'Get-AIDefaultLLMSettings'
                $epDefaultsParams['LLMQueryType'] = $Type
                $epDefaults = @(GenXdev\Get-AIDefaultLLMSettings @epDefaultsParams)

                if ($epDefaults.Count -gt 0) {
                    $seenEndpoints = [ordered]@{}
                    foreach ($epDef in $epDefaults) {
                        $epHt = if ($epDef -is [hashtable]) {
                            $epDef
                        } else {
                            $epDef | GenXdev\ConvertTo-HashTable
                        }
                        $ep = $epHt.ApiEndpoint
                        if ($ep -and -not $seenEndpoints.Contains($ep)) {
                            $seenEndpoints[$ep] = if ($epHt.Provider) {
                                $epHt.Provider } else { 'Custom' }
                        }
                    }
                    foreach ($epKey in $seenEndpoints.Keys) {
                        $prov = $seenEndpoints[$epKey]
                        GenXdev\Write-SpectreMarkupLine -Message `
                            "  ${prov}:  ${epKey}"
                    }
                }
            } catch {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Could not load endpoint hints: $($_.Exception.Message)"
            }
            GenXdev\Write-SpectreLine

            $model = GenXdev\Invoke-SpectreAsk -Message `
                'Enter model name:'
            if ([string]::IsNullOrWhiteSpace($model)) {
                throw 'Model name cannot be empty'
            }

            $endpoint = GenXdev\Invoke-SpectreAsk -Message `
                'Enter API endpoint URL:'
            if ([string]::IsNullOrWhiteSpace($endpoint)) {
                throw 'API endpoint cannot be empty'
            }

            # determine provider family from endpoint
            $providerFamily = if ($endpoint -like '*googleapis*') {
                'Google'
            } elseif ($endpoint -like '*deepseek*') {
                'DeepSeek'
            } elseif ($endpoint -like '*openai*') {
                'OpenAI'
            } else {
                'Custom'
            }

            # look for saved keys for this provider family
            $savedKeys = GetSavedProviderKeys -Provider $providerFamily

            $apiKey = $null
            $keyName = $null

            if ($savedKeys.Count -gt 0) {
                $keyChoices = [System.Collections.Generic.List[string]]::new()
                $keyMap = @{}
                foreach ($sk in $savedKeys) {
                    $keyChoices.Add("Use saved key: $($sk.Display)")
                    $keyMap["Use saved key: $($sk.Display)"] = $sk
                }
                $keyChoices.Add('Enter a new API key')

                $keyMenu = NewSelectionMenu `
                    -Title 'Select an API key:' `
                    -Choices $keyChoices.ToArray() `
                    -ShowBack $true `
                    -ShowCancel $true

                $keyResult = InvokeSelectionMenu -Prompt $keyMenu
                if ($keyResult.IsBack) {
                    return (ConfigureViaManualEntry -Type $Type)
                }

                $keyChosen = $keyResult.Value.ToString()

                if ($keyChosen -like '*Use saved key:*') {
                    $selectedKey = $keyMap[$keyChosen]
                    $apiKey = $selectedKey.Key
                    $keyName = $selectedKey.Name
                } else {
                    $keyName = GenXdev\Invoke-SpectreAsk -Message `
                        'Give this key a name (e.g. Work, Personal):'
                    if ([string]::IsNullOrWhiteSpace($keyName)) {
                        $keyName = 'Default'
                    }
                    $apiKey = GenXdev\Invoke-SpectreAsk -Message `
                        'Enter your API key:'
                    if ([string]::IsNullOrWhiteSpace($apiKey)) {
                        throw 'API key cannot be empty'
                    }
                }
            } else {
                GenXdev\Write-SpectreLine
                $keyName = GenXdev\Invoke-SpectreAsk -Message `
                    'Give this key a name (e.g. Work, Personal):'
                if ([string]::IsNullOrWhiteSpace($keyName)) {
                    $keyName = 'Default'
                }
                $apiKey = GenXdev\Invoke-SpectreAsk -Message `
                    'Enter your API key:'
                if ([string]::IsNullOrWhiteSpace($apiKey)) {
                    throw 'API key cannot be empty'
                }
            }

            # save the key under provider family
            SaveProviderKey -Provider $providerFamily `
                -KeyName $keyName -ApiKey $apiKey

            # ask about capabilities
            GenXdev\Write-SpectreLine
            GenXdev\Write-SpectreMarkupLine -Message `
                '[yellow]Endpoint capabilities:[/]'
            $supportsJsonSchema = GenXdev\Invoke-SpectreConfirm -Message `
                'Does this endpoint support JSON Schema (structured output)?'
            $supportsImageUpload = GenXdev\Invoke-SpectreConfirm -Message `
                'Does this endpoint support image upload?'
            $supportsToolCalls = GenXdev\Invoke-SpectreConfirm -Message `
                'Does this endpoint support tool calling?'

            $setParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $callerParams `
                -FunctionName 'Set-AILLMSettings'
            $setParams['LLMQueryType'] = $Type
            $setParams['Model'] = $model
            $setParams['ApiEndpoint'] = $endpoint
            $setParams['ApiKey'] = $apiKey
            $setParams['NoSupportForJsonSchema'] = -not $supportsJsonSchema
            $setParams['NoSupportForImageUpload'] = -not $supportsImageUpload
            $setParams['NoSupportForToolCalls'] = -not $supportsToolCalls
            GenXdev\Set-AILLMSettings @setParams

            return @{
                Type     = $Type
                Provider = $providerFamily
                Model    = $model
                KeyName  = $keyName
            }
        }

        #######################################################################
        # Helper: configure all types with the same provider in one shot
        #######################################################################
        function ConfigureAllWithSameProvider {
            # first pick ONE provider for a reference type
            GenXdev\Write-SpectreMarkupLine -Message `
                '[yellow]Pick the provider to apply to ALL query types:[/]'
            GenXdev\Write-SpectreLine

            $result = ConfigureViaProviderPick -Type 'SimpleIntelligence'
            if (-not $result) { return @() }

            $configuredItems = @($result)

            # apply to remaining 5 types
            for ($i = 1; $i -lt $allValidTypes.Count; $i++) {
                $type = $allValidTypes[$i]
                $setParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $callerParams `
                    -FunctionName 'Set-AILLMSettings'

                # get the settings we just saved for SimpleIntelligence
                $getAiParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $callerParams `
                    -FunctionName 'Get-AILLMSettings'
                $getAiParams['LLMQueryType'] = 'SimpleIntelligence'
                $refSettings = GenXdev\Get-AILLMSettings @getAiParams `
                    -SuppressAutoPrompt:$true

                $setParams['LLMQueryType'] = $type
                $setParams['Model'] = $refSettings.Model
                $setParams['ApiEndpoint'] = $refSettings.ApiEndpoint
                $setParams['ApiKey'] = $refSettings.ApiKey
                $setParams['NoSupportForJsonSchema'] = `
                    $refSettings.NoSupportForJsonSchema
                $setParams['NoSupportForImageUpload'] = `
                    $refSettings.NoSupportForImageUpload
                $setParams['NoSupportForToolCalls'] = `
                    $refSettings.NoSupportForToolCalls
                GenXdev\Set-AILLMSettings @setParams

                $configuredItems += @{
                    Type     = $type
                    Provider = $result.Provider
                    Model    = $result.Model
                    KeyName  = $result.KeyName
                }
            }

            return $configuredItems
        }
    }

    process {
        # show current settings before any prompts
        ShowCurrentSettings

        # resolve target type(s)
        $cancelRequested = $false
        $typesToConfigure = if ($PSBoundParameters.ContainsKey('LLMQueryType')) {
            @($LLMQueryType)
        } else {
            try {
                $typeChoices = [System.Collections.Generic.List[string]]::new()
                foreach ($t in $allValidTypes) { $typeChoices.Add($t) }
                $typeChoices.Add('ALL')

                $typeMenu = NewSelectionMenu `
                    -Title 'Select which query type(s) to configure:' `
                    -Choices $typeChoices.ToArray() `
                    -HighlightedChoices @('ALL') `
                    -ShowBack $false `
                    -ShowCancel $true

                $typeResult = InvokeSelectionMenu -Prompt $typeMenu
                if ($typeResult.IsBack) { return }

                $typeChosen = $typeResult.Value.ToString()

                if ($typeChosen -eq 'ALL') {
                    # ask: all at once or individually?
                    $allModeChoices = @(
                        'Apply one provider to ALL types at once',
                        'Configure each type individually'
                    )
                    $allModeMenu = NewSelectionMenu `
                        -Title 'How would you like to configure ALL types?' `
                        -Choices $allModeChoices `
                        -HighlightedChoices @($allModeChoices[0]) `
                        -ShowBack $true `
                        -ShowCancel $true

                    $allModeResult = InvokeSelectionMenu -Prompt $allModeMenu
                    if ($allModeResult.IsBack) {
                        # re-show type selection by recursing
                        $PSBoundParameters.Remove('LLMQueryType')
                        return (GenXdev\Invoke-AILLMSettingsPrompt @PSBoundParameters)
                    }

                    $allModeChosen = $allModeResult.Value.ToString()

                    if ($allModeChosen -like '*at once*') {
                        $configuredItems = ConfigureAllWithSameProvider
                        ShowConfiguredSummary -ConfiguredItems $configuredItems
                        return
                    } else {
                        $allValidTypes
                    }
                } else {
                    @($typeChosen)
                }
            } catch {
                if ($_.Exception.Message -eq $cancelMessage) {
                    $cancelRequested = $true
                } else {
                    throw
                }
            }
        }

        if ($cancelRequested) { return }

        # Ensure typesToConfigure is always an array
        $typesToConfigure = @($typesToConfigure)

        # configure types (individually, with progress)
        $configuredItems = [System.Collections.Generic.List[hashtable]]::new()
        $total = $typesToConfigure.Count

        for ($i = 0; $i -lt $total; $i++) {
            try {
                $queryType = $typesToConfigure[$i]

            # check if we should offer "apply to remaining" shortcut
            if ($i -eq 1 -and $total -gt 2 -and $configuredItems.Count -gt 0) {
                $lastProvider = $configuredItems[-1]
                GenXdev\Write-SpectreLine
                $shortcutMsg = "[grey]Apply '$($lastProvider.Model)' to all remaining types?[/]"
                GenXdev\Write-SpectreMarkupLine -Message $shortcutMsg

                $shortcutChoices = @(
                    'Yes, apply to all remaining types',
                    'No, pick individually'
                )
                $shortcutMenu = NewSelectionMenu `
                    -Title '' `
                    -Choices $shortcutChoices `
                    -HighlightedChoices @($shortcutChoices[1]) `
                    -ShowBack $false `
                    -ShowCancel $true

                $shortcutResult = InvokeSelectionMenu `
                    -Prompt $shortcutMenu
                $shortcutChosen = $shortcutResult.Value.ToString()

                if ($shortcutChosen -like '*Yes*') {
                    # apply this provider to remaining types
                    for ($j = $i; $j -lt $total; $j++) {
                        $remType = $typesToConfigure[$j]
                        $getAiShortcutParams = GenXdev\Copy-IdenticalParamValues `
                            -BoundParameters $callerParams `
                            -FunctionName 'Get-AILLMSettings'
                        $getAiShortcutParams['LLMQueryType'] = $typesToConfigure[0]
                        $refSettings = GenXdev\Get-AILLMSettings @getAiShortcutParams `
                            -SuppressAutoPrompt:$true

                        $setParams = GenXdev\Copy-IdenticalParamValues `
                            -BoundParameters $callerParams `
                            -FunctionName 'Set-AILLMSettings'
                        $setParams['LLMQueryType'] = $remType
                        $setParams['Model'] = $refSettings.Model
                        $setParams['ApiEndpoint'] = $refSettings.ApiEndpoint
                        $setParams['ApiKey'] = $refSettings.ApiKey
                        $setParams['NoSupportForJsonSchema'] = `
                            $refSettings.NoSupportForJsonSchema
                        $setParams['NoSupportForImageUpload'] = `
                            $refSettings.NoSupportForImageUpload
                        $setParams['NoSupportForToolCalls'] = `
                            $refSettings.NoSupportForToolCalls
                        GenXdev\Set-AILLMSettings @setParams

                        $configuredItems.Add(@{
                            Type     = $remType
                            Provider = $configuredItems[0].Provider
                            Model    = $configuredItems[0].Model
                            KeyName  = $configuredItems[0].KeyName
                        })
                    }
                    break
                }
                }

                $item = ConfigureSingleType -Type $queryType `
                    -CurrentIndex ($i + 1) -TotalCount $total `
                    -AllowSkip ($total -gt 1)

                if ($item) {
                    $configuredItems.Add($item)
                }
            } catch {
                if ($_.Exception.Message -eq $cancelMessage) {
                    if ($configuredItems.Count -gt 0) {
                        GenXdev\Write-SpectreLine
                        $partialMsg = "[yellow]${configuredItems.Count} type(s) were already saved:[/]"
                        GenXdev\Write-SpectreMarkupLine -Message $partialMsg
                        $saved = ($configuredItems |
                            Microsoft.PowerShell.Core\ForEach-Object { $_.Type }) -join ', '
                        GenXdev\Write-SpectreMarkupLine -Message `
                            "[yellow]${saved}[/]"
                        $rerunMsg = "[grey]Run [yellow]llmset[/] again to configure the remaining types.[/]"
                        GenXdev\Write-SpectreMarkupLine -Message $rerunMsg
                    }
                    return
                }
                throw
            }
        }

        # show summary of what was configured
        if ($configuredItems.Count -gt 0) {

            ShowConfiguredSummary -ConfiguredItems $configuredItems.ToArray()
        }
    }

    end {
    }
}
###############################################################################