<#
.SYNOPSIS
    Stabilizes the newest or specified .mp4 file using FFmpeg + vid.stab (no black borders).

.DESCRIPTION
    Two-pass vid.stab stabilization with optzoom=1 (auto zoom/crop so borders never show)
    plus light sharpening. Works exactly like your Save-Video cmdlet — super simple.

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

.PARAMETER InputFile
    Optional: specific .mp4 to stabilize. If omitted, uses the newest .mp4 in the folder.

.EXAMPLE
    Stabilize-Video                  # stabilizes the most recent .mp4
    Stabilize-Video shaky.mp4         # specific file
#>
function StabilizeVideo {

    [CmdletBinding()]
    param (
        [Parameter(Mandatory = $false, Position = 0)]
        [string]$InputFile
    )

    # ------------------------------------------------------------------
    # 1. Find the input file (newest .mp4 if not specified)
    # ------------------------------------------------------------------
    if (-not $InputFile) {
        $InputFile = Microsoft.PowerShell.Management\Get-ChildItem *.mp4 | Microsoft.PowerShell.Utility\Sort-Object LastWriteTime -Descending | Microsoft.PowerShell.Utility\Select-Object -First 1 -ExpandProperty FullName
        if (-not $InputFile) { throw "No .mp4 file found in the current folder." }
        Microsoft.PowerShell.Utility\Write-Host "Using newest file: $(Microsoft.PowerShell.Management\Split-Path $InputFile -Leaf)" -ForegroundColor Cyan
    }
    if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $InputFile)) { throw "File not found: $InputFile" }

    $file = Microsoft.PowerShell.Management\Get-Item $InputFile
    $dir = $file.DirectoryName
    $base = $file.BaseName
    $ext = $file.Extension
    $output = Microsoft.PowerShell.Management\Join-Path $dir "$base [stabilized]$ext"
    $trf = Microsoft.PowerShell.Management\Join-Path $dir "transforms.trf"

    # ------------------------------------------------------------------
    # 2. Pass 1 – detect camera motion
    # ------------------------------------------------------------------
    Microsoft.PowerShell.Utility\Write-Host "Pass 1/2: Analyzing shakiness..." -ForegroundColor Green
    ffmpeg -y -i $file -vf vidstabdetect=shakiness=8:accuracy=15 -f null NUL
    if ($LASTEXITCODE -ne 0) { throw "vidstabdetect failed" }

    # ------------------------------------------------------------------
    # 3. Pass 2 – apply stabilization (no black borders!)
    # ------------------------------------------------------------------
    Microsoft.PowerShell.Utility\Write-Host "Pass 2/2: Stabilizing & cropping (this may take a while)..." -ForegroundColor Green
    ffmpeg -y -i $file -vf "
vidstabtransform=input=$trf:optzoom=1:crop=black:zoom=3:smoothing=20,
unsharp=5:5:0.8:3:3:0.4" `
        -c:v libx264 -preset slow -crf 23 -tune film `
        -c:a copy `
        "$output"

    if ($LASTEXITCODE -ne 0) { throw "vidstabtransform failed" }

    # ------------------------------------------------------------------
    # 4. Cleanup & finish
    # ------------------------------------------------------------------
    Microsoft.PowerShell.Management\Remove-Item $trf -ErrorAction SilentlyContinue

    Microsoft.PowerShell.Utility\Write-Host "Done! Stabilized video saved as:" -ForegroundColor Green
    Microsoft.PowerShell.Utility\Write-Host "   $(Microsoft.PowerShell.Management\Split-Path $output -Leaf)" -ForegroundColor Yellow

    # Return the new file so you can pipe it (e.g. | Invoke-Item)
    Microsoft.PowerShell.Management\Get-Item $output
}