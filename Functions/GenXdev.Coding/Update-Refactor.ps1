###############################################################################
<#
.SYNOPSIS
Updates and manages refactoring sets including file selection and processing.

.DESCRIPTION
Provides comprehensive management of refactoring sets by:
- Adding or removing files from processing queues
- Cleaning up deleted files from the set
- Managing state information and progress tracking
- Handling LLM-based file selection and processing
- Supporting both automatic and manual file management
- Maintaining detailed logs of all operations
- Gracefully handling deleted files (skipped unless CleanUpDeletedFiles is used)

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
Names of refactor sets to update, accepts wildcards. Default is "*".

.PARAMETER Refactor
Direct input of refactor set objects instead of loading by name.

.PARAMETER FilesToAdd
Files to add to the processing queue.

.PARAMETER FilesToRemove
Files to remove from the processing queue.

.PARAMETER CleanUpDeletedFiles
Remove entries for files that no longer exist on disk. Without this parameter,
deleted files are preserved in collections but gracefully skipped during
processing.

.PARAMETER AskBeforeLLMSelection
Prompt before launching LLM invocations for file selections.

.PARAMETER PerformAutoSelections
Enable LLM-based file selection processing.

.PARAMETER PerformAISelections
Process all files in the refactor set with LLM. Can also be used as
-PerformAISelections.

.PARAMETER RetryFailedLLMSelections
Retry previously failed LLM selections.

.PARAMETER Clear
Remove all files from the refactor set.

.PARAMETER ClearLog
Clear the refactor set's operation log.

.PARAMETER Reset
Start processing from beginning of refactor set.

.PARAMETER ResetLMSelections
Restart all LLM selections from beginning.

.PARAMETER MarkAllCompleted
Mark all files as successfully refactored.

.PARAMETER SelectByModifiedDateFrom
Select files modified on or after this date.

.PARAMETER SelectByModifiedDateTo
Select files modified on or before this date.

.PARAMETER SelectByCreationDateFrom
Select files created on or after this date.

.PARAMETER SelectByCreationDateTo
Select files created on or before this date.

.PARAMETER RedoLast
Reprocess the last refactoring operation.

.PARAMETER PromptKey
Key identifying which prompt script to use.

.PARAMETER Prompt
Direct prompt text to use for processing.

.PARAMETER SelectionScript
PowerShell script for file selection logic.

.PARAMETER ReprocessModifiedFiles
Automatically reprocess files that have been modified since the last refactor
update.

.PARAMETER SelectionPrompt
Content for LLM-based selection prompts.

.PARAMETER Temperature
Temperature setting for response randomness (0.0-1.0).

.PARAMETER Priority
Processing priority level for this refactor set.

.PARAMETER ExposedCmdLets
PowerShell commands available during LLM selection.

.PARAMETER Code
Open file in Visual Studio Code.

.PARAMETER VisualStudio
Open file in Visual Studio.

.PARAMETER KeysToSend
Keystrokes to send after opening file.

.PARAMETER Speak
Enable text-to-speech for operation details.

.PARAMETER LLMQueryType
Type of LLM query to perform.

.PARAMETER Model
LLM model to use

.PARAMETER SelectByFreeRam
Select configuration by available system RAM.

.PARAMETER SelectByFreeGpuRam
Select configuration by available GPU RAM.

.PARAMETER ApiEndpoint
API endpoint URL for LLM service.

.PARAMETER ApiKey
Authentication key for API access.

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

.EXAMPLE
Update-Refactor -Name "CodeCleanup" -FilesToAdd ".\src\*.cs" `
    -CleanUpDeletedFiles -PerformAutoSelections -ReprocessModifiedFiles

.EXAMPLE
Get-Refactor "MyRefactor" | Update-Refactor -Reset -Clear

.EXAMPLE
updaterefactor * -Clear -Reset
#>
###############################################################################
function Update-Refactor {

    [CmdletBinding(DefaultParameterSetName = 'Name', SupportsShouldProcess)]
    [Alias('updaterefactor')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute(
        'PSAvoidUsingInvokeExpression',
        '',
        Justification = 'Required for dynamic script execution in refactoring context')]

    param (
        ###############################################################################
        [Parameter(
            ParameterSetName = 'Name',
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'The name of the refactor, accepts wildcards',
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]] $Name = @('*'),
        ###############################################################################
        [Parameter(
            ParameterSetName = 'Refactor',
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'The refactor set to update'
        )]
        [ValidateNotNull()]
        [GenXdev.Helpers.RefactorDefinition[]] $Refactor,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'Filenames to add'
        )]
        [ValidateNotNull()]
        [System.IO.FileInfo[]] $FilesToAdd = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 3,
            HelpMessage = 'Filenames to remove'
        )]
        [ValidateNotNull()]
        [System.IO.FileInfo[]] $FilesToRemove = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Select files by modified date from'
        )]
        [ValidateNotNullOrEmpty()]
        [datetime] $SelectByModifiedDateFrom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Select files by modified date to'
        )]
        [ValidateNotNullOrEmpty()]
        [datetime] $SelectByModifiedDateTo,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Select files by creation date from'
        )]
        [ValidateNotNullOrEmpty()]
        [datetime] $SelectByCreationDateFrom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Select files by creation date to'
        )]
        [ValidateNotNullOrEmpty()]
        [datetime] $SelectByCreationDateTo,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The prompt key indicates which prompt script to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PromptKey,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The prompt key indicates which prompt script to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Prompt = '',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Powershell script for function to select items to ' +
                'refactor')
        )]
        [ValidateNotNullOrEmpty()]
        [string] $SelectionScript,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('If provided, will invoke LLM to do the selection ' +
                'based on the content of the script')
        )]
        [ValidateNotNullOrEmpty()]
        [string] $SelectionPrompt,
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
        [string] $LLMQueryType = 'Coding',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
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
            HelpMessage = 'Indicates that LLM has no support for JSON schemas'
        )]
        [switch] $NoSupportForJsonSchema,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Priority for this refactor set'
        )]
        [ValidateNotNullOrEmpty()]
        [int] $Priority,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Array of PowerShell command definitions to use as ' +
                'tools during LLM selection')
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]] $ExposedCmdLets = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The keys to invoke as key strokes after opening the file'
        )]
        [Alias('keys')]
        [string[]] $KeysToSend = @(),
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
            HelpMessage = 'Clean up deleted files'
        )]
        [switch] $CleanUpDeletedFiles,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to suppress user interaction'
        )]
        [switch] $AskBeforeLLMSelection,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to enable LLM-based file selection processing'
        )]
        [switch] $PerformAutoSelections,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to process all files in the refactor set'
        )]
        [Alias('PerformAllLLMSelections')]
        [switch] $PerformAISelections,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to retry failed LLM selections'
        )]
        [switch] $RetryFailedLLMSelections,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear all files from the refactor set'
        )]
        [switch] $Clear,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear the log of the refactor set'
        )]
        [switch] $ClearLog,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Start from the beginning of the refactor set'
        )]
        [switch] $Reset,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restart all LLMSelections'
        )]
        [switch] $ResetLMSelections,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Mark all files as refactored'
        )]
        [switch] $MarkAllCompleted,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Redo the last refactor'
        )]
        [switch] $RedoLast,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically reprocess files modified since last update'
        )]
        [Alias('AutoAddModifiedFiles')]
        [switch] $ReprocessModifiedFiles,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The ide to open the file in'
        )]
        [Alias('c')]
        [switch] $Code,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in Visual Studio'
        )]
        [Alias('vs')]
        [switch] $VisualStudio,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Speak out the details of next refactor'
        )]
        [switch] $Speak,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Select configuration by available system RAM'
        )]
        [switch] $SelectByFreeRam,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Select configuration by available GPU RAM'
        )]
        [switch] $SelectByFreeGpuRam,
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
            HelpMessage = ('Store settings only in persistent preferences ' +
                'without affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ###############################################################################
    )

    begin {

        $psRootPath = GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\..\"

        # establish the modules path for GenXdev operations
        $modulesPath = GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\"

        # log start of operation for debugging and tracking
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting Update-Refactor operation'

        # load refactor set by name if not provided directly via pipeline
        if ($PSCmdlet.ParameterSetName -eq 'Name') {

            # retrieve and sort refactor definitions by priority
            $Refactor = @(
                GenXdev\Get-Refactor -Name $Name |
                    Microsoft.PowerShell.Utility\Sort-Object -Property Priority -Descending
            )
        }

        # exit early if no refactor set found to prevent further processing
        if ($null -eq $Refactor -or $Refactor.Count -eq 0) {

            Microsoft.PowerShell.Utility\Write-Warning 'No refactorset found'
            return
        }

        # initialize tracking variables for file operations and progress
        $now = GenXdev\UtcNow
        $script:filesAdded = 0
        $script:filesRemoved = 0
        $script:onlyFirst = -not $PerformAISelections
        $script:last = $null
        $expandedFilesToAdd = @($FilesToAdd | Microsoft.PowerShell.Core\ForEach-Object {
                GenXdev\Expand-Path $_
            })
    }


    process {

        # process each refactor definition in the collection
        foreach ($refactorDefinition in $Refactor) {

            # initialize or clear state containers when requested
            if ($Clear -or ($null -eq $refactorDefinition.State.Unselected)) {

                $refactorDefinition.State.Unselected = @()
            }

            # initialize or clear selected files collection
            if ($Clear -or ($null -eq $refactorDefinition.State.Selected)) {

                $refactorDefinition.State.Selected = @()
            }

            # initialize or clear refactored files collection
            if ($Clear -or ($null -eq $refactorDefinition.State.Refactored)) {

                $refactorDefinition.State.Refactored = @()
            }

            # initialize log collection if missing
            if ($null -eq $refactorDefinition.Log) {

                $refactorDefinition.Log = @()
            }

            # clear operation log if requested
            if ($ClearLog) {

                $null = $refactorDefinition.Log.Clear()

                # record log clearing action in new log entry
                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = 'Log cleared'
                    }
                )
            }

            # reset all state indices and progress when clearing
            if ($Clear) {

                $refactorDefinition.State.RefactoredIndex = -1
                $refactorDefinition.State.SelectedIndex = -1
                $refactorDefinition.State.UnselectedIndex = -1
                $refactorDefinition.State.PercentageComplete = 0

                # log the clear operation for audit trail
                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = 'Refactor set cleared'
                    }
                )
            }

            # migrate folder names
            for ($refactoredIndex = $refactorDefinition.State.Refactored.Count - 1;
                $refactoredIndex -ge 0; $refactoredIndex--) {

                if ($null -eq $refactorDefinition.State.Refactored[$refactoredIndex]) {

                    $null = $refactorDefinition.State.Refactored.RemoveAt($refactoredIndex)

                    if ($refactoredIndex -le $refactorDefinition.State.RefactoredIndex) {

                        $refactorDefinition.State.RefactoredIndex = [Math]::Max(-1,
                            $refactorDefinition.State.RefactoredIndex - 1)
                    }
                }
                else {
                    $path = (GenXdev\Expand-Path ($refactorDefinition.State.Refactored[$refactoredIndex]))

                    if ($path.StartsWith("$modulesPath\GenXdev")) {

                        $parts = $path.Substring($modulesPath.Length).Split('\', [System.StringSplitOptions]::RemoveEmptyEntries);

                        if ($parts.Length -gt 1) {
                            [Version] $version = $null
                            if ([Version]::tryParse($parts[1], [ref]$version)) {

                                $newPath = "$($modulesPath.TrimEnd('\'))\$($parts[0])\3.33.0\$($path.Substring($modulesPath.Length + $parts[0].Length+ $parts[1].Length + 3))"

                                if ($refactorDefinition.State.Refactored.IndexOf($newPath) -lt 0) {

                                    $refactorDefinition.State.Refactored[$refactoredIndex] = $newPath
                                }
                            }
                        }
                    }
                }
            }

            # migrate folder names
            for ($selectedIndex = $refactorDefinition.State.Selected.Count - 1;
                $selectedIndex -ge 0; $selectedIndex--) {
                if ($null -eq $refactorDefinition.State.Selected[$selectedIndex]) {

                    $null = $refactorDefinition.State.Selected.RemoveAt($selectedIndex)
                    if ($selectedIndex -le $refactorDefinition.State.SelectedIndex) {

                        $refactorDefinition.State.SelectedIndex = [Math]::Max(-1,
                            $refactorDefinition.State.SelectedIndex - 1)
                    }
                }
                else {
                    $path = (GenXdev\Expand-Path $refactorDefinition.State.Selected[$selectedIndex])

                    if ($path.StartsWith("$modulesPath\GenXdev")) {

                        $parts = $path.Substring($modulesPath.Length).Split('\', [System.StringSplitOptions]::RemoveEmptyEntries);

                        if ($parts.Length -gt 1) {
                            [Version] $version = $null

                            if ([Version]::tryParse($parts[1], [ref]$version)) {

                                $newPath = "$($modulesPath.TrimEnd('\'))\$($parts[0])\3.33.0\$($path.Substring($modulesPath.Length + $parts[0].Length + $parts[1].Length + 3))"

                                if ($refactorDefinition.State.Selected.IndexOf($newPath) -lt 0) {

                                    $refactorDefinition.State.Selected[$selectedIndex] = $newPath
                                }
                            }
                        }
                    }
                }
            }

            # migrate folder names
            for ($unselectedIndex = $refactorDefinition.State.Unselected.Count - 1;
                $unselectedIndex -ge 0; $unselectedIndex--) {

                if ($null -eq $refactorDefinition.State.Unselected[$unselectedIndex]) {

                    $null = $refactorDefinition.State.Unselected.RemoveAt($unselectedIndex)

                    if ($unselectedIndex -le $refactorDefinition.State.UnselectedIndex) {

                        $refactorDefinition.State.UnselectedIndex = [Math]::Max(-1,
                            $refactorDefinition.State.UnselectedIndex - 1)
                    }
                }
                else {
                    $path = (GenXdev\Expand-Path $refactorDefinition.State.Unselected[$unselectedIndex])

                    if ($path.StartsWith("$modulesPath\GenXdev")) {

                        $parts = $path.Substring($modulesPath.Length).Split('\', [System.StringSplitOptions]::RemoveEmptyEntries);

                        if ($parts.Length -gt 1) {
                            [Version] $version = $null
                            if ([Version]::tryParse($parts[1], [ref]$version)) {

                                $newPath = "$($modulesPath.TrimEnd('\'))\$($parts[0])\3.33.0\$($path.Substring($modulesPath.Length + $parts[0].Length+ $parts[1].Length + 3))"

                                if ($refactorDefinition.State.Unselected.IndexOf($newPath) -lt 0) {

                                    $refactorDefinition.State.Unselected[$unselectedIndex] = $newPath
                                }
                            }
                        }
                    }
                }
            }

            # update prompt key if specified and different from current value
            if ($PSBoundParameters.ContainsKey('PromptKey')) {

                if ($refactorDefinition.RefactorSettings.PromptKey -ne $PromptKey) {

                    # log the change for audit trail
                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = ('Prompt key changed from ' +
                                "'$($refactorDefinition.RefactorSettings.PromptKey)' " +
                                "to '$PromptKey'")
                        }
                    )

                    # apply the new prompt key value
                    $refactorDefinition.RefactorSettings.PromptKey = $PromptKey
                }
            }

            # update prompt text if provided and different
            if ($PSBoundParameters.ContainsKey('Prompt')) {

                if ($refactorDefinition.RefactorSettings.Prompt -ne $Prompt) {

                    # log the prompt text change
                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = ('Prompt changed from ' +
                                "'$($refactorDefinition.RefactorSettings.Prompt)' " +
                                "to '$Prompt'")
                        }
                    )

                    # apply the new prompt text
                    $refactorDefinition.RefactorSettings.Prompt = $Prompt
                }
            }

            # update selection script if provided and different
            if ($PSBoundParameters.ContainsKey('SelectionScript')) {

                if ($refactorDefinition.SelectionSettings.Script -ne $SelectionScript) {

                    # log the selection script change
                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = ('Selection script changed from ' +
                                "'$($refactorDefinition.SelectionSettings.Script)' " +
                                "to '$SelectionScript'")
                        }
                    )

                    # apply the new selection script
                    $refactorDefinition.SelectionSettings.Script = $SelectionScript
                }
            }

            # update reprocess modified files setting if changed
            if ($PSBoundParameters.ContainsKey('ReprocessModifiedFiles')) {

                if ($refactorDefinition.SelectionSettings.AutoAddModifiedFiles -ne $ReprocessModifiedFiles) {

                    # log the reprocess setting change
                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = ('ReprocessModifiedFiles changed from ' +
                                "'$($refactorDefinition.SelectionSettings.AutoAddModifiedFiles)' " +
                                "to '$ReprocessModifiedFiles'")
                        }
                    )

                    # apply the new reprocess setting
                    $refactorDefinition.SelectionSettings.AutoAddModifiedFiles = $ReprocessModifiedFiles
                }
            }

            if ($PSBoundParameters.ContainsKey('SelectionPrompt')) {

                if ($refactorDefinition.SelectionSettings.LLM.Prompt -ne $SelectionPrompt) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "Selection prompt changed from '$($refactorDefinition.SelectionSettings.LLM.Prompt))' to '$SelectionPrompt'"
                        }
                    )
                    $refactorDefinition.SelectionSettings.LLM.Prompt = $SelectionPrompt
                }
            }

            if ($PSBoundParameters.ContainsKey('Model')) {

                if ($refactorDefinition.SelectionSettings.LLM.Model -ne $Model) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "Model changed from '$($refactorDefinition.SelectionSettings.LLM.Model))' to '$Model'"
                        }
                    )
                    $refactorDefinition.SelectionSettings.LLM.Model = $Model
                }
            }

            if ($PSBoundParameters.ContainsKey('Temperature')) {

                if ($refactorDefinition.SelectionSettings.LLM.Temperature -ne $Temperature) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "Temperature changed from '$($refactorDefinition.SelectionSettings.LLM.Temperature))' to '$Temperature'"
                        }
                    )
                    $refactorDefinition.SelectionSettings.LLM.Temperature = $Temperature
                }
            }

            if ($PSBoundParameters.ContainsKey('LLMQueryType')) {

                if ($refactorDefinition.SelectionSettings.LLM.LLMQueryType -ne $LLMQueryType) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "LLMQueryType changed from '$($refactorDefinition.SelectionSettings.LLM.LLMQueryType))' to '$LLMQueryType'"
                        }
                    )
                    $refactorDefinition.SelectionSettings.LLM.LLMQueryType = $LLMQueryType
                }
            }

            if ($PSBoundParameters.ContainsKey('TimeoutSeconds')) {

                if ($refactorDefinition.SelectionSettings.LLM.TimeoutSeconds -ne $TimeoutSeconds) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "TimeoutSeconds changed from '$($refactorDefinition.SelectionSettings.LLM.TimeoutSeconds))' to '$TimeoutSeconds'"
                        }
                    )
                    $refactorDefinition.SelectionSettings.LLM.TimeoutSeconds = $TimeoutSeconds
                }
            }

            if ($PSBoundParameters.ContainsKey('ApiEndpoint')) {

                if ($refactorDefinition.SelectionSettings.LLM.ApiEndpoint -ne $ApiEndpoint) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "ApiEndpoint changed from '$($refactorDefinition.SelectionSettings.LLM.ApiEndpoint))' to '$ApiEndpoint'"
                        }
                    )
                    $refactorDefinition.SelectionSettings.LLM.ApiEndpoint = $ApiEndpoint
                }
            }

            if ($PSBoundParameters.ContainsKey('ApiKey')) {

                if ($refactorDefinition.SelectionSettings.LLM.ApiKey -ne $ApiKey) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "ApiKey changed from '$($refactorDefinition.SelectionSettings.LLM.ApiKey))' to '$ApiKey'"
                        }
                    )
                    $refactorDefinition.SelectionSettings.LLM.ApiKey = $ApiKey
                }
            }

            if ($PSBoundParameters.ContainsKey('NoSupportForJsonSchema')) {

                if ($refactorDefinition.SelectionSettings.LLM.NoSupportForJsonSchema -ne $($NoSupportForJsonSchema -eq $true)) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "NoSupportForJsonSchema changed from '$($refactorDefinition.SelectionSettings.LLM.NoSupportForJsonSchema))' to '$ApiKey'"
                        }
                    )
                    $refactorDefinition.SelectionSettings.LLM.NoSupportForJsonSchema = $($NoSupportForJsonSchema -eq $true)
                }
            }

            if ($PSBoundParameters.ContainsKey('ApiKey')) {

                if ($refactorDefinition.SelectionSettings.LLM.ApiKey -ne $ApiKey) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "ApiKey changed from '$($refactorDefinition.SelectionSettings.LLM.ApiKey))' to '$ApiKey'"
                        }
                    )
                    $refactorDefinition.SelectionSettings.LLM.ApiKey = $ApiKey
                }
            }

            if ($PSBoundParameters.ContainsKey('ExposedCmdLets')) {

                if ($refactorDefinition.SelectionSettings.LLM.ExposedCmdLets -ne $ExposedCmdLets) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "ExposedCmdLets changed from '$($refactorDefinition.SelectionSettings.LLM.ExposedCmdLets))' to '$ExposedCmdLets'"
                        }
                    )
                    $refactorDefinition.SelectionSettings.LLM.ExposedCmdLets = $ExposedCmdLets
                }
            }

            if ($PSBoundParameters.ContainsKey('Priority')) {

                if ($refactorDefinition.Priority -ne $Priority) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "Priority changed from '$($refactorDefinition.Priority))' to '$Priority'"
                        }
                    )
                    $refactorDefinition.Priority = $Priority
                }
            }

            if ($PSBoundParameters.ContainsKey('KeysToSend')) {

                if ($refactorDefinition.RefactorSettings.KeysToSend -ne $KeysToSend) {

                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "KeysToSend changed from '$($refactorDefinition.RefactorSettings.KeysToSend))' to '$KeysToSend'"
                        }
                    )
                    $refactorDefinition.RefactorSettings.KeysToSend = $KeysToSend
                }
            }

            $newCode = $PSBoundParameters.ContainsKey('Code') ? ($Code ? 1 : 0) : -1;
            if ($refactorDefinition.RefactorSettings.Code -ne $newCode) {

                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = "Code changed from '$($refactorDefinition.RefactorSettings.Code))' to '$newCode'"
                    }
                )
                $refactorDefinition.RefactorSettings.Code = $newCode
            }

            $newVisualStudio = $PSBoundParameters.ContainsKey('VisualStudio') ? ($VisualStudio ? 1 : 0) : -1;
            if ($refactorDefinition.RefactorSettings.VisualStudio -ne $newVisualStudio) {

                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = "VisualStudio changed from '$($refactorDefinition.RefactorSettings.VisualStudio))' to '$newVisualStudio'"
                    }
                )

                $refactorDefinition.RefactorSettings.VisualStudio = $newVisualStudio
            }

            if ($null -ne $SelectByModifiedDateFrom) {

                # copy all refactored files to FilesToAdd
                $FilesToAdd += @(
                    $refactorDefinition.State.Refactored | Microsoft.PowerShell.Core\ForEach-Object {

                        if ([string]::IsNullOrWhiteSpace($_)) { return }
                        $fi = [System.IO.FileInfo]::new($_);

                        if ($fi.Exists -and $fi.LastWriteTime -ge $SelectByModifiedDateFrom) {

                            $fi
                        }
                    }
                );

                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = "New file selection made: Redo all files modifief from date '$SelectByModifiedDateFrom'"
                    }
                )
            }

            if ($null -ne $SelectByModifiedDateTo) {

                # copy all refactored files to FilesToAdd
                $FilesToAdd += @(
                    $refactorDefinition.State.Refactored | Microsoft.PowerShell.Core\ForEach-Object {

                        if ([string]::IsNullOrWhiteSpace($_)) { return }

                        $fi = [System.IO.FileInfo]::new($_);

                        if ($fi.Exists -and $fi.LastWriteTime -lt $SelectByModifiedDateFrom) {

                            $fi
                        }
                    }
                );

                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = "New file selection made: Redo all files modifief to date '$SelectByModifiedDateTo'"
                    }
                )
            }

            if ($null -ne $SelectByCreationDateFrom) {

                # copy all refactored files to FilesToAdd
                $FilesToAdd += @(
                    $refactorDefinition.State.Refactored | Microsoft.PowerShell.Core\ForEach-Object {

                        if ([string]::IsNullOrWhiteSpace($_)) { return }

                        $fi = [System.IO.FileInfo]::new($_);

                        if ($fi.Exists -and $fi.CreationTime -ge $SelectByModifiedDateFrom) {

                            $fi
                        }
                    }
                );

                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = "New file selection made: Redo all files created from date '$SelectByCreationDateFrom'"
                    }
                )
            }

            if ($null -ne $SelectByCreationDateTo) {

                # copy all refactored files to FilesToAdd
                $FilesToAdd += @(
                    $refactorDefinition.State.Refactored | Microsoft.PowerShell.Core\ForEach-Object {

                        if ([string]::IsNullOrWhiteSpace($_)) { return }

                        $fi = [System.IO.FileInfo]::new($_);

                        if ($fi.Exists -and $fi.CreationTime -lt $SelectByModifiedDateFrom) {

                            $fi
                        }
                    }
                );

                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = "New file selection made: Redo all files created to date '$SelectByCreationDateTo'"
                    }
                )
            }

            if ($RedoLast -and $refactorDefinition.State.Refactored.Count -gt 0) {

                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = 'Redoing last refactor'
                    }
                )

                $refactorDefinition.State.RefactoredIndex = [Math]::Max(-1,
                    $refactorDefinition.State.RefactoredIndex - 1)
            }
            elseif ($Reset) {

                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = 'Resetting refactor set'
                    }
                )
                $refactorDefinition.State.RefactoredIndex = -1
                $refactorDefinition.State.Selected = @(@(
                        $refactorDefinition.State.Selected +
                        $refactorDefinition.State.Refactored
                    ) | Microsoft.PowerShell.Utility\Select-Object -Unique)
                $null = $refactorDefinition.State.Refactored.Clear();
            }

            if ($MarkAllCompleted) {

                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = 'Marking all files as refactored'
                    }
                )

                $refactorDefinition.State.Refactored = @(@(
                        $refactorDefinition.State.Refactored +
                        $refactorDefinition.State.Selected
                    ) | Microsoft.PowerShell.Utility\Select-Object -Unique)
                $null = $refactorDefinition.State.Selected.Clear();
                $refactorDefinition.State.SelectedIndex = $refactorDefinition.State.Selected.Count - 1;
                $refactorDefinition.State.RefactoredIndex = $refactorDefinition.State.Refactored.Count - 1;
                $refactorDefinition.State.PercentageComplete = 100;
            }

            if ($ResetLMSelections) {

                $null = $refactorDefinition.Log.Add(
                    [GenXdev.Helpers.RefactorLogItem]@{
                        Timestamp = $now
                        Message   = 'Resetting LLM selections'
                    }
                )

                $refactorDefinition.State.SelectedIndex = -1;
                $refactorDefinition.State.Unselected = @(@(
                        $refactorDefinition.State.Unselected +
                        $refactorDefinition.State.Selected
                    ) | Microsoft.PowerShell.Utility\Select-Object -Unique)
                $null = $refactorDefinition.State.Selected.Clear();
            }

            # detect and fix unprocessed files in Refactored collection
            if ($refactorDefinition.State.Refactored.Count -gt 0 -and
                $refactorDefinition.State.RefactoredIndex -lt ($refactorDefinition.State.Refactored.Count - 1)) {

                # move unprocessed files back to Selected for processing
                $unprocessedFiles = @()
                for ($i = $refactorDefinition.State.RefactoredIndex + 1; $i -lt $refactorDefinition.State.Refactored.Count; $i++) {
                    $file = $refactorDefinition.State.Refactored[$i]
                    if (-not [string]::IsNullOrWhiteSpace($file)) {
                        $unprocessedFiles += $file

                        # add to Selected if not already there
                        if ($refactorDefinition.State.Selected.IndexOf($file) -lt 0) {
                            $null = $refactorDefinition.State.Selected.Add($file)
                        }
                    }
                }

                # remove unprocessed files from Refactored collection
                if ($unprocessedFiles.Count -gt 0) {
                    for ($i = $refactorDefinition.State.Refactored.Count - 1; $i -gt $refactorDefinition.State.RefactoredIndex; $i--) {
                        $null = $refactorDefinition.State.Refactored.RemoveAt($i)
                    }

                    # log the correction operation
                    $null = $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "Moved $($unprocessedFiles.Count) unprocessed files from Refactored back to Selected: $($unprocessedFiles -join ', ')"
                        }
                    )

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Corrected incomplete state: moved $($unprocessedFiles.Count) unprocessed files " +
                        "from RefactoredIndex $($refactorDefinition.State.RefactoredIndex) back to Selected"
                    )
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Processing refactor definition: $($refactorDefinition.Name)"

            # execute selection script to get automatically selected files
            # only when PerformAutoSelections or PerformAISelections is specified
            [System.IO.FileInfo[]] $automaticFiles = @(
                if (-not [string]::IsNullOrWhiteSpace(
                        $refactorDefinition.SelectionSettings.Script) -and
                    ($PerformAutoSelections -or $PerformAISelections)) {

                    Microsoft.PowerShell.Utility\Write-Verbose 'Executing selection script'
                    if (-not $Clear) {
                        try {
                            Microsoft.PowerShell.Management\Push-Location $psRootPath
                            try {
                                Microsoft.PowerShell.Utility\Invoke-Expression -Command $refactorDefinition.SelectionSettings.Script
                            }
                            finally {
                                Microsoft.PowerShell.Management\Pop-Location
                            }
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Warning "$($_.Exception.Message)"
                        }
                    }
                }
            ) + @($FilesToAdd | Microsoft.PowerShell.Core\ForEach-Object {

                    if ($null -ne $_) {

                        $item = Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath (GenXdev\Expand-Path $_) -ErrorAction SilentlyContinue
                        if ($null -ne $item) {

                            $item
                        }
                    }
                }) |
                Microsoft.PowerShell.Core\Where-Object { $null -ne $_ -and $_.Exists }

            if ($null -ne $automaticFiles -and $automaticFiles.Count -gt 0) {

                # process new files to be added
                @($automaticFiles) | Microsoft.PowerShell.Core\ForEach-Object {

                    if ($null -eq $_ ) { return }

                    # verify file still exists before processing
                    if (-not $_.Exists) {
                        Microsoft.PowerShell.Utility\Write-Verbose "Skipping deleted file: $($_.FullName)"
                        return
                    }

                    # get the full path as string for collection operations
                    $filePath = $_.FullName

                    # check if file exists in any collection
                    $indexRefactored = $refactorDefinition.State.Refactored.IndexOf($filePath)
                    $indexSelected = $refactorDefinition.State.Selected.IndexOf($filePath)
                    $fileInUnselected = $refactorDefinition.State.Unselected.IndexOf($filePath)

                    # add file if not already present
                    if ($indexRefactored -lt 0 -and $indexSelected -lt 0 -and
                        $fileInUnselected -lt 0) {

                        # add to selected if no LLM prompt, otherwise to unselected
                        if ([string]::IsNullOrWhiteSpace(
                                $refactorDefinition.SelectionSettings.LLM.Prompt)) {

                            $null = $refactorDefinition.State.Selected.Add($filePath)
                        }
                        else {

                            $null = $refactorDefinition.State.Unselected.Add($filePath)
                        }

                        $script:filesAdded++
                        return;
                    }

                    # check if file should be reprocessed due to explicit addition or modification
                    $shouldReprocess = $false

                    # explicit addition via FilesToAdd parameter
                    if ($null -ne $FilesToAdd -and $FilesToAdd.Count -gt 0) {

                        if ($expandedFilesToAdd -contains $filePath) {
                            $shouldReprocess = $true
                        }
                    }

                    # automatic reprocessing of modified files
                    if ($refactorDefinition.SelectionSettings.AutoAddModifiedFiles) {
                        try {
                            if ($_.Exists -and
                                ($refactorDefinition.State.LastUpdated -lt ($_.LastWriteTimeUtc))) {
                                $shouldReprocess = $true
                            }
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Verbose "Could not check modification time for file: $filePath - $($_.Exception.Message)"
                        }
                    }

                    if ($shouldReprocess) {

                        # locate file in collections
                        $indexRefactored = $refactorDefinition.State.Refactored.IndexOf($_)
                        $indexSelected = $refactorDefinition.State.Selected.IndexOf($_)
                        # $indexUnselected = $refactorDefinition.State.Unselected.IndexOf($_)

                        if ($indexRefactored -ge 0) {

                            $null = $refactorDefinition.State.Refactored.RemoveAt($indexRefactored)
                            if ($indexRefactored -le $refactorDefinition.State.RefactoredIndex) {

                                $refactorDefinition.State.RefactoredIndex = [Math]::Max(-1,
                                    $refactorDefinition.State.RefactoredIndex - 1)
                            }
                            $indexRefactored = -1;
                            if ($indexSelected -lt 0) {

                                $null = $refactorDefinition.State.Selected.Add($filePath)
                            }
                        }
                    }
                }
            }


            # process files marked for removal
            $FilesToRemove | Microsoft.PowerShell.Core\ForEach-Object {

                # locate file in collections
                $indexRefactored = $refactorDefinition.State.Refactored.IndexOf($_)
                $indexSelected = $refactorDefinition.State.Selected.IndexOf($_)
                $indexUnselected = $refactorDefinition.State.Unselected.IndexOf($_)

                # remove from refactored collection and update index
                if ($indexRefactored -ge 0) {

                    $target = "File: $($_)"
                    $action = 'Remove from refactored set'

                    if ($PSCmdlet.ShouldProcess($target, $action)) {
                        $null = $refactorDefinition.State.Refactored.RemoveAt($indexRefactored)
                        if ($indexRefactored -le $refactorDefinition.State.RefactoredIndex) {

                            $refactorDefinition.State.RefactoredIndex = [Math]::Max(-1,
                                $refactorDefinition.State.RefactoredIndex - 1)
                        }
                        $indexRefactored = -1
                        $script:filesRemoved++
                    }
                }

                # remove from selected collection and update index
                if ($indexSelected -ge 0) {

                    $null = $refactorDefinition.State.Selected.RemoveAt($indexSelected)
                    if ($indexSelected -le $refactorDefinition.State.SelectedIndex) {

                        $refactorDefinition.State.SelectedIndex = [Math]::Max(-1,
                            $refactorDefinition.State.SelectedIndex - 1)
                    }
                    $indexSelected = -1
                }

                # remove from unselected collection and update index
                if ($indexUnselected -ge 0) {

                    $null = $refactorDefinition.State.Unselected.RemoveAt($indexUnselected)
                    if ($indexUnselected -le $refactorDefinition.State.UnselectedIndex) {

                        $refactorDefinition.State.UnselectedIndex = [Math]::Max(-1,
                            $refactorDefinition.State.UnselectedIndex - 1)
                    }
                    $indexUnselected = -1
                }
            }

            # clean up deleted files if requested
            if ($CleanUpDeletedFiles) {

                # clean refactored collection
                for ($refactoredIndex = $refactorDefinition.State.Refactored.Count - 1;
                    $refactoredIndex -ge 0; $refactoredIndex--) {

                    if ($null -eq $refactorDefinition.State.Refactored[$refactoredIndex]) {

                        $null = $refactorDefinition.State.Refactored.RemoveAt($refactoredIndex)

                    }
                    else {
                        try {
                            $path = (GenXdev\Expand-Path ($refactorDefinition.State.Refactored[$refactoredIndex]))

                            if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $path -PathType Leaf)) {

                                $null = $refactorDefinition.State.Refactored.RemoveAt($refactoredIndex)
                            }
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Verbose "Could not process refactored file path: $($refactorDefinition.State.Refactored[$refactoredIndex]) - $($_.Exception.Message)"
                            # Remove invalid path entry
                            $null = $refactorDefinition.State.Refactored.RemoveAt($refactoredIndex)
                        }
                    }

                    if ($refactorDefinition.State.RefactoredIndex -ge $refactoredIndex) {

                        $refactorDefinition.State.RefactoredIndex = [Math]::Max(-1,
                            $refactorDefinition.State.RefactoredIndex - 1)
                    }
                }

                # clean selected collection
                for ($selectedIndex = $refactorDefinition.State.Selected.Count - 1;
                    $selectedIndex -ge 0; $selectedIndex--) {

                    try {
                        $path = (GenXdev\Expand-Path $refactorDefinition.State.Selected[$selectedIndex])

                        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $path -PathType Leaf)) {

                            $null = $refactorDefinition.State.Selected.RemoveAt($selectedIndex)
                        }
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose "Could not process selected file path: $($refactorDefinition.State.Selected[$selectedIndex]) - $($_.Exception.Message)"
                        # Remove invalid path entry
                        $null = $refactorDefinition.State.Selected.RemoveAt($selectedIndex)
                    }

                    if ($refactorDefinition.State.SelectedIndex -ge $selectedIndex) {

                        $refactorDefinition.State.SelectedIndex = [Math]::Max(-1,
                            $refactorDefinition.State.SelectedIndex - 1)
                    }
                }

                # clean unselected collection
                for ($unselectedIndex = $refactorDefinition.State.Unselected.Count - 1;
                    $unselectedIndex -ge 0; $unselectedIndex--) {

                    try {
                        $path = (GenXdev\Expand-Path $refactorDefinition.State.Unselected[$unselectedIndex])

                        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $path -PathType Leaf)) {

                            $null = $refactorDefinition.State.Unselected.RemoveAt($unselectedIndex)
                        }
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose "Could not process unselected file path: $($refactorDefinition.State.Unselected[$unselectedIndex]) - $($_.Exception.Message)"
                        # Remove invalid path entry
                        $null = $refactorDefinition.State.Unselected.RemoveAt($unselectedIndex)
                    }

                    if ($refactorDefinition.State.UnselectedIndex -ge $unselectedIndex) {

                        $refactorDefinition.State.UnselectedIndex = [Math]::Max(-1,
                            $refactorDefinition.State.UnselectedIndex - 1)
                    }
                }
            }


            if ($ReprocessModifiedFiles) {
                (@($refactorDefinition.State.Refactored) + @($refactorDefinition.State.Selected) + @($refactorDefinition.State.Unselected)) | Microsoft.PowerShell.Core\ForEach-Object {

                    $fileInfo = Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath $_ -ErrorAction SilentlyContinue
                    if (-not $FileInfo) { return }
                    if ($refactorDefinition.State.LastUpdated -lt ($FileInfo.LastWriteTimeUtc)) {

                        # locate file in collections
                        $indexRefactored = $refactorDefinition.State.Refactored.IndexOf($_)
                        $indexSelected = $refactorDefinition.State.Selected.IndexOf($_)
                        # $indexUnselected = $refactorDefinition.State.Unselected.IndexOf($_)

                        if ($indexRefactored -ge 0) {

                            $null = $refactorDefinition.State.Refactored.RemoveAt($indexRefactored)
                            if ($indexRefactored -le $refactorDefinition.State.RefactoredIndex) {

                                $refactorDefinition.State.RefactoredIndex = [Math]::Max(-1,
                                    $refactorDefinition.State.RefactoredIndex - 1)
                            }
                            if ($indexSelected -lt 0) {

                                $null = $refactorDefinition.State.Selected.Add($filePath)
                            }
                        }
                    }
                }
            }

            # handle llm selections if enabled
            if ((-not [string]::IsNullOrWhiteSpace($refactorDefinition.SelectionSettings.LLM.Prompt)) -and
                (!!$PerformAutoSelections -or !!$PerformAISelections)) {

                if (((-not $AskBeforeLLMSelection) -or ($refactorDefinition.State.Selected.Count -eq 0)) -and
                    $refactorDefinition.State.Unselected.Count -ge 0) {

                    $userAnswer = 1;

                    if ($AskBeforeLLMSelection -and (-not $Script:_AlwaysRunLLMDuringRefactors)) {

                        if ($Speak) {

                            GenXdev\Start-TextToSpeech 'What to do next?'
                        }

                        $userAnswer = $host.ui.PromptForChoice(
                            'There are only files left that need an LLM invocation',
                            'What to do next?',
                            @('&Allways run invocations', '&Run all invocation now', '&Run invocation', "&Don't invoke now"),
                            0
                        )
                    }

                    if ($userAnswer -eq 0) {

                        $Script:_AlwaysRunLLMDuringRefactors = $true
                    }
                    if ($userAnswer -eq 1) {

                        $script:onlyFirst = $false
                    }
                    elseif ($userAnswer -eq 3) {

                        continue
                    }

                    if ($RetryFailedLLMSelections) {

                        $refactorDefinition.State.UnselectedIndex = -1;
                    }
                }

                $refactorDefinition.State.UnselectedIndex++;

                $script:nextFile = $refactorDefinition.State.Unselected[$refactorDefinition.State.UnselectedIndex];
                function goNext {

                    $script:nextFile = $null;

                    while ($refactorDefinition.State.UnselectedIndex -lt $refactorDefinition.State.Unselected.Count -and
                        ($null -eq $script:nextFile -or ((-not [IO.File]::Exists($script:nextFile))))) {

                        $refactorDefinition.State.UnselectedIndex = [Math]::Min(
                            $refactorDefinition.State.UnselectedIndex + 1,
                            $refactorDefinition.State.Unselected.Count - 1
                        )

                        if ($refactorDefinition.State.UnselectedIndex -lt $refactorDefinition.State.Unselected.Count) {

                            $script:nextFile = $refactorDefinition.State.Unselected[$refactorDefinition.State.UnselectedIndex];
                        }
                        else {

                            $script:nextFile = $null;
                        }
                    }
                }

                goNext

                while (($null -ne $script:nextFile) -and ($script:last -ne $script:nextFile)) {

                    try {
                        # Create a string builder for verbose output
                        $verboseOutput = [System.Text.StringBuilder]::new()

                        # Create a scriptblock to capture verbose output
                        $verboseScriptBlock = {
                            param($Message)
                            $null = $verboseOutput.AppendLine($Message)
                        }

                        # Register temporary verbose handler
                        $null = Microsoft.PowerShell.Utility\Register-EngineEvent -SourceIdentifier 'Verbose' -Action $verboseScriptBlock

                        # Run the test and get the result
                        $result = GenXdev\Test-RefactorLLMSelection `
                            -RefactorDefinition $refactorDefinition `
                            -Path ($script:nextFile)

                    }
                    catch {
                        $result = $false
                        $now = GenXdev\UtcNow
                        $refactorDefinition.Log.Add(
                            [GenXdev.Helpers.RefactorLogItem]@{
                                Timestamp = $now
                                Message   = "Error during LLM selection of file '$($script:nextFile)' : $($_.Exception.Message)"
                            }
                        )
                    }
                    finally {
                        # Clean up verbose handling
                        $null = Microsoft.PowerShell.Utility\Unregister-Event -SourceIdentifier 'Verbose' -ErrorAction SilentlyContinue
                    }

                    if ($result -eq $true) {

                        $now = GenXdev\UtcNow
                        $refactorDefinition.Log.Add(
                            [GenXdev.Helpers.RefactorLogItem]@{
                                Timestamp = $now
                                Message   = "File '$($script:nextFile)' was selected by LLM for refactoring`n$($verboseOutput.ToString())"
                            }
                        )

                        $indexRefactored = $refactorDefinition.State.Refactored.IndexOf(($script:nextFile))
                        $indexSelected = $refactorDefinition.State.Selected.IndexOf(($script:nextFile))
                        $indexUnselected = $refactorDefinition.State.Unselected.IndexOf(($script:nextFile))

                        if ($indexSelected -lt 0) {

                            $null = $refactorDefinition.State.Selected.Add(($script:nextFile))
                        }

                        if ($indexUnselected -ge 0) {

                            $null = $refactorDefinition.State.Unselected.RemoveAt($indexUnselected)

                            if ($indexUnselected -le $refactorDefinition.State.UnselectedIndex) {

                                $refactorDefinition.State.UnselectedIndex = [Math]::Max(-1,
                                    $refactorDefinition.State.UnselectedIndex - 1)
                            }
                        }

                        if ($indexRefactored -ge 0) {

                            $refactorDefinition.State.Refactored.RemoveAt($indexRefactored)
                            if ($indexRefactored -le $refactorDefinition.State.RefactoredIndex) {

                                $refactorDefinition.State.RefactoredIndex = [Math]::Max(-1,
                                    $refactorDefinition.State.RefactoredIndex - 1)
                            }
                        }

                        # build splatted params to forward PreferencesDatabasePath,
                        # SessionOnly, SkipSession etc. to preference cmdlets
                        if (-not $getPrefParams) {
                            $getPrefParams = GenXdev\Copy-IdenticalParamValues `
                                -BoundParameters $PSBoundParameters `
                                -FunctionName 'GenXdev\Get-GenXdevPreference'
                            $setPrefParams = GenXdev\Copy-IdenticalParamValues `
                                -BoundParameters $PSBoundParameters `
                                -FunctionName 'GenXdev\Set-GenXdevPreference'
                        }

                        # persist changes to preferences
                        if ($PSCmdlet.ShouldProcess(
                                "Refactor set: $($refactorDefinition.Name)",
                                'Save changes')) {

                            $json = $refactorDefinition | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress
                            $latestJson = (GenXdev\Get-GenXdevPreference @getPrefParams `
                                    -Name "refactor_set_$($refactorDefinition.Name)" `
                                    -ErrorAction SilentlyContinue
                            )
                            if ($null -ne $latestJson) {

                                $latest = $latestJson | Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue
                                if ($null -ne $latest -and ($latest.State.LastUpdated -gt $refactorDefinition.State.LastUpdated)) {

                                    $latest.State = $refactorDefinition.State;
                                    $latest.Log = $refactorDefinition.Log;

                                    $refactorDefinition = $latest;
                                }
                            }

                            $now = GenXdev\UtcNow
                            $refactorDefinition.State.LastUpdated = $now
                            $json = $refactorDefinition | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress
                            GenXdev\Set-GenXdevPreference @setPrefParams `
                                -Name "refactor_set_$($refactorDefinition.Name)" `
                                -Value $json `
                                -ErrorAction SilentlyContinue
                        }

                        if ($script:onlyFirst) {

                            break
                        }
                    }
                    else {
                        $now = GenXdev\UtcNow
                        $refactorDefinition.Log.Add(
                            [GenXdev.Helpers.RefactorLogItem]@{
                                Timestamp = $now
                                Message   = "File '$($script:nextFile)' was NOT selected by LLM for refactoring`n$($verboseOutput.ToString())"
                            }
                        )
                    }

                    $script:last = $script:nextFile
                    goNext
                }
            }

            # update state and persist changes if modifications were made
            if (($null -ne $refactorDefinition) -and
                ($refactorDefinition -is [GenXdev.Helpers.RefactorDefinition])) {

                Microsoft.PowerShell.Utility\Write-Verbose ("Updating refactor set state with $script:filesAdded added " +
                    "and $script:filesRemoved removed")

                $totalFilesDone = [Math]::Min($refactorDefinition.State.Refactored.Count, $refactorDefinition.State.RefactoredIndex + 1);

                $totalFiles = (
                    $refactorDefinition.State.Unselected.Count
                ) + (
                    $refactorDefinition.State.Selected.Count
                ) + (
                    $refactorDefinition.State.Refactored.Count
                )

                # calculate and update completion percentage
                $refactorDefinition.State.PercentageComplete = [System.Math]::Min(100, [Math]::Round(
                        (100 * $totalFilesDone) / [Math]::Max(1, $totalFiles),
                        0
                    ))

                $now = GenXdev\UtcNow

                if ($script:filesAdded -gt 0 -or $script:filesRemoved -gt 0) {

                    # log status update
                    $refactorDefinition.Log.Add(
                        [GenXdev.Helpers.RefactorLogItem]@{
                            Timestamp = $now
                            Message   = "Refactor set updated, $script:filesAdded files added, " +
                            "$script:filesRemoved files removed, " +
                            "($($refactorDefinition.State.PercentageComplete)% " +
                            'complete)'
                        }
                    )
                }

                # persist changes to preferences
                if ($PSCmdlet.ShouldProcess(
                        "Refactor set: $($refactorDefinition.Name)",
                        'Save changes')) {

                    $latestJson = (GenXdev\Get-GenXdevPreference @getPrefParams `
                            -Name "refactor_set_$($refactorDefinition.Name)" `
                            -ErrorAction SilentlyContinue
                    )

                    $now = GenXdev\UtcNow
                    $refactorDefinition.State.LastUpdated = $now
                    $json = $refactorDefinition | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 15 -Compress
                    GenXdev\Set-GenXdevPreference `
                        -Name "refactor_set_$($refactorDefinition.Name)" `
                        -Value $json `
                        -PreferencesDatabasePath $PreferencesDatabasePath `
                        -ErrorAction SilentlyContinue
                }

                Microsoft.PowerShell.Utility\Write-Verbose 'Refactor set updated successfully'
            }
        }
    }

    end {
    }
}
###############################################################################