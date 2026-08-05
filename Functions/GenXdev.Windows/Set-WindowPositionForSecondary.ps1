<#
.SYNOPSIS
Positions a window on the secondary monitor with specified layout options.

.DESCRIPTION
This function allows positioning windows on a configured secondary monitor using
Set-WindowPosition with various layout options including alignment, size, and
border settings. It handles monitor selection based on global configuration and
provides a convenient wrapper for secondary monitor window positioning.

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

.PARAMETER Process
The process or processes containing the windows to position.

.PARAMETER Monitor
The monitor to use (0=default, 1=secondary, -1=discard, -2=configured secondary).

.PARAMETER Width
The desired width of the window in pixels.

.PARAMETER Height
The desired height of the window in pixels.

.PARAMETER X
The desired X coordinate for window placement.

.PARAMETER Y
The desired Y coordinate for window placement.

.PARAMETER Left
Place the window on the left side of the screen.

.PARAMETER Right
Place the window on the right side of the screen.

.PARAMETER Top
Place the window at the top of the screen.

.PARAMETER Bottom
Place the window at the bottom of the screen.

.PARAMETER Centered
Center the window on the screen.

.PARAMETER Fullscreen
Maximize the window to fill the screen.

.PARAMETER NoBorders
Remove window borders and title bar.

.PARAMETER RestoreFocus
Return focus to the PowerShell window after positioning.

.PARAMETER FocusWindow
Focus the window after positioning.

.PARAMETER SetForeground
Set the window to foreground after positioning.

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER KeysToSend
Keystrokes to send to the window after positioning.

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on target window when sending keys

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending keys

.PARAMETER PassThru
Return the Process object after positioning.

.PARAMETER SideBySide
Place window side by side with PowerShell on the same monitor.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session.

.EXAMPLE
Set-WindowPositionForSecondary -Process "notepad" -Width 800 -Height 600 `
    -Centered -NoBorders

.EXAMPLE
wps notepad -w 800 -h 600 -c -nb
#>
function Set-WindowPositionForSecondary {
    ################################################################################
    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias('wps')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    param(
        #
        [parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'The process of the window to position',
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            ValueFromRemainingArguments = $false
        )]
        [System.Diagnostics.Process[]] $Process,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0=default, -1=discard, -2=configured'
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -2,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width = -1,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height = -1,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X = -999999,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y = -999999,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the top side of the screen'
        )]
        [switch] $Top,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch] $Centered,
        #
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sends F11 to the window'
        )]
        [Alias('fs')]
        [switch]$FullScreen,

        #
        [Alias('nb')]
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [switch] $NoBorders,
        #

        [parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after positioning'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after positioning'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        #
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
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Keystrokes to send to the window after positioning'
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
            HelpMessage = 'Delay between different input strings in milliseconds when sending keys'
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = 'Returns the process object after positioning'
        )]
        [Alias('pt')]
        [switch]$PassThru,

        #
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Place window side by side with PowerShell on the same ' +
                'monitor')
        )]
        [Alias('sbs')]
        [switch]$SideBySide,

        #
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        #
        [parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        #
    )

    begin {

        # initialize window positioning for secondary monitor
        Microsoft.PowerShell.Utility\Write-Verbose (
            'Initializing window positioning for secondary monitor'
        )

        # determine monitor index if configured secondary monitor requested
        if ($Monitor -lt -1) {

            # get array of all available screens
            $allScreens = @([WpfScreenHelper.Screen]::AllScreens)

            # initialize default secondary monitor index
            [int] $defaultMonitor = 1

            # try to use globally configured secondary monitor if available
            if ([int]::TryParse($Global:DefaultSecondaryMonitor,
                    [ref] $defaultMonitor)) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Using configured secondary monitor: $defaultMonitor"
                )

                # calculate monitor index with proper wrap-around handling
                $Monitor = $defaultMonitor % $allScreens.Length
            }
            else {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Using default secondary monitor: 1'
                )

                # use default secondary monitor with wrap-around handling
                $Monitor = 1 % $allScreens.Length
            }

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Selected monitor index: $Monitor"
            )
        }

        # ensure monitor parameter is included in bound parameters
        if (-not $PSBoundParameters.ContainsKey('Monitor')) {

            # add monitor parameter to bound parameters for forwarding
            $null = $PSBoundParameters.Add('Monitor', $Monitor)
        }
        else {

            # update monitor parameter in bound parameters
            $PSBoundParameters['Monitor'] = $Monitor
        }
    }

    process {

        # copy matching parameters to pass to Set-WindowPosition
        $invocationArguments = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Set-WindowPosition' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local -Name * -ErrorAction SilentlyContinue)

        # determine target for WhatIf processing
        $target = if ($Process) {
            "Process: $($Process.Name)"
        } else {
            'Window'
        }

        # define action description for WhatIf processing
        $action = "Position on monitor $Monitor"

        # perform shouldprocess check before proceeding
        if ($PSCmdlet.ShouldProcess($target, $action)) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Forwarding parameters to Set-WindowPosition'
            )

            # forward all parameters to Set-WindowPosition function
            GenXdev\Set-WindowPosition @invocationArguments
        }
    }

    end {
    }
}
################################################################################