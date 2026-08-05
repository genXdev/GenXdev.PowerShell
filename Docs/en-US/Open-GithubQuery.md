# Open-GithubQuery

> **SubModule:** GenXdev.Queries.Webbrowser | **Type:** Function | **Aliases:** `qgithub`, `qgh`

## Synopsis

> Opens a Github repository search query in a web browser or executes advanced
searches against the GitHub REST API supporting all available qualifiers and
search categories (repositories, code, issues, users, commits, discussions,
topics, wikis).

## Description

Opens a Github repository search query in a web browser with extensive
customization options or performs advanced API searches. This function
provides a powerful interface for quickly accessing Github repositories from
PowerShell with support for multiple browsers, window positioning, language
filtering, and keyboard automation, or retrieving structured data via API.
Key features:
Multiple search query support with pipeline input
Language-specific filtering with automatic localization
Multi-browser support (Edge, Chrome, Firefox)
Advanced window positioning and monitor selection
Private/incognito browsing mode
Application mode for distraction-free browsing
Keyboard automation and focus management
URL return options for programmatic use
Advanced API search with qualifiers, sorting, pagination
Support for all GitHub search types
Authentication with personal access token
Asynchronous job execution for API searches
Raw JSON or structured object output
The function automatically constructs Github search URLs for web mode or API
endpoints for API mode and passes all browser-related parameters to the
underlying Open-Webbrowser function for consistent behavior.


## Syntax

```powershell
Open-GithubQuery -Query <String[]> [-AcceptLang <String>] [-All] [-CaseSensitive] [-Headless] [-In <String[]>] [-Language <String>] [-Order <String>] [-Org <String>] [-Page <Int32>] [-PassThru] [-PerPage <Int32>] [-PlayWright] [-Repo <String>] [-Size <String>] [-SortBy <String>] [-Type <String>] [-User <String>] [-Webkit] [<CommonParameters>]

Open-GithubQuery [-Extension <String>] [-Filename <String>] [-Path <String>] [<CommonParameters>]

Open-GithubQuery [-Assignee <String>] [-Author <String>] [-Labels <String[]>] [-No <String[]>] [-State <String>] [<CommonParameters>]

Open-GithubQuery [-Api] [-AsJob] [-RawResponse] [-Token <String>] [<CommonParameters>]

Open-GithubQuery [-ApplicationMode] [-Bottom] [-Centered] [-Chrome] [-Chromium] [-ClearSession] [-DisablePopupBlocker] [-Edge] [-Firefox] [-FocusWindow] [-Force] [-FullScreen] [-Height <Int32>] [-KeysToSend <String[]>] [-Left] [-Maximize] [-Monitor <Int32>] [-NewWindow] [-NoBorders] [-NoBrowserExtensions] [-Private] [-RestoreFocus] [-ReturnOnlyURL] [-ReturnURL] [-Right] [-SendKeyDelayMilliSeconds <Int32>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-SideBySide] [-SkipSession] [-Top] [-Width <Int32>] [-X <Int32>] [-Y <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Query` | String[] | ✅ | The search queries to execute on Github.<br>Supports  multiple queries and pipeline input<br>for batch searching. Each  query will be<br>URL-encoded and used to search Github. |
| `-Type` | String | ☐ | The major category to search. Defaults to<br>'Code'. |
| `-In` | String[] | ☐ | Field(s) to search. Only valid options for<br>the  selected Type will be accepted. |
| `-User` | String | ☐ | Restrict the search to a user's resources<br>(repos,  code, issues, etc.). |
| `-Org` | String | ☐ | Restrict search to an organization. |
| `-Repo` | String | ☐ | Restrict search to a named repository <br>('owner/repo'). |
| `-Path` | String | ☐ | Restrict code search to specific file or<br>directory  paths (supports wildcards per<br>GitHub Search Syntax). |
| `-Filename` | String | ☐ | Filter results by the filename (not path). |
| `-Extension` | String | ☐ | Restrict code search to file extensions. |
| `-Language` | String | ☐ | Filter by programming language. |
| `-Size` | String | ☐ | File/repo size. Supports numeric and range<br>syntax  (see examples). |
| `-State` | String | ☐ | For issues/PR. |
| `-Author` | String | ☐ | Issues/PR: limit to those created by a<br>specified  user. |
| `-Assignee` | String | ☐ | Issues/PR: limit to those assigned a user. |
| `-Labels` | String[] | ☐ | Issues/PR: must be labeled with all specified<br>strings. |
| `-No` | String[] | ☐ | Issues/PR: must lack certain metadata (e.g.,<br>label,  milestone). |
| `-SortBy` | String | ☐ | Sort field (depends on Type). E.g., "stars", <br>"forks", "updated", etc. |
| `-Order` | String | ☐ | asc" or "desc" order for sorting. |
| `-PerPage` | Int32 | ☐ | Page size (max 100). |
| `-Page` | Int32 | ☐ | Page number for paged results. |
| `-Token` | String | ☐ | GitHub OAuth or Personal Access Token. If not<br>supplied, uses GITHUB_TOKEN or environment<br>variable. |
| `-AcceptLang` | String | ☐ | Set the browser accept-lang http header. |
| `-SendKeyDelayMilliSeconds` | Int32 | ☐ | Delay between sending different key sequences<br>in  milliseconds. |
| `-Monitor` | Int32 | ☐ | The monitor to display results on. 0 =<br>default,  -1 = discard, -2 = secondary. |
| `-Width` | Int32 | ☐ | The initial width of the browser window. |
| `-Height` | Int32 | ☐ | The initial height of the browser window. |
| `-X` | Int32 | ☐ | The initial X position of the browser window. |
| `-Y` | Int32 | ☐ | The initial Y position of the browser window. |
| `-KeysToSend` | String[] | ☐ | Keystrokes to send to the browser window, see<br>documentation for cmdlet GenXdev\Send-Key. |
| `-CaseSensitive` | SwitchParameter | ☐ | Only match case-sensitive results (where<br>supported). |
| `-AsJob` | SwitchParameter | ☐ | Run the search asynchronously as a PowerShell<br>job. |
| `-RawResponse` | SwitchParameter | ☐ | Output raw JSON result from the API. |
| `-Api` | SwitchParameter | ☐ | Use API mode instead of opening in web<br>browser. |
| `-Private` | SwitchParameter | ☐ | Opens the browser in private/incognito<br>browsing  mode for anonymous searching. |
| `-Force` | SwitchParameter | ☐ | Force enable debugging port, stopping<br>existing  browsers if needed. |
| `-Edge` | SwitchParameter | ☐ | Opens the search results in Microsoft Edge<br>browser. |
| `-Chrome` | SwitchParameter | ☐ | Opens the search results in Google Chrome<br>browser. |
| `-Chromium` | SwitchParameter | ☐ | Opens the search results in Microsoft Edge or<br>Google Chrome, depending on what the default<br>browser is. |
| `-Firefox` | SwitchParameter | ☐ | Opens the search results in Mozilla Firefox<br>browser. |
| `-PlayWright` | SwitchParameter | ☐ | Use Playwright-managed browser instead of the<br>OS-installed browser |
| `-Webkit` | SwitchParameter | ☐ | Opens the Playwright-managed WebKit browser. <br>Implies -PlayWright |
| `-Headless` | SwitchParameter | ☐ | Run the browser without a visible window |
| `-All` | SwitchParameter | ☐ | Opens in all registered modern browsers |
| `-FullScreen` | SwitchParameter | ☐ | Opens the browser in fullscreen mode. |
| `-Left` | SwitchParameter | ☐ | Place browser window on the left side of the<br>screen. |
| `-Right` | SwitchParameter | ☐ | Place browser window on the right side of the<br>screen. |
| `-Top` | SwitchParameter | ☐ | Place browser window on the top side of the<br>screen. |
| `-Bottom` | SwitchParameter | ☐ | Place browser window on the bottom side of<br>the  screen. |
| `-Centered` | SwitchParameter | ☐ | Place browser window in the center of the<br>screen. |
| `-ApplicationMode` | SwitchParameter | ☐ | Hide the browser controls. |
| `-NoBrowserExtensions` | SwitchParameter | ☐ | Prevent loading of browser extensions. |
| `-DisablePopupBlocker` | SwitchParameter | ☐ | Disable the popup blocker in the browser. |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the browser window after opening. |
| `-SetForeground` | SwitchParameter | ☐ | Set the browser window to foreground after <br>opening. |
| `-Maximize` | SwitchParameter | ☐ | Maximize the window after positioning. |
| `-RestoreFocus` | SwitchParameter | ☐ | Restore PowerShell window focus. |
| `-NewWindow` | SwitchParameter | ☐ | Don't re-use existing browser window,<br>instead,  create a new one. |
| `-PassThru` | SwitchParameter | ☐ | Returns a [System.Diagnostics.Process] object<br>of  the browserprocess in web mode or query<br>object in API mode. |
| `-ReturnURL` | SwitchParameter | ☐ | Don't open webbrowser, just return the url. |
| `-ReturnOnlyURL` | SwitchParameter | ☐ | After opening webbrowser, return the url. |
| `-SendKeyEscape` | SwitchParameter | ☐ | Escape control characters when sending keys. |
| `-SendKeyHoldKeyboardFocus` | SwitchParameter | ☐ | Prevent returning keyboard focus to<br>PowerShell  after sending keys. |
| `-SendKeyUseShiftEnter` | SwitchParameter | ☐ | Send Shift+Enter instead of regular Enter for<br>line breaks. |
| `-NoBorders` | SwitchParameter | ☐ | Remove window borders and title bar for a<br>cleaner  appearance. |
| `-SideBySide` | SwitchParameter | ☐ | Place browser window side by side with<br>PowerShell  on the same monitor. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences. |
| `-ClearSession` | SwitchParameter | ☐ | Clear alternative settings stored in session<br>for  preferences. |
| `-SkipSession` | SwitchParameter | ☐ | Store settings only in persistent preferences<br>without affecting session. |

## Examples

### Open-GithubQuery -Query "powershell module" -Language "PowerShell" Opens a search for PowerShell modules in Github with language filtering.

```powershell
Open-GithubQuery -Query "powershell module" -Language "PowerShell"
Opens a search for PowerShell modules in Github with language filtering.
```

### qgithub "azure functions" -Monitor 0 Opens a search for Azure Functions on the primary monitor using the alias.

```powershell
qgithub "azure functions" -Monitor 0
Opens a search for Azure Functions on the primary monitor using the alias.
```

### Open-GithubQuery -Type Repository -Query PowerShell -SortBy stars -Order desc -PerPage 1 Repository search: Find top-starred PowerShell repo in GitHub

```powershell
Open-GithubQuery -Type Repository -Query PowerShell -SortBy stars -Order desc
-PerPage 1
Repository search: Find top-starred PowerShell repo in GitHub
```

### Open-GithubQuery -Type Code -Query "def " -Language python -In File Code search for function definitions in Python

```powershell
Open-GithubQuery -Type Code -Query "def " -Language python -In File
Code search for function definitions in Python
```

### Open-GithubQuery -Type Issue -Query security -Repo microsoft/vscode -Labels bug -State open Issue search: All open bugs mentioning 'security' in microsoft/vscode

```powershell
Open-GithubQuery -Type Issue -Query security -Repo microsoft/vscode -Labels
bug -State open
Issue search: All open bugs mentioning 'security' in microsoft/vscode
```

### Open-GithubQuery -Type Repository -Query PowerShell -SortBy stars -Order desc -PerPage 1 -Api API mode for repository search.

```powershell
Open-GithubQuery -Type Repository -Query PowerShell -SortBy stars -Order desc
-PerPage 1 -Api
API mode for repository search.
```

## Parameter Details

### `-Query <String[]>`

> The search queries to execute on Github. Supports  multiple queries and pipeline input for batch searching. Each  query will be URL-encoded and used to search Github.

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `q`, `Name`, `Text`, `Queries` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Type <String>`

> The major category to search. Defaults to 'Code'.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `'Code'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-In <String[]>`

> Field(s) to search. Only valid options for the  selected Type will be accepted.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-User <String>`

> Restrict the search to a user's resources (repos,  code, issues, etc.).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Org <String>`

> Restrict search to an organization.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Repo <String>`

> Restrict search to a named repository  ('owner/repo').

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Path <String>`

> Restrict code search to specific file or directory  paths (supports wildcards per GitHub Search Syntax).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Code |

<hr/>

### `-Filename <String>`

> Filter results by the filename (not path).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Code |

<hr/>

### `-Extension <String>`

> Restrict code search to file extensions.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Code |

<hr/>

### `-Language <String>`

> Filter by programming language.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Size <String>`

> File/repo size. Supports numeric and range syntax  (see examples).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-State <String>`

> For issues/PR.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Issue |

<hr/>

### `-Author <String>`

> Issues/PR: limit to those created by a specified  user.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Issue |

<hr/>

### `-Assignee <String>`

> Issues/PR: limit to those assigned a user.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Issue |

<hr/>

### `-Labels <String[]>`

> Issues/PR: must be labeled with all specified  strings.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Issue |

<hr/>

### `-No <String[]>`

> Issues/PR: must lack certain metadata (e.g., label,  milestone).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Issue |

<hr/>

### `-SortBy <String>`

> Sort field (depends on Type). E.g., "stars",  "forks", "updated", etc.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Order <String>`

> asc" or "desc" order for sorting.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PerPage <Int32>`

> Page size (max 100).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `10` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Page <Int32>`

> Page number for paged results.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Token <String>`

> GitHub OAuth or Personal Access Token. If not  supplied, uses GITHUB_TOKEN or environment variable.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Api |

<hr/>

### `-AcceptLang <String>`

> Set the browser accept-lang http header.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `$null` |
| **Accept pipeline input?** | False |
| **Aliases** | `lang`, `locale` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyDelayMilliSeconds <Int32>`

> Delay between sending different key sequences in  milliseconds.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DelayMilliSeconds` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Monitor <Int32>`

> The monitor to display results on. 0 = default,  -1 = discard, -2 = secondary.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | `m`, `mon` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Width <Int32>`

> The initial width of the browser window.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Height <Int32>`

> The initial height of the browser window.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-X <Int32>`

> The initial X position of the browser window.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Y <Int32>`

> The initial Y position of the browser window.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-999999` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-KeysToSend <String[]>`

> Keystrokes to send to the browser window, see  documentation for cmdlet GenXdev\Send-Key.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-CaseSensitive`

> Only match case-sensitive results (where supported).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AsJob`

> Run the search asynchronously as a PowerShell  job.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Api |

<hr/>

### `-RawResponse`

> Output raw JSON result from the API.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Api |

<hr/>

### `-Api`

> Use API mode instead of opening in web browser.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Api |

<hr/>

### `-Private`

> Opens the browser in private/incognito browsing  mode for anonymous searching.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `incognito`, `inprivate` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Force`

> Force enable debugging port, stopping existing  browsers if needed.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Edge`

> Opens the search results in Microsoft Edge browser.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `e` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Chrome`

> Opens the search results in Google Chrome browser.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ch` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Chromium`

> Opens the search results in Microsoft Edge or  Google Chrome, depending on what the default browser is.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `c` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Firefox`

> Opens the search results in Mozilla Firefox browser.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ff` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-PlayWright`

> Use Playwright-managed browser instead of the  OS-installed browser

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `pw` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Webkit`

> Opens the Playwright-managed WebKit browser.  Implies -PlayWright

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `wk` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Headless`

> Run the browser without a visible window

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `hl` |
| **Accept wildcard characters?** | No |

<hr/>

### `-All`

> Opens in all registered modern browsers

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-FullScreen`

> Opens the browser in fullscreen mode.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fs`, `f` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Left`

> Place browser window on the left side of the screen.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Right`

> Place browser window on the right side of the  screen.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Top`

> Place browser window on the top side of the screen.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Bottom`

> Place browser window on the bottom side of the  screen.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Centered`

> Place browser window in the center of the screen.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-ApplicationMode`

> Hide the browser controls.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `a`, `app`, `appmode` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-NoBrowserExtensions`

> Prevent loading of browser extensions.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `de`, `ne`, `NoExtensions` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-DisablePopupBlocker`

> Disable the popup blocker in the browser.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `allowpopups` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-FocusWindow`

> Focus the browser window after opening.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fw`, `focus` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-SetForeground`

> Set the browser window to foreground after  opening.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fg` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-Maximize`

> Maximize the window after positioning.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-RestoreFocus`

> Restore PowerShell window focus.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `rf`, `bg` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-NewWindow`

> Don't re-use existing browser window, instead,  create a new one.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nw`, `new` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-PassThru`

> Returns a [System.Diagnostics.Process] object of  the browserprocess in web mode or query object in API mode.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `pt` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ReturnURL`

> Don't open webbrowser, just return the url.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-ReturnOnlyURL`

> After opening webbrowser, return the url.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-SendKeyEscape`

> Escape control characters when sending keys.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `Escape` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-SendKeyHoldKeyboardFocus`

> Prevent returning keyboard focus to PowerShell  after sending keys.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `HoldKeyboardFocus` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-SendKeyUseShiftEnter`

> Send Shift+Enter instead of regular Enter for  line breaks.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `UseShiftEnter` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-NoBorders`

> Remove window borders and title bar for a cleaner  appearance.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nb` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-SideBySide`

> Place browser window side by side with PowerShell  on the same monitor.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `sbs` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-SessionOnly`

> Use alternative settings stored in session for  preferences.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-ClearSession`

> Clear alternative settings stored in session for  preferences.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

### `-SkipSession`

> Store settings only in persistent preferences  without affecting session.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |
| **Parameter set** | Web |

<hr/>

## Outputs

- `PSObject`

## Related Links

- [Copy-PDFsFromGoogleQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-PDFsFromGoogleQuery.md)
- [Open-BingQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BingQuery.md)
- [Open-BuiltWithSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BuiltWithSiteInfo.md)
- [Open-GoogleQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GoogleQuery.md)
- [Open-GoogleSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GoogleSiteInfo.md)
- [Open-GrokipediaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GrokipediaQuery.md)
- [Open-IMDBQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-IMDBQuery.md)
- [Open-InstantStreetViewQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-InstantStreetViewQuery.md)
- [Open-MovieQuote](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-MovieQuote.md)
- [Open-SearchEngine](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SearchEngine.md)
- [Open-SimularWebSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-SimularWebSiteInfo.md)
- [Open-StackOverflowQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-StackOverflowQuery.md)
- [Open-WaybackMachineSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WaybackMachineSiteInfo.md)
- [Open-WebsiteAndPerformQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WebsiteAndPerformQuery.md)
- [Open-WhoisHostSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WhoisHostSiteInfo.md)
- [Open-WikipediaNLQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WikipediaNLQuery.md)
- [Open-WikipediaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WikipediaQuery.md)
- [Open-WolframAlphaQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-WolframAlphaQuery.md)
- [Open-YoutubeQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-YoutubeQuery.md)
