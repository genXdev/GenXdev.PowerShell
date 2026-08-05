# Stop-TextToSpeech

> **SubModule:** GenXdev.Console | **Type:** Function | **Aliases:** `sst`

## Synopsis

> Immediately stops any ongoing text-to-speech output.

## Description

Halts all active and queued speech synthesis by canceling both standard and
customized speech operations. This provides an immediate silence for any ongoing
text-to-speech activities.


## Syntax

```powershell
Stop-TextToSpeech [<CommonParameters>]
```

## Examples

### PS C:\> Stop-TextToSpeech Immediately stops any ongoing speech

```powershell
PS C:\> Stop-TextToSpeech
Immediately stops any ongoing speech
```

### PS C:\> say "Hello world"; sst Starts speaking but gets interrupted immediately

```powershell
PS C:\> say "Hello world"; sst
Starts speaking but gets interrupted immediately
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
- [Suspend-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Suspend-TextToSpeech.md)
- [UtcNow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/UtcNow.md)
