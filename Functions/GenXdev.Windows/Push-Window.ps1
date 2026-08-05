###############################################################################
<#
.SYNOPSIS
Pushes the current window onto the window stack with optional modifications.

.DESCRIPTION
Pushes a window helper for the currently focused window onto the stack.
Allows applying various window transformations before or after pushing.
This function captures the current window and stores it for later retrieval
with Pop-Window, while optionally applying positioning, sizing, and visual
effects.

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

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER Minimize
Minimizes the window before pushing it onto the stack.

.PARAMETER Restore
Restores the window to its normal state before pushing it onto the stack.

.PARAMETER Hide
Hides the window before pushing it onto the stack.

.PARAMETER Show
Ensures the window is visible before pushing it onto the stack.

.PARAMETER NoBorders
Removes the window borders before pushing it onto the stack.

.PARAMETER AlwaysOnTop
Sets the window to always be on top before pushing it onto the stack.

.PARAMETER Opacity
Sets the window opacity (0-255) before pushing it onto the stack.

.PARAMETER X
Sets the window X position before pushing it onto the stack.

.PARAMETER Y
Sets the window Y position before pushing it onto the stack.

.PARAMETER Width
Sets the window width before pushing it onto the stack.

.PARAMETER Height
Sets the window height before pushing it onto the stack.

.PARAMETER Focus
Focuses the window before pushing it onto the stack.

.PARAMETER FadeOut
Applies a fade-out effect before pushing the window onto the stack.

.PARAMETER PassThru
Returns the window object after pushing it onto the stack.

.PARAMETER Left
Places window on left half of screen before pushing it onto the stack.

.PARAMETER Right
Places window on right half of screen before pushing it onto the stack.

.PARAMETER Top
Places window on top half of screen before pushing it onto the stack.

.PARAMETER Bottom
Places window on bottom half of screen before pushing it onto the stack.

.PARAMETER Centered
Centers window on screen before pushing it onto the stack.

.PARAMETER Fullscreen
Fills window to entire screen before pushing it onto the stack.

.PARAMETER Monitor
Specifies the monitor to move the window to before pushing onto the stack:
  0 = Primary monitor (default)
  1..n = Specific monitor (1-based index)
  -2 = Secondary monitor (uses $Global:DefaultSecondaryMonitor if defined)

.EXAMPLE
Push-Window -Maximize -AlwaysOnTop
Maximizes the current window, sets it to be always on top, and pushes it onto the stack.

.EXAMPLE
Push-Window -X 100 -Y 100 -Width 800 -Height 600 -NoBorders
Positions and resizes the current window, removes its borders, and pushes it onto the stack.

.EXAMPLE
pushw -Left
Positions the current window on the left half of the screen and pushes it
onto the stack using the alias.

.EXAMPLE
Push-Window -Monitor 1 -Maximize
Moves the current window to the first monitor, maximizes it, and pushes it onto the stack.

.EXAMPLE
Push-Window -Monitor -2 -Fullscreen
Moves the current window to the secondary monitor, makes it fullscreen,
and pushes it onto the stack.
###############################################################################>
function Push-Window {

    ############################################################################
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('pushw')]
    param (
        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Maximize,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Minimize,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Restore,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Hide,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Show,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [Alias('nb')]
        [switch] $NoBorders,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $AlwaysOnTop,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [ValidateRange(0, 255)]
        [byte] $Opacity,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Position',
            Mandatory = $true
        )]
        [int] $X = -999999,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Position',
            Mandatory = $true
        )]
        [int] $Y = -999999,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Dimensions',
            Mandatory = $true
        )]
        [int] $Width = -1,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Dimensions',
            Mandatory = $true
        )]
        [int] $Height = -1,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Focus,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $FadeOut,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [Alias('pt')]
        [switch]$PassThru,


        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Left,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Right,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Top,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Bottom,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [switch] $Centered,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [Alias('sw')]
        [switch]$ShowWindow
        ,

        ########################################################################
        [Parameter(
            ParameterSetName = 'Default'
        )]
        [Parameter(
            ParameterSetName = 'Position'
        )]
        [Parameter(
            ParameterSetName = 'Dimensions'
        )]
        [ValidateNotNull()]
        [Alias('m', 'mon')]
        [int] $Monitor
    )

    ############################################################################
    begin {
        # initialize the global window stack if it doesn't exist yet
        if (-not $Global:GenXdevWindowStack) {
            $Global:GenXdevWindowStack = [System.Collections.Concurrent.ConcurrentQueue[GenXdev.Helpers.WindowObj]]::new()
            Microsoft.PowerShell.Utility\Write-Verbose 'Initialized new window stack'
        }
    }

    ############################################################################
    process {
        # get the process id of the currently focused window
        $processId = GenXdev\Get-CurrentFocusedProcess

        # extract the process id if we got a Process object
        if ($processId -is [System.Diagnostics.Process]) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Received Process object, extracting process ID'
            $processId = $processId.Id
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Current focused process ID: $processId"

        # get a window helper for the currently focused window
        $window = GenXdev\Get-Window -ProcessId $processId

        # validate that we got a valid window
        if (-not $window) {
            Microsoft.PowerShell.Utility\Write-Error "Failed to get a valid window for process ID: $processId"
            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Retrieved window handle: $($window.Handle)"

        [int] $setDefaultMonitor = $Global:DefaultSecondaryMonitor -is [int] ?
        (
            $Global:DefaultSecondaryMonitor
        ):
        2;

        # move to specified monitor if requested
        if ($PSBoundParameters.ContainsKey('Monitor')) {
            # handle special case for secondary monitor (-2)
            if ($Monitor -eq -2 -and $setDefaultMonitor -is [int] -and
                $setDefaultMonitor -ge 0) {
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Using monitor from `$setDefaultMonitor: " +
                    "$setDefaultMonitor"
                )
                $targetMonitor = $setDefaultMonitor
            }
            else {
                $targetMonitor = $Monitor
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Moving window to monitor: $targetMonitor"
            $null = $window.MoveToMonitor($targetMonitor)
        }

        # focus the window if requested
        if ($Focus) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Setting window foreground focus'
            $null = $window.Focus()
        }

        # apply window state modifications
        if ($Maximize) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Maximizing window'
            $null = $window.Maximize()
        }
        elseif ($Minimize) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Minimizing window'
            $null = $window.Minimize()
        }
        elseif ($Restore) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Restoring window'
            $null = $window.Restore()
        }

        # apply positioning parameters
        # Check if both horizontal and vertical positioning are specified
        $horizontalPos = $Left -or $Right
        $verticalPos = $Top -or $Bottom
        $cornerPositioning = $horizontalPos -and $verticalPos

        if ($cornerPositioning) {
            # Handle corner positioning (quarter screen)
            Microsoft.PowerShell.Utility\Write-Verbose 'Positioning window to corner (quarter screen)'

            if ($Left) {
                if ($Top) {
                    Microsoft.PowerShell.Utility\Write-Verbose 'Positioning to top-left corner'
                    $null = $window.PositionTopLeft()
                }
                else {
                    # Bottom
                    Microsoft.PowerShell.Utility\Write-Verbose 'Positioning to bottom-left corner'
                    $null = $window.PositionBottomLeft()
                }
            }
            else {
                # Right
                if ($Top) {
                    Microsoft.PowerShell.Utility\Write-Verbose 'Positioning to top-right corner'
                    $null = $window.PositionTopRight()
                }
                else {
                    # Bottom
                    Microsoft.PowerShell.Utility\Write-Verbose 'Positioning to bottom-right corner'
                    $null = $window.PositionBottomRight()
                }
            }
        }
        # Original half-screen positioning logic
        elseif ($Left) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Positioning window to left half'
            $null = $window.PositionLeft()
        }
        elseif ($Right) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Positioning window to right half'
            $null = $window.PositionRight()
        }
        elseif ($Top) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Positioning window to top half'
            $null = $window.PositionTop()
        }
        elseif ($Bottom) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Positioning window to bottom half'
            $null = $window.PositionBottom()
        }
        elseif ($Centered) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Centering window on screen'
            $null = $window.PositionCentered()
        }
        elseif ($Fullscreen) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Making window fullscreen'
            $null = $window.PositionFullscreen()
        }

        # apply hide/show effects
        if ($Hide) {
            if ($FadeOut) {
                # apply fade-out effect for smooth disappearance
                Microsoft.PowerShell.Utility\Write-Verbose 'Fading out window'
                $window.FadeWindow($false)
            }
            else {
                # hide window immediately
                Microsoft.PowerShell.Utility\Write-Verbose 'Hiding window'
                $null = $window.Hide()
            }
        }
        elseif ($Show) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Showing window'
            $null = $window.Show()
        }

        # apply visual modifications
        if ($NoBorders) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Removing window borders'
            $window.RemoveBorder()
        }

        # set always-on-top property if requested
        if ($AlwaysOnTop) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Setting window to always on top'
            $window.SetAlwaysOnTop($true)
        }

        # set opacity if specified
        if ($PSBoundParameters.ContainsKey('Opacity')) {
            Microsoft.PowerShell.Utility\Write-Verbose "Setting window opacity to: $Opacity"
            $window.SetOpacity($Opacity)
        }

        # apply position changes if requested
        if ($PSBoundParameters.ContainsKey('X') -and $PSBoundParameters.ContainsKey('Y')) {
            Microsoft.PowerShell.Utility\Write-Verbose "Moving window to position X:$X Y:$Y"
            $null = $window.Move($X, $Y)
        }

        # apply size changes if requested
        if ($PSBoundParameters.ContainsKey('Width') -and
            $PSBoundParameters.ContainsKey('Height')) {
            Microsoft.PowerShell.Utility\Write-Verbose "Resizing window to Width:$Width Height:$Height"
            $null = $window.Resize($Width, $Height)
        }

        # add the window to the stack
        Microsoft.PowerShell.Utility\Write-Verbose 'Enqueueing window to global stack'
        $Global:GenXdevWindowStack.Enqueue($window)

        # return window if passthru is specified
        if ($PassThru) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Returning window object (PassThru)'
            return $window
        }
    }

    ############################################################################
    end {
    }
}