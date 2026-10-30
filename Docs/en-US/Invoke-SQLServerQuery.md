# Invoke-SQLServerQuery

> **SubModule:** GenXdev.Data.SqlServer | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Executes one or more SQL queries against a SQL Server database with transaction support.

## Description

Executes SQL queries against a SQL Server database with parameter support and
configurable transaction isolation. Can use an external transaction for batch
operations or create its own internal transaction. When using an external
transaction, the caller is responsible for committing/rolling back.
Connection priority: Transaction > Connection > ConnectionString > DatabaseName
(requires Server). An explicitly provided DatabaseName replaces the database of
the ConnectionString.

Every row of every result set is returned as a hashtable keyed by column name.

When no connection parameter is bound, the command uses the values
$PSDefaultParameterValues holds for it in the caller's scope.


## Syntax


```powershell
Invoke-SQLServerQuery [[-Queries] <String[]>] [[-DatabaseName] <String>] [[-Server] <String>] [[-Transaction] <Microsoft.Data.SqlClient.SqlTransaction>] [[-ConnectionString] <String>] [[-SqlParameters] <Collections.Hashtable[]>] [-Connection <Microsoft.Data.SqlClient.SqlConnection>] [-IsolationLevel <String>] [-TimeoutSeconds <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Queries` | String[] | ☐ | The query or queries to execute. |
| `-DatabaseName` | String | ☐ | The name of the SQL Server database. |
| `-Server` | String | ☐ | The SQL Server instance name. |
| `-Transaction` | Microsoft.Data.SqlClient.SqlTransaction | ☐ | An existing SQL Server transaction to use for<br>the queries. |
| `-Connection` | Microsoft.Data.SqlClient.SqlConnection | ☐ | An existing open SqlConnection to execute on. |
| `-ConnectionString` | String | ☐ | The connection string to the SQL database. |
| `-SqlParameters` | Collections.Hashtable[] | ☐ | Query parameters as hashtables. |
| `-IsolationLevel` | String | ☐ | The isolation level to use, or NoTransaction<br>for autocommit mode. Default is<br>ReadCommitted. |
| `-TimeoutSeconds` | Int32 | ☐ | Command timeout in seconds for every query.<br>Default is 30, 0 waits indefinitely. |

## Examples


```powershell
Invoke-SQLServerQuery -Server "localhost" -DatabaseName "MyDB" `
    -Queries "SELECT * FROM Users"
```

Returns every user row as a hashtable.


```powershell
$tx = Get-SQLServerTransaction -Server "localhost" -DatabaseName "MyDB"
try {
    Invoke-SQLServerQuery -Transaction $tx `
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

### `-Queries <String[]>`

> The query or queries to execute.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `q`, `Value`, `Name`, `Text`, `Query` |
| **Accept wildcard characters?** | No |

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

> An existing SQL Server transaction to use for the queries.

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

> An existing open SqlConnection to execute on.

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
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `data`, `parameters`, `args` |
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
- [Invoke-SQLServerScriptFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLServerScriptFile.md)
- [Invoke-SSMS](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SSMS.md)
- [New-SQLServerDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLServerDatabase.md)
