###############################################################################
<#
.SYNOPSIS
Compares faces in two different images and returns their similarity using
DeepStack.

.DESCRIPTION
This function compares faces between two images to determine similarity. It
uses a local DeepStack face match API running on a configurable port and
returns a similarity score between 0.0 and 1.0. This is typically used for
matching identity documents with pictures of a person or verifying if two
photos show the same person.

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

.PARAMETER ImagePath1
The local path to the first image file to compare. This parameter accepts any
valid file path that can be resolved by the system.

.PARAMETER ImagePath2
The local path to the second image file to compare. This parameter accepts any
valid file path that can be resolved by the system.

.PARAMETER ContainerName
The name for the Docker container. This allows multiple DeepStack instances
or custom naming conventions. Default is "deepstack_face_recognition".

.PARAMETER VolumeName
The name for the Docker volume for persistent storage. This ensures face data
persists between container restarts. Default is "deepstack_face_data".

.PARAMETER ServicePort
The port number for the DeepStack service. Must be between 1 and 65535.
Default is 5000.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check. Must be between 10
and 300 seconds. Default is 60.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts. Must be between 1 and 10
seconds. Default is 3.

.PARAMETER ImageName
Custom Docker image name to use instead of the default DeepStack image. This
allows using custom or updated DeepStack images.

.PARAMETER NoDockerInitialize
Skip Docker initialization when this switch is used. This is typically used
when already called by parent function to avoid duplicate initialization.

.PARAMETER Force
Force rebuild of Docker container and remove existing data when this switch
is used. This is useful for troubleshooting or updating the DeepStack image.

.PARAMETER UseGPU
Use GPU-accelerated version when this switch is used. This requires an
NVIDIA GPU with proper Docker GPU support configured.

.EXAMPLE
Compare-ImageFaces -ImagePath1 "C:\Users\YourName\photo1.jpg" `
                   -ImagePath2 "C:\Users\YourName\photo2.jpg"

Compares faces between two images using default settings.

.EXAMPLE
comparefaces "C:\docs\id_photo.jpg" "C:\photos\person.jpg" -UseGPU

Compares faces using GPU acceleration for identity verification with alias and
positional parameters.

.NOTES
DeepStack API Documentation: POST /v1/vision/face/match endpoint for face
comparison.
Example: curl -X POST -F "image1=@person1.jpg" -F "image2=@person2.jpg"
http://localhost:5000/v1/vision/face/match
#>
function Compare-ImageFaces {

    [CmdletBinding()]
    [OutputType([System.Collections.Hashtable])]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [Alias('comparefaces')]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The local path to the first image file to compare'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImagePath1,
        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $true,
            HelpMessage = 'The local path to the second image file to compare'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImagePath2,
        ###############################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'deepstack_face_recognition',
        ###############################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = ('The name for the Docker volume for persistent ' +
                'storage')
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'deepstack_face_data',
        ###############################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The port number for the DeepStack service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 5000,
        ###############################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service ' +
                'health check')
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###############################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = ('Interval in seconds between health check ' +
                'attempts')
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        ###############################################################################
        [Parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip Docker initialization (used when already ' +
                'called by parent function)')
        )]
        [switch] $NoDockerInitialize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force rebuild of Docker container and remove ' +
                'existing data')
        )]
        [Alias('ForceRebuild')]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use GPU-accelerated version (requires NVIDIA ' +
                'GPU)')
        )]
        [switch] $UseGPU,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show Docker Desktop window during initialization'
        )]
        [Alias('sw')]
        [switch]$ShowWindow,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to Docker Desktop ' +
                'installation and set persistent flag.')
        )]
        [switch] $AutoConsent,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
        ###################################################################

    )

    begin {

        # use script-scoped variables set by ensuredeepstack, with fallback
        # defaults
        if (-not $ApiBaseUrl) {

            $noDockerInitialize = $false
        }

        # ensure that the deepstack face match service is running
        if (-not $NoDockerInitialize) {

            Microsoft.PowerShell.Utility\Write-Verbose `
            ('Ensuring DeepStack face match service is available')

            # copy parameter values for the ensuredeepstack function call
            $ensureParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\EnsureDeepStack' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # initialize deepstack docker container if needed
            $null = GenXdev\EnsureDeepStack @ensureParams
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Skipping Docker initialization as requested'
        }        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using DeepStack face match API at: $script:ApiBaseUrl"

        ###############################################################################
        <#
        .SYNOPSIS
        Processes the face match result from DeepStack API.

        .DESCRIPTION
        This internal helper function processes the response from DeepStack face
        match API and formats it into a standardized result object with success
        status, similarity score, and match percentage.

        .PARAMETER MatchData
        The raw response data from the DeepStack face match API endpoint.

        .EXAMPLE
        $result = Format-FaceMatchResult -MatchData $response
        #>

        function Format-FaceMatchResult {

            [CmdletBinding()]
            [OutputType([System.Collections.Hashtable])]

            param(
                ###################################################################
                [Parameter(
                    Position = 0,
                    Mandatory = $true,
                    HelpMessage = 'The raw response data from DeepStack API'
                )]
                $MatchData
                ###################################################################
            )

            begin {

            }

            process {

                # check if match data is valid and successful
                if (-not $MatchData -or -not $MatchData.success) {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'No successful face match data received'

                    return @{
                        success    = $false
                        similarity = 0.0
                        message    = 'Face match failed'
                    }
                }

                # extract similarity score from the response data
                $similarity = if ($MatchData.similarity) {

                    $MatchData.similarity
                } else {

                    0.0
                }

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Face similarity score: $similarity"

                # return formatted result object with all relevant metrics
                return @{
                    success          = $true
                    similarity       = $similarity
                    confidence       = $similarity
                    match_percentage = [math]::Round($similarity * 100, 2)
                }
            }

            end {

            }
        }
    }

    process {

        try {

            # expand and validate both image paths to absolute paths
            $imagePath1 = GenXdev\Expand-Path $ImagePath1

            $imagePath2 = GenXdev\Expand-Path $ImagePath2

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Comparing images: $imagePath1 and $imagePath2"

            # validate that both files are valid image files
            $null = GenXdev\Test-DeepLinkImageFile -Path $imagePath1

            $null = GenXdev\Test-DeepLinkImageFile -Path $imagePath2

            # construct the api endpoint uri for deepstack face match service
            $uri = "$($script:ApiBaseUrl)/v1/vision/face/match"

            Microsoft.PowerShell.Utility\Write-Verbose "Sending request to: $uri"

            # create form data for deepstack api (it expects multipart form data)
            $form = @{
                image1 = Microsoft.PowerShell.Management\Get-Item -LiteralPath $imagePath1
                image2 = Microsoft.PowerShell.Management\Get-Item -LiteralPath $imagePath2
            }

            # send the request to the deepstack face match api
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Sending image data to DeepStack face match API'

            $response = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                -Verbose:$false `
                -ProgressAction Continue `
                -Uri $uri `
                -Method Post `
                -Form $form `
                -TimeoutSec 30 `
                -ErrorAction Stop

            Microsoft.PowerShell.Utility\Write-Verbose `
            ('API Response: ' +
                "$($response | `
                    Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 3)")

            # process the response from deepstack using the helper function
            $matchResult = Format-FaceMatchResult -MatchData $response

            Microsoft.PowerShell.Utility\Write-Output $matchResult
        }
        catch [System.Net.WebException] {

            Microsoft.PowerShell.Utility\Write-Error `
                "Network error during face comparison: $_"
        }
        catch [System.TimeoutException] {

            Microsoft.PowerShell.Utility\Write-Error `
            ("Timeout during face comparison between $imagePath1 and " +
                "$imagePath2")
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error `
            ("Failed to compare faces between $imagePath1 and " +
                "$imagePath2`: $_")
        }
    }

    end {

    }
}