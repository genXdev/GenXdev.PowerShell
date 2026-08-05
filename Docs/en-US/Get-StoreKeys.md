# Get-StoreKeys

> **SubModule:** GenXdev.Data.KeyValueStore | **Type:** Cmdlet | **Aliases:** `getkeys`

## Synopsis

> Retrieves all key names for a given local key-value store.

## Description

* Queries the KeyValueStore JSON file to retrieve all active (non-deleted)
  keys for a specified store.


## Syntax

```powershell
Get-StoreKeys -StoreName <String> [-DatabasePath <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-StoreName` | String | ✅ | Name of the store whose keys should be<br>retrieved |
| `-DatabasePath` | String | ☐ | Database path for key-value store data files |

## Examples

### Examples 1

```powershell
Get-StoreKeys -StoreName "ApplicationSettings"
```

Retrieves all keys from the ApplicationSettings store.

### Examples 2

```powershell
getkeys AppSettings
```

Retrieves keys using the alias.

## Parameter Details

### `-StoreName <String>`

> Name of the store whose keys should be retrieved

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DatabasePath <String>`

> Database path for key-value store data files

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

- [Get-KeyValueStoreNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KeyValueStoreNames.md)
- [Get-KeyValueStorePath](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-KeyValueStorePath.md)
- [Get-ValueByKeyFromStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ValueByKeyFromStore.md)
- [Remove-KeyFromStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyFromStore.md)
- [Remove-KeyValueStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyValueStore.md)
- [Set-ValueByKeyInStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ValueByKeyInStore.md)
