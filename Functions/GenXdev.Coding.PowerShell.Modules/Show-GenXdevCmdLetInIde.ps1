###############################################################################
<#
.SYNOPSIS
Opens the specified GenXdev cmdlet in Visual Studio Code.

.DESCRIPTION
This function retrieves the script file and line number for the specified GenXdev
cmdlet and opens it in Visual Studio Code. It can open either the main function
implementation or its associated unit tests, based on the UnitTests switch
parameter.

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

.PARAMETER CmdletName
The name of the GenXdev cmdlet to locate and open in Visual Studio Code.

.PARAMETER UnitTests
When specified, opens the unit test file for the cmdlet instead of the main
implementation file.

.PARAMETER ChangeDirectoryOnly -> 'cd'
When specified, only changes the current PowerShell location
the respective Cmdlet sourcecode directory.

.EXAMPLE
Show-GenXdevCmdLetInIde -CmdletName "Get-GenXDevModuleInfo"
Opens the implementation of Get-GenXDevModuleInfo in VSCode.

.EXAMPLE
editcmdlet Get-GenXDevModuleInfo -UnitTests
Opens the unit tests for Get-GenXDevModuleInfo using the alias.
#>
function Show-GenXdevCmdLetInIde {

    [CmdletBinding()]
    [Alias('editcmdlet', 'cmdlet')]
    param(
        ########################################################################
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromRemainingArguments = $false,
            HelpMessage = 'Search pattern to filter cmdlets'
        )]
        [Alias('Filter', 'CmdLet', 'Cmd', 'FunctionName', 'Name')]
        [SupportsWildcards()]
        [string] $CmdletName,
        ########################################################################
        [parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            Position = 1,
            HelpMessage = 'GenXdev module names to search'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('Module', 'SubModuleName')]
        [ValidatePattern('^(GenXdev|GenXde[v]\*|GenXdev(\.[\w\*\[\]\?]*)+)+$')]
        [SupportsWildcards()]
        [string[]] $ModuleName,
        ########################################################################
        [Parameter(Mandatory = $false)]
        [switch] $NoLocal,
        ########################################################################
        [Parameter(Mandatory = $false)]
        [switch] $OnlyPublished,
        ########################################################################
        [Parameter(Mandatory = $false)]
        [switch] $FromScripts,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The ide to open the file in'
        )]
        [Alias('c')]
        [switch] $Code,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open in Visual Studio'
        )]
        [Alias('vs')]
        [switch] $VisualStudio,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Show the function's unit-tests instead of the function"
        )]
        [switch] $UnitTests,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The keys to send'
        )]
        [Alias('keys')]
        [string[]] $KeysToSend = @(),
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Add to Co-Pilot edit session'
        )]
        [switch] $CoPilot,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Also global search for the cmdlet'
        )]
        [switch] $Search,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("When specified, only changes the current PowerShell location\r\n"+
                           "the respective Cmdlet directory")
        )]
        [Alias('cd')]
        [switch] $ChangedirectoryOnly,
        #######################################################################
        [Parameter(
            ParameterSetName="New",
            Mandatory = $false,
            HelpMessage = "Create a new cmdlet"
        )]
        [switch] $New,
        ########################################################################
        [Parameter(
            ParameterSetName="New",
            Position = 3,
            Mandatory = $false,
            HelpMessage = "A brief description of the cmdlet's purpose"
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Synopsis = "todo: A brief description of the cmdlet's purpose",
        ########################################################################
        [Parameter(
            ParameterSetName="New",
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'A detailed description of what the cmdlet does'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Description = 'todo: [A detailed description of what the cmdlet does]',
        ########################################################################
        [Parameter(
            ParameterSetName="New",
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'Integrate the new cmdlet into an existing GenXdev module'
        )]
        [ValidateNotNullOrEmpty()]
        [ValidatePattern('^(GenXdev|GenXdev(\.\w+)+)+$')]
        [string] $BaseModuleName,
        ########################################################################
        [parameter(
            ParameterSetName="New",
            Mandatory = $false,
            Position = 5,
            HelpMessage = 'One or more aliases for the cmdlet. Accepts an array of strings.'
        )]
        [string[]] $CmdletAliases,
        ########################################################################
        [parameter(
            ParameterSetName="New",
            Mandatory = $false,
            HelpMessage = 'The AI prompt key to use for template selection'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PromptKey,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Custom AI prompt text to use for cmdlet generation'
        )]
        [AllowEmptyString()]
        [string] $Prompt = "Create a boilerplate GenXdev cmdlet that does what it's name suggests",
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Only edit the AI prompt without creating the cmdlet'
        )]
        [switch] $EditPrompt,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to this installation type and set persistent flag..')
        )]
        [switch]$AutoConsent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installations. Useful for unattended or CI/CD scenarios.')
        )]
        [switch]$AutoConsentAllPackages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
        ########################################################################
    )

    begin {

        $psRootPath = GenXdev\Get-PowerShellRoot
        $ensureParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\EnsureCopilotKeyboardShortCut'
        $null = GenXdev\EnsureCopilotKeyboardShortCut @ensureParams

        # retrieve and validate the target cmdlet exists
        $invocationParams = GenXdev\Copy-IdenticalParamValues `
            -FunctionName 'GenXdev\Get-GenXDevCmdlet' `
            -BoundParameters $PSBoundParameters
        $invocationParams.ExactMatch = $true
        $m = [string]::IsNullOrWhiteSpace($ModuleName) ? $ModuleName :
                [string]::IsNullOrWhiteSpace($BaseModuleName) ? $Null : $BaseModuleName;
        if ($m) {

            $invocationParams.ModuleName = $m
        }

        if (-not $new -and ($null -eq $cmdletName)) {

            throw "You need to specify a GenXdev cmdletname or alias"
        }


        $cmdlet =  $null

        if (-not $new) {

            $cmdlet = GenXdev\Get-GenXDevCmdlet @invocationParams |
                Microsoft.PowerShell.Utility\Select-Object -First 1

            if (-not $cmdlet) {

                $invocationParams.FromScripts = $true

                $cmdlet = GenXdev\Get-GenXDevCmdlet @invocationParams |
                    Microsoft.PowerShell.Utility\Select-Object -First 1
            }
        }

        if (-not $new -and ($null -eq $cmdlet)) {

            throw "Could not find GenXdev cmdlet $CmdletName"
        }

        # initialize core variables
        $CmdletName = $new ? $CmdletName : $cmdlet.Name

        Microsoft.PowerShell.Utility\Write-Verbose "Processing cmdlet: $CmdletName"

        $PSRootPath = GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\..\"
        $VSCodeInvoked = $false
    }

    process {
        $filePath = $UnitTests ? $cmdlet.ScriptTestFilePath : $cmdlet.ScriptFilePath;

        if ($ChangedirectoryOnly) {

           Microsoft.PowerShell.Management\Set-Location (GenXdev\Expand-Path ([System.IO.Path]::GetDirectoryName($filePath)) -CreateDirectory) -ErrorAction SilentlyContinue
           Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath $filePath -File -ErrorAction SilentlyContinue

           return;
        }

        if ($New) {

            if ([string]::IsNullOrWhiteSpace($PromptKey)) {
                $PromptKey = 'NewGenXdevCmdLet'
            }

            $params = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev\New-GenXdevCmdlet" `
                -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue
            )

            GenXdev\New-GenXdevCmdlet @params

            return
        }

        if ((-not ([String]::IsNullOrWhiteSpace($PromptKey) -or [string]::IsNullOrWhiteSpace($Prompt))) -and
            (($null -eq $KeysToSend) -or ($KeysToSend.Count -eq 0))) {

            $params = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev\Assert-GenXdevCmdlet" `
                -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue
            )

            GenXdev\Assert-GenXdevCmdlet @params

            return;
        }

        if (-not $VSCodeInvoked -and ($filePath.StartsWith("$PSRootPath\"))) {

            $VSCodeInvoked = $true
            GenXdev\Open-SourceFileInIde `
                -Path $PSRootPath `
                -Code
        }

        # open cmdlet in vscode and insert prompt
        $invocationParams = GenXdev\Copy-IdenticalParamValues `
            -FunctionName 'GenXdev\Open-SourceFileInIde' `
            -BoundParameters $PSBoundParameters

        $invocationParams.Path = $filePath
        $invocationParams.LineNo = $UnitTests ? 0 : ($cmdlet.LineNo)
        $invocationParams.KeysToSend = ($CoPilot ? @('+%E', '+%S', '^+%{F12}') : @('+%E', '+%S')) + @($KeysToSend ? $KeysToSend : @())

        GenXdev\Open-SourceFileInIde @invocationParams
    }

    end {

        if ($Search) {

            if ($ChangedirectoryOnly) {

                if (-not [string]::IsNullOrWhiteSpace($ModuleName)) {

                    Microsoft.PowerShell.Utility\Write-Verbose "Searching '$(
                            "$($ModuleName.Replace('.','\.').Replace('*', '.*').Replace('?','.?'))"+
                            "\\"+
                            "$($CmdletName.Replace('.','\.').Replace('*', '.*').Replace('?','.?'))"
                        )' in '$PSRootPath\*.ps1'"

                    GenXdev\Find-Item -PassThru "$PSRootPath\*.ps1" `
                        (
                            "$($ModuleName.Replace('.','\.').Replace('*', '.*').Replace('?','.?'))"+
                            "\\"+
                            "$($CmdletName.Replace('.','\.').Replace('*', '.*').Replace('?','.?'))"
                        ) | Microsoft.PowerShell.Core\Where-Object { $_.FullPath -ne $filePath }
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose "Searching '$($CmdletName.Replace('.','\.').Replace('*', '.*').Replace('?','.?'))' in '$PSRootPath\*.ps1'"

                    GenXdev\Find-Item -PassThru "$PSRootPath\*.ps1" `
                        (
                            "$($CmdletName.Replace('.','\.').Replace('*', '.*').Replace('?','.?'))"
                        ) | Microsoft.PowerShell.Core\Where-Object { $_.FullPath -ne $filePath }
                }
                return;
            }

            $invocationArgs = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Search-GenXdevCmdlet'

            $null = GenXdev\Search-GenXdevCmdlet @invocationArgs
        }
    }
}