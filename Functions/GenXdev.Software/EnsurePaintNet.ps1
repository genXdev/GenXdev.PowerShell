###############################################################################
<#
.SYNOPSIS
Ensures Paint.NET is properly installed and accessible on the system.

.DESCRIPTION
Performs comprehensive checks and setup for Paint.NET:
- Verifies if Paint.NET is installed and accessible in PATH
- Installs Paint.NET via WinGet if not present
- Configures system PATH environment variable
- Ensures paintdotnet.exe is available for command-line usage
The function handles all prerequisites and ensures a working Paint.NET installation.

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
EnsurePaintNet
This will verify and setup Paint.NET if needed.
#>
function EnsurePaintNet {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to Paint.NET and WinGet ' +
                'module installation and set persistent flag.')
        )]
        [switch] $AutoConsent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only auto consent during session')
        )]
        [switch]$SessionOnly
        ########################################################################
    )

    begin {
        # ensure graphics assembly is loaded for image processing
        if (-not [System.Drawing.Rectangle]) {

            Microsoft.PowerShell.Utility\Add-Type -AssemblyName System.Drawing
        }
    }
    process {
        try {
            # First, ensure current session PATH is up to date with both Machine and User PATH
            $paintNetPath = 'C:\Program Files\paint.net'

            # Only add Paint.NET path to user PATH if it's not already present
            $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
            if ($userPath -notlike "*$paintNetPath*") {
                $userPath = "$userPath;$paintNetPath"
                [System.Environment]::SetEnvironmentVariable('PATH', $userPath, 'User')
            }

            # Only update session PATH if Paint.NET path is not already in current session
            if ($env:PATH -notlike "*$paintNetPath*") {
                $env:PATH = "$env:PATH;$paintNetPath"
            }

            # Check if Paint.NET is already accessible
            Microsoft.PowerShell.Utility\Write-Verbose 'Paint.NET not found in PATH, checking installation...'

            # Check again after updating PATH
            if (@(Microsoft.PowerShell.Core\Get-Command 'paintdotnet.exe' -ErrorAction SilentlyContinue).Length -eq 0) {


                # verify administrative privileges are available
                if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                    $json = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName "GenXdev\EnsurePainNet" |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                    GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsurePaintNet @params
"@)) -JobDescription 'Install Paint.NET';

                    return;
                }

                # Request consent before installing Paint.NET
                $paintNetConsent = GenXdev\Confirm-InstallationConsent `
                    -ApplicationName 'Paint.NET' `
                    -Source 'WinGet' `
                    -Description 'Image editing software required for graphics processing operations' `
                    -Publisher 'dotPDN LLC' `
                    -AutoConsent:$AutoConsent `
                    -AutoConsentAllPackages:$AutoConsentAllPackages

                if (-not $paintNetConsent) {
                    throw 'User declined installation of Paint.NET. Cannot proceed without image editing capabilities.'
                }

                Microsoft.PowerShell.Utility\Write-Verbose 'Installing Paint.NET...'

                try {
                    $null = Microsoft.WinGet.Client\Install-WinGetPackage -Id 'dotPDN.PaintDotNet' -Force
                }
                catch {
                    throw "Failed to install Paint.NET via WinGet: $_"
                }                    # Update PATH after installation

            }
        }
        catch {
            $errorMessage = "Failed to setup Paint.NET: $($_.Exception.Message)"
            Microsoft.PowerShell.Utility\Write-Error -Exception $_.Exception -Message $errorMessage -Category OperationStopped
            throw
        }
    }

    end {
        $userPath = [Environment]::GetEnvironmentVariable('PATH', 'User')
        if ($userPath -notlike "*$paintNetPath*") {
            try {
                Microsoft.PowerShell.Utility\Write-Verbose 'Adding Paint.NET to User PATH after installation...'
                [Environment]::SetEnvironmentVariable(
                    'PATH',
                    "$userPath;$paintNetPath",
                    'User')
                # Update current session PATH only if not already present
                if ($env:PATH -notlike "*$paintNetPath*") {
                    $env:PATH = "$env:PATH;$paintNetPath"
                }
            }
            catch [System.Security.SecurityException] {
                throw "Access denied while updating PATH environment variable: $_"
            }
        }

        if (-not (Microsoft.PowerShell.Core\Get-Command 'paintdotnet.exe' -ErrorAction SilentlyContinue)) {
            throw 'Paint.NET installation failed: paintdotnet.exe not found after installation'
        }
    }
}