###############################################################################
<#
.SYNOPSIS
Announces the current time using text-to-speech.

.DESCRIPTION
This function gets the current time and uses the system's text-to-speech engine
to verbally announce it in hours and minutes format. It's useful for
accessibility purposes or when you need an audible time announcement.

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
SayTime
Speaks the current time, e.g. "The time is 14 hours and 30 minutes"
#>
function SayTime {

    [CmdletBinding()]
    param(
        [switch] $Wait
    )

    begin {

        # get the current system time
        $date = Microsoft.PowerShell.Utility\Get-Date

        # extract hours (0-23) and minutes (0-59) from current time
        $hours = $date.Hour
        $minutes = $date.Minute

        # log the current time for troubleshooting
        Microsoft.PowerShell.Utility\Write-Verbose "Processing time announcement for $hours`:$minutes"
    }


    process {

        # construct the speech text in a clear, consistent format
        $speechText = "The time is $($hours.ToString('0')) hours and " +
        "$($minutes.ToString('0')) minutes"

        # log the text that will be spoken
        Microsoft.PowerShell.Utility\Write-Verbose "Speaking: $speechText"

        # convert the text to speech using system TTS engine
        GenXdev\Start-TextToSpeech $speechText -Wait:$Wait
    }

    end {
    }
}