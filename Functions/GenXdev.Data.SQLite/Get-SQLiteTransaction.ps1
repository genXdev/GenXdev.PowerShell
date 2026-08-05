# don't remove this line [dontrefactor]

###############################################################################
<#
.SYNOPSIS
Creates and returns a SQLite transaction object for batch operations.

.DESCRIPTION
Creates a SQLite database connection and transaction object that can be used
for batch operations. The caller is responsible for committing or rolling back
the transaction. The connection will be automatically created if the database
file doesn't exist.

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
The SQLite connection string for database access.

.PARAMETER DatabaseFilePath
The file path to the SQLite database. Will be converted to a connection string.

.PARAMETER IsolationLevel
Transaction isolation level. Defaults to ReadCommitted.

.PARAMETER CreateDatabaseIfNotExists
Whether to create the database file if it doesn't exist. Defaults to true.

.PARAMETER AutoConsent
Force a consent prompt even if a preference is already set for SQLite package
installation, overriding any saved consent preferences.

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation and set a persistent
preference flag for SQLite package, bypassing interactive consent prompts.

.EXAMPLE
$transaction = Get-SQLiteTransaction -DatabaseFilePath "C:\data.db"
try {
    Invoke-SQLiteQuery -Transaction $transaction -Queries "INSERT INTO Users..."
    Invoke-SQLiteQuery -Transaction $transaction -Queries "UPDATE Users..."
    $transaction.Commit()
} catch {
    $transaction.Rollback()
    throw
} finally {
    $transaction.Connection.Close()
}

.EXAMPLE
$transaction = Get-SQLiteTransaction -ConnectionString "Data Source=C:\data.db"

.EXAMPLE
$transaction = Get-SQLiteTransaction -DatabaseFilePath "C:\data.db" -AutoConsentAllPackages
#>
function Get-SQLiteTransaction {

    [CmdletBinding(DefaultParameterSetName = 'DatabaseFilePath')]
    [Alias('getsqltx', 'newsqltx')]
    param (
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory,
            ParameterSetName = 'ConnectionString',
            HelpMessage = 'The connection string to the SQLite database.'
        )]
        [string]$ConnectionString,

        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory,
            ParameterSetName = 'DatabaseFilePath',
            HelpMessage = 'The path to the SQLite database file.'
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('dbpath', 'indexpath')]
        [string]$DatabaseFilePath,

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Transaction isolation level.'
        )]
        [ValidateSet('ReadCommitted', 'ReadUncommitted', 'RepeatableRead', 'Serializable', 'Snapshot', 'Chaos')]
        [string]$IsolationLevel = "ReadCommitted",

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Whether to create the database file if it does not exist.'
        )]
        [bool]$CreateDatabaseIfNotExists = $true,

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to this installation type and set persistent flag..'
        )]
        [switch] $AutoConsent,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to ALL third-party software installations and set persistent flag for SQLite package.'
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
        # load SQLite client assembly with embedded consent using Copy-IdenticalParamValues
        $ensureParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\EnsureNuGetAssembly' `
            -DefaultValues (
            Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue
        )

        # Set specific parameters for SQLite package
        $ensureParams['PackageKey'] = 'System.Data.Sqlite'
        $ensureParams['Description'] = 'SQLite database client library required for database operations'
        $ensureParams['Publisher'] = 'SQLite Development Team'

        GenXdev\EnsureNuGetAssembly @ensureParams

        # initialize connection string from file path if provided
        if ($PSCmdlet.ParameterSetName -eq 'DatabaseFilePath') {
            $expandedPath = GenXdev\Expand-Path $DatabaseFilePath
            # create database if it doesn't exist and CreateDatabaseIfNotExists is true
            if ($CreateDatabaseIfNotExists -and -not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $expandedPath)) {
                Microsoft.PowerShell.Utility\Write-Verbose "Creating database file: $expandedPath"

                # use Copy-IdenticalParamValues to pass compatible parameters to New-SQLiteDatabase
                $params = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName 'GenXdev\New-SQLiteDatabase' `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

                GenXdev\New-SQLiteDatabase @params
            }

            $connString = "Data Source=$expandedPath"
        }
        else {
            $connString = $ConnectionString
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Creating SQLite transaction with connection string: $connString"
    }

    process {
        try {
            # establish database connection
            $connection = Microsoft.PowerShell.Utility\New-Object System.Data.SQLite.SQLiteConnection($connString)
            $connection.Open()
            Microsoft.PowerShell.Utility\Write-Verbose 'SQLite connection opened successfully'

            # begin transaction with specified isolation
            $transaction = $connection.BeginTransaction($IsolationLevel)
            Microsoft.PowerShell.Utility\Write-Verbose "Transaction started with $IsolationLevel isolation level"

            # return the transaction object
            return $transaction
        }
        catch {
            if ($null -ne $connection -and $connection.State -eq 'Open') {
                $connection.Close()
            }
            throw $_
        }
    }

    end {
    }
}