###############################################################################
<#
.SYNOPSIS
Retrieves the schema information for a specified SQL Server table.

.DESCRIPTION
This function queries the SQL Server database to get detailed schema information for
a specified table. It uses the SQL Server INFORMATION_SCHEMA.COLUMNS view to return
column definitions including names, types, nullable status, and default values.

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
Specifies the SQL Server connection string in the format:
"Server=servername;Database=databasename;Integrated Security=true"

.PARAMETER DatabaseName
Specifies the name of the SQL Server database.

.PARAMETER Server
Specifies the SQL Server instance name. Defaults to 'localhost'.

.PARAMETER TableName
Specifies the name of the table for which to retrieve schema information.

.EXAMPLE
Get-SQLServerTableSchema -DatabaseName "mydb" -Server "localhost" `
    -TableName "Users"

.EXAMPLE
Get-SQLServerTableSchema -ConnectionString "Server=localhost;Database=mydb;Integrated Security=true" `
    -TableName "Products"
#>
function Get-SQLServerTableSchema {

    [CmdletBinding(DefaultParameterSetName = 'DatabaseName')]
    param (
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'ConnectionString',
            HelpMessage = 'The connection string to the SQL Server database'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ConnectionString,

        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'The name of the SQL Server database'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName,

        ###########################################################################
        [Parameter(
            Position = 1,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'The SQL Server instance name'
        )]
        [string]$Server = '.',

        ###########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $true,
            HelpMessage = 'The name of the table'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$TableName
    )

    begin {

        # log the start of schema retrieval operation
        Microsoft.PowerShell.Utility\Write-Verbose "Preparing to retrieve schema for table '$TableName'"
    }


    process {

        # construct the INFORMATION_SCHEMA query to get detailed table column information
        $PSBoundParameters['Queries'] = @"
SELECT
    COLUMN_NAME,
    DATA_TYPE,
    IS_NULLABLE,
    COLUMN_DEFAULT,
    CHARACTER_MAXIMUM_LENGTH,
    NUMERIC_PRECISION,
    NUMERIC_SCALE,
    ORDINAL_POSITION
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = '$TableName'
ORDER BY ORDINAL_POSITION
"@

        # log the execution of the schema query
        Microsoft.PowerShell.Utility\Write-Verbose 'Executing schema query against SQL Server database'

        # execute the query and return results using existing Invoke-SQLServerQuery
        GenXdev\Invoke-SQLServerQuery @PSBoundParameters
    }

    end {
    }
}