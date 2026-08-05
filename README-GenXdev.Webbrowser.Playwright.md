# GenXdev.Webbrowser.Playwright

## Overview

GenXdev.Webbrowser.Playwright manages persistent Playwright browser sessions.
It launches browsers with reusable user profiles (preserving logins, cookies,
and extensions), for automated scripting and testing.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Open-PlayWrightBrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-PlayWrightBrowser.md) | `spb` | Start a Playwright-managed browser with a persistent profile |
| [Select-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Select-WebbrowserTab.md) | `st` | Select a tab from running Playwright-managed browsers |
| [Set-WebbrowserTabLocation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-WebbrowserTabLocation.md) | `lt`, `Nav` | Navigate the current tab to a new URL |
| [Close-WebbrowserTab](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-WebbrowserTab.md) | `ct`, `CloseTab` | Close the currently selected browser tab |
| [Get-WebbrowserTabDomNodes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WebbrowserTabDomNodes.md) | `wl` | Query DOM nodes via CSS selectors |
| [Invoke-WebbrowserEvaluation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WebbrowserEvaluation.md) | `Eval`, `et` | Execute arbitrary JavaScript in a browser tab |
| [Get-PlaywrightSessionReference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightSessionReference.md) | — | Get a reference to the current Playwright session |
| [Get-PlaywrightProfileDirectory](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PlaywrightProfileDirectory.md) | — | Get the Playwright profile directory path |

## How It All Comes Together

`Open-PlayWrightBrowser` (`spb`) starts a Playwright-managed browser with a
persistent user profile.

`Select-WebbrowserTab` (`st`) selects a tab from running Playwright-managed
browsers.

`Set-WebbrowserTabLocation` (`lt`, `Nav`) navigates the current
tab to a new URL.

`Get-WebbrowserTabDomNodes` (`wl`) queries
DOM nodes via CSS selectors.

`Invoke-WebbrowserEvaluation` (`Eval`, `et`)
executes JavaScript in a browser tab.

`Get-PlaywrightSessionReference` returns a reference to the current
Playwright session.

`Close-WebbrowserTab` (`ct`, `CloseTab`) closes the
currently selected browser tab.

## See Also

- [GenXdev.Webbrowser](README-GenXdev.Webbrowser.md) — Browser automation
- [GenXdev.Queries.Webbrowser](README-GenXdev.Queries.Webbrowser.md) — Search queries in browser tabs
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevwebbrowserplaywright)
