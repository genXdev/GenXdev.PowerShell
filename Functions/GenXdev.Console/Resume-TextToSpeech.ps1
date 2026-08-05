###############################################################################

<#
.SYNOPSIS
Resumes text-to-speech output that was previously paused via
Suspend-TextToSpeech.

.DESCRIPTION
Resumes audio playback on whichever GenXdev speech synthesizer was paused
by Suspend-TextToSpeech.  Only the instance with an actual paused output
will wake up; the other instances are harmless no-ops.  Also clears the
internal "user paused" flag so that subsequent Start-TextToSpeech -Force
calls will auto-resume as normal.

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
PS C:\> say "Long text" ; Suspend-TextToSpeech ; Resume-TextToSpeech
Starts speaking, pauses it, then resumes.

.EXAMPLE
PS C:\> Suspend-TextToSpeech; say "Urgent!" -Force; Resume-TextToSpeech
Pauses ongoing speech, interrupts with urgent message, then resumes the
original speech.

.NOTES
This cmdlet is commonly used in conjunction with Start-TextToSpeech (alias:
say), Suspend-TextToSpeech, and Stop-TextToSpeech (alias: sst) for speech
control.
#>
function Resume-TextToSpeech {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias("resumespeech")]
    param()

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Initiating speech resume request'
    }

    process {

        try {
            if ($PSCmdlet.ShouldProcess('Text-to-speech output', 'Resume')) {
                # Resume whichever synthesizer was paused.  Clears
                # Misc.IsUserPaused so that -Force auto-resume
                # behavior is restored.
                [GenXdev.Helpers.Misc]::ResumeAllSpeech()

                Microsoft.PowerShell.Utility\Write-Verbose 'Successfully resumed speech output'
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Verbose 'Error occurred while attempting to resume speech'
        }
    }

    end {
    }
}