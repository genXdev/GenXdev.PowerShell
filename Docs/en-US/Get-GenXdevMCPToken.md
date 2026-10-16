# Get-GenXdevMCPToken

> **SubModule:** GenXdev.AI | **Type:** Function | **Aliases:** —

## Synopsis

> Resolves the GenXdev MCP server authentication token.

## Description

Returns the MCP token from the DPAPI protected token file, falling back to the
GENXDEV_MCP_TOKEN user environment variable. The protected file is written by
New-GenXdevMCPToken -SetProtectedFile and is encrypted with the Windows Data
Protection API, so it decrypts silently for the same user on the same machine
and never prompts for a password.
The environment variable is only honoured as a fallback, so an existing setup
that still stores its token there keeps working.


## Syntax


```powershell
Get-GenXdevMCPToken [[-ProtectedFilePath] <String>] [-ProtectedFileOnly] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ProtectedFilePath` | String | ☐ | Path of the DPAPI protected token file |
| `-ProtectedFileOnly` | SwitchParameter | ☐ | Only report a token stored in the protected<br>file |

## Examples



```powershell
$token = Get-GenXdevMCPToken
```



```powershell
Get-GenXdevMCPToken -ProtectedFilePath 'C:\Keys\mcp.clixml'
```

## Parameter Details

### `-ProtectedFilePath <String>`

> Path of the DPAPI protected token file

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `"$env:LOCALAPPDATA\GenXdev\mcp-token.clixml"` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ProtectedFileOnly`

> Only report a token stored in the protected file

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

- `String. The token, or nothing when no token is configured.`
- `String`

## Related Links

- [Get-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AILLMSettings.md)
- [Get-SpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-SpeechToText.md)
- [Get-TextTranslation](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-TextTranslation.md)
- [Get-VectorSimilarity](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-VectorSimilarity.md)
- [Invoke-AILLMSettingsPrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-AILLMSettingsPrompt.md)
- [Invoke-WinMerge](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-WinMerge.md)
- [Merge-TranslationCache](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Merge-TranslationCache.md)
- [New-GenXdevMCPToken](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-GenXdevMCPToken.md)
- [New-LLMAudioChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMAudioChat.md)
- [New-LLMTextChat](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/New-LLMTextChat.md)
- [Receive-RealTimeSpeechToText](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Receive-RealTimeSpeechToText.md)
- [Set-AILLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-AILLMSettings.md)
- [Set-GenXdevCommandNotFoundAction](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Set-GenXdevCommandNotFoundAction.md)
- [Start-GenXdevMCPServer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Start-GenXdevMCPServer.md)
- [Test-DeepLinkImageFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-DeepLinkImageFile.md)
