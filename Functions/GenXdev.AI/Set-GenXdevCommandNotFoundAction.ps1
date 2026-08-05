# Don't remove this line [dontrefactor]

###############################################################################
<#
.SYNOPSIS
Sets up custom command not found handling with optional AI assistance.

.DESCRIPTION
Configures PowerShell to handle unknown commands by either navigating to
directories or using AI to interpret user intent. The handler first tries any
existing command not found handler, then checks if the command is a valid path
for navigation. AI resolution is only enabled when the -UseAIResolve switch is
explicitly specified.

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

.PARAMETER UseAIResolve
When specified, enables AI-powered resolution of unknown commands. The user
will be prompted to confirm before any AI-generated command is executed.

.PARAMETER NoPrompt
When specified together with -UseAIResolve, skips the "What did you want to
do?" question and uses the typed command name directly as the AI query.
Command execution still requires explicit user confirmation.

.EXAMPLE
Set-GenXdevCommandNotFoundAction -UseAIResolve

Enables AI resolution with interactive prompting for unknown commands.

.EXAMPLE
Set-GenXdevCommandNotFoundAction -UseAIResolve -NoPrompt

Enables AI resolution where the unknown command is sent directly to the AI
without asking the user what they meant.
#>
function Set-GenXdevCommandNotFoundAction {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseBOMForUnicodeEncodedFile', '')]
    param(
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
        [string] $LLMQueryType = 'Coding',
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
            HelpMessage = 'Indicates that LLM has no support for JSON schemas'
        )]
        [switch] $NoSupportForJsonSchema,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable AI-powered resolution of unknown commands. '
        )]
        [switch] $UseAIResolve,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip the intent prompt and use the command name directly as the AI query (requires -UseAIResolve).'
        )]
        [switch] $NoPrompt
        #######################################################################
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting Set-GenXdevCommandNotFoundAction'

        # store reference to existing handler if it's not already our handler
        $script:originalHandler = $null
        $currentHandler = $ExecutionContext.InvokeCommand.CommandNotFoundAction

        # check if handler is already installed
        if ($null -ne $currentHandler) {

            $handlerString = $currentHandler.ToString()
            if (-not $handlerString.Contains('Microsoft.PowerShell.Management\Set-Location "+"')) {

                $script:originalHandler = $currentHandler
                Microsoft.PowerShell.Utility\Write-Verbose 'Stored original command handler for chaining'
            }
        }
    }

    process {

        if (-not $PSCmdlet.ShouldProcess('Command not found handling', 'Set AI assistance handler')) {
            return
        }

        try {
            # Add flag to prevent recursion
            $script:insideCommandHandler = $false
            $script:UseAIResolve = $true -eq $UseAIResolve
            $global:UseAIUnknownCommandPrompt = $true -ne $NoPrompt
            $global:AIPowershellCommandParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Invoke-AIPowershellCommand' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            Microsoft.PowerShell.Utility\Write-Verbose 'Configuring new CommandNotFoundAction handler'

            # define the command not found action handler
            $ExecutionContext.InvokeCommand.CommandNotFoundAction = {
                param($CommandName, $CommandLookupEventArgs)

                # prevent recursion
                if ($script:insideCommandHandler) {

                    Microsoft.PowerShell.Utility\Write-Debug "Preventing recursive call for command: $CommandName"
                    return
                }

                $script:insideCommandHandler = $true

                $origPSDebugPreference = $PSDebugPreference
                $origErrorActionPreference = $ErrorActionPreference
                $origVerbosePreference = $VerbosePreference
                $origWarningPreference = $WarningPreference

                try {
                    # suppress unnecessary output during handler execution
                    $PSDebugPreference = 'continue'
                    $ErrorActionPreference = 'SilentlyContinue'
                    $VerbosePreference = 'SilentlyContinue'
                    $WarningPreference = 'SilentlyContinue'

                    # skip .NET method calls
                    if ($CommandName -match '^\[.*\]::') {
                        return
                    }

                    # try original handler first
                    if ($null -ne $script:originalHandler) {
                        try {
                            & $script:originalHandler $CommandName $CommandLookupEventArgs

                            if ($CommandLookupEventArgs.StopSearch) {
                                return
                            }
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Debug "Original handler failed: $_"
                        }
                    }
                }
                finally {
                    # restore original preferences
                    $PSDebugPreference = $origPSDebugPreference
                    $ErrorActionPreference = $origErrorActionPreference
                    $VerbosePreference = $origVerbosePreference
                    $WarningPreference = $origWarningPreference
                    $script:insideCommandHandler = $false
                }

                # handle directory navigation
                if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $CommandName -PathType Container) {

                    $CommandLookupEventArgs.CommandScriptBlock = {
                        Microsoft.PowerShell.Management\Set-Location -LiteralPath $CommandName
                        Microsoft.PowerShell.Management\Get-ChildItem
                    }.GetNewClosure()

                    $CommandLookupEventArgs.StopSearch = $true
                    return
                }

                try {
                    [Uri] $uri;
                    if ([Uri]::TryCreate($CommandName, [UriKind]::Absolute, [ref] $uri)) {

                        return;
                    }
                }
                catch {

                }

                # skip internal and get- commands
                if ($CommandLookupEventArgs.CommandOrigin -eq 'Internal' -or
                    $CommandName -like 'get-*') {

                    if (@(Microsoft.PowerShell.Core\Get-Command $CommandName -ErrorAction SilentlyContinue).Length -eq 0) {

                        return
                    }
                }

                if (($CommandName.trim() -like "$([char]21)") -or ($CommandName.trim() -like "get-$([char]21)") -or ($CommandName.trim() -like '^U') -or
                    ($CommandName.trim() -like 'get-^U') -or ($CommandName.trim() -eq "")) {
                    $CommandLookupEventArgs.CommandScriptBlock = {
                    }

                    $CommandLookupEventArgs.StopSearch = $true
                    return
                }

                if ($CommandName -like '-' -or $CommandName -like "cd -" -or $CommandName -like "Set-Location +") {

                    $CommandLookupEventArgs.CommandScriptBlock = {
                        Microsoft.PowerShell.Management\Set-Location "-"
                    }

                    $CommandLookupEventArgs.StopSearch = $true
                    return
                }

                if ($CommandName -like '+' -or $CommandName -like "cd +" -or $CommandName -like "Set-Location -") {

                    $CommandLookupEventArgs.CommandScriptBlock = {

                        Microsoft.PowerShell.Management\Set-Location "+"
                    }

                    $CommandLookupEventArgs.StopSearch = $true
                    return
                }

                # AI assistance block — only active when -UseAIResolve was set
                if ($script:UseAIResolve) {

                    $CommandLookupEventArgs.CommandScriptBlock = {

                        $faultyLine = $MyInvocation.Line

                        if ($global:UseAIUnknownCommandPrompt) {

                            $userChoice = $host.ui.PromptForChoice(
                                'Command not found',
                                'Do you want AI to figure out what you ' +
                                'want?',
                                @('&Nah', '&Yes'),
                                0)

                            if ($userChoice -eq 0) {

                                return
                            }
                        }

                        $splat = $global:AIPowershellCommandParams

                        Microsoft.PowerShell.Utility\Write-Host "Command not found" -ForegroundColor Cyan
                        Microsoft.PowerShell.Utility\Write-Host "Ok, hold on looking up your instruction using AI.. press Ctrl-C to abort" -ForegroundColor Cyan

                        GenXdev\Invoke-AIPowershellCommand @splat $faultyLine

                    }.GetNewClosure()
                }

                $CommandLookupEventArgs.StopSearch = $true
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to set up command not found handler: $_"
        }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Verbose 'Command not found handler configuration completed'
    }
}