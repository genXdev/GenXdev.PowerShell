<###############################################################################
.SYNOPSIS
Converts PowerShell functions to LLM OpenAI API function definitions.

.DESCRIPTION
Takes exposed cmdlet definitions and generates LLM OpenAI API compatible function definitions
including parameter information and callback handlers.

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

.PARAMETER ExposedCmdLets
Array of custom objects containing function definitions and their allowed parameters to convert to LLM OpenAI API definitions.

.EXAMPLE
Get-Command Get-Process | ConvertTo-LLMOpenAIApiFunctionDefinition

#>
function ConvertTo-LLMOpenAIApiFunctionDefinition {

    [CmdletBinding()]
    [OutputType([System.Collections.Generic.List[hashtable]])]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    param(
        #######################################################################
        # Array of custom objects containing function definitions and their allowed parameters
        [Parameter(
            Mandatory = $false,
            Position = 0,
            ValueFromPipeline = $true,
            HelpMessage = 'PowerShell commands to convert to tool functions'
        )]
        [GenXdev.Helpers.ExposedCmdletDefinition[]] $ExposedCmdLets = @()
    )

    begin {

        # Initialize collection to store the converted function definitions
        [System.Collections.Generic.List[hashtable]] $result = Microsoft.PowerShell.Utility\New-Object 'System.Collections.Generic.List[System.Collections.Hashtable]'

        Microsoft.PowerShell.Utility\Write-Verbose 'Starting conversion of PowerShell functions to LLM OpenAI API format'
    }


    process {

        if ($ExposedCmdLets) {

            foreach ($currentCommand in $ExposedCmdLets) {

                # Retrieve command info for runtime callback (needed to
                # invoke the command at runtime) and for runtime type
                # checks (enum, array, list, switch detection).
                $commandInfo = Microsoft.PowerShell.Core\Get-Command `
                    -Name ($currentCommand.Name) `
                    -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Utility\Select-Object -First 1

                if ($null -eq $commandInfo) {
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Command $($currentCommand.Name) not found. Skipping."
                    continue
                }

                # Leverage Get-CmdletMetaData for all parameter metadata,
                # help messages, output types, and function description.
                $metaData = GenXdev\Get-CmdletMetaData `
                    -Name $currentCommand.Name `
                    -ErrorAction SilentlyContinue

                if ($null -eq $metaData) {
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Could not get metadata for $($currentCommand.Name). Skipping."
                    continue
                }

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Processing command: $($currentCommand.Name)"

                # Extract allowed parameters with optional type overrides
                $allowedParams = @($currentCommand.AllowedParams)

                # Collections to track parameter metadata
                [System.Collections.Generic.List[string]]$requiredParams = @()
                $propertiesTable = @{}

                # Process each parameter from Get-CmdletMetaData
                foreach ($param in $metaData.Parameters) {

                    # Check if parameter is in allowed list and extract
                    # optional type override (e.g. "Name=string").
                    # Match against parameter name AND aliases since
                    # ExposedCmdletDefinitions often use alias names
                    # (e.g. "SearchMask" for the "Name" parameter).
                    $found = $false
                    $typeStr = ''
                    foreach ($allowedParam in $allowedParams) {
                        $parts = "$allowedParam".Split('=')
                        $name = $parts[0].Trim()

                        if ($param.Name -like $name) {
                            $found = $true
                            if ($parts.Length -gt 1) {
                                $typeStr = $parts[1].Trim()
                            }
                            break
                        }

                        # Also check aliases (AllowedParams often
                        # reference parameters by their alias names)
                        if ($param.Aliases -and
                            $param.Aliases.Count -gt 0) {
                            foreach ($alias in $param.Aliases) {
                                if ($alias -like $name) {
                                    $found = $true
                                    if ($parts.Length -gt 1) {
                                        $typeStr = $parts[1].Trim()
                                    }
                                    break
                                }
                            }
                            if ($found) { break }
                        }
                    }

                    if (-not $found) { continue }

                    # Track mandatory parameters
                    if ($param.Mandatory -and
                        $requiredParams.Contains($param.Name) -eq $false) {
                        $null = $requiredParams.Add($param.Name)
                    }

                    # Determine LLM type: use type override if specified,
                    # otherwise convert the .NET type
                    $llmType = if ([string]::IsNullOrWhiteSpace($typeStr)) {
                        GenXdev\Convert-DotNetTypeToLLMType `
                            -DotNetType $param.ParameterType
                    }
                    else { $typeStr }

                    # Build parameter property dictionary
                    $propDef = @{
                        type            = $llmType
                        powershell_type = $param.ParameterType
                    }

                    if (-not [string]::IsNullOrWhiteSpace(
                            $param.HelpMessage)) {
                        $propDef.description = $param.HelpMessage
                    }

                    # Runtime type checks: enum, switch, array, list.
                    # Get-CmdletMetaData returns type names as strings,
                    # so we cross-reference with $commandInfo.Parameters
                    # for .NET reflection (IsEnum, IsArray, etc.).
                    $rtParam = $commandInfo.Parameters[$param.Name]
                    if ($rtParam) {
                        $rtType = $rtParam.ParameterType

                        # Enum → string + allowed values
                        if ($rtType.IsEnum) {
                            $propDef.type = 'string'
                            $propDef.enum = @($rtType.GetEnumNames())
                        }

                        # SwitchParameter → boolean
                        if ($rtType.FullName -eq
                            'System.Management.Automation.SwitchParameter') {
                            if ([string]::IsNullOrWhiteSpace($typeStr)) {
                                $propDef.type = 'boolean'
                            }
                            Microsoft.PowerShell.Utility\Write-Verbose `
                                "Switch parameter '$($param.Name)' set to type '$($propDef.type)'"
                        }

                        # Array types → array + items
                        if ($rtType.IsArray) {
                            $elementType = $rtType.GetElementType().FullName
                            $itemType = GenXdev\Convert-DotNetTypeToLLMType `
                                -DotNetType $elementType
                            $propDef.type = 'array'
                            $propDef.items = @{ type = $itemType }
                        }
                        elseif ($rtType.IsGenericType -and
                            $rtType.Name -like 'List`1*') {
                            $elementType =
                                $rtType.GetGenericArguments()[0].FullName
                            $itemType = GenXdev\Convert-DotNetTypeToLLMType `
                                -DotNetType $elementType
                            $propDef.type = 'array'
                            $propDef.items = @{ type = $itemType }
                        }
                    }

                    $propertiesTable[$param.Name] = $propDef
                }

                # Function-level description: prefer the explicit
                # Description from ExposedCmdletDefinition, then fall
                # back to Get-CmdletMetaData's Description/Synopsis.
                $functionHelpMessage = $currentCommand.Description
                if ([string]::IsNullOrWhiteSpace($functionHelpMessage)) {
                    $functionHelpMessage = $metaData.Description
                }
                if ([string]::IsNullOrWhiteSpace($functionHelpMessage)) {
                    $functionHelpMessage = $metaData.Synopsis
                }
                if ([string]::IsNullOrWhiteSpace($functionHelpMessage)) {
                    $functionHelpMessage = 'No description available.'
                }

                # Output type information from Get-CmdletMetaData
                $returnType = ''
                $powershell_returnType = ''
                if ($metaData.OutputType -and
                    $metaData.OutputType.Count -gt 0 -and
                    -not [string]::IsNullOrWhiteSpace(
                        $metaData.OutputType[0])) {
                    $powershell_returnType = $metaData.OutputType[0]
                    $returnType = GenXdev\Convert-DotNetTypeToLLMType `
                        -DotNetType $powershell_returnType
                }

                # Check if function requires confirmation based on
                # ExposedCmdletDefinition configuration
                $name = $commandInfo.Name
                $found = $false
                $allCmdletNames = @($name.ToLowerInvariant())
                $NoConfirmationToolFunctionNames = @(
                    $ExposedCmdLets |
                        Microsoft.PowerShell.Core\Where-Object `
                            -Property Confirm -EQ $false |
                        Microsoft.PowerShell.Utility\Select-Object `
                            -ExpandProperty Name)

                foreach ($AllowedCmdLet in $NoConfirmationToolFunctionNames) {
                    if ($AllowedCmdLet.ToLowerInvariant() -in
                        $allCmdletNames) {
                        $found = $true
                        break
                    }
                }

                # Construct the final function definition object
                $newFunctionDefinition = @{
                    type     = 'function'
                    function = @{
                        name        = "$name"
                        description = "$functionHelpMessage"
                        parameters  = @{
                            type       = 'object'
                            properties = $propertiesTable
                            required   = $requiredParams
                        }
                        callback    = $commandInfo
                    }
                }

                # Add return type information if available
                if (-not [string]::IsNullOrWhiteSpace(
                        $powershell_returnType)) {
                    $newFunctionDefinition.function.powershell_returnType =
                        $powershell_returnType
                }

                if (-not [string]::IsNullOrWhiteSpace($returnType)) {
                    $newFunctionDefinition.function.returnType = $returnType
                }

                # Add the completed function definition to results
                $null = $result.Add($newFunctionDefinition)
            }
        }
    }

    end {

        # Return the collection of converted function definitions
        Microsoft.PowerShell.Utility\Write-Verbose "Completed conversion with $($result.Count) function definitions"
        Microsoft.PowerShell.Utility\Write-Output $result
    }
}