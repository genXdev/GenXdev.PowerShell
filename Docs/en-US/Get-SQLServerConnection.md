# Get-SQLServerConnection

> **SubModule:** GenXdev.Data.SqlServer | **Type:** Function | **Aliases:** `getsqlconnection`, `newsqlconnection`

## Synopsis

> Opens a SQL Server connection that the caller owns.

## Description

Opens a SQL Server connection and returns it, leaving the caller responsible for
closing it. No transaction is started, so the connection runs in autocommit mode
and keeps one session across every command executed on it. Hand it to
Invoke-SQLServerQuery or Invoke-SQLServerScriptFile with -Connection to keep
session state such as USE, temp tables and SET options alive across calls.
Connection priority: ConnectionString > DatabaseName (requires Server).


## Syntax


```powershell
Get-SQLServerConnection [[-DatabaseName] <String>] [[-Server] <String>] [[-ConnectionString] <String>] [-AutoConsent] [-AutoConsentAllPackages] [-SessionOnly] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-DatabaseName` | String | ☐ | The name of the SQL Server database. |
| `-Server` | String | ☐ | The SQL Server instance name. |
| `-ConnectionString` | String | ☐ | The connection string to the SQL database. |
| `-AutoConsent` | SwitchParameter | ☐ | Force a consent prompt even if a preference<br>is already set. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to ALL third-party<br>software installations and set persistent<br>flag for SQL Server package. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for preferences |

## Examples



```powershell
$connection = Get-SQLServerConnection -Server "localhost" -DatabaseName "MyDB"
try {
    Invoke-SQLServerQuery -Connection $connection -Queries "SELECT * FROM Users"
}
finally {
    $connection.Close()
}
```



```powershell
Get-SQLServerConnection -ConnectionString "Server=localhost;Database=MyDB;Integrated Security=true"
```

## Parameter Details

### `-DatabaseName <String>`

> The name of the SQL Server database.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `'master'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Server <String>`

> The SQL Server instance name.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `'.'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ConnectionString <String>`

> The connection string to the SQL database.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsent`

> Force a consent prompt even if a preference is already set.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsentAllPackages`

> Automatically consent to ALL third-party software installations and set persistent flag for SQL Server package.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Use alternative settings stored in session for preferences

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
- [Invoke-SQLServerScriptFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLServerScriptFile.md)
- [Invoke-SSMS](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SSMS.md)
- [New-SQLServerDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLServerDatabase.md)
