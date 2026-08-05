# GenXdev.Software

## Overview

GenXdev.Software contain general helpers for ensuring third-party tools are installed and available on
your system. Each `Ensure*` cmdlet checks for the tool, installs it if missing (with
user consent), and adds it to the PATH. It covers 3th party apps like: Docker,
Playwright, FFmpeg, 7-Zip, SQLiteStudio, SSMS, VS Code, Paint.NET, WinMerge,
Pester, GitHub CLI, PSTools, DeepStack, and the Windows Media Feature Pack.

## What It Offers

| Command | Aliases | What it does |
|:---|:---|:---|
| [EnsureDockerDesktop](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureDockerDesktop.md) | — | Ensure Docker Desktop is installed and running |
| [EnsurePlaywright](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePlaywright.md) | — | Ensure Playwright .NET assembly and browser binaries |
| [EnsureFFMPEG](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureFFMPEG.md) | — | Ensure FFmpeg is installed and on PATH |
| [Ensure7Zip](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Ensure7Zip.md) | — | Ensure 7-Zip is installed |
| [EnsureDeepStack](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureDeepStack.md) | — | Ensure DeepStack face recognition service is running |
| [EnsureVSCode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureVSCode.md) | — | Install and configure VS Code with recommended extensions |
| [EnsureWinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWinMerge.md) | — | Ensure WinMerge is available for file comparison |
| [EnsureSQLiteStudio](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureSQLiteStudio.md) | — | Ensure SQLiteStudio is installed |
| [EnsureSSMSInstalled](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureSSMSInstalled.md) | — | Ensure SQL Server Management Studio is installed |
| [EnsurePester](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePester.md) | — | Ensure the Pester testing framework is available |
| [EnsureGithubCLI](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureGithubCLI.md) | — | Ensure GitHub CLI is installed and configured |
| [EnsurePSTools](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePSTools.md) | — | Ensure Sysinternals PSTools are installed |
| [EnsurePaintNet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePaintNet.md) | — | Ensure Paint.NET is installed |
| [EnsureWindowsMediaFeaturePack](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWindowsMediaFeaturePack.md) | — | Ensure Windows Media Feature Pack is installed |

## How It All Comes Together

Each `Ensure*` cmdlet verifies that a specific third-party tool is installed
and available. If the tool is missing, it installs it (with user consent).

## See Also

- [GenXdev.Helpers](README-GenXdev.Helpers.md) — `EnsureGenXdev` utility function
- [GenXdev.AI.DeepStack](README-GenXdev.AI.DeepStack.md) — DeepStack face recognition
- [GenXdev.Windows.WireGuard](README-GenXdev.Windows.WireGuard.md) — WireGuard VPN (Docker-based)
- [Full Cmdlet Reference](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/README.md#genxdevsoftware)
