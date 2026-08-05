###############################################################################
<#
.SYNOPSIS
Opens one or more files in Visual Studio Code.

.DESCRIPTION
This function takes file paths and opens them in Visual Studio Code. It expands
paths and validates file existence before attempting to open them. The function
supports both direct file paths and pipeline input, making it ideal for quickly
opening multiple files from terminal searches.

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
One or more file paths to open in Visual Studio Code. Accepts pipeline input
and wildcard patterns.

.PARAMETER Copilot
When specified, opens the file and triggers the Copilot keyboard shortcut to
start an edit session.

.EXAMPLE
VSCode -FilePath "C:\path\to\file.txt" -Copilot

.EXAMPLE
Get-ChildItem *.js -Recurse | VSCode
#>
function VSCode {

    [CmdletBinding()]
    param(
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ValueFromPipeline = $true,
            HelpMessage = 'The path to the file to open in VSCode'
        )]
        [string[]]$FilePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Add sourcefile to Copilot edit-session'
        )]
        [switch]$Copilot,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to this installation type and set persistent flag..')
        )]
        [switch]$AutoConsent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installations. Useful for unattended or CI/CD scenarios.')
        )]
        [switch]$AutoConsentAllPackages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
    )

    begin {

        $PSRootPath = GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\..\"

        # inform user that function execution has started
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting VSCode function to open files'

        # ensure copilot keyboard shortcut is configured if needed
        if ($Copilot) {

            $ensureParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\EnsureCopilotKeyboardShortCut'
            $null = GenXdev\EnsureCopilotKeyboardShortCut @ensureParams
        }
    }


    process {

        $VSCodeInvoked = $false

        # process each file path provided through pipeline or parameter
        $FilePath | Microsoft.PowerShell.Core\ForEach-Object {

            try {
                # expand relative or partial paths to full filesystem paths
                $path = GenXdev\Expand-Path $_

                if (-not $VSCodeInvoked -and ($path.StartsWith("$PSRootPath\"))) {

                    $VSCodeInvoked = $true
                    GenXdev\Open-SourceFileInIde `
                        -Path $PSRootPath `
                        -Code
                }

                # open file in vscode with or without copilot activation
                Microsoft.PowerShell.Utility\Write-Verbose "Opening file in VSCode: $path"
                if ($Copilot) {

                    $null = GenXdev\Open-SourceFileInIde `
                        -Path $path `
                        -Code `
                        -KeysToSend @('^+%{F12}')
                }
                else {
                    $null = GenXdev\Open-SourceFileInIde -Path $path -Code
                }
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Error processing file '$path': $_"
            }
        }
    }

    end {
    }
}