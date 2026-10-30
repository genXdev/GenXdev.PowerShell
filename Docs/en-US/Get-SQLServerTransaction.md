# Get-SQLServerTransaction

> **SubModule:** GenXdev.Data.SqlServer | **Type:** Cmdlet | **Aliases:** `getsqltx`, `newsqltx`

## Synopsis

> Creates and returns a SQL Server transaction object for batch operations.

## Description

Creates a SQL Server transaction object that can be used for batch operations.
The caller is responsible for committing or rolling back the transaction. When no
Connection is provided, a connection is opened for the transaction and returned
inside it, so the caller then owns that connection and must close it.
Connection priority: Connection > ConnectionString > DatabaseName (requires
Server).


## Syntax


```powershell
Get-SQLServerTransaction -Connection <Microsoft.Data.SqlClient.SqlConnection> [<CommonParameters>]

Get-SQLServerTransaction -ConnectionString <String> [<CommonParameters>]

Get-SQLServerTransaction -DatabaseName <String> [[-Server] <String>] [<CommonParameters>]

Get-SQLServerTransaction [-IsolationLevel <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Connection` | Microsoft.Data.SqlClient.SqlConnection | ✅ | An existing open SqlConnection to begin the<br>transaction on. |
| `-ConnectionString` | String | ✅ | The connection string to the SQL database. |
| `-DatabaseName` | String | ✅ | The name of the SQL Server database. |
| `-Server` | String | ☐ | The SQL Server instance name. |
| `-IsolationLevel` | String | ☐ | Transaction isolation level. |

## Examples


```powershell
$transaction = Get-SQLServerTransaction -Server "localhost" `
    -DatabaseName "MyDatabase"
try {
    Invoke-SQLServerQuery -Transaction $transaction `
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

## Parameter Details

### `-Connection <Microsoft.Data.SqlClient.SqlConnection>`

> An existing open SqlConnection to begin the transaction on.

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

> The connection string to the SQL database.

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

## Related Links

- [Get-SQLServerConnection](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerConnection.md)
- [Get-SQLServerSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerSchema.md)
- [Get-SQLServerTableColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableColumnData.md)
- [Get-SQLServerTableData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableData.md)
- [Get-SQLServerTables](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTables.md)
- [Get-SQLServerTableSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableSchema.md)
- [Get-SQLServerViewColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewColumnData.md)
- [Get-SQLServerViewData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewData.md)
- [Get-SQLServerViews](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViews.md)
- [Get-SQLServerViewSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewSchema.md)
- [Invoke-SQLServerQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLServerQuery.md)
- [Invoke-SQLServerScriptFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLServerScriptFile.md)
- [Invoke-SSMS](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SSMS.md)
- [New-SQLServerDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLServerDatabase.md)
