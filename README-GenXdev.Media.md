# GenXdev.Media

## Overview

GenXdev.Media provides media playback control and metadata extraction. It
manages VLC Media Player — launching, playlist navigation, pause/mute/repeat
toggle, lyrics lookup — plus it searches for media files and creates playlists
accordingly with launching of VLC media player.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Open-MediaFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-MediaFile.md) | `vlcmedia`, `media`, `findmedia` | Find and play media files with filtering |
| [Open-VlcMediaPlayer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayer.md) | `vlc` | Launch and control VLC Media Player |
| [Switch-VLCMediaPlayerPaused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VLCMediaPlayerPaused.md) | `vlcpause`, `vlcplay` | Toggle play/pause in VLC |
| [Switch-VlcMediaPlayerMute](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerMute.md) | `vlcmute`, `vlcunmute` | Toggle mute in VLC |
| [Switch-VlcMediaPlayerRepeat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerRepeat.md) | `vlcrepeat` | Toggle repeat mode in VLC |
| [Start-VlcMediaPlayerNextInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerNextInPlaylist.md) | `vlcnext` | Skip to the next track |
| [Start-VlcMediaPlayerPreviousInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerPreviousInPlaylist.md) | `vlcprev`, `vlcback` | Go back to the previous track |
| [Set-VLCPlayerFocused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-VLCPlayerFocused.md) | `showvlc`, `vlcf`, `fvlc` | Bring the VLC window to the foreground |
| [Open-VlcMediaPlayerLyrics](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayerLyrics.md) | `vlclyrics` | Search for lyrics of the currently playing song |
| [Get-ImageMetadata](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageMetadata.md) | — | Extract comprehensive EXIF and metadata from images |
| [Get-ImageGeolocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageGeolocation.md) | — | Extract GPS coordinates from image files |
| [Get-MediaFileCreationDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MediaFileCreationDate.md) | — | Determine the best-effort creation date for any media file |
| [StabilizeVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/StabilizeVideo.md) | — | Stabilize shaky video using FFmpeg + vid.stab |

## How It All Comes Together

`Open-VlcMediaPlayer` (`vlc`) launches VLC Media Player with options for
monitor, position, playlist, volume, start time, and subtitle track.
`Open-MediaFile` (`media`, `vlcmedia`, `findmedia`) finds and plays media
files with configurable filtering.

The playback control cmdlets — `vlcpause`/`vlcplay`, `vlcnext`, `vlcprev`/
`vlcback`, `vlcrepeat`, `vlcmute`/`vlcunmute` — control a running VLC
instance. `Set-VLCPlayerFocused` (`showvlc`, `vlcf`, `fvlc`) brings the
VLC window to the foreground. `Open-VlcMediaPlayerLyrics` (`vlclyrics`)
opens a web browser to search for lyrics of the currently playing song.

`Get-ImageMetadata` extracts EXIF and other metadata from image files.
`Get-ImageGeolocation` extracts GPS coordinates. `Get-MediaFileCreationDate`
determines a best-effort creation date for media files.
`StabilizeVideo` stabilizes video files using FFmpeg + vid.stab.

## See Also

- [GenXdev.AI.Queries](README-GenXdev.AI.Queries.md) — Image metadata pipeline
- [GenXdev.FileSystem](README-GenXdev.FileSystem.md) — File search used by Open-MediaFile
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevmedia)
