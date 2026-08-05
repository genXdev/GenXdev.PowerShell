###############################################################################
<#
.SYNOPSIS
Asserts and improves unit-tests of a specified GenXdev cmdlet.

.DESCRIPTION
This function helps maintain and improve unit tests for GenXdev cmdlets by:
1. Creating test files if they don't exist
2. Opening the cmdlet in VS Code
3. Preparing and applying AI prompts for test generation/improvement
4. Managing test execution workflow

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
The name of the cmdlet to improve unit-tests for. Required.

.PARAMETER Prompt
Custom AI prompt text to use for test generation. Optional.

.PARAMETER EditPrompt
Switch to only edit the AI prompt without modifying the cmdlet. Optional.

.PARAMETER AssertFailedTest
Switch to indicate assertion of a failed test. Optional.

.EXAMPLE
Assert-GenXdevCmdletTests -CmdletName "Get-GenXDevModuleInfo" -EditPrompt

.EXAMPLE
improvecmdlettests Get-GenXDevModuleInfo -AssertFailedTest
###############################################################################>
function Assert-GenXdevCmdletTests {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias('improvecmdlettests')]
    param(
        ########################################################################
        [Alias('cmd')]
        [parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The name of the cmdlet to improve unit-tests for'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $CmdletName,

        ########################################################################
        [parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'Custom AI prompt text to use'
        )]
        [AllowEmptyString()]
        [string] $Prompt = '',
        ########################################################################
        [parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The AI prompt key to use for template selection'
        )]
        [AllowEmptyString()]
        [string] $PromptKey,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to only edit the AI prompt'
        )]
        [switch] $EditPrompt,

        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Indicates to assert a failed test'
        )]
        [switch] $AssertFailedTest,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Search in script files instead of modules'
        )]
        [switch] $FromScripts,
        ########################################################################
        [switch] $ContinuationHandled,
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
    )

    begin {

        # get target cmdlet information including script position
        $params = GenXdev\Copy-IdenticalParamValues `
            -FunctionName 'GenXdev\Get-GenXDevCmdlet' `
            -BoundParameters $PSBoundParameters
        $params.ExactMatch = $true
        $params.CmdletName = $CmdletName
        $cmdlet = GenXdev\Get-GenXDevCmdlet @params |
            Microsoft.PowerShell.Utility\Select-Object -First 1

        # validate cmdlet exists
        if ($null -eq $cmdlet) {
            throw "Could not find GenXdev cmdlet $CmdletName"
        }

        # store cmdlet name for later use
        $CmdletName = $cmdlet.Name
        $functionDefinition = '';

        # determine which prompt template to use based on test file existence
        if (-not [string]::IsNullOrWhiteSpace($PromptKey)) {

            $PromptKey = 'CreateUnitTests'
            $functionDefinition = [System.IO.File]::ReadAllText($cmdlet.ScriptFilePath)

            if ([IO.File]::Exists($cmdlet.ScriptTestFilePath) -and
                (-not [string]::IsNullOrWhiteSpace($functionDefinition))) {

                $PromptKey = $AssertFailedTest ? 'ResolveFailedTest' : 'ImproveUnitTest'
            }
        }

        # process prompt template if key provided
        if (-not [string]::IsNullOrWhiteSpace($PromptKey)) {

            # construct path to prompt template file
            $promptFilePath = GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\Prompts\GenXdev.Coding.PowerShell.Modules\Assert-$PromptKey.txt"

            # ensure prompt directory exists and expand path
            $promptFilePath = GenXdev\Expand-Path -FilePath $promptFilePath `
                -CreateDirectory

            # load template and replace placeholder
            $Prompt = [System.IO.File]::ReadAllText($promptFilePath).Replace(
                "`$Prompt",
                $Prompt
            )
        }

        # populate template variables
        $Prompt = $Prompt.Replace("`$CmdletName", $cmdlet.Name)
        $Prompt = $Prompt.Replace("`$CmdLetNoTestName", $cmdlet.Name)
        $Prompt = $Prompt.Replace(
            "`$ScriptTestFileName",
            [System.IO.Path]::GetFileName($cmdlet.ScriptTestFilePath)
        )
        $Prompt = $Prompt.Replace(
            "`$FullModuleName",
            $cmdlet.ModuleName
        )
        $Prompt = $Prompt.Replace(
            "`$BaseModuleName",

            [string]::Join('.', ($cmdlet.ModuleName.Split('.') | Microsoft.PowerShell.Utility\Select-Object -First 2 -ErrorAction SilentlyContinue))
        )
        $Prompt = $Prompt.Replace(
            "`$ScriptFileName",
            [System.IO.Path]::GetFileName($cmdlet.ScriptFilePath)
        )
        $Prompt = $Prompt.Replace(
            "`$FunctionDefinition",
            $functionDefinition
        )
        $Prompt = $Prompt.Replace("`t", '  ')

        # copy final prompt for use
        $previousClipboard = Microsoft.PowerShell.Management\Get-Clipboard
        $null = Microsoft.PowerShell.Management\Set-Clipboard -Value $Prompt
    }


    process {

        # handle prompt editing request
        if ($EditPrompt) {
            p -c
            code $promptFilePath
            return
        }

        $found = $true

        # create test file if missing
        if (-not [IO.File]::Exists($cmdlet.ScriptTestFilePath) -or
            ([IO.File]::ReadAllText($cmdlet.ScriptTestFilePath).Trim() -eq [string]::Empty)) {

            $found = $false
            Microsoft.PowerShell.Utility\Write-Verbose 'Creating new unit test file'
            $null = GenXdev\Expand-Path -FilePath ($cmdlet.ScriptTestFilePath) -CreateFile
        }

        # ensure copilot keyboard shortcut is configured
        $ensureParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\EnsureCopilotKeyboardShortCut'
        GenXdev\EnsureCopilotKeyboardShortCut @ensureParams

        # open cmdlet in vscode and activate copilot
        # open cmdlet in vscode and insert prompt
        # open cmdlet in vscode and insert prompt
        $invocationParams = GenXdev\Copy-IdenticalParamValues `
            -FunctionName 'GenXdev\Show-GenXdevCmdLetInIde' `
            -BoundParameters $PSBoundParameters
        $invocationParams.UnitTests = $true
        $invocationParams.CmdletName = $CmdletName
        $invocationParams.Code = $true
        $keysToSendFirst = @(
                "^``", "^``", '^+i', '^n', '^a', '{DELETE}', '^%b'
            )
        $keysToSendLast = @('^+%{F12}', '{ENTER}', '^v', '{ENTER}', '^{ENTER}', "^``")
        $invocationParams.KeysToSend = $keysToSendFirst + $keysToSendLast;
        GenXdev\Show-GenXdevCmdLetInIde @invocationParams

        # switch to test file and paste prompt
        Microsoft.PowerShell.Utility\Write-Verbose 'Applying AI prompt from clipboard'
        $invocationParams.KeysToSend = $keysToSendLast
        $invocationParams.UnitTests = $false
        GenXdev\Show-GenXdevCmdLetInIde @invocationParams
        Microsoft.PowerShell.Utility\Start-Sleep 1;
        $null = Microsoft.PowerShell.Management\Set-Clipboard -Value $previousClipboard
        Microsoft.PowerShell.Utility\Start-Sleep 4;

        if ($ContinuationHandled) {

            return;
        }

        # handle workflow based on whether test file existed
        if (-not $found) {

            switch ($host.ui.PromptForChoice(
                    'Make a choice',
                    'What to do next?',
                    @('&Stop', '&Test the new unit tests', 'Redo &Last'),
                    1)) {
                    0 { throw 'Stopped'; return }
                    1 { return (GenXdev\Assert-GenXdevTest -CmdletName $CmdletName -TestFailedAction SolveWithAI -IncludeScripts) }
                    2 { return GenXdev\Assert-GenXdevCmdletTests @PSBoundParameters }
            }
        }
        else {

            switch ($host.ui.PromptForChoice(
                    'Make a choice',
                    'What to do next?',
                    @('&Stop', '&Test the improved unit tests', 'Redo &Last'),
                    1)) {
                    0 { throw 'Stopped'; return }
                    1 { return (GenXdev\Assert-GenXdevTest -CmdletName $CmdletName -TestFailedAction SolveWithAI -IncludeScripts) }
                    2 { return GenXdev\Assert-GenXdevCmdletTests @PSBoundParameters }
            }
        }
    }

    end {

    }
}
###############################################################################