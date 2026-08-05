###############################################################################

<#
.SYNOPSIS
Pauses any ongoing text-to-speech output across all synthesizer instances.

.DESCRIPTION
Pauses audio playback on whichever GenXdev speech synthesizer is currently
producing sound — queued speech (Start-TextToSpeech), force-interrupted
speech (Start-TextToSpeech -Force), or the default instance.  While paused,
new Start-TextToSpeech calls (without -Force) will still queue normally but
won't start playing.  Start-TextToSpeech -Force will speak immediately but
will NOT auto-resume the paused speech afterward.  Use Resume-TextToSpeech
to continue playback.

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
PS C:\> say "This is a long story about PowerShell and GenXdev and all
the amazing things you can do with it" ; Suspend-TextToSpeech
Starts speaking and immediately pauses it.

.EXAMPLE
PS C:\> Suspend-TextToSpeech; say "Urgent!" -Force; Resume-TextToSpeech
Pauses ongoing speech, interrupts with urgent message, then resumes.

.NOTES
This cmdlet is commonly used in conjunction with Start-TextToSpeech (alias:
say), Resume-TextToSpeech, and Stop-TextToSpeech (alias: sst) for speech
control.
#>
function Suspend-TextToSpeech {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias("pausespeech")]
    param()

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Initiating speech pause request'
    }

    process {

        try {
            if ($PSCmdlet.ShouldProcess('Text-to-speech output', 'Pause')) {
                # Pause all three synthesizer instances — whichever
                # is actually playing will pause; the other two are
                # harmless no-ops.  Sets Misc.IsUserPaused = true so
                # that -Force won't auto-resume.
                [GenXdev.Helpers.Misc]::PauseAllSpeech()

                Microsoft.PowerShell.Utility\Write-Verbose 'Successfully paused all speech output'
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose 'Error occurred while attempting to pause speech'
        }
    }

    end {
    }
}