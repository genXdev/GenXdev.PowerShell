###############################################################################
<#
.SYNOPSIS
Pauses video playback in all active browser sessions.

.DESCRIPTION
Iterates through all active browser sessions and pauses any playing videos by
executing JavaScript commands. The function maintains the original session state
and handles errors gracefully.

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
Stop-WebbrowserVideos

.EXAMPLE
wbsst
###############################################################################>
function Stop-WebbrowserVideos {

    [CmdletBinding(SupportsShouldProcess)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias('wbsst')]
    [Alias('ssst')]
    [Alias('wbvideostop')]
    param(
        [Alias('e')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Microsoft Edge'
        )]
        [switch] $Edge,
        ###############################################################################
        [Alias('ch')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Google Chrome'
        )]
        [switch] $Chrome,
        ###############################################################################
        [Alias('c')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Opens in Microsoft Edge or Google Chrome, ' +
                'depending on what the default browser is')
        )]
        [switch] $Chromium,
        ###############################################################################
        [Alias('ff')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Firefox'
        )]
        [switch] $Firefox,
        ###############################################################################
        [Alias('wk')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Uses the Playwright-managed WebKit browser'
        )]
        [switch] $Webkit
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting video pause operation across browser sessions'

        # store the current session reference to restore it later
        $originalSession = $Global:chromeSession
        $originalController = $Global:playwrightController

        # ensure we have an active browser session
        if (($null -eq $Global:chromeSessions) -or
            ($Global:chromeSessions.Count -eq 0)) {

            # select a browser tab if none are active
            $null = GenXdev\Select-WebbrowserTab -Chrome:$chrome -Edge:$edge
        }
    }


    process {
        # iterate through each browser session and pause videos
        $Global:chromeSessions | Microsoft.PowerShell.Core\ForEach-Object {

            $currentSession = $_
            if ($null -eq $_) { return }
            if ($PSCmdlet.ShouldProcess('Browser session', 'Pause videos')) {

                try {
                    Microsoft.PowerShell.Utility\Write-Verbose "Attempting to pause videos in session: $currentSession"

                    # select the current tab for processing
                    $null = GenXdev\Select-WebbrowserTab -ByReference $currentSession

                    # execute pause() command on all video elements
                    GenXdev\Get-WebbrowserTabDomNodes 'video' 'e.pause()' -NoAutoSelectTab
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning "Failed to pause videos in session: $currentSession  `r`n$($_.Exception.Message)"
                }
            }
        }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Verbose 'Restoring original browser session reference'
        $Global:chromeSession = $originalSession
        $Global:playwrightController = $originalController
    }
}