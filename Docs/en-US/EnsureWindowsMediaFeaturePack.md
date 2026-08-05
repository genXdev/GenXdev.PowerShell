# EnsureWindowsMediaFeaturePack

> **SubModule:** GenXdev.Software | **Type:** Function | **Aliases:** —

## Synopsis

> Ensures the Windows Media Feature Pack is installed.

## Description

Checks whether the Windows Media Feature Pack is installed on Windows N
editions and installs it if missing. On non-N editions, no action is
taken. Supports automatic consent for installation prompts and can
elevate privileges when needed.


## Syntax

```powershell
EnsureWindowsMediaFeaturePack [-AutoConsent] [-AutoConsentAllPackages] [-Force] [-SessionOnly] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Force` | SwitchParameter | ☐ | The `-Force` parameter. |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to Windows Media<br>Feature  Pack and Edge installation and set<br>persistent flag. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation and set persistent flag for all<br>packages. |
| `-SessionOnly` | SwitchParameter | ☐ | Only auto consent during session |

## Parameter Details

### `-Force`

> The `-Force` parameter.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsent`

> Automatically consent to Windows Media Feature  Pack and Edge installation and set persistent flag.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsentAllPackages`

> Automatically consent to third-party software  installation and set persistent flag for all packages.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Only auto consent during session

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Ensure7Zip](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Ensure7Zip.md)
- [EnsureDeepStack](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureDeepStack.md)
- [EnsureDockerDesktop](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureDockerDesktop.md)
- [EnsureFFMPEG](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureFFMPEG.md)
- [EnsureGithubCLI](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureGithubCLI.md)
- [EnsurePaintNet](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePaintNet.md)
- [EnsurePester](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePester.md)
- [EnsurePlaywright](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePlaywright.md)
- [EnsurePSTools](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsurePSTools.md)
- [EnsureSQLiteStudio](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureSQLiteStudio.md)
- [EnsureSSMSInstalled](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureSSMSInstalled.md)
- [EnsureVSCode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureVSCode.md)
- [EnsureWinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWinMerge.md)
