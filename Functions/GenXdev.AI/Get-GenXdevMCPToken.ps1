###############################################################################
<#
.SYNOPSIS
Resolves the GenXdev MCP server authentication token.

.DESCRIPTION
Returns the MCP token from the DPAPI protected token file, falling back to the
GENXDEV_MCP_TOKEN user environment variable. The protected file is written by
New-GenXdevMCPToken -SetProtectedFile and is encrypted with the Windows Data
Protection API, so it decrypts silently for the same user on the same machine
and never prompts for a password.

The environment variable is only honoured as a fallback, so an existing setup
that still stores its token there keeps working.

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
System.String. The token, or nothing when no token is configured.

.PARAMETER ProtectedFilePath
Path of the DPAPI protected token file. Defaults to
%LOCALAPPDATA%\GenXdev\mcp-token.clixml.

.PARAMETER ProtectedFileOnly
Only report a token that is stored in the protected file, ignoring the
environment variable. Used to tell whether the token has been migrated to the
protected file yet.

.EXAMPLE
$token = Get-GenXdevMCPToken

.EXAMPLE
Get-GenXdevMCPToken -ProtectedFilePath 'C:\Keys\mcp.clixml'
#>
function Get-GenXdevMCPToken {

    [CmdletBinding()]
    [OutputType([System.String])]
    param(
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Path of the DPAPI protected token file'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ProtectedFilePath = "$env:LOCALAPPDATA\GenXdev\mcp-token.clixml",

        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Only report a token stored in the protected file'
        )]
        [switch] $ProtectedFileOnly
        #######################################################################
    )

    begin {

        Microsoft.PowerShell.Utility\Write-Verbose "Resolving the MCP token from ${ProtectedFilePath}"
    }

    process {

        if ([System.IO.File]::Exists($ProtectedFilePath)) {

            $secureToken = Microsoft.PowerShell.Utility\Import-Clixml -Path $ProtectedFilePath `
                -ErrorAction SilentlyContinue

            if ($null -ne $secureToken) {

                Microsoft.PowerShell.Utility\Write-Verbose 'Using the DPAPI protected token file'

                Microsoft.PowerShell.Utility\Write-Output (
                    Microsoft.PowerShell.Security\ConvertFrom-SecureString `
                        -SecureString $secureToken -AsPlainText)

                return
            }
        }

        if ($ProtectedFileOnly) {
            return
        }

        $environmentToken = [System.Environment]::GetEnvironmentVariable(
            'GENXDEV_MCP_TOKEN', 'User')

        if (-not [string]::IsNullOrEmpty($environmentToken)) {

            Microsoft.PowerShell.Utility\Write-Verbose 'Using the GENXDEV_MCP_TOKEN environment variable'

            Microsoft.PowerShell.Utility\Write-Output $environmentToken
        }
    }

    end {
    }
}

###############################################################################
