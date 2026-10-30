# Get-SQLiteConnection

> **SubModule:** GenXdev.Data.SQLite | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Opens a SQLite connection that the caller owns.

## Description

<details>
<summary><b>Expand description</b></summary>

Opens a SQLite connection and returns it, leaving the caller responsible for
closing it. No transaction is started, so the connection runs in autocommit mode
and keeps one session across every command executed on it. Hand it to
Invoke-SQLiteQuery or Invoke-SQLiteScriptFile with -Connection to keep session
state such as temporary tables and PRAGMA settings alive across calls.

Opening a connection to a database file that does not exist creates it.

Connection priority: ConnectionString > DatabaseFilePath.

When no connection parameter is bound, the command uses the values
$PSDefaultParameterValues holds for it in the caller's scope.

</details>

## Syntax


```powershell
Get-SQLiteConnection [[-DatabaseFilePath] <String>] [[-ConnectionString] <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-DatabaseFilePath` | String | ☐ | The path to the SQLite database file. |
| `-ConnectionString` | String | ☐ | The connection string to the SQLite database. |

## Examples


```powershell
$connection = Get-SQLiteConnection -DatabaseFilePath "C:\data.db"
try {
    Invoke-SQLiteQuery -Connection $connection -Queries "SELECT * FROM Users"
}
finally {
    $connection.Close()
}
```

Keeps one session across every query executed on the connection.


```powershell
Get-SQLiteConnection -ConnectionString "Data Source=C:\data.db"
```

Opens a connection from a connection string.

## Parameter Details

### `-DatabaseFilePath <String>`

> The path to the SQLite database file.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `dbpath`, `indexpath` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ConnectionString <String>`

> The connection string to the SQLite database.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

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
- [Invoke-SQLiteScriptFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteScriptFile.md)
- [Invoke-SQLiteStudio](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteStudio.md)
- [New-SQLiteDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLiteDatabase.md)
