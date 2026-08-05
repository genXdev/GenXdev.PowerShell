###############################################################################
<#
.SYNOPSIS
Prompts the user for input using a Spectre.Console prompt object.

.DESCRIPTION
Uses Spectre.Console to present an interactive prompt to the user and returns
the entered string value. The Prompt parameter accepts a Spectre.Console
prompt object (such as TextPrompt, SelectionPrompt, etc.) that defines the
prompt behavior and validation.

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

.PARAMETER Prompt
A Spectre.Console prompt object (e.g., TextPrompt, SelectionPrompt) that
defines the interactive prompt behavior.

.EXAMPLE
$prompt = New-Object Spectre.Console.TextPrompt[string]("Enter your name:")
Invoke-SpectrePrompt -Prompt $prompt
Presents a text prompt to the user and returns the entered value
#>
function Invoke-SpectrePrompt {

    [CmdletBinding()]
    param(
        ########################################################################
        [parameter(
            Position = 0,
            HelpMessage = 'A Spectre.Console prompt object defining the prompt behavior',
            Mandatory = $False
        )]
        [object] $Prompt
        ########################################################################
    )

    # dont remove this line [dontrefactor]

    begin {
        if ([PsGenXdevCmdlet]::IsRunningUnderPester()) {

            throw "Invalid operation in Pester Test is causing Invoke-SpectrePrompt being invoked, should have used Mocking for these invocations!"
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Showing Spectre prompt"
    }

    process {
        return [Spectre.Console.AnsiConsole]::Prompt[string]($Prompt)
    }

    end {
    }
}