# Don't remove this line [dontrefactor]
###############################################################################
<#
.SYNOPSIS
Assists in refactoring PowerShell source code files using AI assistance.

.DESCRIPTION
This function automates the process of refactoring PowerShell code using AI.
It manages prompt templates, detects the active IDE (VS Code or Visual Studio),
and orchestrates the refactoring workflow through keyboard automation.
The function can handle both module manifest (.psd1) and module script (.psm1)
files.

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

.PARAMETER ModuleName
The name of the PowerShell module to refactor. This module must be available
in the PowerShell module path.

.PARAMETER Prompt
Custom AI prompt text to use for the refactoring process. If not specified,
defaults to an error message if module loading fails.

.PARAMETER EditPrompt
When enabled, only opens the prompt template for editing without executing the
actual refactoring process.

.EXAMPLE
Assert-ModuleDefinition -ModuleName "MyModule" -EditPrompt

.EXAMPLE
"MyModule" | Assert-ModuleDefinition
#>
function Assert-ModuleDefinition {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The name of the module'
        )]
        [ValidateNotNull()]
        [string] $ModuleName,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The AI prompt'
        )]
        [string] $Prompt,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to only edit the AI prompt'
        )]
        [switch] $EditPrompt
        ########################################################################
    )

    begin {
        # store IDE selection at script scope for persistence between calls
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath variable:script:_IDEPreference)) {
            $script:_IDEPreference = -1
        }

        # set default error prompt if none provided
        if ([string]::IsNullOrWhiteSpace($Prompt)) {
            $Prompt = "Could not load module definition for `$ModuleName"
        }

        # attempt to import module and capture any errors
        try {
            $null = Microsoft.PowerShell.Core\Import-Module $ModuleName `
                -Scope Global `
                -ErrorVariable ImportError `
                -Force

            if (($null -ne $ImportError) -and ($importError.Length -gt 0)) {
                throw ($ImportError |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 4 `
                            -ErrorAction SilentlyContinue `
                            -WarningAction SilentlyContinue)
            }
        }
        catch {
            $Prompt = $_.Exception.Message
        }

        # setup refactoring environment
        $promptKey = 'ModuleDefinition'

        # detect active IDE process
        [System.Diagnostics.Process] $hostProcess = GenXdev\Get-PowershellMainWindowProcess
        $isCode = $hostProcess.Name -eq 'Code' -or $hostProcess.Name -eq 'Code - Insiders'
        $isVisualStudio = $hostProcess.Name -eq 'devenv'

        # if no active IDE found, check settings for preferred IDE
        if (-not ($isCode -or $isVisualStudio)) {

            # check code preference
            if ($RefactorDefinition.RefactorSettings.Code -ge 0) {
                $isCode = $RefactorDefinition.RefactorSettings.Code -eq 1
            }

            # check visual studio preference
            if ($RefactorDefinition.RefactorSettings.VisualStudio -ge 0) {
                $isVisualStudio = $RefactorDefinition.RefactorSettings.VisualStudio -eq 1
            }

            # attempt to find any running IDE as fallback
            if (-not ($isCode -or $isVisualStudio)) {

                Microsoft.PowerShell.Utility\Write-Verbose 'Attempting to detect running IDE instances'

                # try to find VS Code
                [System.Diagnostics.Process] $hostProcess = Microsoft.PowerShell.Management\Get-Process 'Code' `
                    -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Utility\Sort-Object |
                    Microsoft.PowerShell.Utility\Select-Object -First 1

                $isCode = $null -ne $hostProcess

                # try to find Visual Studio
                $hostProcess = Microsoft.PowerShell.Management\Get-Process 'devenv' -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Utility\Sort-Object |
                    Microsoft.PowerShell.Utility\Select-Object -First 1

                $isVisualStudio = $null -ne $hostProcess
            }
        }

        # prompt user to select IDE if no clear choice determined
        if (-not ($isCode -bxor $isVisualStudio)) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Prompting user to select IDE'
            $userAnswer = $script:_IDEPreference -ge 0 ?
            $script:_IDEPreference :
                ($host.ui.PromptForChoice(
                'Make a choice',
                'What IDE to use for refactoring?',
                @('Visual Studio &Code', '&Visual Studio'),
                0))

            # store selection for future use
            $script:_IDEPreference = $userAnswer

            # set IDE flags based on user selection
            switch ($userAnswer) {
                0 {
                    $isCode = $true
                    $isVisualStudio = $false
                    break;
                }
                1 {
                    $isCode = $false
                    $isVisualStudio = $true
                    break;
                }
            }
        }

        # determine appropriate prompt template path based on file location
        $promptFilePath = GenXdev\Expand-Path `
            "$($MyInvocation.MyCommand.Module.ModuleBase)\Prompts\GenXdev.Coding.PowerShell.Modules\" `
            -CreateDirectory

        $promptFilePath = Microsoft.PowerShell.Management\Join-Path $promptFilePath "Assert-$PromptKey.txt"

        # load template and replace placeholder
        $Prompt = [System.IO.File]::ReadAllText($promptFilePath).Replace(
            "`$Prompt",
            $Prompt
        )

        # replace template variables in prompt text
        $Prompt = $Prompt.Replace(
            "`$ModuleName",
            $ModuleName
        )

        $Prompt = $Prompt.Replace("`t", '  ')

        # save current clipboard content to restore later
        $previousClipboard = Microsoft.PowerShell.Management\Get-Clipboard
        $null = Microsoft.PowerShell.Management\Set-Clipboard -Value $prompt

        Microsoft.PowerShell.Utility\Write-Verbose 'Prepared prompt and copied to clipboard:'
        Microsoft.PowerShell.Utility\Write-Verbose $prompt
    }


    process {
        # exit early if only editing prompt
        if ($EditPrompt) {
            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose 'Opening file in IDE for refactoring'

        # process each module file
        . GenXdev\Invoke-OnEachGenXdevModule -ModuleName $ModuleName `
            -Script {

            $files = @(
                Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath .\ -Filter "*.psm1" -File -ErrorAction SilentlyContinue
            ) + @(
                Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath .\ -Filter "*.psd1" -File -ErrorAction SilentlyContinue
            );

            foreach ($file in $files) {

                $keysToSend = @()
                $isFirst = $file -eq $files[0]
                $isLast = $file -eq $files[-1]

                # set default key sequences for each IDE
                if ($isCode) {

                    if ($isFirst) {

                        $keysToSend = @(
                            "^``", "^``", '^+i', '^n', '^a', '{DELETE}', '^%b'
                        )
                    }

                    if ($isLast) {

                        $keysToSend = @(
                            "^``", "^``", '^+%{F12}', '{ENTER}', '^v', '{ENTER}', '^{ENTER}', "^``"
                        )
                    }
                    else {

                        $keysToSend = @('^+%{F12}')
                    }
                }
                elseif ($isVisualStudio) {

                    if ($isFirst) {

                        $keysToSend = @("^``", "^``", '^+i', '^n')
                    }

                    if ($isLast) {

                        $keysToSend = @("^``", "^``", '^+i', '^v', '{ENTER}', '^{ENTER}',"^``")
                    }
                    else {

                        $keysToSend = @("^``", '^+i')
                    }
                }

                # prepare parameters for IDE invocation
                $invocationParams = @{

                    Path       = $file.FullName
                    KeysToSend = $keysToSend
                }

                # add optional IDE parameters if specified
                $invocationParams.Code = $Code
                $invocationParams.VisualStudio = $VisualStudio

                # open file in selected IDE
                GenXdev\Open-SourceFileInIde @invocationParams

                Microsoft.PowerShell.Utility\Start-Sleep 4;
            }

            # set IDE flags based on user selection
            switch (($host.ui.PromptForChoice(
                        'Make a choice',
                        'What to do next?',
                        @('&Stop', '&Reload'),
                        0))) {
                0 {
                    return;
                }
                1 {
                    return (GenXdev\Assert-ModuleDefinition @PSBoundParameters)
                }
            }
        }
    }

    end {
        # restore original clipboard content
        $null = Microsoft.PowerShell.Management\Set-Clipboard -Value $previousClipboard
    }
}