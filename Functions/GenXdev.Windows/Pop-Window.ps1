###############################################################################
<#
.SYNOPSIS
Pops the last active window helper from the stack with optional modifications.

.DESCRIPTION
Pops a window helper from the stack and optionally applies window transformations.
If the stack is empty or contains invalid windows, returns the currently focused
window. This function allows you to manipulate windows that were previously saved
with Push-Window, applying various positioning, sizing, and visual effects.

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
Minimizes the window after popping it from the stack.

.PARAMETER Restore
Restores the window to its normal state after popping it from the stack.

.PARAMETER Hide
Hides the window after popping it from the stack.

.PARAMETER Show
Ensures the window is visible after popping it from the stack.

.PARAMETER NoBorders
Removes the window borders after popping it from the stack.

.PARAMETER AlwaysOnTop
Sets the window to always be on top after popping it from the stack.

.PARAMETER Opacity
Sets the window opacity (0-255) after popping it from the stack.

.PARAMETER X
Sets the window X position after popping it from the stack.

.PARAMETER Y
Sets the window Y position after popping it from the stack.

.PARAMETER Width
Sets the window width after popping it from the stack.

.PARAMETER Height
Sets the window height after popping it from the stack.

.PARAMETER Focus
Focuses the window after popping it from the stack.

.PARAMETER FadeIn
Applies a fade-in effect when showing the window after popping it from the stack.

.PARAMETER NoModify
Pops the window but doesn't apply any modifications (just returns it).

.PARAMETER Left
Places window on left half of screen after popping it from the stack.

.PARAMETER Right
Places window on right half of screen after popping it from the stack.

.PARAMETER Top
Places window on top half of screen after popping it from the stack.

.PARAMETER Bottom
Places window on bottom half of screen after popping it from the stack.

.PARAMETER Centered
Centers window on screen after popping it from the stack.

.PARAMETER Fullscreen
Fills window to entire screen after popping it from the stack.

.PARAMETER Monitor
Specifies the monitor to move the window to after popping from the stack:
  0 = Primary monitor (default)
  1..n = Specific monitor (1-based index)
  -2 = Secondary monitor (uses $Global:DefaultSecondaryMonitor if defined)

.EXAMPLE
Pop-Window -Maximize -Focus
Pops the last window from the stack, maximizes it and gives it focus.

.EXAMPLE
Pop-Window -X 100 -Y 100 -Width 800 -Height 600 -AlwaysOnTop
Pops the last window, positions it at coordinates (100,100),
resizes it to 800x600, and sets it to always stay on top.

.EXAMPLE
popw -Left -Focus
Pops the last window, positions it on the left half of the screen,
and gives it focus using the alias.

.EXAMPLE
Pop-Window -Monitor 1 -Maximize
Pops the last window, moves it to the first monitor, and maximizes it.

.EXAMPLE
Pop-Window -Monitor -2 -Fullscreen
Pops the last window, moves it to the secondary monitor, and makes it fullscreen.
###############################################################################>
function Pop-Window {

    ############################################################################
    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('popw')]
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
        [switch] $FadeIn,

        ########################################################################
        [Parameter(
            ParameterSetName = 'NoModify'
        )]
        [switch] $NoModify,

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
        # Check if the type already exists
        $typeName = 'Win32.Unique2165442User32'
        $typeExists = $null -ne [System.Type]::GetType($typeName)

        # define the iswindow function from user32.dll if it doesn't already exist
        if (-not $typeExists) {
            Microsoft.PowerShell.Utility\Add-Type -Namespace Win32 -Name Unique2165442User32 `
                -MemberDefinition @'
                [DllImport("user32.dll")]
                public static extern bool IsWindow(IntPtr hWnd);
'@ -Language CSharp
        }
    }

    ############################################################################
    process {
        # helper function to check if a window handle is still valid
        function IsWindowValid {
            param (
                [Parameter(Mandatory)]
                [IntPtr] $Handle
            )

            return [Win32.Unique2165442User32]::IsWindow($Handle)
        }

        # initialize the popped window variable to null
        [GenXdev.Helpers.WindowObj] $poppedWindow = $null

        # Check if window stack exists
        if (-not $Global:GenXdevWindowStack) {
            Microsoft.PowerShell.Utility\Write-Verbose "Window stack doesn't exist, initializing"
            $Global:GenXdevWindowStack = [System.Collections.Concurrent.ConcurrentQueue[GenXdev.Helpers.WindowObj]]::new()
        }

        # Log stack status
        Microsoft.PowerShell.Utility\Write-Verbose "Window stack empty: $($Global:GenXdevWindowStack.IsEmpty)"

        # try to get a valid window from the stack, discarding invalid handles
        while ($Global:GenXdevWindowStack -and -not $Global:GenXdevWindowStack.IsEmpty) {
            # attempt to dequeue a window from the stack
            $Global:GenXdevWindowStack.TryDequeue([ref]$poppedWindow) |
                Microsoft.PowerShell.Core\Out-Null

            # check if window is valid; if so, break the loop
            if ($poppedWindow -and $poppedWindow.Handle -and
                (IsWindowValid -Handle $poppedWindow.Handle)) {
                Microsoft.PowerShell.Utility\Write-Verbose "Found valid window in stack, Handle: $($poppedWindow.Handle), Title: $($poppedWindow.Title)"
                break
            }

            # reset to null if window was invalid
            Microsoft.PowerShell.Utility\Write-Verbose 'Discarded invalid window from stack'
            $poppedWindow = $null
        }

        # if no valid window found, push current window and use that instead
        if (-not $poppedWindow) {
            Microsoft.PowerShell.Utility\Write-Verbose 'No valid window in stack, getting current window'
            try {
                # Get the current foreground window directly
                $foregroundHandle = GenXdev\Get-CurrentFocusedWindow
                if ($foregroundHandle -ne 0) {
                    Microsoft.PowerShell.Utility\Write-Verbose "Got foreground window handle: $foregroundHandle"
                    $poppedWindow = [GenXdev.Helpers.WindowObj]::GetMainWindow($foregroundHandle)
                    Microsoft.PowerShell.Utility\Write-Verbose "Created window object, Title: $($poppedWindow.Title)"
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Verbose 'Failed to get foreground window, falling back to Push-Window'
                    $null = GenXdev\Push-Window
                    $Global:GenXdevWindowStack.TryDequeue([ref]$poppedWindow) |
                        Microsoft.PowerShell.Core\Out-Null
                }
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Verbose "Error getting current window: $_"
                Microsoft.PowerShell.Utility\Write-Verbose 'Falling back to Push-Window'
                $null = GenXdev\Push-Window
                $Global:GenXdevWindowStack.TryDequeue([ref]$poppedWindow) |
                    Microsoft.PowerShell.Core\Out-Null
            }
        }

        # Validate we have a window to work with
        if (-not $poppedWindow -or -not $poppedWindow.Handle -or -not (IsWindowValid -Handle $poppedWindow.Handle)) {
            Microsoft.PowerShell.Utility\Write-Error 'Failed to get a valid window to manipulate'
            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Working with window: $($poppedWindow.Title), Handle: $($poppedWindow.Handle)"

        # skip modifications if nomodify is specified
        if ($NoModify) {
            return $poppedWindow
        }

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
            $null = $poppedWindow.MoveToMonitor($targetMonitor)
        }

        # apply show/fade effects if requested
        if ($Show) {
            if ($FadeIn) {
                # apply fade-in effect for smooth appearance
                $poppedWindow.FadeWindow($true)
            }
            else {
                # show window immediately
                $null = $poppedWindow.Show()
            }
        }

        # apply window state modifications
        if ($Maximize) {
            $null = $poppedWindow.Maximize()
        }
        elseif ($Minimize) {
            $null = $poppedWindow.Minimize()
        }
        elseif ($Restore) {
            $null = $poppedWindow.Restore()
        }

        # apply positioning parameters - with enhanced logging
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
                    $result = $poppedWindow.PositionTopLeft()
                    Microsoft.PowerShell.Utility\Write-Verbose "PositionTopLeft result: $result"
                }
                else {
                    # Bottom
                    Microsoft.PowerShell.Utility\Write-Verbose 'Positioning to bottom-left corner'
                    $result = $poppedWindow.PositionBottomLeft()
                    Microsoft.PowerShell.Utility\Write-Verbose "PositionBottomLeft result: $result"
                }
            }
            else {
                # Right
                if ($Top) {
                    Microsoft.PowerShell.Utility\Write-Verbose 'Positioning to top-right corner'
                    $result = $poppedWindow.PositionTopRight()
                    Microsoft.PowerShell.Utility\Write-Verbose "PositionTopRight result: $result"
                }
                else {
                    # Bottom
                    Microsoft.PowerShell.Utility\Write-Verbose 'Positioning to bottom-right corner'
                    $result = $poppedWindow.PositionBottomRight()
                    Microsoft.PowerShell.Utility\Write-Verbose "PositionBottomRight result: $result"
                }
            }
        }
        # Original half-screen positioning logic
        elseif ($Left) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Positioning window to left half of screen'
            $result = $poppedWindow.PositionLeft()
            Microsoft.PowerShell.Utility\Write-Verbose "PositionLeft result: $result"
        }
        elseif ($Right) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Positioning window to right half of screen'
            $result = $poppedWindow.PositionRight()
            Microsoft.PowerShell.Utility\Write-Verbose "PositionRight result: $result"
        }
        elseif ($Top) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Positioning window to top half of screen'
            $result = $poppedWindow.PositionTop()
            Microsoft.PowerShell.Utility\Write-Verbose "PositionTop result: $result"
        }
        elseif ($Bottom) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Positioning window to bottom half of screen'
            $result = $poppedWindow.PositionBottom()
            Microsoft.PowerShell.Utility\Write-Verbose "PositionBottom result: $result"
        }
        elseif ($Centered) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Centering window on screen'
            $result = $poppedWindow.PositionCentered()
            Microsoft.PowerShell.Utility\Write-Verbose "PositionCentered result: $result"
        }
        elseif ($Fullscreen) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Making window fullscreen'
            $result = $poppedWindow.PositionFullscreen()
            Microsoft.PowerShell.Utility\Write-Verbose "PositionFullscreen result: $result"
        }

        # hide window if requested
        if ($Hide) {
            $null = $poppedWindow.Hide()
        }

        # apply visual modifications
        if ($NoBorders) {
            $poppedWindow.RemoveBorder()
        }

        # set always-on-top property if requested
        if ($AlwaysOnTop) {
            $poppedWindow.SetAlwaysOnTop($true)
        }

        # set opacity if specified
        if ($PSBoundParameters.ContainsKey('Opacity')) {
            $poppedWindow.SetOpacity($Opacity)
        }

        # apply position changes if requested
        if ($PSBoundParameters.ContainsKey('X') -and $PSBoundParameters.ContainsKey('Y')) {
            $null = $poppedWindow.Move($X, $Y)
        }

        # apply size changes if requested
        if ($PSBoundParameters.ContainsKey('Width') -and $PSBoundParameters.ContainsKey('Height')) {
            $null = $poppedWindow.Resize($Width, $Height)
        }

        # focus the window if requested (done last for proper visibility)
        if ($Focus) {
            $null = $poppedWindow.Focus()
        }

        # return the window object for potential further manipulationanipulation
        return $poppedWindow
    }

    ################################################################################################################################
    end {
    }
}