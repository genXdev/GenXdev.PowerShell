# Invoke-SQLServerScriptFile

> **SubModule:** GenXdev.Data.SqlServer | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Executes SQL script files against a SQL Server database, batch by batch.

## Description

<details>
<summary><b>Expand description</b></summary>

Reads one or more SQL script files and executes them in order, splitting every
file into batches on the GO batch separator, the same way SQL Server Management
Studio does. A GO line always terminates the current batch, and repeats it with
an optional repeat count, as in 'GO 5'.

Every batch of a file is executed on one shared connection, so session state
survives a GO exactly as it does in SQL Server Management Studio: USE, temp
tables and SET options stay in effect for the rest of the file. Batches run in
autocommit mode, unless a Transaction is provided by the caller.

Failures are reported through the effective error action: an explicitly bound
-ErrorAction wins, otherwise $ErrorActionPreference decides. When the effective
action is not Stop, the failing batch is reported and the next batch is
executed.

When no connection parameter is bound, the command uses the values
$PSDefaultParameterValues holds for it in the caller's scope.

</details>

## Syntax


```powershell
Invoke-SQLServerScriptFile [[-Name] <String[]>] [<CommonParameters>]

Invoke-SQLServerScriptFile [-InputObject <Object>] [<CommonParameters>]

Invoke-SQLServerScriptFile [[-DatabaseName] <String>] [[-Server] <String>] [[-Transaction] <Microsoft.Data.SqlClient.SqlTransaction>] [[-ConnectionString] <String>] [[-SqlParameters] <Collections.Hashtable[]>] [-Connection <Microsoft.Data.SqlClient.SqlConnection>] [-ParentProgressId <Int32>] [-TimeoutSeconds <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Name` | String[] | ☐ | One or more SQL script files to execute 🌐<br>wildcards |
| `-InputObject` | Object | ☐ | SQL script files to execute, as names or<br>FileInfo objects 🌐 wildcards |
| `-DatabaseName` | String | ☐ | The name of the SQL Server database. |
| `-Server` | String | ☐ | The SQL Server instance name. |
| `-Transaction` | Microsoft.Data.SqlClient.SqlTransaction | ☐ | An existing SQL Server transaction to use for<br>the batches. |
| `-Connection` | Microsoft.Data.SqlClient.SqlConnection | ☐ | An existing open SqlConnection to execute all<br>batches on. |
| `-ConnectionString` | String | ☐ | The connection string to the SQL database. |
| `-SqlParameters` | Collections.Hashtable[] | ☐ | Query parameters as hashtables. |
| `-TimeoutSeconds` | Int32 | ☐ | Command timeout in seconds for every query.<br>Default is 30, 0 waits indefinitely. |
| `-ParentProgressId` | Int32 | ☐ | The activity identifier of the parent<br>progress record. |

## Examples


```powershell
Invoke-SQLServerScriptFile -Name '.\deploy.sql' -Server 'localhost' `
    -DatabaseName 'MyDB'
```

Executes every batch of deploy.sql against MyDB on localhost.


```powershell
Get-ChildItem -Path '.\migrations' -Filter '*.sql' |
    Invoke-SQLServerScriptFile -DatabaseName 'MyDB' -ErrorAction Continue
```

Executes every migration script in name order, reporting failures and
continuing with the next batch.

## Parameter Details

### `-Name <String[]>`

> One or more SQL script files to execute

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `like`, `Path`, `LiteralPath`, `SearchMask`, `Include` |
| **Accept wildcard characters?** | Yes |
| **Parameter set** | ByName |

<hr/>

### `-InputObject <Object>`

> SQL script files to execute, as names or FileInfo objects

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `FullName`, `Input` |
| **Accept wildcard characters?** | Yes |
| **Parameter set** | ByPipeline |

<hr/>

### `-DatabaseName <String>`

> The name of the SQL Server database.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Server <String>`

> The SQL Server instance name.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Transaction <Microsoft.Data.SqlClient.SqlTransaction>`

> An existing SQL Server transaction to use for the batches.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 3 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Connection <Microsoft.Data.SqlClient.SqlConnection>`

> An existing open SqlConnection to execute all batches on.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ConnectionString <String>`

> The connection string to the SQL database.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 4 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SqlParameters <Collections.Hashtable[]>`

> Query parameters as hashtables.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 5 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `data`, `parameters`, `args` |
| **Accept wildcard characters?** | No |

<hr/>

### `-TimeoutSeconds <Int32>`

> Command timeout in seconds for every query. Default is 30, 0 waits indefinitely.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | `timeout`, `maxseconds` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ParentProgressId <Int32>`

> The activity identifier of the parent progress record.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-SQLServerConnection](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerConnection.md)
- [Get-SQLServerSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerSchema.md)
- [Get-SQLServerTableColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableColumnData.md)
- [Get-SQLServerTableData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableData.md)
- [Get-SQLServerTables](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTables.md)
- [Get-SQLServerTableSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableSchema.md)
- [Get-SQLServerTransaction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTransaction.md)
- [Get-SQLServerViewColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewColumnData.md)
- [Get-SQLServerViewData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewData.md)
- [Get-SQLServerViews](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViews.md)
- [Get-SQLServerViewSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewSchema.md)
- [Invoke-SQLServerQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLServerQuery.md)
- [Invoke-SSMS](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SSMS.md)
- [New-SQLServerDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLServerDatabase.md)
