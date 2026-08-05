# Get-ImageMetadata

> **SubModule:** GenXdev.Media | **Type:** Function | **Aliases:** —

## Synopsis

> Extracts comprehensive metadata from an image file.

## Description

This function reads EXIF, IPTC and other metadata from an image file. It extracts
a wide range of information including camera details, exposure settings, GPS coordinates,
dates, copyright information, and more. It supports images that contain metadata
in their EXIF data (JPEG, TIFF) as well as PNG metadata.


## Syntax

```powershell
Get-ImageMetadata -ImagePath <String> [-AutoConsent] [-AutoConsentAllPackages] [-SessionOnly] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ImagePath` | String | ✅ | Path to the image file to analyze |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to this installation<br>type and set persistent flag.. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to ALL third-party<br>software installations and set persistent<br>flag for ImageSharp packages. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences |

## Examples

### Get-ImageMetadata -ImagePath "C:\Pictures\vacation.jpg"

```powershell
Get-ImageMetadata -ImagePath "C:\Pictures\vacation.jpg"
```

### "C:\Pictures\vacation.jpg" | Get-ImageMetadata

```powershell
"C:\Pictures\vacation.jpg" | Get-ImageMetadata
```

### Get-ImageMetadata -ImagePath "C:\Pictures\photo.webp" -AutoConsentAllPackages

```powershell
Get-ImageMetadata -ImagePath "C:\Pictures\photo.webp" -AutoConsentAllPackages
```

## Parameter Details

### `-ImagePath <String>`

> Path to the image file to analyze

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsent`

> Automatically consent to this installation type and set persistent flag..

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsentAllPackages`

> Automatically consent to ALL third-party software installations and set persistent flag for ImageSharp packages.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Use alternative settings stored in session for  preferences

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Outputs

- `Collections.Hashtable
Returns a hashtable containing all available metadata categories including:
- Basic (dimensions, format, etc.)
- Camera (make, model, etc.)
- Exposure (aperture, shutter speed, ISO, etc.)
- GPS (latitude, longitude, etc.)
- DateTime (when taken, modified, etc.)
- Author (artist, copyright, etc.)
- Additional (software, comments, etc.)`
- `GenXdev.Helpers.ImageSearchResultMetadata`

## Related Links

- [Get-ImageGeolocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageGeolocation.md)
- [Get-MediaFileCreationDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MediaFileCreationDate.md)
- [Open-MediaFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-MediaFile.md)
- [Open-VlcMediaPlayer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayer.md)
- [Open-VlcMediaPlayerLyrics](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayerLyrics.md)
- [Set-VLCPlayerFocused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-VLCPlayerFocused.md)
- [StabilizeVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/StabilizeVideo.md)
- [Start-VlcMediaPlayerNextInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerNextInPlaylist.md)
- [Start-VlcMediaPlayerPreviousInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerPreviousInPlaylist.md)
- [Switch-VlcMediaPlayerMute](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerMute.md)
- [Switch-VLCMediaPlayerPaused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VLCMediaPlayerPaused.md)
- [Switch-VlcMediaPlayerRepeat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerRepeat.md)
