###############################################################################
<#
.SYNOPSIS
Ensures the Windows Media Feature Pack is installed.

.DESCRIPTION
Checks whether the Windows Media Feature Pack is installed on Windows N
editions and installs it if missing. On non-N editions, no action is
taken. Supports automatic consent for installation prompts and can
elevate privileges when needed.

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

#>
function EnsureWindowsMediaFeaturePack {

    [CmdletBinding()]
    param(
        [switch] $Force,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to Windows Media Feature ' +
                'Pack and Edge installation and set persistent flag.')
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
        if ($Force) {
            Microsoft.PowerShell.Utility\Write-Verbose "Force mode enabled – will ensure mfplat.dll exists."
        }
    }

    process {

        $edition = (CimCmdlets\Get-CimInstance Win32_OperatingSystem).Caption
        $isN = $edition -like '*N*'

        if ($isN) {

            Microsoft.PowerShell.Utility\Write-Verbose "Detected Windows N edition – installing Media Feature Pack."

            $cap = Dism\Get-WindowsCapability -Online -Name 'Media.MediaFeaturePack~~~~0.0.1.0' | Microsoft.PowerShell.Core\Where-Object State -eq Installed

            if (-not $cap) {

                # verify administrative privileges are available
                if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                    $json = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName "GenXdev\EnsureWindowsMediaFeaturePack" |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                    GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsureWindowsMediaFeaturePack @params
"@)) -JobDescription 'Installing Windows Media Feature Pack';

                    return;
                }

                # YOUR CONSENT PROMPT — preserved exactly
                $consent = GenXdev\Confirm-InstallationConsent `
                    -ApplicationName 'Windows Media Feature Pack' `
                    -Source 'Windows' `
                    -Description 'Your $Edition is missing critical components for playing video, text-to-speech, etc' `
                    -Publisher 'Microsoft' `
                    -AutoConsent:$AutoConsent `
                    -AutoConsentAllPackages:$AutoConsentAllPackages

                if (-not $consent) {
                    Microsoft.PowerShell.Utility\Write-Verbose 'Windows Media Feature Pack installation cancelled by user.'
                    return
                }

                Microsoft.PowerShell.Utility\Write-Verbose "Media Feature Pack not installed – installing now."

                try {
                    Dism\Add-WindowsCapability -Online -Name 'Media.MediaFeaturePack~~~~0.0.1.0' -ErrorAction Stop

                    # verify the capability was installed
                    $cap = Dism\Get-WindowsCapability -Online `
                        -Name 'Media.MediaFeaturePack~~~~0.0.1.0' |
                        Microsoft.PowerShell.Core\Where-Object State -eq Installed
                    if (-not $cap) {
                        throw 'Media Feature Pack installation verification failed — capability not found after installation.'
                    }
                }
                catch {
                    throw "Failed to install Media Feature Pack: $($_.Exception.Message)"
                }
            }
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "Non‑N edition – Media Feature Pack is irrelevant."
        }

        if ($Force) {

            $edge = Microsoft.WinGet.Client\Get-WinGetPackage -Id Microsoft.Edge | Microsoft.PowerShell.Core\Where-Object { $_.Id -eq 'Microsoft.Edge' }

            if ($edge) {

                Microsoft.PowerShell.Utility\Write-Verbose "Microsoft Edge is already installed."
                return
            }

            Microsoft.PowerShell.Utility\Write-Warning "Microsoft Edge is not installed – but needed for certain media features like text-to-speech."

            if ($fod) {

                $consent = GenXdev\Confirm-InstallationConsent `
                    -ApplicationName 'Microsoft Edge Browser (AppX)' `
                    -Source 'Windows' `
                    -Description 'Installing Edge from offline FoD package.' `
                    -Publisher 'Microsoft' `
                    -AutoConsent:$AutoConsent `
                    -AutoConsentAllPackages:$AutoConsentAllPackages

                if (-not $consent) {

                    Microsoft.PowerShell.Utility\Write-Warning "Edge installation cancelled by user."
                    return
                }

                try {
                    Microsoft.WinGet.Client\Install-WinGetPackage -Id Microsoft.Edge -Force

                    Microsoft.PowerShell.Utility\Write-Host "Microsoft Edge installed from offline package."
                    return
                }
                catch {

                }
            }
        }
    }
}