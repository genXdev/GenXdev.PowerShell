# GenXdev.Data.SqlServer

## Overview

GenXdev.Data.SqlServer provides comprehensive SQL Server database access from
PowerShell. It mirrors GenXdev.Data.SQLite's cmdlet surface — schema discovery,
table and view data retrieval, transaction management, query execution, and
SSMS integration — providing a consistent experience across both database
engines.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [New-SQLServerDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLServerDatabase.md) | `nsqldb` | Create a new SQL Server database |
| [Invoke-SQLServerQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLServerQuery.md) | — | Execute SQL queries with transaction support |
| [Invoke-SSMS](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SSMS.md) | `ssms` | Launch SQL Server Management Studio |
| [Get-SQLServerTables](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTables.md) | — | List all tables in a database |
| [Get-SQLServerTableSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableSchema.md) | — | Get the schema definition for a table |
| [Get-SQLServerTableData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableData.md) | — | Retrieve rows from a table with optional limits |
| [Get-SQLServerTableColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTableColumnData.md) | — | Retrieve data from a specific column |
| [Get-SQLServerViews](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViews.md) | — | List all views in a database |
| [Get-SQLServerViewSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewSchema.md) | — | Get the view definition |
| [Get-SQLServerViewData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerViewData.md) | — | Retrieve rows from a view |
| [Get-SQLServerSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerSchema.md) | — | Get the complete database schema at once |
| [Get-SQLServerTransaction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLServerTransaction.md) | `getsqltx`, `newsqltx` | Create a transaction for batch operations |

## How It All Comes Together

`New-SQLServerDatabase` (`nsqldb`) creates a new SQL Server database.
`Invoke-SQLServerQuery` executes SQL statements. The schema discovery
cmdlets (`Get-SQLServerTables`, `Get-SQLServerTableSchema`,
`Get-SQLServerTableData`, `Get-SQLServerViews`, `Get-SQLServerViewSchema`,
`Get-SQLServerViewData`, `Get-SQLServerTableColumnData`,
`Get-SQLServerViewColumnData`, `Get-SQLServerSchema`) let you explore
database structure and data from PowerShell.

`Get-SQLServerTransaction` (`getsqltx`, `newsqltx`) creates a transaction
object for batch operations. `Invoke-SSMS` (`ssms`) launches SQL Server
Management Studio.

## See Also

- [GenXdev.Data.SQLite](README-GenXdev.Data.SQLite.md) — SQLite counterpart with identical patterns
- [GenXdev.Data.Preferences](README-GenXdev.Data.Preferences.md) — Typed preferences system
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevdatasqlserver)
