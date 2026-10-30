# Invoke-SQLiteScriptFile

> **SubModule:** GenXdev.Data.SQLite | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Executes SQL script files against a SQLite database, batch by batch.

## Description

<details>
<summary><b>Expand description</b></summary>

Reads one or more SQL script files and executes them in order, splitting every
file into batches on the GO batch separator, the same convention SQL Server
Management Studio uses. A GO line always terminates the current batch, and
repeats it with an optional repeat count, as in 'GO 5'.

Every batch of a file is executed on one shared connection, so session state
survives a GO: temporary tables and PRAGMA settings stay in effect for the rest
of the file. Batches run in autocommit mode, unless a Transaction is provided by
the caller.

Failures are reported through the effective error action: an explicitly bound
-ErrorAction wins, otherwise $ErrorActionPreference decides. When the effective
action is not Stop, the failing batch is reported and the next batch is
executed.

When no connection parameter is bound, the command uses the values
$PSDefaultParameterValues holds for it in the caller's scope.

</details>

## Syntax


```powershell
Invoke-SQLiteScriptFile [[-Name] <String[]>] [<CommonParameters>]

Invoke-SQLiteScriptFile [-InputObject <Object>] [<CommonParameters>]

Invoke-SQLiteScriptFile [[-DatabaseFilePath] <String>] [[-Transaction] <Data.SQLite.SQLiteTransaction>] [[-ConnectionString] <String>] [[-SqlParameters] <Collections.Hashtable[]>] [-Connection <Data.SQLite.SQLiteConnection>] [-ParentProgressId <Int32>] [-TimeoutSeconds <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Name` | String[] | ☐ | One or more SQL script files to execute 🌐<br>wildcards |
| `-InputObject` | Object | ☐ | SQL script files to execute, as names or<br>FileInfo objects 🌐 wildcards |
| `-DatabaseFilePath` | String | ☐ | The path to the SQLite database file. |
| `-Transaction` | Data.SQLite.SQLiteTransaction | ☐ | An existing SQLite transaction to use for the<br>batches. |
| `-Connection` | Data.SQLite.SQLiteConnection | ☐ | An existing open SQLiteConnection to execute<br>all batches on. |
| `-ConnectionString` | String | ☐ | The connection string to the SQLite database. |
| `-SqlParameters` | Collections.Hashtable[] | ☐ | Query parameters as hashtables. |
| `-TimeoutSeconds` | Int32 | ☐ | Command timeout in seconds for every query.<br>Default is 30, 0 waits indefinitely. |
| `-ParentProgressId` | Int32 | ☐ | The activity identifier of the parent<br>progress record. |

## Examples


```powershell
Invoke-SQLiteScriptFile -Name '.\deploy.sql' `
    -DatabaseFilePath '.\data.sqlite'
```

Executes every batch of deploy.sql against data.sqlite.


```powershell
Get-ChildItem -Path '.\migrations' -Filter '*.sql' |
    Invoke-SQLiteScriptFile -DatabaseFilePath '.\data.sqlite' `
        -ErrorAction Continue
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

### `-DatabaseFilePath <String>`

> The path to the SQLite database file.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `dbpath`, `indexpath` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Transaction <Data.SQLite.SQLiteTransaction>`

> An existing SQLite transaction to use for the batches.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Connection <Data.SQLite.SQLiteConnection>`

> An existing open SQLiteConnection to execute all batches on.

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

> The connection string to the SQLite database.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 3 |
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
| **Position?** | 4 |
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

- [Get-SQLiteConnection](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteConnection.md)
- [Get-SQLiteSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteSchema.md)
- [Get-SQLiteTableColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTableColumnData.md)
- [Get-SQLiteTableData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTableData.md)
- [Get-SQLiteTables](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTables.md)
- [Get-SQLiteTableSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTableSchema.md)
- [Get-SQLiteTransaction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTransaction.md)
- [Get-SQLiteViewColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewColumnData.md)
- [Get-SQLiteViewData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewData.md)
- [Get-SQLiteViews](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViews.md)
- [Get-SQLiteViewSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewSchema.md)
- [Invoke-SQLiteQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteQuery.md)
- [Invoke-SQLiteStudio](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteStudio.md)
- [New-SQLiteDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLiteDatabase.md)
