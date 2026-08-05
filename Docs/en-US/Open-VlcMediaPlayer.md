# Open-VlcMediaPlayer

> **SubModule:** GenXdev.Media | **Type:** Function | **Aliases:** `vlc`

## Synopsis

> Launches and controls VLC Media Player with extensive configuration options.

## Description

This function provides a comprehensive interface to launch and control VLC
Media Player with support for window positioning, monitor selection, playback
settings, audio and video filters, subtitle handling, multiple language
support, network proxy settings, and advanced performance options. The
function can automatically install VLC if not present and provides extensive
customization for media playbook scenarios. It integrates seamlessly with the
GenXdev window management system and supports keyboard input automation through
the Send-Key functionality.


## Syntax

```powershell
Open-VlcMediaPlayer [[-Path] <String[]>] [[-Width] <Int32>] [[-Height] <Int32>] [[-X] <Int32>] [[-Y] <Int32>] [-AlwaysOnTop] [-Arguments <String>] [-AspectRatio <String>] [-AudioFilterModules <String[]>] [-AudioFilters <String[]>] [-AudioLanguage <String>] [-AudioVisualization <String>] [-AutoScale] [-Bottom] [-Centered] [-ClearSession] [-Close] [-Crop <String>] [-Deinterlace <String>] [-DeinterlaceMode <String>] [-DisableAudio] [-DisableSubtitles] [-EnableAudioTimeStretch] [-EnableTimeStretch] [-EnableWallpaperMode] [-FocusWindow] [-ForceDolbySurround <String>] [-FullScreen] [-HighPriority] [-HttpProxy <String>] [-HttpProxyPassword <String>] [-IgnoredExtensions <String>] [-IgnoredFileExtensions <String>] [-KeysToSend <String[]>] [-Left] [-Loop] [-Maximize] [-Modules <String[]>] [-Monitor <Int32>] [-NewWindow] [-NoBorders] [-PassThru] [-PlayAndExit] [-PreferredAudioLanguage <String>] [-PreferredSubtitleLanguage <String>] [-Random] [-Repeat] [-ReplayGainMode <String>] [-ReplayGainPreamp <Single>] [-RestoreFocus] [-Right] [-SendKeyDelayMilliSeconds <Int32>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-SideBySide] [-SkipSession] [-StartPaused] [-SubdirectoryBehavior <String>] [-SubtitleFile <String>] [-SubtitleLanguage <String>] [-SubtitleScale <Int32>] [-Top] [-VerbosityLevel <Int32>] [-VideoFilterModules <String[]>] [-VideoFilters <String[]>] [-Visualization <String>] [-VLCPath <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Path` | String[] | ☐ | The media file(s) or URL(s) to open in VLC |
| `-Width` | Int32 | ☐ | The initial width of the window |
| `-Height` | Int32 | ☐ | The initial height of the window |
| `-X` | Int32 | ☐ | The initial X position of the window |
| `-Y` | Int32 | ☐ | The initial Y position of the window |
| `-KeysToSend` | String[] | ☐ | Keystrokes to send to the VLC Player Window, <br>see documentation for cmdlet GenXdev\Send-Key |
| `-SendKeyEscape` | SwitchParameter | ☐ | Escape control characters and modifiers when<br>sending keys to VLC |
| `-SendKeyUseShiftEnter` | SwitchParameter | ☐ | Use Shift+Enter instead of Enter when sending<br>keys to VLC |
| `-SendKeyDelayMilliSeconds` | Int32 | ☐ | Delay between different input strings in<br>milliseconds when sending keys to VLC |
| `-SendKeyHoldKeyboardFocus` | SwitchParameter | ☐ | Hold keyboard focus on the VLC window after<br>sending keys |
| `-Monitor` | Int32 | ☐ | The monitor to use, 0 = default, -1 is<br>discard |
| `-AspectRatio` | String | ☐ | Source aspect ratio |
| `-Crop` | String | ☐ | Video cropping |
| `-SubtitleFile` | String | ☐ | Use subtitle file |
| `-SubtitleScale` | Int32 | ☐ | Subtitles text scaling factor |
| `-SubtitleLanguage` | String | ☐ | Subtitle language |
| `-AudioLanguage` | String | ☐ | Audio language |
| `-PreferredAudioLanguage` | String | ☐ | Preferred audio language |
| `-HttpProxy` | String | ☐ | HTTP proxy |
| `-HttpProxyPassword` | String | ☐ | HTTP proxy password |
| `-VerbosityLevel` | Int32 | ☐ | Verbosity level |
| `-SubdirectoryBehavior` | String | ☐ | Subdirectory behavior |
| `-IgnoredExtensions` | String | ☐ | Ignored extensions |
| `-VLCPath` | String | ☐ | Path to VLC executable |
| `-ReplayGainMode` | String | ☐ | Replay gain mode |
| `-ReplayGainPreamp` | Single | ☐ | Replay gain preamp |
| `-ForceDolbySurround` | String | ☐ | Force detection of Dolby Surround |
| `-AudioFilters` | String[] | ☐ | Audio filters |
| `-Visualization` | String | ☐ | Audio visualizations |
| `-Deinterlace` | String | ☐ | Deinterlace |
| `-DeinterlaceMode` | String | ☐ | Deinterlace mode |
| `-VideoFilters` | String[] | ☐ | Video filter module |
| `-VideoFilterModules` | String[] | ☐ | Video filter modules |
| `-Modules` | String[] | ☐ | Modules |
| `-AudioFilterModules` | String[] | ☐ | Audio filter modules |
| `-AudioVisualization` | String | ☐ | Audio visualization mode |
| `-PreferredSubtitleLanguage` | String | ☐ | Preferred subtitle language |
| `-IgnoredFileExtensions` | String | ☐ | Ignored file extensions |
| `-Arguments` | String | ☐ | Additional arguments |
| `-NoBorders` | SwitchParameter | ☐ | Removes the borders of the window |
| `-Left` | SwitchParameter | ☐ | Place window on the left side of the screen |
| `-Right` | SwitchParameter | ☐ | Place window on the right side of the screen |
| `-Top` | SwitchParameter | ☐ | Place window on the top side of the screen |
| `-Bottom` | SwitchParameter | ☐ | Place window on the bottom side of the screen |
| `-Centered` | SwitchParameter | ☐ | Place window in the center of the screen |
| `-FullScreen` | SwitchParameter | ☐ | Sends F11 to the window |
| `-PassThru` | SwitchParameter | ☐ | Returns the window helper for each process |
| `-AlwaysOnTop` | SwitchParameter | ☐ | Always on top |
| `-Random` | SwitchParameter | ☐ | Play files randomly forever |
| `-Loop` | SwitchParameter | ☐ | Repeat all |
| `-Repeat` | SwitchParameter | ☐ | Repeat current item |
| `-StartPaused` | SwitchParameter | ☐ | Start paused |
| `-PlayAndExit` | SwitchParameter | ☐ | Play and exit |
| `-DisableAudio` | SwitchParameter | ☐ | Disable audio |
| `-DisableSubtitles` | SwitchParameter | ☐ | Disable subtitles |
| `-AutoScale` | SwitchParameter | ☐ | Video Auto Scaling |
| `-HighPriority` | SwitchParameter | ☐ | Increase the priority of the process |
| `-EnableTimeStretch` | SwitchParameter | ☐ | Enable time stretching audio |
| `-NewWindow` | SwitchParameter | ☐ | Open new VLC mediaplayer instance |
| `-EnableWallpaperMode` | SwitchParameter | ☐ | Enable video wallpaper mode |
| `-EnableAudioTimeStretch` | SwitchParameter | ☐ | Enable audio time stretching |
| `-Close` | SwitchParameter | ☐ | Close the VLC media player window |
| `-SideBySide` | SwitchParameter | ☐ | Will either set the window fullscreen on a<br>different monitor than Powershell, or  side<br>by side with Powershell on the same monitor |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the VLC window after opening |
| `-SetForeground` | SwitchParameter | ☐ | Set the VLC window to foreground after<br>opening |
| `-Maximize` | SwitchParameter | ☐ | Maximize the window |
| `-RestoreFocus` | SwitchParameter | ☐ | Restore PowerShell window focus after opening<br>VLC |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for AI preferences |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for AI preferences |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without affecting session |

## Examples

### Open-VlcMediaPlayer -Path "video.mp4" -Fullscreen -Monitor 0 Opens a video file in fullscreen mode on the primary monitor for immersive viewing experience.

```powershell
Open-VlcMediaPlayer -Path "video.mp4" -Fullscreen -Monitor 0
Opens a video file in fullscreen mode on the primary monitor for immersive
viewing experience.
```

### vlc "video.mp4" -fs -m 0 Short form using aliases to open video fullscreen on monitor 0 with minimal typing required.

```powershell
vlc "video.mp4" -fs -m 0
Short form using aliases to open video fullscreen on monitor 0 with minimal
typing required.
```

### Open-VlcMediaPlayer -Path "movie.mkv" -SubtitleFile "movie.srt" -AudioLanguage "English" Opens a movie with external subtitles and specific audio language for enhanced viewing with captions.

```powershell
Open-VlcMediaPlayer -Path "movie.mkv" -SubtitleFile "movie.srt" -AudioLanguage "English"
Opens a movie with external subtitles and specific audio language for
enhanced viewing with captions.
```

## Parameter Details

### `-Path <String[]>`

> The media file(s) or URL(s) to open in VLC

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Width <Int32>`

> The initial width of the window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Height <Int32>`

> The initial height of the window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-X <Int32>`

> The initial X position of the window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 3 |
| **Default value** | `-999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Y <Int32>`

> The initial Y position of the window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 4 |
| **Default value** | `-999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-KeysToSend <String[]>`

> Keystrokes to send to the VLC Player Window,  see documentation for cmdlet GenXdev\Send-Key

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | True (ByPropertyName) |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyEscape`

> Escape control characters and modifiers when sending keys to VLC

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `Escape` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyUseShiftEnter`

> Use Shift+Enter instead of Enter when sending keys to VLC

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `UseShiftEnter` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyDelayMilliSeconds <Int32>`

> Delay between different input strings in milliseconds when sending keys to VLC

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `50` |
| **Accept pipeline input?** | False |
| **Aliases** | `DelayMilliSeconds` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyHoldKeyboardFocus`

> Hold keyboard focus on the VLC window after sending keys

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `HoldKeyboardFocus` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Monitor <Int32>`

> The monitor to use, 0 = default, -1 is discard

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | `m`, `mon` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AspectRatio <String>`

> Source aspect ratio

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Crop <String>`

> Video cropping

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SubtitleFile <String>`

> Use subtitle file

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SubtitleScale <Int32>`

> Subtitles text scaling factor

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SubtitleLanguage <String>`

> Subtitle language

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AudioLanguage <String>`

> Audio language

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PreferredAudioLanguage <String>`

> Preferred audio language

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-HttpProxy <String>`

> HTTP proxy

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-HttpProxyPassword <String>`

> HTTP proxy password

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-VerbosityLevel <Int32>`

> Verbosity level

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SubdirectoryBehavior <String>`

> Subdirectory behavior

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-IgnoredExtensions <String>`

> Ignored extensions

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-VLCPath <String>`

> Path to VLC executable

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `"${env:ProgramFiles}\VideoLAN\VLC\vlc.exe"` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ReplayGainMode <String>`

> Replay gain mode

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ReplayGainPreamp <Single>`

> Replay gain preamp

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ForceDolbySurround <String>`

> Force detection of Dolby Surround

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AudioFilters <String[]>`

> Audio filters

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Visualization <String>`

> Audio visualizations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Deinterlace <String>`

> Deinterlace

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DeinterlaceMode <String>`

> Deinterlace mode

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-VideoFilters <String[]>`

> Video filter module

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-VideoFilterModules <String[]>`

> Video filter modules

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Modules <String[]>`

> Modules

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AudioFilterModules <String[]>`

> Audio filter modules

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AudioVisualization <String>`

> Audio visualization mode

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PreferredSubtitleLanguage <String>`

> Preferred subtitle language

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-IgnoredFileExtensions <String>`

> Ignored file extensions

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Arguments <String>`

> Additional arguments

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoBorders`

> Removes the borders of the window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nb` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Left`

> Place window on the left side of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Right`

> Place window on the right side of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Top`

> Place window on the top side of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Bottom`

> Place window on the bottom side of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Centered`

> Place window in the center of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-FullScreen`

> Sends F11 to the window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fs` |
| **Accept wildcard characters?** | No |

<hr/>

### `-PassThru`

> Returns the window helper for each process

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `pt` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AlwaysOnTop`

> Always on top

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Random`

> Play files randomly forever

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `Shuffle` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Loop`

> Repeat all

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Repeat`

> Repeat current item

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-StartPaused`

> Start paused

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PlayAndExit`

> Play and exit

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DisableAudio`

> Disable audio

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DisableSubtitles`

> Disable subtitles

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoScale`

> Video Auto Scaling

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-HighPriority`

> Increase the priority of the process

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-EnableTimeStretch`

> Enable time stretching audio

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NewWindow`

> Open new VLC mediaplayer instance

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-EnableWallpaperMode`

> Enable video wallpaper mode

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-EnableAudioTimeStretch`

> Enable audio time stretching

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Close`

> Close the VLC media player window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SideBySide`

> Will either set the window fullscreen on a different monitor than Powershell, or  side by side with Powershell on the same monitor

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `sbs` |
| **Accept wildcard characters?** | No |

<hr/>

### `-FocusWindow`

> Focus the VLC window after opening

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fw`, `focus` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SetForeground`

> Set the VLC window to foreground after opening

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fg` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Maximize`

> Maximize the window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-RestoreFocus`

> Restore PowerShell window focus after opening VLC

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `rf`, `bg` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Use alternative settings stored in session for AI preferences

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ClearSession`

> Clear alternative settings stored in session for AI preferences

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipSession`

> Store settings only in persistent preferences without affecting session

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-ImageGeolocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageGeolocation.md)
- [Get-ImageMetadata](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageMetadata.md)
- [Get-MediaFileCreationDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MediaFileCreationDate.md)
- [Open-MediaFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-MediaFile.md)
- [Open-VlcMediaPlayerLyrics](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayerLyrics.md)
- [Set-VLCPlayerFocused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-VLCPlayerFocused.md)
- [StabilizeVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/StabilizeVideo.md)
- [Start-VlcMediaPlayerNextInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerNextInPlaylist.md)
- [Start-VlcMediaPlayerPreviousInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerPreviousInPlaylist.md)
- [Switch-VlcMediaPlayerMute](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerMute.md)
- [Switch-VLCMediaPlayerPaused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VLCMediaPlayerPaused.md)
- [Switch-VlcMediaPlayerRepeat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerRepeat.md)
