# GenXdev.Webbrowser

## Overview

GenXdev.Webbrowser provides complete browser automation — launch, position,
and close browser windows; manage tabs; import/export and search bookmarks
across Chrome, Edge, and Firefox;

## Features

* launching of default browser, Microsoft Edge, Google Chrome or Firefox
* launching of webbrowser with full control of window positioning
* launching of webbrowser with a large set of options

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [Open-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-Webbrowser.md) | `wb` | Open URLs in positioned browser windows with full control |
| [Open-WebbrowserSideBySide](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebbrowserSideBySide.md) | `wbn` | Launches a browser window beside the current PowerShell window. |
| [Close-Webbrowser](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Close-Webbrowser.md) | `wbc` | Close browser instances selectively |
| [Find-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Find-BrowserBookmark.md) | `bookmarks` | Search bookmarks across all installed browsers |
| [Get-BrowserBookmark](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-BrowserBookmark.md) | `gbm` | Export all bookmarks from installed browsers |
| [Export-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Export-BrowserBookmarks.md) | — | Export bookmarks to a JSON file |
| [Import-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-BrowserBookmarks.md) | — | Import bookmarks from a file into browsers |
| [Import-GenXdevBookmarkletMenu](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-GenXdevBookmarkletMenu.md) | — | Import GenXdev JavaScript bookmarklets |
| [Open-BrowserBookmarks](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BrowserBookmarks.md) | `sites` | Open bookmarks matching search criteria |
| [Show-WebsiteInAllBrowsers](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-WebsiteInAllBrowsers.md) | — | Open a URL in all installed browsers in a mosaic layout |

## How It All Comes Together

`Open-Webbrowser` (`wb`) opens URLs in browser windows with options for
positioning, monitor selection, and window styling.

`Open-WebbrowserSideBySide` (`wbn`) launches a browser window beside the
current PowerShell window.

`Close-Webbrowser` (`wbc`) closes browser instances.

`Find-BrowserBookmark` (`bookmarks`) searches and return bookmarks objects,

`Get-BrowserBookmark` (`gbm`) retrieves all bookmarks,

`Export-BrowserBookmarks` and `Import-BrowserBookmarks` handle export/import,

`Import-GenXdevBookmarkletMenu` imports GenXdev bookmarklets,

`Open-BrowserBookmarks` (`sites`) opens bookmarks matching search criteria.

`Show-WebsiteInAllBrowsers` opens a URL in multiple browsers simultaneously.

## See Also

- [GenXdev.Webbrowser.Playwright](README-GenXdev.Webbrowser.Playwright.md) — Playwright session management
- [GenXdev.Queries.Webbrowser](README-GenXdev.Queries.Webbrowser.md) — Search engine query launchers
- [GenXdev.Queries.AI](README-GenXdev.Queries.AI.md) — AI chat query launchers
- [GenXdev.Windows](README-GenXdev.Windows.md) — Window positioning primitives
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevwebbrowser)
