###############################################################################
<#
.SYNOPSIS
Retrieves a list of table names from a SQL Server database.

.DESCRIPTION
Queries the SQL Server system tables to retrieve all user-defined table names
from a SQL Server database. Supports connecting via either a direct connection
string or a database name with server parameters. Returns the table names as a
collection of strings.

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
The full connection string to connect to the SQL Server database. Should include
the Server and Database parameters at minimum.

.PARAMETER DatabaseName
The name of the SQL Server database.

.PARAMETER Server
The SQL Server instance name. Defaults to 'localhost'.

.EXAMPLE
Get-SQLServerTables -DatabaseName "Inventory" -Server "localhost"
Returns all table names from the specified database

.EXAMPLE
Get-SQLServerTables -ConnectionString "Server=localhost;Database=Users;Integrated Security=true;"
Returns all table names using a custom connection string

#>

function Get-SQLServerTables {
    [System.Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]
    [CmdletBinding(DefaultParameterSetName = 'DatabaseName')]
    param (
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'ConnectionString',
            HelpMessage = 'The connection string to the SQL Server database.'
        )]
        [string]$ConnectionString,

        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'The name of the SQL Server database.'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName,

        ###########################################################################
        [Parameter(
            Position = 1,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'The SQL Server instance name.'
        )]
        [string]$Server = '.'
    )

    begin {

        # log the start of table retrieval operation
        Microsoft.PowerShell.Utility\Write-Verbose 'Starting SQL table name retrieval operation'
    }


    process {

        # define the query to get all table names from SQL Server system tables
        $PSBoundParameters['Queries'] = 'SELECT name FROM sys.tables ORDER BY name'

        # execute query using the inherited connection parameters
        Microsoft.PowerShell.Utility\Write-Verbose 'Executing query to retrieve table names'
        GenXdev\Invoke-SQLServerQuery @PSBoundParameters
    }

    end {
    }
}