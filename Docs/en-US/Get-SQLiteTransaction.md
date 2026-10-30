# Get-SQLiteTransaction

> **SubModule:** GenXdev.Data.SQLite | **Type:** Cmdlet | **Aliases:** `getsqltx`, `newsqltx`

## Synopsis

> Creates and returns a SQLite transaction object for batch operations.

## Description

Creates a SQLite database connection and transaction object that can be used
for batch operations. The caller is responsible for committing or rolling back
the transaction. The connection is returned inside the transaction, so the
caller owns it and must close it.

When DatabaseFilePath is used, the database file is created unless
CreateDatabaseIfNotExists is false.
Connection priority: Connection > ConnectionString > DatabaseFilePath.


## Syntax


```powershell
Get-SQLiteTransaction -Connection <Data.SQLite.SQLiteConnection> [<CommonParameters>]

Get-SQLiteTransaction -ConnectionString <String> [<CommonParameters>]

Get-SQLiteTransaction -DatabaseFilePath <String> [<CommonParameters>]

Get-SQLiteTransaction [-CreateDatabaseIfNotExists <Boolean>] [-IsolationLevel <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Connection` | Data.SQLite.SQLiteConnection | ✅ | An existing open SQLiteConnection to begin<br>the transaction on. |
| `-ConnectionString` | String | ✅ | The connection string to the SQLite database. |
| `-DatabaseFilePath` | String | ✅ | The path to the SQLite database file. |
| `-IsolationLevel` | String | ☐ | Transaction isolation level. |
| `-CreateDatabaseIfNotExists` | Boolean | ☐ | Whether to create the database file if it<br>does not exist. |

## Examples


```powershell
$transaction = Get-SQLiteTransaction -DatabaseFilePath "C:\data.db"
try {
    Invoke-SQLiteQuery -Transaction $transaction `
        -Queries "INSERT INTO Users VALUES (@name)" `
        -SqlParameters @{"name"="John"}
    $transaction.Commit()
} catch {
    $transaction.Rollback()
    throw
} finally {
    $transaction.Connection.Close()
}
```

Runs statements inside a transaction the caller commits or rolls back.


```powershell
Get-SQLiteTransaction -ConnectionString "Data Source=C:\data.db"
```

Starts a transaction on an existing database file.

## Parameter Details

### `-Connection <Data.SQLite.SQLiteConnection>`

> An existing open SQLiteConnection to begin the transaction on.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Connection |

<hr/>

### `-ConnectionString <String>`

> The connection string to the SQLite database.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | ConnectionString |

<hr/>

### `-DatabaseFilePath <String>`

> The path to the SQLite database file.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `dbpath`, `indexpath` |
| **Accept wildcard characters?** | No |
| **Parameter set** | DatabaseFilePath |

<hr/>

### `-IsolationLevel <String>`

> Transaction isolation level.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-CreateDatabaseIfNotExists <Boolean>`

> Whether to create the database file if it does not exist.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `False` |
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
- [Get-SQLiteViewColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewColumnData.md)
- [Get-SQLiteViewData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewData.md)
- [Get-SQLiteViews](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViews.md)
- [Get-SQLiteViewSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewSchema.md)
- [Invoke-SQLiteQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteQuery.md)
- [Invoke-SQLiteScriptFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteScriptFile.md)
- [Invoke-SQLiteStudio](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteStudio.md)
- [New-SQLiteDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLiteDatabase.md)
