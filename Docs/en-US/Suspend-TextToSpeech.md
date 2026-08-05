# Suspend-TextToSpeech

> **SubModule:** GenXdev.Console | **Type:** Function | **Aliases:** `pausespeech`

## Synopsis

> Pauses any ongoing text-to-speech output across all synthesizer instances.

## Description

Pauses audio playback on whichever GenXdev speech synthesizer is currently
producing sound — queued speech (Start-TextToSpeech), force-interrupted
speech (Start-TextToSpeech -Force), or the default instance.  While paused,
new Start-TextToSpeech calls (without -Force) will still queue normally but
won't start playing.  Start-TextToSpeech -Force will speak immediately but
will NOT auto-resume the paused speech afterward.  Use Resume-TextToSpeech
to continue playback.


## Syntax

```powershell
Suspend-TextToSpeech [<CommonParameters>]
```

## Examples

### PS C:\> say "This is a long story about PowerShell and GenXdev and all the amazing things you can do with it" ; Suspend-TextToSpeech Starts speaking and immediately pauses it.

```powershell
PS C:\> say "This is a long story about PowerShell and GenXdev and all
the amazing things you can do with it" ; Suspend-TextToSpeech
Starts speaking and immediately pauses it.
```

### PS C:\> Suspend-TextToSpeech; say "Urgent!" -Force; Resume-TextToSpeech Pauses ongoing speech, interrupts with urgent message, then resumes.

```powershell
PS C:\> Suspend-TextToSpeech; say "Urgent!" -Force; Resume-TextToSpeech
Pauses ongoing speech, interrupts with urgent message, then resumes.
```

## Related Links

- [Get-IsSpeaking](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-IsSpeaking.md)
- [New-MicrosoftShellTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-MicrosoftShellTab.md)
- [Now](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Now.md)
- [Resume-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-TextToSpeech.md)
- [SayDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayDate.md)
- [SayTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayTime.md)
- [secondscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/secondscreen.md)
- [sidebyside](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/sidebyside.md)
- [Start-SnakeGame](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-SnakeGame.md)
- [Start-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-TextToSpeech.md)
- [Stop-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-TextToSpeech.md)
- [UtcNow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/UtcNow.md)
