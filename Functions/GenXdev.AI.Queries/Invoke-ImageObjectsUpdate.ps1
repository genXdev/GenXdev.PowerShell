###############################################################################
<#
.SYNOPSIS
Updates object detection metadata for image files in a specified directory.

.DESCRIPTION
This function processes images in a specified directory to detect objects using
artificial intelligence. It creates JSON metadata files containing detected
objects, their positions, confidence scores, and labels. The function supports
batch processing with configurable confidence thresholds and can optionally
skip existing metadata files or retry previously failed detections.

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

.PARAMETER ImageDirectories
Array of directory paths containing images to process. Can be relative or
absolute paths. Default is the current directory.

.PARAMETER Recurse
If specified, processes images in the specified directory and all
subdirectories recursively.

.PARAMETER OnlyNew
If specified, only processes images that don't already have object metadata
files or have empty metadata files.

.PARAMETER RetryFailed
If specified, retries processing previously failed images that have empty
metadata files or contain error indicators.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. Used when already called
by parent function to avoid redundant container setup.

.PARAMETER ConfidenceThreshold
Minimum confidence threshold (0.0-1.0) for object detection. Objects detected
with confidence below this threshold will be filtered out. Default is 0.5.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch
is used. This will recreate the entire detection environment.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. Requires an NVIDIA GPU
with appropriate drivers and CUDA support.

.PARAMETER ContainerName
The name for the Docker container running the object detection service.
Default is "deepstack_face_recognition".

.PARAMETER VolumeName
The name for the Docker volume for persistent storage of detection models
and data. Default is "deepstack_face_data".

.PARAMETER ServicePort
The port number for the DeepStack service to listen on. Must be between
1 and 65535. Default is 5000.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check before timing out.
Must be between 10 and 300 seconds. Default is 60.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts when waiting for service
startup. Must be between 1 and 10 seconds. Default is 3.

.PARAMETER ImageName
Custom Docker image name to use instead of the default DeepStack image.
Allows using alternative object detection models or configurations.

.EXAMPLE
Invoke-ImageObjectsUpdate -ImageDirectories @("C:\Photos", "D:\Pictures") -Recurse

This example processes all images in C:\Photos and D:\Pictures and all
subdirectories using default settings with 0.5 confidence threshold.

.EXAMPLE
Invoke-ImageObjectsUpdate @("C:\Photos", "C:\Archive") -RetryFailed -OnlyNew

This example processes only new images and retries previously failed ones
in multiple directories using positional parameter syntax.

.EXAMPLE
Invoke-ImageObjectsUpdate -ImageDirectories "C:\Photos" -UseGPU `
    -ConfidenceThreshold 0.7

This example uses GPU acceleration with higher confidence threshold of 0.7
for more accurate but fewer object detections.
#>
function Invoke-ImageObjectsUpdate {

    [CmdletBinding()]
    [Alias('imageobjectdetection')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The directory paths containing images to process'
        )]
        [string[]] $ImageDirectories = @('.\'),

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Process images in specified directory and all ' +
                'subdirectories')
        )]
        [switch] $Recurse,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ("Only process images that don't already have face " +
                'metadata files')
        )]
        [switch] $OnlyNew,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will retry previously failed image keyword ' +
                'updates')
        )]
        [switch] $RetryFailed,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The language for generated descriptions and ' +
                'keywords')
        )]
        [PSDefaultValue(Value = 'English')]
        [ValidateSet(
            'Afrikaans',
            'Akan',
            'Albanian',
            'Amharic',
            'Arabic',
            'Armenian',
            'Azerbaijani',
            'Basque',
            'Belarusian',
            'Bemba',
            'Bengali',
            'Bihari',
            'Bosnian',
            'Breton',
            'Bulgarian',
            'Cambodian',
            'Catalan',
            'Cherokee',
            'Chichewa',
            'Chinese (Simplified)',
            'Chinese (Traditional)',
            'Corsican',
            'Croatian',
            'Czech',
            'Danish',
            'Dutch',
            'English',
            'Esperanto',
            'Estonian',
            'Ewe',
            'Faroese',
            'Filipino',
            'Finnish',
            'French',
            'Frisian',
            'Ga',
            'Galician',
            'Georgian',
            'German',
            'Greek',
            'Guarani',
            'Gujarati',
            'Haitian Creole',
            'Hausa',
            'Hawaiian',
            'Hebrew',
            'Hindi',
            'Hungarian',
            'Icelandic',
            'Igbo',
            'Indonesian',
            'Interlingua',
            'Irish',
            'Italian',
            'Japanese',
            'Javanese',
            'Kannada',
            'Kazakh',
            'Kinyarwanda',
            'Kirundi',
            'Kongo',
            'Korean',
            'Krio (Sierra Leone)',
            'Kurdish',
            'Kurdish (Soranî)',
            'Kyrgyz',
            'Laothian',
            'Latin',
            'Latvian',
            'Lingala',
            'Lithuanian',
            'Lozi',
            'Luganda',
            'Luo',
            'Macedonian',
            'Malagasy',
            'Malay',
            'Malayalam',
            'Maltese',
            'Maori',
            'Marathi',
            'Mauritian Creole',
            'Moldavian',
            'Mongolian',
            'Montenegrin',
            'Nepali',
            'Nigerian Pidgin',
            'Northern Sotho',
            'Norwegian',
            'Norwegian (Nynorsk)',
            'Occitan',
            'Oriya',
            'Oromo',
            'Pashto',
            'Persian',
            'Polish',
            'Portuguese (Brazil)',
            'Portuguese (Portugal)',
            'Punjabi',
            'Quechua',
            'Romanian',
            'Romansh',
            'Runyakitara',
            'Russian',
            'Scots Gaelic',
            'Serbian',
            'Serbo-Croatian',
            'Sesotho',
            'Setswana',
            'Seychellois Creole',
            'Shona',
            'Sindhi',
            'Sinhalese',
            'Slovak',
            'Slovenian',
            'Somali',
            'Spanish',
            'Spanish (Latin American)',
            'Sundanese',
            'Swahili',
            'Swedish',
            'Tajik',
            'Tamil',
            'Tatar',
            'Telugu',
            'Thai',
            'Tigrinya',
            'Tonga',
            'Tshiluba',
            'Tumbuka',
            'Turkish',
            'Turkmen',
            'Twi',
            'Uighur',
            'Ukrainian',
            'Urdu',
            'Uzbek',
            'Vietnamese',
            'Welsh',
            'Wolof',
            'Xhosa',
            'Yiddish',
            'Yoruba',
            'Zulu')]
        [string] $Language,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The type of LLM query'
        )]
        [ValidateSet(
            'SimpleIntelligence',
            'Knowledge',
            'Pictures',
            'TextTranslation',
            'Coding',
            'ToolUse'
        )]
        [string] $LLMQueryType = 'SimpleIntelligence',
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The timeout in seconds for AI operations'
        )]
        [int] $TimeoutSeconds,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch] $SessionOnly,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences')
        )]
        [switch] $ClearSession,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences without ' +
                'affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ########################################################################

    )
    begin {

        # process each directory provided
        $processedDirectories = @()
        foreach ($directory in $ImageDirectories) {
            # convert the possibly relative path to an absolute path for reliable access
            $path = GenXdev\Expand-Path $directory

            # ensure the target directory exists before proceeding with any operations
            if (-not [System.IO.Directory]::Exists($path)) {
                Microsoft.PowerShell.Utility\Write-Warning (
                    "The directory '$path' does not exist - skipping"
                )
                continue
            }

            $processedDirectories += $path
            # output verbose information about the processing directory
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Processing images for object detection in directory: $path"
            )
        }

        if ($processedDirectories.Count -eq 0) {
            Microsoft.PowerShell.Utility\Write-Warning "No valid directories found to process"
            return
        }
    }

    process {

        # process each validated directory
        foreach ($path in $processedDirectories) {
            Microsoft.PowerShell.Utility\Write-Verbose "Processing directory: $path"

            # retrieve all supported image files from the specified directory
            # applying recursion only if the recurse switch was provided
            # get all supported image files from the specified directory
            $imageTypes = @(".jpg", ".jpeg", ".png", ".gif", ".bmp", ".webp", ".tiff", ".tif")
            $findParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName "GenXdev\Find-Item" `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            # Add NoRecurse parameter if Recurse was not specified
            if (-not $Recurse) {
                $findParams['NoRecurse'] = $true
            }

            # Get all image files matching the criteria
            GenXdev\Find-Item @findParams -PassThru -SearchMask "$path\*" -Category Pictures | Microsoft.PowerShell.Core\Where-Object {
                $imageTypes.IndexOf(([IO.Path]::GetExtension($_.FullName).ToLowerInvariant())) -ge 0
            } | Microsoft.PowerShell.Core\ForEach-Object {

                try {

                    # store the full path to the current image for better readability
                    $image = $PSItem.FullName

                    # output verbose information about current image being processed
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Processing image for object detection: $image"
                    )

                    # construct path for the metadata file
                    $metadataFilePath = "$($image):objects.json"

                    # check if a metadata file already exists for this image
                    $fileExists = [System.IO.File]::Exists($metadataFilePath)

                    # check if we have valid existing content
                    $hasValidContent = $false
                    if ($fileExists) {
                        try {
                            $content = [System.IO.File]::ReadAllText($metadataFilePath)
                            $existingData = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json
                            # Content is valid if success is true (successful processing)
                            $hasValidContent = $existingData.success -eq $true
                        }
                        catch {
                            # If JSON parsing fails, treat as invalid content
                            $hasValidContent = $false
                        }
                    }

                    # determine if we should process this image based on conditions
                    # Process if: not OnlyNew OR file doesn't exist OR (RetryFailed and no valid content)
                    if ((-not $OnlyNew) -or
                        (-not $fileExists) -or
                        ($RetryFailed -and (-not $hasValidContent))) {

                            try {
                                # obtain object detection data using ai detection technology
                                $params = GenXdev\Copy-IdenticalParamValues `
                                    -BoundParameters $PSBoundParameters `
                                    -FunctionName 'GenXdev\Get-ImageDetectedObjects' `
                                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                                        -Scope Local -ErrorAction SilentlyContinue)

                                $objectData = GenXdev\Get-ImageDetectedObjects `
                                    @params `
                                    -ImagePath $image

                                $NoDockerInitialize = $true;
                                # process the detection results into structured data format
                                $processedData = if ($objectData -and
                                    $objectData.success -and
                                    $objectData.predictions) {

                                    # extract predictions array from detection results
                                    $predictions = $objectData.predictions

                                    # create array of object labels from predictions
                                    $objectLabels = $predictions |
                                        Microsoft.PowerShell.Core\ForEach-Object {
                                            $_.label
                                        }

                                # group objects by label to get counts
                                $objectCounts = $objectLabels |
                                    Microsoft.PowerShell.Utility\Group-Object `
                                        -NoElement

                                    # construct structured data object with all metadata
                                    $data = @{
                                        success       = $true
                                        count         = $predictions.Count
                                        objects       = $objectLabels
                                        predictions   = $predictions
                                        object_counts = @{}
                                    }

                                    # populate object counts for each unique object type
                                    $objectCounts |
                                        Microsoft.PowerShell.Core\ForEach-Object {
                                            $data.object_counts[$_.Name] = $_.Count
                                        }

                                        $data
                                    } else {

                                        # create empty structure if no objects are detected
                                        @{
                                            success       = $true
                                            count         = 0
                                            objects       = @()
                                            predictions   = @()
                                            object_counts = @{}
                                        }
                                    }

                                    # convert processed data to json format for storage
                                    $objects = $processedData |
                                        Microsoft.PowerShell.Utility\ConvertTo-Json `
                                            -Depth 20 `
                                            -WarningAction SilentlyContinue

                                    # output verbose confirmation of detection analysis completion
                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        "Received object detection analysis for: $image"
                                    )

                                # re-parse and compress json for consistent formatting
                                $newContent = ($objects |
                                        Microsoft.PowerShell.Utility\ConvertFrom-Json |
                                        Microsoft.PowerShell.Utility\ConvertTo-Json `
                                            -Compress `
                                            -Depth 20 `
                                            -WarningAction SilentlyContinue)

                                # save the processed object data to metadata file
                                [System.IO.File]::WriteAllText($metadataFilePath, $newContent)

                                Microsoft.PowerShell.Utility\Write-Verbose (
                                    "Successfully saved object metadata for: $image"
                                )
                            }
                            catch {
                                # write failure JSON to prevent infinite retries without -RetryFailed
                                try {
                                    $failureData = @{
                                        success = $false
                                        count = 0
                                        objects = @()
                                        predictions = @()
                                        object_counts = @{}
                                        error = "Object detection failed: $($_.Exception.Message)"
                                    }

                                    $failureJson = $failureData | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 10
                                    [System.IO.File]::WriteAllText($metadataFilePath, $failureJson)
                                }
                                catch {
                                    # If we can't even write the failure JSON, just log it
                                    Microsoft.PowerShell.Utility\Write-Verbose "Failed to write error metadata for ${image}: $($_.Exception.Message)"
                                }

                                Microsoft.PowerShell.Utility\Write-Warning (
                                    "Failed to process objects for $image : $($_.Exception.Message)")
                            }
                    }
                }
                catch {
                    # log any errors that occur during image processing
                    Microsoft.PowerShell.Utility\Write-Verbose (
                        "Error processing image '$image': " +
                        "$($_.Exception.Message)"
                    )
                }
            }
        }
    }

    end {
    }
}