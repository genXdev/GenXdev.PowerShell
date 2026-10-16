###############################################################################
<#
.SYNOPSIS
Executes a tool call function with validation and parameter filtering.

.DESCRIPTION
This function processes tool calls by validating arguments, filtering parameters,
and executing callbacks with proper confirmation handling. It supports both script
block and command info callbacks.

Every exposed cmdlet advertises the output stream switch that
ConvertTo-LLMOpenAIApiFunctionDefinition adds to its schema. That switch is
consumed here and is never passed on to the callback. With it, the verbose,
information and warning streams travel back next to the output; without it, only
errors do, which are always returned. Json output is wrapped so every stream has
its own named property, text output has the streams appended as labelled
sections.

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

.PARAMETER ToolCall
A hashtable containing the function details and arguments to be executed.

.PARAMETER Functions
Array of function definitions that can be called as tools.

.PARAMETER ExposedCmdLets
Array of PowerShell command definitions available as tools.

.PARAMETER NoConfirmationToolFunctionNames
Array of command names that can execute without user confirmation.

.PARAMETER ForceAsText
Forces the output to be formatted as text.

.EXAMPLE
Invoke-CommandFromToolCall -ToolCall $toolCall -Functions $functions `
    -ExposedCmdLets $exposedCmdlets

.EXAMPLE
$result = Invoke-CommandFromToolCall $toolCall $functions -ForceAsText
#>
function Invoke-CommandFromToolCall {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'Tool call object containing function details and args'
        )]
        [ValidateNotNull()]
        [hashtable]
        $ToolCall,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of function definitions'
        )]
        [hashtable[]]
        $Functions = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Array of PowerShell command definitions to use as tools'
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]]
        $ExposedCmdLets = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Array of command names that don't require confirmation"
        )]
        [Alias('NoConfirmationFor')]
        [string[]]
        $NoConfirmationToolFunctionNames = @(),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force output as text'
        )]
        [switch]
        $ForceAsText
    )

    begin {
        # initialize the result object with default values
        $result = [GenXdev.Helpers.ExposedToolCallInvocationResult] @{}
        $result.CommandExposed = $false
        $result.Reason = 'Function not found, check spelling and availability'
        $result.Output = $null
        $result.OutputType = $null
        $result.FullName = $null

        # extract and convert arguments from the tool call
        $result.UnfilteredArguments = $ToolCall.function.arguments |
            Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue |
            GenXdev\ConvertTo-HashTable |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        Microsoft.PowerShell.Utility\Write-Verbose "Processing tool call: $($ToolCall.function.name)"
        Microsoft.PowerShell.Utility\Write-Verbose "Unfiltered arguments: $($result.UnfilteredArguments |
            Microsoft.PowerShell.Utility\ConvertTo-Json)"

        $result.FilteredArguments = [hashtable] @{}
        $result.ExposedCmdLet = $null
        $result.Error = $null

        # convert captured stream records into plain message strings
        function convertRecordMessages {
            param([System.Collections.Generic.List[object]] $Records)

            return , @($Records | Microsoft.PowerShell.Core\ForEach-Object {

                    if ($PSItem -is [System.Management.Automation.InformationRecord]) {
                        "$($PSItem.MessageData)"
                    }
                    elseif ($PSItem -is [System.Management.Automation.ErrorRecord]) {
                        $PSItem.Exception.Message
                    }
                    else {
                        $PSItem.Message
                    }
                })
        }

        # invoke a callback, keeping its output clean and capturing what it writes
        function invokeToolCallCallback {
            param(
                [object] $Callback,
                [hashtable] $Arguments,
                [bool] $IncludeAllOutputStreams = $false
            )

            $informationRecords = [System.Collections.Generic.List[object]]::new()
            $warningRecords = [System.Collections.Generic.List[object]]::new()
            $verboseRecords = [System.Collections.Generic.List[object]]::new()
            $errorRecords = [System.Collections.Generic.List[object]]::new()

            # sort each record the callback writes into its own stream list
            $classifyStreamRecord = {

                if ($PSItem -is [System.Management.Automation.InformationRecord]) {
                    $informationRecords.Add($PSItem)
                }
                elseif ($PSItem -is [System.Management.Automation.WarningRecord]) {
                    $warningRecords.Add($PSItem)
                }
                elseif ($PSItem -is [System.Management.Automation.VerboseRecord]) {
                    $verboseRecords.Add($PSItem)
                }
                elseif ($PSItem -is [System.Management.Automation.ErrorRecord]) {
                    $errorRecords.Add($PSItem)
                }
                else {
                    $PSItem
                }
            }

            $oldVerbosePreference = $VerbosePreference
            $oldWarningPreference = $WarningPreference
            $oldInformationPreference = $InformationPreference
            $oldErrorActionPreference = $ErrorActionPreference
            $VerbosePreference = 'Continue'
            $WarningPreference = 'Continue'
            $InformationPreference = 'Continue'

            # the errors a callback writes have to reach the caller, so only Stop and
            # Continue may govern it. SilentlyContinue, Inquire or Break would hide
            # them, block on them, or interrupt the run, so they are coerced.
            $ErrorActionPreference = if ($oldErrorActionPreference -in 'Stop', 'Continue') {
                $oldErrorActionPreference
            }
            else {
                'Continue'
            }

            $callbackOutput = $null

            # a forced ErrorAction may only be Stop or Continue, since anything else
            # would hide the errors this contract exists to return
            if ($Arguments.ContainsKey('ErrorAction')) {

                $requestedErrorAction = "$($Arguments['ErrorAction'])"

                if ($requestedErrorAction -notin 'Stop', 'Continue') {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Coercing ErrorAction '${requestedErrorAction}' to Continue " +
                        'for the callback.')

                    $Arguments['ErrorAction'] = 'Continue'
                }
            }

            try {
                if ($IncludeAllOutputStreams) {

                    # the caller asked for the diagnostics, so keep every stream
                    $callbackOutput = &$Callback @Arguments 2>&1 3>&1 4>&1 6>&1 |
                        Microsoft.PowerShell.Core\ForEach-Object $classifyStreamRecord
                }
                else {

                    # only errors travel back, the other streams stay where they belong
                    $callbackOutput = &$Callback @Arguments 2>&1 |
                        Microsoft.PowerShell.Core\ForEach-Object $classifyStreamRecord
                }
            }
            catch {
                $errorRecords.Add([System.Management.Automation.ErrorRecord]::new(
                        $PSItem.Exception,
                        'ToolCallExecutionError',
                        [System.Management.Automation.ErrorCategory]::OperationStopped,
                        $null))
            }
            finally {
                $VerbosePreference = $oldVerbosePreference
                $WarningPreference = $oldWarningPreference
                $InformationPreference = $oldInformationPreference
                $ErrorActionPreference = $oldErrorActionPreference
            }

            # errors always travel back, the diagnostic streams only on request
            $result.Errors = convertRecordMessages $errorRecords

            if ($IncludeAllOutputStreams) {
                $result.Information = convertRecordMessages $informationRecords
                $result.Warnings = convertRecordMessages $warningRecords
                $result.Verbose = convertRecordMessages $verboseRecords
            }

            $callbackOutput
        }
    }


    process {

        $fullToolFunction = $ToolCall.function.name
        $toolFunction = $fullToolFunction.Split('\')[1];

        # find all exising predefined function definitions that match the tool call
        $matchedFunctions = @(
            $Functions.function | Microsoft.PowerShell.Core\ForEach-Object {

                $fullFunction = $PSItem.Name
                $function = $fullFunction.Split('\')[1];
                if ([string]::IsNullOrWhiteSpace($function) -or [string]::IsNullOrWhiteSpace($toolFunction)) {

                    if ([string]::IsNullOrWhiteSpace($function) -and [string]::IsNullOrWhiteSpace($toolFunction)) {

                        if ($fullFunction -eq $fullToolFunction) {

                            $PSItem
                        }
                    }
                    elseif ([string]::IsNullOrWhiteSpace($toolFunction)) {

                        if ($function -eq $fullToolFunction) {

                            $PSItem
                        }
                    }
                    else {

                        if ($fullFunction -eq $toolFunction) {

                            $PSItem
                        }
                    }
                }
                else {

                    if ($function -eq $toolFunction) {

                        $PSItem
                    }
                }
            }
        )

        # process each matched function
        foreach ($matchedFunction in $matchedFunctions) {

            # start optimistic
            $result.CommandExposed = $true

            # start by checking if all required parameters are present
            $matchedFunction.parameters.required | Microsoft.PowerShell.Core\ForEach-Object {

                # reference next required parameter's name
                $definedParamName = $_

                $foundArguments = @(
                    $result.UnfilteredArguments.GetEnumerator() | Microsoft.PowerShell.Core\ForEach-Object {
                        if ($PSItem.Name -EQ $definedParamName) { $PSItem } }
                );

                if ($foundArguments.Count -eq 0) {

                    $result.CommandExposed = $false
                    $result.Reason = "Missing required parameter: $definedParamName"
                    $result.Output = $null
                    $result.OutputType = $null
                    $result.FullName = $null
                    $result.UnfilteredArguments = $ToolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue | GenXdev\ConvertTo-HashTable | Microsoft.PowerShell.Utility\Select-Object -First 1
                    $result.FilteredArguments = [hashtable] @{}
                    $result.ExposedCmdLet = $null
                    $result.Error = $null

                    # maybe there is another function that matches
                    break;
                }
            }

            if (-not $result.CommandExposed) {

                # maybe there is another function that matches
                break;
            }

            # check if all parameters are valid
            [Hashtable] $properies = $matchedFunction.parameters.properties

            foreach ($unfilteredArgument in $result.UnfilteredArguments.GetEnumerator()) {

                $unfilteredArgumentName = $unfilteredArgument.Name

                if ($unfilteredArgumentName -notin $properies.Keys) {

                    $result.CommandExposed = $false
                    $result.Reason = "Function found, but provided argument with name $unfilteredArgumentName not found in advertised tool function parameters"
                    $result.Output = $null
                    $result.OutputType = $null
                    $result.FullName = $null
                    $result.UnfilteredArguments = $ToolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue | GenXdev\ConvertTo-HashTable | Microsoft.PowerShell.Utility\Select-Object -First 1
                    $result.FilteredArguments = [hashtable] @{}
                    $result.ExposedCmdLet = $null
                    $result.Error = $null

                    # maybe there is another function that matches
                    break;
                }
            }

            if (-not $result.CommandExposed) {

                # maybe there is another function that matches
                break;
            }

            # add all properties and their values from the unfiltered to the filtered arguments
            $result.FilteredArguments = [hashtable] @{}
            foreach ($unfilteredArgument in $result.UnfilteredArguments.GetEnumerator()) {

                $unfilteredArgumentName = $unfilteredArgument.Name

                $result.FilteredArguments."$unfilteredArgumentName" = $unfilteredArgument.Value
            }

            # the output stream switch is consumed here and never reaches the callback
            $includeAllOutputStreams = $false
            $outputStreamsParameter = [GenXdev.Helpers.ExposedCmdletDefinition]::OutputStreamsParameterName

            if ($result.FilteredArguments.ContainsKey($outputStreamsParameter)) {

                $outputStreamsValue = $result.FilteredArguments[$outputStreamsParameter]

                # a sloppy caller can send the switch as text, and [bool]'false' is true
                $includeAllOutputStreams =
                    ($outputStreamsValue -is [bool] -and $outputStreamsValue) -or
                    ("$outputStreamsValue" -ieq 'true')

                $null = $result.FilteredArguments.Remove($outputStreamsParameter)
            }

            # check if there are any forced parameters
            $foundCmdlets = @(
                $ExposedCmdLets |
                    Microsoft.PowerShell.Utility\Sort-Object -Property Name -Descending |
                    Microsoft.PowerShell.Core\ForEach-Object {
                        if (
                        ($_.Name -EQ ($matchedFunction.name)) -or
                        ($_.Name -like "*\$($matchedFunction.name)") -or
                        ($matchedFunction.name -like "*\$($_.Name)")
                        ) { $_ }
                    }
            );

            foreach ($exposedCmdLet in $foundCmdlets) {

                $exposedCmdLetParamNames = @($exposedCmdLet.AllowedParams | Microsoft.PowerShell.Core\ForEach-Object { "$_".Split('=')[0] }) + @($exposedCmdLet.ForcedParams)

                $foundUnmatchingParam = $false;
                foreach ($filteredArgument in $result.FilteredArguments.GetEnumerator()) {

                    $filteredArgumentName = $filteredArgument.Name;

                    if ($filteredArgumentName -notin $exposedCmdLetParamNames) {

                        $foundUnmatchingParam = $true
                        break;
                    }
                }

                if ($foundUnmatchingParam) {

                    $result.CommandExposed = $false
                    $result.Reason = "Function found, but provided argument with name $filteredArgument. Name not found in advertised tool function parameters"
                    $result.Output = $null
                    $result.OutputType = $null
                    $result.FullName = $null
                    $result.UnfilteredArguments = $ToolCall.function.arguments | Microsoft.PowerShell.Utility\ConvertFrom-Json -ErrorAction SilentlyContinue | GenXdev\ConvertTo-HashTable | Microsoft.PowerShell.Utility\Select-Object -First 1
                    $result.FilteredArguments = [hashtable] @{}
                    $result.ExposedCmdLet = $null
                    $result.Error = $null

                    # maybe there is another function that matches
                    continue
                }

                foreach ($forcedParam in $exposedCmdLet.ForcedParams) {

                    $result.FilteredArguments."$($forcedParam.Name)" = $forcedParam.Value
                }

                $result.ExposedCmdLet = $exposedCmdLet
            }

            if (-not $result.CommandExposed) {

                # maybe there is another function that matches
                break;
            }

            $result.Reason = $null
            $result.Output = $null
            $result.FullName = $ToolCall.function.name

            $cb = $matchedFunction.callback;
            if ($cb -isnot [System.Management.Automation.ScriptBlock] -and
                $cb -isnot [System.Management.Automation.CommandInfo]) {

                throw "Callback is not a script block or command info, type: $(($cb.GetType().FullName))"
            }

            $tmpResult = $null

            try {
                # Execute callback
                # Add confirmation prompt for tool functions that require it
                if (($NoConfirmationToolFunctionNames -and $NoConfirmationToolFunctionNames.IndexOf($toolCall.function.name) -ge 0) -or
                    ($result.ExposedCmdLet -and (-not $result.ExposedCmdLet.Confirm))) {

                    $filteredArguments = $result.FilteredArguments;
                    $tmpResult = invokeToolCallCallback -Callback $cb -Arguments $filteredArguments -IncludeAllOutputStreams $includeAllOutputStreams
                }
                else {

                    $location = (Microsoft.PowerShell.Management\Get-Location).Path
                    $functionName = $toolCall.function.Name
                    $filteredArguments = $result.FilteredArguments;
                    $parametersLine = $filteredArguments.GetEnumerator() | Microsoft.PowerShell.Core\ForEach-Object {

                        $skip = $false;
                        $filteredArgumentName = $_.Name

                        if ($result.ExposedCmdlet) {

                            foreach ($name in $result.ExposedCmdLet.DontShowDuringConfirmationParamNames) {

                                if ($filteredArgumentName -like $name) {

                                    $skip = $true;
                                    break;
                                }
                            }
                        }

                        if (-not $skip) {

                            "-$($_.Name) ($($_.Value | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 10 -WarningAction SilentlyContinue))"
                        }
                        else {

                            "-$($_.Name) [value]"
                        }
                    } | Microsoft.PowerShell.Core\ForEach-Object {

                        $_ -join ' '
                    }

                    # Add confirmation prompt for tool functions that require it
                    # queued keystrokes must not approve a tool call on your behalf
                    if (-not [Console]::IsInputRedirected) {
                        while ([Console]::KeyAvailable) { $null = [Console]::ReadKey() }
                    }

                    switch ($host.ui.PromptForChoice(
                            'Confirm',
                            "Are you sure you want to ALLOW the LLM to execute: `r`nPS $location> $functionName $parametersLine",
                            @(
                                '&Allow',
                                '&Disallow, reject'), 0)) {
                        0 {
                            $tmpResult = invokeToolCallCallback -Callback $cb -Arguments $filteredArguments -IncludeAllOutputStreams $includeAllOutputStreams

                            break;
                        }

                        1 {
                            throw 'User cancelled execution'
                            break;
                        }
                    }
                }

                if ($null -eq $tmpResult -and $result.Errors.Count -eq 0) {
                    $tmpResult = 'null # No output (success, void return)'
                }

                # whether the callers present this output as text
                $asText = $ForceAsText -or
                    ($result.ExposedCmdLet -and
                    ($result.ExposedCmdLet.OutputText -eq $true))

                # streams travel with the output, structured for json and appended for text
                $streamsEnveloped = $false

                if (($result.Errors.Count + $result.Warnings.Count +
                        $result.Information.Count + $result.Verbose.Count) -gt 0) {

                    if ($asText) {

                        $sections = @()

                        foreach ($stream in @(
                                @{ Name = 'ERRORS'; Messages = $result.Errors },
                                @{ Name = 'WARNINGS'; Messages = $result.Warnings },
                                @{ Name = 'INFORMATION'; Messages = $result.Information },
                                @{ Name = 'VERBOSE'; Messages = $result.Verbose })) {

                            if ($stream.Messages.Count -gt 0) {

                                $sections += "--- $($stream.Name) ---"
                                $sections += $stream.Messages
                            }
                        }

                        $tmpResult = @(@($tmpResult |
                                    Microsoft.PowerShell.Core\Where-Object {
                                        $null -ne $PSItem
                                    }) + $sections)
                    }
                    else {

                        $tmpResult = @{
                            output      = $tmpResult
                            errors      = $result.Errors
                            warnings    = $result.Warnings
                            information = $result.Information
                            verbose     = $result.Verbose
                        }

                        # the envelope itself costs one level of json depth
                        $streamsEnveloped = $true
                    }
                }

                if ($null -ne $tmpResult) {

                    # check if the tmpResult is already a valid JSON string
                    # this can happen if the callback already converts to JSON
                    $isAlreadyJson = $false
                    try {
                        if ($tmpResult -is [string]) {
                            $jsonTest = $tmpResult |
                                Microsoft.PowerShell.Utility\ConvertFrom-Json `
                                    -ErrorAction Stop `
                                    -WarningAction SilentlyContinue
                            if ($jsonTest) {
                                $isAlreadyJson = $true
                                $result.OutputType = 'application/json'
                            }
                        }
                    }
                    catch {
                        # not valid JSON, continue with normal processing
                        $isAlreadyJson = $false
                    }

                    if ($isAlreadyJson) {
                        # already JSON, use it as is
                        $result.Output = $tmpResult
                    }
                    else {
                        # handle non-JSON output
                        $result.OutputType = 'string'

                        if ($tmpResult -isnot [string]) {

                            $result.OutputType = 'application/json'
                            $jsonDepth = 2;
                            if ($result.ExposedCmdLet -and $result.ExposedCmdLet.JsonDepth) {

                                $jsonDepth = $result.ExposedCmdLet.JsonDepth;
                            }
                            if ($streamsEnveloped) { $jsonDepth++ }
                            if ($asText) {

                                $tmpResult = (@($tmpResult) |
                                        Microsoft.PowerShell.Core\ForEach-Object { $_ | Microsoft.PowerShell.Utility\Out-String }) |
                                        Microsoft.PowerShell.Utility\ConvertTo-Json -Depth $jsonDepth `
                                            -WarningAction SilentlyContinue
                            }
                            else {

                                # Convert to JSON directly with error handling
                                try {
                                    $tmpResult = $tmpResult |
                                        Microsoft.PowerShell.Utility\ConvertTo-Json -Depth $jsonDepth `
                                            -WarningAction SilentlyContinue
                                }
                                catch {
                                    # If JSON conversion fails, try to create a simplified representation
                                    Microsoft.PowerShell.Utility\Write-Verbose "JSON conversion failed for $($tmpResult.GetType().Name): $($_.Exception.Message)"

                                    # Special handling for web response objects
                                    if ($tmpResult -is [Microsoft.PowerShell.Commands.WebResponseObject]) {
                                        $simplifiedWebResponse = @{
                                            StatusCode = $tmpResult.StatusCode
                                            StatusDescription = $tmpResult.StatusDescription
                                            Headers = @{}
                                            Content = if ($tmpResult.Content) { $tmpResult.Content.ToString() } else { "" }
                                            RawContentLength = $tmpResult.RawContentLength
                                        }

                                        # Add headers safely
                                        foreach ($header in $tmpResult.Headers.GetEnumerator()) {
                                            try {
                                                $simplifiedWebResponse.Headers[$header.Name] = $header.Value -join ", "
                                            }
                                            catch {
                                                $simplifiedWebResponse.Headers[$header.Name] = "[Could not serialize header value]"
                                            }
                                        }

                                        $tmpResult = $simplifiedWebResponse | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth $jsonDepth
                                    }
                                    else {
                                        # For other types, fall back to string representation
                                        $tmpResult = $tmpResult | Microsoft.PowerShell.Utility\Out-String
                                    }
                                }
                            }
                        }

                        $result.Output = $tmpResult
                    }
                }
            }
            catch {
                $result.Error = [PSCustomObject]@{
                    error           = $_.Exception.Message
                    exceptionThrown = $true
                    exceptionClass  = $_.Exception.GetType().FullName
                } | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 3 -WarningAction SilentlyContinue
            }

            # we only execute the first matching function
            break;
        }
    }

    end {

        Microsoft.PowerShell.Utility\Write-Output $result
    }
}