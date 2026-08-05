###############################################################################

<#
.SYNOPSIS
Reads JSON file with retry logic and automatic lock cleanup.

.DESCRIPTION
Attempts to read a JSON file with retry logic to handle concurrent access.
Implements automatic cleanup of stale lock files. Returns empty hashtable if
file doesn't exist.

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
The path to the JSON file to read.

.PARAMETER AsHashtable
Return the parsed JSON as a hashtable instead of PSCustomObject. Defaults to true.

.PARAMETER MaxRetries
Maximum number of retry attempts. Defaults to 10.

.PARAMETER RetryDelayMs
Delay in milliseconds between retries. Defaults to 200.
#>
function ReadJsonWithRetry {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string]$FilePath,

        [Parameter(Mandatory = $false)]
        [int]$MaxRetries = 10,

        [Parameter(Mandatory = $false)]
        [int]$RetryDelayMs = 200,

        [Parameter(Mandatory = $false)]
        [switch]$AsHashtable
    )

    # return empty hashtable if file doesn't exist
    if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $FilePath)) {
        if ($AsHashtable) {
            return @{}
        }
        else {
            return
        }
    }

    # construct lock file path
    $lockFile = "${FilePath}.lock"

    # attempt to read with retries
    for ($attempt = 0; $attempt -lt $MaxRetries; $attempt++) {
        try {
            # clean up stale lock files older than 30 seconds
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $lockFile) {
                $lockInfo = [System.IO.FileInfo]::new($lockFile)
                $ageSeconds = ([DateTime]::Now - $lockInfo.LastWriteTime).TotalSeconds

                if ($ageSeconds -gt 30) {
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Removing stale lock file: $lockFile (age: ${ageSeconds}s)"
                    Microsoft.PowerShell.Management\Remove-Item `
                        -LiteralPath $lockFile `
                        -Force `
                        -ErrorAction SilentlyContinue
                }
            }

            # read and parse json file
            $content = Microsoft.PowerShell.Management\Get-Content `
                -LiteralPath $FilePath `
                -Raw `
                -ErrorAction Stop

            if ([string]::IsNullOrWhiteSpace($content)) {
                if ($AsHashtable) {
                    return @{}
                }
                else {
                    return
                }
            }

            if ($AsHashtable) {
                $data = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json `
                    -AsHashtable `
                    -ErrorAction Stop
            }
            else {
                $data = $content | Microsoft.PowerShell.Utility\ConvertFrom-Json `
                    -ErrorAction Stop
            }

            return $data
        }
        catch {
            # log retry attempt
            Microsoft.PowerShell.Utility\Write-Verbose `
                "Read attempt $($attempt + 1) failed: $($_.Exception.Message)"

            # wait before retry unless this is the last attempt
            if ($attempt -lt ($MaxRetries - 1)) {
                Microsoft.PowerShell.Utility\Start-Sleep `
                    -Milliseconds $RetryDelayMs
            }
            else {
                # final attempt failed, throw error
                throw "Failed to read JSON file after ${MaxRetries} attempts: $_"
            }
        }
    }
}