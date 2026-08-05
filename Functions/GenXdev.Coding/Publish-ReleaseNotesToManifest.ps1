###############################################################################
<#
.SYNOPSIS
Publishes uncompleted release notes from README.md to the module manifest.

.DESCRIPTION
Reads the "## Release notes" section from a README.md file, collects all
uncompleted release notes (lines starting with - ☐), writes them into the
ReleaseNotes field of GenXdev.psd1, and marks them as completed (☐ → ☒)
in the README. Both files are updated atomically in one operation.

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

.PARAMETER UseHomeREADME
Use README.md from PowerShell profile directory instead of current location.

.PARAMETER UseOneDriveREADME
Use README.md from OneDrive directory instead of current location.

.PARAMETER ManifestPath
Path to the .psd1 module manifest to update. If not specified, auto-detects
the GenXdev.psd1 in the module directory.

.EXAMPLE
Publish-ReleaseNotesToManifest

.EXAMPLE
Publish-ReleaseNotesToManifest -ManifestPath ".\MyModule.psd1"
#>
function Publish-ReleaseNotesToManifest {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias('pubrelnotes')]
    param(
        #######################################################################
        [Parameter(
            Mandatory = $true,
            HelpMessage = 'Path to the .psd1 module manifest'
        )]
        [string] $ManifestPath,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use README in PowerShell profile directory'
        )]
        [switch] $UseHomeREADME,

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use README in OneDrive directory'
        )]
        [switch] $UseOneDriveREADME
    )

    begin {
        Microsoft.PowerShell.Utility\Write-Verbose `
            'Starting Publish-ReleaseNotesToManifest'

        # Resolve README path (same logic as Add-LineToREADME begin block)
        if ($UseHomeREADME) {
            $readmePath = GenXdev\Expand-Path `
                -FilePath "$([IO.Path]::GetDirectoryName($Profile))\README.md"
        }
        elseif ($UseOneDriveREADME) {
            $readmePath = GenXdev\Expand-Path `
                -FilePath "$(GenXdev\Get-KnownFolderPath -KnownFolder 'OneDrive')\README.md" `
                -CreateDirectory
        }
        else {
            # Walk up from current directory to find README
            $startDir = GenXdev\Expand-Path $PWD
            $readmePath = $null
            $currentDir = $startDir
            while ($true) {
                $candidate = "$currentDir\README.md"
                if ([System.IO.File]::Exists($candidate)) {
                    $readmePath = $candidate
                    break
                }
                $parent = GenXdev\Expand-Path "$currentDir\..\"
                if ($parent -eq $currentDir) { break }
                $currentDir = $parent
            }
            if (-not $readmePath) {
                $readmePath = GenXdev\Expand-Path `
                    -FilePath "$(GenXdev\Get-KnownFolderPath -KnownFolder 'OneDrive')\README.md" `
                    -CreateDirectory
            }
        }

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using README at: ${readmePath}"

        if (![IO.File]::Exists($readmePath)) {
            throw "README file not found at: ${readmePath}"
        }

        if ([String]::IsNullOrWhiteSpace($ManifestPath)) {

            throw "Specify a valid ManifestPath -ManifestPath."
        }

        $ManifestPath = GenXdev\Expand-Path $ManifestPath;

        if (-not [IO.File]::Exists($ManifestPath)) {

            throw "Module manifest not found. Specify -ManifestPath."
        }

        Microsoft.PowerShell.Utility\Write-Verbose `
            "Using manifest at: ${ManifestPath}"
    }

    process {
        # Read README content
        $readmeContent = [IO.File]::ReadAllText($readmePath)
        $lineEnding = if ($readmeContent.IndexOf("`r`n") -ge 0) { "`r`n" } `
            else { "`n" }

        $section = '## Release notes'

        # Find the section
        $sectionStart = $readmeContent.IndexOf(
            $section,
            [System.StringComparison]::OrdinalIgnoreCase
        )
        if ($sectionStart -lt 0) {
            Microsoft.PowerShell.Utility\Write-Warning `
                "Section '${section}' not found in ${readmePath}"
            return
        }

        $sectionContentStart = $sectionStart + $section.Length +
            $lineEnding.Length
        $sectionLevel = ($section -replace '^([#]+).*$', '$1').Length
        $rest = $readmeContent.Substring($sectionContentStart)
        $nextHeading = [regex]::Match($rest, "(?m)^#{1,$sectionLevel}\s")
        $sectionEnd = if ($nextHeading.Success) {
            $sectionContentStart + $nextHeading.Index
        }
        else { $readmeContent.Length }

        $sectionContent = $readmeContent.Substring(
            $sectionContentStart,
            $sectionEnd - $sectionContentStart
        )
        $sectionLines = $sectionContent -split $lineEnding

        # Collect uncompleted release notes (lines with ☐)
        $uncompletedLines = [System.Collections.Generic.List[string]]::new()
        $uncompletedRaw = [System.Collections.Generic.List[string]]::new()
        $lineIndices = [System.Collections.Generic.List[int]]::new()

        for ($i = 0; $i -lt $sectionLines.Count; $i++) {
            $ln = $sectionLines[$i]
            if ($ln -match '^- ☐ \[P') {
                # Strip prefix and date: "- ☐ [P{N}] yyyyMMdd --> " → raw text
                $rawText = $ln -replace '^- ☐ \[P-?\d+\] \d{8}\s*-->\s*', ''
                $null = $uncompletedLines.Add($ln)
                $null = $uncompletedRaw.Add($rawText)
                $null = $lineIndices.Add($i)
            }
        }

        if ($uncompletedRaw.Count -eq 0) {
            Microsoft.PowerShell.Utility\Write-Host `
                'No uncompleted release notes found.'
            return
        }

        # Build release notes text for the manifest
        $releaseNotesText = ($uncompletedRaw -join "`n")

        # Mark lines as done in README
        foreach ($idx in $lineIndices) {
            $sectionLines[$idx] = $sectionLines[$idx].Replace('☐', '☒')
        }
        $newSectionContent = $sectionLines -join $lineEnding
        $newReadmeContent = $readmeContent.Substring(0, $sectionContentStart) +
            $newSectionContent +
            $readmeContent.Substring($sectionEnd)

        # Write both files atomically
        if ($PSCmdlet.ShouldProcess(
                "README and ${ManifestPath}",
                'Publish release notes to manifest'
            )) {
            # Save backup copies first
            $readmeBackup = $readmeContent
            $manifestBackup = [IO.File]::ReadAllText($ManifestPath)

            try {
                GenXdev\Write-TextFileAtomic `
                    -FilePath $readmePath `
                    -Data $newReadmeContent

                PowerShellGet\Update-ModuleManifest -Path $ManifestPath -ReleaseNotes $releaseNotesText -Confirm:$false

                Microsoft.PowerShell.Utility\Write-Host `
                    "Published $($uncompletedRaw.Count) release note(s) to ${ManifestPath}"
            }
            catch {
                # Rollback on failure
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Write failed, rolling back: $_"
                try {
                    GenXdev\Write-TextFileAtomic `
                        -FilePath $readmePath `
                        -Data $readmeBackup
                }
                catch {
                    Microsoft.PowerShell.Utility\Write-Warning `
                        "Rollback also failed: $_"
                }
                throw
            }
        }
    }

    end {
    }
}