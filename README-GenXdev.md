# GenXdev — Core

## Overview

The root GenXdev module is the entry point to the platform. It provides the
discovery cmdlets that let you explore the full suite — list every module,
cmdlet, and alias in one view, or search for specific commands and open their
source instantly.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Show-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-GenXdevCmdlet.md) | `cmds` | Display all or find cmdlets on a part of their name or aliases |
| [Get-GenXDevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevCmdlet.md) | `gcmds` | Retrieve and filter the full cmdlet list programmatically |

## How It All Comes Together

`Show-GenXdevCmdlet` (`cmds`) displays all GenXdev modules with their
cmdlets and aliases. `Get-GenXDevCmdlet` (`gcmds`) retrieves and filters
the full cmdlet list programmatically.

## See Also

- [GenXdev.AI](README-GenXdev.AI.md) — LLM settings, chat, MCP server
- [GenXdev.FileSystem](README-GenXdev.FileSystem.md) — File search, RoboCopy, atomic writes
- [GenXdev.Webbrowser](README-GenXdev.Webbrowser.md) — Browser automation
- [GenXdev.Windows](README-GenXdev.Windows.md) — Window management and system control
- [Docs/en-US/README.md](Docs/en-US/README.md) — Full cmdlet reference
