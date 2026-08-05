###############################################################################
<#
.SYNOPSIS
Extracts comprehensive metadata from an image file.

.DESCRIPTION
This function reads EXIF, IPTC and other metadata from an image file. It extracts
a wide range of information including camera details, exposure settings, GPS coordinates,
dates, copyright information, and more. It supports images that contain metadata
in their EXIF data (JPEG, TIFF) as well as PNG metadata.

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

.PARAMETER ImagePath
The full path to the image file to analyze. The file must be a valid image format
that supports metadata (JPEG, TIFF, PNG, etc.).

.PARAMETER AutoConsent
Force a consent prompt even if a preference is already set for ImageSharp package
installation, overriding any saved consent preferences.

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation and set a persistent
preference flag for ImageSharp packages, bypassing interactive consent prompts.

.OUTPUTS
System.Collections.Hashtable
Returns a hashtable containing all available metadata categories including:
- Basic (dimensions, format, etc.)
- Camera (make, model, etc.)
- Exposure (aperture, shutter speed, ISO, etc.)
- GPS (latitude, longitude, etc.)
- DateTime (when taken, modified, etc.)
- Author (artist, copyright, etc.)
- Additional (software, comments, etc.)

.EXAMPLE
Get-ImageMetadata -ImagePath "C:\Pictures\vacation.jpg"

.EXAMPLE
"C:\Pictures\vacation.jpg" | Get-ImageMetadata

.EXAMPLE
Get-ImageMetadata -ImagePath "C:\Pictures\photo.webp" -AutoConsentAllPackages
#>
function Get-ImageMetadata {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [OutputType([GenXdev.Helpers.ImageSearchResultMetadata])]

    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Path to the image file to analyze'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ImagePath,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to this installation type and set persistent flag..'
        )]
        [switch] $AutoConsent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to ALL third-party software installations and set persistent flag for ImageSharp packages.'
        )]
        [switch] $AutoConsentAllPackages,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
        ########################################################################
    )

    begin {
        [GenXdev.Helpers.ImageSearchResultMetadata] $metadata = [GenXdev.Helpers.ImageSearchResultMetadata]::new();

        # check if image path exists
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $ImagePath)) {

            Microsoft.PowerShell.Utility\Write-Error (
                "The specified image path '$ImagePath' does not exist."
            )

            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Processing image: $ImagePath"
        )

        # Define EXIF tags by their ID numbers for lookup
        $exifTags = @{
            # Version tags
            0x9000 = 'ExifVersion'
            0xA000 = 'FlashpixVersion'

            # Image data characteristics
            0xA001 = 'ColorSpace'
            0xA500 = 'Gamma'

            # Date and time
            0x9003 = 'DateTimeOriginal'
            0x9004 = 'DateTimeDigitized'
            0x9290 = 'SubsecTime'
            0x9291 = 'SubsecTimeOriginal'
            0x9292 = 'SubsecTimeDigitized'

            # Camera settings
            0x829A = 'ExposureTime'
            0x829D = 'FNumber'
            0x8822 = 'ExposureProgram'
            0x8824 = 'SpectralSensitivity'
            0x8827 = 'ISOSpeedRatings'
            0x8828 = 'OECF'
            0x9201 = 'ShutterSpeedValue'
            0x9202 = 'ApertureValue'
            0x9203 = 'BrightnessValue'
            0x9204 = 'ExposureBiasValue'
            0x9205 = 'MaxApertureValue'
            0x9206 = 'SubjectDistance'
            0x9207 = 'MeteringMode'
            0x9208 = 'LightSource'
            0x9209 = 'Flash'
            0x920A = 'FocalLength'
            0x9214 = 'SubjectArea'
            0xA20B = 'FlashEnergy'
            0xA20C = 'SpatialFrequencyResponse'
            0xA20E = 'FocalPlaneXResolution'
            0xA20F = 'FocalPlaneYResolution'
            0xA210 = 'FocalPlaneResolutionUnit'
            0xA214 = 'SubjectLocation'
            0xA215 = 'ExposureIndex'
            0xA217 = 'SensingMethod'
            0xA300 = 'FileSource'
            0xA301 = 'SceneType'
            0xA302 = 'CFAPattern'
            0xA401 = 'CustomRendered'
            0xA402 = 'ExposureMode'
            0xA403 = 'WhiteBalance'
            0xA404 = 'DigitalZoomRatio'
            0xA405 = 'FocalLengthIn35mmFilm'
            0xA406 = 'SceneCaptureType'
            0xA407 = 'GainControl'
            0xA408 = 'Contrast'
            0xA409 = 'Saturation'
            0xA40A = 'Sharpness'
            0xA40B = 'DeviceSettingDescription'
            0xA40C = 'SubjectDistanceRange'

            # Other tags
            0xA420 = 'ImageUniqueID'
            0x8769 = 'ExifIFDPointer'
            0x8825 = 'GPSInfoIFDPointer'

            # Maker notes
            0x927C = 'MakerNote'
            0x9286 = 'UserComment'

            # Camera manufacturer and model
            0x010F = 'Make'
            0x0110 = 'Model'
            0x0131 = 'Software'
            0x013B = 'Artist'
            0x8298 = 'Copyright'

            # GPS tags
            0x0000 = 'GPSVersionID'
            0x0001 = 'GPSLatitudeRef'
            0x0002 = 'GPSLatitude'
            0x0003 = 'GPSLongitudeRef'
            0x0004 = 'GPSLongitude'
            0x0005 = 'GPSAltitudeRef'
            0x0006 = 'GPSAltitude'
            0x0007 = 'GPSTimeStamp'
            0x0008 = 'GPSSatellites'
            0x0009 = 'GPSStatus'
            0x000A = 'GPSMeasureMode'
            0x000B = 'GPSDOP'
            0x000C = 'GPSSpeedRef'
            0x000D = 'GPSSpeed'
            0x000E = 'GPSTrackRef'
            0x000F = 'GPSTrack'
            0x0010 = 'GPSImgDirectionRef'
            0x0011 = 'GPSImgDirection'
            0x0012 = 'GPSMapDatum'
            0x0013 = 'GPSDestLatitudeRef'
            0x0014 = 'GPSDestLatitude'
            0x0015 = 'GPSDestLongitudeRef'
            0x0016 = 'GPSDestLongitude'
            0x0017 = 'GPSDestBearingRef'
            0x0018 = 'GPSDestBearing'
            0x0019 = 'GPSDestDistanceRef'
            0x001A = 'GPSDestDistance'
            0x001B = 'GPSProcessingMethod'
            0x001C = 'GPSAreaInformation'
            0x001D = 'GPSDateStamp'
            0x001E = 'GPSDifferential'

            # IPTC tags (added as EXIF tags by some software)
            0x83BB = 'IPTC-NAA'

            # Basic image info
            0x0100 = 'ImageWidth'
            0x0101 = 'ImageLength'
            0x0102 = 'BitsPerSample'
            0x0103 = 'Compression'
            0x0106 = 'PhotometricInterpretation'
            0x0112 = 'Orientation'
            0x0115 = 'SamplesPerPixel'
            0x011A = 'XResolution'
            0x011B = 'YResolution'
            0x011C = 'PlanarConfiguration'
            0x0128 = 'ResolutionUnit'
            0x0132 = 'DateTime'
        }
    }

    process {
        $image = $null
        try {

            # Load the image file
            Microsoft.PowerShell.Utility\Write-Verbose 'Loading image file'

            $actualPath = $ImagePath

            if ([IO.Path]::GetExtension($ImagePath).ToLowerInvariant() -eq '.webp') {

                # If the path is a script, execute it to get the actual image path
                $actualPath = [IO.Path]::GetTempFileName() + ".png";

                # Load ImageSharp packages with embedded consent using Copy-IdenticalParamValues
                $ensureParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\EnsureNuGetAssembly' `
                    -DefaultValues (
                    Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                        -ErrorAction SilentlyContinue
                )

                # Set specific parameters for ImageSharp packages
                $ensureParams['Description'] = 'Required for WebP image format processing and conversion'
                $ensureParams['Publisher'] = 'SixLabors'

                # Load required ImageSharp packages
                $ensureParams['PackageKey'] = 'SixLabors.ImageSharp'
                GenXdev\EnsureNuGetAssembly @ensureParams

                $ensureParams['PackageKey'] = 'Shorthand.ImageSharp.WebP'
                GenXdev\EnsureNuGetAssembly @ensureParams

                $ensureParams['PackageKey'] = 'SixLabors.ImageSharp.Drawing'
                GenXdev\EnsureNuGetAssembly @ensureParams

                try {
                    $webpImage = [SixLabors.ImageSharp.Image]::Load($ImagePath)
                    try {
                        # Use Save method with PNG encoder and file stream
                        $pngEncoder = [SixLabors.ImageSharp.Formats.Png.PngEncoder]::new()
                        $fileStream = [System.IO.File]::Create($actualPath)
                        try {
                            $webpImage.Save($fileStream, $pngEncoder)
                        }
                        finally {
                            $fileStream.Close()
                        }
                    }
                    finally {
                        if ($webpImage -and ($webpImage -is [IDisposable])) {
                            $webpImage.Dispose()
                        }
                    }
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning "Error converting WebP to PNG: $($_.Exception.Message)"
                }
            }
            try {
                $image = [System.Drawing.Image]::FromFile($actualPath)
            }
            catch {

                return;
            }
            finally {
                if ($actualPath -ne $ImagePath) {

                    # Clean up temporary file if created
                    Microsoft.PowerShell.Management\Remove-Item -LiteralPath $actualPath -Force -ErrorAction Ignore
                }
            }

            # Set basic image information
            $metadata.Basic.Width = $image.Width
            $metadata.Basic.Height = $image.Height
            $metadata.Basic.PixelFormat = $image.PixelFormat.ToString()
            $metadata.Basic.Format = $image.RawFormat.ToString()
            $metadata.Basic.HorizontalResolution = $image.HorizontalResolution
            $metadata.Basic.VerticalResolution = $image.VerticalResolution
            $metadata.Basic.FileSizeBytes = (Microsoft.PowerShell.Management\Get-Item -LiteralPath $ImagePath).Length
            $metadata.Basic.FileName = (Microsoft.PowerShell.Management\Get-Item -LiteralPath $ImagePath).Name
            $metadata.Basic.FileExtension = [System.IO.Path]::GetExtension($ImagePath).ToLower()

            # Get all property items
            $propertyItems = $image.PropertyItems

            # Process each property item
            foreach ($item in $propertyItems) {
                $tagName = $exifTags[[int]$item.Id]

                # Skip if we don't know what this tag is
                if (-not $tagName) {
                    continue
                }

                # Process based on tag type
                try {
                    switch ($tagName) {
                        # GPS coordinates handling
                        'GPSLatitude' {
                            # Already processed in GPS section
                        }
                        'GPSLongitude' {
                            # Already processed in GPS section
                        }
                        'GPSLatitudeRef' {
                            # Already processed in GPS section
                        }
                        'GPSLongitudeRef' {
                            # Already processed in GPS section
                        }

                        # Date/time strings
                        { $_ -match 'DateTime' } {
                            $value = [System.Text.Encoding]::ASCII.GetString($item.Value).TrimEnd([char]0)
                            try {
                                $metadata.DateTime."$tagName" = $value
                            }
                            catch {

                            }
                        }

                        # String values
                        { $_ -in 'Make', 'Model', 'Software', 'Artist', 'Copyright', 'UserComment' } {
                            $value = [System.Text.Encoding]::ASCII.GetString($item.Value).TrimEnd([char]0)
                            try {
                                if ($_ -in 'Make', 'Model') {
                                    $metadata.Camera."$tagName" = $value
                                }
                                elseif ($_ -in 'Artist', 'Copyright') {
                                    $metadata.Author."$tagName" = $value
                                }
                                else {
                                    $metadata.Other."$tagName" = $value
                                }
                            }
                            catch {

                            }
                        }

                        # Numeric values for exposure
                        { $_ -in 'FNumber', 'ExposureTime', 'ISOSpeedRatings', 'FocalLength', 'ExposureProgram', 'MeteringMode', 'Flash' } {
                            if ($item.Type -eq 5) {
                                # Rational type
                                if ($item.Value.Length -ge 8) {
                                    $numerator = [BitConverter]::ToUInt32($item.Value, 0)
                                    $denominator = [BitConverter]::ToUInt32($item.Value, 4)
                                    if ($denominator -ne 0) {
                                        $value = [math]::Round($numerator / $denominator, 2)
                                    }
                                    else {
                                        $value = 0
                                    }
                                }
                                else {
                                    $value = "Unknown format"
                                }
                            }
                            else {
                                $value = $item.Value[0]
                            }
                            try {
                                $metadata.Exposure."$tagName" = $value
                            }
                            catch {

                            }
                        }

                        # Default catch-all
                        default {
                            try {
                                $metadata.Other."$tagName" = "Binary data"
                            }
                            catch {

                            }
                        }
                    }
                }
                catch {
                    try {
                        $metadata.Other["Error_$tagName"] = "Failed to parse: $_"
                    }
                    catch {

                    }
                }
            }

            # Special handling for GPS data
            $latitudeRef = $propertyItems | Microsoft.PowerShell.Core\Where-Object { $_.Id -eq 0x0001 }
            $latitude = $propertyItems | Microsoft.PowerShell.Core\Where-Object { $_.Id -eq 0x0002 }
            $longitudeRef = $propertyItems | Microsoft.PowerShell.Core\Where-Object { $_.Id -eq 0x0003 }
            $longitude = $propertyItems | Microsoft.PowerShell.Core\Where-Object { $_.Id -eq 0x0004 }
            $altitude = $propertyItems | Microsoft.PowerShell.Core\Where-Object { $_.Id -eq 0x0006 }
            $altitudeRef = $propertyItems | Microsoft.PowerShell.Core\Where-Object { $_.Id -eq 0x0005 }

            if ($latitude -and $longitude -and $latitudeRef -and $longitudeRef) {
                # Parse latitude
                if ($latitude.Value.Length -ge 24) {
                    # 3 rational values (3 * 8 bytes)
                    $latDegNum = [BitConverter]::ToUInt32($latitude.Value, 0)
                    $latDegDen = [BitConverter]::ToUInt32($latitude.Value, 4)
                    $latMinNum = [BitConverter]::ToUInt32($latitude.Value, 8)
                    $latMinDen = [BitConverter]::ToUInt32($latitude.Value, 12)
                    $latSecNum = [BitConverter]::ToUInt32($latitude.Value, 16)
                    $latSecDen = [BitConverter]::ToUInt32($latitude.Value, 20)

                    if ($latDegDen -ne 0 -and $latMinDen -ne 0 -and $latSecDen -ne 0) {
                        $latDeg = $latDegNum / $latDegDen
                        $latMin = $latMinNum / $latMinDen
                        $latSec = $latSecNum / $latSecDen
                        $latDecimal = $latDeg + ($latMin / 60) + ($latSec / 3600)

                        # Apply reference direction
                        if ($latitudeRef.Value -eq [byte][char]'S') {
                            $latDecimal = - $latDecimal
                        }

                        $metadata.GPS.Latitude = $latDecimal
                        $metadata.GPS.LatitudeDMS = "$latDeg° $latMin' $latSec`""
                    }
                }
                else {
                    try {
                        # Simple rational format
                        $latNum = [BitConverter]::ToUInt32($latitude.Value, 0)
                        $latDen = [BitConverter]::ToUInt32($latitude.Value, 4)
                        if ($latDen -ne 0) {
                            $lat = $latNum / $latDen
                            # Apply reference direction
                            if ($latitudeRef.Value -eq [byte][char]'S') {
                                $lat = - $lat
                            }
                            $metadata.GPS.Latitude = $lat
                        }
                    }
                    catch {
                        $metadata.GPS.LatitudeError = "Failed to parse: $_"
                    }
                }

                # Parse longitude
                if ($longitude.Value.Length -ge 24) {
                    $lonDegNum = [BitConverter]::ToUInt32($longitude.Value, 0)
                    $lonDegDen = [BitConverter]::ToUInt32($longitude.Value, 4)
                    $lonMinNum = [BitConverter]::ToUInt32($longitude.Value, 8)
                    $lonMinDen = [BitConverter]::ToUInt32($longitude.Value, 12)
                    $lonSecNum = [BitConverter]::ToUInt32($longitude.Value, 16)
                    $lonSecDen = [BitConverter]::ToUInt32($longitude.Value, 20)

                    if ($lonDegDen -ne 0 -and $lonMinDen -ne 0 -and $lonSecDen -ne 0) {
                        $lonDeg = $lonDegNum / $lonDegDen
                        $lonMin = $lonMinNum / $lonMinDen
                        $lonSec = $lonSecNum / $lonSecDen
                        $lonDecimal = $lonDeg + ($lonMin / 60) + ($lonSec / 3600)

                        # Apply reference direction
                        if ($longitudeRef.Value -eq [byte][char]'W') {
                            $lonDecimal = - $lonDecimal
                        }

                        $metadata.GPS.Longitude = $lonDecimal
                        $metadata.GPS.LongitudeDMS = "$lonDeg° $lonMin' $lonSec`""
                    }
                }
                else {
                    try {
                        # Simple rational format
                        $lonNum = [BitConverter]::ToUInt32($longitude.Value, 0)
                        $lonDen = [BitConverter]::ToUInt32($longitude.Value, 4)
                        if ($lonDen -ne 0) {
                            $lon = $lonNum / $lonDen
                            # Apply reference direction
                            if ($longitudeRef.Value -eq [byte][char]'W') {
                                $lon = - $lon
                            }
                            $metadata.GPS.Longitude = $lon
                        }
                    }
                    catch {
                        $metadata.GPS.LongitudeError = "Failed to parse: $_"
                    }
                }
            }

            # Process altitude if available
            if ($altitude -and $altitudeRef) {
                try {
                    $altNum = [BitConverter]::ToUInt32($altitude.Value, 0)
                    $altDen = [BitConverter]::ToUInt32($altitude.Value, 4)
                    if ($altDen -ne 0) {
                        $alt = $altNum / $altDen
                        # If altitudeRef is 1, altitude is below sea level
                        if ($altitudeRef.Value -eq 1) {
                            $alt = - $alt
                        }
                        $metadata.GPS.Altitude = $alt
                    }
                }
                catch {
                    $metadata.GPS.AltitudeError = "Failed to parse: $_"
                }
            }

            return
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to process image metadata: $_"
            )
            return
        }
        finally {
            if ($image) {
                $image.Dispose()
            }
        }
    }

    end {
        return $metadata;
    }
}