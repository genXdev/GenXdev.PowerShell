# GenXdev.Data.SQLite

## Overview

GenXdev.Data.SQLite provides comprehensive SQLite database access from
PowerShell. It handles schema discovery, table and view data retrieval,
transaction management, and query execution — plus it can launch SQLiteStudio
for visual database work.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [New-SQLiteDatabase](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-SQLiteDatabase.md) | `nsqldb` | Create a new SQLite database file |
| [Invoke-SQLiteQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteQuery.md) | — | Execute SQL queries with transaction support |
| [Invoke-SQLiteStudio](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SQLiteStudio.md) | — | Launch SQLiteStudio for visual database management |
| [Get-SQLiteTables](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTables.md) | — | List all tables in a database |
| [Get-SQLiteTableSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTableSchema.md) | — | Get the CREATE TABLE schema for a table |
| [Get-SQLiteTableData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTableData.md) | — | Retrieve rows from a table with optional limits |
| [Get-SQLiteTableColumnData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTableColumnData.md) | — | Retrieve data from a specific column |
| [Get-SQLiteViews](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViews.md) | — | List all views in a database |
| [Get-SQLiteViewSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewSchema.md) | — | Get the view definition |
| [Get-SQLiteViewData](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteViewData.md) | — | Retrieve rows from a view |
| [Get-SQLiteSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteSchema.md) | — | Get the complete database schema at once |
| [Get-SQLiteTransaction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SQLiteTransaction.md) | `getsqltx`, `newsqltx` | Create a transaction for batch operations |

## How It All Comes Together

`New-SQLiteDatabase` (`nsqldb`) creates a new SQLite database file.
`Invoke-SQLiteQuery` executes SQL statements against a database. The schema
discovery cmdlets (`Get-SQLiteTables`, `Get-SQLiteTableSchema`,
`Get-SQLiteTableData`, `Get-SQLiteViews`, `Get-SQLiteViewSchema`,
`Get-SQLiteViewData`, `Get-SQLiteTableColumnData`, `Get-SQLiteViewColumnData`,
`Get-SQLiteSchema`) let you explore database structure and data without
leaving PowerShell.

`Get-SQLiteTransaction` (`getsqltx`, `newsqltx`) creates a transaction object
for batch operations. `Invoke-SQLiteStudio` launches SQLiteStudio, a visual
database tool.

## See Also

- [GenXdev.Data.SqlServer](README-GenXdev.Data.SqlServer.md) — SQL Server counterpart with identical patterns
- [GenXdev.Data.Preferences](README-GenXdev.Data.Preferences.md) — Typed preferences system
- [GenXdev.Data.KeyValueStore](README-GenXdev.Data.KeyValueStore.md) — Simpler JSON storage
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevdatasqlite)
