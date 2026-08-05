###############################################################################
<#
.SYNOPSIS
Launches and controls VLC Media Player with extensive configuration options.

.DESCRIPTION
This function provides a comprehensive interface to launch and control VLC
Media Player with support for window positioning, monitor selection, playback
settings, audio and video filters, subtitle handling, multiple language
support, network proxy settings, and advanced performance options. The
function can automatically install VLC if not present and provides extensive
customization for media playbook scenarios. It integrates seamlessly with the
GenXdev window management system and supports keyboard input automation through
the Send-Key functionality.

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

.PARAMETER Path
The media file(s) or URL(s) to open in VLC. Supports local files, network

.PARAMETER Width
The initial width of the VLC window in pixels. Used for precise window sizing.

.PARAMETER Height
The initial height of the VLC window in pixels. Used for precise window sizing.

.PARAMETER X
The initial X position of the VLC window on the screen in pixels.

.PARAMETER Y
The initial Y position of the VLC window on the screen in pixels.

.PARAMETER KeysToSend
Keystrokes to send to the VLC Player Window after opening. Uses the same
syntax as the GenXdev\Send-Key function for automation purposes.

.PARAMETER SendKeyEscape
Escape control characters and modifiers when sending keys to VLC to ensure
literal key interpretation.

.PARAMETER SendKeyUseShiftEnter
Use Shift+Enter instead of Enter when sending keys to VLC for line breaks.

.PARAMETER SendKeyDelayMilliSeconds
Delay between different input strings in milliseconds when sending keys to
ensure reliable delivery.

.PARAMETER SendKeyHoldKeyboardFocus
Hold keyboard focus on the VLC window after sending keys instead of returning
focus to PowerShell.

.PARAMETER Monitor
The monitor to use for VLC display. 0 = default monitor, -1 = discard
positioning, >0 = specific monitor number.

.PARAMETER AspectRatio
Source aspect ratio for video display to ensure correct proportions.

.PARAMETER Crop
Video cropping settings to adjust the visible video area.

.PARAMETER SubtitleFile
Path to subtitle file to use with the media for caption display.

.PARAMETER SubtitleScale
Subtitles text scaling factor percentage for readability adjustment.

.PARAMETER SubtitleLanguage
Subtitle language preference for multi-language content selection.

.PARAMETER AudioLanguage
Audio language preference for multi-language content selection.

.PARAMETER PreferredAudioLanguage
Preferred audio language for multi-language content when multiple tracks exist.

.PARAMETER HttpProxy
HTTP proxy server for network streams when behind corporate firewalls.

.PARAMETER HttpProxyPassword
HTTP proxy password for authentication when required by proxy server.

.PARAMETER VerbosityLevel
Verbosity level for VLC output to control logging detail.

.PARAMETER SubdirectoryBehavior
How to handle subdirectories in playlists for folder-based media organization.

.PARAMETER IgnoredExtensions
File extensions to ignore when building playlists to filter unwanted files.

.PARAMETER VLCPath
Custom path to VLC executable when installed in non-standard location.

.PARAMETER ReplayGainMode
Replay gain mode for audio normalization to maintain consistent volume levels.

.PARAMETER ReplayGainPreamp
Replay gain preamp value in decibels for volume adjustment.

.PARAMETER ForceDolbySurround
Force detection of Dolby Surround audio for enhanced audio processing.

.PARAMETER AudioFilters
Audio filters to apply during playback for sound enhancement.

.PARAMETER Visualization
Audio visualization type to display for audio-only content.

.PARAMETER Deinterlace
Deinterlace video content to improve quality of interlaced video.

.PARAMETER DeinterlaceMode
Deinterlace algorithm to use for optimal video quality processing.

.PARAMETER VideoFilters
Video filters to apply during playback for visual enhancement.

.PARAMETER VideoFilterModules
Video filter modules to load for advanced video processing.

.PARAMETER Modules
Additional modules to load for extended VLC functionality.

.PARAMETER AudioFilterModules
Audio filter modules to load for advanced audio processing.

.PARAMETER AudioVisualization
Audio visualization mode for visual representation of audio content.

.PARAMETER PreferredSubtitleLanguage
Preferred subtitle language for automatic subtitle selection.

.PARAMETER IgnoredFileExtensions
File extensions to ignore during media file processing.

.PARAMETER Arguments
Additional command-line arguments to pass to VLC for custom configuration.

.PARAMETER NoBorders
Removes window borders for a cleaner, distraction-free viewing experience.

.PARAMETER Left
Places VLC window on left side of screen for side-by-side arrangements.

.PARAMETER Right
Places VLC window on right side of screen for side-by-side arrangements.

.PARAMETER Top
Places VLC window on top side of screen for vertical arrangements.

.PARAMETER Bottom
Places VLC window on bottom side of screen for vertical arrangements.

.PARAMETER Centered
Centers the VLC window on screen for optimal viewing position.

.PARAMETER Fullscreen
Maximizes the VLC window to fullscreen for immersive viewing.

.PARAMETER PassThru
Returns the window helper object for further manipulation and control.

.PARAMETER AlwaysOnTop
Keeps the VLC window always on top of other windows for persistent visibility.

.PARAMETER Random
Play files randomly forever in shuffle mode for varied playback order.

.PARAMETER Loop
Repeat all files in the playlist continuously for extended viewing.

.PARAMETER Repeat
Repeat current item continuously for focused content consumption.

.PARAMETER StartPaused
Start playback in paused state for manual playback control.

.PARAMETER PlayAndExit
Play media and exit VLC when finished for automated batch processing.

.PARAMETER DisableAudio
Disable audio output completely for silent video playback.

.PARAMETER DisableSubtitles
Disable all subtitles for clean video display without captions.

.PARAMETER AutoScale
Enable automatic video scaling for optimal display size adjustment.

.PARAMETER HighPriority
Increase the priority of the VLC process for better performance.

.PARAMETER EnableTimeStretch
Enable time stretching audio during playback for speed adjustments.

.PARAMETER NewWindow
Open new VLC mediaplayer instance instead of reusing existing windows.

.PARAMETER EnableWallpaperMode
Enable video wallpaper mode for desktop background video display.

.PARAMETER EnableAudioTimeStretch
Enable audio time stretching for playback speed modifications.

.PARAMETER Close
Close the VLC media player window and terminate the process.

.PARAMETER SideBySide
Will either set the window fullscreen on a different monitor than PowerShell,
or side by side with PowerShell on the same monitor for workflow optimization.

.PARAMETER FocusWindow
Focus the VLC window after opening for immediate interaction readiness.

.PARAMETER SetForeground
Set the VLC window to foreground after opening for visibility assurance.

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER RestoreFocus
Restore PowerShell window focus after opening VLC for continued workflow.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences during current
session only.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences to reset
configuration.

.PARAMETER SkipSession
Store settings only in persistent preferences without affecting session to
maintain separation.

.EXAMPLE
Open-VlcMediaPlayer -Path "video.mp4" -Fullscreen -Monitor 0
Opens a video file in fullscreen mode on the primary monitor for immersive
viewing experience.

.EXAMPLE
vlc "video.mp4" -fs -m 0
Short form using aliases to open video fullscreen on monitor 0 with minimal
typing required.

.EXAMPLE
Open-VlcMediaPlayer -Path "movie.mkv" -SubtitleFile "movie.srt" -AudioLanguage "English"
Opens a movie with external subtitles and specific audio language for
enhanced viewing with captions.
#>
###############################################################################
function Open-VlcMediaPlayer {

    [CmdletBinding()]
    [Alias('vlc')]

    param(
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The media file(s) or URL(s) to open in VLC'
        )]
        [string[]]$Path,
        ###########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width = -1,
        ###########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height = -1,
        ###########################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'The initial X position of the window'
        )]
        [int] $X = -999999,
        ###########################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the window'
        )]
        [int] $Y = -999999,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = ('Keystrokes to send to the VLC Player Window, ' +
                'see documentation for cmdlet GenXdev\Send-Key')
        )]
        [string[]] $KeysToSend = @(),
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys to VLC'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys to VLC'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay between different input strings in milliseconds when sending keys to VLC'
        )]
        [ValidateRange(0, [int]::MaxValue)]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds = 50,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on the VLC window after sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ###########################################################################
        [Alias('m', 'mon')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The monitor to use, 0 = default, -1 is discard'
        )]
        [int] $Monitor = -1,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Source aspect ratio'
        )]
        [string]$AspectRatio,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Video cropping'
        )]
        [string]$Crop,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use subtitle file'
        )]
        [string]$SubtitleFile,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Subtitles text scaling factor'
        )]
        [ValidateRange(10, 500)]
        [int]$SubtitleScale,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Subtitle language'
        )]
        [ValidateSet(
            'Afrikaans', 'Akan', 'Albanian', 'Amharic', 'Arabic', 'Armenian', 'Azerbaijani', 'Basque', 'Belarusian',
            'Bemba', 'Bengali', 'Bihari', 'Bork, bork, bork!', 'Bosnian', 'Breton', 'Bulgarian', 'Cambodian',
            'Catalan', 'Cherokee', 'Chichewa', 'Chinese (Simplified)', 'Chinese (Traditional)', 'Corsican',
            'Croatian', 'Czech', 'Danish', 'Dutch', 'Elmer Fudd', 'English', 'Esperanto', 'Estonian', 'Ewe',
            'Faroese', 'Filipino', 'Finnish', 'French', 'Frisian', 'Ga', 'Galician', 'Georgian', 'German', 'Greek',
            'Guarani', 'Gujarati', 'Hacker', 'Haitian Creole', 'Hausa', 'Hawaiian', 'Hebrew', 'Hindi', 'Hungarian',
            'Icelandic', 'Igbo', 'Indonesian', 'Interlingua', 'Irish', 'Italian', 'Japanese', 'Javanese', 'Kannada',
            'Kazakh', 'Kinyarwanda', 'Kirundi', 'Klingon', 'Kongo', 'Korean', 'Krio (Sierra Leone)', 'Kurdish',
            'Kurdish (Soranî)', 'Kyrgyz', 'Laothian', 'Latin', 'Latvian', 'Lingala', 'Lithuanian', 'Lozi', 'Luganda',
            'Luo', 'Macedonian', 'Malagasy', 'Malay', 'Malayalam', 'Maltese', 'Maori', 'Marathi', 'Mauritian Creole',
            'Moldavian', 'Mongolian', 'Montenegrin', 'Nepali', 'Nigerian Pidgin', 'Northern Sotho', 'Norwegian',
            'Norwegian (Nynorsk)', 'Occitan', 'Oriya', 'Oromo', 'Pashto', 'Persian', 'Pirate', 'Polish',
            'Portuguese (Brazil)', 'Portuguese (Portugal)', 'Punjabi', 'Quechua', 'Romanian', 'Romansh', 'Runyakitara',
            'Russian', 'Scots Gaelic', 'Serbian', 'Serbo-Croatian', 'Sesotho', 'Setswana', 'Seychellois Creole',
            'Shona', 'Sindhi', 'Sinhalese', 'Slovak', 'Slovenian', 'Somali', 'Spanish', 'Spanish (Latin American)',
            'Sundanese', 'Swahili', 'Swedish', 'Tajik', 'Tamil', 'Tatar', 'Telugu', 'Thai', 'Tigrinya', 'Tonga',
            'Tshiluba', 'Tumbuka', 'Turkish', 'Turkmen', 'Twi', 'Uighur', 'Ukrainian', 'Urdu', 'Uzbek', 'Vietnamese',
            'Welsh', 'Wolof', 'Xhosa', 'Yiddish', 'Yoruba', 'Zulu')]
        [string]$SubtitleLanguage,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio language'
        )]
        [ValidateSet(
            'Afrikaans', 'Akan', 'Albanian', 'Amharic', 'Arabic', 'Armenian', 'Azerbaijani', 'Basque', 'Belarusian',
            'Bemba', 'Bengali', 'Bihari', 'Bork, bork, bork!', 'Bosnian', 'Breton', 'Bulgarian', 'Cambodian',
            'Catalan', 'Cherokee', 'Chichewa', 'Chinese (Simplified)', 'Chinese (Traditional)', 'Corsican',
            'Croatian', 'Czech', 'Danish', 'Dutch', 'Elmer Fudd', 'English', 'Esperanto', 'Estonian', 'Ewe',
            'Faroese', 'Filipino', 'Finnish', 'French', 'Frisian', 'Ga', 'Galician', 'Georgian', 'German', 'Greek',
            'Guarani', 'Gujarati', 'Hacker', 'Haitian Creole', 'Hausa', 'Hawaiian', 'Hebrew', 'Hindi', 'Hungarian',
            'Icelandic', 'Igbo', 'Indonesian', 'Interlingua', 'Irish', 'Italian', 'Japanese', 'Javanese', 'Kannada',
            'Kazakh', 'Kinyarwanda', 'Kirundi', 'Klingon', 'Kongo', 'Korean', 'Krio (Sierra Leone)', 'Kurdish',
            'Kurdish (Soranî)', 'Kyrgyz', 'Laothian', 'Latin', 'Latvian', 'Lingala', 'Lithuanian', 'Lozi', 'Luganda',
            'Luo', 'Macedonian', 'Malagasy', 'Malay', 'Malayalam', 'Maltese', 'Maori', 'Marathi', 'Mauritian Creole',
            'Moldavian', 'Mongolian', 'Montenegrin', 'Nepali', 'Nigerian Pidgin', 'Northern Sotho', 'Norwegian',
            'Norwegian (Nynorsk)', 'Occitan', 'Oriya', 'Oromo', 'Pashto', 'Persian', 'Pirate', 'Polish',
            'Portuguese (Brazil)', 'Portuguese (Portugal)', 'Punjabi', 'Quechua', 'Romanian', 'Romansh', 'Runyakitara',
            'Russian', 'Scots Gaelic', 'Serbian', 'Serbo-Croatian', 'Sesotho', 'Setswana', 'Seychellois Creole',
            'Shona', 'Sindhi', 'Sinhalese', 'Slovak', 'Slovenian', 'Somali', 'Spanish', 'Spanish (Latin American)',
            'Sundanese', 'Swahili', 'Swedish', 'Tajik', 'Tamil', 'Tatar', 'Telugu', 'Thai', 'Tigrinya', 'Tonga',
            'Tshiluba', 'Tumbuka', 'Turkish', 'Turkmen', 'Twi', 'Uighur', 'Ukrainian', 'Urdu', 'Uzbek', 'Vietnamese',
            'Welsh', 'Wolof', 'Xhosa', 'Yiddish', 'Yoruba', 'Zulu')]
        [string]$AudioLanguage,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Preferred audio language'
        )]
        [ValidateSet(
            'Afrikaans', 'Akan', 'Albanian', 'Amharic', 'Arabic', 'Armenian', 'Azerbaijani', 'Basque', 'Belarusian',
            'Bemba', 'Bengali', 'Bihari', 'Bork, bork, bork!', 'Bosnian', 'Breton', 'Bulgarian', 'Cambodian',
            'Catalan', 'Cherokee', 'Chichewa', 'Chinese (Simplified)', 'Chinese (Traditional)', 'Corsican',
            'Croatian', 'Czech', 'Danish', 'Dutch', 'Elmer Fudd', 'English', 'Esperanto', 'Estonian', 'Ewe',
            'Faroese', 'Filipino', 'Finnish', 'French', 'Frisian', 'Ga', 'Galician', 'Georgian', 'German', 'Greek',
            'Guarani', 'Gujarati', 'Hacker', 'Haitian Creole', 'Hausa', 'Hawaiian', 'Hebrew', 'Hindi', 'Hungarian',
            'Icelandic', 'Igbo', 'Indonesian', 'Interlingua', 'Irish', 'Italian', 'Japanese', 'Javanese', 'Kannada',
            'Kazakh', 'Kinyarwanda', 'Kirundi', 'Klingon', 'Kongo', 'Korean', 'Krio (Sierra Leone)', 'Kurdish',
            'Kurdish (Soranî)', 'Kyrgyz', 'Laothian', 'Latin', 'Latvian', 'Lingala', 'Lithuanian', 'Lozi', 'Luganda',
            'Luo', 'Macedonian', 'Malagasy', 'Malay', 'Malayalam', 'Maltese', 'Maori', 'Marathi', 'Mauritian Creole',
            'Moldavian', 'Mongolian', 'Montenegrin', 'Nepali', 'Nigerian Pidgin', 'Northern Sotho', 'Norwegian',
            'Norwegian (Nynorsk)', 'Occitan', 'Oriya', 'Oromo', 'Pashto', 'Persian', 'Pirate', 'Polish',
            'Portuguese (Brazil)', 'Portuguese (Portugal)', 'Punjabi', 'Quechua', 'Romanian', 'Romansh', 'Runyakitara',
            'Russian', 'Scots Gaelic', 'Serbian', 'Serbo-Croatian', 'Sesotho', 'Setswana', 'Seychellois Creole',
            'Shona', 'Sindhi', 'Sinhalese', 'Slovak', 'Slovenian', 'Somali', 'Spanish', 'Spanish (Latin American)',
            'Sundanese', 'Swahili', 'Swedish', 'Tajik', 'Tamil', 'Tatar', 'Telugu', 'Thai', 'Tigrinya', 'Tonga',
            'Tshiluba', 'Tumbuka', 'Turkish', 'Turkmen', 'Twi', 'Uighur', 'Ukrainian', 'Urdu', 'Uzbek', 'Vietnamese',
            'Welsh', 'Wolof', 'Xhosa', 'Yiddish', 'Yoruba', 'Zulu')]
        [string]$PreferredAudioLanguage,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'HTTP proxy'
        )]
        [string]$HttpProxy,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'HTTP proxy password'
        )]
        [string]$HttpProxyPassword,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Verbosity level'
        )]
        [ValidateRange(0, 2)]
        [int]$VerbosityLevel,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Subdirectory behavior'
        )]
        [ValidateSet('None', 'Collapse', 'Expand')]
        [string]$SubdirectoryBehavior,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Ignored extensions'
        )]
        [string]$IgnoredExtensions,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Path to VLC executable'
        )]
        [string]$VLCPath = "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe",
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Replay gain mode'
        )]
        [ValidateSet('None', 'Track', 'Album')]
        [string]$ReplayGainMode,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Replay gain preamp'
        )]
        [ValidateRange(-20.0, 20.0)]
        [float]$ReplayGainPreamp,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force detection of Dolby Surround'
        )]
        [ValidateSet('Auto', 'On', 'Off')]
        [string]$ForceDolbySurround,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio filters'
        )]
        [string[]]$AudioFilters,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio visualizations'
        )]
        [ValidateSet('None', 'Goom', 'ProjectM', 'Visual', 'GLSpectrum')]
        [string]$Visualization,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Deinterlace'
        )]
        [ValidateSet('Off', 'Automatic', 'On')]
        [string]$Deinterlace,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Deinterlace mode'
        )]
        [ValidateSet('Auto', 'Discard', 'Blend', 'Mean', 'Bob', 'Linear', 'X', 'Yadif', 'Yadif2x', 'Phosphor', 'IVTC')]
        [string]$DeinterlaceMode,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Video filter module'
        )]
        [string[]]$VideoFilters,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Video filter modules'
        )]
        [string[]]$VideoFilterModules,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Modules'
        )]
        [string[]]$Modules,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio filter modules'
        )]
        [string[]]$AudioFilterModules,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Audio visualization mode'
        )]
        [ValidateSet('None', 'Goom', 'ProjectM', 'Visual', 'GLSpectrum')]
        [string]$AudioVisualization,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Preferred subtitle language'
        )]
        [string]$PreferredSubtitleLanguage,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Ignored file extensions'
        )]
        [string]$IgnoredFileExtensions,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Additional arguments'
        )]
        [string]$Arguments,
        ###########################################################################
        [Alias('nb')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [switch] $NoBorders,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the top side of the screen'
        )]
        [switch] $Top,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch] $Centered,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Sends F11 to the window'
        )]
        [Alias('fs')]
        [switch]$FullScreen,

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Returns the window helper for each process'
        )]
        [Alias('pt')]
        [switch]$PassThru,

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Always on top'
        )]
        [switch]$AlwaysOnTop,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Play files randomly forever'
        )]
        [Alias('Shuffle')]
        [switch]$Random,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Repeat all'
        )]
        [switch]$Loop,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Repeat current item'
        )]
        [switch]$Repeat,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Start paused'
        )]
        [switch]$StartPaused,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Play and exit'
        )]
        [switch]$PlayAndExit,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable audio'
        )]
        [switch]$DisableAudio,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable subtitles'
        )]
        [switch]$DisableSubtitles,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Video Auto Scaling'
        )]
        [switch]$AutoScale,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Increase the priority of the process'
        )]
        [switch]$HighPriority,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable time stretching audio'
        )]
        [switch]$EnableTimeStretch,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open new VLC mediaplayer instance'
        )]
        [switch] $NewWindow,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable video wallpaper mode'
        )]
        [switch]$EnableWallpaperMode,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Enable audio time stretching'
        )]
        [switch]$EnableAudioTimeStretch,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Close the VLC media player window'
        )]
        [switch] $Close,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will either set the window fullscreen on a different monitor than Powershell, or ' +
            'side by side with Powershell on the same monitor'
        )]
        [Alias('sbs')]
        [switch]$SideBySide,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the VLC window after opening'
        )]
        [Alias('fw', 'focus')]
        [switch] $FocusWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the VLC window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window'
        )]
        [switch] $Maximize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus after opening VLC'
        )]
        [Alias('rf', 'bg')]
        [switch]$RestoreFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use alternative settings stored in session for AI preferences'
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear alternative settings stored in session for AI preferences'
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Store settings only in persistent preferences without affecting session'
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ###########################################################################
    )

    begin {

        # exit early if only closing vlc windows
        if ($Close) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Closing VLC windows'

            # stop all vlc processes
            Microsoft.PowerShell.Management\Get-Process vlc `
                -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Management\Stop-Process -Force

            return
        }

        $positioningParams = @(
            "Monitor",
            "NoBorders",
            "Width",
            "Height",
            "X",
            "Y",
            "Left",
            "Right",
            "Top",
            "Bottom",
            "Centered",
            "Fullscreen",
            "SideBySide",
            "FocusWindow",
            #            "RestoreFocus",
            "SetForeground",
            "Minimize",
            "Maximize",
            "KeysToSend",
            "SendKeyEscape",
            "SendKeyHoldKeyboardFocus",
            "SendKeyUseShiftEnter",
            "SendKeyDelayMilliSeconds"
        );

        $haveOnlyPositioningParams = $true;
        foreach ($param in $PSBoundParameters.Keys) {
            if ($positioningParams -notcontains $param) {
                $haveOnlyPositioningParams = $false;
                break;
            }
        }

        if (-not $PSBoundParameters.ContainsKey('Monitor')) {
            $Monitor = -1
            $PSBoundParameters['Monitor'] = $Monitor
        }

        # Check if VLC is already running and we have no positioning parameters (just focus)
        $vlcWindow = GenXdev\Get-Window -ProcessName vlc -ErrorAction SilentlyContinue
        $hasPositioningParams = $PSBoundParameters.Keys | Microsoft.PowerShell.Core\Where-Object {
            $_ -in $positioningParams
        }
        $hasNonPositioningParams = $PSBoundParameters.Keys | Microsoft.PowerShell.Core\Where-Object {
            $_ -notin $positioningParams
        }

        # If VLC is running and we only have positioning params, just focus without repositioning
        if (($null -ne $vlcWindow) -and (-not $hasNonPositioningParams)) {
            Microsoft.PowerShell.Utility\Write-Verbose 'VLC already running with only positioning params, just focusing window without repositioning'

            # Just focus the existing VLC window without any repositioning
            GenXdev\Set-WindowPosition -WindowHelper $vlcWindow -FocusWindow -SetForeground

            return
        }

        # If VLC is running and we have non-positioning params, skip window positioning entirely
        $skipWindowPositioning = ($null -ne $vlcWindow) -and $hasNonPositioningParams -and (-not $hasPositioningParams)

        if ($haveOnlyPositioningParams) {

            $params = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Set-WindowPosition' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            # Only add fullscreen keystroke if user explicitly requested Fullscreen
            # Don't use $FullScreen variable here as it may be set by default logic later
            if ($PSBoundParameters.ContainsKey('Fullscreen') -and $Fullscreen) {
                $params.KeysToSend = @("f") + $KeysToSend
                $params.RestoreFocus = $true
            }

            if ($params.ContainsKey(("KeysToSend"))) {

                $null = $params.Remove("KeysToSend")
            }

            GenXdev\Set-WindowPosition @params -ProcessName 'vlc'

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Only positioning parameters specified, exiting...';
            return;
        }

        # ensure vlc is installed and install if needed
        if (-not (Microsoft.PowerShell.Management\Test-Path `
                    -LiteralPath "${env:ProgramFiles}\VideoLAN\VLC\vlc.exe")) {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'VLC not found, installing via WinGet...'

            # check consent for VLC installation
            $vlcConsent = GenXdev\Confirm-InstallationConsent `
                -ApplicationName 'VLC Media Player' `
                -Source 'WinGet' `
                -Description 'Media player required for video/audio playback functionality' `
                -Publisher 'VideoLAN'

            if (-not $vlcConsent) {
                throw 'Installation consent denied for VLC Media Player. Cannot proceed without media player.'
            }

            # check and install winget module if not present
            if (-not (Microsoft.PowerShell.Core\Get-Module -ListAvailable `
                        -Name 'Microsoft.WinGet.Client')) {

                # check consent for WinGet client module installation
                $wingetConsent = GenXdev\Confirm-InstallationConsent `
                    -ApplicationName 'Microsoft.WinGet.Client' `
                    -Source 'PowerShell Gallery' `
                    -Description 'Required PowerShell module for installing VLC Media Player' `
                    -Publisher 'Microsoft'

                if (-not $wingetConsent) {
                    throw 'Installation consent denied for Microsoft.WinGet.Client module. Cannot install VLC without WinGet client.'
                }

                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Installing WinGet client module'

                $null = PowerShellGet\Install-Module `
                    -Name 'Microsoft.WinGet.Client' `
                    -Force -Scope CurrentUser -AllowClobber -SkipPublisherCheck

                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Importing WinGet client module'

                Microsoft.PowerShell.Core\Import-Module `
                    -Name 'Microsoft.WinGet.Client'
            }

            # install vlc media player using winget
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Installing VLC media player'

            Microsoft.WinGet.Client\Install-WinGetPackage `
                -Id 'VideoLAN.VLC' -Scope System -Force

            # Configure VLC to not resize window on media change
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Configuring VLC to prevent window auto-resizing'

            $vlcConfigPath = "${env:APPDATA}\vlc"
            $vlcrcPath = Microsoft.PowerShell.Management\Join-Path $vlcConfigPath 'vlcrc'

            # Ensure config directory exists
            if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $vlcConfigPath)) {
                $null = Microsoft.PowerShell.Management\New-Item `
                    -Path $vlcConfigPath -ItemType Directory -Force
            }

            # Configure settings to prevent window resizing
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $vlcrcPath) {
                # Read existing config
                $vlcConfig = Microsoft.PowerShell.Management\Get-Content `
                    -Path $vlcrcPath -Raw

                # Update or add qt-video-autoresize setting
                if ($vlcConfig -match '#?qt-video-autoresize=') {
                    $vlcConfig = $vlcConfig -replace '#?qt-video-autoresize=.*', 'qt-video-autoresize=0'
                }
                else {
                    $vlcConfig += "`nqt-video-autoresize=0"
                }

                # Update or add autoscale setting
                if ($vlcConfig -match '#?autoscale=') {
                    $vlcConfig = $vlcConfig -replace '#?autoscale=.*', 'autoscale=0'
                }
                else {
                    $vlcConfig += "`nautoscale=0"
                }

                # Write updated config
                Microsoft.PowerShell.Management\Set-Content `
                    -Path $vlcrcPath -Value $vlcConfig -Force
            }
            else {
                # Create new config file with settings
                $newConfig = @"
# VLC media player preferences
qt-video-autoresize=0
autoscale=0
"@
                Microsoft.PowerShell.Management\Set-Content `
                    -Path $vlcrcPath -Value $newConfig -Force
            }

            Microsoft.PowerShell.Utility\Write-Verbose `
                'VLC configured: window auto-resize disabled'
        }

        # create vlc parameter conversion function
        function ConvertTo-VLCParameter {

            param (
                [string]$parameterName,
                $parameterValue
            )

            # convert powershell parameters to vlc command line arguments
            switch ($parameterName) {

                # parameters that need explicit off states
                'Random' {
                    return $parameterValue ? '--random' : '--no-random'
                }
                'Loop' {
                    return $parameterValue ? '--loop' : '--no-loop'
                }
                'Repeat' {
                    return $parameterValue ? '--repeat' : '--no-repeat'
                }
                'StartPaused' {
                    return $parameterValue ? '--start-paused' : `
                        '--no-start-paused'
                }
                'PlayAndExit' {
                    return $parameterValue ? '--play-and-exit' : `
                        '--no-play-and-exit'
                }
                'AlwaysOnTop' {
                    return $parameterValue ? '--video-on-top' : `
                        '--no-video-on-top'
                }
                'DisableAudio' {
                    return $parameterValue ? '--no-audio' : '--audio'
                }

                # parameters with value mappings
                'ReplayGainMode' {
                    return "--audio-replay-gain-mode=$($parameterValue.ToLower())"
                }
                'ReplayGainPreamp' {
                    return "--audio-replay-gain-preamp=$parameterValue"
                }
                'ForceDolbySurround' {
                    return "--force-dolby-surround=$($parameterValue.ToLower())"
                }
                'AudioFilters' {
                    return "--audio-filter=$($parameterValue -join ',')"
                }
                'Visualization' {
                    return "--audio-visual=$($parameterValue.ToLower())"
                }
                'Deinterlace' {
                    return "--deinterlace=$($parameterValue.ToLower())"
                }
                'DeinterlaceMode' {
                    return "--deinterlace-mode=$($parameterValue.ToLower())"
                }
                'AspectRatio' {
                    return "--aspect-ratio=$parameterValue"
                }
                'Crop' {
                    return "--crop=$parameterValue"
                }
                'AutoScale' {
                    if ($parameterValue) {
                        return '--autoscale'
                    }
                }
                'VideoFilters' {
                    return "--video-filter=$($parameterValue -join ',')"
                }
                'SubtitleFile' {
                    return "--sub-file=$parameterValue"
                }
                'DisableSubtitles' {
                    if ($parameterValue) {
                        return '--no-spu'
                    }
                }
                'SubtitleScale' {
                    return "--sub-text-scale=$parameterValue"
                }
                'SubtitleLanguage' {
                    $languageDict = GenXdev\Get-WebLanguageDictionary
                    return "--sub-language=$($languageDict[$parameterValue])"
                }
                'AudioLanguage' {
                    $languageDict = GenXdev\Get-WebLanguageDictionary
                    return "--audio-language=$($languageDict[$parameterValue])"
                }
                'PreferredAudioLanguage' {
                    $languageDict = GenXdev\Get-WebLanguageDictionary
                    return "--preferred-audio-language=$($languageDict[$parameterValue])"
                }
                'HttpProxy' {
                    return "--http-proxy=$parameterValue"
                }
                'HttpProxyPassword' {
                    return "--http-proxy-pwd=$parameterValue"
                }
                'VerbosityLevel' {
                    return "--verbose=$parameterValue"
                }
                'SubdirectoryBehavior' {
                    return "--recursive=$($parameterValue.ToLower())"
                }
                'IgnoredExtensions' {
                    return "--ignore-filetypes=$parameterValue"
                }
                'HighPriority' {
                    if ($parameterValue) {
                        return '--high-priority'
                    }
                }
                'EnableTimeStretch' {
                    if ($parameterValue) {
                        return '--audio-time-stretch'
                    }
                }
                'EnableWallpaperMode' {
                    if ($parameterValue) {
                        return '--video-wallpaper'
                    }
                }
                'VideoFilterModules' {
                    return "--video-filter=$($parameterValue -join ',')"
                }
                'Modules' {
                    return "--modules=$($parameterValue -join ',')"
                }
                'AudioFilterModules' {
                    return "--audio-filter=$($parameterValue -join ',')"
                }
                'AudioVisualization' {
                    return "--audio-visual=$($parameterValue.ToLower())"
                }
                'PreferredSubtitleLanguage' {
                    return "--sub-language=$parameterValue"
                }
                'IgnoredFileExtensions' {
                    return "--ignore-filetypes=$parameterValue"
                }
                'EnableAudioTimeStretch' {
                    if ($parameterValue) {
                        return '--audio-time-stretch'
                    }
                }
            }
        }

        # check if vlc is already running (if not already checked above)
        $vlcProcess = $null
        if ($null -eq $vlcWindow) {
            $vlcWindow = GenXdev\Get-Window -ProcessName vlc `
                -ErrorAction SilentlyContinue
        }

        # initialize vlc argument list
        [System.Collections.Generic.List[string]]$vlcArgs = @()

        # Check if positioning parameters are supplied
        $hasPositioningParams = $PSBoundParameters.Keys | Microsoft.PowerShell.Core\Where-Object {
            $_ -in @('Monitor', 'Width', 'Height', 'X', 'Y',
                'Left', 'Right', 'Top', 'Bottom', 'Centered', 'Fullscreen',
                'SideBySide')
        }

        # Note: VLC's initial positioning arguments (--video-x, --video-y, --width, --height)
        # are unreliable for main window positioning. We'll rely entirely on post-launch
        # Set-WindowPosition for accurate positioning instead.

        # Only add --fullscreen if no positioning will occur, since positioning handles fullscreen via F11
        if ($FullScreen -and (-not $hasPositioningParams) -and ($null -eq $KeysToSend -or $KeysToSend.Count -eq 0)) {
            $vlcArgs.Add('--fullscreen')
            $FullScreen = $false
            $Maximize = $false
        }

        # configure instance mode
        if ($NewWindow) {

            $null = $vlcArgs.Add('--no-one-instance')
        }
        else {

            $null = $vlcArgs.Add('--one-instance')
        }

        # process each parameter and convert to vlc arguments
        $null = $PSBoundParameters.GetEnumerator() |
            Microsoft.PowerShell.Core\ForEach-Object {

                if ($_.Key -notin @('VLCPath', 'Path', 'Arguments', 'Close',
                        'SideBySide', 'FocusWindow', 'SetForeground',
                        'Maximize', 'RestoreFocus', 'SessionOnly',
                        'ClearSession', 'SkipSession', 'PassThru',
                        'KeysToSend', 'SendKeyEscape', 'SendKeyUseShiftEnter',
                        'SendKeyDelayMilliSeconds', 'SendKeyHoldKeyboardFocus',
                        'Monitor', 'NoBorders', 'Left', 'Right', 'Top',
                        'Bottom', 'Centered', 'Fullscreen', 'Width', 'Height',
                        'X', 'Y', 'NewWindow')) {

                    $vlcArgument = ConvertTo-VLCParameter -parameterName $_.Key `
                        -parameterValue $_.Value

                    if ($vlcArgument) {

                        $null = $vlcArgs.Add($vlcArgument)
                    }
                }
            }

        # add custom arguments if specified
        if ($Arguments) {

            $Arguments |
                Microsoft.PowerShell.Core\ForEach-Object {

                    $null = $vlcArgs.Add($_)
                }
        }

        # add media paths to argument list
        @($Path) |
            Microsoft.PowerShell.Core\ForEach-Object {

                if ($null -eq $_) {
                    return
                }

                $expandedPath = GenXdev\Expand-Path $_
                $null = $vlcArgs.Add("`"$expandedPath`"")
            }

        # build the process start arguments
        $processArgs = @{
            FilePath     = $VLCPath
            ArgumentList = $vlcArgs
            PassThru     = $true
            ErrorAction  = 'SilentlyContinue'
        }

        # Start VLC minimized if we'll be positioning it later to prevent visual jumping
        if ($hasPositioningParams) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Starting VLC minimized since positioning will occur'
            $processArgs.WindowStyle = 'Minimized'
        }

        # handle existing vlc instance
        if ($null -eq $vlcWindow) {

            # ensure vlc executable exists
            if (-not (Microsoft.PowerShell.Management\Test-Path `
                        -LiteralPath $processArgs.FilePath -ErrorAction SilentlyContinue)) {

                throw 'VLC Media Player executable not found. Please ensure VLC is properly installed.'
            }

            # close any existing vlc processes
            Microsoft.PowerShell.Management\Get-Process vlc `
                -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Management\Stop-Process -Force
        }
        else {

            # get existing vlc process with main window
            $vlcProcess = Microsoft.PowerShell.Management\Get-Process `
                -Name vlc -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Core\Where-Object `
                    -Property MainWindowHandle -NE 0
        }

        # start vlc if needed
        # Only restart VLC if:
        # 1. VLC is not running, OR
        # 2. We have media files to open (Path parameter provided), OR
        # 3. We have significant configuration changes (more than just --one-instance)
        $hasMediaFiles = ($null -ne $Path) -and ($Path.Count -gt 0)
        $hasSignificantArgs = ($processArgs.ArgumentList.Count -gt 1) -and $hasMediaFiles

        if (($null -eq $vlcWindow) -or $hasSignificantArgs) {

            # start vlc with configured arguments
            try {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Starting VLC with arguments: $($vlcArgs -join ' ')"

                $vlcProcess = Microsoft.PowerShell.Management\Start-Process `
                    @processArgs

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "VLC started with PID: $($vlcProcess.Id)"

                Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 2500
            }
            catch {

                Microsoft.PowerShell.Utility\Write-Error `
                    "Failed to start VLC: $_"
            }
        }

        # wait up to 20 seconds for vlc window to appear
        $vlcWindow = $null
        for ($i = 0; $i -lt 20; $i++) {
            $vlcWindow = GenXdev\Get-Window -ProcessName vlc `
                -ErrorAction SilentlyContinue
            if ($vlcWindow) { break }
            Microsoft.PowerShell.Utility\Start-Sleep -Seconds 1
        }

        # verify vlc window was found
        if ($null -eq $vlcWindow) {

            Microsoft.PowerShell.Utility\Write-Warning `
                'Failed to find VLC window'

            return
        }

        # Check if any positioning param (other than KeysToSend and RestoreFocus) was explicitly provided
        $hasPositioningParams = $PSBoundParameters.Keys | Microsoft.PowerShell.Core\Where-Object {
            $_ -in @('Monitor', 'NoBorders', 'Width', 'Height', 'X', 'Y',
                'Left', 'Right', 'Top', 'Bottom', 'Centered', 'Fullscreen',
                'SideBySide', 'FocusWindow', 'SetForeground', 'Minimize', 'Maximize')
        }

        # Check if this is a "keys only" operation (no positioning, no new media)
        $isKeysOnlyOperation = ($null -ne $KeysToSend) -and ($KeysToSend.Count -gt 0) -and
        (-not $hasPositioningParams) -and
        (-not $PSBoundParameters.ContainsKey('Path'))

        # prepare window positioning parameters
        if ($PSBoundParameters.ContainsKey('Process')) {
            $null = $PSBoundParameters.Remove('Process')
        }

        # copy window positioning parameters using helper function, but exclude RestoreFocus for keys-only operations
        $parametersToCopy = $PSBoundParameters
        if ($isKeysOnlyOperation) {
            # Create a copy without RestoreFocus to prevent unwanted positioning
            $parametersToCopy = @{}
            $PSBoundParameters.GetEnumerator() | Microsoft.PowerShell.Core\ForEach-Object {
                if ($_.Key -ne 'RestoreFocus') {
                    $parametersToCopy[$_.Key] = $_.Value
                }
            }
        }

        # If we're skipping window positioning, exclude KeysToSend params since they'll be handled separately
        $invocationParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Set-WindowPosition' `
            -DefaultValues @((Microsoft.PowerShell.Utility\Get-Variable -Name 'Monitor' -Scope Local))

        $invocationParams.WindowHelper = $vlcWindow
        $invocationParams.SideBySide = $SideBySide

        # Only set default monitor and fullscreen if we have actual positioning params
        # OR if Path is provided (opening VLC, not just sending keys)
        # AND we're not skipping window positioning
        if ((-not $PSBoundParameters.ContainsKey('Monitor')) -and (-not $SideBySide) -and ($hasPositioningParams -or $PSBoundParameters.ContainsKey('Path')) -and
            ($null -eq $KeysToSend -or $KeysToSend.Count -eq 0) -and (-not $skipWindowPositioning)
        ) {
            $invocationParams.Monitor = -2
            $Fullscreen = $true
        }
        if ($FullScreen) {
            # $invocationParams.Maximize = $true
            $invocationParams.Fullscreen = $false
            # Only set fullscreen keystroke if user didn't provide KeysToSend
            if (-not $PSBoundParameters.ContainsKey('KeysToSend')) {
                $invocationParams.KeysToSend = @('f')
            }
            $invocationParams.RestoreFocus = $true
        }

        if ($invocationParams.ContainsKey(("KeysToSend"))) {

            $null = $invocationParams.Remove("KeysToSend")
        }

        # Only apply window positioning if not a keys-only operation AND not skipping window positioning
        if (-not $isKeysOnlyOperation -and -not $skipWindowPositioning) {
            # apply window positioning if parameters specified
            $null = GenXdev\Set-WindowPosition @invocationParams
        }

        Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 500
    }


    process {

        # handle close request
        if ($Close) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Closing VLC windows'

            if ($vlcProcess) {

                $null = $vlcProcess.CloseMainWindow()

                $null = $vlcProcess.WaitForExit(2000)
            }

            $null = Microsoft.PowerShell.Management\Get-Process vlc `
                -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Management\Stop-Process -Force

            return
        }

        if ($haveOnlyPositioningParams) {

            return
        }

        # exit if no keys to send
        if ($null -eq $KeysToSend -or ($KeysToSend.Count -eq 0)) {

            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose `
            'Sending keystrokes to VLC window'

        # copy key sending parameters using helper function
        $invocationParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Send-Key'

        $invocationParams.WindowHandle = $vlcWindow.Handle

        # send keys to vlc window
        $null = GenXdev\Send-Key @invocationParams
    }

    end {

        if ($haveOnlyPositioningParams) {

            return
        }

        # restore focus to powershell window if requested
        if ($RestoreFocus) {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Restoring PowerShell window focus'

            # restore powershell window focus
            $null = GenXdev\Set-WindowPosition -FocusWindow -SetForeground
        }

        # return window helper if requested
        if ($PassThru) {

            return $vlcWindow
        }
    }
}
###############################################################################