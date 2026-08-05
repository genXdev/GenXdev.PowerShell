<#
.SYNOPSIS
Opens and plays media files using VLC media player with advanced filtering and
configuration options.

.DESCRIPTION
This function scans for media files based on search patterns,
creates a playlist, and launches VLC media player with comprehensive
configuration options. It supports videos, audio files, and pictures with
automatic VLC installation if needed. The function provides extensive control
over playback behavior, window positioning, audio/video settings, and subtitle
handling.

.LICENSE
Copyright (C) 2026 René Vaessen / GenXdev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>.

.PARAMETER Name
File name or pattern to search for. Supports wildcards. Default is '*' to find
all media files.

.PARAMETER InputObject
File name or pattern to search for from pipeline input. Default is "*".

.PARAMETER PlaylistPath
Playlist path to save the media files to. If not specified, the playlist will
be saved in a temporary directory.

.PARAMETER MaxDegreeOfParallelism
Maximum degree of parallelism for directory tasks.

.PARAMETER TimeoutSeconds
Optional: cancellation timeout in seconds.

.PARAMETER SendKeyEscape
Escape control characters and modifiers in the KeysToSend parameter.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when processing KeysToSend.

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending keys.

.PARAMETER SendKeyHoldKeyboardFocus
Prevents returning keyboard focus to PowerShell after sending keys.

.PARAMETER Monitor
The monitor to display VLC on. 0 = default monitor, -1 = discard positioning.

.PARAMETER AspectRatio
Forces a specific aspect ratio for video content.

.PARAMETER Crop
Applies video cropping with specified dimensions.

.PARAMETER SubtitleFile
Path to an external subtitle file to use with video content.

.PARAMETER SubtitleScale
Sets the subtitle text scaling factor (10-500 percent).

.PARAMETER SubtitleLanguage
Specifies the preferred subtitle language from available tracks.

.PARAMETER AudioLanguage
Specifies the preferred audio language from available tracks.

.PARAMETER PreferredAudioLanguage
Sets the default preferred audio language for future playback.

.PARAMETER HttpProxy
HTTP proxy server address for network streaming content.

.PARAMETER HttpProxyPassword
Password for HTTP proxy authentication.

.PARAMETER VerbosityLevel
Sets VLC's log verbosity level (0=quiet, 1=errors, 2=verbose).

.PARAMETER SubdirectoryBehavior
Controls how subdirectories are handled in the playlist.

.PARAMETER IgnoredExtensions
File extensions to ignore during media file scanning.

.PARAMETER VLCPath
Full path to the VLC executable. Defaults to standard installation location.

.PARAMETER ReplayGainMode
Sets the audio replay gain mode to normalize volume levels across tracks.

.PARAMETER ReplayGainPreamp
Sets the replay gain preamp level in decibels (-20.0 to 20.0).

.PARAMETER ForceDolbySurround
Forces detection of Dolby Surround audio encoding.

.PARAMETER AudioFilters
Specifies audio filter modules to apply during playback.

.PARAMETER Visualization
Sets the audio visualization mode for audio-only content.

.PARAMETER Deinterlace
Controls video deinterlacing for improved quality on interlaced content.

.PARAMETER DeinterlaceMode
Specifies the deinterlacing algorithm to use.

.PARAMETER VideoFilters
Specifies video filter modules to apply during playback.

.PARAMETER VideoFilterModules
Additional video filter modules to load and apply.

.PARAMETER Modules
General VLC modules to load during startup.

.PARAMETER AudioFilterModules
Additional audio filter modules to load and apply.

.PARAMETER AudioVisualization
Sets the audio visualization mode for enhanced audio-only experience.

.PARAMETER PreferredSubtitleLanguage
Sets the default preferred subtitle language for future playback.

.PARAMETER IgnoredFileExtensions
File extensions to completely ignore during scanning.

.PARAMETER Arguments
Additional command-line arguments to pass directly to VLC.

.PARAMETER AllDrives
Search across all available drives instead of just the current directory.

.PARAMETER IncludeAlternateFileStreams
Include alternate data streams in search results.

.PARAMETER NoRecurse
Do not recurse into subdirectories during the file search.

.PARAMETER FollowSymlinkAndJunctions
Follow symlinks and junctions during directory traversal.

.PARAMETER MaxRecursionDepth
Maximum recursion depth for directory traversal. 0 means unlimited.

.PARAMETER MaxSearchUpDepth
Maximum recursion depth for continuing searching upwards the tree for relative
searches while no items are found. 0 means disabled.

.PARAMETER MaxFileSize
Maximum file size in bytes to include in results. 0 means unlimited.

.PARAMETER MinFileSize
Minimum file size in bytes to include in results. 0 means no minimum.

.PARAMETER ModifiedAfter
Only include files modified after this date/time (UTC).

.PARAMETER ModifiedBefore
Only include files modified before this date/time (UTC).

.PARAMETER AttributesToSkip
File attributes to skip (e.g., System, Hidden, or None). The default is
System.

.PARAMETER IncludeOpticalDiskDrives
Include optical disk drives.

.PARAMETER SearchDrives
Optional: search specific drives.

.PARAMETER DriveLetter
Optional: search specific drives.

.PARAMETER Root
Optional: search specific base folders combined with provided Names.

.PARAMETER OnlyVideos
Filter to only include video files in the playlist (.mp4, .avi, .mkv, .mov,
.wmv).

.PARAMETER OnlyAudio
Filter to only include audio files in the playlist (.mp3, .flac, .wav, .midi,
.mid, .au, .aiff, .aac, .m4a, .ogg, .wma, .ra, .ram, .rm, .rmm).

.PARAMETER OnlyPictures
Filter to only include picture files in the playlist (.jpg, .jpeg, .png, .gif,
.bmp, .tiff, .tif).

.PARAMETER IncludeVideos
Additionally include video files in the playlist when other filters are
applied.

.PARAMETER IncludeAudio
Additionally include audio files in the playlist when other filters are
applied.

.PARAMETER IncludePictures
Additionally include picture files in the playlist when other filters are
applied.

.PARAMETER NoBorders
Removes the window borders from the VLC player window.

.PARAMETER Left
Place the VLC window on the left side of the screen.

.PARAMETER Right
Place the VLC window on the right side of the screen.

.PARAMETER Top
Place the VLC window on the top side of the screen.

.PARAMETER Bottom
Place the VLC window on the bottom side of the screen.

.PARAMETER Centered
Place the VLC window in the center of the screen.

.PARAMETER Fullscreen
Maximize the VLC window to fullscreen mode.

.PARAMETER AlwaysOnTop
Keeps the VLC window always on top of other windows.

.PARAMETER Random
Enables random playback order (shuffle mode) for the playlist.

.PARAMETER Loop
Enables playlist looping - repeats the entire playlist when finished.

.PARAMETER Repeat
Enables single item repeat - repeats the current media file indefinitely.

.PARAMETER StartPaused
Starts VLC in paused state instead of immediately playing.

.PARAMETER PlayAndExit
Automatically exits VLC when playback is completed.

.PARAMETER DisableAudio
Completely disables audio output during playback.

.PARAMETER DisableSubtitles
Completely disables subtitle display during playback.

.PARAMETER AutoScale
Enables automatic video scaling to fit the window.

.PARAMETER HighPriority
Increases the process priority of the VLC player for better performance.

.PARAMETER EnableTimeStretch
Enables audio time stretching to maintain pitch during speed changes.

.PARAMETER NewWindow
Forces opening a new VLC instance instead of using existing one.

.PARAMETER EnableWallpaperMode
Enables video wallpaper mode where video plays as desktop background.

.PARAMETER EnableAudioTimeStretch
Enables advanced audio time stretching capabilities.

.PARAMETER Close
Closes the VLC media player window.

.PARAMETER SideBySide
Places the VLC window side by side with PowerShell or on a different monitor
for fullscreen mode.

.PARAMETER FocusWindow
Focuses the VLC window after opening.

.PARAMETER SetForeground
Sets the VLC window to foreground after opening.

.PARAMETER Maximize
Maximize the window after positioning.

.PARAMETER RestoreFocus
Restores PowerShell window focus after opening VLC.

.PARAMETER SessionOnly
Uses alternative settings stored in session for AI preferences.

.PARAMETER ClearSession
Clears alternative settings stored in session for AI preferences.

.PARAMETER SkipSession
Stores settings only in persistent preferences without affecting session.

.PARAMETER CaseNameMatching
Gets or sets the case-sensitivity for files and directories.

.PARAMETER MaxRecursionDepth
Maximum recursion depth for directory traversal. 0 means unlimited.

.PARAMETER MaxFileSize
Maximum file size in bytes to include in results. 0 means unlimited.

.PARAMETER MinFileSize
Minimum file size in bytes to include in results. 0 means no minimum.

.PARAMETER ModifiedAfter
Only include files modified after this date/time (UTC).

.PARAMETER ModifiedBefore
Only include files modified before this date/time (UTC).

.PARAMETER AttributesToSkip
File attributes to skip (e.g., System, Hidden or None).

.PARAMETER Exclude
Exclude files or directories matching these wildcard patterns.

.PARAMETER PassThru
Returns the files found by the search.

.PARAMETER PassThruNoOpen
Returns the files found by the search without opening VLC.

.PARAMETER PassThruWindow
Returns the window helper for each process.

.EXAMPLE
Open-MediaFile

Opens all media files in the current directory using default VLC settings.

.EXAMPLE
vlcmedia ~\Pictures -OnlyPictures -Fullscreen

Opens only picture files from the Pictures folder in fullscreen mode using the
alias 'vlcmedia'.

.EXAMPLE
media ~\Videos -OnlyVideos -Loop

Opens video files with looping enabled using the alias 'media'.
#>
function Open-MediaFile {

    [CmdletBinding()]
    [Alias('vlcmedia', 'media', 'findmedia')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = "File name or pattern to search for. Default is '*'"
        )]
        [Alias("like", "Path", "LiteralPath", "Query", "SearchMask", "Include")]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]] $Name = '*',
        ########################################################################
        ###############################################################################
        <#
        .PARAMETER AllDrives
        Search across all available drives.
        #>
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Search across all available drives'
        )]

        [switch] $AllDrives,
        ###############################################################################
        <#
        .PARAMETER NoRecurse
        Do not recurse into subdirectories.
        #>
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Do not recurse into subdirectories'
        )]
        [switch] $NoRecurse,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Follow symlinks and junctions during directory traversal.'
        )]
        [switch] $FollowSymlinkAndJunctions,
        ###############################################################################

        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum recursion depth for continuing searching upwards the tree for relative searches, while no items are found. 0 means disabled.'
        )]
        [Alias('maxupward')]
        [int] $MaxSearchUpDepth = 0,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum file size in bytes to include in results. 0 means unlimited.'
        )]
        [Alias('maxlength', 'maxsize')]
        [long] $MaxFileSize = 0,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Minimum file size in bytes to include in results. 0 means no minimum.'
        )]
        [Alias('minsize', 'minlength')]
        [long] $MinFileSize = 0,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only include files modified after this date/time (UTC).'
        )]
        [Alias('ma', 'after')]
        [DateTime] $ModifiedAfter,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only include files modified before this date/time (UTC).'
        )]
        [Alias('before', 'mb')]
        [DateTime] $ModifiedBefore,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'File attributes to skip (e.g., System, Hidden or None).'
        )]
        [Alias('skipattr')]
        [System.IO.FileAttributes] $AttributesToSkip = [System.IO.FileAttributes]::System,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'File name or pattern to search for from pipeline input. Default is "*"'
        )]
        [Alias('FullName')]
        [SupportsWildcards()]
        [object] $InputObject,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Playlist path to save the media files to. If not specified, ' +
            'the playlist will be saved in a temporary directory.'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PlaylistPath = [System.IO.Path]::GetTempFileName() + '.m3u',
        ########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width = -1,
        ########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height = -1,
        ########################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X = -999999,
        ########################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y = -999999,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = ('Keystrokes to send to the VLC Player Window, see ' +
                'documentation for cmdlet GenXdev\Send-Key')
        )]
        [string[]] $KeysToSend,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum degree of parallelism for directory tasks'
        )]
        [Alias('threads')]
        [int] $MaxDegreeOfParallelism = 0,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Optional: cancellation timeout in seconds'
        )]
        [Alias('maxseconds')]
        [int] $TimeoutSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys to VLC'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys to VLC'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay between different input strings in milliseconds when sending keys to VLC'
        )]
        [ValidateRange(0, [int]::MaxValue)]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on the VLC window after sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard'
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -2,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Source aspect ratio'
        )]
        [string] $AspectRatio,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Video cropping'
        )]
        [string] $Crop,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use subtitle file'
        )]
        [string] $SubtitleFile,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Subtitles text scaling factor'
        )]
        [ValidateRange(10, 500)]
        [int] $SubtitleScale,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Subtitle language'
        )]
        [ValidateSet(
            'Afrikaans', 'Akan', 'Albanian', 'Amharic', 'Arabic', 'Armenian',
            'Azerbaijani', 'Basque', 'Belarusian', 'Bemba', 'Bengali', 'Bihari',
            'Bork, bork, bork!', 'Bosnian', 'Breton', 'Bulgarian', 'Cambodian',
            'Catalan', 'Cherokee', 'Chichewa', 'Chinese (Simplified)',
            'Chinese (Traditional)', 'Corsican', 'Croatian', 'Czech', 'Danish',
            'Dutch', 'Elmer Fudd', 'English', 'Esperanto', 'Estonian', 'Ewe',
            'Faroese', 'Filipino', 'Finnish', 'French', 'Frisian', 'Ga',
            'Galician', 'Georgian', 'German', 'Greek', 'Guarani', 'Gujarati',
            'Hacker', 'Haitian Creole', 'Hausa', 'Hawaiian', 'Hebrew', 'Hindi',
            'Hungarian', 'Icelandic', 'Igbo', 'Indonesian', 'Interlingua',
            'Irish', 'Italian', 'Japanese', 'Javanese', 'Kannada', 'Kazakh',
            'Kinyarwanda', 'Kirundi', 'Klingon', 'Kongo', 'Korean',
            'Krio (Sierra Leone)', 'Kurdish', 'Kurdish (Soranî)', 'Kyrgyz',
            'Laothian', 'Latin', 'Latvian', 'Lingala', 'Lithuanian', 'Lozi',
            'Luganda', 'Luo', 'Macedonian', 'Malagasy', 'Malay', 'Malayalam',
            'Maltese', 'Maori', 'Marathi', 'Mauritian Creole', 'Moldavian',
            'Mongolian', 'Montenegrin', 'Nepali', 'Nigerian Pidgin',
            'Northern Sotho', 'Norwegian', 'Norwegian (Nynorsk)', 'Occitan',
            'Oriya', 'Oromo', 'Pashto', 'Persian', 'Pirate', 'Polish',
            'Portuguese (Brazil)', 'Portuguese (Portugal)', 'Punjabi',
            'Quechua', 'Romanian', 'Romansh', 'Runyakitara', 'Russian',
            'Scots Gaelic', 'Serbian', 'Serbo-Croatian', 'Sesotho', 'Setswana',
            'Seychellois Creole', 'Shona', 'Sindhi', 'Sinhalese', 'Slovak',
            'Slovenian', 'Somali', 'Spanish', 'Spanish (Latin American)',
            'Sundanese', 'Swahili', 'Swedish', 'Tajik', 'Tamil', 'Tatar',
            'Telugu', 'Thai', 'Tigrinya', 'Tonga', 'Tshiluba', 'Tumbuka',
            'Turkish', 'Turkmen', 'Twi', 'Uighur', 'Ukrainian', 'Urdu',
            'Uzbek', 'Vietnamese', 'Welsh', 'Wolof', 'Xhosa', 'Yiddish',
            'Yoruba', 'Zulu')]
        [string] $SubtitleLanguage,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio language'
        )]
        [ValidateSet(
            'Afrikaans', 'Akan', 'Albanian', 'Amharic', 'Arabic', 'Armenian',
            'Azerbaijani', 'Basque', 'Belarusian', 'Bemba', 'Bengali', 'Bihari',
            'Bork, bork, bork!', 'Bosnian', 'Breton', 'Bulgarian', 'Cambodian',
            'Catalan', 'Cherokee', 'Chichewa', 'Chinese (Simplified)',
            'Chinese (Traditional)', 'Corsican', 'Croatian', 'Czech', 'Danish',
            'Dutch', 'Elmer Fudd', 'English', 'Esperanto', 'Estonian', 'Ewe',
            'Faroese', 'Filipino', 'Finnish', 'French', 'Frisian', 'Ga',
            'Galician', 'Georgian', 'German', 'Greek', 'Guarani', 'Gujarati',
            'Hacker', 'Haitian Creole', 'Hausa', 'Hawaiian', 'Hebrew', 'Hindi',
            'Hungarian', 'Icelandic', 'Igbo', 'Indonesian', 'Interlingua',
            'Irish', 'Italian', 'Japanese', 'Javanese', 'Kannada', 'Kazakh',
            'Kinyarwanda', 'Kirundi', 'Klingon', 'Kongo', 'Korean',
            'Krio (Sierra Leone)', 'Kurdish', 'Kurdish (Soranî)', 'Kyrgyz',
            'Laothian', 'Latin', 'Latvian', 'Lingala', 'Lithuanian', 'Lozi',
            'Luganda', 'Luo', 'Macedonian', 'Malagasy', 'Malay', 'Malayalam',
            'Maltese', 'Maori', 'Marathi', 'Mauritian Creole', 'Moldavian',
            'Mongolian', 'Montenegrin', 'Nepali', 'Nigerian Pidgin',
            'Northern Sotho', 'Norwegian', 'Norwegian (Nynorsk)', 'Occitan',
            'Oriya', 'Oromo', 'Pashto', 'Persian', 'Pirate', 'Polish',
            'Portuguese (Brazil)', 'Portuguese (Portugal)', 'Punjabi',
            'Quechua', 'Romanian', 'Romansh', 'Runyakitara', 'Russian',
            'Scots Gaelic', 'Serbian', 'Serbo-Croatian', 'Sesotho', 'Setswana',
            'Seychellois Creole', 'Shona', 'Sindhi', 'Sinhalese', 'Slovak',
            'Slovenian', 'Somali', 'Spanish', 'Spanish (Latin American)',
            'Sundanese', 'Swahili', 'Swedish', 'Tajik', 'Tamil', 'Tatar',
            'Telugu', 'Thai', 'Tigrinya', 'Tonga', 'Tshiluba', 'Tumbuka',
            'Turkish', 'Turkmen', 'Twi', 'Uighur', 'Ukrainian', 'Urdu',
            'Uzbek', 'Vietnamese', 'Welsh', 'Wolof', 'Xhosa', 'Yiddish',
            'Yoruba', 'Zulu')]
        [string] $AudioLanguage,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Preferred audio language'
        )]
        [ValidateSet(
            'Afrikaans', 'Akan', 'Albanian', 'Amharic', 'Arabic', 'Armenian',
            'Azerbaijani', 'Basque', 'Belarusian', 'Bemba', 'Bengali', 'Bihari',
            'Bork, bork, bork!', 'Bosnian', 'Breton', 'Bulgarian', 'Cambodian',
            'Catalan', 'Cherokee', 'Chichewa', 'Chinese (Simplified)',
            'Chinese (Traditional)', 'Corsican', 'Croatian', 'Czech', 'Danish',
            'Dutch', 'Elmer Fudd', 'English', 'Esperanto', 'Estonian', 'Ewe',
            'Faroese', 'Filipino', 'Finnish', 'French', 'Frisian', 'Ga',
            'Galician', 'Georgian', 'German', 'Greek', 'Guarani', 'Gujarati',
            'Hacker', 'Haitian Creole', 'Hausa', 'Hawaiian', 'Hebrew', 'Hindi',
            'Hungarian', 'Icelandic', 'Igbo', 'Indonesian', 'Interlingua',
            'Irish', 'Italian', 'Japanese', 'Javanese', 'Kannada', 'Kazakh',
            'Kinyarwanda', 'Kirundi', 'Klingon', 'Kongo', 'Korean',
            'Krio (Sierra Leone)', 'Kurdish', 'Kurdish (Soranî)', 'Kyrgyz',
            'Laothian', 'Latin', 'Latvian', 'Lingala', 'Lithuanian', 'Lozi',
            'Luganda', 'Luo', 'Macedonian', 'Malagasy', 'Malay', 'Malayalam',
            'Maltese', 'Maori', 'Marathi', 'Mauritian Creole', 'Moldavian',
            'Mongolian', 'Montenegrin', 'Nepali', 'Nigerian Pidgin',
            'Northern Sotho', 'Norwegian', 'Norwegian (Nynorsk)', 'Occitan',
            'Oriya', 'Oromo', 'Pashto', 'Persian', 'Pirate', 'Polish',
            'Portuguese (Brazil)', 'Portuguese (Portugal)', 'Punjabi',
            'Quechua', 'Romanian', 'Romansh', 'Runyakitara', 'Russian',
            'Scots Gaelic', 'Serbian', 'Serbo-Croatian', 'Sesotho', 'Setswana',
            'Seychellois Creole', 'Shona', 'Sindhi', 'Sinhalese', 'Slovak',
            'Slovenian', 'Somali', 'Spanish', 'Spanish (Latin American)',
            'Sundanese', 'Swahili', 'Swedish', 'Tajik', 'Tamil', 'Tatar',
            'Telugu', 'Thai', 'Tigrinya', 'Tonga', 'Tshiluba', 'Tumbuka',
            'Turkish', 'Turkmen', 'Twi', 'Uighur', 'Ukrainian', 'Urdu',
            'Uzbek', 'Vietnamese', 'Welsh', 'Wolof', 'Xhosa', 'Yiddish',
            'Yoruba', 'Zulu')]
        [string] $PreferredAudioLanguage,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'HTTP proxy'
        )]
        [string] $HttpProxy,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'HTTP proxy password'
        )]
        [string] $HttpProxyPassword,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Verbosity level'
        )]
        [ValidateRange(0, 2)]
        [int] $VerbosityLevel,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Subdirectory behavior'
        )]
        [ValidateSet('None', 'Collapse', 'Expand')]
        [string] $SubdirectoryBehavior,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Ignored extensions'
        )]
        [string] $IgnoredExtensions,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Path to VLC executable'
        )]
        [string] $VLCPath = "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe",
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Replay gain mode'
        )]
        [ValidateSet('None', 'Track', 'Album')]
        [string] $ReplayGainMode,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Replay gain preamp'
        )]
        [ValidateRange(-20.0, 20.0)]
        [float] $ReplayGainPreamp,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force detection of Dolby Surround'
        )]
        [ValidateSet('Auto', 'On', 'Off')]
        [string] $ForceDolbySurround,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio filters'
        )]
        [string[]] $AudioFilters,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio visualizations'
        )]
        [ValidateSet('None', 'Goom', 'ProjectM', 'Visual', 'GLSpectrum')]
        [string] $Visualization,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Deinterlace'
        )]
        [ValidateSet('Off', 'Automatic', 'On')]
        [string] $Deinterlace,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Deinterlace mode'
        )]
        [ValidateSet('Auto', 'Discard', 'Blend', 'Mean', 'Bob', 'Linear', 'X',
            'Yadif', 'Yadif2x', 'Phosphor', 'IVTC')]
        [string] $DeinterlaceMode,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Video filter module'
        )]
        [string[]] $VideoFilters,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Video filter modules'
        )]
        [string[]] $VideoFilterModules,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Modules'
        )]
        [string[]] $Modules,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio filter modules'
        )]
        [string[]] $AudioFilterModules,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio visualization mode'
        )]
        [ValidateSet('None', 'Goom', 'ProjectM', 'Visual', 'GLSpectrum')]
        [string] $AudioVisualization,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Preferred subtitle language'
        )]
        [string] $PreferredSubtitleLanguage,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Ignored file extensions'
        )]
        [string] $IgnoredFileExtensions,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Additional arguments'
        )]
        [string] $Arguments,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Include alternate data streams in search results'
        )]
        [Alias('ads')]
        [switch] $IncludeAlternateFileStreams,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only include video files in the playlist'
        )]
        [switch] $OnlyVideos,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only include audio files in the playlist'
        )]
        [switch] $OnlyAudio,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only include pictures in the playlist'
        )]
        [switch] $OnlyPictures,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Additionally include videos in the playlist'
        )]
        [switch] $IncludeVideos,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Additionally include audio files in the playlist'
        )]
        [switch] $IncludeAudio,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Additionally include pictures in the playlist'
        )]
        [switch] $IncludePictures,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the top side of the screen'
        )]
        [switch] $Top,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch] $Centered,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sends F11 to the window'
        )]
        [Alias('fs')]
        [switch]$FullScreen,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Always on top'
        )]
        [switch] $AlwaysOnTop,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Play files randomly forever'
        )]
        [Alias('Shuffle')]
        [switch] $Random,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Repeat all'
        )]
        [switch] $Loop,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Repeat current item'
        )]
        [switch] $Repeat,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Start paused'
        )]
        [switch] $StartPaused,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Play and exit'
        )]
        [switch] $PlayAndExit,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable audio'
        )]
        [switch] $DisableAudio,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable subtitles'
        )]
        [switch] $DisableSubtitles,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Video Auto Scaling'
        )]
        [switch] $AutoScale,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Increase the priority of the process'
        )]
        [switch] $HighPriority,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable time stretching audio'
        )]
        [switch] $EnableTimeStretch,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open new VLC mediaplayer instance'
        )]
        [switch] $NewWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable video wallpaper mode'
        )]
        [switch] $EnableWallpaperMode,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable audio time stretching'
        )]
        [switch] $EnableAudioTimeStretch,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Close the VLC media player window'
        )]
        [switch] $Close,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will either set the window fullscreen on a ' +
                'different monitor than Powershell, or side by side ' +
                'with Powershell on the same monitor')
        )]
        [Alias('sbs')]
        [switch]$SideBySide,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the VLC window after opening'
        )]
        [Alias('fw', 'focus')]
        [switch] $FocusWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the VLC window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window'
        )]
        [switch] $Maximize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restores PowerShell window focus after opening VLC.'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use alternative settings stored in session for AI preferences'
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear alternative settings stored in session for AI preferences'
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Store settings only in persistent preferences without affecting session'
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Gets or sets the case-sensitivity for files and directories'
        )]
        [Alias('casing', 'CaseSearchMaskMatching')]
        [System.IO.MatchCasing] $CaseNameMatching = [System.IO.MatchCasing]::PlatformDefault,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum recursion depth for directory traversal. 0 means unlimited.'
        )]
        [Alias('md', 'depth', 'maxdepth')]
        [int] $MaxRecursionDepth = 0,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Exclude files or directories matching these wildcard patterns (e.g., *.tmp, *\\bin\\*).'
        )]
        [Alias('skiplike')]
        [string[]] $Exclude = @('*\\.git\\*'),
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Returns the files found by the search'
        )]
        [Alias('pt')]
        [switch]$PassThru,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Returns the files found by the search without opening VLC'
        )]
        [switch] $PassThruNoOpen,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Returns the window helper for each process'
        )]
        [switch] $PassThruWindow
    )

    begin {

        # set comfortable default that can be overridden by user
        $RestoreFocus = $PSBoundParameters.ContainsKey('RestoreFocus') ?
        $RestoreFocus : $true;

        $SideBySide = $PSBoundParameters.ContainsKey('SideBySide') ?
        $SideBySide : (GenXdev\Get-MonitorCount) -lt 2;

        $FullScreen = $PSBoundParameters.ContainsKey('FullScreen') ?
        $FullScreen : (-not $SideBySide);

        # expand the playlist path and ensure directory exists for m3u file
        $PlaylistPath = GenXdev\Expand-Path $PlaylistPath `
            -CreateDirectory `
            -DeleteExistingFile

        # copy parameters from current function to find-item function parameters
        # this maintains consistency in parameter handling across functions
        $invocationParams = GenXdev\Copy-IdenticalParamValues `
            -FunctionName 'GenXdev\Find-Item' `
            -BoundParameters $PSBoundParameters `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

        # ensure we get file objects back instead of just paths for processing
        $invocationParams.PassThru = $true

        # determine which media categories to search for based on user filters
        $invocationParams.Category = @(
            (
                @($OnlyVideos ? 'Videos' : (
                        $OnlyAudio ? 'Music' : (
                            $OnlyPictures ? 'Pictures' : @()
                        )
                    )) +
                ($IncludeVideos ? 'Videos' : @()) +
                ($IncludeAudio ? 'Music' : @()) +
                ($IncludePictures ? 'Pictures' : @())
            ) |
                Microsoft.PowerShell.Utility\Select-Object -Unique
        )

        # default to all media types if no specific category filters applied
        if ($invocationParams.Category.Count -eq 0) {

            $invocationParams.Category = @('Videos', 'Music', 'Pictures')
        }

        # log the search parameters for troubleshooting purposes
        Microsoft.PowerShell.Utility\Write-Verbose ('Searching for files with ' +
            'parameters: ' + ($invocationParams.Keys -join ', '))

        # log the playlist location for debugging and troubleshooting
        Microsoft.PowerShell.Utility\Write-Verbose ('Creating playlist at: ' +
            $playlistPath)

        # initialize stream variables for safe disposal in finally block
        $fileStream = $null
        $streamWriter = $null

        # create file stream for writing playlist with proper encoding and buffering
        $fileStream = [System.IO.FileStream]::new(
            $PlaylistPath,
            [System.IO.FileMode]::Create,
            [System.IO.FileAccess]::Write,
            [System.IO.FileShare]::Read
        )

        # create stream writer with utf-8 encoding for proper m3u compatibility
        $streamWriter = [System.IO.StreamWriter]::new(
            $fileStream,
            [System.Text.Encoding]::UTF8
        )

        # write the m3u header to start the playlist file
        $streamWriter.WriteLine("#EXTM3U")

        # initialize collections for managing input and found files
        [System.Collections.Generic.List[System.IO.FileInfo]] $inputFiles = @()
        [System.Collections.Generic.List[System.IO.FileInfo]] $allFiles = @()
    }

    process {

        # log current parameter set name for debugging pipeline behavior
        Microsoft.PowerShell.Utility\Write-Verbose (
            "process: Detected paramset : $($PSCmdlet.ParameterSetName)")

        # skip processing if no input received from pipeline
        if ($null -eq $Input) { return }

        # recursive function to process various input object types
        function processObject($inputObj) {

            # log the type of object being processed for troubleshooting
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Processing input object of type: $($inputObj.GetType().FullName)")

            # directly add fileinfo objects to the final collection
            if ($inputObj -is [System.IO.FileInfo]) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Adding FileInfo to allFiles: $($inputObj.FullName)")

                $null = $allFiles.Add($inputObj)
                return
            }

            # add strings and directory objects to search collection
            if ($inputObj -is [string] -or $inputObj -is [System.IO.DirectoryInfo]) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Adding String or DirectoryInfo to inputFiles: $inputObj")

                $null = $inputFiles.Add($inputObj)
                return
            }

            # recursively process enumerable collections
            if ($inputObj -is [System.Collections.IEnumerable]) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing IEnumerable, iterating through items...")

                foreach ($item in $inputObj) {

                    processObject($item)
                }
                return
            }

            # handle any other object types by forcing array conversion
            @($inputObj) |
                Microsoft.PowerShell.Core\ForEach-Object {

                    # avoid infinite recursion for the same object
                    if ($_ -ne $inputObj) {

                        processObject($_)
                    }
                }
        }

        # process the pipeline input through our recursive handler
        processObject($Input)
    }

    end {
        Microsoft.PowerShell.Utility\Write-Verbose "end: Detected paramset : $($PSCmdlet.ParameterSetName)"

        try {

            # Only use Find-Item if we're in Default parameter set (no pipeline input)
            # OR if we received directories/strings that need to be searched
            # BUT NOT if we already have FileInfo objects from pipeline
            $shouldUseFindItem = ($PSBoundParameters.ContainsKey("Name") -or
                ($inputFiles.Count -gt 0) -or ($allFiles.Count -eq 0))

            if ($shouldUseFindItem) {

                Microsoft.PowerShell.Utility\Write-Verbose "** Performing search for provided names.`r`n$($invocationParams | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 3)"

                Microsoft.PowerShell.Utility\Write-Verbose ($InvocationParams | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 3)

                if ($inputFiles.Count -gt 0) {

                    Microsoft.PowerShell.Utility\Write-Verbose "Processing $($inputFiles.Count) input files or directories."

                    # find all matching files and sort them alphabetically by full path
                    $InputFiles | GenXdev\Find-Item @invocationParams | Microsoft.PowerShell.Core\ForEach-Object {

                        $null = $allFiles.Add($_)
                    }
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose "No input files or directories provided, searching based on Names parameter only.";

                    # find all matching files and sort them alphabetically by full path
                    GenXdev\Find-Item @invocationParams | Microsoft.PowerShell.Core\ForEach-Object {

                        $null = $allFiles.Add($_)
                    }
                }
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Found $($allFiles.Count) files matching criteria."

            $allFiles | Microsoft.PowerShell.Utility\Sort-Object -Property FullName | Microsoft.PowerShell.Core\ForEach-Object {

                # log each file being added to the playlist for troubleshooting
                Microsoft.PowerShell.Utility\Write-Verbose ('Adding file to ' +
                    'playlist: ' + $_.FullName)

                # create more readable display names by cleaning up file names
                $displayName = $_.Name.Replace('_', ' ').Replace('.', ' ').Replace('  ', ' ')

                # build m3u format entry with duration (-1 = unknown) and file path
                # extinf format: #extinf:duration,title followed by path on next line
                $streamWriter.WriteLine("#EXTINF:-1, $displayName")
                $streamWriter.WriteLine($_.FullName)

                if ($PassThru) {

                    Microsoft.PowerShell.Utility\Write-Output $_
                }
            }
        }
        catch {

            # log any errors encountered during playlist creation for troubleshooting
            Microsoft.PowerShell.Utility\Write-Error (
                'Error creating playlist: ' + $_.Exception.Message)
            return
        }
        finally {

            # ensure the stream writer is properly disposed to flush all data
            if ($streamWriter) {

                $streamWriter.Flush()
                $streamWriter.Dispose()
                $streamWriter = $null
            }

            # ensure the file stream is properly disposed to release file handle
            if ($fileStream) {

                $fileStream.Dispose()
                $fileStream = $null
            }
        }

        # return early if user only wants file list without opening vlc
        if ($PassThruNoOpen) {

            return
        }

        # confirm playlist creation was successful for troubleshooting
        Microsoft.PowerShell.Utility\Write-Verbose ('Playlist created ' +
            'successfully')

        # ensure no existing vlc instances are running to avoid conflicts
        Microsoft.PowerShell.Utility\Write-Verbose 'Stopping existing VLC processes'

        # forcibly terminate any running vlc processes to ensure clean launch
        $null = Microsoft.PowerShell.Management\Get-Process vlc `
            -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Management\Stop-Process -Force

        # copy all relevant parameters from current function to vlc media player
        # this ensures consistent parameter handling and reduces code duplication
        $invocationParams = GenXdev\Copy-IdenticalParamValues `
            -FunctionName 'GenXdev\Open-VlcMediaPlayer' `
            -BoundParameters $PSBoundParameters `
        (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Core\Where-Object {
                    $_.Value -isnot [int] -or $_.Value -ne 0
                })

        # configure specific parameters for vlc media player invocation
        $invocationParams.Path = $playlistPath        # use our generated playlist
        $invocationParams.PassThru = $true            # return window helper object

        # log that we're about to launch vlc media player with playlist
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting VLC player'

        # launch vlc with all configured parameters and capture the window helper
        # for potential manipulation if passthru window is requested
        $vlcWindowHelper = GenXdev\Open-VlcMediaPlayer @invocationParams

        # return the window helper object only if explicitly requested via passthru
        # this allows further manipulation of the vlc window programmatically
        if ($PassThruWindow) {

            Microsoft.PowerShell.Utility\Write-Output $vlcWindowHelper
        }
    }
}
################################################################################