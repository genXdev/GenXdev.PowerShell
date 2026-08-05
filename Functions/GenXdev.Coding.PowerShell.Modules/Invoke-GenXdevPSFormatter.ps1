<#
.SYNOPSIS
Formats PowerShell script files using PSScriptAnalyzer formatting rules.

.DESCRIPTION
This function applies PowerShell formatting rules to script files using
PSScriptAnalyzer's Invoke-Formatter cmdlet. It can process individual files or
recursively format multiple files in directories. The function uses customizable
formatting settings and provides detailed logging of the formatting process.

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
Specifies the path to the script file or directory to format. Accepts pipeline
input and supports various path aliases for compatibility.

.PARAMETER Settings
A settings hashtable or a path to a PowerShell data file (.psd1) that contains
the formatting settings. If not specified, the function will attempt to load
settings from a predefined location or use built-in defaults.

.PARAMETER Range
The range within which formatting should take place as an array of four integers:
starting line number, starting column number, ending line number, ending column
number. If not specified, the entire file will be formatted.

.PARAMETER Recurse
Recursively process files in subdirectories when the Path parameter points to
a directory.

.EXAMPLE
Invoke-GenXdevPSFormatter -Path "C:\Scripts\MyScript.ps1"

.EXAMPLE
Invoke-GenXdevPSFormatter -Path "C:\Scripts" -Recurse

.EXAMPLE
"MyScript.ps1" | Invoke-GenXdevPSFormatter -Settings @{IncludeRules=@('PSUseCorrectCasing')}
#>
function Invoke-GenXdevPSFormatter {

    [CmdletBinding()]

    param(
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'Specifies the path to the script file to format.'
        )]
        [Alias('Name', 'FullName', 'ImagePath', 'FileName', 'ScriptFileName')]
        [string] $Path,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('A settings hashtable or a path to a PowerShell data ' +
                'file (.psd1) that contains the formatting settings.')
        )]
        [Object] $Settings,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The range within which formatting should take place ' +
                'as an array of four integers: starting line number, starting ' +
                'column number, ending line number, ending column number.')
        )]
        [int[]] $Range,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Recursively process files in subdirectories.'
        )]
        [switch] $Recurse
        ###############################################################################
    )

    begin {

        # check if settings parameter was provided by the caller
        if (-not $Settings) {

            try {

                # build path to the default formatting settings file
                $settingsPath = GenXdev\Expand-Path `
                    "$($MyInvocation.MyCommand.Module.ModuleBase)\PSScriptAnalyzerFormattingSettings.psd1"

                # attempt to load settings from the predefined file
                if ([IO.File]::Exists($settingsPath)) {

                    # read and evaluate the settings file content
                    $settings = [IO.File]::ReadAllText($settingsPath)

                    # use formatting-specific settings if available
                    if ($settings.CodeFormatting) {

                        $Settings = $settings.CodeFormatting
                    }
                    elseif ($settings) {

                        $Settings = $settings
                    }
                }
                else {

                    # notify user that settings file was not found
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'Settings file not found. Using built-in defaults.'

                    # define default formatting settings
                    $Settings = @{
                        IncludeRules = @(
                            # 'PSUseCorrectCasing',
                            'PSUseFullyQualifiedCmdletNames',
                            'PSPlaceOpenBrace',
                            'PSUseConsistentIndentation',
                            'PSUseConsistentWhitespace',
                            'PSAvoidUsingDoubleQuotesForConstantString',
                            'PSAlignAssignmentStatement'
                        )
                        Rules        = @{
                            PSUseCorrectCasing                        = @{
                                Enable = $true
                            }
                            PSPlaceOpenBrace                          = @{
                                Enable     = $true
                                OnSameLine = $true
                            }
                            PSUseConsistentIndentation                = @{
                                Enable                      = $true
                                IndentationSize             = 4
                                ContinuationIndentationSize = 4
                            }
                            PSUseConsistentWhitespace                 = @{
                                Enable = $true
                            }
                            PSAvoidUsingDoubleQuotesForConstantString = @{
                                Enable = $true
                            }
                            PSAlignAssignmentStatement                = @{
                                Enable = $true
                            }
                            PSUseFullyQualifiedCmdletNames            = @{
                                Enable = $true
                            }
                        }
                    }
                }
            }
            catch {

                # warn about settings initialization failure and fall back to defaults
                Microsoft.PowerShell.Utility\Write-Warning `
                ("Could not initialize settings: $($_.Exception.Message). " +
                    'Using defaults.')
            }
        }

        # notify user that formatter has been initialized
        Microsoft.PowerShell.Utility\Write-Verbose `
            'PowerShell formatter initialized with settings.'
    }

    process {

        try {

            # store the input path for processing
            $filePath = $Path

            # expand the path to handle relative paths and wildcards
            $filePaths = GenXdev\Find-Item $FilePath -PassThru |
                Microsoft.PowerShell.Core\ForEach-Object FullName

            # process each file path found
            foreach ($filePath in $filePaths) {

                # get the file extension to determine if it's a powershell file
                $extension = [IO.Path]::GetExtension($filePath).ToLower()

                # skip files that are not powershell script files
                if ($extension -notin @('.ps1', '.psm1', '.psd1')) {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Skipping non-PowerShell file: $filePath"

                    continue
                }

                # notify user about the file being processed
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Processing file: $filePath"

                # initialize variable to hold script content
                $scriptDefinition = $null

                try {

                    # read the entire file content as utf-8 text
                    $scriptDefinition = [IO.File]::ReadAllText($filePath, `
                            [Text.Encoding]::UTF8)
                }
                catch {

                    # warn about file read failure and continue to next file
                    Microsoft.PowerShell.Utility\Write-Warning `
                    ("Could not read file: $filePath - " +
                        "$($_.Exception.Message)")

                    continue
                }

                # skip files that are empty or contain only whitespace
                if ([string]::IsNullOrWhiteSpace($scriptDefinition)) {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Skipping empty file: $filePath"

                    continue
                }

                # initialize variable to hold formatted script content
                $formattedScript = $null

                try {

                    # prepare parameters for the psscriptanalyzer formatter
                    $invocationParams = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'PSScriptAnalyzer\Invoke-Formatter'

                    $invocationParams.scriptDefinition = $scriptDefinition

                    # invoke the psscriptanalyzer formatter with the prepared parameters
                    $formattedScript = PSScriptAnalyzer\Invoke-Formatter `
                        @invocationParams
                }
                catch {

                    # warn about formatter error and continue to next file
                    Microsoft.PowerShell.Utility\Write-Warning `
                        "Formatter error: $($_.Exception.Message)"

                    continue
                }

                # skip files where formatter returned empty or whitespace content
                if ([string]::IsNullOrWhiteSpace($formattedScript)) {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "No formatting changes needed for: $filePath"

                    continue
                }

                # check if the formatted content differs from the original
                if ($formattedScript -eq $scriptDefinition) {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "No formatting changes needed for: $filePath"

                    continue
                }

                try {

                    # write the formatted content back to the original file
                    [IO.File]::WriteAllText($filePath, $formattedScript, `
                            [Text.Encoding]::UTF8)

                    # notify user that the file was successfully formatted
                    Microsoft.PowerShell.Utility\Write-Output `
                        "Formatted file: $filePath"
                }
                catch {

                    # warn about file write failure
                    Microsoft.PowerShell.Utility\Write-Warning `
                    ("Could not write formatted content to file: $filePath " +
                        "- $($_.Exception.Message)")
                }
            }
        }
        catch {

            # warn about general processing error
            Microsoft.PowerShell.Utility\Write-Warning `
                "Error processing file ${filePath}: $($_.Exception.Message)"
        }
    }

    end {

        # notify user that formatter processing has completed
        Microsoft.PowerShell.Utility\Write-Verbose `
            'PowerShell formatter processing completed'
    }
}
################################################################################