# Ensure7Zip

> **SubModule:** GenXdev.Software | **Type:** Function | **Aliases:** —

## Synopsis

> Ensures 7-Zip is installed and available on the PATH.

## Description

This function verifies if 7-Zip is installed on the system by checking both
the PATH and the default installation location. If not found, it attempts to
install 7-Zip via winget after obtaining user consent. Adds the 7-Zip
directory to the session PATH so that 7z.exe can be invoked directly.


## Syntax

```powershell
Ensure7Zip [-AutoConsent] [-AutoConsentAllPackages] [-SessionOnly] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to 7-Zip installation <br>and set persistent flag. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation and set persistent flag for all<br>packages. |
| `-SessionOnly` | SwitchParameter | ☐ | Only auto consent during session |

## Examples

### Ensure7Zip 7z x -y "-oC:\Output" archive.7z

```powershell
Ensure7Zip
7z x -y "-oC:\Output" archive.7z
```

## Parameter Details

### `-AutoConsent`

> Automatically consent to 7-Zip installation  and set persistent flag.

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
- [EnsureWindowsMediaFeaturePack](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWindowsMediaFeaturePack.md)
- [EnsureWinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWinMerge.md)
