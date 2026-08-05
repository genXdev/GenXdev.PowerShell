###############################################################################
<#
.SYNOPSIS
Updates image metadata with AI-generated descriptions and keywords.

.DESCRIPTION
The Invoke-ImageKeywordUpdate function analyzes images using AI to generate
descriptions, keywords, and other metadata. It creates a companion JSON file for
each image containing this information. The function can process new images only
or update existing metadata, and supports recursive directory scanning.

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
Specifies the directories containing images to process. Defaults to current
directory if not specified.

.PARAMETER Language
Specifies the language for generated descriptions and keywords. Defaults to
English.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER Recurse
When specified, searches for images in the specified directory and all
subdirectories.

.PARAMETER OnlyNew
When specified, only processes images that don't already have metadata JSON
files.

.PARAMETER RetryFailed
When specified, reprocesses images where previous metadata generation attempts
failed.

.PARAMETER SessionOnly
Use alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER ClearSession
Clear alternative settings stored in session for AI preferences like Language,
Image collections, etc.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Invoke-ImageKeywordUpdate -ImageDirectories @("C:\Photos", "D:\Pictures") -Recurse -OnlyNew

.EXAMPLE
updateimages @("C:\Photos", "C:\Archive") -Recurse -RetryFailed -Language "Spanish"
#>
###############################################################################
function Invoke-ImageKeywordUpdate {

    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    [Alias('imagekeywordgeneration')]

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
        [parameter(
            Mandatory = $false,
            HelpMessage = ('The directory containing face images organized ' +
                'by person folders. If not specified, uses the configured ' +
                'faces directory preference.')
        )]
        [string] $FacesDirectory,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            Position = 2,
            HelpMessage = 'System instructions for the model'
        )]
        [string] $Instructions,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'A JSON schema for the requested output format'
        )]
        [string] $ResponseFormat = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Temperature for response randomness (0.0-1.0)'
        )]
        [ValidateRange(-1, 1.0)]
        [double] $Temperature = -1,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Image detail level'
        )]
        [ValidateSet('low', 'medium', 'high')]
        [string] $ImageDetail = 'high',
        ########################################################################
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
        [string] $LLMQueryType = 'Pictures',
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The model identifier or pattern to use for AI operations'
        )]
        [string] $Model,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI operations'
        )]
        [string] $ApiEndpoint,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI operations'
        )]
        [string] $ApiKey,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Launch interactive prompt to configure LLM settings')
        )]
        [switch] $PromptForSettings,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Indicates that LLM has no support for JSON schemas'
        )]
        [switch] $NoSupportForJsonSchema,
        ###########################################################################
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
            HelpMessage = "Include model's thoughts in output"
        )]
        [switch] $IncludeThoughts,
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
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specifies the functions to use for the AI operation.'
        )]
        [string[]] $Functions,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specifies the exposed cmdlets for the AI operation.'
        )]
        [string[]] $ExposedCmdLets,
        ###############################################################################
        [Alias('NoConfirmationFor')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Specifies tool function names that do not require confirmation.'
        )]
        [string[]] $NoConfirmationToolFunctionNames,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'If specified, disables context usage.'
        )]
        [switch] $NoContext,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum callback length for tool calls.'
        )]
        [int] $MaxToolcallBackLength,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('PassThru to return structured objects instead ' +
                'of outputting to console')
        )]
        [Alias('pt')]
        [switch]$PassThru,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Detects changes in the faces directory and ' +
                're-registers faces if needed')
        )]
        [switch] $AutoUpdateFaces
    )

    begin {

        # copy identical parameter values for ai meta language function
        $params = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-AIMetaLanguage' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                -Scope Local -ErrorAction SilentlyContinue)

        # get the resolved language setting from ai meta system
        $language = GenXdev\Get-AIMetaLanguage @params
    }

    process {

        # process each image directory provided
        foreach ($directory in $ImageDirectories) {

            # convert relative path to absolute path
            $path = GenXdev\Expand-Path $directory

            # verify directory exists before proceeding
            if (-not [System.IO.Directory]::Exists($path)) {
                Microsoft.PowerShell.Utility\Write-Warning ("The directory '$path' " +
                    'does not exist - skipping')
                continue
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Processing directory: $path"

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
            GenXdev\Find-Item @findParams -PassThru -Name "$path\*" -Category Pictures | Microsoft.PowerShell.Core\Where-Object {
                $imageTypes.IndexOf(([IO.Path]::GetExtension($_.FullName).ToLowerInvariant())) -ge 0
            } | Microsoft.PowerShell.Core\ForEach-Object {
                try {
                    # get the full path of the current image file
                    $image = $PSItem.FullName

                    # ensure image is writable by removing read-only flag if present
                    if ($PSItem.Attributes -band [System.IO.FileAttributes]::ReadOnly) {

                        $PSItem.Attributes = $PSItem.Attributes -bxor `
                            [System.IO.FileAttributes]::ReadOnly
                    }

                    # determine which metadata file to check based on language preference
                    $metadataFile = if ($language -eq 'English') {
                        "$($image):description.json"
                    }
                    else {
                        "$($image):description.$language.json"
                    }

                    # check if metadata file already exists
                    $fileExists = [System.IO.File]::Exists($metadataFile)

                    # check if we have valid existing content
                    $hasValidContent = $false
                    if ($fileExists) {
                        try {
                            $content = [System.IO.File]::ReadAllText($metadataFile)
                            $existingData = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json
                            # Content is valid if success is true AND has required data
                            $hasValidContent = ($existingData.success -eq $true) -and
                            ($existingData.short_description) -and
                            ($existingData.keywords)
                        }
                        catch {
                            # If JSON parsing fails, treat as invalid content
                            $hasValidContent = $false
                        }
                    }

                    # process image if conditions are met (new files or update requested)
                    # Process if: not OnlyNew OR file doesn't exist OR (RetryFailed and no valid content)
                    if ((-not $OnlyNew) -or
                        (-not $fileExists) -or
                        ($RetryFailed -and (-not $hasValidContent))) {

                        # define response format schema for ai analysis
                        $responseSchema = @{
                            type        = 'json_schema'
                            json_schema = @{
                                name   = 'image_analysis_response'
                                strict = $true
                                schema = @{
                                    type       = 'object'
                                    properties = @{
                                        short_description     = @{
                                            type        = 'string'
                                            description = ('Brief description of the ' +
                                                'image (max 80 chars)')
                                            maxLength   = 80
                                        }
                                        long_description      = @{
                                            type        = 'string'
                                            description = ('Detailed description of ' +
                                                'the image')
                                        }
                                        has_nudity            = @{
                                            type        = 'boolean'
                                            description = ('Whether the image ' +
                                                'contains nudity')
                                        }
                                        keywords              = @{
                                            type        = 'array'
                                            items       = @{
                                                type = 'string'
                                            }
                                            description = 'Array of descriptive keywords'
                                        }
                                        has_explicit_content  = @{
                                            type        = 'boolean'
                                            description = ('Whether the image contains ' +
                                                'explicit content')
                                        }
                                        overall_mood_of_image = @{
                                            type        = 'string'
                                            description = ('The general mood or emotion ' +
                                                'conveyed by the image')
                                        }
                                        picture_type          = @{
                                            type        = 'string'
                                            description = ('The type or category of ' +
                                                'the image')
                                        }
                                        style_type            = @{
                                            type        = 'string'
                                            description = ('The artistic or visual style ' +
                                                'of the image')
                                        }
                                    }
                                    required   = @(
                                        'short_description',
                                        'long_description',
                                        'has_nudity',
                                        'keywords',
                                        'has_explicit_content',
                                        'overall_mood_of_image',
                                        'picture_type',
                                        'style_type'
                                    )
                                }
                            }
                        } | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10

                        # output verbose information about the image being analyzed
                        Microsoft.PowerShell.Utility\Write-Verbose ('Analyzing image ' +
                            "content: $image with language: $language")

                        $Additional = @{metadata = @(
                                GenXdev\Find-Item "$($image):people.json" -IncludeAlternateFileStreams -PassThru |
                                    Microsoft.PowerShell.Core\ForEach-Object FullName |
                                    Microsoft.PowerShell.Core\ForEach-Object {
                                        try {
                                            $content = [IO.File]::ReadAllText($_)
                                            $obj = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json
                                            if (($null -ne $obj) -and ($null -ne $obj.predictions) -and ($obj.predictions.Count -gt 0)) {

                                                $obj.predictions | Microsoft.PowerShell.Core\ForEach-Object { $_ }
                                            }
                                        }
                                        catch {
                                            # ignore errors reading existing metadata
                                        }
                                    });
                                FileInfo         = @{
                                    ImageFilename = [IO.Path]::GetFileName($image)
                                }
                            };

                            $json = $Additional | Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 20

                            # construct comprehensive ai query for image analysis
                            $query = (
                                'Analyze image and return a JSON object with properties: ' +
                                "'short_description' (max 80 chars), 'long_description', " +
                                "'has_nudity', 'keywords' (array of strings with all " +
                                'detected objects, text or anything describing this ' +
                                'picture, max 15 keywords), ' +
                                "'has_explicit_content', 'overall_mood_of_image', " +
                                "'picture_type' and 'style_type'.`r`n`r`n" +
                                "Generate all descriptions and keywords in $language " +
                                "language.`r`n`r`n" +
                                "Output only JSON, no markdown or anything other than JSON.`r`n`r`n" +
                                "$(($Additional.metadata.Count -gt 0 ? @"
Use the metadata below to enrich the descriptions and titles.
Like mentioning the person's name in the title when high confidence is detected (> 0.8).
If it the name is that of a famous person, tell about his/her life in the long description
and mention his name in the title.
$json`r`n
"@ : "$json`r`n"))"
                            );

                            try {
                                # get ai-generated image description and metadata
                                $params = GenXdev\Copy-IdenticalParamValues `
                                    -BoundParameters $PSBoundParameters `
                                    -FunctionName 'GenXdev\Invoke-QueryImageContent' `
                                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                                        -Scope Local -ErrorAction SilentlyContinue)
                                $description = GenXdev\Invoke-QueryImageContent `
                                    @params `
                                    -ResponseFormat $responseSchema `
                                    -Query $query `
                                    -ImagePath $image `
                                    -Temperature 0.1

                                # output verbose information about the received analysis
                                Microsoft.PowerShell.Utility\Write-Verbose ('Received ' +
                                    "analysis: $description")

                                # extract just the json portion of the response text
                                $description = $description.trim()

                                # find the first opening brace position
                                $i0 = $description.IndexOf('{')

                                # find the last closing brace position
                                $i1 = $description.LastIndexOf('}')

                                # extract only the json content if braces found
                                if ($i0 -ge 0) {

                                    $description = $description.Substring(
                                        $i0, $i1 - $i0 + 1)
                                }

                                $description = (($description | Microsoft.PowerShell.Utility\ConvertFrom-Json | GenXdev\ConvertTo-HashTable) + $Additional.FileInfo) |
                                    Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 20 -WarningAction SilentlyContinue

                                    # save formatted json metadata to companion file
                                    $null = [System.IO.File]::WriteAllText(
                                        $metadataFile,
                                        $description
                                    )

                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        "Successfully saved keyword metadata for: $image")
                                }
                                catch {
                                    # write failure JSON to prevent infinite retries without -RetryFailed
                                    try {
                                        $failureData = @{
                                            success               = $false
                                            short_description     = ""
                                            long_description      = ""
                                            has_nudity            = $true
                                            keywords              = @()
                                            has_explicit_content  = $true
                                            overall_mood_of_image = ""
                                            picture_type          = ""
                                            style_type            = ""
                                            error                 = "Keyword generation failed: $($_.Exception.Message)"
                                        }

                                        $failureJson = $failureData | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress -Depth 10
                                        [System.IO.File]::WriteAllText($metadataFile, $failureJson)
                                    }
                                    catch {
                                        # If we can't even write the failure JSON, just log it
                                        Microsoft.PowerShell.Utility\Write-Verbose "Failed to write error metadata for ${image}: $($_.Exception.Message)"
                                    }

                                    Microsoft.PowerShell.Utility\Write-Warning (
                                        "Failed to process keywords for $image : $($_.Exception.Message)")
                                }
                            }
                        }
                        catch {
                            # output error message if image processing fails
                            Microsoft.PowerShell.Utility\Write-Verbose ("Failed to process image: $image`r`n" +
                                "Error: $($_.Exception.Message)")
                        }
                    }
        }
    }
    end {
    }
}
###############################################################################