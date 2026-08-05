###############################################################################
<#
.SYNOPSIS
Connects to an existing browser instance via debugging port.

.DESCRIPTION
Establishes a connection to a running Chromium-based browser instance using the
WebSocket debugger URL. Creates a Playwright instance and connects over CDP
(Chrome DevTools Protocol). The connected browser instance is stored in a global
dictionary for later reference.

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

.PARAMETER WsEndpoint
The WebSocket URL for connecting to the browser's debugging port. This URL
typically follows the format 'ws://hostname:port/devtools/browser/<id>'.

.EXAMPLE
Connect-PlaywrightViaDebuggingPort `
    -WsEndpoint "ws://localhost:9222/devtools/browser/abc123"
###############################################################################>
function Connect-PlaywrightViaDebuggingPort {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'WebSocket URL for browser debugging connection'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$WsEndpoint,
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

        # log connection attempt for debugging purposes
        Microsoft.PowerShell.Utility\Write-Verbose "Attempting to connect to browser at: $WsEndpoint"

        $ensureParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\EnsurePlaywright'
        GenXdev\EnsurePlaywright @ensureParams

       $Global:GenXdevPlaywrightBrowserDictionary = $Global:GenXdevPlaywrightBrowserDictionary ?
       $Global:GenXdevPlaywrightBrowserDictionary :
       [System.Collections.Concurrent.ConcurrentDictionary[string, Microsoft.Playwright.IBrowser]]::new()
    }


    process {
        try {
            # create new playwright instance
            Microsoft.PowerShell.Utility\Write-Verbose 'Creating Playwright instance'
            $playwright = [Microsoft.Playwright.Playwright]::CreateAsync().Result

            # connect to browser using CDP protocol
            Microsoft.PowerShell.Utility\Write-Verbose 'Connecting to browser via CDP'
            $browser = $playwright.Chromium.ConnectOverCDPAsync($WsEndpoint).Result

            # store browser instance for module-wide access
            Microsoft.PowerShell.Utility\Write-Verbose 'Storing browser instance in global dictionary'
            $Global:GenXdevPlaywrightBrowserDictionary[$WsEndpoint] = $browser

            return $browser
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to connect via debugging port: $_"
            throw
        }
    }

    end {
    }
}