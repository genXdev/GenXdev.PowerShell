###############################################################################
<#
.SYNOPSIS
Configures Windows 11+ taskbar alignment between center and left positions.

.DESCRIPTION
Sets the taskbar alignment in Windows 11 and newer versions by modifying the
registry key 'TaskbarAl' under HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\
Explorer\Advanced. The alignment can be set to either center (value 1) or left
(value 0).

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

.PARAMETER Justify
Specifies the desired taskbar alignment: 'Center' or 'Left'. This setting is
converted to the appropriate registry value (1 for Center, 0 for Left).

.EXAMPLE
Set-TaskbarAlignment -Justify Left
Sets the Windows 11 taskbar to left alignment

.EXAMPLE
Set-TaskAlign Center -WhatIf
Shows what would happen if taskbar was set to center alignment
#>
function Set-TaskbarAlignment {

    [CmdletBinding(SupportsShouldProcess = $true)]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The taskbar alignment (Center or Left)'
        )]
        [ValidateSet('Center', 'Left')]
        [string] $Justify
        ########################################################################
    )

    begin {

        # store the registry path for taskbar settings
        $regPath = 'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\Advanced'

        # log the requested alignment change for troubleshooting
        Microsoft.PowerShell.Utility\Write-Verbose "Setting taskbar alignment to: $Justify"
    }


    process {

        # convert the alignment choice to its corresponding registry value
        $value = if ($Justify -eq 'Left') { 0 } else { 1 }

        # check if we should proceed with the registry modification
        if ($PSCmdlet.ShouldProcess(
                'Windows Taskbar Alignment',
                "Set alignment to $Justify"
            )) {

            # update the registry key
            $null = Microsoft.PowerShell.Management\Set-ItemProperty -Path $regPath `
                -Name 'TaskbarAl' `
                -Value $value

            Microsoft.PowerShell.Utility\Write-Verbose "Registry value 'TaskbarAl' set to: $value"
        }
    }

    end {
    }
}