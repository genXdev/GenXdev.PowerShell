# GenXdev.Coding.PowerShell.Modules

## Overview

GenXdev.Coding.PowerShell.Modules is the meta-module — it's how GenXdev
develops, documents, tests, and analyzes itself. It generates MAML XML help
and per-cmdlet markdown, runs PSScriptAnalyzer, validates cross-module references,
and provides AI-assisted cmdlet improvement workflows.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [New-ModuleMarkdownHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleMarkdownHelp.md) | — | Generate rich markdown help files for any PowerShell module |
| [New-ModuleXmlHelp](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-ModuleXmlHelp.md) | — | Generate MAML XML help for any PowerShell module |
| [Assert-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevCmdlet.md) | `improvecmdlet` | AI-assisted cmdlet documentation and implementation improvement |
| [Assert-GenXdevCmdletTests](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevCmdletTests.md) | `improvecmdlettests` | AI-assisted unit test improvement |
| [Assert-GenXdevTest](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-GenXdevTest.md) | `rungenxdevtests` | Run tests with AI-powered error resolution |
| [Get-GenXDevNewModulesInOrderOfDependency](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-GenXDevNewModulesInOrderOfDependency.md) | — | Get modules sorted by dependency order |
| [Search-GenXdevCmdlet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Search-GenXdevCmdlet.md) | `searchcmdlet` | Search for a cmdlet and optionally open it in an IDE |
| [Show-GenXdevCmdLetInIde](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-GenXdevCmdLetInIde.md) | `editcmdlet`, `cmdlet` | Open a GenXdev cmdlet source in VS Code |
| [Invoke-GenXdevScriptAnalyzer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevScriptAnalyzer.md) | — | Run PSScriptAnalyzer with GenXdev rules |
| [Invoke-GenXdevPSFormatter](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-GenXdevPSFormatter.md) | — | Format PowerShell source files |
| [EnsureDefaultGenXdevRefactors](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureDefaultGenXdevRefactors.md) | — | Set up default refactoring definitions |

## How It All Comes Together

`New-ModuleXmlHelp` and `New-ModuleMarkdownHelp` generate MAML XML and
markdown help files from PowerShell comment-based help. They work against
any PowerShell module.

`Assert-GenXdevCmdlet` (`improvecmdlet`) and `Assert-GenXdevCmdletTests`
(`improvecmdlettests`) use AI to improve cmdlet documentation and tests.
`Assert-GenXdevTest` (`rungenxdevtests`) runs unit tests with AI-powered
error resolution.

`Assert-GenXdevDependencyUsage` (`checkgenxdevdependencies`) validates
cross-module dependency usage. `Get-GenXDevNewModulesInOrderOfDependency`
gets modules sorted by their dependency order.

`Search-GenXdevCmdlet` (`searchcmdlet`) searches for a GenXdev cmdlet and
can open it in an IDE. `Show-GenXdevCmdLetInIde` (`cmdlet`, `editcmdlet`)
opens a cmdlet's source in VS Code.

`Invoke-GenXdevScriptAnalyzer` runs PSScriptAnalyzer. `Invoke-GenXdevPSFormatter`
formats PowerShell source files.

## See Also

- [GenXdev.Coding](README-GenXdev.Coding.md) — Refactoring and README management
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevcodingpowershellmodules)
