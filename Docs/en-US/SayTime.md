# SayTime

> **SubModule:** GenXdev.Console | **Type:** Function | **Aliases:** —

## Synopsis

> Announces the current time using text-to-speech.

## Description

This function gets the current time and uses the system's text-to-speech engine
to verbally announce it in hours and minutes format. It's useful for
accessibility purposes or when you need an audible time announcement.


## Syntax

```powershell
SayTime [-Wait] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Wait` | SwitchParameter | ☐ | The `-Wait` parameter. |

## Examples

### SayTime Speaks the current time, e.g. "The time is 14 hours and 30 minutes"

```powershell
SayTime
Speaks the current time, e.g. "The time is 14 hours and 30 minutes"
```

## Parameter Details

### `-Wait`

> The `-Wait` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-IsSpeaking](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-IsSpeaking.md)
- [New-MicrosoftShellTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-MicrosoftShellTab.md)
- [Now](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Now.md)
- [Resume-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Resume-TextToSpeech.md)
- [SayDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/SayDate.md)
- [secondscreen](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/secondscreen.md)
- [sidebyside](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/sidebyside.md)
- [Start-SnakeGame](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-SnakeGame.md)
- [Start-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-TextToSpeech.md)
- [Stop-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Stop-TextToSpeech.md)
- [Suspend-TextToSpeech](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Suspend-TextToSpeech.md)
- [UtcNow](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/UtcNow.md)
