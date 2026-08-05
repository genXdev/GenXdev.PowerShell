# Copy-PDFsFromGoogleQuery

> **SubModule:** GenXdev.Queries.Webbrowser | **Type:** Function | **Aliases:** —

## Synopsis

> Downloads PDF files found through Google search results.

## Description

Performs a Google query in the previously selected webbrowser tab and downloads
all found PDF files into the current directory. Supports multiple queries and
language filtering.


## Syntax

```powershell
Copy-PDFsFromGoogleQuery -Queries <String[]> [[-Max] <Int32>] [[-Language] <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Queries` | String[] | ✅ | The search terms to query Google for PDF<br>files |
| `-Max` | Int32 | ☐ | Maximum number of results to retrieve<br>(default: 200) |
| `-Language` | String | ☐ | Optional language filter for search results |

## Examples

### Open-Webbrowser Select-WebbrowserTab $null = New-Item -ItemType Directory -Name pdfs Set-Location pdfs Copy-PDFsFromGoogleQuery "scientific paper co2" -Max 50 -Language "English"

```powershell
Open-Webbrowser
Select-WebbrowserTab
$null = New-Item -ItemType Directory -Name pdfs
Set-Location pdfs
Copy-PDFsFromGoogleQuery "scientific paper co2" -Max 50 -Language "English"
```

## Parameter Details

### `-Queries <String[]>`

> The search terms to query Google for PDF files

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `q`, `Name`, `Text`, `Query` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Max <Int32>`

> Maximum number of results to retrieve (default: 200)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `200` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Language <String>`

> Optional language filter for search results

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Open-BingQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BingQuery.md)
- [Open-BuiltWithSiteInfo](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-BuiltWithSiteInfo.md)
- [Open-GithubQuery](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Open-GithubQuery.md)
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
