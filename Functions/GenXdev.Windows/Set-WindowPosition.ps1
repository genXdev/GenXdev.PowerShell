<#
.SYNOPSIS
Positions and resizes windows when explicit positioning parameters are provided.

.DESCRIPTION
Provides precise control over window positioning and sizing when positioning
parameters are specified. Supports multiple monitors, border removal, and
various preset positions like left/right split, top/bottom split, and center
placement. Windows can be positioned by coordinates or using predefined layouts.
Without positioning parameters, the function performs no action on the window.

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

.PARAMETER ProcessName
The process name of the window to position

.PARAMETER Process
Process or processes whose windows need positioning

.PARAMETER WindowHelper
Window helper object for direct window manipulation

.PARAMETER Monitor
Monitor selection: 0=primary, 1+=specific monitor, -1=current, -2=secondary

.PARAMETER NoBorders
Removes window borders and title bar for a cleaner appearance

.PARAMETER Width
Window width in pixels

.PARAMETER Height
Window height in pixels

.PARAMETER X
Window horizontal position in pixels

.PARAMETER Y
Window vertical position in pixels

.PARAMETER Left
Places window on left half of screen

.PARAMETER Right
Places window on right half of screen

.PARAMETER Top
Places window on top half of screen

.PARAMETER Bottom
Places window on bottom half of screen

.PARAMETER Centered
Centers window on screen

.PARAMETER Fullscreen
Maximizes window to fill entire screen

.PARAMETER RestoreFocus
Returns focus to PowerShell window after positioning

.PARAMETER PassThru
Returns window helper object for further manipulation

.PARAMETER SideBySide
Will either set the window fullscreen on a different monitor than Powershell, or
side by side with Powershell on the same monitor

.PARAMETER FocusWindow
Focus the window after positioning

.PARAMETER SetForeground
Set the window to foreground after positioning

.PARAMETER Minimize
Minimizes the window after positioning

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER KeysToSend
Keystrokes to send to the window after positioning

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on target window when sending keys

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending keys

.PARAMETER SessionOnly
Switch to use alternative settings stored in session for AI preferences

.PARAMETER ClearSession
Switch to clear alternative settings stored in session for AI preferences

.PARAMETER SkipSession
Switch to store settings only in persistent preferences without affecting
session

.PARAMETER OnlyOutputCoords
Only output the calculated coordinates and size without actually positioning
the window. Returns a hashtable with Left, Top, Width, and Height properties
representing global (multi-monitor) coordinates

.EXAMPLE
Set-WindowPosition -Centered -Monitor 0 -NoBorders
Position PowerShell window centered on primary monitor with no borders

.EXAMPLE
Get-Process notepad,calc | wp -m 1 -l,-r
Split notepad and calc side by side on second monitor using aliases

.EXAMPLE
Set-WindowPosition -ProcessName notepad
Does nothing - no positioning parameters specified

.EXAMPLE
Set-WindowPosition -ProcessName notepad -KeysToSend "Hello World"
Sends keystrokes to notepad window without repositioning it

.EXAMPLE
Set-WindowPosition -ProcessName notepad -Left -Monitor 1 -OnlyOutputCoords
Returns the calculated coordinates where notepad would be placed on the left
side of monitor 1 without actually moving the window
#>
################################################################################
function Set-WindowPosition {

    [CmdletBinding(DefaultParameterSetName = 'Default', SupportsShouldProcess = $true)]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Alias('wp')]
    param(
        ########################################################################
        [parameter(
            ParameterSetName = 'ProcessName',
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'The process name of the window to position',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments = $false
        )]
        [SupportsWildcards()]
        [Alias('Name')]
        [string] $ProcessName,
        ########################################################################
        [parameter(
            ParameterSetName = 'Process',
            Mandatory = $false,
            HelpMessage = 'The process of the window to position',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments = $false
        )]
        [ValidateNotNull()]
        [System.Diagnostics.Process] $Process,
        ########################################################################
        [parameter(
            ParameterSetName = 'WindowHelper',
            Mandatory = $false,
            HelpMessage = 'Get-Window helper object for direct window manipulation',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments = $false
        )]
        [ValidateNotNull()]
        [GenXdev.Helpers.WindowObj[]] $WindowHelper,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Monitor selection: 0=primary, 1+=specific monitor, -1=current, -2=secondary'
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -1,
        ########################################################################
        [Alias('nb')]
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [switch] $NoBorders,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Window width in pixels'
        )]
        [int] $Width = -1,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Window height in pixels'
        )]
        [int] $Height = -999999,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Window horizontal position in pixels'
        )]
        [int] $X = -999999,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Window vertical position in pixels'
        )]
        [int] $Y = -999999,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the top side of the screen'
        )]
        [switch] $Top,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch] $Centered,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window'
        )]
        [Alias('fs')]
        [switch] $Fullscreen,
        ########################################################################

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch]$RestoreFocus,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Returns the window helper for each process'
        )]
        [Alias('pt')]
        [switch]$PassThru,
        ########################################################################
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Will either set the window fullscreen on a different ' +
                'monitor than Powershell, or side by side with Powershell on the ' +
                'same monitor')
        )]
        [Alias('sbs')]
        [switch]$SideBySide,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Minimizes the window after positioning'
        )]
        [switch] $Minimize,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore the window to normal state after positioning'
        )]
        [switch] $SetRestored,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Window, ' +
                'see documentation for cmdlet GenXdev\Send-Key')
        )]
        [string[]] $KeysToSend,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between different input strings in ' +
                'milliseconds when sending keys')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only output the calculated coordinates and size ' +
                'without actually positioning the window')
        )]
        [switch] $OnlyOutputCoords
        ########################################################################
    )

    begin {

        # initialize screen selection variable for monitor targeting
        $screen = $null
        [int] $setDefaultMonitor = $Global:DefaultSecondaryMonitor -is [int] ?
            (
                $Global:DefaultSecondaryMonitor
            ):
            2;

        # retrieve all available monitors from the system
        $allScreens = @([WpfScreenHelper.Screen]::AllScreens |
                Microsoft.PowerShell.Core\ForEach-Object { $PSItem })

        # log the total number of detected monitors for debugging
        Microsoft.PowerShell.Utility\Write-Verbose ("Found $($allScreens.Count) " +
            "monitors available for window positioning")

        # enumerate and log details of each available monitor
        for ($i = 0; $i -lt $allScreens.Count; $i++) {

            # get current monitor information for logging
            $screenInfo = $allScreens[$i]

            # log monitor specifications including size, position and device name
            Microsoft.PowerShell.Utility\Write-Verbose ("Monitor ${i}: " +
                "$($screenInfo.WorkingArea.Width)x$($screenInfo.WorkingArea.Height) " +
                "at ($($screenInfo.WorkingArea.X),$($screenInfo.WorkingArea.Y)) " +
                "Device: $($screenInfo.DeviceName)")
        }


        # obtain reference to powershell main window for focus restoration
        $powerShellWindow = GenXdev\Get-PowershellMainWindow

        # log powershell window information if successfully detected
        if ($null -ne $powerShellWindow) {

            Microsoft.PowerShell.Utility\Write-Verbose ("PowerShell window " +
                "found - Handle: $($powerShellWindow.Handle), " +
                "Position: $($powerShellWindow.Position().X)," +
                "$($powerShellWindow.Position().Y), " +
                "Size: $($powerShellWindow.Size().Width)x" +
                "$($powerShellWindow.Size().Height)")
        }
        else {

            # log warning when powershell window cannot be detected
            Microsoft.PowerShell.Utility\Write-Verbose ("PowerShell window " +
                "not found or not available")
        }

        # copy window positioning parameters for validation and logging
        $wpparams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\Set-WindowPosition'

        # log which positioning parameters were provided by the user
        Microsoft.PowerShell.Utility\Write-Verbose ("Window positioning " +
            "parameters available: $($wpparams.Keys -join ', ')")

        # determine if side-by-side mode should be forced due to monitor limitations
        $ForcedSideBySide = ($Monitor -eq -2) -and (
               ($allScreens.Count -lt 2)  -or
               (-not ($setDefaultMonitor -is [int] -and ($setDefaultMonitor -gt 0)))
        )

        if ($ForcedSideBySide) {

            Microsoft.PowerShell.Utility\Write-Verbose ("Forcing side-by-side " +
                "positioning: insufficient monitors ($($allScreens.Count)) or " +
                "invalid DefaultSecondaryMonitor " +
                "($setDefaultMonitor)")
        }

        # Store side-by-side request for processing in the process block
        # where we can handle both coordinate-only and actual window modes
        $SideBySideRequested = $SideBySide -or $ForcedSideBySide

        if ($SideBySideRequested -and (-not $OnlyOutputCoords)) {
            # Only configure side-by-side settings when actually positioning windows
            if ($null -ne $powerShellWindow) {
                Microsoft.PowerShell.Utility\Write-Verbose ("Configuring " +
                    "side-by-side positioning - PowerShell monitor: " +
                    "$($powerShellWindow.GetCurrentMonitor()), " +
                    "Target monitor: $($powerShellWindow.GetCurrentMonitor() + 1)")

                $SideBySide = $true
                $Monitor = $powerShellWindow.GetCurrentMonitor() + 1
                $SetForeground = $true
                $RestoreFocus = $true
                $SetRestored = $true
                $Maximize = $false
                $FullScreen = $false
                if ($null -ne $KeysToSend -and $KeysToSend.Count -eq 1 -and $KeysToSend[0] -in @('f', '{F11}')) {
                    $KeysToSend = $null
                }

                Microsoft.PowerShell.Utility\Write-Verbose ("Side-by-side final " +
                    "settings: Monitor=$Monitor, SetForeground=$SetForeground, " +
                    "RestoreFocus=$RestoreFocus, Maximize=$Maximize")
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose ("Side-by-side requested but PowerShell window not available - deferring to process block")
            }
        }

        # preserve bound parameters for use in subsequent function calls
        $myPSBoundParameters = $PSBoundParameters

        # determine if process lookup should be skipped for coordinate-only calculations
        # coordinate calculation mode only requires positioning math without window interaction
        $skipProcessLookup = $OnlyOutputCoords

        # resolve target process based on the parameter set specified by the user
        switch ($PSCmdlet.ParameterSetName) {
            'ProcessName' {
                # handle process lookup by name when not in coordinate-only mode
                if (-not $skipProcessLookup) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('ParameterSetName: ProcessName')

                    # search for processes matching the specified name with active windows
                    $foundProcess = Microsoft.PowerShell.Management\Get-Process `
                        -Name $ProcessName `
                        -ErrorAction SilentlyContinue |
                        Microsoft.PowerShell.Core\Where-Object `
                            -Property 'MainWindowHandle' `
                            -NE 0 |
                        Microsoft.PowerShell.Utility\Sort-Object `
                            -Property 'StartTime' `
                            -Descending |
                        Microsoft.PowerShell.Utility\Select-Object `
                            -First 1

                    # validate that a matching process with a window was found
                    if ($null -eq $foundProcess) {
                        Microsoft.PowerShell.Utility\Write-Verbose ("No process found with name '$ProcessName' (ProcessName set)")
                        Microsoft.PowerShell.Utility\Write-Error ('No process found with ' + "name '$ProcessName'")
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Verbose ("Process found: $($foundProcess.ProcessName) with ID $($foundProcess.Id) (ProcessName set)")
                        $Process = $foundProcess
                        Microsoft.PowerShell.Utility\Write-Verbose ('Found process: ' + "$($Process.ProcessName) with ID $($Process.Id)")
                    }
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose ('OnlyOutputCoords set - skipping process lookup for ProcessName')
                }
                break;
            }
            'Process' {
                if (-not $skipProcessLookup) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('ParameterSetName: Process')

                # get process by id first
                $foundProcess = Microsoft.PowerShell.Management\Get-Process `
                    -Id ($Process.Id) `
                    -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Core\Where-Object `
                        -Property 'MainWindowHandle' `
                        -NE 0

                if ($null -eq $foundProcess) {

                    Microsoft.PowerShell.Utility\Write-Verbose ("No process found by Id $($Process.Id), trying by Name $($Process.Name) (Process set)")

                    # fallback to process by name
                    $foundProcess = Microsoft.PowerShell.Management\Get-Process `
                        -Name ($Process.Name) `
                        -ErrorAction SilentlyContinue |
                        Microsoft.PowerShell.Core\Where-Object `
                            -Property 'MainWindowHandle' `
                            -NE 0

                    if ($null -eq $foundProcess) {

                        Microsoft.PowerShell.Utility\Write-Verbose ("No process found with name '$($Process.Name)' (Process set)")
                        Microsoft.PowerShell.Utility\Write-Error ('No process found with ' + "name '$($Process.Name)'")
                        $Process = $null

                    } else {

                        Microsoft.PowerShell.Utility\Write-Verbose ("Process found by Name: $($foundProcess.ProcessName) with ID $($foundProcess.Id) (Process set)")
                    }
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose ("Process found by Id: $($foundProcess.ProcessName) with ID $($foundProcess.Id) (Process set)")
                    $Process = $foundProcess
                    Microsoft.PowerShell.Utility\Write-Verbose ('Found process: ' + "$($Process.ProcessName) with ID $($Process.Id)")
                }
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose ('OnlyOutputCoords set - skipping process lookup for Process')
                }
                break;
            }
            'WindowHelper' {
                if (-not $skipProcessLookup) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('ParameterSetName: WindowHelper')

                # get processes from window helper handles
                $foundProcess = Microsoft.PowerShell.Management\Get-Process `
                    -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Core\Where-Object `
                        -Property MainWindowHandle `
                        -EQ $WindowHelper.Handle

                if ($null -eq $foundProcess) {

                    Microsoft.PowerShell.Utility\Write-Verbose ("No process found with window handle '$($WindowHelper.Handle)' (WindowHelper set)")
                    Microsoft.PowerShell.Utility\Write-Error ('No process found with ' + "window handle '$($WindowHelper.Handle)'")
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose ("Process found by WindowHelper: $($foundProcess.ProcessName) with ID $($foundProcess.Id) (WindowHelper set)")
                    $Process = $foundProcess
                    Microsoft.PowerShell.Utility\Write-Verbose ('Found process: ' + "$($Process.ProcessName) with ID $($Process.Id)")
                }
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose ('OnlyOutputCoords set - skipping process lookup for WindowHelper')
                }
                break;
            }
            default {
                if (-not $skipProcessLookup) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('ParameterSetName: default (using PowerShell main window process)')
                    # default to powershell main window process
                    $Process = (GenXdev\Get-PowershellMainWindowProcess)
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose ('OnlyOutputCoords set - skipping default process lookup')
                }
                break;
            }
        }
    }

    process {


        ########################################################################

        # handle coordinate-only calculation mode without process interaction
        # this mode calculates positioning coordinates without actually moving any window
        if ($OnlyOutputCoords) {

            Microsoft.PowerShell.Utility\Write-Verbose ('OnlyOutputCoords mode - calculating coordinates without process')

            # Handle side-by-side logic for coordinate calculation
            if ($SideBySideRequested) {
                Microsoft.PowerShell.Utility\Write-Verbose ('Side-by-side requested in coordinate-only mode')

                # For coordinate calculation, assume PowerShell is on primary monitor (index 0)
                # and use sensible defaults for side-by-side positioning
                $powerShellMonitorIndex = 0
                if ($allScreens.Count -gt 1) {
                    # Use next monitor for side-by-side if available
                    $Monitor = 1
                } else {
                    # Single monitor - use half-screen positioning
                    $Monitor = 0
                }

                $SideBySide = $true
                $SetForeground = $true
                $RestoreFocus = $true
                $SetRestored = $true
                $Maximize = $false
                $FullScreen = $false

                # Determine split direction based on primary monitor dimensions
                $primaryScreen = $allScreens[0]
                if ($primaryScreen.WorkingArea.Width -gt $primaryScreen.WorkingArea.Height) {
                    # Wide screen - split horizontally (right side)
                    $Right = $true
                    Microsoft.PowerShell.Utility\Write-Verbose ('Coordinate-only side-by-side: using right half of screen')
                } else {
                    # Tall screen - split vertically (top half)
                    $Top = $true
                    Microsoft.PowerShell.Utility\Write-Verbose ('Coordinate-only side-by-side: using top half of screen')
                }

                Microsoft.PowerShell.Utility\Write-Verbose ("Side-by-side coordinate calculation: Monitor=$Monitor, Right=$Right, Top=$Top")
            }

            # evaluate if any positioning parameters were provided for calculation
            $havePositioningParams = ($X -gt -999999) -or ($Y -gt -999999) `
                -or ($Width -gt 0) -or ($Height -gt 0) `
                -or $Left -or $Right -or $Top -or $Bottom `
                -or $Centered -or $Fullscreen -or $SideBySide `
                -or $Maximize -or $Minimize -or $NoBorders

            # return null if no positioning parameters were provided for calculation
            if (-not $havePositioningParams) {
                Microsoft.PowerShell.Utility\Write-Verbose ('No positioning parameters provided for coordinate calculation')
                return $null
            }
        }

        # begin processing windows that require positioning or focus changes
        if (($null -ne $Process) -or $OnlyOutputCoords) {

            # log which type of processing is being performed
            if ($null -ne $Process) {
                Microsoft.PowerShell.Utility\Write-Verbose ("Processing window for process: $($Process.ProcessName) (Id: $($Process.Id))")
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose ("Processing coordinate calculation (no process)")
            }

            # analyze all provided parameters to determine required operations
            $havePositioningParams = ($X -gt -999999) -or ($Y -gt -999999) `
                -or ($Width -gt 0) -or ($Height -gt 0) `
                -or $Left -or $Right -or $Top -or $Bottom `
                -or $Centered -or $Fullscreen -or $SideBySide `
                -or $Maximize -or $Minimize -or $NoBorders

            # check for focus and foreground control parameters
            $haveFocusParams = $SetForeground -or $FocusWindow -or $RestoreFocus -or ($KeysToSend -and ($KeysToSend.Count -gt 0))

            # determine overall processing requirements based on parameter analysis
            $shouldProcessWindow = $havePositioningParams -or $haveFocusParams -or ($null -ne $KeysToSend -and ($KeysToSend.Count -gt 0))

            # log comprehensive parameter analysis for troubleshooting and debugging
            Microsoft.PowerShell.Utility\Write-Verbose ("Positioning parameters " +
                "detected: $havePositioningParams (X=$X, Y=$Y, Width=$Width, " +
                "Height=$Height, Left=$Left, Right=$Right, Top=$Top, " +
                "Bottom=$Bottom, Centered=$Centered, Fullscreen=$Fullscreen, " +
                "SideBySide=$SideBySide, Maximize=$Maximize, Minimize=$Minimize, " +
                "NoBorders=$NoBorders)")

            # log focus and foreground parameter analysis for debugging
            Microsoft.PowerShell.Utility\Write-Verbose ("Focus parameters " +
                "detected: $haveFocusParams (SetForeground=$SetForeground, " +
                "FocusWindow=$FocusWindow, RestoreFocus=$RestoreFocus)")

            # log overall window processing decision based on parameter analysis
            Microsoft.PowerShell.Utility\Write-Verbose ("Should process window: " +
                "$shouldProcessWindow (positioning=$havePositioningParams, " +
                "focus=$haveFocusParams, keys=$($null -ne $KeysToSend -and ($KeysToSend.Count -gt 0)))")

            # obtain window handle for positioning operations (skip if coordinate-only mode)
            $window = $null
            $originalWindowState = $null
            if (-not $OnlyOutputCoords) {
                # get window object using either provided helper or process main window
                $window = $WindowHelper ? $WindowHelper : (GenXdev\Get-Window -ProcessId ($Process.Id))

                # capture current window state for potential restoration after positioning
                if ($null -ne $window) {
                    $originalWindowState = $window.CaptureState()
                    Microsoft.PowerShell.Utility\Write-Verbose ("Original window state captured: Maximized=$($originalWindowState.IsMaximized), Minimized=$($originalWindowState.IsMinimized)")
                }
            }

            # validate window object detection and log detailed window information
            if ($null -ne $window) {

                # log comprehensive window details for debugging and troubleshooting
                Microsoft.PowerShell.Utility\Write-Verbose ("`r`n-----------`r`nWindow object found:`r`n" +
                    "Title: $($window.Title)`r`n" +
                    "Handle: $($window.Handle)`r`n" +
                    "Position: $($window.Position().X),$($window.Position().Y)`r`n" +
                    "Size: $($window.Size().Width)x$($window.Size().Height)`r`n-----------")
            }
            else {

                # log appropriate message based on operation mode when window not found
                if (-not $OnlyOutputCoords) {
                    Microsoft.PowerShell.Utility\Write-Verbose ("No window object " +
                        "available for process $($Process.ProcessName)")
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose ("OnlyOutputCoords mode - no window object needed")
                }
            }

            # determine current monitor for window position comparison (skip in coordinate-only mode)
            $currentWindowScreen = $null
            if (($null -ne $window) -and (-not $OnlyOutputCoords)) {
                # detect which monitor currently contains the window based on position
                $currentWindowScreen = [WpfScreenHelper.Screen]::FromPoint(@{X = $window.Position().X; Y = $window.Position().Y })

                # log current monitor information for positioning reference
                Microsoft.PowerShell.Utility\Write-Verbose ("Window's current " +
                    "monitor detected: $($currentWindowScreen.DeviceName) - " +
                    "$($currentWindowScreen.WorkingArea.Width)x" +
                    "$($currentWindowScreen.WorkingArea.Height)")
            }
            # handle explicit primary monitor selection when monitor parameter is zero
            if ($Monitor -eq 0) {
                Microsoft.PowerShell.Utility\Write-Verbose ('Choosing primary ' +
                    'monitor, because default monitor requested using -Monitor 0')

                # select the system's primary monitor for window positioning
                $Screen = [WpfScreenHelper.Screen]::PrimaryScreen;

                # log primary monitor specifications for reference
                Microsoft.PowerShell.Utility\Write-Verbose ("Primary monitor " +
                    "selected: $($Screen.DeviceName) - " +
                    "$($Screen.WorkingArea.Width)x$($Screen.WorkingArea.Height) " +
                    "at ($($Screen.WorkingArea.X),$($Screen.WorkingArea.Y))")
            }
            elseif ((-not $SideBySide) -and ((GenXdev\Get-MonitorCount) -gt 1) -and $Monitor -eq -2 -and $setDefaultMonitor -is [int] -and $setDefaultMonitor -ge 0) {

                # use global default secondary monitor when available and valid
                $userMonitorNum = $setDefaultMonitor
                # For monitor selection, convert 1-based monitor number to 0-based array index
                # Monitor 1 = index 0, Monitor 2 = index 1, etc.
                $screenIndex = ($setDefaultMonitor - 1) % $AllScreens.Length
                Microsoft.PowerShell.Utility\Write-Verbose ('Picking monitor ' +
                    "#$userMonitorNum as secondary (requested with -monitor -2) " +
                    "set by `$Global:DefaultSecondaryMonitor")

                # select the user-configured secondary monitor from available screens
                $Screen = $AllScreens[$screenIndex];
                $Monitor = $setDefaultMonitor;

                # log secondary monitor selection details for verification
                Microsoft.PowerShell.Utility\Write-Verbose ("Secondary monitor " +
                    "selected: $($Screen.DeviceName) - " +
                    "$($Screen.WorkingArea.Width)x$($Screen.WorkingArea.Height) " +
                    "at ($($Screen.WorkingArea.X),$($Screen.WorkingArea.Y))")

            } elseif ($Monitor -eq -2 -and ((GenXdev\Get-MonitorCount) -gt 1) -and -not $SideBySide) {

                # fallback to first secondary monitor when global default not configured
                Microsoft.PowerShell.Utility\Write-Verbose ('Picking monitor #1 ' +
                    'as default secondary (requested with -monitor -2), because ' +
                    '`$Global:DefaultSecondaryMonitor not set')

                # select monitor index 1 as default secondary from available screens
                $Screen = $AllScreens[1 % $AllScreens.Length];

                # log fallback secondary monitor selection for reference
                Microsoft.PowerShell.Utility\Write-Verbose ("Default secondary " +
                    "monitor selected: $($Screen.DeviceName) - " +
                    "$($Screen.WorkingArea.Width)x$($Screen.WorkingArea.Height) " +
                    "at ($($Screen.WorkingArea.X),$($Screen.WorkingArea.Y))")
            }
            elseif ($Monitor -eq -2 -and -not $SideBySide) {
                # fallback to primary monitor when secondary monitor requested but unavailable
                Microsoft.PowerShell.Utility\Write-Verbose ('Monitor -2 requested ' + 'but no secondary monitor found, defaulting to primary.')
                $Monitor = 0
                $Screen = [WpfScreenHelper.Screen]::PrimaryScreen;

                # log fallback to primary monitor when secondary not available
                Microsoft.PowerShell.Utility\Write-Verbose ("Fallback to primary " +
                    "monitor: $($Screen.DeviceName) - " +
                    "$($Screen.WorkingArea.Width)x$($Screen.WorkingArea.Height) " +
                    "at ($($Screen.WorkingArea.X),$($Screen.WorkingArea.Y))")
            }
            elseif ((-not $SideBySide) -and $Monitor -ge 1) {

                # select specific monitor by user-provided number (1-based indexing)
                # Convert 1-based monitor number to 0-based array index
                $selectedIndex = ($Monitor - 1) % $AllScreens.Length

                Microsoft.PowerShell.Utility\Write-Verbose ('Picking monitor ' +
                    "#$Monitor (array index $selectedIndex) as requested by the -Monitor parameter")

                # select the specific monitor from available screens array
                $Screen = $AllScreens[$selectedIndex]

                # log requested monitor selection details for verification
                Microsoft.PowerShell.Utility\Write-Verbose ("Requested monitor " +
                    "selected: $($Screen.DeviceName) - " +
                    "$($Screen.WorkingArea.Width)x$($Screen.WorkingArea.Height) " +
                    "at ($($Screen.WorkingArea.X),$($Screen.WorkingArea.Y))")
            }
            else {
                # handle default monitor selection based on current context
                if (-not $SideBySide) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Picking monitor ' + '#1 (FromPoint)')
                    # use window's current monitor as default for positioning operations
                    $Screen = $currentWindowScreen

                    # fallback to primary monitor if no current window screen in coordinate-only mode
                    if ($null -eq $Screen) {
                        Microsoft.PowerShell.Utility\Write-Verbose ('No current window screen available, using primary monitor')
                        $Screen = $allScreens[0]
                    }

                    # log current monitor selection when successfully detected
                    if ($null -ne $Screen) {

                        Microsoft.PowerShell.Utility\Write-Verbose ("Monitor used: $($Screen.DeviceName) - " +
                            "$($Screen.WorkingArea.Width)x$($Screen.WorkingArea.Height) " +
                            "at ($($Screen.WorkingArea.X),$($Screen.WorkingArea.Y))")
                    }
                }
                else {
                    # use powershell's monitor for side-by-side positioning reference
                    if (($null -ne $powerShellWindow) -and (-not $OnlyOutputCoords)) {
                        $Screen = $allScreens[$powerShellWindow.GetCurrentMonitor()]
                        Microsoft.PowerShell.Utility\Write-Verbose ("PowerShell's " +
                            "current monitor used for side-by-side: " +
                            "$($Screen.DeviceName) - " +
                            "$($Screen.WorkingArea.Width)x$($Screen.WorkingArea.Height) " +
                            "at ($($Screen.WorkingArea.X),$($Screen.WorkingArea.Y))")
                    } else {
                        # In coordinate-only mode or when PowerShell window not available, use primary monitor
                        $Screen = $allScreens[0]
                        Microsoft.PowerShell.Utility\Write-Verbose ("Side-by-side coordinate calculation using primary monitor: " +
                            "$($Screen.DeviceName) - " +
                            "$($Screen.WorkingArea.Width)x$($Screen.WorkingArea.Height) " +
                            "at ($($Screen.WorkingArea.X),$($Screen.WorkingArea.Y))")
                    }
                }
            }

            # handle side-by-side positioning
            if ($SideBySide -and (($null -eq $powerShellWindow) -or ($null -eq $window) -or ($powerShellWindow.Handle -ne $window.Handle) -or $OnlyOutputCoords)) {

                Microsoft.PowerShell.Utility\Write-Verbose ('SideBySide requested')

                if ($OnlyOutputCoords) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Side-by-side coordinate calculation mode')
                    # In coordinate-only mode, position logic is already set above
                    # Just ensure the positioning flags are properly set
                    $FullScreen = $false
                    $Centered = $false
                    $RestoreFocus = $true
                } else {
                    # Normal side-by-side window positioning
                    $PowershellScreen = $Screen  # Use the same screen as determined above
                    $powershellMonitorIndex = $AllScreens.IndexOf($PowershellScreen) + 1
                    Microsoft.PowerShell.Utility\Write-Verbose ('Window and PowerShell are ' + 'on the same screen.')
                    Microsoft.PowerShell.Utility\Write-Verbose ("PowerShell screen index: " +
                        "$powershellMonitorIndex for side-by-side positioning")

                    $Left = $false; $Top = $false; $Right = $false; $FullScreen = $false; $Centered = $false
                    if ($null -ne $KeysToSend -and $KeysToSend.Count -eq 1 -and $KeysToSend[0] -in @('f', '{F11}')) {
                        $KeysToSend = @()
                    }
                    $RestoreFocus = $true

                    # split horizontally or vertically based on screen orientation
                    if ($PowershellScreen.WorkingArea.Width -gt $PowershellScreen.WorkingArea.Height) {
                        Microsoft.PowerShell.Utility\Write-Verbose ('Screen is wider than ' +
                            'tall, splitting horizontally (Left). Screen dimensions: ' +
                            "$($PowershellScreen.WorkingArea.Width)x" +
                            "$($PowershellScreen.WorkingArea.Height)")
                        GenXdev\Set-WindowPosition -Left -Monitor $powershellMonitorIndex
                        $FullScreen = $false
                        $Right = $true
                        Microsoft.PowerShell.Utility\Write-Verbose ('PowerShell moved to ' + 'left, target window will be positioned on right')
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Verbose ('Screen is taller than ' +
                            'wide, splitting vertically (Bottom). Screen dimensions: ' +
                            "$($PowershellScreen.WorkingArea.Width)x" +
                            "$($PowershellScreen.WorkingArea.Height)")
                        GenXdev\Set-WindowPosition -Bottom -Monitor $powershellMonitorIndex
                        $FullScreen = $false
                        $Top = $true
                        Microsoft.PowerShell.Utility\Write-Verbose ('PowerShell moved to ' + 'bottom, target window will be positioned at top')
                    }
                }
            }

            if ($null -eq $screen) {
                Microsoft.PowerShell.Utility\Write-Verbose ("No screen object set, using window's current monitor as fallback.")
                $screen = $currentWindowScreen ? $currentWindowScreen : $allScreens[0]
            }

            # detect if monitor change is being requested (skip in coordinate-only mode)
            $isMonitorChangeRequest = $false
            if (($Monitor -ge 0) -and ($null -ne $currentWindowScreen) -and ($null -ne $Screen) -and (-not $OnlyOutputCoords)) {

                $isMonitorChangeRequest = ($currentWindowScreen.DeviceName -ne $Screen.DeviceName)

                if ($isMonitorChangeRequest) {

                    Microsoft.PowerShell.Utility\Write-Verbose ("Monitor change " +
                        "detected: Moving window from " +
                        "'$($currentWindowScreen.DeviceName)' to " +
                        "'$($Screen.DeviceName)'")
                    Microsoft.PowerShell.Utility\Write-Verbose ("Source monitor " +
                        "working area: $($currentWindowScreen.WorkingArea.Width)x" +
                        "$($currentWindowScreen.WorkingArea.Height) at " +
                        "($($currentWindowScreen.WorkingArea.X)," +
                        "$($currentWindowScreen.WorkingArea.Y))")
                    Microsoft.PowerShell.Utility\Write-Verbose ("Target monitor " +
                        "working area: $($Screen.WorkingArea.Width)x" +
                        "$($Screen.WorkingArea.Height) at " +
                        "($($Screen.WorkingArea.X),$($Screen.WorkingArea.Y))")

                    # Monitor change implies positioning is needed
                    if (-not $havePositioningParams) {

                        Microsoft.PowerShell.Utility\Write-Verbose ('No explicit ' + 'positioning parameters, but monitor change requested ' +
                            '- enabling positioning for monitor change')
                        $havePositioningParams = $true

                        Microsoft.PowerShell.Utility\Write-Verbose ('Detecting ' +
                            'current window position to preserve when moving to ' +
                            'new monitor')

                        # Get current window position and size
                        $currentPos = $window.Position()
                        $currentSize = $window.Size()
                        $currentWorkArea = $currentWindowScreen.WorkingArea

                        # Calculate relative position within current monitor's work area
                        $relativeX = ($currentPos.X - $currentWorkArea.X) / $currentWorkArea.Width
                        $relativeY = ($currentPos.Y - $currentWorkArea.Y) / $currentWorkArea.Height
                        $relativeWidth = $currentSize.Width / $currentWorkArea.Width
                        $relativeHeight = $currentSize.Height / $currentWorkArea.Height

                        Microsoft.PowerShell.Utility\Write-Verbose ("Current relative position: X=$([Math]::Round($relativeX, 2)), Y=$([Math]::Round($relativeY, 2)), W=$([Math]::Round($relativeWidth, 2)), H=$([Math]::Round($relativeHeight, 2))")

                        # Detect positioning style based on relative position and size
                        $tolerance = 0.1  # 10% tolerance for position detection
                        $sizeTolerance = 0.4  # 40% minimum size to consider positioned (allows for half-screen at 50%)

                        # Determine primary positioning based on which dimension is more constrained
                        # If width is more constrained (< 90% of screen), check left/right first
                        # If height is more constrained (< 90% of screen), check top/bottom first

                        $widthConstrained = $relativeWidth -lt 0.9
                        $heightConstrained = $relativeHeight -lt 0.9

                        # Priority 1: Check the more constrained dimension first
                        if ($widthConstrained -and (-not $heightConstrained)) {
                            # Width is constrained, height spans most/all screen - check left/right
                            if ($relativeWidth -ge $sizeTolerance) {
                                if ($relativeX -le $tolerance) {
                                    $Left = $true
                                    Microsoft.PowerShell.Utility\Write-Verbose ('Detected LEFT positioning (full height) - preserving on new monitor')
                                } elseif (($relativeX + $relativeWidth) -ge (1.0 - $tolerance)) {
                                    $Right = $true
                                    Microsoft.PowerShell.Utility\Write-Verbose ('Detected RIGHT positioning (full height) - preserving on new monitor')
                                }
                            }
                        } elseif ($heightConstrained -and (-not $widthConstrained)) {
                            # Height is constrained, width spans most/all screen - check top/bottom
                            if ($relativeHeight -ge $sizeTolerance) {
                                if ($relativeY -le $tolerance) {
                                    $Top = $true
                                    Microsoft.PowerShell.Utility\Write-Verbose ('Detected TOP positioning (full width) - preserving on new monitor')
                                } elseif (($relativeY + $relativeHeight) -ge (1.0 - $tolerance)) {
                                    $Bottom = $true
                                    Microsoft.PowerShell.Utility\Write-Verbose ('Detected BOTTOM positioning (full width) - preserving on new monitor')
                                }
                            }
                        } elseif ($widthConstrained -and $heightConstrained) {
                            # Both dimensions constrained - check for corner positioning or centered
                            $centerX = $relativeX + ($relativeWidth / 2)
                            $centerY = $relativeY + ($relativeHeight / 2)

                            # Window with 10% margins (like X=0.1, W=0.8) should be considered centered
                            $leftMargin = $relativeX
                            $rightMargin = 1.0 - ($relativeX + $relativeWidth)
                            $topMargin = $relativeY
                            $bottomMargin = 1.0 - ($relativeY + $relativeHeight)

                            # Consider centered if ALL margins are small (≤ 10% for more reasonable detection)
                            $hasSmallMargins = ($leftMargin -le 0.1) -and ($rightMargin -le 0.1) -and ($topMargin -le 0.1) -and ($bottomMargin -le 0.1)

                            Microsoft.PowerShell.Utility\Write-Verbose ("Positioning check: centerX=$([Math]::Round($centerX, 2)), centerY=$([Math]::Round($centerY, 2))")
                            Microsoft.PowerShell.Utility\Write-Verbose ("Window bounds: X=$([Math]::Round($relativeX, 2)), Y=$([Math]::Round($relativeY, 2)), W=$([Math]::Round($relativeWidth, 2)), H=$([Math]::Round($relativeHeight, 2))")
                            Microsoft.PowerShell.Utility\Write-Verbose ("Actual margins: Left=$([Math]::Round($leftMargin, 3)), Right=$([Math]::Round($rightMargin, 3)), Top=$([Math]::Round($topMargin, 3)), Bottom=$([Math]::Round($bottomMargin, 3))")
                            Microsoft.PowerShell.Utility\Write-Verbose ("Has small margins (all ≤ 10%): $hasSmallMargins")

                            # If window has small margins on all sides, consider it centered
                            if ($hasSmallMargins) {
                                $Centered = $true
                                Microsoft.PowerShell.Utility\Write-Verbose ('Detected CENTERED positioning (small margins on all sides) - preserving on new monitor')
                            } else {
                                # Check for specific edge positioning
                                # Check left/right first
                                if ($relativeWidth -ge $sizeTolerance) {
                                    if ($relativeX -le $tolerance) {
                                        $Left = $true
                                        Microsoft.PowerShell.Utility\Write-Verbose ('Detected LEFT positioning - preserving on new monitor')
                                    } elseif (($relativeX + $relativeWidth) -ge (1.0 - $tolerance)) {
                                        $Right = $true
                                        Microsoft.PowerShell.Utility\Write-Verbose ('Detected RIGHT positioning - preserving on new monitor')
                                    }
                                }
                                # Then check top/bottom
                                if ($relativeHeight -ge $sizeTolerance) {
                                    if ($relativeY -le $tolerance) {
                                        $Top = $true
                                        Microsoft.PowerShell.Utility\Write-Verbose ('Detected TOP positioning - preserving on new monitor')
                                    } elseif (($relativeY + $relativeHeight) -ge (1.0 - $tolerance)) {
                                        $Bottom = $true
                                        Microsoft.PowerShell.Utility\Write-Verbose ('Detected BOTTOM positioning - preserving on new monitor')
                                    }
                                }

                                # If no specific positioning detected, just enable positioning for auto-sizing
                                if ((-not $Left) -and (-not $Right) -and (-not $Top) -and (-not $Bottom)) {
                                    Microsoft.PowerShell.Utility\Write-Verbose ('No specific positioning detected - enabling auto-sizing to maximum')
                                }
                            }
                        } else {
                            # Neither dimension particularly constrained - likely fullscreen or very large window
                            # Check margins for large window centered detection
                            $leftMargin = $relativeX
                            $rightMargin = 1.0 - ($relativeX + $relativeWidth)
                            $topMargin = $relativeY
                            $bottomMargin = 1.0 - ($relativeY + $relativeHeight)

                            # For large windows, be even more generous (≤ 15% margins)
                            $hasSmallMargins = ($leftMargin -le 0.15) -and ($rightMargin -le 0.15) -and ($topMargin -le 0.15) -and ($bottomMargin -le 0.15)

                            if (-not $hasSmallMargins) {
                                $Centered = $true
                                Microsoft.PowerShell.Utility\Write-Verbose ('Detected CENTERED positioning (large window with small margins) - preserving on new monitor')
                            } else {
                                Microsoft.PowerShell.Utility\Write-Verbose ('Large window not centered - enabling auto-sizing to maximum')
                            }
                        }
                    }
                }
            }

            # calculate final window coordinates and dimensions
            if (($X -le -999999) -or ($X -isnot [int])) {
                Microsoft.PowerShell.Utility\Write-Verbose ('X not provided or invalid, using screen.WorkingArea.X')
                $X = $Screen.WorkingArea.X;
            }
            else {
                # adjust x position for monitor offset
                if ($Monitor -ge 0) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Adjusting X for monitor offset.')
                    $X = $Screen.WorkingArea.X + $X;
                }
            }
            Microsoft.PowerShell.Utility\Write-Verbose ("X determined to be $X")
            # calculate y position
            if (($Y -le -999999) -or ($Y -isnot [int])) {
                Microsoft.PowerShell.Utility\Write-Verbose ('Y not provided or invalid, using screen.WorkingArea.Y')
                $Y = $Screen.WorkingArea.Y;
            }
            else {
                # adjust y position for monitor offset
                if ($Monitor -ge 0) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Adjusting Y for monitor offset.')
                    $Y = $Screen.WorkingArea.Y + $Y;
                }
            }
            Microsoft.PowerShell.Utility\Write-Verbose ("Y determined to be $Y")
            # set fullscreen dimensions if requested
            if ($Fullscreen -eq $true) {
                Microsoft.PowerShell.Utility\Write-Verbose ('Fullscreen requested, setting Width/Height to screen.WorkingArea.')
                $Width = $Screen.WorkingArea.Width;
                $Height = $Screen.WorkingArea.Height;
            }
            Microsoft.PowerShell.Utility\Write-Verbose ('Have positioning parameters set')

            # Reset width/height for smart positioning if detected during monitor change
            if ($isMonitorChangeRequest -and ($Left -or $Right -or $Top -or $Bottom -or $Centered)) {
                $Width = -999999
                $Height = -999999
                Microsoft.PowerShell.Utility\Write-Verbose ('Reset Width/Height to allow smart positioning to control sizing')
            }

            # check if width and height were explicitly provided
            $widthProvided = ($Width -gt 0) -and ($Width -is [int]);
            $heightProvided = ($Height -gt 0) -and ($Height -is [int]);
            # use screen width if width not provided
            if ($widthProvided -eq $false) {
                Microsoft.PowerShell.Utility\Write-Verbose ('Width not provided, using screen.WorkingArea.Width')
                $Width = $Screen.WorkingArea.Width;
                Microsoft.PowerShell.Utility\Write-Verbose ('Width not provided ' + "resetted to $Width")
            }
            # use screen height if height not provided
            if ($heightProvided -eq $false) {
                Microsoft.PowerShell.Utility\Write-Verbose ('Height not provided, using screen.WorkingArea.Height')
                $Height = $Screen.WorkingArea.Height;
                Microsoft.PowerShell.Utility\Write-Verbose ('Height not provided ' + "resetted to $Height")
            }
            # apply layout positioning (left/right/top/bottom/centered)
            if ($Left -eq $true) {
                Microsoft.PowerShell.Utility\Write-Verbose ('Left positioning requested.')
                $X = $Screen.WorkingArea.X;
                Microsoft.PowerShell.Utility\Write-Verbose ("Left positioning: " +
                    "X coordinate set to screen working area left edge: $X")
                # use half width if not explicitly provided
                if ($widthProvided -eq $false) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Width not provided ' + 'for Left, using half screen width.')
                    $Width = [Math]::Min($Screen.WorkingArea.Width / 2, $Width);
                    Microsoft.PowerShell.Utility\Write-Verbose ("Auto-calculated " +
                        "width for left positioning: $Width (half of " +
                        "$($Screen.WorkingArea.Width))")
                }
                Microsoft.PowerShell.Utility\Write-Verbose ("Left chosen, " +
                    "X = $X, Width = $Width")
            }
            else {
                # position on right side
                if ($Right -eq $true) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Right positioning requested.')
                    # use half width if not explicitly provided
                    if ($widthProvided -eq $false) {
                        Microsoft.PowerShell.Utility\Write-Verbose ('Width not ' + 'provided for Right, using half screen width.')
                        $Width = [Math]::Min($Screen.WorkingArea.Width / 2, $Width);
                        Microsoft.PowerShell.Utility\Write-Verbose ("Auto-calculated " +
                            "width for right positioning: $Width (half of " +
                            "$($Screen.WorkingArea.Width))")
                    }
                    $X = $Screen.WorkingArea.X + $Screen.WorkingArea.Width - $Width;
                    Microsoft.PowerShell.Utility\Write-Verbose ("Right positioning: " +
                        "X coordinate calculated as " +
                        "$($Screen.WorkingArea.X) + $($Screen.WorkingArea.Width) " +
                        "- $Width = $X")
                    Microsoft.PowerShell.Utility\Write-Verbose ("Right chosen, " +
                        "X = $X, Width = $Width")
                }
            }
            # position on top
            if ($Top -eq $true) {
                Microsoft.PowerShell.Utility\Write-Verbose ('Top positioning requested.')
                $Y = $Screen.WorkingArea.Y;
                Microsoft.PowerShell.Utility\Write-Verbose ("Top positioning: " +
                    "Y coordinate set to screen working area top edge: $Y")
                # use half height if not explicitly provided
                if ($heightProvided -eq $false) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Height not provided ' + 'for Top, using half screen height.')
                    $Height = [Math]::Min($Screen.WorkingArea.Height / 2, $Height);
                    Microsoft.PowerShell.Utility\Write-Verbose ("Auto-calculated " +
                        "height for top positioning: $Height (half of " +
                        "$($Screen.WorkingArea.Height))")
                }
                Microsoft.PowerShell.Utility\Write-Verbose ("Top chosen, " +
                    "Y = $Y, Height = $Height")
            }
            else {
                # position on bottom
                if ($Bottom -eq $true) {
                    Microsoft.PowerShell.Utility\Write-Verbose ('Bottom positioning requested.')
                    # use half height if not explicitly provided
                    if ($heightProvided -eq $false) {
                        Microsoft.PowerShell.Utility\Write-Verbose ('Height not ' + 'provided for Bottom, using half screen height.')
                        $Height = [Math]::Min($Screen.WorkingArea.Height / 2, $Height);
                        Microsoft.PowerShell.Utility\Write-Verbose ("Auto-calculated " +
                            "height for bottom positioning: $Height (half of " +
                            "$($Screen.WorkingArea.Height))")
                    }
                    $Y = $Screen.WorkingArea.Y + $Screen.WorkingArea.Height - $Height;
                    Microsoft.PowerShell.Utility\Write-Verbose ("Bottom positioning: " +
                        "Y coordinate calculated as " +
                        "$($Screen.WorkingArea.Y) + $($Screen.WorkingArea.Height) " +
                        "- $Height = $Y")
                    Microsoft.PowerShell.Utility\Write-Verbose ("Bottom chosen, " +
                        "Y = $Y, Height = $Height")
                }
            }
            # center window on screen
            if ($Centered -eq $true) {

                Microsoft.PowerShell.Utility\Write-Verbose ('Centered positioning requested.')

                # use 80% of screen dimensions if not explicitly provided
                if ($heightProvided -eq $false) {

                    Microsoft.PowerShell.Utility\Write-Verbose ('Height not provided ' + 'for Centered, using 80% of screen height.')
                    $Height = [Math]::Round([Math]::Min($Screen.WorkingArea.Height * 0.8, $Height), 0);

                    Microsoft.PowerShell.Utility\Write-Verbose ("Auto-calculated " +
                        "height for centered positioning: $Height (80% of " +
                        "$($Screen.WorkingArea.Height))")
                }

                if ($widthProvided -eq $false) {

                    Microsoft.PowerShell.Utility\Write-Verbose ('Width not provided ' + 'for Centered, using 80% of screen width.')

                    $Width = [Math]::Round([Math]::Min($Screen.WorkingArea.Width * 0.8, $Width), 0);

                    Microsoft.PowerShell.Utility\Write-Verbose ("Auto-calculated " +
                        "width for centered positioning: $Width (80% of " +
                        "$($Screen.WorkingArea.Width))")
                }

                # calculate center position
                $X = $Screen.WorkingArea.X + [Math]::Round(($screen.WorkingArea.Width - $Width) / 2, 0);
                $Y = $Screen.WorkingArea.Y + [Math]::Round(($screen.WorkingArea.Height - $Height) / 2, 0);

                Microsoft.PowerShell.Utility\Write-Verbose ("Centered position " +
                    "calculation: X = $($Screen.WorkingArea.X) + " +
                    "(($($screen.WorkingArea.Width) - $Width) / 2) = $X")
                Microsoft.PowerShell.Utility\Write-Verbose ("Centered position " +
                    "calculation: Y = $($Screen.WorkingArea.Y) + " +
                    "(($($screen.WorkingArea.Height) - $Height) / 2) = $Y")
                Microsoft.PowerShell.Utility\Write-Verbose ("Centered chosen, " +
                    "X = $X, Width = $Width, Y = $Y, Height = $Height")
            }

            # recalculate shouldProcessWindow after all positioning logic is complete
            # (monitor change detection may have updated havePositioningParams)
            $shouldProcessWindow = $havePositioningParams -or $haveFocusParams -or ($null -ne $KeysToSend -and ($KeysToSend.Count -gt 0))

            Microsoft.PowerShell.Utility\Write-Verbose ("Final shouldProcessWindow check: $shouldProcessWindow (positioning=$havePositioningParams, focus=$haveFocusParams, keys=$($null -ne $KeysToSend -and ($KeysToSend.Count -gt 0)))")

            # if OnlyOutputCoords is set, return the calculated coordinates without positioning
            if ($OnlyOutputCoords) {
                Microsoft.PowerShell.Utility\Write-Verbose ('OnlyOutputCoords specified - returning calculated coordinates without positioning window')

                $coordsOutput = @{
                    Left   = $X
                    Top    = $Y
                    Width  = $Width
                    Height = $Height
                }

                Microsoft.PowerShell.Utility\Write-Verbose ("Calculated coordinates: Left=$($coordsOutput.Left), Top=$($coordsOutput.Top), Width=$($coordsOutput.Width), Height=$($coordsOutput.Height)")

                return $coordsOutput
            }

            if (-not $shouldProcessWindow) {
                Microsoft.PowerShell.Utility\Write-Verbose ('No positioning, focus, or key parameters provided - exiting early')
                return;
            }

            # confirm with user if whatif support is enabled
            $whatIfMessage = if ($havePositioningParams) {
                "Set position/size to: X=$X Y=$Y W=$Width H=$Height"
            } elseif ($haveFocusParams) {
                "Apply focus/foreground changes"
            } elseif ($null -ne $KeysToSend -and ($KeysToSend.Count -gt 0)) {
                "Send keystrokes: $($KeysToSend -join ', ')"
            }
            else {
                "No additional information available"
            }

            if ($PSCmdlet.ShouldProcess(
                    "Window of process '$($Process.ProcessName)'",
                    $whatIfMessage)) {

                Microsoft.PowerShell.Utility\Write-Verbose ('ShouldProcess returned ' + 'true, proceeding with window operations.')

                if ($havePositioningParams) {
                    Microsoft.PowerShell.Utility\Write-Verbose ("Final window positioning: " +
                        "Process='$($Process.ProcessName))', Handle=$($window.Handle), " +
                        "Target coordinates: X=$X, Y=$Y, Width=$Width, Height=$Height")

                    Microsoft.PowerShell.Utility\Write-Verbose ("Target monitor: " +
                        "$($Screen.DeviceName) - Working area: " +
                        "$($Screen.WorkingArea.Width)x$($Screen.WorkingArea.Height) " +
                        "at ($($Screen.WorkingArea.X),$($Screen.WorkingArea.Y))")
                } else {
                    Microsoft.PowerShell.Utility\Write-Verbose ("Processing window for focus/foreground or keystroke operations only - no positioning")
                }

                # have a handle to the mainwindow of the browser?
                if ($null -ne $window) {

                    if ($havePositioningParams) {
                        Microsoft.PowerShell.Utility\Write-Verbose ('Restoring and ' +
                            'positioning window')

                        # restore window from maximized/minimized state first
                        Microsoft.PowerShell.Utility\Write-Verbose ('Restoring window from maximized/minimized state')
                        $null = $window.Restore()

                        # focus and position window
                        Microsoft.PowerShell.Utility\Write-Verbose ('Showing window ' + '(first call to ensure window is visible)')
                        $null = $window.Focus()
                        Microsoft.PowerShell.Utility\Write-Verbose ("[Set-WindowPosition] " +
                            "About to move window. Handle: $($window.Handle) " +
                            "Target: X=$X, Y=$Y, Width=$Width, Height=$Height")
                        Microsoft.PowerShell.Utility\Write-Verbose ('Executing first ' + 'Move operation to set window position and size')
                        $null = $window.Move($X, $Y, $Width, $Height)
                        Microsoft.PowerShell.Utility\Write-Verbose ('Executing second ' + 'Move operation for stability (some windows need this)')
                        $null = $window.Move($X, $Y, $Width, $Height)
                        Microsoft.PowerShell.Utility\Write-Verbose ('Window positioning ' + 'operations completed successfully')
                    } else {
                        Microsoft.PowerShell.Utility\Write-Verbose ('No positioning parameters - skipping window positioning operations')
                    }
                    # maximize window if fullscreen requested
                    if ($Fullscreen) {

                        Microsoft.PowerShell.Utility\Write-Verbose ('Fullscreen ' + 'requested, sending F11 keystroke.')
                        $KeysToSend = ($KeysToSend ? $KeysToSend : @()) + @('{F11}')
                    }
                    # needs to be set noborders manually?
                    if ($NoBorders -eq $true) {

                        Microsoft.PowerShell.Utility\Write-Verbose ('Setting NoBorders ' + '- removing window chrome and decorations')
                        $null = $window.RemoveBorder();
                        Microsoft.PowerShell.Utility\Write-Verbose ('Window border ' + 'removal completed')
                    }

                    if ($Maximize) {

                        if ($PSBoundParameters.Count -gt 1) {
                            Microsoft.PowerShell.Utility\Start-Sleep 1
                        }

                        Microsoft.PowerShell.Utility\Write-Verbose ('Maximize requested, maximizing window.')
                        $null = $window.Maximize()
                        Microsoft.PowerShell.Utility\Write-Verbose ('Window maximization completed')
                    }
                    elseif ($Minimize) {

                        Microsoft.PowerShell.Utility\Write-Verbose ('Minimize requested, minimizing window.')
                        $null = $window.Minimize()
                        Microsoft.PowerShell.Utility\Write-Verbose ('Window minimization completed')
                    }
                    elseif ($SetRestored) {

                        Microsoft.PowerShell.Utility\Write-Verbose ('SetRestored requested, ensuring window is in normal state.')
                        $null = $window.Restore()
                        Microsoft.PowerShell.Utility\Write-Verbose ('Window restored to normal state')
                    }
                    elseif ($havePositioningParams -and ($null -ne $originalWindowState)) {

                        # No explicit state requested, but we moved the window
                        # Restore original state, but never restore to minimized
                        # (if you call Set-WindowPosition, you want to see the window)
                        if ($originalWindowState.IsMaximized) {
                            Microsoft.PowerShell.Utility\Write-Verbose ('Restoring original maximized state after positioning')
                            $null = $window.Maximize()
                        }
                        elseif ($originalWindowState.IsMinimized) {
                            Microsoft.PowerShell.Utility\Write-Verbose ('Window was minimized, but restoring to normal state (not minimized) since Set-WindowPosition was called')
                            $null = $window.Restore()
                        }
                        else {
                            Microsoft.PowerShell.Utility\Write-Verbose ('Preserving original normal window state')
                            # Already in normal state from the Restore() call before Move()
                        }
                    }
                    # handle focus and foreground - if both requested, SetForeground handles both
                    if ($SetForeground -eq $true) {
                        Microsoft.PowerShell.Utility\Write-Verbose ('Setting window to ' +
                            'foreground (bringing to front and giving focus)')
                        $null = $window.SetForeground()
                        Microsoft.PowerShell.Utility\Write-Verbose ('Window foreground ' + 'operation completed')
                    }
                    elseif ($FocusWindow -eq $true) {
                        Microsoft.PowerShell.Utility\Write-Verbose ('Focusing window')
                        $null = $window.Focus()
                    }
                    # send keys if specified, after a delay to ensure window is ready
                    if ($null -ne $KeysToSend -and ($KeysToSend.Count -gt 0)) {

                        $KeysToSend = @($KeysToSend | Microsoft.PowerShell.Core\Where-Object { -not [string]::IsNullOrEmpty($_) })

                        if ($null -ne $KeysToSend -and ($KeysToSend.Count -gt 0)) {

                            Microsoft.PowerShell.Utility\Write-Verbose ('Sending keystrokes ' +
                                'to window after 500ms delay. Keys to send: ' +
                                "$($KeysToSend -join ', ')")

                            Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 500

                            # copy identical parameters between functions
                            $params = GenXdev\Copy-IdenticalParamValues `
                                -FunctionName 'GenXdev\Send-Key' `
                                -BoundParameters $myPSBoundParameters `
                                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                                    -Scope Local -ErrorAction SilentlyContinue)

                            # set the window handle for the send-key function
                            $params.WindowHandle = $window.Handle
                            $params.KeysToSend = $KeysToSend
                            $null = $params.Remove('Process')
                            $null = $params.Remove('ProcessName')

                            # send keys to the window
                            Microsoft.PowerShell.Utility\Write-Verbose ("Calling Send-Key " +
                                "with window handle $($window.Handle) and parameters: " +
                                "$($params | Microsoft.PowerShell.Utility\Out-String)")

                            $null = GenXdev\Send-Key @params -SendKeyHoldKeyboardFocus
                            Microsoft.PowerShell.Utility\Write-Verbose ('Keystroke sending ' + 'operation completed')
                        }
                    }
                } else {

                    Microsoft.PowerShell.Utility\Write-Verbose ('No window object ' +
                        'available to position.')
                }

                # return window helper if passthru specified
                if ($PassThru -eq $true) {

                    Microsoft.PowerShell.Utility\Write-Verbose ('PassThru specified, returning window object.')
                    $window
                }
            } else {
                Microsoft.PowerShell.Utility\Write-Verbose ('ShouldProcess returned false, skipping window positioning.')
            }
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose ('No process object available, skipping window positioning.')
        }
    }

    end {

        # only proceed if restore focus was requested
        if ($RestoreFocus) {

            $powerShellWindow = GenXdev\Get-PowershellMainWindow
            if (-not $powerShellWindow) {
                Microsoft.PowerShell.Utility\Write-Verbose 'Failed to retrieve PowerShell main window for focus restoration.'
                return
            }
            Microsoft.PowerShell.Utility\Write-Verbose ('RestoreFocus requested ' + 'and target window differs from PowerShell window')
            Microsoft.PowerShell.Utility\Write-Verbose ("Target window handle: " +
                "$($process.MainWindowHandle)), PowerShell handle: " +
                "$($powerShellWindow.handle)")

            Microsoft.PowerShell.Utility\Write-Verbose ('Restoring focus to ' + 'PowerShell window using Set-WindowPosition with ' +
                '-SetForeground')

            $null = $powerShellWindow.SetForeground();

            Microsoft.PowerShell.Utility\Write-Verbose ('PowerShell window ' + 'focus restoration completed')
        }
    }
}
################################################################################