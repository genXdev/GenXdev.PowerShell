# GenXdev.Coding.Templating

## Overview

GenXdev.Coding.Templating provides string templating utilities for code
generation and text formatting. It formats collections of objects against a
template string with property placeholders, and cleans up double empty lines
in generated code.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Add-ArrayTemplate](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-ArrayTemplate.md) | `FormatArray` | Format a collection of objects using `{PropertyName}` placeholders |
| [Remove-DoubleEmptyLines](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-DoubleEmptyLines.md) | — | Remove consecutive empty lines from code strings |

## How It All Comes Together

`Add-ArrayTemplate` (`FormatArray`) takes a collection of objects and a
template string with `{PropertyName}` or `{PropertyName:format}`
placeholders, producing a single formatted string from the entire collection.

`Remove-DoubleEmptyLines` collapses consecutive blank lines in a string
into single empty lines, with optional reformatting.

## See Also

- [GenXdev.Coding](README-GenXdev.Coding.md) — Refactoring and README management
- [GenXdev.Coding.PowerShell.Modules](README-GenXdev.Coding.PowerShell.Modules.md) — Documentation generation (uses templating)
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevcodingtemplating)
