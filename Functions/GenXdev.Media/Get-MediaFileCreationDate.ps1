<#
.SYNOPSIS
Extracts the best-effort creation date for media and other files.

.DESCRIPTION
Attempts several strategies to determine an accurate creation or capture
date for the specified file. strategies include reading image EXIF metadata,
parsing date/time information from filenames, and falling back to the file's
last-write time when no other reliable information is available. the function
always returns a [DateTime]; when no date can be determined it returns
[DateTime]::MinValue.

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

.PARAMETER FilePath
Path to the file to inspect. the path is expanded and normalized by
`GenXdev\Expand-Path` before inspection.

.EXAMPLE
Get-MediaFileCreationDate -FilePath '.\IMG_20250601_123000.jpg'

.EXAMPLE
#>

function Get-MediaFileCreationDate {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true, ValueFromPipeline = $true, ValueFromPipelineByPropertyName = $true)]
        [string]$FilePath
    )
    process {
        # Expand and normalize the incoming path using your custom module helper
        $FilePath = GenXdev\Expand-Path $FilePath

        # Defensive check: if path doesn't exist, gracefully fallback or return epoch/null
        # but to guarantee no throwing, we safely fetch item details
        $fileInfo = $null
        try {
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $FilePath -PathType Leaf) {
                $fileInfo = Microsoft.PowerShell.Management\Get-Item -LiteralPath $FilePath -Force
            }
        }
        catch {
            # Suppress errors completely
        }

        if ($null -eq $fileInfo) {
            # Fallback safe return if the file cannot be read or found at all
            return [DateTime]::MinValue
        }

        # --- Method 1: Try Image Metadata for Photos ---
        if ($fileInfo.Extension -match '\.(jpg|jpeg|tif|tiff|png)$') {
            $img = $null
            try {
                # Load picture metadata using the standard .NET System.Drawing namespace
                Microsoft.PowerShell.Utility\Add-Type -AssemblyName System.Drawing -ErrorAction SilentlyContinue

                $img = [System.Drawing.Image]::FromFile($fileInfo.FullName)

                # EXIF tags: 0x9003 = DateTimeOriginal, 0x0132 = DateTime (Modified)
                $dateProperty = $null
                try { $dateProperty = $img.GetPropertyItem(0x9003) } catch {}
                if ($null -eq $dateProperty) {
                    try { $dateProperty = $img.GetPropertyItem(0x0132) } catch {}
                }

                if ($null -ne $dateProperty) {
                    # EXIF string format is typically "YYYY:MM:DD HH:MM:SS\0"
                    $asciiStr = [System.Text.Encoding]::ASCII.GetString($dateProperty.Value)
                    if ($null -ne $asciiStr) {
                        $asciiStr = $asciiStr.Replace("`0", "").Trim()

                        # Convert custom EXIF colons into standard hyphenated date format
                        if ($asciiStr -match '^(\d{4}):(\d{2}):(\d{2})\s(.*)$') {
                            $parsedDateString = "$($Matches[1])-$($Matches[2])-$($Matches[3]) $($Matches[4])"
                            $extractedDate = $parsedDateString -as [DateTime]

                            if ($null -ne $extractedDate) {
                                $img.Dispose()
                                return $extractedDate
                            }
                        }
                    }
                }
            }
            catch {
                # Suppress exceptions completely and step to next method
            }
            finally {
                # Guaranteed cleanup of the file handle lock if open
                if ($null -ne $img) {
                    try { $img.Dispose() } catch {}
                }
            }
        }

        # --- Method 2: Intelligent Filename Parsing ---
        try {
            $baseName = $fileInfo.BaseName
            # Looks for 2026-06-14, 2026_06_14, or 20260614 bordered by non-digits
            $dateRegex = '(?<!\d)(\d{4})([-_]?)(\d{2})\2(\d{2})(?!\d)'

            if ($baseName -match $dateRegex) {
                $year = $Matches[1]
                $month = $Matches[3]
                $day = $Matches[4]

                # Check if there is an accompanying timestamp right after it (e.g., _060619)
                # Looking for an optional non-digit separator followed by HHMMSS
                $timeRegex = "(?<!\d)$year[-_]?$month[-_]?$day[-_ ]?(\d{2})(\d{2})(\d{2})(?!\d)"
                if ($baseName -match $timeRegex) {
                    $hour = $Matches[1]
                    $minute = $Matches[2]
                    $second = $Matches[3]
                    $constructedDateStr = "$year-$month-$day ${hour}:${minute}:$second"
                }
                else {
                    $constructedDateStr = "$year-$month-$day"
                }

                # Natively cast via the safe type operator; never throws an overload error
                $parsedDate = $constructedDateStr -as [DateTime]
                if ($null -ne $parsedDate) {
                    return $parsedDate
                }
            }
        }
        catch {
            # Suppress filename parsing exceptions completely
        }

        # --- Method 3: Ultimate Fallback to File Last Modified Date ---
        try {
            return $fileInfo.LastWriteTime
        }
        catch {
            # Ultimate safety fallback if file IO is entirely restricted
            return [DateTime]::MinValue
        }
    }
}