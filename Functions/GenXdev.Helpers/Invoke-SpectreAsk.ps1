###############################################################################
<#
.SYNOPSIS
Prompts the user for text input using Spectre.Console.

.DESCRIPTION
Uses Spectre.Console to display a text input prompt and returns the user's
typed response as a string.

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

.PARAMETER Message
The prompt message to display to the user.

.EXAMPLE
$name = Invoke-SpectreAsk -Message "What is your name?"
Prompts the user for their name and returns the entered text
#>
function Invoke-SpectreAsk {

    [CmdletBinding()]
    param(
        ########################################################################
        [parameter(
            Position = 0,
            HelpMessage = 'The prompt message to display to the user',
            Mandatory = $False
        )]
        [string] $Message
        ########################################################################
    )

    # dont remove this line [dontrefactor]

    begin {
        if ([PsGenXdevCmdlet]::IsRunningUnderPester()) {

            throw "Invalid operation in Pester Test is causing Invoke-SpectreAsk being invoked, should have used Mocking for these invocations!"
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Showing Spectre ask prompt"
    }

    process {
        return [Spectre.Console.AnsiConsole]::Ask[string]($Message)
    }

    end {
    }
}