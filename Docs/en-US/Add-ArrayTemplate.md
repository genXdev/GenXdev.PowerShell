# Add-ArrayTemplate

> **SubModule:** GenXdev.Coding.Templating | **Type:** Function | **Aliases:** `FormatArray`

## Synopsis

> Formats a collection of objects using a template string with property
placeholders, producing a single formatted string.

## Description

Iterates over a collection of objects and applies a template string with
{PropertyName} or {PropertyName:format} placeholders to each item. The
formatted results are joined with a configurable delimiter. Supports
indentation, trailing newlines, and trailing delimiters for flexible output
formatting.


## Syntax

```powershell
Add-ArrayTemplate -InputObject <Collections.IEnumerable> -Template <String> [[-Delimiter] <String>] [[-Indentation] <Int32>] [-EndDelimiter] [-NewLine] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-InputObject` | Collections.IEnumerable | ✅ | The collection of objects to format |
| `-Template` | String | ✅ | The template string with {PropertyName} or <br>{PropertyName:format} placeholders |
| `-Delimiter` | String | ☐ | The delimiter string to insert between<br>formatted items |
| `-Indentation` | Int32 | ☐ | The number of indentation levels (4 spaces<br>per level) to apply |
| `-NewLine` | SwitchParameter | ☐ | Appends a trailing delimiter after the final<br>item |
| `-EndDelimiter` | SwitchParameter | ☐ | Add delimiter at end when array not empty |

## Examples

### @(     @{ Name = "Alice"; Age = 30 }     @{ Name = "Bob"; Age = 25 } ) | Add-ArrayTemplate -Template "{Name} is {Age} years old" Name: Alice Age: 30 Name: Bob Age: 25 Formats an array of hashtables with property placeholders.

```powershell
@(
    @{ Name = "Alice"; Age = 30 }
    @{ Name = "Bob"; Age = 25 }
) | Add-ArrayTemplate -Template "{Name} is {Age} years old"
Name: Alice
Age: 30
Name: Bob
Age: 25
Formats an array of hashtables with property placeholders.
```

### $items | FormatArray -Template "  - {Name}" -Delimiter ", " -Indentation 1 Uses the FormatArray alias with indentation and a custom delimiter.

```powershell
$items | FormatArray -Template "  - {Name}" -Delimiter ", " -Indentation 1
Uses the FormatArray alias with indentation and a custom delimiter.
```

## Parameter Details

### `-InputObject <Collections.IEnumerable>`

> The collection of objects to format

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue) |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Template <String>`

> The template string with {PropertyName} or  {PropertyName:format} placeholders

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Delimiter <String>`

> The delimiter string to insert between formatted items

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | `"`n"` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Indentation <Int32>`

> The number of indentation levels (4 spaces per level) to apply

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 3 |
| **Default value** | `0` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NewLine`

> Appends a trailing delimiter after the final item

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$false` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-EndDelimiter`

> Add delimiter at end when array not empty

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$false` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Outputs

- `String`

## Related Links

- [Remove-DoubleEmptyLines](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-DoubleEmptyLines.md)
