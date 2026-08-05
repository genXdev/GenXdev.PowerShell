# Find-Image

> **SubModule:** GenXdev.AI.Queries | **Type:** Function | **Aliases:** `findimages`, `li`

## Synopsis

> Searches for image files and metadata in specified directories with filtering
capabilities and optional browser-based gallery display.

## Description

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


## Syntax

```powershell
Find-Image [[-Any] <String[]>] [[-Name] <String[]>] [-AcceptLang <String>] [-All] [-AllDrives] [-ApplicationMode] [-AttributesToSkip <IO.FileAttributes>] [-AutoAnimateRectangles] [-AutoScrollPixelsPerSecond <Int32>] [-Bottom] [-Centered] [-Chrome] [-Chromium] [-ClearSession] [-Description <String>] [-DescriptionSearch <String[]>] [-DisablePopupBlocker] [-Edge] [-EmbedImages] [-Firefox] [-FocusWindow] [-FollowSymlinkAndJunctions] [-Force] [-FullScreen] [-GeoDistanceInMeters <Double>] [-GeoLocation <Double[]>] [-HasExplicitContent] [-HasNudity] [-Headless] [-Height <Int32>] [-ImageUrlPrefix <String>] [-Interactive] [-KeysToSend <String[]>] [-Keywords <String[]>] [-Language <String>] [-Left] [-MaxFileSize <Int64>] [-Maximize] [-MaxRecursionDepth <Int32>] [-MaxSearchUpDepth <Int32>] [-MetaCameraMake <String[]>] [-MetaCameraModel <String[]>] [-MetaDateTaken <DateTime[]>] [-MetaExposureTime <Double[]>] [-MetaFNumber <Double[]>] [-MetaFocalLength <Double[]>] [-MetaGPSAltitude <Double[]>] [-MetaGPSLatitude <Double[]>] [-MetaGPSLongitude <Double[]>] [-MetaHeight <Int32[]>] [-MetaISO <Int32[]>] [-MetaWidth <Int32[]>] [-MinConfidenceRatio <Double>] [-MinFileSize <Int64>] [-ModifiedAfter <DateTime>] [-ModifiedBefore <DateTime>] [-Monitor <Int32>] [-NeverRebuild] [-NewWindow] [-NoBorders] [-NoBrowserExtensions] [-NoExplicitContent] [-NoFallback] [-NoNudity] [-NoRecurse] [-Objects <String[]>] [-OnlyReturnHtml] [-OverallMood <String[]>] [-PassThru] [-People <String[]>] [-PictureType <String[]>] [-PlayWright] [-PreferencesDatabasePath <String>] [-Private] [-RestoreFocus] [-Right] [-Scenes <String[]>] [-SendKeyDelayMilliSeconds <Int32>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-SetRestored] [-ShowInBrowser] [-ShowOnlyPictures] [-SideBySide] [-SingleColumnMode] [-SkipSession] [-StyleType <String[]>] [-Title <String>] [-Top] [-Webkit] [-Width <Int32>] [-X <Int32>] [-Y <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Any` | String[] | ☐ | Will match any of all the possible meta data<br>types. |
| `-Name` | String[] | ☐ | Array of directory paths to search for images |
| `-Language` | String | ☐ | Language for descriptions and keywords. |
| `-DescriptionSearch` | String[] | ☐ | The description text to look for, wildcards <br>allowed. |
| `-Keywords` | String[] | ☐ | The keywords to look for, wildcards allowed. |
| `-People` | String[] | ☐ | People to look for, wildcards allowed. |
| `-Objects` | String[] | ☐ | Objects to look for, wildcards allowed. |
| `-Scenes` | String[] | ☐ | Scene categories to look for, wildcards<br>allowed. |
| `-PictureType` | String[] | ☐ | Picture type to filter by (e.g., 'daylight', <br>'evening', 'indoor', etc). Supports<br>wildcards. |
| `-StyleType` | String[] | ☐ | Style type to filter by (e.g., 'casual',<br>'formal',  etc). Supports wildcards. |
| `-OverallMood` | String[] | ☐ | Overall mood to filter by (e.g., 'calm', <br>'cheerful', 'sad', etc). Supports wildcards. |
| `-MetaCameraMake` | String[] | ☐ | Filter by camera make in image EXIF metadata.<br>Supports wildcards. |
| `-MetaCameraModel` | String[] | ☐ | Filter by camera model in image EXIF<br>metadata. Supports wildcards. |
| `-MetaGPSLatitude` | Double[] | ☐ | Filter by GPS latitude range in image EXIF<br>metadata. |
| `-MetaGPSLongitude` | Double[] | ☐ | Filter by GPS longitude range in image EXIF<br>metadata. |
| `-MetaGPSAltitude` | Double[] | ☐ | Filter by GPS altitude range in image EXIF<br>metadata (in meters). |
| `-GeoLocation` | Double[] | ☐ | Geographic coordinates [latitude, longitude]<br>to search near. |
| `-GeoDistanceInMeters` | Double | ☐ | Maximum distance in meters from GeoLocation<br>to search for images. |
| `-MetaExposureTime` | Double[] | ☐ | Filter by exposure time range in image EXIF<br>metadata (in seconds). |
| `-MetaFNumber` | Double[] | ☐ | Filter by F-number (aperture) range in image<br>EXIF metadata. |
| `-MetaISO` | Int32[] | ☐ | Filter by ISO sensitivity range in image EXIF<br>metadata. |
| `-MetaFocalLength` | Double[] | ☐ | Filter by focal length range in image EXIF<br>metadata (in mm). |
| `-MetaWidth` | Int32[] | ☐ | Filter by image width range in pixels from<br>EXIF metadata. |
| `-MetaHeight` | Int32[] | ☐ | Filter by image height range in pixels from<br>EXIF metadata. |
| `-MetaDateTaken` | DateTime[] | ☐ | Filter by date taken from EXIF metadata. Can<br>be a date range. |
| `-Title` | String | ☐ | Title for the gallery |
| `-Description` | String | ☐ | Description for the gallery |
| `-AcceptLang` | String | ☐ | Set the browser accept-lang http header |
| `-KeysToSend` | String[] | ☐ | Keystrokes to send to the Browser window, <br>see documentation for cmdlet GenXdev\Send-Key |
| `-SendKeyEscape` | SwitchParameter | ☐ | Escape control characters and modifiers when <br>sending keys |
| `-SendKeyHoldKeyboardFocus` | SwitchParameter | ☐ | Prevent returning keyboard focus to<br>PowerShell  after sending keys |
| `-SendKeyUseShiftEnter` | SwitchParameter | ☐ | Use Shift+Enter instead of Enter when sending<br>keys |
| `-SendKeyDelayMilliSeconds` | Int32 | ☐ | Delay between different input strings in <br>milliseconds when sending keys |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the browser window after opening |
| `-SetForeground` | SwitchParameter | ☐ | Set the browser window to foreground after<br>opening |
| `-Maximize` | SwitchParameter | ☐ | Maximize the window after positioning |
| `-SetRestored` | SwitchParameter | ☐ | Restore the window to normal state after<br>positioning |
| `-Monitor` | Int32 | ☐ | The monitor to use, 0 = default, -1 is<br>discard,  -2 = Configured secondary monitor,<br>defaults to  `Global:DefaultSecondaryMonitor<br>or 2 if not found |
| `-Width` | Int32 | ☐ | The initial width of the webbrowser window |
| `-Height` | Int32 | ☐ | The initial height of the webbrowser window |
| `-X` | Int32 | ☐ | The initial X position of the webbrowser<br>window |
| `-Y` | Int32 | ☐ | The initial Y position of the webbrowser<br>window |
| `-PreferencesDatabasePath` | String | ☐ | Database path for preference data files |
| `-EmbedImages` | SwitchParameter | ☐ | Embed images as base64. |
| `-NoFallback` | SwitchParameter | ☐ | Switch to disable fallback behavior. |
| `-NeverRebuild` | SwitchParameter | ☐ | Switch to skip database initialization and<br>rebuilding. |
| `-AllDrives` | SwitchParameter | ☐ | Search across all available drives |
| `-NoRecurse` | SwitchParameter | ☐ | Do not recurse into subdirectories |
| `-FollowSymlinkAndJunctions` | SwitchParameter | ☐ | Follow symlinks and junctions during<br>directory traversal. |
| `-MaxRecursionDepth` | Int32 | ☐ | Maximum recursion depth for directory<br>traversal. 0 means unlimited. |
| `-MaxSearchUpDepth` | Int32 | ☐ | Maximum recursion depth for continuing<br>searching upwards the tree for relative<br>searches, while no items are found. 0 means<br>disabled. |
| `-MaxFileSize` | Int64 | ☐ | Maximum file size in bytes to include in<br>results. 0 means unlimited. |
| `-MinFileSize` | Int64 | ☐ | Minimum file size in bytes to include in<br>results. 0 means no minimum. |
| `-ModifiedAfter` | DateTime | ☐ | Only include files modified after this<br>date/time (UTC). |
| `-ModifiedBefore` | DateTime | ☐ | Only include files modified before this<br>date/time (UTC). |
| `-AttributesToSkip` | IO.FileAttributes | ☐ | File attributes to skip (e.g., System, Hidden<br>or None). |
| `-HasNudity` | SwitchParameter | ☐ | Filter images that contain nudity. |
| `-NoNudity` | SwitchParameter | ☐ | Filter images that do NOT contain nudity. |
| `-HasExplicitContent` | SwitchParameter | ☐ | Filter images that contain explicit content. |
| `-NoExplicitContent` | SwitchParameter | ☐ | Filter images that do NOT contain explicit<br>content. |
| `-ShowInBrowser` | SwitchParameter | ☐ | Display the search results in a browser-based<br>image gallery. |
| `-PassThru` | SwitchParameter | ☐ | Return image data as objects. When used with <br>-ShowInBrowser, both displays the gallery and<br>returns  the objects. |
| `-NoBorders` | SwitchParameter | ☐ | Remove window borders and title bar for a<br>cleaner appearance |
| `-SideBySide` | SwitchParameter | ☐ | Place browser window side by side with<br>PowerShell on the same monitor |
| `-Interactive` | SwitchParameter | ☐ | Will connect to browser and adds additional <br>buttons like Edit and Delete. Only effective<br>when used with  -ShowInBrowser. |
| `-Private` | SwitchParameter | ☐ | Opens in incognito/private browsing mode |
| `-Force` | SwitchParameter | ☐ | Force enable debugging port, stopping<br>existing  browsers if needed |
| `-Edge` | SwitchParameter | ☐ | Opens in Microsoft Edge |
| `-Chrome` | SwitchParameter | ☐ | Opens in Google Chrome |
| `-Chromium` | SwitchParameter | ☐ | Opens in Microsoft Edge or Google Chrome, <br>depending on what the default browser is |
| `-Firefox` | SwitchParameter | ☐ | Opens in Firefox |
| `-PlayWright` | SwitchParameter | ☐ | Use Playwright-managed browser instead of the<br>OS-installed browser |
| `-Webkit` | SwitchParameter | ☐ | Opens the Playwright-managed WebKit browser. <br>Implies -PlayWright |
| `-Headless` | SwitchParameter | ☐ | Run the browser without a visible window |
| `-All` | SwitchParameter | ☐ | Opens in all registered modern browsers |
| `-FullScreen` | SwitchParameter | ☐ | Opens in fullscreen mode |
| `-Left` | SwitchParameter | ☐ | Place browser window on the left side of the<br>screen |
| `-Right` | SwitchParameter | ☐ | Place browser window on the right side of the<br>screen |
| `-Top` | SwitchParameter | ☐ | Place browser window on the top side of the<br>screen |
| `-Bottom` | SwitchParameter | ☐ | Place browser window on the bottom side of<br>the screen |
| `-Centered` | SwitchParameter | ☐ | Place browser window in the center of the<br>screen |
| `-ApplicationMode` | SwitchParameter | ☐ | Hide the browser controls |
| `-NoBrowserExtensions` | SwitchParameter | ☐ | Prevent loading of browser extensions |
| `-DisablePopupBlocker` | SwitchParameter | ☐ | Disable the popup blocker |
| `-RestoreFocus` | SwitchParameter | ☐ | Restore PowerShell window focus |
| `-NewWindow` | SwitchParameter | ☐ | Don't re-use existing browser window,<br>instead,  create a new one |
| `-OnlyReturnHtml` | SwitchParameter | ☐ | Only return the generated HTML instead of <br>displaying it in a browser. |
| `-ShowOnlyPictures` | SwitchParameter | ☐ | Show only pictures in a rounded rectangle, no<br>text below. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences like Language, Image<br>collections, etc |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for  AI preferences like Language, Image<br>collections, etc |
| `-SkipSession` | SwitchParameter | ☐ | Dont use alternative settings stored in<br>session  for AI preferences like Language,<br>Image collections, etc |
| `-AutoScrollPixelsPerSecond` | Int32 | ☐ | Auto-scroll the page by this many pixels per<br>second (null to disable) |
| `-AutoAnimateRectangles` | SwitchParameter | ☐ | Animate rectangles (objects/faces) in visible<br>range, cycling every 300ms |
| `-SingleColumnMode` | SwitchParameter | ☐ | Force single column layout (centered, 1/3<br>screen width) |
| `-ImageUrlPrefix` | String | ☐ | Prefix to prepend to each image path (e.g.<br>for remote URLs) |
| `-MinConfidenceRatio` | Double | ☐ | Minimum confidence ratio (0.0-1.0) for<br>filtering  people, scenes, and objects by<br>confidence. Only returns data for  people,<br>scenes, and objects with confidence greater<br>than or equal  to this value. |

## Examples

### Find-Image -Keywords "cat","dog" -Name "C:\Photos\*" Searches for images containing 'cat' OR 'dog' keywords and returns the image objects.

```powershell
Find-Image -Keywords "cat","dog" -Name "C:\Photos\*"
Searches for images containing 'cat' OR 'dog' keywords and returns the image objects.
```

### findimages cat,dog "C:\Photos" Same as above using the alias and positional parameters.

```powershell
findimages cat,dog "C:\Photos"
Same as above using the alias and positional parameters.
```

### Find-Image -People "John","Jane" -Name "C:\Family\*" -ShowInBrowser Searches for photos containing John OR Jane and displays them in a web gallery.

```powershell
Find-Image -People "John","Jane" -Name "C:\Family\*" -ShowInBrowser
Searches for photos containing John OR Jane and displays them in a web gallery.
```

### Find-Image -Keywords "vacation" -People "John" -Objects "beach" -Name "C:\Photos\*" Searches for images that contain vacation keywords AND John as a person AND beach objects. All three criteria must be met (AND logic between parameter types).

```powershell
Find-Image -Keywords "vacation" -People "John" -Objects "beach" -Name "C:\Photos\*"
Searches for images that contain vacation keywords AND John as a person AND beach objects.
All three criteria must be met (AND logic between parameter types).
```

### Find-Image -MetaISO 100,800 -MetaFNumber 1.4,2.8 -Name "C:\Photos\*" Finds images with ISO between 100-800 AND aperture (F-number) between f/1.4-f/2.8. EXIF parameters use range filtering with [min, max] values.

```powershell
Find-Image -MetaISO 100,800 -MetaFNumber 1.4,2.8 -Name "C:\Photos\*"
Finds images with ISO between 100-800 AND aperture (F-number) between f/1.4-f/2.8.
EXIF parameters use range filtering with [min, max] values.
```

### Find-Image -Objects "car","bicycle" -Name "C:\Photos\*" -ShowInBrowser -PassThru Searches for images containing detected cars or bicycles, displays them in a gallery, and also returns the objects.

```powershell
Find-Image -Objects "car","bicycle" -Name "C:\Photos\*" -ShowInBrowser -PassThru
Searches for images containing detected cars or bicycles, displays them in a gallery, and also returns the objects.
```

### findimages -Language "Spanish" -Keywords "playa","sol" -Name "C:\Vacations\*" -ShowInBrowser Searches for images with Spanish metadata containing the keywords "playa" (beach) or "sol" (sun) and displays in gallery.

```powershell
findimages -Language "Spanish" -Keywords "playa","sol" -Name "C:\Vacations\*" -ShowInBrowser
Searches for images with Spanish metadata containing the keywords "playa" (beach) or "sol" (sun) and displays in gallery.
```

### Find-Image -Keywords "vacation" -People "John" -Objects "beach*" -Name "C:\Photos\*" Searches for vacation photos with John in them that also contain beach-related objects and returns the data objects.

```powershell
Find-Image -Keywords "vacation" -People "John" -Objects "beach*" -Name "C:\Photos\*"
Searches for vacation photos with John in them that also contain beach-related objects and returns the data objects.
```

### Find-Image -Scenes "beach","forest","mountain*" -Name "C:\Nature\*" -ShowInBrowser Searches for images classified as beach, forest, or mountain scenes and displays them in a gallery.

```powershell
Find-Image -Scenes "beach","forest","mountain*" -Name "C:\Nature\*" -ShowInBrowser
Searches for images classified as beach, forest, or mountain scenes and displays them in a gallery.
```

### Find-Image -NoNudity -NoExplicitContent -Name "C:\Family\*" -ShowInBrowser Searches for family-safe images (no nudity or explicit content) and displays them in a gallery.

```powershell
Find-Image -NoNudity -NoExplicitContent -Name "C:\Family\*" -ShowInBrowser
Searches for family-safe images (no nudity or explicit content) and displays them in a gallery.
```

### Find-Image -PictureType "daylight" -OverallMood "calm" -Name "C:\Photos\*" Searches for daylight photos with a calm/peaceful mood and returns the image objects.

```powershell
Find-Image -PictureType "daylight" -OverallMood "calm" -Name "C:\Photos\*"
Searches for daylight photos with a calm/peaceful mood and returns the image objects.
```

### findimages -StyleType "casual" -HasNudity -Name "C:\Art\*" Searches for casual style images that contain nudity and returns the data objects.

```powershell
findimages -StyleType "casual" -HasNudity -Name "C:\Art\*"
Searches for casual style images that contain nudity and returns the data objects.
```

### Find-Image -Scenes "beach" -MinConfidenceRatio 0.75 -Name "C:\Photos\*" Searches for beach scenes with confidence level of 75% or higher and filters people, scenes, and objects data by confidence.

```powershell
Find-Image -Scenes "beach" -MinConfidenceRatio 0.75 -Name "C:\Photos\*"
Searches for beach scenes with confidence level of 75% or higher and filters people, scenes, and objects data by confidence.
```

## Parameter Details

### `-Any <String[]>`

> Will match any of all the possible meta data types.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Name <String[]>`

> Array of directory paths to search for images

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `@('.\')` |
| **Accept pipeline input?** | False |
| **Aliases** | `imagespath`, `directories`, `imgdirs`, `imagedirectory`, `ImageDirectories` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Language <String>`

> Language for descriptions and keywords.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DescriptionSearch <String[]>`

> The description text to look for, wildcards  allowed.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Keywords <String[]>`

> The keywords to look for, wildcards allowed.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-People <String[]>`

> People to look for, wildcards allowed.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Objects <String[]>`

> Objects to look for, wildcards allowed.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Scenes <String[]>`

> Scene categories to look for, wildcards allowed.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PictureType <String[]>`

> Picture type to filter by (e.g., 'daylight',  'evening', 'indoor', etc). Supports wildcards.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-StyleType <String[]>`

> Style type to filter by (e.g., 'casual', 'formal',  etc). Supports wildcards.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-OverallMood <String[]>`

> Overall mood to filter by (e.g., 'calm',  'cheerful', 'sad', etc). Supports wildcards.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaCameraMake <String[]>`

> Filter by camera make in image EXIF metadata. Supports wildcards.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaCameraModel <String[]>`

> Filter by camera model in image EXIF metadata. Supports wildcards.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `@()` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaGPSLatitude <Double[]>`

> Filter by GPS latitude range in image EXIF metadata.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaGPSLongitude <Double[]>`

> Filter by GPS longitude range in image EXIF metadata.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaGPSAltitude <Double[]>`

> Filter by GPS altitude range in image EXIF metadata (in meters).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-GeoLocation <Double[]>`

> Geographic coordinates [latitude, longitude] to search near.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-GeoDistanceInMeters <Double>`

> Maximum distance in meters from GeoLocation to search for images.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `1000` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaExposureTime <Double[]>`

> Filter by exposure time range in image EXIF metadata (in seconds).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaFNumber <Double[]>`

> Filter by F-number (aperture) range in image EXIF metadata.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaISO <Int32[]>`

> Filter by ISO sensitivity range in image EXIF metadata.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaFocalLength <Double[]>`

> Filter by focal length range in image EXIF metadata (in mm).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaWidth <Int32[]>`

> Filter by image width range in pixels from EXIF metadata.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaHeight <Int32[]>`

> Filter by image height range in pixels from EXIF metadata.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MetaDateTaken <DateTime[]>`

> Filter by date taken from EXIF metadata. Can be a date range.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Title <String>`

> Title for the gallery

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `'Photo Gallery'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Description <String>`

> Description for the gallery

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `('Hover over images to see face recognition ' +
            'and object detection data')` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AcceptLang <String>`

> Set the browser accept-lang http header

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
| **Accept pipeline input?** | False |
| **Aliases** | `lang`, `locale` |
| **Accept wildcard characters?** | No |

<hr/>

### `-KeysToSend <String[]>`

> Keystrokes to send to the Browser window,  see documentation for cmdlet GenXdev\Send-Key

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyEscape`

> Escape control characters and modifiers when  sending keys

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `Escape` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyHoldKeyboardFocus`

> Prevent returning keyboard focus to PowerShell  after sending keys

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `HoldKeyboardFocus` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyUseShiftEnter`

> Use Shift+Enter instead of Enter when sending  keys

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

> Delay between different input strings in  milliseconds when sending keys

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DelayMilliSeconds` |
| **Accept wildcard characters?** | No |

<hr/>

### `-FocusWindow`

> Focus the browser window after opening

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

> Set the browser window to foreground after opening

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

> Maximize the window after positioning

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SetRestored`

> Restore the window to normal state after positioning

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Monitor <Int32>`

> The monitor to use, 0 = default, -1 is discard,  -2 = Configured secondary monitor, defaults to  `Global:DefaultSecondaryMonitor or 2 if not found

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-2` |
| **Accept pipeline input?** | False |
| **Aliases** | `m`, `mon` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Width <Int32>`

> The initial width of the webbrowser window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Height <Int32>`

> The initial height of the webbrowser window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-X <Int32>`

> The initial X position of the webbrowser window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Y <Int32>`

> The initial Y position of the webbrowser window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PreferencesDatabasePath <String>`

> Database path for preference data files

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DatabasePath` |
| **Accept wildcard characters?** | No |

<hr/>

### `-EmbedImages`

> Embed images as base64.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoFallback`

> Switch to disable fallback behavior.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NeverRebuild`

> Switch to skip database initialization and rebuilding.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

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

### `-HasNudity`

> Filter images that contain nudity.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoNudity`

> Filter images that do NOT contain nudity.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-HasExplicitContent`

> Filter images that contain explicit content.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoExplicitContent`

> Filter images that do NOT contain explicit content.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ShowInBrowser`

> Display the search results in a browser-based  image gallery.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `show`, `s` |
| **Accept wildcard characters?** | No |

<hr/>

### `-PassThru`

> Return image data as objects. When used with  -ShowInBrowser, both displays the gallery and returns  the objects.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `pt` |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoBorders`

> Remove window borders and title bar for a cleaner appearance

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nb` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SideBySide`

> Place browser window side by side with PowerShell on the same monitor

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `sbs` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Interactive`

> Will connect to browser and adds additional  buttons like Edit and Delete. Only effective when used with  -ShowInBrowser.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `i`, `editimages` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Private`

> Opens in incognito/private browsing mode

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `incognito`, `inprivate` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Force`

> Force enable debugging port, stopping existing  browsers if needed

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Edge`

> Opens in Microsoft Edge

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `e` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Chrome`

> Opens in Google Chrome

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ch` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Chromium`

> Opens in Microsoft Edge or Google Chrome,  depending on what the default browser is

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `c` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Firefox`

> Opens in Firefox

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ff` |
| **Accept wildcard characters?** | No |

<hr/>

### `-PlayWright`

> Use Playwright-managed browser instead of the  OS-installed browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `pw` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Webkit`

> Opens the Playwright-managed WebKit browser.  Implies -PlayWright

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `wk` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Headless`

> Run the browser without a visible window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `hl` |
| **Accept wildcard characters?** | No |

<hr/>

### `-All`

> Opens in all registered modern browsers

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

> Opens in fullscreen mode

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fs`, `f` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Left`

> Place browser window on the left side of the screen

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

> Place browser window on the right side of the screen

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

> Place browser window on the top side of the screen

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

> Place browser window on the bottom side of the screen

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

> Place browser window in the center of the screen

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ApplicationMode`

> Hide the browser controls

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `a`, `app`, `appmode` |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoBrowserExtensions`

> Prevent loading of browser extensions

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `de`, `ne`, `NoExtensions` |
| **Accept wildcard characters?** | No |

<hr/>

### `-DisablePopupBlocker`

> Disable the popup blocker

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `allowpopups` |
| **Accept wildcard characters?** | No |

<hr/>

### `-RestoreFocus`

> Restore PowerShell window focus

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `rf`, `bg` |
| **Accept wildcard characters?** | No |

<hr/>

### `-NewWindow`

> Don't re-use existing browser window, instead,  create a new one

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nw`, `new` |
| **Accept wildcard characters?** | No |

<hr/>

### `-OnlyReturnHtml`

> Only return the generated HTML instead of  displaying it in a browser.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ShowOnlyPictures`

> Show only pictures in a rounded rectangle, no  text below.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `NoMetadata`, `OnlyPictures` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Use alternative settings stored in session for  preferences like Language, Image collections, etc

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

> Clear alternative settings stored in session for  AI preferences like Language, Image collections, etc

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

> Dont use alternative settings stored in session  for AI preferences like Language, Image collections, etc

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoScrollPixelsPerSecond <Int32>`

> Auto-scroll the page by this many pixels per second (null to disable)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoAnimateRectangles`

> Animate rectangles (objects/faces) in visible range, cycling every 300ms

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SingleColumnMode`

> Force single column layout (centered, 1/3 screen width)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$false` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ImageUrlPrefix <String>`

> Prefix to prepend to each image path (e.g. for remote URLs)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `''` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MinConfidenceRatio <Double>`

> Minimum confidence ratio (0.0-1.0) for filtering  people, scenes, and objects by confidence. Only returns data for  people, scenes, and objects with confidence greater than or equal  to this value.

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

- `GenXdev.Helpers.ImageSearchResult`
- `String`

## Related Links

- [Add-EmoticonsToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-EmoticonsToText.md)
- [ConvertFrom-CorporateSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertFrom-CorporateSpeak.md)
- [ConvertFrom-DiplomaticSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertFrom-DiplomaticSpeak.md)
- [ConvertTo-CorporateSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-CorporateSpeak.md)
- [ConvertTo-DiplomaticSpeak](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-DiplomaticSpeak.md)
- [Get-AIKnownFacesRootpath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AIKnownFacesRootpath.md)
- [Get-AIMetaLanguage](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AIMetaLanguage.md)
- [Get-Fallacy](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-Fallacy.md)
- [Get-ScriptExecutionErrorFixPrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ScriptExecutionErrorFixPrompt.md)
- [Get-SimularMovieTitles](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SimularMovieTitles.md)
- [Invoke-AIPowershellCommand](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-AIPowershellCommand.md)
- [Invoke-ImageFacesUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageFacesUpdate.md)
- [Invoke-ImageKeywordUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageKeywordUpdate.md)
- [Invoke-ImageMetadataUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageMetadataUpdate.md)
- [Invoke-ImageObjectsUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageObjectsUpdate.md)
- [Invoke-ImageScenesUpdate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageScenesUpdate.md)
- [Invoke-LLMBooleanEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMBooleanEvaluation.md)
- [Invoke-LLMQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMQuery.md)
- [Invoke-LLMStringListEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMStringListEvaluation.md)
- [Invoke-LLMTextTransformation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-LLMTextTransformation.md)
- [Invoke-QueryImageContent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-QueryImageContent.md)
- [Remove-ImageMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-ImageMetaData.md)
- [Save-FoundImageFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Save-FoundImageFaces.md)
- [Save-Transcriptions](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Save-Transcriptions.md)
- [Set-AIKnownFacesRootpath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AIKnownFacesRootpath.md)
- [Set-AIMetaLanguage](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AIMetaLanguage.md)
- [Show-FoundImagesInBrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-FoundImagesInBrowser.md)
- [Start-AudioTranscription](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-AudioTranscription.md)
- [Update-AllImageMetaData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Update-AllImageMetaData.md)
