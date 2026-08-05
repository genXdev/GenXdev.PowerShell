# StabilizeVideo

> **SubModule:** GenXdev.Media | **Type:** Function | **Aliases:** —

## Synopsis

> Stabilizes the newest or specified .mp4 file using FFmpeg + vid.stab (no black borders).

## Description

Two-pass vid.stab stabilization with optzoom=1 (auto zoom/crop so borders never show)
    plus light sharpening. Works exactly like your Save-Video cmdlet — super simple.


## Syntax

```powershell
StabilizeVideo [[-InputFile] <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-InputFile` | String | ☐ | The `-InputFile` parameter. |

## Examples

### Stabilize-Video                  # stabilizes the most recent .mp4     Stabilize-Video shaky.mp4         # specific file

```powershell
Stabilize-Video                  # stabilizes the most recent .mp4
    Stabilize-Video shaky.mp4         # specific file
```

## Parameter Details

### `-InputFile <String>`

> The `-InputFile` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-ImageGeolocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageGeolocation.md)
- [Get-ImageMetadata](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageMetadata.md)
- [Get-MediaFileCreationDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MediaFileCreationDate.md)
- [Open-MediaFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-MediaFile.md)
- [Open-VlcMediaPlayer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayer.md)
- [Open-VlcMediaPlayerLyrics](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayerLyrics.md)
- [Set-VLCPlayerFocused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-VLCPlayerFocused.md)
- [Start-VlcMediaPlayerNextInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerNextInPlaylist.md)
- [Start-VlcMediaPlayerPreviousInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerPreviousInPlaylist.md)
- [Switch-VlcMediaPlayerMute](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerMute.md)
- [Switch-VLCMediaPlayerPaused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VLCMediaPlayerPaused.md)
- [Switch-VlcMediaPlayerRepeat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerRepeat.md)
