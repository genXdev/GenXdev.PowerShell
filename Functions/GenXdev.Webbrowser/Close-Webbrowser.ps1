###############################################################################
<#
.SYNOPSIS
Closes one or more webbrowser instances selectively.

.DESCRIPTION
Provides granular control over closing web browser instances. Can target specific
browsers (Edge, Chrome, Firefox) or close all browsers. Supports closing both main
windows and background processes.

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

.PARAMETER Edge
Closes all Microsoft Edge browser instances.

.PARAMETER Chrome
Closes all Google Chrome browser instances.

.PARAMETER Chromium
Closes the default Chromium-based browser (Edge or Chrome).

.PARAMETER Firefox
Closes all Firefox browser instances.

.PARAMETER PlayWright
Closes all Playwright-managed browser instances and removes
their global state from $Global:GenXdevPlaywright.

.PARAMETER All
Closes all detected modern browser instances.

.PARAMETER IncludeBackgroundProcesses
Also closes background processes and tasks for the selected browsers.

.EXAMPLE
Close-Webbrowser -Chrome -Firefox -IncludeBackgroundProcesses
Closes all Chrome and Firefox instances including background processes

.EXAMPLE
wbc -a -bg
Closes all browser instances including background processes using aliases
#>
function Close-Webbrowser {

    [CmdletBinding(DefaultParameterSetName = 'Specific')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Alias('wbc')]

    param(
        ########################################################################
        [Alias('e')]
        [parameter(
            Mandatory = $false,
            ParameterSetName = 'Specific',
            HelpMessage = 'Closes Microsoft Edge browser instances'
        )]
        [switch] $Edge,
        ########################################################################
        [Alias('ch')]
        [parameter(
            Mandatory = $false,
            ParameterSetName = 'Specific',
            HelpMessage = 'Closes Google Chrome browser instances'
        )]
        [switch] $Chrome,
        ########################################################################
        [Alias('c')]
        [parameter(
            Mandatory = $false,
            ParameterSetName = 'Specific',
            HelpMessage = 'Closes default chromium-based browser'
        )]
        [switch] $Chromium,
        ########################################################################
        [Alias('ff')]
        [parameter(
            Mandatory = $false,
            ParameterSetName = 'Specific',
            HelpMessage = 'Closes Firefox browser instances'
        )]
        [switch] $Firefox,
        ###############################################################################
        [Alias('pw')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use Playwright-managed browser instead of the ' +
                'OS-installed browser')
        )]
        [switch] $PlayWright,
        ###############################################################################
        [Alias('wk')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Opens the Playwright-managed WebKit browser. ' +
                'Implies -PlayWright')
        )]
        [switch] $Webkit,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Run the browser without a visible window'
        )]
        [Alias('hl')]
        [switch] $Headless,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in all registered modern browsers'
        )]
        [switch] $All,
        ###############################################################################
        [Alias('bg', 'Force')]
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Closes all instances including background tasks'
        )]
        [switch] $IncludeBackgroundProcesses
        ########################################################################
    )

    begin {
        # query system for installed browser information
        $params = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev\Get-Webbrowser" `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        $installedBrowsers = GenXdev\Get-Webbrowser @params

        # determine system default browser
        $defaultBrowser = GenXdev\Get-DefaultWebbrowser

        Microsoft.PowerShell.Utility\Write-Verbose "Found $($installedBrowsers.Count) installed browsers"
        Microsoft.PowerShell.Utility\Write-Verbose "Default browser: $($defaultBrowser.Name)"
    }


    process {

        function Close-BrowserInstance {
            param (
                [object] $Browser
            )

            Microsoft.PowerShell.Utility\Write-Verbose "Attempting to close $($Browser.Name)"

            # extract process name without extension for matching
            $processName = [System.IO.Path]::GetFileNameWithoutExtension($Browser.Path)

            # find and process all matching browser instances
            Microsoft.PowerShell.Management\Get-Process -Name $processName -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Core\ForEach-Object {

                    $currentProcess = $_

                    # handle background processes based on user preference
                    if ((-not $IncludeBackgroundProcesses) -and
                    ($currentProcess.MainWindowHandle -eq 0)) {

                        Microsoft.PowerShell.Utility\Write-Verbose "Skipping background process $($currentProcess.Id)"
                        return
                    }
                    elseif ($currentProcess.MainWindowHandle -ne 0) {

                        # attempt graceful window close for processes with UI
                        [GenXdev.Helpers.WindowObj]::GetMainWindow($currentProcess) |
                            Microsoft.PowerShell.Core\ForEach-Object {

                                $startTime = [DateTime]::UtcNow
                                $window = $_

                                # try graceful close
                                $null = $window.Close()

                                # wait up to 4 seconds for process to exit
                                while (!$currentProcess.HasExited -and
                            ([datetime]::UtcNow - $startTime -lt
                                    [System.TimeSpan]::FromSeconds(4))) {

                                    Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 20
                                }

                                if ($currentProcess.HasExited) {
                                    Microsoft.PowerShell.Utility\Set-Variable -Scope Global `
                                        -Name "_LastClose$($Browser.Name)" `
                                        -Value ([DateTime]::UtcNow.AddSeconds(-1))
                                    return
                                }
                            }
                        }

                        # force terminate if process still running
                        try {
                            $null = $currentProcess.Kill()
                            Microsoft.PowerShell.Utility\Set-Variable -Scope Global -Name "_LastClose$($Browser.Name)" `
                                -Value ([DateTime]::UtcNow)
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Warning "Failed to kill $($Browser.Name) process: $_"
                        }
                    }
        }

        # shared helper: close Playwright browsers matching the given keys
        function ClosePlaywrightBrowsers {
            param (
                [string[]] $TargetKeys
            )

            if ($Global:GenXdevPlaywright -isnot [Hashtable]) { return }

            $keysToClose = if ($TargetKeys.Count -gt 0) {
                @($Global:GenXdevPlaywright.Keys) |
                    Microsoft.PowerShell.Core\Where-Object { $_ -in $TargetKeys }
            }
            else {
                @($Global:GenXdevPlaywright.Keys)
            }

            foreach ($key in $keysToClose) {
                $state = $Global:GenXdevPlaywright[$key]
                try {
                    if ($state.Context) {
                        $state.Context.CloseAsync().GetAwaiter().GetResult()
                    }
                    if ($state.Browser -and $state.Browser.IsConnected) {
                        $state.Browser.CloseAsync().GetAwaiter().GetResult()
                    }
                    $Global:GenXdevPlaywright.Remove($key)
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Closed ${key} Playwright browser"
                    )
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning (
                        "Failed to close ${key} Playwright browser: $($_.Exception.Message)"
                    )
                    $Global:GenXdevPlaywright.Remove($key)
                }
            }

            # also kill any lingering ms-playwright processes
            $killedProcessIds = [System.Collections.Generic.List[int]]::new()
            Microsoft.PowerShell.Management\Get-Process -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Core\Where-Object {
                    $PSItem.Path -and ($PSItem.Path -like '*\ms-playwright\*')
                } |
                Microsoft.PowerShell.Core\ForEach-Object {
                    try {
                        $null = $PSItem.Kill()
                        $killedProcessIds.Add($PSItem.Id)
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Killed lingering Playwright process: $($PSItem.Id)"
                        )
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose (
                            "Could not kill process $($PSItem.Id): $_"
                        )
                    }
                }

            # wait up to 5 seconds for killed processes to fully exit
            # to release the profile directory SingletonLock
            if ($killedProcessIds.Count -gt 0) {
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Waiting for $($killedProcessIds.Count) " +
                    'Playwright process(es) to fully exit...'
                )
                $waitStart = [DateTime]::UtcNow
                $allExited = $false
                do {
                    Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 200
                    $stillRunning = @(
                        Microsoft.PowerShell.Management\Get-Process -Id $killedProcessIds `
                            -ErrorAction SilentlyContinue
                    )
                    $allExited = $stillRunning.Count -eq 0
                } while (-not $allExited -and
                    ([DateTime]::UtcNow - $waitStart).TotalSeconds -lt 5)

                if (-not $allExited) {
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Some Playwright processes did not exit within timeout'
                    )
                }
            }
        }

        # resolve which Playwright browser types to target based on switches
        function ResolvePlaywrightTargetKeys {
            $keys = [System.Collections.Generic.List[string]]::new()

            if ($Edge) {
                $keys.Add('EdgeNormal')
            }
            if ($Chrome) {
                $keys.Add('ChromeNormal')
            }
            if ($Chromium) {
                $keys.Add('ChromiumNormal')
                $keys.Add('ChromiumPlaywright')
            }
            if ($Firefox) {
                $keys.Add('FirefoxPlaywright')
            }
            if ($Webkit) {
                $keys.Add('WebKitPlaywright')
            }

            # if no specific browser switch is set alongside -PlayWright,
            # close all Playwright browsers (empty list = all)
            if ($keys.Count -eq 0) {
                return @()
            }
            return $keys.ToArray()
        }

        # close Playwright-managed browsers if requested
        if ($PlayWright) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Closing Playwright-managed browsers'

            $pwKeys = ResolvePlaywrightTargetKeys
            ClosePlaywrightBrowsers -TargetKeys $pwKeys

            # also clear legacy global state
            $Global:playwrightController = $null
            $Global:chromeSession = $null
            $Global:chrome = $null

            return
        }

        # close all browsers if requested
        if ($All) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Closing all browsers'
            $installedBrowsers | Microsoft.PowerShell.Core\ForEach-Object { Close-BrowserInstance $_ }

            # also close all Playwright-managed browsers when -All is used
            ClosePlaywrightBrowsers -TargetKeys @()

            $Global:playwrightController = $null
            $Global:chromeSession = $null
            $Global:chrome = $null

            return
        }

        # handle default chromium browser closure
        if ($Chromium -and -not ($Chrome -or $Edge)) {
            if ($defaultBrowser.Name -like '*Chrome*' -or
                $defaultBrowser.Name -like '*Edge*') {

                Close-BrowserInstance $defaultBrowser
                return
            }

            # fallback to first available chromium browser
            $installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $_.Name -like '*Edge*' -or $_.Name -like '*Chrome*' } |
                Microsoft.PowerShell.Utility\Select-Object -First 1 |
                Microsoft.PowerShell.Core\ForEach-Object {
                    Close-BrowserInstance $_
                }
            return
        }

        # handle specific browser closures
        if ($Chrome) {
            $installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $_.Name -like '*Chrome*' } |
                Microsoft.PowerShell.Core\ForEach-Object { Close-BrowserInstance $_ }
        }

        if ($Edge) {
            $installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $_.Name -like '*Edge*' } |
                Microsoft.PowerShell.Core\ForEach-Object { Close-BrowserInstance $_ }
        }

        if ($Firefox) {
            $installedBrowsers |
                Microsoft.PowerShell.Core\Where-Object { $_.Name -like '*Firefox*' } |
                Microsoft.PowerShell.Core\ForEach-Object { Close-BrowserInstance $_ }
        }

        # close default browser if no specific browser selected
        if (-not ($Chromium -or $Chrome -or $Edge -or $Firefox -or $PlayWright)) {
            Close-BrowserInstance $defaultBrowser
        }
    }

    end {
    }
}