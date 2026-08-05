# GenXdev.Data.KeyValueStore

## Overview

GenXdev.Data.KeyValueStore provides a persistent JSON-based key-value store
on the local filesystem. You create named stores, set and get values by key,
enumerate keys, and remove entries or entire stores.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Set-ValueByKeyInStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ValueByKeyInStore.md) | `setvalue` | Store a value under a key in a named key-value store |
| [Get-ValueByKeyFromStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ValueByKeyFromStore.md) | `getvalue` | Retrieve a value by key from a named store |
| [Get-StoreKeys](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-StoreKeys.md) | `getkeys` | List all keys in a named key-value store |
| [Get-KeyValueStoreNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KeyValueStoreNames.md) | `getstorenames` | List all available key-value stores |
| [Get-KeyValueStorePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KeyValueStorePath.md) | — | Get the filesystem path for a named store |
| [Remove-KeyFromStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyFromStore.md) | `removekey` | Remove a single key from a store |
| [Remove-KeyValueStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyValueStore.md) | — | Delete an entire key-value store |

## How It All Comes Together

Each key-value store is a named JSON file on disk. `Set-ValueByKeyInStore`
(`setvalue`) writes a value under a key. `Get-ValueByKeyFromStore`
(`getvalue`) reads it back. `Get-StoreKeys` (`getkeys`) lists all keys in a
store. `Remove-KeyFromStore` (`removekey`) removes a single key.
`Remove-KeyValueStore` deletes an entire store. `Get-KeyValueStoreNames`
(`getstorenames`) lists all available stores. `Get-KeyValueStorePath`
returns the filesystem path for a store.

## See Also

- [GenXdev.Data.Preferences](README-GenXdev.Data.Preferences.md) — Typed preferences with defaults
- [GenXdev.Data.SQLite](README-GenXdev.Data.SQLite.md) — Full relational database access
- [GenXdev.FileSystem](README-GenXdev.FileSystem.md) — File system utilities
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevdatakeyvaluestore)
