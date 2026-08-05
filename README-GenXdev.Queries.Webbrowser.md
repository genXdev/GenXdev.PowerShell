# GenXdev.Queries.Webbrowser

## Overview

GenXdev.Queries.Webbrowser opens search queries across every major search
engine and information site. It covers general search (Google, Bing), code
(GitHub, Stack Overflow), media (YouTube, IMDB, MovieQuotes), site analysis
(BuiltWith, SimilarWeb, Whois, Wayback Machine), reference (Wikipedia,
Wolfram Alpha, Grokipedia), and geographic lookup (Instant StreetView).

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Open-SearchEngine](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SearchEngine.md) | `q` | Open a search in the configured default search engine |
| [Open-GoogleQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GoogleQuery.md) | — | Open a Google search with extensive customization options |
| [Open-BingQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BingQuery.md) | `bq` | Open a Bing search query |
| [Open-GithubQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GithubQuery.md) | `qgithub`, `qgh` | Search GitHub repositories, code, issues, and more |
| [Open-StackOverflowQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-StackOverflowQuery.md) | `qso` | Search Stack Overflow |
| [Open-YoutubeQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-YoutubeQuery.md) | `youtube` | Search YouTube |
| [Open-IMDBQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-IMDBQuery.md) | `imdb` | Search IMDB |
| [Open-MovieQuote](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-MovieQuote.md) | `moviequote` | Open a video clip of a movie quote |
| [Open-WikipediaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WikipediaQuery.md) | `wikipedia` | Search Wikipedia |
| [Open-WikipediaNLQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WikipediaNLQuery.md) | `wikinl` | Search Dutch Wikipedia |
| [Open-GrokipediaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GrokipediaQuery.md) | `wiki` | Search Grokipedia |
| [Open-WolframAlphaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WolframAlphaQuery.md) | `qalpha` | Query Wolfram Alpha |
| [Open-WebsiteAndPerformQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebsiteAndPerformQuery.md) | `owaq` | Open a website and execute queries on it |
| [Open-BuiltWithSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BuiltWithSiteInfo.md) | — | Check what technology a site is built with |
| [Open-SimularWebSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SimularWebSiteInfo.md) | `simularsite` | View SimilarWeb traffic analysis for a site |
| [Open-WhoisHostSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WhoisHostSiteInfo.md) | `whois` | Look up domain registration info |
| [Open-WaybackMachineSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WaybackMachineSiteInfo.md) | `wayback` | View historical snapshots of a site |
| [Open-GoogleSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GoogleSiteInfo.md) | — | View Google's cached information about a site |
| [Open-InstantStreetViewQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-InstantStreetViewQuery.md) | `isv` | Open a location in Instant StreetView |
| [Copy-PDFsFromGoogleQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-PDFsFromGoogleQuery.md) | — | Download PDFs found through Google search results |

## How It All Comes Together

`Open-SearchEngine` (`q`) opens a query in Google or via parameter specified searchengine. Each other cmdlet targets a specific service:

- Search: `Open-GoogleQuery`, `Open-BingQuery` (`bq`), `Open-YoutubeQuery`
  (`youtube`)
- Reference: `Open-WikipediaQuery` (`wikipedia`), `Open-WikipediaNLQuery`
  (`wikinl`), `Open-GrokipediaQuery` (`wiki`), `Open-WolframAlphaQuery`
  (`qalpha`)
- Code: `Open-GithubQuery` (`qgithub`, `qgh`), `Open-StackOverflowQuery`
  (`qso`)
- Media: `Open-IMDBQuery` (`imdb`), `Open-MovieQuote` (`moviequote`)
- Site analysis: `Open-BuiltWithSiteInfo`, `Open-SimularWebSiteInfo`
  (`simularsite`), `Open-WhoisHostSiteInfo` (`whois`),
  `Open-WaybackMachineSiteInfo` (`wayback`), `Open-GoogleSiteInfo`
- Other: `Open-InstantStreetViewQuery` (`isv`), `Open-WebsiteAndPerformQuery`
  (`owaq`), `Copy-PDFsFromGoogleQuery`

## See Also

- [GenXdev.Queries](README-GenXdev.Queries.md) — `qq` multi-source queries
- [GenXdev.Queries.AI](README-GenXdev.Queries.AI.md) — AI chat launchers
- [GenXdev.Webbrowser](README-GenXdev.Webbrowser.md) — Browser automation
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevquerieswebbrowser)
