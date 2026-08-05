# Open-MediaFile

> **SubModule:** GenXdev.Media | **Type:** Function | **Aliases:** `vlcmedia`, `media`, `findmedia`

## Synopsis

> Opens and plays media files using VLC media player with advanced filtering and
configuration options.

## Description

This function scans for media files based on search patterns,
creates a playlist, and launches VLC media player with comprehensive
configuration options. It supports videos, audio files, and pictures with
automatic VLC installation if needed. The function provides extensive control
over playback behavior, window positioning, audio/video settings, and subtitle
handling.


## Syntax

```powershell
Open-MediaFile [[-Name] <String[]>] [[-Width] <Int32>] [[-Height] <Int32>] [[-X] <Int32>] [[-Y] <Int32>] [-AllDrives] [-AlwaysOnTop] [-Arguments <String>] [-AspectRatio <String>] [-AttributesToSkip <IO.FileAttributes>] [-AudioFilterModules <String[]>] [-AudioFilters <String[]>] [-AudioLanguage <String>] [-AudioVisualization <String>] [-AutoScale] [-Bottom] [-CaseNameMatching <IO.MatchCasing>] [-Centered] [-ClearSession] [-Close] [-Crop <String>] [-Deinterlace <String>] [-DeinterlaceMode <String>] [-DisableAudio] [-DisableSubtitles] [-EnableAudioTimeStretch] [-EnableTimeStretch] [-EnableWallpaperMode] [-Exclude <String[]>] [-FocusWindow] [-FollowSymlinkAndJunctions] [-ForceDolbySurround <String>] [-FullScreen] [-HighPriority] [-HttpProxy <String>] [-HttpProxyPassword <String>] [-IgnoredExtensions <String>] [-IgnoredFileExtensions <String>] [-IncludeAlternateFileStreams] [-IncludeAudio] [-IncludePictures] [-IncludeVideos] [-InputObject <Object>] [-KeysToSend <String[]>] [-Left] [-Loop] [-MaxDegreeOfParallelism <Int32>] [-MaxFileSize <Int64>] [-Maximize] [-MaxRecursionDepth <Int32>] [-MaxSearchUpDepth <Int32>] [-MinFileSize <Int64>] [-ModifiedAfter <DateTime>] [-ModifiedBefore <DateTime>] [-Modules <String[]>] [-Monitor <Int32>] [-NewWindow] [-NoBorders] [-NoRecurse] [-OnlyAudio] [-OnlyPictures] [-OnlyVideos] [-PassThru] [-PassThruNoOpen] [-PassThruWindow] [-PlayAndExit] [-PlaylistPath <String>] [-PreferredAudioLanguage <String>] [-PreferredSubtitleLanguage <String>] [-Random] [-Repeat] [-ReplayGainMode <String>] [-ReplayGainPreamp <Single>] [-RestoreFocus] [-Right] [-SendKeyDelayMilliSeconds <Int32>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-SideBySide] [-SkipSession] [-StartPaused] [-SubdirectoryBehavior <String>] [-SubtitleFile <String>] [-SubtitleLanguage <String>] [-SubtitleScale <Int32>] [-TimeoutSeconds <Int32>] [-Top] [-VerbosityLevel <Int32>] [-VideoFilterModules <String[]>] [-VideoFilters <String[]>] [-Visualization <String>] [-VLCPath <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Name` | String[] | ☐ | File name or pattern to search for. Default<br>is '* 🌐 wildcards |
| `-AllDrives` | SwitchParameter | ☐ | Search across all available drives |
| `-NoRecurse` | SwitchParameter | ☐ | Do not recurse into subdirectories |
| `-FollowSymlinkAndJunctions` | SwitchParameter | ☐ | Follow symlinks and junctions during<br>directory traversal. |
| `-MaxSearchUpDepth` | Int32 | ☐ | Maximum recursion depth for continuing<br>searching upwards the tree for relative<br>searches, while no items are found. 0 means<br>disabled. |
| `-MaxFileSize` | Int64 | ☐ | Maximum file size in bytes to include in<br>results. 0 means unlimited. |
| `-MinFileSize` | Int64 | ☐ | Minimum file size in bytes to include in<br>results. 0 means no minimum. |
| `-ModifiedAfter` | DateTime | ☐ | Only include files modified after this<br>date/time (UTC). |
| `-ModifiedBefore` | DateTime | ☐ | Only include files modified before this<br>date/time (UTC). |
| `-AttributesToSkip` | IO.FileAttributes | ☐ | File attributes to skip (e.g., System, Hidden<br>or None). |
| `-InputObject` | Object | ☐ | File name or pattern to search for from<br>pipeline input. Default is "* 🌐 wildcards |
| `-PlaylistPath` | String | ☐ | Playlist path to save the media files to. If<br>not specified,  the playlist will be saved in<br>a temporary directory. |
| `-Width` | Int32 | ☐ | The initial width of the window |
| `-Height` | Int32 | ☐ | The initial height of the window |
| `-X` | Int32 | ☐ | The initial X position of the window |
| `-Y` | Int32 | ☐ | The initial Y position of the window |
| `-KeysToSend` | String[] | ☐ | Keystrokes to send to the VLC Player Window,<br>see  documentation for cmdlet<br>GenXdev\Send-Key |
| `-MaxDegreeOfParallelism` | Int32 | ☐ | Maximum degree of parallelism for directory<br>tasks |
| `-TimeoutSeconds` | Int32 | ☐ | Optional: cancellation timeout in seconds |
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
| `-IncludeAlternateFileStreams` | SwitchParameter | ☐ | Include alternate data streams in search<br>results |
| `-OnlyVideos` | SwitchParameter | ☐ | Only include video files in the playlist |
| `-OnlyAudio` | SwitchParameter | ☐ | Only include audio files in the playlist |
| `-OnlyPictures` | SwitchParameter | ☐ | Only include pictures in the playlist |
| `-IncludeVideos` | SwitchParameter | ☐ | Additionally include videos in the playlist |
| `-IncludeAudio` | SwitchParameter | ☐ | Additionally include audio files in the<br>playlist |
| `-IncludePictures` | SwitchParameter | ☐ | Additionally include pictures in the playlist |
| `-NoBorders` | SwitchParameter | ☐ | Removes the borders of the window |
| `-Left` | SwitchParameter | ☐ | Place window on the left side of the screen |
| `-Right` | SwitchParameter | ☐ | Place window on the right side of the screen |
| `-Top` | SwitchParameter | ☐ | Place window on the top side of the screen |
| `-Bottom` | SwitchParameter | ☐ | Place window on the bottom side of the screen |
| `-Centered` | SwitchParameter | ☐ | Place window in the center of the screen |
| `-FullScreen` | SwitchParameter | ☐ | Sends F11 to the window |
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
| `-SideBySide` | SwitchParameter | ☐ | Will either set the window fullscreen on a <br>different monitor than Powershell, or side by<br>side  with Powershell on the same monitor |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the VLC window after opening |
| `-SetForeground` | SwitchParameter | ☐ | Set the VLC window to foreground after<br>opening |
| `-Maximize` | SwitchParameter | ☐ | Maximize the window |
| `-RestoreFocus` | SwitchParameter | ☐ | Restores PowerShell window focus after<br>opening VLC. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for AI preferences |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for AI preferences |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without affecting session |
| `-CaseNameMatching` | IO.MatchCasing | ☐ | Gets or sets the case-sensitivity for files<br>and directories |
| `-MaxRecursionDepth` | Int32 | ☐ | Maximum recursion depth for directory<br>traversal. 0 means unlimited. |
| `-Exclude` | String[] | ☐ | Exclude files or directories matching these<br>wildcard patterns (e.g., *.tmp, *\\bin\\*). |
| `-PassThru` | SwitchParameter | ☐ | Returns the files found by the search |
| `-PassThruNoOpen` | SwitchParameter | ☐ | Returns the files found by the search without<br>opening VLC |
| `-PassThruWindow` | SwitchParameter | ☐ | Returns the window helper for each process |

## Examples

### Open-MediaFile Opens all media files in the current directory using default VLC settings.

```powershell
Open-MediaFile
Opens all media files in the current directory using default VLC settings.
```

### vlcmedia ~\Pictures -OnlyPictures -Fullscreen Opens only picture files from the Pictures folder in fullscreen mode using the alias 'vlcmedia'.

```powershell
vlcmedia ~\Pictures -OnlyPictures -Fullscreen
Opens only picture files from the Pictures folder in fullscreen mode using the
alias 'vlcmedia'.
```

### media ~\Videos -OnlyVideos -Loop Opens video files with looping enabled using the alias 'media'.

```powershell
media ~\Videos -OnlyVideos -Loop
Opens video files with looping enabled using the alias 'media'.
```

## Parameter Details

### `-Name <String[]>`

> File name or pattern to search for. Default is '*

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `'*'` |
| **Accept pipeline input?** | False |
| **Aliases** | `like`, `Path`, `LiteralPath`, `Query`, `SearchMask`, `Include` |
| **Accept wildcard characters?** | Yes |

<hr/>

### `-AllDrives`

> Search across all available drives

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoRecurse`

> Do not recurse into subdirectories

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-FollowSymlinkAndJunctions`

> Follow symlinks and junctions during directory traversal.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxSearchUpDepth <Int32>`

> Maximum recursion depth for continuing searching upwards the tree for relative searches, while no items are found. 0 means disabled.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `maxupward` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxFileSize <Int64>`

> Maximum file size in bytes to include in results. 0 means unlimited.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `maxlength`, `maxsize` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MinFileSize <Int64>`

> Minimum file size in bytes to include in results. 0 means no minimum.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `minsize`, `minlength` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ModifiedAfter <DateTime>`

> Only include files modified after this date/time (UTC).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ma`, `after` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ModifiedBefore <DateTime>`

> Only include files modified before this date/time (UTC).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `before`, `mb` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AttributesToSkip <IO.FileAttributes>`

> File attributes to skip (e.g., System, Hidden or None).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `[System.IO.FileAttributes]::System` |
| **Accept pipeline input?** | False |
| **Aliases** | `skipattr` |
| **Accept wildcard characters?** | No |

<hr/>

### `-InputObject <Object>`

> File name or pattern to search for from pipeline input. Default is "*

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `FullName` |
| **Accept wildcard characters?** | Yes |

<hr/>

### `-PlaylistPath <String>`

> Playlist path to save the media files to. If not specified,  the playlist will be saved in a temporary directory.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `[System.IO.Path]::GetTempFileName() + '.m3u'` |
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

> Keystrokes to send to the VLC Player Window, see  documentation for cmdlet GenXdev\Send-Key

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByPropertyName) |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxDegreeOfParallelism <Int32>`

> Maximum degree of parallelism for directory tasks

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `threads` |
| **Accept wildcard characters?** | No |

<hr/>

### `-TimeoutSeconds <Int32>`

> Optional: cancellation timeout in seconds

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `maxseconds` |
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
| **Default value** | *(none)* |
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
| **Default value** | `-2` |
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

### `-IncludeAlternateFileStreams`

> Include alternate data streams in search results

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ads` |
| **Accept wildcard characters?** | No |

<hr/>

### `-OnlyVideos`

> Only include video files in the playlist

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-OnlyAudio`

> Only include audio files in the playlist

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-OnlyPictures`

> Only include pictures in the playlist

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-IncludeVideos`

> Additionally include videos in the playlist

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-IncludeAudio`

> Additionally include audio files in the playlist

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-IncludePictures`

> Additionally include pictures in the playlist

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

> Will either set the window fullscreen on a  different monitor than Powershell, or side by side  with Powershell on the same monitor

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

> Restores PowerShell window focus after opening VLC.

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

### `-CaseNameMatching <IO.MatchCasing>`

> Gets or sets the case-sensitivity for files and directories

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `[System.IO.MatchCasing]::PlatformDefault` |
| **Accept pipeline input?** | False |
| **Aliases** | `casing`, `CaseSearchMaskMatching` |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxRecursionDepth <Int32>`

> Maximum recursion depth for directory traversal. 0 means unlimited.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `md`, `depth`, `maxdepth` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Exclude <String[]>`

> Exclude files or directories matching these wildcard patterns (e.g., *.tmp, *\\bin\\*).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@('*\\.git\\*')` |
| **Accept pipeline input?** | False |
| **Aliases** | `skiplike` |
| **Accept wildcard characters?** | No |

<hr/>

### `-PassThru`

> Returns the files found by the search

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `pt` |
| **Accept wildcard characters?** | No |

<hr/>

### `-PassThruNoOpen`

> Returns the files found by the search without opening VLC

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PassThruWindow`

> Returns the window helper for each process

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

- [Get-ImageGeolocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageGeolocation.md)
- [Get-ImageMetadata](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageMetadata.md)
- [Get-MediaFileCreationDate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-MediaFileCreationDate.md)
- [Open-VlcMediaPlayer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayer.md)
- [Open-VlcMediaPlayerLyrics](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-VlcMediaPlayerLyrics.md)
- [Set-VLCPlayerFocused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-VLCPlayerFocused.md)
- [StabilizeVideo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/StabilizeVideo.md)
- [Start-VlcMediaPlayerNextInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerNextInPlaylist.md)
- [Start-VlcMediaPlayerPreviousInPlaylist](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-VlcMediaPlayerPreviousInPlaylist.md)
- [Switch-VlcMediaPlayerMute](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerMute.md)
- [Switch-VLCMediaPlayerPaused](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VLCMediaPlayerPaused.md)
- [Switch-VlcMediaPlayerRepeat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Switch-VlcMediaPlayerRepeat.md)
