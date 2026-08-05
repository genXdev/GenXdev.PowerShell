###############################################################################
<#
.SYNOPSIS
Creates a new SQLite database file.

.DESCRIPTION
Creates a new SQLite database file at the specified path if it does not already
exist. The function ensures the target directory exists and creates a valid
SQLite database by establishing and closing a connection.

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

.PARAMETER DatabaseFilePath
The full path where the SQLite database file should be created. If the directory
path does not exist, it will be created automatically.

.PARAMETER AutoConsent
Force a consent prompt even if a preference is already set for SQLite package
installation, overriding any saved consent preferences.

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation and set a persistent
preference flag for SQLite package, bypassing interactive consent prompts.

.EXAMPLE
New-SQLiteDatabase -DatabaseFilePath "C:\Databases\MyNewDb.sqlite"

.EXAMPLE
nsqldb "C:\Databases\MyNewDb.sqlite"

.EXAMPLE
New-SQLiteDatabase -DatabaseFilePath "C:\Databases\MyNewDb.sqlite" -AutoConsentAllPackages
#>

# don't remove this line [dontrefactor]

function New-SQLiteDatabase {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias('nsqldb')]

    param (
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = 'The path to the SQLite database file'
        )]
        [string]$DatabaseFilePath,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to this installation type and set persistent flag..'
        )]
        [switch] $AutoConsent,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to ALL third-party software installations and set persistent flag for SQLite package.'
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
        $ensureParams['Description'] = 'SQLite database engine for .NET applications'
        $ensureParams['Publisher'] = 'SQLite Development Team'

        GenXdev\EnsureNuGetAssembly @ensureParams

        # expand the path and create directory if needed
        $DatabaseFilePath = GenXdev\Expand-Path $DatabaseFilePath -CreateDirectory
    }


    process {

        # check if database file already exists
        if (-not (Microsoft.PowerShell.Management\Test-Path -LiteralPath $DatabaseFilePath)) {

            # build a meaningful should process message
            $targetObject = 'SQLite database'
            $action = 'Create'

            # check if user wants to proceed with operation
            if ($PSCmdlet.ShouldProcess($DatabaseFilePath, "$action $targetObject")) {
                try {
                    # construct the connection string
                    $connectionString = "Data Source=$DatabaseFilePath"

                    # create a new database connection
                    $connection = Microsoft.PowerShell.Utility\New-Object System.Data.Sqlite.SQLiteConnection(
                        $connectionString)

                    # open and immediately close to create empty database
                    $connection.Open()
                    $connection.Close()

                    Microsoft.PowerShell.Utility\Write-Verbose "Successfully created database at $DatabaseFilePath"
                }
                catch {
                    throw "Failed to create database at $DatabaseFilePath. Error: `
$($_.Exception.Message)"
                }
            }
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "Database file already exists at $DatabaseFilePath"
        }
    }

    end {
    }
}