# EnsureVSCode

> **SubModule:** GenXdev.Software | **Type:** Function | **Aliases:** —

## Synopsis

> Installs and configures Visual Studio Code with recommended extensions.

## Description

Checks if Visual Studio Code is installed and if not, installs it using WinGet.
Configures user settings, keybindings, and installs recommended extensions from
the workspace configuration. Also sets up PSGallery as a trusted repository and
configures specific extension settings.


## Syntax

```powershell
EnsureVSCode [-AutoConsent] [-AutoConsentAllPackages] [-Force] [-SessionOnly] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Force` | SwitchParameter | ☐ | The `-Force` parameter. |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to VSCode and extension<br>installation and set persistent flag. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation and set persistent flag for all<br>packages. |
| `-SessionOnly` | SwitchParameter | ☐ | Only auto consent during session |

## Examples

### EnsureVSCode

```powershell
EnsureVSCode
```

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

> Automatically consent to VSCode and extension  installation and set persistent flag.

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
- [EnsureWindowsMediaFeaturePack](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWindowsMediaFeaturePack.md)
- [EnsureWinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWinMerge.md)
