using System.Collections;
using System.Management.Automation;

namespace GenXdev.Media
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Extracts geolocation data from an image file.
.DESCRIPTION
* Reads EXIF metadata from an image file to extract its latitude and
  longitude coordinates.
* Supports images that contain GPS metadata in their EXIF data.
* Uses the System.Drawing.Image class to load the image and parse the GPS
  coordinates from property items.

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

.EXAMPLE
```powershell
Get-ImageGeolocation -ImagePath ""C:\Pictures\vacation.jpg""
```

Extracts GPS coordinates from a vacation photo.
.EXAMPLE
```powershell
""C:\Pictures\vacation.jpg"" | Get-ImageGeolocation
```

Uses the pipeline to pass the image path.
")]
    [Cmdlet(VerbsCommon.Get, "ImageGeolocation")]
    [OutputType(typeof(Hashtable))]
    public class GetImageGeolocationCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The full path to the image file to analyze
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Path to the image file to analyze")]
        [ValidateNotNullOrEmpty]
        public string ImagePath { get; set; }

        /// <summary>
        /// Begin processing - validate image path exists
        /// </summary>
        protected override void BeginProcessing()
        {
            // Use PowerShell Test-Path for exact path resolution behavior
            var scriptBlock = ScriptBlock.Create("param($path) Test-Path -LiteralPath $path");
            var testResult = scriptBlock.Invoke(ImagePath);

            if (!(bool)testResult[0].BaseObject)
            {
                WriteError(new ErrorRecord(
                    new FileNotFoundException($"The specified image path '{ImagePath}' does not exist."),
                    "PathNotFound",
                    ErrorCategory.ObjectNotFound,
                    ImagePath));
                return;
            }

            WriteVerbose($"Processing image: {ImagePath}");
        }

        /// <summary>
        /// Process record - extract GPS metadata from image
        /// </summary>
        protected override void ProcessRecord()
        {
            Image image = null;

            try
            {
                // Load the image file
                WriteVerbose("Loading image file");
                image = Image.FromFile(ImagePath);

                // Get all property items
                var propertyItems = image.PropertyItems;

                // Extract GPS metadata properties
                WriteVerbose("Extracting GPS metadata");
                var latitudeRef = propertyItems.FirstOrDefault(pi => pi.Id == 0x0001);
                var latitude = propertyItems.FirstOrDefault(pi => pi.Id == 0x0002);
                var longitudeRef = propertyItems.FirstOrDefault(pi => pi.Id == 0x0003);
                var longitude = propertyItems.FirstOrDefault(pi => pi.Id == 0x0004);

                // Check if GPS data exists
                if (latitude != null && longitude != null && latitudeRef != null && longitudeRef != null)
                {
                    // Calculate actual latitude and longitude values
                    uint latNum = BitConverter.ToUInt32(latitude.Value, 0);
                    uint latDen = BitConverter.ToUInt32(latitude.Value, 4);
                    double lat = (double)latNum / latDen;

                    uint lonNum = BitConverter.ToUInt32(longitude.Value, 0);
                    uint lonDen = BitConverter.ToUInt32(longitude.Value, 4);
                    double lon = (double)lonNum / lonDen;

                    // Adjust for south and west hemispheres
                    if (latitudeRef.Value[0] == (byte)'S')
                    {
                        lat = -lat;
                    }

                    if (longitudeRef.Value[0] == (byte)'W')
                    {
                        lon = -lon;
                    }

                    WriteVerbose($"GPS coordinates found: {lat}, {lon}");

                    var result = new Hashtable
                    {
                        ["Latitude"] = lat,
                        ["Longitude"] = lon
                    };

                    WriteObject(result);
                }
                else
                {
                    WriteVerbose("No GPS metadata found in image");
                    WriteObject(null);
                }
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "ImageProcessingError",
                    ErrorCategory.InvalidOperation,
                    ImagePath));
            }
            finally
            {
                if (image != null)
                {
                    image.Dispose();
                }
            }
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}