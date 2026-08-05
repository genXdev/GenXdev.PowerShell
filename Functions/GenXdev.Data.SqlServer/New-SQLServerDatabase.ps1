# don't remove this line [dontrefactor]

###############################################################################
<#
.SYNOPSIS
Creates a new SQL Server database.

.DESCRIPTION
Creates a new SQL Server database with the specified name on the specified
server. Requires appropriate permissions to create databases on the target SQL
Server instance. If the database already exists, the operation will be skipped.
Supports file-based database creation with explicit .mdf/.ldf paths.

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

.PARAMETER DatabaseName
The name of the SQL Server database to create. Must be a valid SQL Server
database name.

.PARAMETER Server
The SQL Server instance name where the database should be created. Defaults to
'.' (local instance).

.PARAMETER ConnectionString
Alternative connection string to use instead of Server parameter. Should
connect to master database or have appropriate permissions.

.PARAMETER DataFilePath
Optional path for the database data file (.mdf). When specified, creates a
file-based database at this location instead of using default SQL Server paths.

.PARAMETER LogFilePath
Optional path for the database log file (.ldf). If not specified but
DataFilePath is provided, defaults to same directory with _log.ldf suffix.

.PARAMETER DetachAfterCreation
Detach the database after creation. Typically used with DataFilePath to create
a portable database file that can be attached via connection string.

.PARAMETER AutoConsent
Force a consent prompt even if a preference is already set for SQL Server
package installation, overriding any saved consent preferences.

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation and set a persistent
preference flag for SQL Server package, bypassing interactive consent prompts.

.EXAMPLE
New-SQLServerDatabase -DatabaseName "MyNewDatabase" -Server "localhost"

.EXAMPLE
New-SQLServerDatabase "MyNewDatabase"

.EXAMPLE
New-SQLServerDatabase -DatabaseName "MyDB" -ConnectionString "Server=.;..."

.EXAMPLE
New-SQLServerDatabase -DatabaseName "ImageIndex" -DataFilePath "C:\Data\ImageIndex.mdf" -DetachAfterCreation

.EXAMPLE
New-SQLServerDatabase -DatabaseName "MyDB" -Server "." -AutoConsentAllPackages
#>
function New-SQLServerDatabase {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias('nsqldb')]

    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'The name of the SQL Server database to create'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName,
        ########################################################################
        [Parameter(
            Position = 1,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'The SQL Server instance name'
        )]
        [string]$Server = '.',
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ParameterSetName = 'ConnectionString',
            HelpMessage = 'The connection string to connect to SQL Server'
        )]
        [string]$ConnectionString,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'Optional data file path (.mdf) for file-based database creation.'
        )]
        [string]$DataFilePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'Optional log file path (.ldf) for file-based database creation.'
        )]
        [string]$LogFilePath,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            ParameterSetName = 'DatabaseName',
            HelpMessage = 'Detach database after creation (for file-based databases).'
        )]
        [switch]$DetachAfterCreation,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to this installation type and set persistent flag..')
        )]
        [switch] $AutoConsent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for SQL Server package.')
        )]
        [switch] $AutoConsentAllPackages,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
        ########################################################################
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


        # prepare connection string
        if ($PSCmdlet.ParameterSetName -eq 'DatabaseName') {
            $masterConnectionString = "Server=$Server;Database=master;Integrated Security=true;TrustServerCertificate=true"
        }
        else {
            $masterConnectionString = $ConnectionString
        }
    }

    process {

        # build a meaningful should process message
        $targetObject = 'SQL Server database'
        $action = 'Create'
        $target = if ($PSCmdlet.ParameterSetName -eq 'DatabaseName') { "$DatabaseName on $Server" } else { "database via connection string" }

        # check if user wants to proceed with operation
        if ($PSCmdlet.ShouldProcess($target, "$action $targetObject")) {
            try {
                # create connection to master database to check if target database exists
                $connectionClass = "System.Data.SqlClient.SqlConnection"
                $connection = Microsoft.PowerShell.Utility\New-Object $connectionClass($masterConnectionString)
                $connection.Open()

                # check if database already exists
                $checkQuery = if ($PSCmdlet.ParameterSetName -eq 'DatabaseName') {
                    "SELECT database_id FROM sys.databases WHERE name = @DatabaseName"
                }
                else {
                    # For connection string mode, we'll try to connect directly and see if it fails
                    $null
                }

                if ($checkQuery) {
                    $checkCommand = $connection.CreateCommand()
                    $checkCommand.CommandText = $checkQuery
                    $checkCommand.Parameters.AddWithValue("@DatabaseName", $DatabaseName)
                    $existingDb = $checkCommand.ExecuteScalar()

                    if ($null -eq $existingDb) {
                        # Build CREATE DATABASE statement
                        if ($DataFilePath) {
                            # File-based database with explicit paths
                            $dbName = $DatabaseName -replace '-', '_' -replace ' ', '_'
                            $logPath = if ($LogFilePath) { $LogFilePath } else { $DataFilePath -replace '\.mdf$', '_log.ldf' }

                            # Ensure parent directories exist
                            $dataDir = [System.IO.Path]::GetDirectoryName($DataFilePath)
                            if (-not [System.IO.Directory]::Exists($dataDir)) {
                                [System.IO.Directory]::CreateDirectory($dataDir) | Microsoft.PowerShell.Utility\Out-Null
                            }

                            $logDir = [System.IO.Path]::GetDirectoryName($logPath)
                            if (-not [System.IO.Directory]::Exists($logDir)) {
                                [System.IO.Directory]::CreateDirectory($logDir) | Microsoft.PowerShell.Utility\Out-Null
                            }

                            $createQuery = @"
CREATE DATABASE [$DatabaseName]
ON PRIMARY (
    NAME = N'${dbName}',
    FILENAME = N'${DataFilePath}',
    SIZE = 8MB,
    FILEGROWTH = 64MB
)
LOG ON (
    NAME = N'${dbName}_log',
    FILENAME = N'${logPath}',
    SIZE = 8MB,
    FILEGROWTH = 64MB
)
"@
                        }
                        else {
                            # Standard database with default file locations
                            $createQuery = "CREATE DATABASE [$DatabaseName]"
                        }

                        $createCommand = $connection.CreateCommand()
                        $createCommand.CommandText = $createQuery
                        $createCommand.ExecuteNonQuery()

                        Microsoft.PowerShell.Utility\Write-Verbose "Successfully created database '$DatabaseName' on server '$Server'"

                        # Set recovery model to SIMPLE to avoid excessive log file growth
                        $recoveryCommand = $connection.CreateCommand()
                        $recoveryCommand.CommandText = "ALTER DATABASE [$DatabaseName] SET RECOVERY SIMPLE"
                        $recoveryCommand.ExecuteNonQuery()
                        Microsoft.PowerShell.Utility\Write-Verbose "Set recovery model to SIMPLE for database '$DatabaseName'"

                        # Detach if requested (typically for file-based databases)
                        if ($DetachAfterCreation) {
                            $detachCommand = $connection.CreateCommand()
                            $detachCommand.CommandText = "EXEC sp_detach_db @dbname = N'$DatabaseName'"
                            $detachCommand.ExecuteNonQuery()
                            Microsoft.PowerShell.Utility\Write-Verbose "Detached database '$DatabaseName' from server '$Server'"
                        }
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Verbose "Database '$DatabaseName' already exists on server '$Server'"
                    }
                }

                $connection.Close()
            }
            catch {
                if ($null -ne $connection -and $connection.State -eq 'Open') {
                    $connection.Close()
                }
                throw "Failed to create database. Error: $($_.Exception.Message)"
            }
        }
    }

    end {
    }
}