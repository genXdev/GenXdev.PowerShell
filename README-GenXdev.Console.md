# GenXdev.Console

## Overview

GenXdev.Console provides terminal enhancement utilities — text-to-speech
with pause/resume, date/time announcements, a built-in Snake game, Windows
Terminal tab management, and quick-access commands for monitor positioning.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Start-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-TextToSpeech.md) | `say` | Convert text to speech using Microsoft Edge's neural TTS engine |
| [Stop-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-TextToSpeech.md) | `sst` | Immediately stop all text-to-speech output |
| [Suspend-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Suspend-TextToSpeech.md) | `pausespeech` | Pause ongoing speech, resumable later |
| [Resume-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-TextToSpeech.md) | `resumespeech` | Resume paused speech where it left off |
| [SayDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayDate.md) | — | Speak the current date aloud |
| [SayTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayTime.md) | — | Announce the current time |
| [Start-SnakeGame](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-SnakeGame.md) | `snake` | Play Snake in the terminal |
| [New-MicrosoftShellTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-MicrosoftShellTab.md) | `x` | Open a new Windows Terminal PowerShell tab |
| [Now](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Now.md) | — | Get current system date and time |
| [UtcNow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/UtcNow.md) | — | Get current UTC date and time |
| [secondscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/secondscreen.md) | — | Configure default secondary monitor for browser or mediaplayer placement |
| [sidebyside](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/sidebyside.md) | — | Configure side-by-side window defaults |

## How It All Comes Together

`Start-TextToSpeech` (`say`) reads text aloud using Windows' neural voices.
`Suspend-TextToSpeech` (`pausespeech`) and `Resume-TextToSpeech`
(`resumespeech`) control playback. `Stop-TextToSpeech` (`sst`) stops all
ongoing speech.

`SayDate` and `SayTime` speak the current date or time. `Now` and `UtcNow`
return the current system time.

`Start-SnakeGame` (`snake`) starts a terminal-based Snake game.
`New-MicrosoftShellTab` (`x`) opens a new Windows Terminal PowerShell tab.

`secondscreen` and `sidebyside` configure default monitor settings for
browser and media player placement.

## See Also

- [GenXdev.Webbrowser](README-GenXdev.Webbrowser.md) — Browser window management
- [GenXdev.Windows](README-GenXdev.Windows.md) — Window positioning
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevconsole)
