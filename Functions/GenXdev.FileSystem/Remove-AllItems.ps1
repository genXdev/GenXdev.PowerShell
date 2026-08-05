###############################################################################
<#
.SYNOPSIS
Recursively removes all content from a directory with advanced error handling.

.DESCRIPTION
Safely removes all files and subdirectories within a specified directory

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

.PARAMETER Path
The directory path to clear. Can be relative or absolute path. Will be normalized
and expanded before processing.

.PARAMETER DeleteFolder
When specified, also removes the root directory specified by Path after clearing
its contents.

.PARAMETER WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

.EXAMPLE
Remove-AllItems -Path "C:\Temp\BuildOutput" -DeleteFolder -Verbose

.EXAMPLE
sdel ".\temp" -DeleteFolder
#>
function Remove-AllItems {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Alias('sdel')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'The directory path to clear'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('FullName')]
        [string] $Path,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Also delete the root folder supplied with the Path parameter'
        )]
        [switch] $DeleteFolder
        ###############################################################################
    )

    begin {

        # convert relative or shorthand paths to full filesystem paths
        $Path = GenXdev\Expand-Path "$Path\"
        Microsoft.PowerShell.Utility\Write-Verbose "Normalized path: $Path"
    }

    process {
        try {
            if (-not [System.IO.Directory]::Exists($Path)) {

                Microsoft.PowerShell.Utility\Write-Verbose "Directory does not exist: $Path"
                return
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Processing directory: $Path"

            if (-not $PSCmdlet.ShouldProcess($Path, 'Delete directory')) { return }

            $null = cmd.exe /c rd /S /Q "$Path" 2>&1

            if (-not $DeleteFolder) {

                $null = GenXdev\Expand-Path "$Path\" -CreateDirectory
            }
        }
        catch {

           GenXdev\Show-ExceptionPanel -Exception $_.Exception
        }
    }

    end {
    }
}