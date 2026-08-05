# Remove-KeyFromStore

> **SubModule:** GenXdev.Data.KeyValueStore | **Type:** Cmdlet | **Aliases:** `removekey`

## Synopsis

> Removes a key from a local key-value store.

## Description

This function marks a specified key as deleted in a named local key-value
store. The key's value is preserved with a deletion timestamp for audit
purposes.


## Syntax

```powershell
Remove-KeyFromStore -StoreName <String> -KeyName <String> [-DatabasePath <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-StoreName` | String | ✅ | Name of the store |
| `-KeyName` | String | ✅ | Key to be deleted |
| `-DatabasePath` | String | ☐ | Database path for key-value store data files |

## Examples

### Examples 1

```powershell
Remove-KeyFromStore -StoreName "MyStore" -KeyName "MyKey"
```

Remove the key "MyKey" from the store "MyStore".

### Examples 2

```powershell
removekey "MyStore" "MyKey"
```

Remove a key using the alias.

## Parameter Details

### `-StoreName <String>`

> Name of the store

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-KeyName <String>`

> Key to be deleted

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
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
- [Get-StoreKeys](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-StoreKeys.md)
- [Get-ValueByKeyFromStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ValueByKeyFromStore.md)
- [Remove-KeyValueStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyValueStore.md)
- [Set-ValueByKeyInStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ValueByKeyInStore.md)
