# Resume-TextToSpeech

> **SubModule:** GenXdev.Console | **Type:** Function | **Aliases:** `resumespeech`

## Synopsis

> Resumes text-to-speech output that was previously paused via
Suspend-TextToSpeech.

## Description

Resumes audio playback on whichever GenXdev speech synthesizer was paused
by Suspend-TextToSpeech.  Only the instance with an actual paused output
will wake up; the other instances are harmless no-ops.  Also clears the
internal "user paused" flag so that subsequent Start-TextToSpeech -Force
calls will auto-resume as normal.


## Syntax

```powershell
Resume-TextToSpeech [<CommonParameters>]
```

## Examples

### PS C:\> say "Long text" ; Suspend-TextToSpeech ; Resume-TextToSpeech Starts speaking, pauses it, then resumes.

```powershell
PS C:\> say "Long text" ; Suspend-TextToSpeech ; Resume-TextToSpeech
Starts speaking, pauses it, then resumes.
```

### PS C:\> Suspend-TextToSpeech; say "Urgent!" -Force; Resume-TextToSpeech Pauses ongoing speech, interrupts with urgent message, then resumes the original speech.

```powershell
PS C:\> Suspend-TextToSpeech; say "Urgent!" -Force; Resume-TextToSpeech
Pauses ongoing speech, interrupts with urgent message, then resumes the
original speech.
```

## Related Links

- [Get-IsSpeaking](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-IsSpeaking.md)
- [New-MicrosoftShellTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-MicrosoftShellTab.md)
- [Now](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Now.md)
- [SayDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayDate.md)
- [SayTime](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayTime.md)
- [secondscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/secondscreen.md)
- [sidebyside](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/sidebyside.md)
- [Start-SnakeGame](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-SnakeGame.md)
- [Start-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-TextToSpeech.md)
- [Stop-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-TextToSpeech.md)
- [Suspend-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Suspend-TextToSpeech.md)
- [UtcNow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/UtcNow.md)
