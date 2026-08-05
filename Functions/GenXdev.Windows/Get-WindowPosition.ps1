<#
.SYNOPSIS
Gets the position and state information of windows.

.DESCRIPTION
Retrieves detailed information about window positioning, size, monitor placement,
docking state, and focus status for specified processes or window handles.

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
The process name of the window to get position information for

.PARAMETER Process
Process or processes whose windows need position information

.PARAMETER WindowHelper
Window helper object for direct window manipulation

.EXAMPLE
Get-WindowPosition -ProcessName notepad
Gets position information for all notepad windows

.EXAMPLE
Get-Process notepad | Get-WindowPosition
Gets position information for notepad processes via pipeline

.EXAMPLE
Get-Window -ProcessName notepad | Get-WindowPosition
Gets position information using window helper objects
#>
################################################################################
function Get-WindowPosition {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    [Alias('gwp')]
    param(
        ########################################################################
        [parameter(
            ParameterSetName = 'ProcessName',
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'The process name of the window to get position for',
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
            HelpMessage = 'The process of the window to get position for',
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
        [GenXdev.Helpers.WindowObj[]] $WindowHelper
        ########################################################################
    )

    begin {

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

        # resolve target process based on the parameter set specified by the user
        switch ($PSCmdlet.ParameterSetName) {
            'ProcessName' {
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
                    Microsoft.PowerShell.Utility\Write-Verbose ("No process found with name '$ProcessName'")
                    Microsoft.PowerShell.Utility\Write-Error ('No process found with ' + "name '$ProcessName'")
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Verbose ("Process found: $($foundProcess.ProcessName) with ID $($foundProcess.Id)")
                    $Process = $foundProcess
                    Microsoft.PowerShell.Utility\Write-Verbose ('Found process: ' + "$($Process.ProcessName) with ID $($Process.Id)")
                }
                break;
            }
            'Process' {
                Microsoft.PowerShell.Utility\Write-Verbose ('ParameterSetName: Process')
                break;
            }
            'WindowHelper' {
                Microsoft.PowerShell.Utility\Write-Verbose ('ParameterSetName: WindowHelper')
                break;
            }
            default {
                Microsoft.PowerShell.Utility\Write-Verbose ('ParameterSetName: default (using PowerShell main window process)')
                # default to powershell main window process
                $Process = (GenXdev\Get-PowershellMainWindowProcess)
                break;
            }
        }
    }

    process {

        # begin processing windows that require position information
        if ($null -ne $Process) {

            # log which type of processing is being performed
            Microsoft.PowerShell.Utility\Write-Verbose ("Processing window for process: $($Process.ProcessName) (Id: $($Process.Id))")

            # get window object using either provided helper or process main window
            $window = $WindowHelper ? $WindowHelper : (GenXdev\Get-Window -ProcessId ($Process.Id))

            # validate window object detection and log detailed window information
            if ($null -ne $window) {

                # log comprehensive window details for debugging and troubleshooting
                Microsoft.PowerShell.Utility\Write-Verbose ("`r`n-----------`r`nWindow object found:`r`n" +
                    "Title: $($window.Title)`r`n" +
                    "Handle: $($window.Handle)`r`n" +
                    "Position: $($window.Position().X),$($window.Position().Y)`r`n" +
                    "Size: $($window.Size().Width)x$($window.Size().Height)`r`n-----------")

                # get window position and size
                $position = $window.Position()
                $size = $window.Size()

                # get monitor information
                $monitorIndex = $window.GetCurrentMonitor()
                $monitor = $monitorIndex + 1  # 1-based

                # get current screen
                $currentScreen = $allScreens[$monitorIndex]
                if ($null -eq $currentScreen) {
                    $currentScreen = $allScreens[0]  # fallback to primary
                }

                # detect docking state
                $dockedLeft = $false
                $dockedTop = $false
                $dockedRight = $false
                $dockedBottom = $false
                $dockedLeftTop = $false
                $dockedTopRight = $false
                $dockedBottomLeft = $false
                $dockedBottomRight = $false

                # calculate relative position within monitor's work area
                $workArea = $currentScreen.WorkingArea
                $relativeX = ($position.X - $workArea.X) / $workArea.Width
                $relativeY = ($position.Y - $workArea.Y) / $workArea.Height
                $relativeWidth = $size.Width / $workArea.Width
                $relativeHeight = $size.Height / $workArea.Height

                $tolerance = 0.1  # 10% tolerance for position detection
                $sizeTolerance = 0.4  # 40% minimum size to consider positioned

                # detect docking based on relative position and size
                if ($relativeWidth -ge $sizeTolerance) {
                    if ($relativeX -le $tolerance) {
                        $dockedLeft = $true
                    } elseif (($relativeX + $relativeWidth) -ge (1.0 - $tolerance)) {
                        $dockedRight = $true
                    }
                }
                if ($relativeHeight -ge $sizeTolerance) {
                    if ($relativeY -le $tolerance) {
                        $dockedTop = $true
                    } elseif (($relativeY + $relativeHeight) -ge (1.0 - $tolerance)) {
                        $dockedBottom = $true
                    }
                }

                # detect corner docking
                if ($dockedLeft -and $dockedTop) {
                    $dockedLeftTop = $true
                }
                if ($dockedTop -and $dockedRight) {
                    $dockedTopRight = $true
                }
                if ($dockedBottom -and $dockedLeft) {
                    $dockedBottomLeft = $true
                }
                if ($dockedBottom -and $dockedRight) {
                    $dockedBottomRight = $true
                }

                # get window state
                $isMinimized = $window.IsMinimized()
                $isMaximized = $window.IsMaximized()
                $isHidden = -not $window.IsVisible()
                $isRestored = -not $isMinimized -and -not $isMaximized

                # get focus information
                $foregroundWindow = [GenXdev.Helpers.WindowObj]::GetFocusedWindow()
                $hasFocus = $false
                $isInForeground = $false
                if ($null -ne $foregroundWindow) {
                    $hasFocus = ($window.Handle -eq $foregroundWindow.Handle)
                    $isInForeground = $hasFocus
                }

                # create result hashtable
                $result = @{
                    Left             = $position.X
                    Top              = $position.Y
                    Width            = $size.Width
                    Height           = $size.Height
                    MonitorIndex     = $monitorIndex
                    Monitor          = $monitor
                    DockedLeft       = $dockedLeft
                    DockedTop        = $dockedTop
                    DockedBottom     = $dockedBottom
                    DockedRight      = $dockedRight
                    DockedLeftTop    = $dockedLeftTop
                    DockedTopRight   = $dockedTopRight
                    DockedBottomLeft = $dockedBottomLeft
                    DockedBottomRight= $dockedBottomRight
                    IsMinimized      = $isMinimized
                    IsMaximized      = $isMaximized
                    IsHidden         = $isHidden
                    IsRestored       = $isRestored
                    WindowHandle     = $window.Handle
                    Process          = $Process
                    HasFocus         = $hasFocus
                    IsInForeground   = $isInForeground
                }

                # return the result
                $result

            } else {
                Microsoft.PowerShell.Utility\Write-Verbose ("No window object available for process $($Process.ProcessName)")
            }
        } else {
            Microsoft.PowerShell.Utility\Write-Verbose ('No process object available')
        }
    }

    end {
    }
}
################################################################################