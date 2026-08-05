###############################################################################
<#
.SYNOPSIS
Searches for image files and metadata in specified directories with filtering
capabilities and optional browser-based gallery display.

.DESCRIPTION
Searches for image files (jpg, jpeg, png, gif, bmp, webp, tiff, tif) in the
specified directory and its subdirectories. For each image, checks associated
description.json,
keywords.json, people.json, and objects.json files for metadata. Can filter
images based on keyword matches, people recognition, and object detection, then
return the results as objects. Use -ShowInBrowser to display results in a
browser-based masonry layout.

Parameter Logic:
- Within each parameter type (Keywords, People, Objects, etc.): Uses OR logic
  Example: -Keywords "cat","dog" finds images with EITHER cat OR dog
- Between different parameter types: Uses AND logic
  Example: -Keywords "cat" -People "John" finds images with cat AND John
- EXIF range parameters: Provide [min, max] values for filtering ranges
- String parameters: Support wildcard matching with * and ?

The function searches through image directories and examines alternate data
streams containing metadata in JSON format. It can match keywords using wildcard
patterns, filter for specific people, and search for detected objects. By
default, returns image data objects. Use -ShowInBrowser to display in a web
browser.

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

.PARAMETER Any
Will match any of all the possible meta data types.

.PARAMETER Name
Array of directory paths to search for images. Each directory is searched
recursively for jpg, jpeg, png, gif, bmp, webp, tiff, and tif files. Relative
paths are converted to
absolute paths automatically.

.PARAMETER Language
The language for retrieving descriptions and keywords. Will try to find metadata
in the specified language first, then fall back to English if not available.
This allows you to have metadata in multiple languages for the same images.

.PARAMETER EmbedImages
Switch to embed images as base64 data URLs instead of file:// URLs. This makes
the generated HTML file completely self-contained and portable, but results in
larger file sizes. Useful when the HTML needs to be shared or viewed on
different systems where the original image files may not be accessible.

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

.PARAMETER DescriptionSearch
The description text to look for, wildcards allowed.

.PARAMETER Keywords
Array of keywords to search for in image metadata. Supports wildcards. If empty,
returns all images with any metadata. Keywords are matched against both the
description content and keywords arrays in metadata files.

.PARAMETER People
Array of people names to search for in image metadata. Supports wildcards. Used
to filter images based on face recognition metadata stored in people.json files.

.PARAMETER Objects
Array of object names to search for in image metadata. Supports wildcards. Used
to filter images based on object detection metadata stored in objects.json files.

.PARAMETER Scenes
Array of scene categories to search for in image metadata. Supports wildcards.
Used to filter images based on scene classification metadata stored in
scenes.json files.

.PARAMETER PictureType
Array of picture types to filter by (e.g., 'daylight', 'evening', 'indoor',
'outdoor'). Supports wildcards. Matches against the picture_type property in
description metadata.

.PARAMETER StyleType
Array of style types to filter by (e.g., 'casual', 'formal'). Supports
wildcards. Matches against the style_type property in description metadata.

.PARAMETER OverallMood
Array of overall moods to filter by (e.g., 'calm', 'cheerful', 'sad',
'energetic'). Supports wildcards. Matches against the overall_mood_of_image
property in description metadata.

.PARAMETER Title
The title to display at the top of the image gallery.

.PARAMETER Description
The description text to display in the image gallery.

.PARAMETER FocusWindow
Focus the browser window after opening.

.PARAMETER SetForeground
Set the browser window to foreground after opening.

.PARAMETER Maximize
Maximize the window after positioning

.PARAMETER SetRestored
Restore the window to normal state after positioning

.PARAMETER AcceptLang
Set the browser accept-lang http header.

.PARAMETER Monitor
The monitor to use, 0 = default, -1 is discard, -2 = Configured secondary
monitor, defaults to Global:DefaultSecondaryMonitor or 2 if not found.

.PARAMETER FocusWindow
Focus the browser window after opening.

.PARAMETER SetForeground
Set the browser window to foreground after opening.

.PARAMETER KeysToSend
Send specified keys to the browser window after opening.

.PARAMETER SendKeyEscape
When specified, escapes special characters so they are sent as literal text
instead of being interpreted as control sequences.

.PARAMETER SendKeyHoldKeyboardFocus
Prevents returning keyboard focus to PowerShell after sending keys.

.PARAMETER SendKeyUseShiftEnter
Sends Shift+Enter instead of regular Enter for line breaks.

.PARAMETER SendKeyDelayMilliSeconds
Adds delay between sending different key sequences. Useful for slower apps.

.PARAMETER Width
The initial width of the webbrowser window.

.PARAMETER Height
The initial height of the webbrowser window.

.PARAMETER X
The initial X position of the webbrowser window.

.PARAMETER Y
The initial Y position of the webbrowser window.

.PARAMETER HasNudity
Switch to filter for images that contain nudity. Only returns images where the
has_nudity property is true in the metadata.

.PARAMETER NoNudity
Switch to filter for images that do NOT contain nudity. Only returns images
where the has_nudity property is false in the metadata.

.PARAMETER HasExplicitContent
Switch to filter for images that contain explicit content. Only returns images
where the has_explicit_content property is true in the metadata.

.PARAMETER NoExplicitContent
Switch to filter for images that do NOT contain explicit content. Only returns
images where the has_explicit_content property is false in the metadata.

.PARAMETER ShowInBrowser
Switch to display the search results in a browser-based masonry layout gallery.
When used, the results are shown in an interactive web view. Can be combined
with -PassThru to also return the objects.

.PARAMETER PassThru
Switch to return image data as objects. When used with -ShowInBrowser, both
displays the gallery and returns the objects. When used alone with
-ShowInBrowser, only displays the gallery without returning objects.

.PARAMETER NoBorders
Remove window borders and title bar for a cleaner appearance.

.PARAMETER SideBySide
Place browser window side by side with PowerShell on the same monitor.

.PARAMETER Interactive
Connects to browser and adds additional buttons like Edit and Delete.

.PARAMETER Private
Opens in incognito/private browsing mode.

.PARAMETER Force
Force enable debugging port, stopping existing browsers if needed.

.PARAMETER Edge
Opens in Microsoft Edge.

.PARAMETER Chrome
Opens in Google Chrome.

.PARAMETER Chromium
Opens in Microsoft Edge or Google Chrome, depending on what the default browser
is.

.PARAMETER Firefox
Opens in Firefox.

.PARAMETER All
Opens in all registered modern browsers.

.PARAMETER FullScreen
Open in fullscreen mode.

.PARAMETER Left
Place browser window on the left side of the screen.

.PARAMETER Right
Place browser window on the right side of the screen.

.PARAMETER Top
Place browser window on the top side of the screen.

.PARAMETER Bottom
Place browser window on the bottom side of the screen.

.PARAMETER Centered
Place browser window in the center of the screen.

.PARAMETER ApplicationMode
Hide the browser controls.

.PARAMETER NoBrowserExtensions
Prevent loading of browser extensions.

.PARAMETER DisablePopupBlocker
Disable the popup blocker.

.PARAMETER RestoreFocus
Restore PowerShell window focus.

.PARAMETER NewWindow
Don't re-use existing browser window, instead, create a new one.

.PARAMETER OnlyReturnHtml
Only return the generated HTML instead of displaying it in a browser.

.PARAMETER ShowOnlyPictures
Show only pictures in a rounded rectangle, no text below.

.PARAMETER MetaCameraMake
Filter by camera make in image EXIF metadata. Supports wildcards.
Multiple values use OR logic within this parameter.

.PARAMETER MetaCameraModel
Filter by camera model in image EXIF metadata. Supports wildcards.
Multiple values use OR logic within this parameter.

.PARAMETER MetaGPSLatitude
Filter by GPS latitude range in image EXIF metadata.
Provide two values for range filtering [min, max].

.PARAMETER MetaGPSLongitude
Filter by GPS longitude range in image EXIF metadata.
Provide two values for range filtering [min, max].

.PARAMETER MetaGPSAltitude
Filter by GPS altitude range in image EXIF metadata (in meters).
Provide two values for range filtering [min, max].

.PARAMETER GeoLocation
Geographic coordinates [latitude, longitude] to search near.

.PARAMETER GeoDistanceInMeters
Maximum distance in meters from GeoLocation to search for images.

.PARAMETER MetaExposureTime
Filter by exposure time range in image EXIF metadata (in seconds).
Provide two values for range filtering [min, max].

.PARAMETER MetaFNumber
Filter by F-number (aperture) range in image EXIF metadata.
Provide two values for range filtering [min, max].

.PARAMETER MetaISO
Filter by ISO sensitivity range in image EXIF metadata.
Provide two values for range filtering [min, max].

.PARAMETER MetaFocalLength
Filter by focal length range in image EXIF metadata (in mm).
Provide two values for range filtering [min, max].

.PARAMETER MetaWidth
Filter by image width range in pixels from EXIF metadata.
Provide two values for range filtering [min, max].

.PARAMETER MetaHeight
Filter by image height range in pixels from EXIF metadata.
Provide two values for range filtering [min, max].

.PARAMETER MetaDateTaken
Filter by date taken from EXIF metadata. Can be a date range.
Provide two DateTime values for range filtering [start, end].

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER MinConfidenceRatio
Minimum confidence ratio (0.0-1.0) for filtering people, scenes, and objects
by confidence. Only returns data for people, scenes, and objects with confidence
greater than or equal to this value. When specified, filters out low-confidence
detection results from people, scenes, and objects data while keeping the image.

.EXAMPLE
Find-Image -Keywords "cat","dog" -Name "C:\Photos\*"
Searches for images containing 'cat' OR 'dog' keywords and returns the image objects.

.EXAMPLE
findimages cat,dog "C:\Photos"
Same as above using the alias and positional parameters.

.EXAMPLE
Find-Image -People "John","Jane" -Name "C:\Family\*" -ShowInBrowser
Searches for photos containing John OR Jane and displays them in a web gallery.

.EXAMPLE
Find-Image -Keywords "vacation" -People "John" -Objects "beach" -Name "C:\Photos\*"
Searches for images that contain vacation keywords AND John as a person AND beach objects.
All three criteria must be met (AND logic between parameter types).

.EXAMPLE
Find-Image -MetaISO 100,800 -MetaFNumber 1.4,2.8 -Name "C:\Photos\*"
Finds images with ISO between 100-800 AND aperture (F-number) between f/1.4-f/2.8.
EXIF parameters use range filtering with [min, max] values.

.EXAMPLE
Find-Image -Objects "car","bicycle" -Name "C:\Photos\*" -ShowInBrowser -PassThru
Searches for images containing detected cars or bicycles, displays them in a gallery, and also returns the objects.

.EXAMPLE
findimages -Language "Spanish" -Keywords "playa","sol" -Name "C:\Vacations\*" -ShowInBrowser
Searches for images with Spanish metadata containing the keywords "playa" (beach) or "sol" (sun) and displays in gallery.

.EXAMPLE
Find-Image -Keywords "vacation" -People "John" -Objects "beach*" -Name "C:\Photos\*"
Searches for vacation photos with John in them that also contain beach-related objects and returns the data objects.

.EXAMPLE
Find-Image -Scenes "beach","forest","mountain*" -Name "C:\Nature\*" -ShowInBrowser
Searches for images classified as beach, forest, or mountain scenes and displays them in a gallery.

.EXAMPLE
Find-Image -NoNudity -NoExplicitContent -Name "C:\Family\*" -ShowInBrowser
Searches for family-safe images (no nudity or explicit content) and displays them in a gallery.

.EXAMPLE
Find-Image -PictureType "daylight" -OverallMood "calm" -Name "C:\Photos\*"
Searches for daylight photos with a calm/peaceful mood and returns the image objects.

.EXAMPLE
findimages -StyleType "casual" -HasNudity -Name "C:\Art\*"
Searches for casual style images that contain nudity and returns the data objects.

.EXAMPLE
Find-Image -Scenes "beach" -MinConfidenceRatio 0.75 -Name "C:\Photos\*"
Searches for beach scenes with confidence level of 75% or higher and filters people, scenes, and objects data by confidence.
#>
###############################################################################
function Find-Image {

    [CmdletBinding()]
    [OutputType([GenXdev.Helpers.ImageSearchResult], [string])]
    [Alias('findimages', 'li')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'Will match any of all the possible meta data types.'
        )]
        [string[]] $Any = @(),
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'Array of directory paths to search for images'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('imagespath', 'directories', 'imgdirs', 'imagedirectory', 'ImageDirectories')]
        [string[]] $Name = @('.\'),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Language for descriptions and keywords.'
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
            'Portuguese (Brazil)', 'Portuguese (Portugal)', 'Punjabi', 'Quechua',
            'Romanian', 'Romansh', 'Runyakitara', 'Russian', 'Scots Gaelic',
            'Serbian', 'Serbo-Croatian', 'Sesotho', 'Setswana',
            'Seychellois Creole', 'Shona', 'Sindhi', 'Sinhalese', 'Slovak',
            'Slovenian', 'Somali', 'Spanish', 'Spanish (Latin American)',
            'Sundanese', 'Swahili', 'Swedish', 'Tajik', 'Tamil', 'Tatar',
            'Telugu', 'Thai', 'Tigrinya', 'Tonga', 'Tshiluba', 'Tumbuka',
            'Turkish', 'Turkmen', 'Twi', 'Uighur', 'Ukrainian', 'Urdu', 'Uzbek',
            'Vietnamese', 'Welsh', 'Wolof', 'Xhosa', 'Yiddish', 'Yoruba', 'Zulu'
        )]
        [string] $Language,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The description text to look for, wildcards ' +
                'allowed.')
        )]
        [string[]] $DescriptionSearch = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The keywords to look for, wildcards allowed.'
        )]
        [string[]] $Keywords = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'People to look for, wildcards allowed.'
        )]
        [string[]] $People = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Objects to look for, wildcards allowed.'
        )]
        [string[]] $Objects = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Scene categories to look for, wildcards allowed.'
        )]
        [string[]] $Scenes = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Picture type to filter by (e.g., 'daylight', " +
                "'evening', 'indoor', etc). Supports wildcards.")
        )]
        [string[]] $PictureType = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Style type to filter by (e.g., 'casual', 'formal', " +
                'etc). Supports wildcards.')
        )]
        [string[]] $StyleType = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Overall mood to filter by (e.g., 'calm', " +
                "'cheerful', 'sad', etc). Supports wildcards.")
        )]
        [string[]] $OverallMood = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by camera make in image EXIF metadata. Supports wildcards.'
        )]
        [string[]] $MetaCameraMake = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by camera model in image EXIF metadata. Supports wildcards.'
        )]
        [string[]] $MetaCameraModel = @(),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by GPS latitude range in image EXIF metadata.'
        )]
        [double[]] $MetaGPSLatitude,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by GPS longitude range in image EXIF metadata.'
        )]
        [double[]] $MetaGPSLongitude,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by GPS altitude range in image EXIF metadata (in meters).'
        )]
        [double[]] $MetaGPSAltitude,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Geographic coordinates [latitude, longitude] to search near.'
        )]
        [double[]] $GeoLocation,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum distance in meters from GeoLocation to search for images.'
        )]
        [double] $GeoDistanceInMeters = 1000,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by exposure time range in image EXIF metadata (in seconds).'
        )]
        [double[]] $MetaExposureTime,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by F-number (aperture) range in image EXIF metadata.'
        )]
        [double[]] $MetaFNumber,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by ISO sensitivity range in image EXIF metadata.'
        )]
        [int[]] $MetaISO,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by focal length range in image EXIF metadata (in mm).'
        )]
        [double[]] $MetaFocalLength,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by image width range in pixels from EXIF metadata.'
        )]
        [int[]] $MetaWidth,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by image height range in pixels from EXIF metadata.'
        )]
        [int[]] $MetaHeight,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter by date taken from EXIF metadata. Can be a date range.'
        )]
        [DateTime[]] $MetaDateTaken,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Title for the gallery'
        )]
        [string] $Title = 'Photo Gallery',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Description for the gallery'
        )]
        [string] $Description = ('Hover over images to see face recognition ' +
            'and object detection data'),
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser accept-lang http header'
        )]
        [Alias('lang', 'locale')]
        [string] $AcceptLang = $null,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Keystrokes to send to the Browser window, ' +
                'see documentation for cmdlet GenXdev\Send-Key')
        )]
        [string[]] $KeysToSend,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Escape control characters and modifiers when ' +
                'sending keys')
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Prevent returning keyboard focus to PowerShell ' +
                'after sending keys')
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use Shift+Enter instead of Enter when sending ' +
                'keys')
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between different input strings in ' +
                'milliseconds when sending keys')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the browser window after opening'
        )]
        [Alias('fw', 'focus')]
        [switch] $FocusWindow,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the browser window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window after positioning'
        )]
        [switch] $Maximize,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore the window to normal state after positioning'
        )]
        [switch] $SetRestored,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The monitor to use, 0 = default, -1 is discard, ' +
                '-2 = Configured secondary monitor, defaults to ' +
                "`Global:DefaultSecondaryMonitor or 2 if not found")
        )]
        [Alias('m', 'mon')]
        [int] $Monitor = -2,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the webbrowser window'
        )]
        [int] $Width,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the webbrowser window'
        )]
        [int] $Height,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial X position of the webbrowser window'
        )]
        [int] $X = -999999,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial Y position of the webbrowser window'
        )]
        [int] $Y = -999999,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Embed images as base64.'
        )]
        [switch] $EmbedImages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to disable fallback behavior.'
        )]
        [switch] $NoFallback,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Switch to skip database initialization and rebuilding.'
        )]
        [switch] $NeverRebuild,
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
            HelpMessage = 'Maximum recursion depth for directory traversal. 0 means unlimited.'
        )]
        [Alias('md', 'depth', 'maxdepth')]
        [int] $MaxRecursionDepth = 0,
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
            HelpMessage = 'Filter images that contain nudity.'
        )]
        [switch] $HasNudity,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that do NOT contain nudity.'
        )]
        [switch] $NoNudity,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that contain explicit content.'
        )]
        [switch] $HasExplicitContent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Filter images that do NOT contain explicit content.'
        )]
        [switch] $NoExplicitContent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Display the search results in a browser-based ' +
                'image gallery.')
        )]
        [Alias('show', 's')]
        [switch] $ShowInBrowser,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Return image data as objects. When used with ' +
                '-ShowInBrowser, both displays the gallery and returns ' +
                'the objects.')
        )]
        [Alias('pt')]
        [switch]$PassThru,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Remove window borders and title bar for a cleaner appearance'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window side by side with PowerShell on the same monitor'
        )]
        [Alias('sbs')]
        [switch]$SideBySide,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will connect to browser and adds additional ' +
                'buttons like Edit and Delete. Only effective when used with ' +
                '-ShowInBrowser.')
        )]
        [Alias('i', 'editimages')]
        [switch] $Interactive,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in incognito/private browsing mode'
        )]
        [Alias('incognito', 'inprivate')]
        [switch] $Private,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force enable debugging port, stopping existing ' +
                'browsers if needed')
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Microsoft Edge'
        )]
        [Alias('e')]
        [switch] $Edge,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Google Chrome'
        )]
        [Alias('ch')]
        [switch] $Chrome,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Opens in Microsoft Edge or Google Chrome, ' +
                'depending on what the default browser is')
        )]
        [Alias('c')]
        [switch] $Chromium,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in Firefox'
        )]
        [Alias('ff')]
        [switch] $Firefox,
        ###############################################################################
        [Alias('pw')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use Playwright-managed browser instead of the ' +
                'OS-installed browser')
        )]
        [switch] $PlayWright,
        ###############################################################################
        [Alias('wk')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Opens the Playwright-managed WebKit browser. ' +
                'Implies -PlayWright')
        )]
        [switch] $Webkit,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Run the browser without a visible window'
        )]
        [Alias('hl')]
        [switch] $Headless,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in all registered modern browsers'
        )]
        [switch] $All,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Opens in fullscreen mode'
        )]
        [Alias('fs', 'f')]
        [switch] $FullScreen,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the left side of the screen'
        )]
        [switch] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the right side of the screen'
        )]
        [switch] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the top side of the screen'
        )]
        [switch] $Top,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place browser window in the center of the screen'
        )]
        [switch] $Centered,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hide the browser controls'
        )]
        [Alias('a', 'app', 'appmode')]
        [switch] $ApplicationMode,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prevent loading of browser extensions'
        )]
        [Alias('de', 'ne', 'NoExtensions')]
        [switch] $NoBrowserExtensions,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Disable the popup blocker'
        )]
        [Alias('allowpopups')]
        [switch] $DisablePopupBlocker,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Don't re-use existing browser window, instead, " +
                'create a new one')
        )]
        [Alias('nw', 'new')]
        [switch] $NewWindow,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only return the generated HTML instead of ' +
                'displaying it in a browser.')
        )]
        [switch] $OnlyReturnHtml,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Show only pictures in a rounded rectangle, no ' +
                'text below.')
        )]
        [Alias('NoMetadata', 'OnlyPictures')]
        [switch] $ShowOnlyPictures,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session ' +
                'for AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Auto-scroll the page by this many pixels per second (null to disable)'
        )]
        [int]$AutoScrollPixelsPerSecond = $null,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Animate rectangles (objects/faces) in visible range, cycling every 300ms'
        )]
        [switch]$AutoAnimateRectangles,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force single column layout (centered, 1/3 screen width)'
        )]
        [switch]$SingleColumnMode = $false,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Prefix to prepend to each image path (e.g. for remote URLs)'
        )]
        [string]$ImageUrlPrefix = '',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Minimum confidence ratio (0.0-1.0) for filtering ' +
                'people, scenes, and objects by confidence. Only returns data for ' +
                'people, scenes, and objects with confidence greater than or equal ' +
                'to this value.')
        )]
        [ValidateRange(0.0, 1.0)]
        [double] $MinConfidenceRatio
        ###############################################################################
    )

    begin {
        # configure html return mode if requested
        if ($OnlyReturnHtml) {

            $Interactive = $false
            $ShowInBrowser = $true
        }

        # get language preference using helper function with parameter copying
        $params = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-AIMetaLanguage' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local `
                -ErrorAction SilentlyContinue)

        # retrieve the language preference from ai meta language function
        $language = GenXdev\Get-AIMetaLanguage @params

        # enable interactive mode when interactive switch is used
        if ($Interactive) {

            $ShowInBrowser = $true
        }

        # initialize results collection for all found images
        $results = [System.Collections.Generic.List[Object]] @()

        # process any parameter - prepare for OR-based matching across metadata types
        $anySearchTerms = @()
        if ($null -ne $Any -and $Any.Length -gt 0) {
            # add wildcards to entries that don't already have them for flexible matching
            $anySearchTerms = @($Any | Microsoft.PowerShell.Core\ForEach-Object {
                    # trim whitespace from each entry
                    $entry = $_.Trim()
                    # check if entry already has wildcard characters
                    if ($entry.IndexOfAny([char[]]@('*', '?')) -lt 0) {
                        # add wildcard wrapping for broader matching
                        "*$entry*"
                    }
                    else {
                        # return entry as-is if wildcards already present
                        $_
                    }
                })
        }

        $FindItemParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Find-Item'
    }

    process {

        # define internal function to process individual image files
        function processImageFile {

            param($item)

            # get full path of current image file being processed
            $image = $item.FullName

            # skip if image path is null or empty
            if ([string]::IsNullOrEmpty($image)) {
                Microsoft.PowerShell.Utility\Write-Verbose "Skipping null or empty image path"
                return
            }

            # output current image being processed for debugging purposes
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Processing image: $image")

            # initialize metadata containers for this image with empty defaults
            $keywordsFound = @()

            # initialize description container
            $descriptionFound = $null

            # initialize metadata file path variable
            $metadataFile = $null

            # try to load description metadata in requested language if not english
            if ($language -ne 'English' -and
                [System.IO.File]::Exists(
                    "$($image):description.$language.json")) {

                # log that language-specific metadata was found
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Found $language metadata for $image")

                # set path to language-specific description file
                $metadataFile = "$($image):description.$language.json"
            }
            # fallback to english if language-specific file doesn't exist
            elseif ([System.IO.File]::Exists("$($image):description.json")) {

                # log that english fallback metadata was found
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Found English metadata for $image")

                # set path to english description file
                $metadataFile = "$($image):description.json"
            }

            # try to load description metadata if any file was found
            if ($metadataFile) {

                try {

                    # read and parse description json from alternate data stream
                    $descriptionFound = [System.IO.File]::ReadAllText(
                        $metadataFile) |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    # extract keywords from description if they exist in metadata
                    $keywordsFound = ($null -eq $descriptionFound.keywords) ?
                    @() : $descriptionFound.keywords
                }
                catch {
                    # reset description if json parsing fails
                    $descriptionFound = $null
                    # log parsing failure for debugging purposes
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Failed to parse metadata from $metadataFile")
                    Microsoft.PowerShell.Utility\Write-Verbose "[Find-Image] Exception 1111: $($_.Exception.Message)"
                }
            }

            # initialize people metadata container with default structure
            $peopleFound = @{count = 0; faces = @() }

            # try to load people metadata if alternate data stream exists
            if ([System.IO.File]::Exists("$($image):people.json")) {

                try {

                    # read and parse people json from alternate data stream
                    $peopleFound = [System.IO.File]::ReadAllText(
                        "$($image):people.json") |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json |
                        GenXdev\ConvertTo-HashTable

                    if ($peopleFound.faces -is [string]) {

                        $peopleFound.faces = @($peopleFound.faces)
                    }

                    # ensure people data has proper structure or reset to default
                    $peopleFound = (($null -eq $peopleFound) -or
                        ($peopleFound.count -eq 0)) ?
                    @{count = 0; faces = @() } : $peopleFound
                }
                catch {
                    # reset people data if json parsing fails
                    $peopleFound = @{count = 0; faces = @() }
                    Microsoft.PowerShell.Utility\Write-Verbose " [Find-Image] Exception 2: $($_.Exception.Message)"
                }
            }

            # initialize objects metadata container with default structure
            $objectsFound = @{
                count         = 0;
                objects       = @();
                object_counts = @{}
            }

            # try to load objects metadata if alternate data stream exists
            if ([System.IO.File]::Exists("$($image):objects.json")) {

                try {

                    # read and parse objects json from alternate data stream
                    $parsedObjects = [System.IO.File]::ReadAllText(
                        "$($image):objects.json") |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json


                    if ($parsedObjects.objects -is [string]) {

                        $parsedObjects.objects = @($parsedObjects.objects)
                    }

                    # if parsed data is not null and has predictions
                    if ($null -ne $parsedObjects -and
                        $null -ne $parsedObjects.objects) {

                        # remap to the structure the script expects
                        $objectsFound = @{
                            count         = $parsedObjects.objects.Count
                            objects       = $parsedObjects.predictions || $parsedObjects.objects
                            object_counts = $parsedObjects.object_counts
                        }
                    }
                }
                catch {

                    # reset objects data if json parsing fails
                    $objectsFound = @{
                        count         = 0;
                        objects       = @();
                        object_counts = @{}
                    }
                    Microsoft.PowerShell.Utility\Write-Verbose "[Find-Image] Exception 3: $($_.Exception.Message)"
                }
            }

            # initialize scenes metadata container with default structure
            $scenesFound = @{
                success    = $false;
                scene      = 'unknown';
                confidence = 0.0
            }

            # try to load scenes metadata if alternate data stream exists
            if ([System.IO.File]::Exists("$($image):scenes.json")) {

                try {

                    # read and parse scenes json from alternate data stream
                    $parsedScenes = [System.IO.File]::ReadAllText(
                        "$($image):scenes.json") |
                        Microsoft.PowerShell.Utility\ConvertFrom-Json

                    # if parsed data is not null and has scene data
                    if ($null -ne $parsedScenes -and
                        $null -ne $parsedScenes.scene) {

                        $scenesFound = $parsedScenes
                    }
                }
                catch {
                    # reset scenes data if json parsing fails
                    $scenesFound = @{
                        success    = $false;
                        scene      = 'unknown';
                        confidence = 0.0
                    }
                    Microsoft.PowerShell.Utility\Write-Verbose "[Find-Image] Exception 4: $($_.Exception.Message)"
                }
            }

            # determine if image has search criteria or metadata for filtering
            $hasSearchCriteria = (($null -ne $Keywords) -and
                ($Keywords.Length -gt 0)) -or
            (($null -ne $People) -and ($People.Count -gt 0)) -or
            (($null -ne $Objects) -and ($Objects.Count -gt 0)) -or
            (($null -ne $Scenes) -and ($Scenes.Count -gt 0)) -or
            $HasNudity -or $NoNudity -or $HasExplicitContent -or
            $NoExplicitContent -or
            (($null -ne $PictureType) -and ($PictureType.Count -gt 0)) -or
            (($null -ne $StyleType) -and ($StyleType.Count -gt 0)) -or
            (($null -ne $OverallMood) -and ($OverallMood.Count -gt 0)) -or
            (($null -ne $DescriptionSearch) -and ($DescriptionSearch.Count -gt 0)) -or
            (($null -ne $MetaCameraMake) -and ($MetaCameraMake.Count -gt 0)) -or
            (($null -ne $MetaCameraModel) -and ($MetaCameraModel.Count -gt 0)) -or
            (($null -ne $MetaWidth) -and ($MetaWidth.Count -gt 0)) -or
            (($null -ne $MetaHeight) -and ($MetaHeight.Count -gt 0)) -or
            (($null -ne $MetaGPSLatitude) -and ($MetaGPSLatitude.Count -gt 0)) -or
            (($null -ne $MetaGPSLongitude) -and ($MetaGPSLongitude.Count -gt 0)) -or
            (($null -ne $MetaGPSAltitude) -and ($MetaGPSAltitude.Count -gt 0)) -or
            (($null -ne $MetaExposureTime) -and ($MetaExposureTime.Count -gt 0)) -or
            (($null -ne $MetaFNumber) -and ($MetaFNumber.Count -gt 0)) -or
            (($null -ne $MetaISO) -and ($MetaISO.Count -gt 0)) -or
            (($null -ne $MetaFocalLength) -and ($MetaFocalLength.Count -gt 0)) -or
            (($null -ne $MetaDateTaken) -and ($MetaDateTaken.Count -gt 0)) -or
            (($null -ne $GeoLocation) -and ($GeoLocation.Count -eq 2)) -or
            ($PSBoundParameters.ContainsKey('MinConfidenceRatio'))

            # assume match if no search criteria specified (return all images with metadata)
            # if we have search criteria, start with true and set to false if any criteria fails (AND logic)
            $found = $true

            # initialize individual criteria match results for proper AND logic between parameter types
            $keywordMatch = $true
            $peopleMatch = $true
            $objectMatch = $true
            $sceneMatch = $true
            $descriptionMatch = $true
            $pictureTypeMatch = $true
            $styleTypeMatch = $true
            $moodMatch = $true
            $contentMatch = $true
            $exifMatch = $true
            $anyMatch = $true
            $confidenceMatch = $true

            # check basic content filtering criteria (nudity and explicit content)
            if ($HasNudity -or $NoNudity -or $HasExplicitContent -or $NoExplicitContent) {
                $contentMatch = $false  # Start with false, set true if any content criteria matches

                # check if nudity is required and image has nudity flag set to true
                if ($HasNudity -and ($null -ne $descriptionFound) -and
                    ($descriptionFound.has_nudity -eq $true)) {
                    $contentMatch = $true
                }

                # check if no nudity is required and (no metadata OR nudity flag not set to true)
                # images without metadata are treated as safe (no nudity)
                if ($NoNudity -and (($null -eq $descriptionFound) -or
                        ($descriptionFound.has_nudity -ne $true))) {
                    $contentMatch = $true
                }

                # check if explicit content is required and image has explicit content flag set to true
                if ($HasExplicitContent -and ($null -ne $descriptionFound) -and
                    ($descriptionFound.has_explicit_content -eq $true)) {
                    $contentMatch = $true
                }

                # check if no explicit content is required and (no metadata OR explicit content flag not set to true)
                # images without metadata are treated as safe (no explicit content)
                if ($NoExplicitContent -and (($null -eq $descriptionFound) -or
                        ($descriptionFound.has_explicit_content -ne $true))) {
                    $contentMatch = $true
                }
            }

            # check description search criteria against image description metadata
            if ($null -ne $DescriptionSearch -and $DescriptionSearch.Count -gt 0) {

                $descriptionMatch = $false

                if ($null -ne $descriptionFound -and $null -ne $descriptionFound.description) {

                    # check each required keyword against description content
                    foreach ($requiredDescriptionPhrase in $DescriptionSearch) {

                        # use wildcard matching for flexible description search against both long and short descriptions
                        if ($descriptionFound.description.long_description -like
                            $requiredDescriptionPhrase -or
                            $descriptionFound.description.short_description -like
                            $requiredDescriptionPhrase) {
                            $descriptionMatch = $true
                            break
                        }
                    }
                }
            }

            # perform picture type filtering against image metadata
            if ($null -ne $PictureType -and $PictureType.Count -gt 0) {

                $pictureTypeMatch = $false

                if ($null -ne $descriptionFound) {

                    # check each required picture type against image metadata
                    foreach ($requiredPictureType in $PictureType) {

                        # use wildcard matching for flexible picture type filtering
                        if ($descriptionFound.picture_type -like $requiredPictureType) {
                            $pictureTypeMatch = $true
                            break
                        }
                    }
                }
            }

            # perform style type filtering against image metadata
            if ($null -ne $StyleType -and $StyleType.Count -gt 0) {

                $styleTypeMatch = $false

                if ($null -ne $descriptionFound) {

                    # check each required style type against image metadata
                    foreach ($requiredStyleType in $StyleType) {

                        # use wildcard matching for flexible style type filtering
                        if ($descriptionFound.style_type -like $requiredStyleType) {
                            $styleTypeMatch = $true
                            break
                        }
                    }
                }
            }

            # perform overall mood filtering against image metadata
            if ($null -ne $OverallMood -and $OverallMood.Count -gt 0) {

                $moodMatch = $false
                if ($null -ne $descriptionFound) {

                    # check each required mood against image metadata
                    foreach ($requiredMood in $OverallMood) {

                        # use wildcard matching for flexible mood filtering
                        if ($descriptionFound.overall_mood_of_image -like $requiredMood) {

                            $moodMatch = $true
                            break
                        }
                    }
                }
            }

            # perform keywords filtering if keywords criteria specified
            if ($null -ne $Keywords -and $Keywords.Length -gt 0) {

                $keywordMatch = $false  # Start with false, set true if any keyword matches (OR within parameter)

                # check each found keyword against search criteria using nested loops
                foreach ($foundKeyword in $keywordsFound) {

                    # check each searched keywords against found keyword with wildcard matching
                    foreach ($searchedForKeyword in $Keywords) {

                        # use wildcard matching for flexible keyword search
                        if ($foundKeyword -like $searchedForKeyword) {

                            $keywordMatch = $true
                            break
                        }
                    }
                    # exit early if any keyword matches to improve performance
                    if ($keywordMatch) { break }
                }
            }

            # perform people filtering if people criteria specified
            if ($null -ne $People -and $People.Length -gt 0) {

                $peopleMatch = $false  # Start with false, set true if any person matches (OR within parameter)

                # check each found person against search criteria using nested loops
                foreach ($foundPerson in $peopleFound.faces) {

                    # check each searched person against found person with wildcard matching
                    foreach ($searchedForPerson in $People) {

                        # use wildcard matching for flexible people search
                        if ($foundPerson -like $searchedForPerson) {

                            $peopleMatch = $true
                            break
                        }
                    }
                    # exit early if any person matches to improve performance
                    if ($peopleMatch) { break }
                }
            }

            # perform objects filtering if objects criteria specified
            if ($null -ne $Objects -and $Objects.Length -gt 0) {

                $objectMatch = $false  # Start with false, set true if any object matches (OR within parameter)

                # check each found object against search criteria using nested loops
                foreach ($foundObject in $objectsFound.objects) {

                    # check each searched object against found object with wildcard matching
                    foreach ($searchedForObject in $Objects) {

                        # use wildcard matching for flexible objects search
                        if ($foundObject.label -like $searchedForObject) {

                            $objectMatch = $true
                            break
                        }
                    }

                    # exit early if any object matches to improve performance
                    if ($objectMatch) { break }
                }
            }

            # perform scenes filtering if scenes criteria specified
            if ($null -ne $Scenes -and $Scenes.Count -gt 0) {

                $sceneMatch = $false

                # output debug information for scene filtering when verbose mode is enabled
                if ($VerbosePreference -eq 'Continue') {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Scene filtering - Searching for: ' +
                        "$($Scenes -join ', ')")

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Scene filtering - Found scene: $($scenesFound.scene)")

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Scene filtering - Scene success: ' +
                        "$($scenesFound.success)")
                }

                # check if the found scene matches any of the search criteria with wildcard support
                foreach ($searchedForScene in $Scenes) {

                    # use wildcard matching for flexible scene search
                    if ($scenesFound.scene -like $searchedForScene -and (
                            $scenesFound.scene -notlike "unknown")) {

                        $sceneMatch = $true

                        # output match confirmation when verbose mode is enabled
                        if ($VerbosePreference -eq 'Continue') {

                            Microsoft.PowerShell.Utility\Write-Verbose (
                                'Scene filtering - Match found: ' +
                                "'$($scenesFound.scene)' matches " +
                                "'$searchedForScene'")
                        }

                        break
                    }
                }

                # output no match message when verbose mode is enabled and no matches found
                if (-not $sceneMatch -and $VerbosePreference -eq 'Continue') {

                    Microsoft.PowerShell.Utility\Write-Verbose (
                        'Scene filtering - No match found for scene: ' +
                        "$($scenesFound.scene)")
                }
            }

            # perform confidence filtering only if minimum confidence ratio is explicitly specified
            if ($PSBoundParameters.ContainsKey('MinConfidenceRatio') -and $null -ne $MinConfidenceRatio) {
                $confidenceMatch = $false  # Start with false, set true if any confidence meets minimum threshold

                # filter scenes by confidence - remove scenes below minimum threshold
                if ($null -ne $scenesFound -and $null -ne $scenesFound.confidence) {

                    if ($scenesFound.confidence -ge $MinConfidenceRatio) {

                        $confidenceMatch = $true
                    }
                    else {

                        # filter out the scene data by setting it to default
                        $scenesFound = @{
                            success    = $false
                            scene      = 'unknown'
                            label      = 'unknown'
                            confidence = 0.0
                        }
                    }
                }

                # filter people by confidence - remove people predictions below minimum threshold
                if ($null -ne $peopleFound -and $null -ne $peopleFound.predictions -and $peopleFound.predictions.Count -gt 0) {

                    $filteredPredictions = @()

                    foreach ($prediction in $peopleFound.predictions) {

                        if ($null -ne $prediction.confidence -and $prediction.confidence -ge $MinConfidenceRatio) {

                            $filteredPredictions += $prediction
                            $confidenceMatch = $true
                        }
                    }
                    $peopleFound.predictions = $filteredPredictions
                    $peopleFound.count = $filteredPredictions.Count

                    # update faces array to match filtered predictions
                    $peopleFound.faces = @($filteredPredictions | Microsoft.PowerShell.Core\ForEach-Object { $_.label })
                }

                # filter objects by confidence - remove object predictions below minimum threshold
                if ($null -ne $objectsFound -and $null -ne $objectsFound.objects -and $objectsFound.objects.Count -gt 0) {
                    $filteredObjects = @()
                    $filteredCounts = @{}

                    foreach ($obj in $objectsFound.objects) {

                        if ($null -ne $obj.confidence -and $obj.confidence -ge $MinConfidenceRatio) {

                            $filteredObjects += $obj
                            $confidenceMatch = $true

                            # update object counts for filtered objects
                            if ($filteredCounts.ContainsKey($obj.label)) {

                                $filteredCounts[$obj.label]++
                            }
                            else {

                                $filteredCounts[$obj.label] = 1
                            }
                        }
                    }

                    $objectsFound.objects = $filteredObjects
                    $objectsFound.count = $filteredObjects.Count
                    $objectsFound.object_counts = $filteredCounts
                }

                # if no confidence match was found and MinConfidenceRatio is specified, skip this image
                if (-not $confidenceMatch) {

                    # skip the image when confidence filtering is enabled but no data meets threshold
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Confidence filtering - No confidence data meets minimum threshold " +
                        "$MinConfidenceRatio for image $image")
                }
            }

            # perform EXIF metadata filtering if criteria specified
            $width = $null
            $height = $null
            $metadata = $null
            if ($hasSearchCriteria -and (($null -ne $MetaCameraMake -and $MetaCameraMake.Count -gt 0) -or
                    ($null -ne $MetaCameraModel -and $MetaCameraModel.Count -gt 0) -or
                    ($null -ne $MetaWidth -and $MetaWidth.Count -gt 0) -or
                    ($null -ne $MetaHeight -and $MetaHeight.Count -gt 0) -or
                    ($null -ne $MetaGPSLatitude -and $MetaGPSLatitude.Count -gt 0) -or
                    ($null -ne $MetaGPSLongitude -and $MetaGPSLongitude.Count -gt 0) -or
                    ($null -ne $MetaGPSAltitude -and $MetaGPSAltitude.Count -gt 0) -or
                    ($null -ne $MetaExposureTime -and $MetaExposureTime.Count -gt 0) -or
                    ($null -ne $MetaFNumber -and $MetaFNumber.Count -gt 0) -or
                    ($null -ne $MetaISO -and $MetaISO.Count -gt 0) -or
                    ($null -ne $MetaFocalLength -and $MetaFocalLength.Count -gt 0) -or
                    ($null -ne $MetaDateTaken -and $MetaDateTaken.Count -gt 0) -or
                    ($null -ne $GeoLocation -and $GeoLocation.Count -eq 2))) {

                $exifMatch = $false  # Start with false, will be set true if EXIF criteria match

                try {
                    # get metadata for EXIF filtering
                    $metadataStream = "${image}:EXIF.json"

                    if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $metadataStream -ErrorAction SilentlyContinue) {
                        try {
                            $cachedMetadata = Microsoft.PowerShell.Management\Get-Content -LiteralPath $metadataStream -Raw -ErrorAction SilentlyContinue
                            if ($cachedMetadata) {
                                $metadata = $cachedMetadata | Microsoft.PowerShell.Utility\ConvertFrom-Json -AsHashtable -ErrorAction Stop
                            }
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Verbose "Failed to read cached metadata: $_"
                            Microsoft.PowerShell.Utility\Write-Verbose "[Find-Image] Exception: 5 $($_.Exception.Message)"
                            $metadata = GenXdev\Get-ImageMetadata -ImagePath $image
                        }
                    }
                    else {
                        $metadata = GenXdev\Get-ImageMetadata -ImagePath $image
                    }

                    if ($null -ne $metadata) {
                        $width = $metadata.Basic.Width
                        $height = $metadata.Basic.Height
                        $exifMatch = $true  # Start with true for AND logic between EXIF criteria

                        # check camera make filter (OR within parameter, AND with other EXIF)
                        if ($null -ne $MetaCameraMake -and $MetaCameraMake.Count -gt 0) {
                            $makeMatch = $false
                            foreach ($make in $MetaCameraMake) {
                                if ($null -ne $metadata.Camera.Make -and $metadata.Camera.Make -like $make) {
                                    $makeMatch = $true
                                    break
                                }
                            }
                            $exifMatch = $exifMatch -and $makeMatch
                        }

                        # check camera model filter (OR within parameter, AND with other EXIF)
                        if ($exifMatch -and $null -ne $MetaCameraModel -and $MetaCameraModel.Count -gt 0) {

                            $modelMatch = $false

                            foreach ($model in $MetaCameraModel) {

                                if ($null -ne $metadata.Camera.Model -and $metadata.Camera.Model -like $model) {
                                    $modelMatch = $true
                                    break
                                }
                            }
                            $exifMatch = $exifMatch -and $modelMatch
                        }

                        # Width filter (exact or range)
                        if ($exifMatch -and $null -ne $MetaWidth -and $MetaWidth.Count -gt 0) {

                            $widthMatch = $false

                            if ($MetaWidth.Count -eq 1) {

                                $widthMatch = $width -eq $MetaWidth[0]
                            }
                            elseif ($MetaWidth.Count -eq 2) {

                                $widthMatch = $width -ge $MetaWidth[0] -and $width -le $MetaWidth[1]
                            }

                            $exifMatch = $exifMatch -and $widthMatch
                        }

                        # Height filter (exact or range)
                        if ($exifMatch -and $null -ne $MetaHeight -and $MetaHeight.Count -gt 0) {

                            $heightMatch = $false

                            if ($MetaHeight.Count -eq 1) {

                                $heightMatch = $height -eq $MetaHeight[0]
                            }
                            elseif ($MetaHeight.Count -eq 2) {

                                $heightMatch = $height -ge $MetaHeight[0] -and $height -le $MetaHeight[1]
                            }

                            $exifMatch = $exifMatch -and $heightMatch
                        }

                        # GPS filtering - exclude images without GPS data when GPS parameters are specified
                        if ($exifMatch -and (($null -ne $MetaGPSLatitude -and $MetaGPSLatitude.Count -gt 0) -or
                                ($null -ne $MetaGPSLongitude -and $MetaGPSLongitude.Count -gt 0) -or
                                ($null -ne $MetaGPSAltitude -and $MetaGPSAltitude.Count -gt 0) -or
                                ($null -ne $GeoLocation -and $GeoLocation.Count -eq 2))) {

                            $gpsMatch = $false

                            # Check if image has GPS coordinates in metadata
                            if ($null -ne $metadata.GPS -and
                                $null -ne $metadata.GPS.Latitude -and
                                $null -ne $metadata.GPS.Longitude) {

                                $imageLatitude = $metadata.GPS.Latitude
                                $imageLongitude = $metadata.GPS.Longitude
                                $imageAltitude = $metadata.GPS.Altitude

                                # GPS Latitude filter (exact or range)
                                if ($null -ne $MetaGPSLatitude -and $MetaGPSLatitude.Count -gt 0) {
                                    if ($MetaGPSLatitude.Count -eq 1) {
                                        $gpsMatch = $imageLatitude -eq $MetaGPSLatitude[0]
                                    }
                                    elseif ($MetaGPSLatitude.Count -eq 2) {
                                        $gpsMatch = $imageLatitude -ge $MetaGPSLatitude[0] -and $imageLatitude -le $MetaGPSLatitude[1]
                                    }
                                }

                                # GPS Longitude filter (exact or range) - AND with latitude if both specified
                                if ($gpsMatch -and $null -ne $MetaGPSLongitude -and $MetaGPSLongitude.Count -gt 0) {
                                    $longitudeMatch = $false
                                    if ($MetaGPSLongitude.Count -eq 1) {
                                        $longitudeMatch = $imageLongitude -eq $MetaGPSLongitude[0]
                                    }
                                    elseif ($MetaGPSLongitude.Count -eq 2) {
                                        $longitudeMatch = $imageLongitude -ge $MetaGPSLongitude[0] -and $imageLongitude -le $MetaGPSLongitude[1]
                                    }
                                    $gpsMatch = $gpsMatch -and $longitudeMatch
                                }
                                elseif ($null -ne $MetaGPSLongitude -and $MetaGPSLongitude.Count -gt 0) {
                                    # Only longitude specified, no latitude filter
                                    if ($MetaGPSLongitude.Count -eq 1) {
                                        $gpsMatch = $imageLongitude -eq $MetaGPSLongitude[0]
                                    }
                                    elseif ($MetaGPSLongitude.Count -eq 2) {
                                        $gpsMatch = $imageLongitude -ge $MetaGPSLongitude[0] -and $imageLongitude -le $MetaGPSLongitude[1]
                                    }
                                }

                                # GPS Altitude filter (exact or range) - AND with other GPS criteria
                                if ($gpsMatch -and $null -ne $MetaGPSAltitude -and $MetaGPSAltitude.Count -gt 0 -and $null -ne $imageAltitude) {
                                    $altitudeMatch = $false
                                    if ($MetaGPSAltitude.Count -eq 1) {
                                        $altitudeMatch = $imageAltitude -eq $MetaGPSAltitude[0]
                                    }
                                    elseif ($MetaGPSAltitude.Count -eq 2) {
                                        $altitudeMatch = $imageAltitude -ge $MetaGPSAltitude[0] -and $imageAltitude -le $MetaGPSAltitude[1]
                                    }
                                    $gpsMatch = $gpsMatch -and $altitudeMatch
                                }
                                elseif ($null -ne $MetaGPSAltitude -and $MetaGPSAltitude.Count -gt 0 -and $null -ne $imageAltitude) {
                                    # Only altitude specified
                                    if ($MetaGPSAltitude.Count -eq 1) {
                                        $gpsMatch = $imageAltitude -eq $MetaGPSAltitude[0]
                                    }
                                    elseif ($MetaGPSAltitude.Count -eq 2) {
                                        $gpsMatch = $imageAltitude -ge $MetaGPSAltitude[0] -and $imageAltitude -le $MetaGPSAltitude[1]
                                    }
                                }
                                elseif ($null -ne $MetaGPSAltitude -and $MetaGPSAltitude.Count -gt 0) {
                                    # Altitude filter specified but image has no altitude data
                                    $gpsMatch = $false
                                }

                                # GeoLocation proximity filter - AND with other GPS criteria
                                if ($gpsMatch -and $null -ne $GeoLocation -and $GeoLocation.Count -eq 2) {
                                    $targetLatitude = $GeoLocation[0]
                                    $targetLongitude = $GeoLocation[1]
                                    $maxDistance = $null -ne $MaxDistanceInMeters ? $MaxDistanceInMeters : 1000 # Default 1km

                                    # Calculate distance using Haversine formula
                                    $earthRadius = 6371000 # Earth's radius in meters
                                    $lat1Rad = [Math]::PI * $imageLatitude / 180
                                    $lat2Rad = [Math]::PI * $targetLatitude / 180
                                    $deltaLatRad = [Math]::PI * ($targetLatitude - $imageLatitude) / 180
                                    $deltaLonRad = [Math]::PI * ($targetLongitude - $imageLongitude) / 180

                                    $a = [Math]::Sin($deltaLatRad / 2) * [Math]::Sin($deltaLatRad / 2) +
                                    [Math]::Cos($lat1Rad) * [Math]::Cos($lat2Rad) *
                                    [Math]::Sin($deltaLonRad / 2) * [Math]::Sin($deltaLonRad / 2)
                                    $c = 2 * [Math]::Atan2([Math]::Sqrt($a), [Math]::Sqrt(1 - $a))
                                    $distance = $earthRadius * $c

                                    $proximityMatch = $distance -le $maxDistance
                                    $gpsMatch = $gpsMatch -and $proximityMatch
                                }
                                elseif ($null -ne $GeoLocation -and $GeoLocation.Count -eq 2) {
                                    # Only GeoLocation specified (no other GPS filters)
                                    $targetLatitude = $GeoLocation[0]
                                    $targetLongitude = $GeoLocation[1]
                                    $maxDistance = $null -ne $MaxDistanceInMeters ? $MaxDistanceInMeters : 1000

                                    # Calculate distance using Haversine formula
                                    $earthRadius = 6371000
                                    $lat1Rad = [Math]::PI * $imageLatitude / 180
                                    $lat2Rad = [Math]::PI * $targetLatitude / 180
                                    $deltaLatRad = [Math]::PI * ($targetLatitude - $imageLatitude) / 180
                                    $deltaLonRad = [Math]::PI * ($targetLongitude - $imageLongitude) / 180

                                    $a = [Math]::Sin($deltaLatRad / 2) * [Math]::Sin($deltaLatRad / 2) +
                                    [Math]::Cos($lat1Rad) * [Math]::Cos($lat2Rad) *
                                    [Math]::Sin($deltaLonRad / 2) * [Math]::Sin($deltaLonRad / 2)
                                    $c = 2 * [Math]::Atan2([Math]::Sqrt($a), [Math]::Sqrt(1 - $a))
                                    $distance = $earthRadius * $c

                                    $gpsMatch = $distance -le $maxDistance
                                }
                            }
                            # If GPS parameters are specified but image has no GPS data, exclude it
                            # $gpsMatch remains $false, which will make $exifMatch false

                            $exifMatch = $exifMatch -and $gpsMatch
                        }
                    }
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Verbose ("Could not process EXIF metadata for ${image}: $_")
                    Microsoft.PowerShell.Utility\Write-Verbose "[Find-Image] Exception 6: $($_.Exception.Message)"
                    $exifMatch = $false
                }
            }

            # check Any parameter - match against any metadata type (OR logic within Any)
            if ($anySearchTerms.Length -gt 0) {
                $anyMatch = $false  # Start with false, set true if any criteria matches

                foreach ($anyTerm in $anySearchTerms) {
                    # Check file path and filename
                    if ($image -like $anyTerm) {
                        $anyMatch = $true
                        break
                    }

                    # Check filename only (without path)
                    $filename = Microsoft.PowerShell.Management\Split-Path -Leaf $image
                    if ($filename -like $anyTerm) {
                        $anyMatch = $true
                        break
                    }

                    # Check description search
                    if ($null -ne $descriptionFound -and $null -ne $descriptionFound.description) {
                        if ($descriptionFound.description.long_description -like $anyTerm -or
                            $descriptionFound.description.short_description -like $anyTerm) {
                            $anyMatch = $true
                            break
                        }

                        # Check ImageFilename from description metadata
                        if ($descriptionFound.description.ImageFilename -like $anyTerm) {
                            $anyMatch = $true
                            break
                        }
                    }

                    # Check keywords
                    foreach ($foundKeyword in $keywordsFound) {
                        if ($foundKeyword -like $anyTerm) {
                            $anyMatch = $true
                            break
                        }
                    }
                    if ($anyMatch) { break }

                    # Check people
                    foreach ($foundPerson in $peopleFound.faces) {
                        if ($foundPerson -like $anyTerm) {
                            $anyMatch = $true
                            break
                        }
                    }
                    if ($anyMatch) { break }

                    # Check objects
                    foreach ($foundObject in $objectsFound.objects) {
                        if ($foundObject.label -like $anyTerm) {
                            $anyMatch = $true
                            break
                        }
                    }
                    if ($anyMatch) { break }

                    # Check scenes
                    if ($scenesFound.scene -like $anyTerm -or $scenesFound.label -like $anyTerm) {
                        $anyMatch = $true
                        break
                    }

                    # Check picture type
                    if ($null -ne $descriptionFound -and $descriptionFound.picture_type -like $anyTerm) {
                        $anyMatch = $true
                        break
                    }

                    # Check style type
                    if ($null -ne $descriptionFound -and $descriptionFound.style_type -like $anyTerm) {
                        $anyMatch = $true
                        break
                    }

                    # Check overall mood
                    if ($null -ne $descriptionFound -and $descriptionFound.overall_mood_of_image -like $anyTerm) {
                        $anyMatch = $true
                        break
                    }

                    # Check EXIF metadata if available
                    if ($null -ne $metadata) {
                        # Check camera make and model
                        if ($metadata.Camera.Make -like $anyTerm -or $metadata.Camera.Model -like $anyTerm) {
                            $anyMatch = $true
                            break
                        }

                        # Check software used
                        if ($metadata.Other.Software -like $anyTerm) {
                            $anyMatch = $true
                            break
                        }

                        # Check basic file information
                        if ($metadata.Basic.FileName -like $anyTerm -or
                            $metadata.Basic.Format -like $anyTerm -or
                            $metadata.Basic.FileExtension -like $anyTerm) {
                            $anyMatch = $true
                            break
                        }
                    }
                }
            }

            # combine all criteria using proper AND logic between parameter types
            # if no search criteria specified, return all images with metadata
            if (-not $hasSearchCriteria) {
                $found = $true
            }
            else {
                # AND logic between different parameter types: ALL specified criteria must match
                $found = $keywordMatch -and $peopleMatch -and $objectMatch -and
                $sceneMatch -and $descriptionMatch -and $pictureTypeMatch -and
                $styleTypeMatch -and $moodMatch -and $contentMatch -and $exifMatch -and
                $anyMatch -and $confidenceMatch
            }

            # return image data if all criteria matched
            if ($found) {

                # output match found for debugging purposes
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Found matching image: $image")

                # get image dimensions and metadata for output (if not already loaded by EXIF filtering)
                if ($null -eq $metadata) {
                    try {
                        # try to get metadata for output purposes
                        $metadataStream = "${image}:EXIF.json"
                        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $metadataStream -ErrorAction SilentlyContinue) {
                            try {
                                $cachedMetadata = Microsoft.PowerShell.Management\Get-Content -LiteralPath $metadataStream -Raw -ErrorAction SilentlyContinue
                                if ($cachedMetadata) {
                                    $metadata = $cachedMetadata | Microsoft.PowerShell.Utility\ConvertFrom-Json -AsHashtable -ErrorAction Stop
                                }
                            }
                            catch {
                                Microsoft.PowerShell.Utility\Write-Verbose "Failed to read cached metadata: $_"
                                Microsoft.PowerShell.Utility\Write-Verbose "[Find-Image] Exception 7: $($_.Exception.Message)"
                                $metadata = GenXdev\Get-ImageMetadata -ImagePath $image
                                # save
                                $null = $metadata | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 |
                                    Microsoft.PowerShell.Management\Set-Content -LiteralPath $metadataStream -ErrorAction SilentlyContinue
                            }
                        }
                        else {
                            $metadata = GenXdev\Get-ImageMetadata -ImagePath $image
                            # save
                            $null = $metadata | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 |
                                Microsoft.PowerShell.Management\Set-Content -LiteralPath $metadataStream -ErrorAction SilentlyContinue
                        }

                        if ($null -ne $metadata) {
                            $width = $metadata.Basic.Width
                            $height = $metadata.Basic.Height
                        }
                        else {
                            # fallback to just getting dimensions if metadata extraction fails
                            $imageObj = [System.Drawing.Image]::FromFile($image)
                            $width = $imageObj.Width
                            $height = $imageObj.Height
                            $null = $imageObj.Dispose()
                        }
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose "[Find-Image] Exception 8: $($_.Exception.Message)"
                    }
                }

                if ($null -ne $objectsFound -and $null -ne $objectsFound.objects -and
                    $objectsFound.objects -isnot [System.Collections.IEnumerable]) {
                    $objectsFound.objects = @($objectsFound.objects)
                }
                elseif ($null -ne $objectsFound -and $null -ne $objectsFound.objects -and
                    $objectsFound.objects -is [string]) {
                    $objectsFound.objects = @($objectsFound.objects)
                }
                elseif ($null -ne $objectsFound -and $null -eq $objectsFound.objects) {
                    $objectsFound.objects = @()
                }

                if ($null -ne $peopleFound -and $null -ne $peopleFound.faces -and $peopleFound.faces -isnot [System.Collections.IEnumerable]) {
                    $peopleFound.faces = @($peopleFound.faces)
                }
                if ($null -ne $peopleFound -and $null -ne $peopleFound.predictions -and $peopleFound.predictions -isnot [System.Collections.IEnumerable]) {
                    $peopleFound.predictions = @($peopleFound.predictions)
                }
                if ($null -ne $keywordsFound -and $keywordsFound -isnot [System.Collections.IEnumerable]) {
                    $keywordsFound = @($keywordsFound)
                }

                # Ensure Description object has proper structure with Keywords
                if ($null -eq $descriptionFound) {
                    $descriptionFound = @{}
                }
                if ($null -ne $keywordsFound) {
                    $descriptionFound.Keywords = $keywordsFound
                }

                $obj = @{
                    Path        = $image
                    Width       = $metadata.Basic.Width
                    Height      = $metadata.Basic.Height
                    Metadata    = $metadata
                    Description = $descriptionFound
                    People      = $peopleFound
                    Objects     = $objectsFound
                    Scenes      = $scenesFound
                }
                [GenXdev.Helpers.ImageSearchResult] $standardizedOutput = $null
                $json = $obj | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 -Compress;
                try {
                    $standardizedOutput = [GenXdev.Helpers.ImageSearchResult]::FromJson((
                            $json)
                    );
                }
                catch {
                    $msg = "[Find-Image] Exception 9: $($_.Exception.Message)";
                    Microsoft.PowerShell.Utility\Write-Verbose $msg;
                    throw;
                }

                Microsoft.PowerShell.Utility\Write-Output $standardizedOutput
            }
        }

        # search for image files (jpg, jpeg, gif, png, bmp, webp, tiff, tif) and process each one found
        @(GenXdev\Find-Item `
                @FindItemParams `
                -Name $Name `
                -Category Pictures `
                -PassThru
        ) | Microsoft.PowerShell.Core\ForEach-Object {

            try {
                # process the image file and handle output appropriately based on display mode
                processImageFile $_ |
                    Microsoft.PowerShell.Core\ForEach-Object {

                        # output directly or add to results based on browser display setting
                        if (-not $ShowInBrowser) {

                            # Convert to formatted ImageSearchResult object
                            $_  #| GenXdev\ConvertTo-ImageSearchResult
                        }
                        else {

                            # add to results collection for browser display
                            $null = $results.Add($_)
                        }
                    }
                }
                catch {
                    $msg = "[Find-Image] Exception 10: $($_.Exception.Message)";
                    Microsoft.PowerShell.Utility\Write-Verbose $msg;
                }
            }
    }

    end {

        # if showinbrowser is requested, display the gallery using browser interface
        if ($ShowInBrowser) {

            # check if any results were found before attempting to display
            if ((-not $results) -or ($null -eq $results) -or
                ($results.Length -eq 0)) {

                # notify user that no images matched the search criteria
                Microsoft.PowerShell.Utility\Write-Host ('No images found')

                return
            }

            # set default title if empty to provide meaningful gallery header
            if ([String]::IsNullOrWhiteSpace($Title)) {

                $Title = 'Image Search Results'
            }

            # set default description if empty to show the original command
            if ([String]::IsNullOrWhiteSpace($Description)) {

                $Description = $MyInvocation.Statement
            }

            # copy parameters for show function call using helper function
            $params = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\Show-FoundImagesInBrowser' 

            # pass the results to show-foundimagesinbrowser for display
            GenXdev\Show-FoundImagesInBrowser @params -InputObject $results

            # return results if passthru is requested for further processing
            if ($PassThru) {

                # output each result object to pipeline with formatting
                $results | Microsoft.PowerShell.Core\ForEach-Object { $_ } # GenXdev\ConvertTo-ImageSearchResult
            }
        }
    }
}
###############################################################################