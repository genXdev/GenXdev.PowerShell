# Get-SQLServerTableData

> **SubModule:** GenXdev.Data.SqlServer | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Retrieves data from a SQL database table with optional record limiting.

## Description

This command queries data from a SQL Server table using either a connection
string or a database name with server. It provides flexibility in connecting to
the database and controlling the amount of data retrieved through the Count
parameter. Every row is returned as a hashtable keyed by column name.


## Syntax


```powershell
Get-SQLServerTableData -ConnectionString <String> [<CommonParameters>]

Get-SQLServerTableData -DatabaseName <String> [[-Server] <String>] [<CommonParameters>]

Get-SQLServerTableData -TableName <String> [[-Count] <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ConnectionString` | String | ✅ | The connection string to the SQL Server<br>database. |
| `-DatabaseName` | String | ✅ | The name of the SQL Server database. |
| `-Server` | String | ☐ | The SQL Server instance name. |
| `-TableName` | String | ✅ | The name of the table to query data from. |
| `-Count` | Int32 | ☐ | The maximum number of records to return. -1<br>for all. |

## Examples


```powershell
Get-SQLServerTableData -DatabaseName "tempdb" -Server "localhost" `
    -TableName "Employees" -Count 50
```

Returns at most 50 rows from the Employees table.


```powershell
Get-SQLServerTableData -DatabaseName "tempdb" -TableName "Employees" -Count -1
```

Returns every row from the Employees table.

## Parameter Details

### `-ConnectionString <String>`

> The connection string to the SQL Server database.

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

### `-DatabaseName <String>`

> The name of the SQL Server database.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | DatabaseName |

<hr/>

### `-Server <String>`

> The SQL Server instance name.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | DatabaseName |

<hr/>

### `-TableName <String>`

> The name of the table to query data from.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 2 |
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
| **Position?** | 3 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-SQLServerConnection](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerConnection.md)
- [Get-SQLServerSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerSchema.md)
- [Get-SQLServerTableColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableColumnData.md)
- [Get-SQLServerTables](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTables.md)
- [Get-SQLServerTableSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableSchema.md)
- [Get-SQLServerTransaction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTransaction.md)
- [Get-SQLServerViewColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewColumnData.md)
- [Get-SQLServerViewData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewData.md)
- [Get-SQLServerViews](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViews.md)
- [Get-SQLServerViewSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewSchema.md)
- [Invoke-SQLServerQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLServerQuery.md)
- [Invoke-SQLServerScriptFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLServerScriptFile.md)
- [Invoke-SSMS](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SSMS.md)
- [New-SQLServerDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLServerDatabase.md)
