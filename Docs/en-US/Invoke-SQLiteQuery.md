# Invoke-SQLiteQuery

> **SubModule:** GenXdev.Data.SQLite | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Executes one or more SQL queries against a SQLite database with transaction support.

## Description

Executes SQL queries against a SQLite database with parameter support and
configurable transaction isolation. Can use an external transaction for batch
operations or create its own internal transaction. When using an external
transaction, the caller is responsible for committing/rolling back.
Connection priority: Transaction > Connection > ConnectionString >
DatabaseFilePath.

Every row of every result set is returned as a hashtable keyed by column name.

When no connection parameter is bound, the command uses the values
$PSDefaultParameterValues holds for it in the caller's scope.


## Syntax


```powershell
Invoke-SQLiteQuery [[-ConnectionString] <String>] [[-DatabaseFilePath] <String>] [[-Transaction] <Data.SQLite.SQLiteTransaction>] -Queries <String[]> [[-SqlParameters] <Collections.Hashtable[]>] [-Connection <Data.SQLite.SQLiteConnection>] [-IsolationLevel <String>] [-TimeoutSeconds <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ConnectionString` | String | ☐ | The connection string to the SQLite database. |
| `-DatabaseFilePath` | String | ☐ | The path to the SQLite database file. |
| `-Transaction` | Data.SQLite.SQLiteTransaction | ☐ | An existing SQLite transaction to use for the<br>queries. |
| `-Connection` | Data.SQLite.SQLiteConnection | ☐ | An existing open SQLiteConnection to execute<br>on. |
| `-Queries` | String[] | ✅ | The query or queries to execute. |
| `-SqlParameters` | Collections.Hashtable[] | ☐ | Query parameters as hashtables. |
| `-TimeoutSeconds` | Int32 | ☐ | Command timeout in seconds for every query.<br>Default is 30, 0 waits indefinitely. |
| `-IsolationLevel` | String | ☐ | The isolation level to use, or NoTransaction<br>for autocommit mode. Default is<br>ReadCommitted. |

## Examples


```powershell
Invoke-SQLiteQuery -DatabaseFilePath "C:\data.db" `
    -Queries "SELECT * FROM Users"
```

Returns every user row as a hashtable.


```powershell
$tx = Get-SQLiteTransaction -DatabaseFilePath "C:\data.db"
try {
    Invoke-SQLiteQuery -Transaction $tx `
        -Queries "INSERT INTO Users VALUES (@name)" `
        -SqlParameters @{"name"="John"}
    $tx.Commit()
} catch {
    $tx.Rollback()
    throw
} finally {
    $tx.Connection.Close()
}
```

Runs a statement inside a transaction the caller owns.

## Parameter Details

### `-ConnectionString <String>`

> The connection string to the SQLite database.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

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

> An existing SQLite transaction to use for the queries.

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

> An existing open SQLiteConnection to execute on.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Queries <String[]>`

> The query or queries to execute.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 3 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `q`, `Value`, `Name`, `Text`, `Query` |
| **Accept wildcard characters?** | No |

> This parameter accepts all remaining arguments.

<hr/>

### `-SqlParameters <Collections.Hashtable[]>`

> Query parameters as hashtables.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 4 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `data`, `parameters`, `args` |
| **Accept wildcard characters?** | No |

> This parameter accepts all remaining arguments.

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

### `-IsolationLevel <String>`

> The isolation level to use, or NoTransaction for autocommit mode. Default is ReadCommitted.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
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
- [Invoke-SQLiteScriptFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteScriptFile.md)
- [Invoke-SQLiteStudio](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteStudio.md)
- [New-SQLiteDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLiteDatabase.md)
