<#
.SYNOPSIS
Executes a refactoring operation on a source file using the specified IDE and
AI prompt template.

.DESCRIPTION
This function automates the refactoring process by preparing an AI prompt based
on the refactor definition, detecting or selecting the appropriate IDE (VS Code
or Visual Studio), and opening the target file with the prepared prompt. The
function handles prompt template processing, IDE detection, and automation of
the refactoring workflow.

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

.PARAMETER RefactorDefinition
The refactor definition object containing settings, prompt templates, and IDE
preferences for the refactoring operation.

.PARAMETER Path
The absolute or relative path to the source file that needs to be refactored.
The path will be expanded to an absolute path during processing.

.EXAMPLE
$refactorDef = Get-RefactorDefinition -Type "Documentation"
Assert-RefactorFile -RefactorDefinition $refactorDef -Path "MyScript.ps1"

.EXAMPLE
Assert-RefactorFile -RefactorDefinition $refactorDef -Path ".\Functions\Test.ps1"
#>
function Assert-RefactorFile {

    [CmdletBinding()]
    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The path to the source file to improve'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [string] $Path,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'The refactor definition containing settings and prompt template'
        )]
        [ValidateNotNull()]
        [GenXdev.Helpers.RefactorSettings] $RefactorSettings = [GenXdev.Helpers.RefactorSettings]::new(),
        ###############################################################################
        [switch] $AllowLongRunningTests
    )

    begin {

        # prepare paths for scripts and modules directories
        $scriptsPath = GenXdev\Expand-Path `
            "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\..\Scripts\" `
            -CreateDirectory

        $modulesPath = GenXdev\Expand-Path `
            "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\" `
            -CreateDirectory

        # expand the target file path to absolute path
        $Path = GenXdev\Expand-Path $Path

        # extract prompt settings from the refactor definition
        $prompt = $RefactorSettings.Prompt

        $promptKey = $RefactorSettings.PromptKey

        # detect which IDE is currently active by examining running processes
        [System.Diagnostics.Process] $hostProcess = `
            GenXdev\Get-PowershellMainWindowProcess

        $isCode = $hostProcess.Name -eq 'Code' -or $hostProcess.Name -eq 'Code - Insiders'
        $isVisualStudio = $hostProcess.Name -eq 'devenv'

        # fallback to refactor definition preferences if no active IDE found
        if (-not ($isCode -or $isVisualStudio)) {

            # check if VS Code is preferred in settings
            if ($RefactorSettings.Code -ge 0) {

                $isCode = $RefactorSettings.Code -eq 1
            }

            # check if Visual Studio is preferred in settings
            if ($RefactorSettings.VisualStudio -ge 0) {

                $isVisualStudio = $RefactorSettings.VisualStudio -eq 1
            }

            # attempt to find any running IDE process as final fallback
            if (-not ($isCode -or $isVisualStudio)) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Attempting to detect running IDE instances')

                # search for running VS Code processes
                [System.Diagnostics.Process] $hostProcess = `
                    Microsoft.PowerShell.Management\Get-Process 'Code' `
                        -ErrorAction SilentlyContinue |
                        Microsoft.PowerShell.Utility\Sort-Object |
                        Microsoft.PowerShell.Utility\Select-Object -First 1

                $isCode = $null -ne $hostProcess

                # search for running Visual Studio processes
                $hostProcess = Microsoft.PowerShell.Management\Get-Process 'devenv' `
                    -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Utility\Sort-Object |
                    Microsoft.PowerShell.Utility\Select-Object -First 1

                $isVisualStudio = $null -ne $hostProcess
            }
        }

        # prompt user to select IDE if no clear choice can be determined
        if (-not ($isCode -bxor $isVisualStudio)) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Prompting user to select IDE'

            # use cached selection or prompt for new choice
            $userAnswer = $null -ne $Script:_CodeOrVisualStudioRefactor ?
                $Script:_CodeOrVisualStudioRefactor :
                ($host.ui.PromptForChoice(
                    'Make a choice',
                    'What IDE to use for refactoring?',
                    @('Visual Studio &Code', '&Visual Studio'),
                    0))

            # cache the user's selection for future operations
            $Script:_CodeOrVisualStudioRefactor = $userAnswer

            # apply the user's IDE selection
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

        # process and load prompt template if a template key is specified
        if (-not [string]::IsNullOrWhiteSpace($PromptKey)) {

            # construct the base path for prompt templates
            $promptFilePath = GenXdev\Expand-Path `
                "$($MyInvocation.MyCommand.Module.ModuleBase)\Prompts\GenXdev.Coding.PowerShell.Modules\" `
                -CreateDirectory

            # build the template file path using the prompt key
            $promptFilePath = Microsoft.PowerShell.Management\Join-Path `
                $promptFilePath "Assert-$PromptKey.txt"

            # use script-specific template if target file is in scripts folder
            if ($Path -like "$scriptsPath\*.ps1") {

                $promptFilePath = GenXdev\Expand-Path (
                    "$($MyInvocation.MyCommand.Module.ModuleBase)\Prompts\GenXdev.Coding.PowerShell.Modules\" +
                    "Assert-$PromptKey-script.txt") -CreateFile
            }

            # load the template file and replace the prompt placeholder
            $Prompt = [System.IO.File]::ReadAllText($promptFilePath).Replace(
                "`$Prompt",
                $Prompt
            )
        }

        # replace template variables with actual values from the target file
        $Prompt = $Prompt.Replace(
            "`$CmdletName",
            [System.IO.Path]::GetFileNameWithoutExtension($Path)
        )

        # remove test suffix from cmdlet name for cleaner prompts
        $Prompt = $Prompt.Replace(
            "`$CmdLetNoTestName",
            [System.IO.Path]::GetFileNameWithoutExtension($Path).Replace(
                '.Tests', ''
            )
        )

        # insert the script filename into the prompt
        $Prompt = $Prompt.Replace(
            "`$ScriptFileName",
            [System.IO.Path]::GetFileName($Path)
        )

        # normalize tab characters to spaces for consistent formatting
        $Prompt = $Prompt.Replace("`t", '  ')

        # determine module context based on file location
        if ($Path.ToLowerInvariant().StartsWith($scriptsPath.ToLowerInvariant())) {

            # handle files in the scripts directory
            $Prompt = $Prompt.Replace(
                "`$FullModuleName",
                'GenXdev.Scripts'
            )

            $Prompt = $Prompt.Replace(
                "`$BaseModuleName",
                ''
            )
        }
        else {

            # extract base module name from the file path
            $baseModuleName = `
                "$($Path.Substring($modulesPath.Length + 1).Split('\')[0])"

            # construct paths for functions and tests directories
            $functionsPath = GenXdev\Expand-Path `
                "$modulesPath\$baseModuleName\3.33.0\Functions\" `
                -CreateDirectory

            $testsPath = GenXdev\Expand-Path `
                "$modulesPath\$baseModuleName\3.33.0\Tests\" `
                -CreateDirectory

            # determine the specific module context based on file location
            if ($Path.ToLowerInvariant().StartsWith($functionsPath.ToLowerInvariant())) {

                # extract sub-module name from functions path
                $Prompt = $Prompt.Replace(
                    "`$FullModuleName",
                    "$($Path.Substring($functionsPath.Length + 1).Split('\')[0])"
                )
            }
            elseif ($Path.ToLowerInvariant().StartsWith($testsPath.ToLowerInvariant())) {

                # extract sub-module name from tests path
                $Prompt = $Prompt.Replace(
                    "`$FullModuleName",
                    "$($Path.Substring($testsPath.Length + 1).Split('\')[0])"
                )
            }
            else {

                # use base module name for other locations
                $Prompt = $Prompt.Replace(
                    "`$FullModuleName",
                    "$baseModuleName"
                )
            }

            # set the base module name in the prompt
            $Prompt = $Prompt.Replace(
                "`$BaseModuleName",
                "$baseModuleName"
            )
        }

        # final normalization of tab characters
        $Prompt = $Prompt.Replace("`t", '  ')

        # preserve current clipboard content for later restoration
        $previousClipboard = Microsoft.PowerShell.Management\Get-Clipboard

        # copy the prepared prompt to clipboard for use in IDE
        $null = Microsoft.PowerShell.Management\Set-Clipboard -Value $prompt

        Microsoft.PowerShell.Utility\Write-Verbose (
            'Prepared prompt and copied to clipboard:')

        Microsoft.PowerShell.Utility\Write-Verbose $prompt

        # determine keyboard automation sequence based on selected IDE
        $keysToSend = $RefactorSettings.KeysToSend

        # use default key sequences if none specified in settings
        if (($null -eq $keysToSend) -or ($keysToSend.Count -eq 0)) {

            # configure VS Code key sequence for AI assistant integration
            if ($isCode) {

                $keysToSend = @("^``", "^``", '^+i', '^n', '^a', '{DELETE}', '^%b',
                    '^+%{F12}', '{ENTER}', '^v', '{ENTER}', '^{ENTER}', "^``") # '^%b',
            }
            elseif ($isVisualStudio) {

                # configure Visual Studio key sequence for copilot integration
                $keysToSend = @('^\', '^c', '^a', ' {DELETE}', '^v',
                    '{ENTER}', '^{ENTER}')
            }
        }
    }

    process {

        Microsoft.PowerShell.Utility\Write-Verbose (
            'Opening file in IDE for refactoring')

        # prepare parameter hashtable for IDE invocation
        $invocationParams = @{
            Path       = $Path
            KeysToSend = $keysToSend
        }

        # add IDE-specific parameters if they exist in current scope
        $invocationParams.Code = $Code

        $invocationParams.VisualStudio = $VisualStudio

        # launch the selected IDE with automation parameters
        GenXdev\Open-SourceFileInIde @invocationParams
    }

    end {

        # restore the original clipboard content to maintain user workflow
        $null = Microsoft.PowerShell.Management\Set-Clipboard -Value $previousClipboard
    }
}
################################################################################