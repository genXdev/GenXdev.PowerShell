###############################################################################
<#
.SYNOPSIS
Starts the configured Windows screensaver.

.DESCRIPTION
Activates the Windows system screensaver by executing the default screensaver
executable (scrnsave.scr) with the /s switch to start it immediately.

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

.EXAMPLE
Enable-Screensaver

.NOTES
This function requires the Windows screensaver to be properly configured in the
system settings. The screensaver executable must exist at the default Windows
System32 location.
#>
function Enable-Screensaver {

    [CmdletBinding()]
    param()

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Starting Windows screensaver activation'
    }


    process {

        # execute the windows screensaver executable with the start switch
        & "$ENV:SystemRoot\system32\scrnsave.scr" /s
    }

    end {
    }
}