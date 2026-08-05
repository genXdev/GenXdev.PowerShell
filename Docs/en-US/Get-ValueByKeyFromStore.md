# Get-ValueByKeyFromStore

> **SubModule:** GenXdev.Data.KeyValueStore | **Type:** Cmdlet | **Aliases:** `getvalue`

## Synopsis

> Retrieves a value from a local JSON-based key-value store.

## Description

* Retrieves a value for a specified key from a JSON file-based key-value
  store.
* Supports optional default values when the key is not found.


## Syntax

```powershell
Get-ValueByKeyFromStore -StoreName <String> -KeyName <String> [[-DefaultValue] <String>] [-DatabasePath <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-StoreName` | String | ✅ | Name of the store to retrieve the key from |
| `-KeyName` | String | ✅ | Key to retrieve from the specified store |
| `-DefaultValue` | String | ☐ | A optional default value |
| `-DatabasePath` | String | ☐ | Database path for key-value store data files |

## Examples

### Examples 1

```powershell
Get-ValueByKeyFromStore -StoreName "AppSettings" -KeyName "Theme" -DefaultValue "Dark"
```

Retrieves the "Theme" value from "AppSettings", returning "Dark" if not
found.

### Examples 2

```powershell
getvalue AppSettings Theme
```

Uses the 'getvalue' alias to retrieve a value.

## Parameter Details

### `-StoreName <String>`

> Name of the store to retrieve the key from

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

> Key to retrieve from the specified store

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DefaultValue <String>`

> A optional default value

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
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
- [Remove-KeyFromStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyFromStore.md)
- [Remove-KeyValueStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-KeyValueStore.md)
- [Set-ValueByKeyInStore](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-ValueByKeyInStore.md)
