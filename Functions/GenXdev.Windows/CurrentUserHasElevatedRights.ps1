###############################################################################
<#
.SYNOPSIS
Checks if the current user has elevated rights.

.DESCRIPTION
Determines whether the current Windows user has administrative or backup operator
privileges by checking their security principal roles. Returns true if the user
has elevated rights, false otherwise. Implements robust error handling for
security and access-related issues.

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

.OUTPUTS
System.Boolean
Returns true if user has admin or backup operator rights, false otherwise.

.EXAMPLE
$hasRights = CurrentUserHasElevatedRights
###############################################################################>
function CurrentUserHasElevatedRights {

    [CmdletBinding()]
    [OutputType([System.Boolean])]
    param()

    begin {

        # store original error preferences for restoration
        $originalEAP = $ErrorActionPreference
        $originalErrorView = $ErrorView

        # set strict error handling
        $ErrorActionPreference = 'Stop'
        $ErrorView = 'DetailedView'

        Microsoft.PowerShell.Utility\Write-Verbose "Checking current user's security privileges..."
    }


    process {

        try {

            # get the current windows identity with error handling
            $identity = [System.Security.Principal.WindowsIdentity]::GetCurrent()

            # create a new principal object from the identity
            $principal = Microsoft.PowerShell.Utility\New-Object `
                -TypeName System.Security.Principal.WindowsPrincipal `
                -ArgumentList $identity

            # check for administrative or backup operator privileges
            if ($principal.IsInRole(
                    [System.Security.Principal.WindowsBuiltInRole]::Administrator) -or
                $principal.IsInRole(
                    [System.Security.Principal.WindowsBuiltInRole]::BackupOperator)) {

                Microsoft.PowerShell.Utility\Write-Verbose 'User has elevated rights'
                return $true
            }

            Microsoft.PowerShell.Utility\Write-Verbose 'User does not have elevated rights'
            return $false
        }
        catch [System.Security.SecurityException] {

            Microsoft.PowerShell.Utility\Write-Error `
                -Message 'Security violation checking user rights' `
                -Exception $_.Exception `
                -Category SecurityError `
                -ErrorId 'SecurityViolation'
            throw
        }
        catch [System.UnauthorizedAccessException] {

            Microsoft.PowerShell.Utility\Write-Error `
                -Message 'Access denied while verifying user privileges' `
                -Exception $_.Exception `
                -Category PermissionDenied `
                -ErrorId 'AccessDenied'
            throw
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error `
                -Message 'Unexpected error during rights verification' `
                -Exception $_.Exception `
                -Category OperationStopped `
                -ErrorId 'UnexpectedError'
            throw
        }
    }

    end {

        # restore original error handling settings
        $ErrorActionPreference = $originalEAP
        $ErrorView = $originalErrorView
    }
}