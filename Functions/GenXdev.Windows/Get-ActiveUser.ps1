###############################################################################
<#
.SYNOPSIS
Retrieves a list of unique usernames from currently active system processes.

.DESCRIPTION
Queries all running processes on the system, extracts the associated username for
each process, and returns a deduplicated list of users who have active processes.
This is useful for system administration and security monitoring.

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
Get-ActiveUser
Returns a list of all unique usernames with active processes.

.EXAMPLE
gusers
Uses the alias to get the same results.
###############################################################################>
function Get-ActiveUser {

    [CmdletBinding()]
    [Alias('gusers')]
    param()

    begin {

        # store original error preferences for restoration
        $originalEAP = $ErrorActionPreference
        $originalErrorView = $ErrorView

        # set strict error handling
        $ErrorActionPreference = 'Stop'
        $ErrorView = 'DetailedView'

        # inform about the start of process enumeration
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting to enumerate all system processes...'
    }


    process {

        try {

            # get all processes with associated usernames (requires admin privileges)
            $processes = Microsoft.PowerShell.Management\Get-Process * `
                -IncludeUserName `
                -ErrorAction Stop

            # extract and deduplicate usernames from process list
            $users = $processes |
                Microsoft.PowerShell.Core\ForEach-Object UserName |
                Microsoft.PowerShell.Utility\Select-Object -Unique

            # return the filtered list
            $users
        }
        catch [System.UnauthorizedAccessException] {

            Microsoft.PowerShell.Utility\Write-Error `
                -Message 'Access denied while retrieving processes. Run with elevated privileges.' `
                -Exception $_.Exception `
                -Category PermissionDenied `
                -ErrorId 'ActiveUserAccessDenied'
            throw
        }
        catch [System.ArgumentException] {

            Microsoft.PowerShell.Utility\Write-Error `
                -Message 'Invalid argument provided when retrieving processes.' `
                -Exception $_.Exception `
                -Category InvalidArgument `
                -ErrorId 'ActiveUserInvalidArgument'
            throw
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error `
                -Message "Unexpected error while retrieving active users: $_" `
                -Exception $_.Exception `
                -Category OperationStopped `
                -ErrorId 'ActiveUserUnexpectedError'
            throw
        }
    }

    end {

        # restore original error handling settings
        $ErrorActionPreference = $originalEAP
        $ErrorView = $originalErrorView

        # output completion status if users were found
        if ($null -ne $users) {

            Microsoft.PowerShell.Utility\Write-Verbose `
                "Process completed. Found $($users.Count) unique active users."
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Process completed. No active users found or an error occurred.'
        }
    }
}