###############################################################################
<#
.SYNOPSIS
Sets the directory for face image files used in GenXdev.AI operations.

.DESCRIPTION
This function configures the global face directory used by the GenXdev.AI
module for various face recognition and AI operations. Settings can be stored
persistently in preferences (default), only in the current session (using
-SessionOnly), or cleared from the session (using -ClearSession).

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

.PARAMETER FacesDirectory
A directory path where face image files are located. This directory
will be used by GenXdev.AI functions for face discovery and processing
operations.

.PARAMETER SessionOnly
When specified, stores the setting only in the current session (Global
variable) without persisting to preferences. Setting will be lost when the
session ends.

.PARAMETER ClearSession
When specified, clears only the session setting (Global variable) without
affecting persistent preferences.

.PARAMETER PreferencesDatabasePath
Database path for preference data files.

.PARAMETER SkipSession
Dont use alternative settings stored in session for AI preferences like
Language, Image collections, etc.

.EXAMPLE
Set-AIKnownFacesRootpath -FacesDirectory "C:\Faces"

Sets the faces directory persistently in preferences.

.EXAMPLE
Set-AIKnownFacesRootpath "C:\FacePictures"

Sets the faces directory persistently in preferences.

.EXAMPLE
Set-AIKnownFacesRootpath -FacesDirectory "C:\TempFaces" -SessionOnly

Sets the faces directory only for the current session (Global variable).

.EXAMPLE
Set-AIKnownFacesRootpath -ClearSession

Clears the session faces directory setting (Global variable) without affecting
persistent preferences.
#>
###############################################################################
function Set-AIKnownFacesRootpath {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSAvoidGlobalVars', '')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSShouldProcess', '')]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            Position = 0,
            HelpMessage = 'Directory path for face image files'
        )]
        [string] $FacesDirectory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Database path for preference data files'
        )]
        [Alias('DatabasePath')]
        [string] $PreferencesDatabasePath,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for AI ' +
                'preferences like Language, Image collections, etc')
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Dont use alternative settings stored in session for ' +
                'AI preferences like Language, Image collections, etc')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession
        ###############################################################################
    )
    # fallback to default system directories
    $picturesPath = GenXdev\Expand-Path '~\Pictures'

    try {

        # attempt to get known folder path for pictures directory
        $picturesPath = GenXdev\Get-KnownFolderPath Pictures
    }
    catch {

        # fallback to default if known folder retrieval fails
        $picturesPath = GenXdev\Expand-Path '~\Pictures'
    }

    $params = GenXdev\Copy-IdenticalParamValues `
        -BoundParameters $PSBoundParameters `
        -FunctionName 'GenXdev\Set-GenXdevPreference'

    $null = GenXdev\Set-GenXdevPreference @params `
        -Name 'AIKnownFacesRootpath' `
        -Value "$((GenXdev\Expand-Path ([string]::IsNullOrWhiteSpace($FacesDirectory) ? "$picturesPath\Faces\" : $FacesDirectory) -CreateDirectory))"
}
###############################################################################