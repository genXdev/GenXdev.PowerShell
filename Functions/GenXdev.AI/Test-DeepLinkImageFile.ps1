###############################################################################
<#
.SYNOPSIS
Tests if the specified file path is a valid image file with a supported format.

.DESCRIPTION
This function validates that a file exists at the specified path and has a
supported image file extension. It checks for common image formats including
PNG, JPG, JPEG, GIF, BMP, WebP, TIFF, and TIF files. The function throws
exceptions for invalid paths or unsupported file formats.

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
The file path to the image file to be tested. Must be a valid file system path.

.EXAMPLE
Test-DeepLinkImageFile -Path "C:\Images\photo.jpg"

.EXAMPLE
Test-DeepLinkImageFile "C:\Images\logo.png"
#>
function Test-DeepLinkImageFile {

    [CmdletBinding()]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The file path to the image file to be tested'
        )]
        [string] $Path
        ###############################################################################
    )

    begin {

        # define supported image file extensions
        $validExtensions = @('.png', '.jpg', '.jpeg', '.gif', '.bmp', '.webp', '.tiff', '.tif')
    }

    process {

        # check if the file exists at the specified path
        if (-not ([IO.File]::Exists($Path))) {

            throw "Image file not found: $Path"
        }

        # get the file extension and convert to lowercase for comparison
        $fileExtension = [System.IO.Path]::GetExtension($Path).ToLower()

        # verify the file has a supported image format extension
        if ($validExtensions -notcontains $fileExtension) {

            throw ('Invalid image format. Supported formats: ' +
                'png, jpg, jpeg, gif, bmp, webp, tiff, tif')
        }

        # output verbose information about successful validation
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Successfully validated image file: $Path"
        )
    }

    end {
    }
}