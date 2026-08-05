################################################################################
<#
.SYNOPSIS
Toggles the pause/play state of the VLC Media Player.

.DESCRIPTION
This function sends a space key to VLC Media Player to toggle between paused
and playing states. It automatically restores focus to the original window
after sending the key command.

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
Switch-VLCMediaPlayerPaused

Toggles the pause/play state of VLC Media Player.

.EXAMPLE
vlcpause

Uses the alias to toggle the pause/play state.

.EXAMPLE
vlcplay

Uses the alternate alias to toggle the pause/play state.
#>
function Switch-VLCMediaPlayerPaused {

    [CmdletBinding()]
    [Alias('vlcpause', 'vlcplay')]

    param (
    )

    begin {

    }

    process {

        # send space key to vlc media player to toggle pause/play state
        Microsoft.PowerShell.Utility\Write-Verbose "Toggling VLC Media Player pause/play state"

        # send the space key command and restore focus to original window
        GenXdev\Open-VlcMediaPlayer -KeysToSend ' ' -RestoreFocus
    }

    end {

    }
}
################################################################################