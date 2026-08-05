###############################################################################
<#
.SYNOPSIS
Permanently deletes specified folders from all branches in a Git repository.

.DESCRIPTION
Cleans a Git repository by removing specified folders from the entire commit
history across all branches. This is done by cloning the repository, using
git filter-branch to remove the folders, and force pushing the changes back.
This operation is destructive and permanently rewrites Git history.

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

.PARAMETER RepoUri
The Git repository URI to clean (HTTPS or SSH format).

.PARAMETER Folders
Array of folder paths to remove from the repository history. Paths can be
specified with forward or back slashes.

.NOTES
This operation is destructive and cannot be undone. It rewrites Git history and
requires force pushing, which affects all repository users.

.EXAMPLE
PermanentlyDeleteGitFolders `
    -RepoUri "https://github.com/user/repo.git" `
    -Folders "bin", "obj"
#>
function PermanentlyDeleteGitFolders {

    [CmdletBinding(SupportsShouldProcess = $true, ConfirmImpact = 'High')]
    [OutputType([string[]])]
    param(
        ########################################################################
        [parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The URI of the Git repository to clean'
        )]
        [string] $RepoUri,
        ########################################################################
        [parameter(
            Position = 1,
            Mandatory = $true,
            HelpMessage = 'Array of folder paths to permanently remove'
        )]
        [string[]] $Folders,
        ########################################################################
        [parameter(Mandatory = $false)]
        [string] $tempPath = "~\convert.tmp\"
        ########################################################################
    )

    begin {

        $oldErrorActionPreference = $ErrorActionPreference
        $ErrorActionPreference = 'Stop'

        # display prominent warnings about the destructive nature of this operation
        Microsoft.PowerShell.Utility\Write-Warning '!!! DANGER - PERMANENT DESTRUCTIVE OPERATION !!!'
        Microsoft.PowerShell.Utility\Write-Warning ('This operation will permanently delete the specified ' +
            'folders from ALL git history')
        Microsoft.PowerShell.Utility\Write-Warning ('It rewrites Git history and force pushes the changes, ' +
            'which CANNOT BE UNDONE')
        Microsoft.PowerShell.Utility\Write-Warning ('Other users of this repository will need to re-clone ' +
            'or reset their local copies')

        # create unique temp directory using UTC ticks for isolation
        $tempPath = GenXdev\Expand-Path $tempPath -CreateDirectory
        Microsoft.PowerShell.Utility\Write-Verbose "Using temp directory: $tempPath"

        # store current location to restore at end
        Microsoft.PowerShell.Management\Push-Location
    }


    process {

        # final confirmation before proceeding with destructive operation
        if (-not $PSCmdlet.ShouldProcess(
                ("Repository: $RepoUri - Permanently delete folders: " +
                "$($Folders -join ', ')"),
                ('Are you ABSOLUTELY SURE you want to permanently remove ' +
                'these folders from ALL git history?'),
                'DANGER: Permanent Git History Modification')) {
            Microsoft.PowerShell.Utility\Write-Verbose 'Operation cancelled by user'
            return
        }

        try {

            # change to temp directory
            Microsoft.PowerShell.Management\Set-Location -LiteralPath $tempPath
            Microsoft.PowerShell.Utility\Write-Verbose 'Changed to temp directory'

            # clone the repository
            Microsoft.PowerShell.Utility\Write-Verbose "Cloning repository: $RepoUri"
            $null = git clone $RepoUri repo

            # change to repo directory
            Microsoft.PowerShell.Management\Set-Location -LiteralPath repo
            Microsoft.PowerShell.Utility\Write-Verbose 'Changed to repository directory'

            # create tracking branches for all remote branches except HEAD
            Microsoft.PowerShell.Utility\Write-Verbose 'Creating tracking branches'
            git branch -r | Microsoft.PowerShell.Core\ForEach-Object {

                if (-not $PSItem.Contains('/HEAD')) {
                    $null = git checkout --track $PSItem.Trim()
                }

                # process each folder to remove
                foreach ($folder in $Folders) {

                    # normalize folder path to use forward slashes
                    $folderFixed = $folder.replace('\', '/')
                    if ($folderFixed.endswith('/')) {
                        $folderFixed = $folderFixed.Substring(0, $folderFixed.Length - 1)
                    }

                    if ($PSCmdlet.ShouldProcess($folderFixed, 'Removing from Git history')) {
                        # remove folder from git history
                        Microsoft.PowerShell.Utility\Write-Verbose "Removing $folderFixed from history"
                        $filterCommand = "git rm -rf --cached --ignore-unmatch $folderFixed/"
                        git filter-branch --index-filter $filterCommand --prune-empty --tag-name-filter cat -- --all
                    }
                }

                try {
                    # clean up refs
                    Microsoft.PowerShell.Utility\Write-Verbose 'Cleaning up refs'
                    $refs = git for-each-ref --format="%(refname)" refs/original/
                    foreach ($ref in $refs) {
                        git update-ref -d $ref
                    }

                    # remove old refs and logs
                    Microsoft.PowerShell.Management\Get-ChildItem -LiteralPath @('.git/logs', '.git/refs/original') `
                        -ErrorAction SilentlyContinue -Directory |
                        Microsoft.PowerShell.Core\ForEach-Object -ErrorAction SilentlyContinue {
                            Microsoft.PowerShell.Management\Remove-Item -LiteralPath $PSItem.FullName -Force -Recurse `
                                -ErrorAction SilentlyContinue
                        }
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose "Error cleaning up refs (non-critical): $_"
                    }

                    # garbage collect to remove unreferenced commits
                    Microsoft.PowerShell.Utility\Write-Verbose 'Running garbage collection'
                    $null = git gc --prune=all --aggressive

                    # force push changes to remote
                    if ($PSCmdlet.ShouldProcess('Origin', 'Force pushing all changes')) {
                        Microsoft.PowerShell.Utility\Write-Verbose 'Force pushing changes to remote'
                        $null = git push origin --all --force
                        $null = git push origin --tags --force
                    }
                }
            }
            finally {
                # restore original working directory
                Microsoft.PowerShell.Utility\Write-Verbose 'Restored original location'
            }
        }

        end {
            $ErrorActionPreference = $oldErrorActionPreference
            Microsoft.PowerShell.Management\Pop-Location
        }
    }