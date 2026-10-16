###############################################################################
<#
.SYNOPSIS
Opens a SQL Server connection that the caller owns.

.DESCRIPTION
Opens a SQL Server connection and returns it, leaving the caller responsible for
closing it. No transaction is started, so the connection runs in autocommit mode
and keeps one session across every command executed on it. Hand it to
Invoke-SQLServerQuery or Invoke-SQLServerScriptFile with -Connection to keep
session state such as USE, temp tables and SET options alive across calls.

Connection priority: ConnectionString > DatabaseName (requires Server).

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

.PARAMETER ConnectionString
The SQL Server connection string for database access.

.PARAMETER DatabaseName
The name of the SQL Server database to connect to. Requires Server parameter.

.PARAMETER Server
The SQL Server instance name. Used with DatabaseName to create connection string.

.PARAMETER AutoConsent
Force a consent prompt even if a preference is already set for SQL Server package
installation, overriding any saved consent preferences.

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation and set a persistent
preference flag for SQL Server package, bypassing interactive consent prompts.

.PARAMETER SessionOnly
Use alternative settings stored in session for preferences.

.EXAMPLE
$connection = Get-SQLServerConnection -Server "localhost" -DatabaseName "MyDB"
try {
    Invoke-SQLServerQuery -Connection $connection -Queries "SELECT * FROM Users"
}
finally {
    $connection.Close()
}

.EXAMPLE
Get-SQLServerConnection -ConnectionString "Server=localhost;Database=MyDB;Integrated Security=true"
#>
function Get-SQLServerConnection {

    [CmdletBinding()]
    [Alias('getsqlconnection', 'newsqlconnection')]

    param (
        ###############################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The name of the SQL Server database.'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName = 'master',

        ###############################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The SQL Server instance name.'
        )]
        [string]$Server = '.',

        ###############################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The connection string to the SQL database.'
        )]
        [string]$ConnectionString,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force a consent prompt even if a preference is already set.'
        )]
        [switch]$AutoConsent,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to ALL third-party software installations and set persistent flag for SQL Server package.'
        )]
        [switch]$AutoConsentAllPackages,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use alternative settings stored in session for preferences'
        )]
        [switch]$SessionOnly
        ###############################################################################
    )

    begin {

        # load SQL Server client assembly with embedded consent
        $ensureParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\EnsureNuGetAssembly' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue)

        $ensureParams['PackageKey'] = 'System.Data.SqlClient'
        $ensureParams['Description'] = 'SQL Server client library required for database operations'
        $ensureParams['Publisher'] = 'Microsoft'

        GenXdev\EnsureNuGetAssembly @ensureParams
        Microsoft.PowerShell.Utility\Add-Type -AssemblyName System.Data.SqlClient

        # determine connection string from ConnectionString or DatabaseName+Server
        $connString = if ([String]::IsNullOrWhiteSpace($ConnectionString)) {
            "Server=$Server;Database=$DatabaseName;Integrated Security=true;TrustServerCertificate=true"
        }
        else {
            $ConnectionString
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Will open connection with connection string: $connString"
    }

    process {

        $connectionClass = 'System.Data.SqlClient.SqlConnection'
        $connection = Microsoft.PowerShell.Utility\New-Object $connectionClass($connString)
        $connection.Open()

        Microsoft.PowerShell.Utility\Write-Verbose 'SQL Server connection opened, the caller owns it'

        $connection
    }

    end {
    }
}

###############################################################################
