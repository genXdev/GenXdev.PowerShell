###############################################################################
<#
.SYNOPSIS
Creates a new refactoring set for code transformation tasks.

.DESCRIPTION
Creates and configures a new refactoring definition with specified settings for
LLM-based code transformations. The function handles:
- Setting up refactoring configuration
- Configuring selection criteria and prompts
- Managing LLM model settings
- Integrating with development environments
- Persisting refactor definitions

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

.PARAMETER Name
Unique identifier for the refactoring set. Must be non-empty and unique.

.PARAMETER PromptKey
Key identifying which prompt template to use for refactoring operations.

.PARAMETER Prompt
Optional custom prompt text to override the template specified by PromptKey.

.PARAMETER SelectionScript
PowerShell script defining selection criteria for items to refactor.

.PARAMETER SelectionPrompt
Custom prompt text used by the LLM to guide selection of items for refactoring.

.PARAMETER LLMQueryType
The type of LLM query to perform (SimpleIntelligence, Knowledge, Pictures, etc.).

.PARAMETER Model
Name or identifier of the specific LLM model to use for processing.

.PARAMETER SelectByFreeRam
Select configuration by available system RAM.

.PARAMETER SelectByFreeGpuRam
Select configuration by available GPU RAM.

.PARAMETER Temperature
Controls randomness in LLM responses (0.0-1.0). Lower is more deterministic.

.PARAMETER ApiEndpoint
Custom API endpoint URL for accessing the LLM service.

.PARAMETER ApiKey
Authentication key required for API access.

.PARAMETER TimeoutSeconds
The timeout in seconds for AI operations.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.PARAMETER Priority
Processing priority for this refactor set (higher numbers = higher priority).

.PARAMETER ExposedCmdLets
Array of PowerShell cmdlet definitions to expose as tools to the LLM.

.PARAMETER FilesToAdd
Array of files to initially include in the refactoring set.

.PARAMETER AutoAddModifiedFiles
When enabled, automatically adds any modified files to the refactoring queue.

.PARAMETER Code
Opens files in Visual Studio Code when enabled.

.PARAMETER VisualStudio
Opens files in Visual Studio when enabled.

.PARAMETER KeysToSend
Array of keystrokes to send after opening files.

.EXAMPLE
New-Refactor -Name "UpdateLogging" -PromptKey "LoggingRefactor" `
    -SelectionScript "Get-LoggingMethods" -Priority 1 `
    -Code

.EXAMPLE
newrefactor UpdateLogging LoggingRefactor -p "Get-LoggingMethods" -c
#>
###############################################################################
function New-Refactor {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias('newrefactor')]

    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The name of this new refactor set'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Name,
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $true,
            HelpMessage = 'The prompt key indicates which prompt script to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PromptKey,
        ########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'Custom prompt text to override the template'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Prompt = '',
        ########################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'Powershell script for selecting items to refactor'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $SelectionScript,
        ########################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'LLM selection guidance prompt'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $SelectionPrompt,
        ########################################################################
        [Parameter(
            Position = 5,
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
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Select configuration by available system RAM'
        )]
        [switch] $SelectByFreeRam,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Select configuration by available GPU RAM'
        )]
        [switch] $SelectByFreeGpuRam,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI operations'
        )]
        [string] $ApiKey,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Indicates that LLM has no support for JSON schemas'
        )]
        [switch] $NoSupportForJsonSchema,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Priority for this refactor set'
        )]
        [ValidateNotNullOrEmpty()]
        [int] $Priority = 0,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of PowerShell command definitions for LLM tools'
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of files to process'
        )]
        [ValidateNotNull()]
        [System.IO.FileInfo[]] $FilesToAdd = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will automatically add modified files to the queue'
        )]
        [switch] $AutoAddModifiedFiles,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open files in Visual Studio Code'
        )]
        [Alias('c')]
        [switch] $Code,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in Visual Studio'
        )]
        [Alias('vs')]
        [switch] $VisualStudio,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Keystrokes to send after opening files'
        )]
        [Alias('keys')]
        [string[]] $KeysToSend = @()
        ########################################################################
    )

    begin {

        # capture current UTC timestamp for logging
        $currentTime = GenXdev\UtcNow

        # output verbose information about the refactor set being created
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Initializing new refactor set '$Name' with priority $Priority"
        )

        # initialize new refactor definition object
        $refactorDefinition = [GenXdev.Helpers.RefactorDefinition]::new()
        $refactorDefinition.Name = $Name
        $refactorDefinition.Priority = $Priority

        # configure base refactoring settings
        $refactorDefinition.RefactorSettings.PromptKey = $PromptKey
        $refactorDefinition.RefactorSettings.Prompt = $Prompt

        # setup selection criteria configuration
        $refactorDefinition.SelectionSettings.Script = $SelectionScript
        $refactorDefinition.SelectionSettings.AutoAddModifiedFiles = `
            $AutoAddModifiedFiles
        $refactorDefinition.SelectionSettings.LLM.Prompt = $SelectionPrompt

        # configure LLM processing settings
        $llmConfigParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-AILLMSettings' `
            -DefaultValues  (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        $llmConfig = GenXdev\Get-AILLMSettings @llmConfigParams

        foreach ($param in $llmConfig.Keys) {

            if ($null -ne $llmConfig[$param]) {

                $refactorDefinition.SelectionSettings.LLM."$param" = $llmConfig."$param"
            }
        }

        $refactorDefinition.SelectionSettings.LLM.ExposedCmdLets = `
            $ExposedCmdLets

        # set IDE integration preferences
        $refactorDefinition.RefactorSettings.KeysToSend = $KeysToSend
        $refactorDefinition.RefactorSettings.Code = `
            $PSBoundParameters.ContainsKey('Code') ? ($Code ? 1 : 0) : -1
        $refactorDefinition.RefactorSettings.VisualStudio = `
            $PSBoundParameters.ContainsKey('VisualStudio') ? `
        ($VisualStudio ? 1 : 0) : -1

        # record creation event in log
        $null = $refactorDefinition.Log.Add(
            @{
                Timestamp = $currentTime
                Message   = 'Refactor set created'
            }
        )

        # initialize state tracking
        $refactorDefinition.State.Status = 'Created'
        $refactorDefinition.State.LastUpdated = $currentTime
    }

    process {

        # create unique storage key for this refactor set
        $preferenceName = "refactor_set_$Name"

        # output verbose information about refactor set existence check
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Validating refactor set '$Name' does not exist"
        )

        # build splatted params to forward PreferencesDatabasePath,
        # SessionOnly, SkipSession etc. to preference cmdlets
        $getPrefParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-GenXdevPreference'

        # verify no existing refactor with same name exists
            $existingDefinition = GenXdev\Get-GenXdevPreference @getPrefParams `
            -Name $preferenceName `
            -ErrorAction SilentlyContinue

        # check for existing refactor set with same name
        if ($existingDefinition) {
            Microsoft.PowerShell.Utility\Write-Error (
                "Refactor set '$Name' already exists"
            )
            return
        }

        # confirm with user before creating new refactor set
        if ($PSCmdlet.ShouldProcess($Name, 'Create new refactor set')) {

            # output verbose information about saving the refactor set
            Microsoft.PowerShell.Utility\Write-Verbose "Saving refactor set '$Name'"

            # initialize with provided files
            GenXdev\Update-Refactor `
                -Refactor $refactorDefinition `
                -FilesToAdd:$FilesToAdd `
                -PerformAutoSelections
        }
    }

    end {
    }
}
###############################################################################