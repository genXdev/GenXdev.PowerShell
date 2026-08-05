###############################################################################
<#
.SYNOPSIS
Displays a Spectre.Console confirmation prompt and returns the user's choice.

.DESCRIPTION
Uses Spectre.Console to present a confirmation dialog to the user with the
specified message. Returns $true if the user confirms, $false otherwise.

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
The confirmation message to display to the user.

.EXAMPLE
Invoke-SpectreConfirm -Message "Are you sure you want to continue?"
Presents a confirmation prompt with the specified message
#>
function Invoke-SpectreConfirm {

    [CmdletBinding()]
    param(
        ########################################################################
        [parameter(
            Position = 0,
            HelpMessage = 'The confirmation message to display to the user',
            Mandatory = $False
        )]
        [string] $Message
        ########################################################################
    )

    # dont remove this line [dontrefactor]

    begin {
        if ([PsGenXdevCmdlet]::IsRunningUnderPester()) {

            throw "Invalid operation in Pester Test is causing Invoke-SpectreConfirm being invoked, should have used Mocking for these invocations!"
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Showing Spectre confirmation prompt"
    }

    process {
        return [Spectre.Console.AnsiConsole]::Confirm($Message)
    }

    end {
    }
}