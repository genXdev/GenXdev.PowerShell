# Invoke-SpectreConfirm

> **SubModule:** GenXdev.Helpers | **Type:** Function | **Aliases:** —

## Synopsis

> Displays a Spectre.Console confirmation prompt and returns the user's choice.

## Description

Uses Spectre.Console to present a confirmation dialog to the user with the
specified message. Returns $true if the user confirms, $false otherwise.


## Syntax

```powershell
Invoke-SpectreConfirm [[-Message] <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Message` | String | ☐ | The confirmation message to display to the<br>user |

## Examples

### Invoke-SpectreConfirm -Message "Are you sure you want to continue?" Presents a confirmation prompt with the specified message

```powershell
Invoke-SpectreConfirm -Message "Are you sure you want to continue?"
Presents a confirmation prompt with the specified message
```

## Parameter Details

### `-Message <String>`

> The confirmation message to display to the user

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [alignScript](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/alignScript.md)
- [Approve-NewTextFileContent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Approve-NewTextFileContent.md)
- [Assert-RefactorFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-RefactorFile.md)
- [Confirm-InstallationConsent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Confirm-InstallationConsent.md)
- [Convert-DotNetTypeToLLMType](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Convert-DotNetTypeToLLMType.md)
- [ConvertTo-HashTable](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-HashTable.md)
- [ConvertTo-LLMOpenAIApiFunctionDefinition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-LLMOpenAIApiFunctionDefinition.md)
- [Copy-IdenticalParamValues](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Copy-IdenticalParamValues.md)
- [EnsureGenXdev](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureGenXdev.md)
- [EnsureNuGetAssembly](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureNuGetAssembly.md)
- [GenerateMasonryLayoutHtml](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/GenerateMasonryLayoutHtml.md)
- [Get-AIDefaultLLMSettings](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-AIDefaultLLMSettings.md)
- [Get-BCP47LanguageDictionary](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-BCP47LanguageDictionary.md)
- [Get-DefaultWebLanguage](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-DefaultWebLanguage.md)
- [Get-JsonExampleFromSchema](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-JsonExampleFromSchema.md)
- [Get-LLMJsonOutput](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-LLMJsonOutput.md)
- [Get-PowerShellRoot](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-PowerShellRoot.md)
- [Get-WebLanguageDictionary](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WebLanguageDictionary.md)
- [Import-GenXdevModules](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Import-GenXdevModules.md)
- [Initialize-SearchPaths](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Initialize-SearchPaths.md)
- [Invoke-CommandFromToolCall](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-CommandFromToolCall.md)
- [Invoke-OnEachGenXdevModule](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-OnEachGenXdevModule.md)
- [Invoke-SpectreAsk](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SpectreAsk.md)
- [Invoke-SpectrePrompt](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SpectrePrompt.md)
- [Remove-JSONComments](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-JSONComments.md)
- [resetdefaultmonitor](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/resetdefaultmonitor.md)
- [ResolveInputObjectFileNames](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ResolveInputObjectFileNames.md)
- [Show-Verb](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Show-Verb.md)
- [Test-RefactorLLMSelection](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-RefactorLLMSelection.md)
- [Test-UnattendedMode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Test-UnattendedMode.md)
- [Write-SpectreLine](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-SpectreLine.md)
- [Write-SpectreMarkupLine](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Write-SpectreMarkupLine.md)
- [WriteFileOutput](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/WriteFileOutput.md)
