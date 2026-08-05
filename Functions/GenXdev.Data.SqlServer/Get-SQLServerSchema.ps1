###############################################################################
<#
.SYNOPSIS
Retrieves the complete schema information from a SQL Server database.

.DESCRIPTION
This function queries SQL Server system tables and information schema to obtain
the complete schema definition of a SQL Server database, including tables, views,
indexes, stored procedures and other database objects. It accepts either a
connection string or database name with server parameters.

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
The SQL Server connection string that specifies the database location and any
additional connection parameters.

.PARAMETER DatabaseName
The name of the SQL Server database.

.PARAMETER Server
The SQL Server instance name. Defaults to 'localhost'.

.EXAMPLE
Get-SQLServerSchema -DatabaseName "inventory" -Server "localhost"

.EXAMPLE
Get-SQLServerSchema -ConnectionString "Server=localhost;Database=inventory;Integrated Security=true;"
#>
function Get-SQLServerSchema {

    [CmdletBinding(DefaultParameterSetName = 'DatabaseName')]

    param (
        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'ConnectionString',
            HelpMessage = 'The connection string to the SQL Server database.'
        )]
        [string]$ConnectionString,

        ########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'The name of the SQL Server database.'
        )]
        [string]$DatabaseName,

        ########################################################################
        [Parameter(
            Position = 1,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'The SQL Server instance name.'
        )]
        [string]$Server = 'localhost'
    )

    begin {

        # output verbose information about the selected parameter set
        Microsoft.PowerShell.Utility\Write-Verbose "Using parameter set: $($PSCmdlet.ParameterSetName)"
    }


    process {

        # prepare comprehensive schema queries for SQL Server
        $schemaQueries = @(
            "SELECT 'TABLE' as object_type, name, schema_id, object_id FROM sys.tables ORDER BY name",
            "SELECT 'VIEW' as object_type, name, schema_id, object_id FROM sys.views ORDER BY name",
            "SELECT 'PROCEDURE' as object_type, name, schema_id, object_id FROM sys.procedures ORDER BY name",
            "SELECT 'FUNCTION' as object_type, name, schema_id, object_id FROM sys.objects WHERE type IN ('FN','IF','TF') ORDER BY name"
        )

        $PSBoundParameters['Queries'] = $schemaQueries

        # execute the schema queries using the existing Invoke-SQLServerQuery function
        GenXdev\Invoke-SQLServerQuery @PSBoundParameters
    }

    end {
    }
}