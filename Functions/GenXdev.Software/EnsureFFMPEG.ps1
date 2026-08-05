###############################################################################
<#
.SYNOPSIS
Ensures FFmpeg is installed and available on the PATH.

.DESCRIPTION
This function verifies if FFmpeg is installed on the system by checking both
the PATH and the default WinGet installation locations. If not found, it
attempts to install FFmpeg via winget after obtaining user consent. Adds the
FFmpeg directory to the session PATH so that ffmpeg.exe can be invoked
directly.

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
EnsureFFMPEG
ffmpeg -i input.mp4 -ac 1 -ar 16000 output.wav
#>
function EnsureFFMPEG {

    [CmdletBinding()]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseBOMForUnicodeEncodedFile', '')]
    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to FFmpeg installation ' +
                'and set persistent flag.')
        )]
        [switch] $AutoConsent,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only auto consent during session')
        )]
        [switch] $SessionOnly
        #######################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose 'Ensuring FFmpeg is installed...'

        # known installation locations for ffmpeg via winget
        $wingetLinksPath = "${env:LOCALAPPDATA}\Microsoft\WinGet\Links"
        $ffmpegSymlink = "${wingetLinksPath}\ffmpeg.exe"

        # add the ffmpeg directory to the session PATH
        if ($ffmpegDir -and ($env:Path -notlike "*${ffmpegDir}*")) {
            $env:Path = "${ffmpegDir};${env:Path}"
            Microsoft.PowerShell.Utility\Write-Verbose "Added FFmpeg directory to PATH: ${ffmpegDir}"
        }
    }

    process {

        # check if ffmpeg is available in PATH
        if ((Microsoft.PowerShell.Core\Get-Command 'ffmpeg' -ErrorAction SilentlyContinue).Length -eq 0) {

            $ffmpegFound = $false

            # try the symlink location (fastest)
            if ([System.IO.File]::Exists($ffmpegSymlink)) {

                $ffmpegFound = $true
                $ffmpegDir = $wingetLinksPath
            }

            # fallback to recursive search in winget directory
            if (-not $ffmpegFound) {

                $foundExe = Microsoft.PowerShell.Management\Get-ChildItem `
                    -LiteralPath "${env:LOCALAPPDATA}\Microsoft\WinGet" `
                    -Filter "ffmpeg.exe" `
                    -Recurse -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Utility\Select-Object -First 1

                if ($foundExe) {

                    $ffmpegFound = $true
                    $ffmpegDir = [System.IO.Path]::GetDirectoryName(
                        $foundExe.FullName
                    )

                    # add the ffmpeg directory to the session PATH
                    if ($ffmpegDir -and ($env:Path -notlike "*${ffmpegDir}*")) {
                        $env:Path = "${ffmpegDir};${env:Path}"
                        Microsoft.PowerShell.Utility\Write-Verbose "Added FFmpeg directory to PATH: ${ffmpegDir}"
                    }
                }
            }

            if (-not $ffmpegFound) {

                # verify administrative privileges are available
                if (-not (GenXdev\CurrentUserHasElevatedRights)) {

                    $json = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName "GenXdev\EnsureFFMpeg" |
                        Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

                    GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\EnsureFFMPEG @params
"@)) -JobDescription 'Installing FFMpeg';

                    # fallback to recursive search in winget directory
                    if (-not $ffmpegFound) {

                        $foundExe = Microsoft.PowerShell.Management\Get-ChildItem `
                            -LiteralPath "${env:LOCALAPPDATA}\Microsoft\WinGet" `
                            -Filter "ffmpeg.exe" `
                            -Recurse -ErrorAction SilentlyContinue |
                            Microsoft.PowerShell.Utility\Select-Object -First 1

                        if ($foundExe) {

                            $ffmpegFound = $true
                            $ffmpegDir = [System.IO.Path]::GetDirectoryName(
                                $foundExe.FullName
                            )

                            # add the ffmpeg directory to the session PATH
                            if ($ffmpegDir -and ($env:Path -notlike "*${ffmpegDir}*")) {
                                $env:Path = "${ffmpegDir};${env:Path}"
                                Microsoft.PowerShell.Utility\Write-Verbose "Added FFmpeg directory to PATH: ${ffmpegDir}"
                            }
                        }
                    }

                    return;
                }

                # FFmpeg not found — need to install
                Microsoft.PowerShell.Utility\Write-Verbose 'FFmpeg not found, attempting installation...'
                Microsoft.PowerShell.Utility\Write-Host 'FFmpeg not found. Installing FFmpeg...'


                try {
                    # request consent before installing FFmpeg
                    $consentParams = GenXdev\Copy-IdenticalParamValues `
                        -BoundParameters $PSBoundParameters `
                        -FunctionName 'GenXdev\Confirm-InstallationConsent'

                    $consent = GenXdev\Confirm-InstallationConsent `
                        @consentParams `
                        -ApplicationName 'FFmpeg' `
                        -Source 'Winget' `
                        -Description ('Audio/video processing library ' +
                        'required for converting media files to formats ' +
                        'compatible with speech recognition and other ' +
                        'media operations') `
                        -Publisher 'Gyan'

                    if (-not $consent) {
                        throw 'FFmpeg installation was denied by user.'
                    }

                    # install FFmpeg via winget
                    Microsoft.PowerShell.Utility\Write-Verbose 'Installing FFmpeg via winget...'
                    Microsoft.WinGet.Client\Install-WinGetPackage -Id 'Gyan.FFmpeg' -MatchOption EqualsCaseInsensitive

                    # re-check the symlink location after installation
                    if (-not [System.IO.File]::Exists($ffmpegSymlink)) {
                        throw 'FFmpeg installation completed but ffmpeg.exe was not found at the expected location.'
                    }

                    $ffmpegDir = $wingetLinksPath
                    Microsoft.PowerShell.Utility\Write-Host 'FFmpeg installed successfully.'
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Error "Failed to install FFmpeg. Error: $PSItem"
                    throw
                }
            }

        }

        Microsoft.PowerShell.Utility\Write-Verbose 'FFmpeg is available on PATH.'
    }

    end {

        if (-not (Microsoft.PowerShell.Core\Get-Command ffmpeg.exe)) {

            throw "FFMPeg not installed successfully"
        }
    }
}