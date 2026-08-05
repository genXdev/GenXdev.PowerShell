# New-GenXdevMCPToken

> **SubModule:** GenXdev.AI | **Type:** Function | **Aliases:** —

## Synopsis

> Generates a secure random Bearer token for GenXdev MCP server
    authentication.

## Description

Creates a cryptographically secure random token and optionally stores
    it in the user environment variable GENXDEV_MCP_TOKEN. The token is
    used to authenticate requests to the GenXdev MCP server from clients on
    the local network.


## Syntax

```powershell
New-GenXdevMCPToken [[-Length] <Int32>] [-Force] [-SetEnvironmentVariable] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Length` | Int32 | ☐ | The length of the token in bytes (default:<br>32, minimum: 16) |
| `-SetEnvironmentVariable` | SwitchParameter | ☐ | Store the token in GENXDEV_MCP_TOKEN user<br>environment variable |
| `-Force` | SwitchParameter | ☐ | Overwrite existing environment variable<br>without prompting |

## Examples

### New-GenXdevMCPToken     Generates and displays a new random token without storing it.

```powershell
New-GenXdevMCPToken
    Generates and displays a new random token without storing it.
```

### New-GenXdevMCPToken -SetEnvironmentVariable     Generates a new token and stores it in the GENXDEV_MCP_TOKEN user     environment variable. Prompts if a token already exists.

```powershell
New-GenXdevMCPToken -SetEnvironmentVariable
    Generates a new token and stores it in the GENXDEV_MCP_TOKEN user
    environment variable. Prompts if a token already exists.
```

### New-GenXdevMCPToken -Length 64 -SetEnvironmentVariable -Force     Generates a longer 64-byte token, stores it in the environment     variable, and overwrites any existing token without prompting.

```powershell
New-GenXdevMCPToken -Length 64 -SetEnvironmentVariable -Force
    Generates a longer 64-byte token, stores it in the environment
    variable, and overwrites any existing token without prompting.
```

### $token = New-GenXdevMCPToken     Start-GenXdevMCPServer -Token $token     Generates a token and passes it directly to the MCP server without     storing in environment.

```powershell
$token = New-GenXdevMCPToken
    Start-GenXdevMCPServer -Token $token
    Generates a token and passes it directly to the MCP server without
    storing in environment.
```

## Parameter Details

### `-Length <Int32>`

> The length of the token in bytes (default: 32, minimum: 16)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `32` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SetEnvironmentVariable`

> Store the token in GENXDEV_MCP_TOKEN user environment variable

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Force`

> Overwrite existing environment variable without prompting

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Outputs

- `String. The generated Bearer token as a base64-encoded string.`

## Related Links

- [Get-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AILLMSettings.md)
- [Get-SpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SpeechToText.md)
- [Get-TextTranslation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TextTranslation.md)
- [Get-VectorSimilarity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-VectorSimilarity.md)
- [Invoke-AILLMSettingsPrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-AILLMSettingsPrompt.md)
- [Invoke-WinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WinMerge.md)
- [Merge-TranslationCache](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Merge-TranslationCache.md)
- [New-LLMAudioChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMAudioChat.md)
- [New-LLMTextChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMTextChat.md)
- [Receive-RealTimeSpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Receive-RealTimeSpeechToText.md)
- [Set-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AILLMSettings.md)
- [Set-GenXdevCommandNotFoundAction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevCommandNotFoundAction.md)
- [Start-GenXdevMCPServer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-GenXdevMCPServer.md)
- [Test-DeepLinkImageFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-DeepLinkImageFile.md)
