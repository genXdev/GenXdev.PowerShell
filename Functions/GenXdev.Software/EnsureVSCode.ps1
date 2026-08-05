###############################################################################
<#
.SYNOPSIS
Installs and configures Visual Studio Code with recommended extensions.

.DESCRIPTION
Checks if Visual Studio Code is installed and if not, installs it using WinGet.
Configures user settings, keybindings, and installs recommended extensions from
the workspace configuration. Also sets up PSGallery as a trusted repository and
configures specific extension settings.

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
EnsureVSCode
#>
function EnsureVSCode {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    param(
        ###############################################################################

        [switch] $Force,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to VSCode and extension ' +
                'installation and set persistent flag.')
        )]
        [switch] $AutoConsent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only auto consent during session')
        )]
        [switch]$SessionOnly
        ###############################################################################
    )

    begin {

        # ensure copilot keyboard shortcut is configured
        $ensureParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\EnsureCopilotKeyboardShortCut'
        $null = GenXdev\EnsureCopilotKeyboardShortCut @ensureParams

        # get the process that's hosting the current PowerShell session
        [System.Diagnostics.Process] $hostProcess = `
            GenXdev\Get-PowershellMainWindowProcess

        # determine default IDE path based on host process availability
        $normalPath = Microsoft.PowerShell.Management\Join-Path `
            $env:LOCALAPPDATA 'Programs\Microsoft VS Code\Code.exe'
        $normalPath2 = Microsoft.PowerShell.Management\Join-Path `
            $env:ProgramFiles 'Microsoft VS Code\Code.exe'
        $previewPath = Microsoft.PowerShell.Management\Join-Path `
            $env:LOCALAPPDATA `
            'Programs\Microsoft VS Code Insiders\Code - Insiders.exe'
        $previewPath2 = Microsoft.PowerShell.Management\Join-Path `
            $env:ProgramFiles `
            '\Microsoft VS Code Insiders\Code - Insiders.exe'

        $idePath = ((($null -eq $hostProcess) -or `
                ($hostProcess -like '*Terminal*')) ? (
                ([IO.File]::Exists($previewPath) ? $previewPath : (
                    ([IO.File]::Exists($previewPath2) ? $previewPath2 : (
                        ([IO.File]::Exists($normalPath) ? $normalPath : (
                            ([IO.File]::Exists($normalPath2) ? $normalPath2 : 'code')))))))) : `
                $hostProcess.Path)

        # check if vscode executable is available in path
        $vSCodeMissing = $idePath -eq 'code'
        Microsoft.PowerShell.Utility\Write-Verbose `
        ("VSCode installation check: $($vSCodeMissing ? 'Missing' : 'Found')")
    }

    process {

        if ($vSCodeMissing -or $Force) {

            # verify administrative privileges are available
            if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                $json = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev\EnsureVSCode" |
                    Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsureVSCode @params
"@)) -JobDescription 'Installing Visual Studio Code';

                # refresh search paths after installation
                GenXdev\Initialize-SearchPaths

                # verify VSCode was installed successfully
                $codeCmd = Microsoft.PowerShell.Core\Get-Command code `
                    -ErrorAction SilentlyContinue
                if (-not $codeCmd) {
                    throw 'Visual Studio Code installation verification failed — code command not found after installation.'
                }
                return;
            }

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Installing Visual Studio Code...'

            # check installation consent before proceeding
            $consent = GenXdev\Confirm-InstallationConsent `
                -ApplicationName 'Visual Studio Code Insiders' `
                -Source 'Winget' `
                -Description 'Code editor and development environment for PowerShell module development' `
                -Publisher 'Microsoft' `
                -AutoConsent:$AutoConsent `
                -AutoConsentAllPackages:$AutoConsentAllPackages

            if (-not $consent) {
                Microsoft.PowerShell.Utility\Write-Warning `
                    'Visual Studio Code installation cancelled by user.'
                return
            }

            # install visual studio code insiders using winget
            Microsoft.WinGet.Client\Install-WinGetPackage `
                -Id 'Microsoft.VisualStudioCode.Insiders' `
                -Mode Silent `
                -Force `
                -Scope SystemOrUnknown

            # refresh search paths after installation
            GenXdev\Initialize-SearchPaths

            # verify VSCode was installed successfully
            $codeCmd = Microsoft.PowerShell.Core\Get-Command code `
                -ErrorAction SilentlyContinue
            if (-not $codeCmd) {
                throw 'Visual Studio Code installation verification failed — code command not found after installation.'
            }

            # generate and store MCP server authentication token if not already configured
            try {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Checking MCP server authentication token..."

                $existingToken = [System.Environment]::GetEnvironmentVariable(
                    'GENXDEV_MCP_TOKEN', 'User')

                if ([string]::IsNullOrEmpty($existingToken)) {

                    Microsoft.PowerShell.Utility\Write-Host `
                        "Generating secure MCP server authentication token..." `
                        -ForegroundColor Yellow

                    # generate and store token without prompting
                    $null = GenXdev\New-GenXdevMCPToken `
                        -SetEnvironmentVariable `
                        -Force

                    Microsoft.PowerShell.Utility\Write-Host `
                    ("MCP server authentication token generated and " +
                        "stored in GENXDEV_MCP_TOKEN environment variable.") `
                        -ForegroundColor Green

                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "MCP server authentication token already configured."
                }

            }
            catch {

                Microsoft.PowerShell.Utility\Write-Warning `
                ("Failed to generate MCP server token: " +
                    "$($_.Exception.Message)")
            }

            # copy asset files to workspace
            $sourcePath = GenXdev\Expand-Path `
                "$($MyInvocation.MyCommand.Module.ModuleBase)\Assets\"

            $targetPath = GenXdev\Expand-Path `
                "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\..\"

            # process each asset file in source directory
            GenXdev\Find-Item "$sourcePath\*" `
                -RelativeBasePath $sourcePath |
                Microsoft.PowerShell.Core\ForEach-Object {

                    # build source and target file paths
                    $sourceFile = GenXdev\Expand-Path `
                        "$sourcePath\$PSItem"

                    $targetFile = GenXdev\Expand-Path `
                    ("$targetPath\$PSItem".Replace('.asset.txt', '')) `
                        -CreateDirectory

                    # determine if file should be overwritten
                    $doOverwrite = ($targetFile -like "\.vscode\tasks.json") -and `
                    (Microsoft.PowerShell.Management\Test-Path `
                            -LiteralPath $targetFile) -and `
                    ([IO.File]::ReadAllText($targetFile) -like `
                            "*-DebugFailedTests*")

                    # skip if target file exists and overwrite is not needed
                    if ([IO.File]::Exists($targetFile) -and (-not $doOverwrite)) {

                        return
                    }

                    # copy asset file to target location
                    Microsoft.PowerShell.Management\Copy-Item `
                        -LiteralPath $sourceFile `
                        -Destination $targetFile
                }
        }
    }

    end {

    }
}
###############################################################################