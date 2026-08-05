###############################################################################
<#
.SYNOPSIS
Takes control of a selected web browser tab for interactive manipulation.

.DESCRIPTION
This function enables interactive control of a browser tab that was previously
selected using Select-WebbrowserTab. It provides direct access to the Microsoft
Playwright Page object's properties and methods, allowing for automated browser
interaction.

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

.PARAMETER UseCurrent
When specified, uses the currently assigned browser tab instead of prompting to
select a new one. This is useful for continuing work with the same tab.

.PARAMETER Force
Forces a browser restart by closing all tabs if no debugging server is detected.
Use this when the browser connection is in an inconsistent state.

.EXAMPLE
Unprotect-WebbrowserTab -UseCurrent

.EXAMPLE
wbctrl -Force
#>
function Unprotect-WebbrowserTab {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Alias('wbctrl')]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Default',
            HelpMessage = 'Use current tab instead of selecting a new one'
        )]
        [Alias('current')]
        [switch] $UseCurrent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'Default',
            HelpMessage = 'Restart browser if no debugging server detected'
        )]
        [switch] $Force
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Initializing browser tab control sequence...'

        # get reference to powershell window for manipulation
        $pwshW = GenXdev\Get-PowershellMainWindow
    }


    process {

        if (-not $UseCurrent) {

            Clear-Host

            Microsoft.PowerShell.Utility\Write-Verbose 'Prompting user to select a browser tab...'
            Microsoft.PowerShell.Utility\Write-Host 'Select to which browser tab you want to send commands to'

            # attempt to get list of available browser tabs
            GenXdev\Select-WebbrowserTab -Force:$Force

            if ($Global:ChromeSessions.Length -eq 0) {

                Microsoft.PowerShell.Utility\Write-Host 'No browser tabs are open'
                return
            }

            # get valid tab selection from user
            $tabNumber = 0
            do {
                $tabNumber = Microsoft.PowerShell.Utility\Read-Host 'Enter the number of the tab you want to control'
                $tabNumber = $tabNumber -as [int]
                $tabCount = $Global:ChromeSessions.Length

                if ($tabNumber -lt 0 -or $tabNumber -gt $tabCount - 1) {
                    Microsoft.PowerShell.Utility\Write-Host ('Invalid tab number. Please enter a number ' +
                        "between 0 and $($tabCount-1)")
                    continue
                }
                break
            } while ($true)

            # activate the selected browser tab
            GenXdev\Select-WebbrowserTab $tabNumber
        }

        if (-not $Global:playwrightController) {

            Microsoft.PowerShell.Utility\Write-Host 'No ChromeController object found'
            return
        }

        try {
            # maximize the powershell window
            $null = $pwshW.Maximize()
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose "Failed to maximize PowerShell window: $_"
        }

        # create background job for keyboard input
        $null = Microsoft.PowerShell.Core\Start-Job {

            # send keyboard sequence to expose chrome controller object
            $null = GenXdev\Send-Key `
                '{ESCAPE}', 'Clear-Host', '{ENTER}', "`$ChromeController", '.',
            '^( )', 'y' `
                -SendKeyDelayMilliSeconds 500 `
                -WindowHandle ((GenXdev\Get-PowershellMainWindow).Handle)

            # allow time for commands to complete
            $null = Microsoft.PowerShell.Utility\Start-Sleep 3
        }

        try {
            # attempt to bring powershell window to front
            $null = GenXdev\Get-PowershellMainWindow | Microsoft.PowerShell.Core\ForEach-Object {

                $null = $_.Focus()
                $null = GenXdev\Set-ForegroundWindow $_.handle
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose "Failed to set PowerShell window focus: $_"
        }
    }

    end {
    }
}
###############################################################################