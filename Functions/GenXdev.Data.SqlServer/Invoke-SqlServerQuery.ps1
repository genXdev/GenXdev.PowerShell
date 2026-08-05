###############################################################################
<#
.SYNOPSIS
Executes one or more SQL queries against a SQL Server database with transaction support.

.DESCRIPTION
Executes SQL queries against a SQL Server database with parameter support and
configurable transaction isolation. Can use an external transaction for batch
operations or create its own internal transaction. When using an external
transaction, the caller is responsible for committing/rolling back.
Connection priority: Transaction > ConnectionString > DatabaseName (requires Server).

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
The SQL Server connection string for database access. Used if no Transaction is provided.

.PARAMETER DatabaseName
The name of the SQL Server database to connect to. Requires Server parameter.
Used if no Transaction or ConnectionString is provided.

.PARAMETER Server
The SQL Server instance name. Used with DatabaseName to create connection string.

.PARAMETER Transaction
An existing SQL Server transaction to use. When provided, the function will not
commit or rollback the transaction - that's the caller's responsibility.
Takes priority over ConnectionString and DatabaseName/Server.

.PARAMETER Queries
One or more SQL queries to execute. Can be passed via pipeline.

.PARAMETER SqlParameters
Optional parameters for the queries as hashtables. Format: @{"param"="value"}

.PARAMETER IsolationLevel
Transaction isolation level. Defaults to ReadCommitted. Only used when creating
an internal transaction.

.PARAMETER AutoConsent
Force a consent prompt even if a preference is already set for SQL Server package
installation, overriding any saved consent preferences.

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation and set a persistent
preference flag for SQL Server package, bypassing interactive consent prompts.

.EXAMPLE
Invoke-SQLServerQuery -Server "localhost" -DatabaseName "MyDB" -Queries "SELECT * FROM Users"

.EXAMPLE
"SELECT * FROM Users" | Invoke-SQLServerQuery -ConnectionString "Server=localhost;Database=MyDB;Integrated Security=true" -SqlParameters @{"UserId"=1}

.EXAMPLE
Batch operations using external transaction
$tx = Get-SQLServerTransaction -Server "localhost" -DatabaseName "MyDB"
try {
    Invoke-SQLServerQuery -Transaction $tx -Queries "INSERT INTO Users VALUES (@name)" -SqlParameters @{"name"="John"}
    Invoke-SQLServerQuery -Transaction $tx -Queries "UPDATE Users SET active=1 WHERE name=@name" -SqlParameters @{"name"="John"}
    $tx.Commit()
} catch {
    $tx.Rollback()
    throw
} finally {
    $tx.Connection.Close()
}

.EXAMPLE
Invoke-SQLServerQuery -Server "localhost" -DatabaseName "MyDB" -Queries "SELECT * FROM Users" -AutoConsentAllPackages
#>
function Invoke-SQLServerQuery {

    [CmdletBinding()]

    param (
        ###########################################################################
        [Alias("q", "Value", "Name", "Text", "Query")]
        [parameter(
            Position = 0,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'The query or queries to execute.'
        )]
        [string[]]$Queries,

        ###########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The name of the SQL Server database.'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName = 'master',

        ###########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The SQL Server instance name.'
        )]
        [string]$Server = '.',

        ###########################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'An existing SQL Server transaction to use for the queries.'
        )]
        [object]$Transaction,

        ###########################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The connection string to the SQL database.'
        )]
        [string]$ConnectionString,

        ###########################################################################
        [Alias('data', 'parameters', 'args')]
        [parameter(
            Position = 5,
            ValueFromPipeline,
            ValueFromPipelineByPropertyName,
            HelpMessage = 'Query parameters as hashtables.'
        )]
        [System.Collections.Hashtable[]]$SqlParameters = @(),

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The isolation level to use. default is ReadCommitted.'
        )]
        [ValidateSet('ReadCommitted', 'ReadUncommitted', 'RepeatableRead', 'Serializable', 'Snapshot', 'Chaos')]
        [string]$IsolationLevel = "ReadCommitted",

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to this installation type and set persistent flag..'
        )]
        [switch] $AutoConsent,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to ALL third-party software installations and set persistent flag for SQL Server package.'
        )]
        [switch] $AutoConsentAllPackages,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
        ###########################################################################
    )

    begin {
        # load SQL Server client assembly with embedded consent using Copy-IdenticalParamValues
        $ensureParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\EnsureNuGetAssembly' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue
        )

        # Set specific parameters for SQL Server package
        $ensureParams['PackageKey'] = 'System.Data.SqlClient'
        $ensureParams['Description'] = 'SQL Server client library required for database operations'
        $ensureParams['Publisher'] = 'Microsoft'

        GenXdev\EnsureNuGetAssembly @ensureParams
        Microsoft.PowerShell.Utility\Add-Type -AssemblyName System.Data.SqlClient

        # determine connection source priority: Transaction > ConnectionString > DatabaseName+Server
        if ($null -ne $Transaction) {
            $connection = $Transaction.Connection
            $transaction = $Transaction
            $isExternalTransaction = $true
            Microsoft.PowerShell.Utility\Write-Verbose 'Using external transaction'
        }
        elseif (-not [String]::IsNullOrWhiteSpace($ConnectionString)) {
            $connString = $ConnectionString
            $isExternalTransaction = $false
            Microsoft.PowerShell.Utility\Write-Verbose "Will create internal transaction with connection string: $connString"
        }
        elseif (-not [String]::IsNullOrWhiteSpace($DatabaseName)) {
            $connString = "Server=$Server;Database=$DatabaseName;Integrated Security=true;TrustServerCertificate=true"
            $isExternalTransaction = $false
            Microsoft.PowerShell.Utility\Write-Verbose "Will create internal transaction with server: $Server, database: $DatabaseName"
        }
        else {
            throw 'You must provide either a Transaction, ConnectionString, or DatabaseName (with optional Server) parameter.'
        }
    }

    process {
        try {
            # establish database connection and transaction if not using external
            if (-not $isExternalTransaction) {
                $connectionClass = "System.Data.SqlClient.SqlConnection"
                $connection = Microsoft.PowerShell.Utility\New-Object $connectionClass($connString)
                $connection.Open()
                Microsoft.PowerShell.Utility\Write-Verbose "Successfully connected using System.Data.SqlClient"

                # begin transaction with specified isolation
                $transaction = $connection.BeginTransaction($IsolationLevel)
                Microsoft.PowerShell.Utility\Write-Verbose "Started internal transaction with $IsolationLevel isolation"
            }

            # ensure parameters array exists
            $SqlParameters = if ($SqlParameters) { $SqlParameters } else { @() }

            # validate that queries are provided
            if (-not $Queries -or $Queries.Count -eq 0) {
                throw 'You must provide at least one query to execute.'
            }

            try {
                $idx = -1

                # process each query
                $Queries | Microsoft.PowerShell.Core\ForEach-Object {

                    $idx++
                    Microsoft.PowerShell.Utility\Write-Verbose "Executing query $($idx + 1) of $($Queries.Count)"

                    # get parameter set for current query
                    [System.Collections.Hashtable] $data = if ($SqlParameters.Length -gt $idx) {
                        $SqlParameters[[Math]::Min($idx, $SqlParameters.Count - 1)]
                    }
                    else {
                        $null
                    }

                    # prepare command
                    $command = $connection.CreateCommand()
                    $command.CommandText = $PSItem
                    $command.Transaction = $transaction

                    # add parameters if provided
                    if ($null -ne $data) {
                        $data.GetEnumerator() | Microsoft.PowerShell.Core\ForEach-Object {
                            $value = if ($null -eq $PSItem.Value) {
                                [DBNull]::Value
                            }
                            else {
                                $PSItem.Value
                            }

                            $null = $command.Parameters.AddWithValue(
                                '@' + $PSItem.Key,
                                $value
                            )
                        }
                    }

                    # execute and read results
                    $reader = $command.ExecuteReader()

                    while ($reader.Read()) {
                        $record = @{}
                        for ($i = 0; $i -lt $reader.FieldCount; $i++) {
                            $name = $reader.GetName($i)
                            $value = $reader.GetValue($i)
                            $record[$name] = $value
                        }
                        Microsoft.PowerShell.Utility\Write-Output $record
                    }

                    $reader.Close()
                }

                # only commit if we created the transaction internally
                if (-not $isExternalTransaction) {
                    $transaction.Commit()
                    Microsoft.PowerShell.Utility\Write-Verbose 'Internal transaction committed successfully'
                }
            }
            catch {
                # only rollback if we created the transaction internally
                if (-not $isExternalTransaction) {
                    $transaction.Rollback()
                    Microsoft.PowerShell.Utility\Write-Verbose 'Internal transaction rolled back due to error'
                }
                throw $_
            }
            finally {
                if ($null -ne $reader) { $reader.Close(); $reader = $null; }

                # only close connection if we created it internally
                if (-not $isExternalTransaction) {
                    $connection.Close()
                    Microsoft.PowerShell.Utility\Write-Verbose 'Internal connection closed'
                }
            }
        }
        catch {
            throw $_
        }
    }

    end {
    }
}