# Get-KeyValueStorePath

> **SubModule:** GenXdev.Data.KeyValueStore | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Gets the file path for a local key-value store.

## Description

* Constructs the file path for a key-value store based on the store name
  and base directory. All stores use the "Local" prefix.


## Syntax

```powershell
Get-KeyValueStorePath -StoreName <String> [-BasePath <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-StoreName` | String | ✅ | The name of the key-value store |
| `-BasePath` | String | ☐ | The base directory path for store files |

## Examples

### Examples 1

```powershell
Get-KeyValueStorePath -StoreName "MyStore"
```

Get the file path for a local key-value store.

## Parameter Details

### `-StoreName <String>`

> The name of the key-value store

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-BasePath <String>`

> The base directory path for store files

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
- [Get-StoreKeys](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-StoreKeys.md)
- [Get-ValueByKeyFromStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ValueByKeyFromStore.md)
- [Remove-KeyFromStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyFromStore.md)
- [Remove-KeyValueStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyValueStore.md)
- [Set-ValueByKeyInStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ValueByKeyInStore.md)
