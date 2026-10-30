# Get-SQLiteTableData

> **SubModule:** GenXdev.Data.SQLite | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Retrieves data from a SQLite database table with optional record limiting.

## Description

This command queries data from a SQLite database table using either a connection
string or database file path. It provides flexibility in connecting to the
database and controlling the amount of data retrieved through the Count
parameter. Every row is returned as a hashtable keyed by column name.


## Syntax


```powershell
Get-SQLiteTableData -ConnectionString <String> [<CommonParameters>]

Get-SQLiteTableData -DatabaseFilePath <String> [<CommonParameters>]

Get-SQLiteTableData -TableName <String> [[-Count] <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ConnectionString` | String | ✅ | The connection string to the SQLite database. |
| `-DatabaseFilePath` | String | ✅ | The path to the SQLite database file. |
| `-TableName` | String | ✅ | The name of the table to query data from. |
| `-Count` | Int32 | ☐ | The maximum number of records to return. -1<br>for all. |

## Examples


```powershell
Get-SQLiteTableData -DatabaseFilePath "C:\data\users.db" `
    -TableName "Employees" -Count 50
```

Returns at most 50 rows from the Employees table.


```powershell
Get-SQLiteTableData -DatabaseFilePath "C:\data\users.db" `
    -TableName "Employees" -Count -1
```

Returns every row from the Employees table.

## Parameter Details

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

### `-TableName <String>`

> The name of the table to query data from.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Count <Int32>`

> The maximum number of records to return. -1 for all.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-SQLiteConnection](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteConnection.md)
- [Get-SQLiteSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteSchema.md)
- [Get-SQLiteTableColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTableColumnData.md)
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
