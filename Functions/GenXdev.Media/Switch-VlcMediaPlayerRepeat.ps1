################################################################################
<#
.SYNOPSIS
Toggles the repeat mode in VLC Media Player.

.DESCRIPTION
This function sends the 'r' key command to VLC Media Player to toggle between
different repeat modes (no repeat, repeat current, repeat all). The function
opens VLC if it's not already running and restores focus to the previous
window after sending the command.

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
Switch-VlcMediaPlayerRepeat

.EXAMPLE
vlcrepeat
#>
function Switch-VlcMediaPlayerRepeat {

    [CmdletBinding()]
    [Alias('vlcrepeat')]

    param(
    )

    begin {

    }

    process {

        # send the repeat toggle key ('r') to vlc media player
        GenXdev\Open-VlcMediaPlayer -KeysToSend 'r' -RestoreFocus
    }

    end {

    }
}
################################################################################