###############################################################################
<#
.SYNOPSIS
Executes SQL script files against a SQL Server database, batch by batch.

.DESCRIPTION
Reads one or more SQL script files and executes them in order, splitting every
file into batches on the GO batch separator, the same way SQL Server Management
Studio does. A GO line always terminates the current batch, and repeats it with
an optional repeat count, as in 'GO 5'.

Every batch of a file is executed by Invoke-SQLServerQuery on one shared
connection that this cmdlet opens itself, so session state survives a GO exactly
as it does in SQL Server Management Studio: USE, temp tables and SET options stay
in effect for the rest of the file. Batches run in autocommit mode, unless a
Transaction is provided by the caller.

Failures are reported through the effective error action: an explicitly bound
-ErrorAction wins, otherwise $ErrorActionPreference decides. When the effective
action is not Stop, the failing batch is reported and the next batch is
executed.

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

.PARAMETER Name
One or more SQL script files to execute, in the order given. Relative paths are
resolved against the current directory, and a search mask such as *.sql is
expanded against the file system.

.PARAMETER InputObject
SQL script files accepted from the pipeline, as file names or as FileInfo
objects. This parameter set is mutually exclusive with Name.

.PARAMETER DatabaseName
The name of the SQL Server database to connect to. Requires Server parameter.
Used if no Transaction or ConnectionString is provided.

.PARAMETER Server
The SQL Server instance name. Used with DatabaseName to create connection string.

.PARAMETER Transaction
An existing SQL Server transaction to use. When provided, the function will not
commit or rollback the transaction - that's the caller's responsibility.
Takes priority over Connection, ConnectionString and DatabaseName/Server.

.PARAMETER Connection
An existing open SqlConnection to execute every batch on. The caller owns the
connection, so it is never closed here. Takes priority over ConnectionString and
DatabaseName/Server.

.PARAMETER ConnectionString
The SQL Server connection string for database access. Used if no Transaction is
provided.

.PARAMETER SqlParameters
Optional parameters for the queries as hashtables. Format: @{"param"="value"}
Every batch is executed as its own query, so the first parameter set applies to
every batch.

.PARAMETER IsolationLevel
Transaction isolation level. Defaults to ReadCommitted. Only used when creating
an internal transaction.

.PARAMETER AutoConsent
Force a consent prompt even if a preference is already set for SQL Server package
installation, overriding any saved consent preferences.

.PARAMETER AutoConsentAllPackages
Automatically consent to third-party software installation and set a persistent
preference flag for SQL Server package, bypassing interactive consent prompts.

.PARAMETER SessionOnly
Use alternative settings stored in session for preferences.

.EXAMPLE
Invoke-SQLServerScriptFile -Name '.\deploy.sql' -Server 'localhost' -DatabaseName 'MyDB'

.EXAMPLE
Get-ChildItem -Path '.\migrations' -Filter '*.sql' |
    Invoke-SQLServerScriptFile -DatabaseName 'MyDB' -ErrorAction Continue
#>
function Invoke-SQLServerScriptFile {

    [CmdletBinding(DefaultParameterSetName = 'ByName')]

    param (
        ###########################################################################
        [Alias('like', 'Path', 'LiteralPath', 'SearchMask', 'Include')]
        [parameter(
            ParameterSetName = 'ByName',
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'One or more SQL script files to execute'
        )]
        [ValidateNotNullOrEmpty()]
        [SupportsWildcards()]
        [string[]]$Name,

        ###########################################################################
        [parameter(
            ParameterSetName = 'ByPipeline',
            Mandatory = $false,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'SQL script files to execute, as names or FileInfo objects'
        )]
        [Alias('FullName', 'Input')]
        [SupportsWildcards()]
        [object]$InputObject,

        ###########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The name of the SQL Server database.'
        )]
        [ValidateNotNullOrEmpty()]
        [string]$DatabaseName = 'tempDb',

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
            HelpMessage = 'An existing SQL Server transaction to use for the batches.'
        )]
        [object]$Transaction,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'An existing open SqlConnection to execute all batches on.'
        )]
        [object]$Connection,

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
            Mandatory = $false,
            HelpMessage = 'Query parameters as hashtables.'
        )]
        [System.Collections.Hashtable[]]$SqlParameters = @(),

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The isolation level to use. default is ReadCommitted.'
        )]
        [ValidateSet('ReadCommitted', 'ReadUncommitted', 'RepeatableRead', 'Serializable', 'Snapshot', 'Chaos')]
        [string]$IsolationLevel = 'ReadCommitted',

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to this installation type and set persistent flag..'
        )]
        [switch]$AutoConsent,

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Automatically consent to ALL third-party software installations and set persistent flag for SQL Server package.'
        )]
        [switch]$AutoConsentAllPackages,

        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use alternative settings stored in session for preferences'
        )]
        [switch]$SessionOnly
        ###########################################################################
    )

    begin {

        # an explicitly bound -ErrorAction overrides $ErrorActionPreference
        $effectiveErrorAction = if ($PSBoundParameters.ContainsKey('ErrorAction')) {
            [System.Management.Automation.ActionPreference] "$($PSBoundParameters['ErrorAction'])"
        }
        else {
            [System.Management.Automation.ActionPreference] "$ErrorActionPreference"
        }

        # script files to execute, in the exact order they were provided
        $scriptFilePaths = [System.Collections.Generic.List[string]]::new()

        # whether the caller provided any input at all
        $receivedInput = $false

        # GO on its own line separates batches, an optional count repeats one
        $batchSeparator = [System.Text.RegularExpressions.Regex]::new(
            '^GO(?:\s+(?<count>\d+))?$',
            [System.Text.RegularExpressions.RegexOptions]::IgnoreCase)

        # connection parameters for the Invoke-SQLServerQuery calls
        $queryParameters = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Invoke-SQLServerQuery' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue)

        # connection parameters for the connection this cmdlet opens itself
        $connectionParameters = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-SQLServerConnection' `
            -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local `
                -ErrorAction SilentlyContinue)

        # report a failure through the effective error action policy
        function writeScriptFailure {
            param(
                [string] $Message,
                [object] $TargetObject,
                [System.Exception] $InnerException = $null
            )

            $exception = if ($null -eq $InnerException) {
                [System.InvalidOperationException]::new($Message)
            }
            else {
                [System.InvalidOperationException]::new($Message, $InnerException)
            }

            $errorRecord = [System.Management.Automation.ErrorRecord]::new(
                $exception,
                'InvokeSQLServerScriptFileError',
                [System.Management.Automation.ErrorCategory]::InvalidOperation,
                $TargetObject
            )

            if ($effectiveErrorAction -eq 'Stop') {
                $PSCmdlet.ThrowTerminatingError($errorRecord)
            }

            Microsoft.PowerShell.Utility\Write-Error -ErrorRecord $errorRecord -ErrorAction $effectiveErrorAction
        }

        # append the script file a single input value refers to
        function addScriptFilePaths {
            param([object] $Value)

            if ($null -eq $Value) {
                return
            }

            if ($Value -is [System.IO.FileInfo]) {

                if ([System.IO.File]::Exists($Value.FullName) -eq $false) {
                    writeScriptFailure (
                        "Cannot find script file '$($Value.FullName)'.") $Value
                    return
                }

                $scriptFilePaths.Add($Value.FullName)
                return
            }

            if ($Value -isnot [string]) {
                writeScriptFailure ('Script file input must be a file name or ' +
                    "a FileInfo object, not $($Value.GetType().FullName).") $Value
                return
            }

            if ([string]::IsNullOrWhiteSpace($Value)) {
                return
            }

            $resolvedPath = GenXdev\Expand-Path $Value

            # expand a search mask against the file system
            if ($resolvedPath.IndexOfAny('*?'.ToCharArray()) -ge 0) {

                $matchedFiles = @(Microsoft.PowerShell.Management\Get-ChildItem -Path $resolvedPath -File `
                        -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\Sort-Object -Property Name)

                if ($matchedFiles.Count -eq 0) {
                    writeScriptFailure "No script files match '$Value'." $Value
                    return
                }

                foreach ($matchedFile in $matchedFiles) {
                    $scriptFilePaths.Add($matchedFile.FullName)
                }

                return
            }

            if ([System.IO.File]::Exists($resolvedPath)) {
                $scriptFilePaths.Add($resolvedPath)
                return
            }

            if ([System.IO.Directory]::Exists($resolvedPath)) {
                writeScriptFailure ("Cannot execute '$Value': it is a " +
                    'directory, not a script file.') $Value
                return
            }

            writeScriptFailure "Cannot find script file '$Value'." $Value
        }

        # execute every batch of one script file in order
        function invokeScriptFile {
            param([string] $ScriptFilePath)

            $batchLines = [System.Collections.Generic.List[string]]::new()
            $batchNumber = 0

            # a trailing flush terminates a batch the file left open
            try {
                $scriptLines = @(Microsoft.PowerShell.Management\Get-Content -LiteralPath $ScriptFilePath `
                        -ErrorAction Stop) + 'GO'
            }
            catch {
                $failureMessage = "Cannot read script file '$ScriptFilePath': " +
                    "$($PSItem.Exception.Message)"

                writeScriptFailure -Message $failureMessage `
                    -TargetObject $ScriptFilePath -InnerException $PSItem.Exception

                return
            }

            foreach ($line in $scriptLines) {

                $separator = $batchSeparator.Match("$line".Trim())

                if ($separator.Success -eq $false) {
                    $batchLines.Add("$line")
                    continue
                }

                $repeatCount = if ($separator.Groups['count'].Success) {
                    [int] $separator.Groups['count'].Value
                }
                else {
                    1
                }

                $batchText = $batchLines -join [Environment]::NewLine
                $batchLines.Clear()

                if ([string]::IsNullOrWhiteSpace($batchText)) {
                    continue
                }

                for ($repeat = 1; $repeat -le $repeatCount; $repeat++) {

                    $batchNumber++
                    $queryParameters['Queries'] = $batchText

                    Microsoft.PowerShell.Utility\Write-Verbose ("Executing $ScriptFilePath batch " +
                        "$batchNumber")

                    try {
                        GenXdev\Invoke-SQLServerQuery @queryParameters
                    }
                    catch {
                        $failureMessage = "Script file '$ScriptFilePath' " +
                            "batch $batchNumber failed: " +
                            "$($PSItem.Exception.Message)"

                        writeScriptFailure -Message $failureMessage `
                            -TargetObject $ScriptFilePath `
                            -InnerException $PSItem.Exception
                    }
                }
            }
        }

        if ($null -ne $Name) {
            $receivedInput = $true

            foreach ($nameValue in $Name) {
                addScriptFilePaths $nameValue
            }
        }
    }

    process {

        if ($null -ne $InputObject) {
            $receivedInput = $true
        }

        addScriptFilePaths $InputObject
    }

    end {

        if ($scriptFilePaths.Count -eq 0) {

            if ($receivedInput -eq $false) {

                $missingInputMessage = 'No script files were provided. ' +
                    'Pass -Name or pipe file names or FileInfo objects.'

                writeScriptFailure -Message $missingInputMessage `
                    -TargetObject $null
            }

            return
        }

        # one connection for every batch, unless the caller brought one
        $ownsConnection = ($null -eq $Transaction) -and ($null -eq $Connection)
        $ownedConnection = $null

        try {
            if ($ownsConnection) {

                try {
                    $ownedConnection = GenXdev\Get-SQLServerConnection `
                        @connectionParameters
                }
                catch {
                    $failureMessage = 'Cannot open the SQL Server ' +
                        "connection: $($PSItem.Exception.Message)"

                    writeScriptFailure -Message $failureMessage `
                        -InnerException $PSItem.Exception

                    return
                }

                $queryParameters['Connection'] = $ownedConnection
            }

            foreach ($scriptFilePath in $scriptFilePaths) {
                invokeScriptFile $scriptFilePath
            }
        }
        finally {
            if ($null -ne $ownedConnection) {
                $ownedConnection.Close()
            }
        }
    }
}

###############################################################################
