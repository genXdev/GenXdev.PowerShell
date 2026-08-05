# Copy-IdenticalParamValues

> **SubModule:** GenXdev.Helpers | **Type:** Cmdlet | **Aliases:** —

## Synopsis

> Copies parameter values from bound parameters to a new hashtable based on
another function's possible parameters.

## Description

* This cmdlet creates a new hashtable containing only the parameter values
  that match the parameters defined in the specified target function.
* The resulting hashtable can then be used to invoke the function using
  PowerShell splatting.
* Switch parameters are only included in the result if they were explicitly
  provided and set to $true in the bound parameters.
* Non-present switch parameters are excluded from the result to maintain
  proper parameter semantics.


## Syntax

```powershell
Copy-IdenticalParamValues -BoundParameters <Object[]> -FunctionName <String> [[-DefaultValues] <Object>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-BoundParameters` | Object[] | ✅ | Source bound parameters to copy from |
| `-FunctionName` | String | ✅ | Target function name to filter parameters |
| `-DefaultValues` | Object | ☐ | Default values for parameters |

## Examples

### Examples 1

```powershell
function Test-Function {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true)]
        [string] $Path,
        [Parameter(Mandatory = $false)]
        [switch] $Recurse
    )

    $params = GenXdev\Copy-IdenticalParamValues `
        -BoundParameters $PSBoundParameters `
        -FunctionName 'Get-ChildItem'

    Get-ChildItem @params
}
```

Demonstrates copying bound parameters for use with splatting.

## Parameter Details

### `-BoundParameters <Object[]>`

> Source bound parameters to copy from

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-FunctionName <String>`

> Target function name to filter parameters

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DefaultValues <Object>`

> Default values for parameters

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

- [alignScript](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/alignScript.md)
- [Approve-NewTextFileContent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Approve-NewTextFileContent.md)
- [Assert-RefactorFile](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Assert-RefactorFile.md)
- [Confirm-InstallationConsent](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Confirm-InstallationConsent.md)
- [Convert-DotNetTypeToLLMType](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Convert-DotNetTypeToLLMType.md)
- [ConvertTo-HashTable](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-HashTable.md)
- [ConvertTo-LLMOpenAIApiFunctionDefinition](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/ConvertTo-LLMOpenAIApiFunctionDefinition.md)
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
- [Invoke-SpectreConfirm](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-SpectreConfirm.md)
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
