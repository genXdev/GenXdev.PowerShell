# GenXdev.Queries

## Overview

GenXdev.Queries dispatches search terms across multiple AI providers, search
engines, and content sources simultaneously — open a question in ChatGPT,
Google, Wikipedia, and Stack Overflow all at once with a single command.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Open-AllPossibleQueries](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-AllPossibleQueries.md) | `qq` | Fire a query at all available AI and search engine targets simultaneously |
| [ConvertTo-Uris](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-Uris.md) | — | Parse any string for valid URIs |

## How It All Comes Together

`Open-AllPossibleQueries` (`qq`) opens search terms or URLs across multiple
AI providers, search engines, and content sources simultaneously. Each opens
in a browser window.

`ConvertTo-Uris` parses strings for valid URIs, determining whether the
input is a search term or a URL that should be opened directly.

## See Also

- [GenXdev.Queries.AI](README-GenXdev.Queries.AI.md) — AI chat query launchers
- [GenXdev.Queries.Webbrowser](README-GenXdev.Queries.Webbrowser.md) — Search engine query launchers
- [GenXdev.Queries.Websites](README-GenXdev.Queries.Websites.md) — Specialized web apps
- [GenXdev.Queries.Text](README-GenXdev.Queries.Text.md) — Text lookups (Wikipedia, affirmations)
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevqueries)
