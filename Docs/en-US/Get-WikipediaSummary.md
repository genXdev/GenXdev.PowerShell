# Get-WikipediaSummary

> **SubModule:** GenXdev.Queries.Text | **Type:** Function | **Aliases:** `wikitxt`

## Synopsis

> Retrieves a summary of a topic from Wikipedia.

## Description

Queries the Wikipedia API to get a concise summary of the specified topic,
removing parenthetical content for improved readability.


## Syntax

```powershell
Get-WikipediaSummary -Queries <String[]> [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Queries` | String[] | ✅ | The query to perform |

## Examples

### Get-WikipediaSummary -Queries "PowerShell"

```powershell
Get-WikipediaSummary -Queries "PowerShell"
```

### wikitxt "PowerShell", "Typescript", "C#"

```powershell
wikitxt "PowerShell", "Typescript", "C#"
```

## Parameter Details

### `-Queries <String[]>`

> The query to perform

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `q`, `Name`, `Text`, `Query` |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Get-NextAffirmation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-NextAffirmation.md)
