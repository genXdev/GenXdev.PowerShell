###############################################################################
<#
.SYNOPSIS
Retrieves the schema information for a specified SQLite table.

.DESCRIPTION
This function queries the SQLite database to get detailed schema information for
a specified table. It uses the SQLite PRAGMA table_info command to return column
definitions including names, types, nullable status, and default values.

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
Specifies the SQLite connection string in the format:
"Data Source=path_to_database_file"

.PARAMETER DatabaseFilePath
Specifies the direct file path to the SQLite database file. This is converted
internally to a connection string.

.PARAMETER TableName
Specifies the name of the table for which to retrieve schema information.

.EXAMPLE
Get-SQLiteTableSchema -DatabaseFilePath "C:\Databases\mydb.sqlite" `
    -TableName "Users"

.EXAMPLE
Get-SQLiteTableSchema -ConnectionString "Data Source=C:\Databases\mydb.sqlite" `
    -TableName "Products"
#>
function Get-SQLiteTableSchema {

    [CmdletBinding(DefaultParameterSetName = 'Default')]
    param (
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'ConnectionString',
            HelpMessage = 'The connection string to the SQLite database'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$ConnectionString,

        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            ParameterSetName = 'DatabaseFilePath',
            HelpMessage = 'The path to the SQLite database file'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('dbpath', 'indexpath')]
        [string]$DatabaseFilePath,

        ###########################################################################
        [Parameter(
            Position = 1,
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

        # construct the PRAGMA query to get detailed table column information
        $PSBoundParameters['Queries'] = "PRAGMA table_info($TableName)"

        # log the execution of the schema query
        Microsoft.PowerShell.Utility\Write-Verbose 'Executing schema query against SQLite database'

        # execute the query and return results using existing Invoke-SQLiteQuery
        GenXdev\Invoke-SQLiteQuery @PSBoundParameters
    }

    end {
    }
}