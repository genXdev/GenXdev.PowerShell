# Don't remove this line [dontrefactor]

###############################################################################
<#
.SYNOPSIS
Extracts archive files in the current directory to their own folders and deletes
them afterwards.

.DESCRIPTION
Automatically extracts common archive formats (zip, 7z, tar, etc.) found in the
current directory into individual folders named after each archive. After
successful extraction, the original archive files are deleted unless
-DontDeleteArchives is specified. Requires 7-Zip to be installed on the
system.

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
PS C:\Downloads> Invoke-Fasti

.EXAMPLE
PS C:\Downloads> fasti

.NOTES
Supported formats: 7z, zip, rar, tar, iso and many others.
Requires 7-Zip installation (will attempt auto-install via winget if missing).
#>
function Invoke-Fasti {

    [CmdletBinding()]
    [Alias("fasti")]
    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Enter the password for the encrypted archive(s)"
        )]
        [string] $Password,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Recursively extract archives found within extracted folders"
        )]
        [switch] $ExtractOutputToo,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to 7-Zip installation ' +
                'and set persistent flag.')
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
            HelpMessage = ('Keep original archive files after ' +
                'successful extraction.')
        )]
        [switch] $DontDeleteArchives,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
    )

    begin {

        # list of supported archive extensions
        $extensions = @("*.7z", "*.7z.001", "*.xz", "*.bzip2", "*.gzip", "*.tar", "*.zip", "*.zip.001",
            "*.wim", "*.ar", "*.arj", "*.cab", "*.chm", "*.cpio", "*.cramfs",
            "*.dmg", "*.ext", "*.fat", "*.gpt", "*.hfs", "*.ihex", "*.iso",
            "*.lzh", "*.lzma", "*.mbr", "*.msi", "*.nsis", "*.ntfs", "*.qcow2",
            "*.rar", "*.rpm", "*.squashfs", "*.udf", "*.uefi", "*.vdi", "*.vhd",
            "*.vmdk", "*.wim", "*.xar", "*.z")
    }


    process {

        # process each archive file found in current directory
        Microsoft.PowerShell.Management\Get-ChildItem -Path $extensions -File -ErrorAction SilentlyContinue |
            Microsoft.PowerShell.Core\ForEach-Object {

                Microsoft.PowerShell.Utility\Write-Verbose "Processing archive: $($PSItem.Name)"

                # get archive details
                $zipFile = $PSItem.fullname
                $name = [system.IO.Path]::GetFileNameWithoutExtension($zipFile)
                $path = [System.IO.Path]::GetDirectoryName($zipFile)
                $extractPath = [system.Io.Path]::Combine($path, $name)

                # create extraction directory if it doesn"t exist
                if ([System.IO.Directory]::exists($extractPath) -eq $false) {

                    Microsoft.PowerShell.Utility\Write-Verbose "Creating directory: $extractPath"
                    [System.IO.Directory]::CreateDirectory($extractPath)
                }

                # ensure 7-Zip is installed and on PATH
                $ensureParams = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\Ensure7Zip'
                GenXdev\Ensure7Zip @ensureParams

                # extract archive contents
                Microsoft.PowerShell.Utility\Write-Verbose "Extracting to: $extractPath"
                $pwparam = if ($Password) { "-p$Password" } else { "" }
                if ([string]::IsNullOrWhiteSpace($Password)) {

                    7z x -y "-o$extractPath" $zipFile
                }
                else {

                    7z x -y $pwparam "-o$extractPath" $zipFile
                }

                # delete original archive if extraction succeeded (unless -DontDeleteArchives)
                if ($? -and (-not $DontDeleteArchives)) {

                    try {
                        Microsoft.PowerShell.Utility\Write-Verbose "Removing original archive: $zipFile"
                        Microsoft.PowerShell.Management\Remove-Item -LiteralPath "$zipFile" -Force -ErrorAction silentlycontinue
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose "Failed to remove original archive"
                    }
                }

                # if ExtractOutputToo is enabled, recursively extract archives in the output folder
                if ($? -and $ExtractOutputToo) {
                    Microsoft.PowerShell.Utility\Write-Verbose "Checking for nested archives in: $extractPath"

                    do {
                        # find all archives recursively in the extraction path
                        $nestedArchives = Microsoft.PowerShell.Management\Get-ChildItem -Recurse -File "${extractPath}\*" -ErrorAction SilentlyContinue |
                            Microsoft.PowerShell.Core\Where-Object {
                                $extensions -contains "*$($_.Extension)"
                            }

                            if ($nestedArchives.Count -eq 0) {
                                Microsoft.PowerShell.Utility\Write-Verbose "No more nested archives found"
                                break
                            }

                            Microsoft.PowerShell.Utility\Write-Verbose "Found $($nestedArchives.Count) nested archive(s)"

                            $nestedDirectories = $nestedArchives | Microsoft.PowerShell.Core\ForEach-Object {
                                [System.IO.Path]::GetDirectoryName($_.FullName)
                            } | Microsoft.PowerShell.Utility\Select-Object -Unique

                            $errorOccured = $false

                            # process each nested archive in its own directory
                            foreach ($nestedDirectory in $nestedDirectories) {

                                Microsoft.PowerShell.Utility\Write-Verbose "Processing nested archive in: $nestedDirectory"

                                try {
                                    Microsoft.PowerShell.Management\Push-Location -LiteralPath $nestedDirectory
                                    if ($Password) {
                                        GenXdev\Invoke-Fasti -Password $Password -ExtractOutputToo -DontDeleteArchives:$DontDeleteArchives
                                    }
                                    else {
                                        GenXdev\Invoke-Fasti -ExtractOutputToo -DontDeleteArchives:$DontDeleteArchives
                                    }
                                }
                                catch {
                                    $errorOccured = $true
                                    Microsoft.PowerShell.Utility\Write-Verbose "Error occurred while processing nested archive in: $nestedDirectory"
                                }
                                finally {
                                    Microsoft.PowerShell.Management\Pop-Location
                                }
                            }
                        } while (-not $errorOccured)
                    }
                }
    }

    end {
    }
}