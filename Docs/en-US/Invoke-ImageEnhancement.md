# Invoke-ImageEnhancement

> **SubModule:** GenXdev.AI.DeepStack | **Type:** Function | **Aliases:** `enhanceimage`

## Synopsis

> Enhances an image by enlarging it 4X while improving quality using DeepStack.

## Description

This function enhances an image by enlarging it to 4 times the original width
and height while simultaneously increasing the quality of the image. It uses
a local DeepStack image enhancement API running on a configurable port and
returns the enhanced image as base64 data or saves it to a file. The function
supports GPU acceleration and Docker container management.


## Syntax

```powershell
Invoke-ImageEnhancement -ImagePath <String> [[-OutputPath] <String>] [-AutoConsent] [-AutoConsentAllPackages] [-ContainerName <String>] [-Force] [-HealthCheckInterval <Int32>] [-HealthCheckTimeout <Int32>] [-ImageName <String>] [-NoDockerInitialize] [-ServicePort <Int32>] [-SessionOnly] [-ShowWindow] [-UseGPU] [-VolumeName <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ImagePath` | String | ✅ | The local path to the image file to enhance |
| `-OutputPath` | String | ☐ | Optional path where the enhanced image should<br>be  saved |
| `-NoDockerInitialize` | SwitchParameter | ☐ | Skip Docker initialization (used when already<br>called by parent function) |
| `-Force` | SwitchParameter | ☐ | Force rebuild of Docker container and remove <br>existing data |
| `-UseGPU` | SwitchParameter | ☐ | Use GPU-accelerated version (requires NVIDIA <br>GPU) |
| `-ContainerName` | String | ☐ | The name for the Docker container |
| `-VolumeName` | String | ☐ | The name for the Docker volume for persistent<br>storage |
| `-ServicePort` | Int32 | ☐ | The port number for the DeepStack service |
| `-HealthCheckTimeout` | Int32 | ☐ | Maximum time in seconds to wait for service <br>health check |
| `-HealthCheckInterval` | Int32 | ☐ | Interval in seconds between health check <br>attempts |
| `-ImageName` | String | ☐ | Custom Docker image name to use |
| `-ShowWindow` | SwitchParameter | ☐ | Show Docker Desktop window during<br>initialization |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to Docker Desktop <br>installation and set persistent flag. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation and set persistent flag for all<br>packages. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences |

## Examples

### Invoke-ImageEnhancement -ImagePath "C:\Users\YourName\small_photo.jpg" `                         -OutputPath "C:\Users\YourName\enhanced_photo.jpg" Enhances the image and saves it to the specified output path.

```powershell
Invoke-ImageEnhancement -ImagePath "C:\Users\YourName\small_photo.jpg" `
                        -OutputPath "C:\Users\YourName\enhanced_photo.jpg"
Enhances the image and saves it to the specified output path.
```

### enhanceimage "C:\photos\low_quality.jpg" Enhances the image and returns the base64 data and dimensions using alias.

```powershell
enhanceimage "C:\photos\low_quality.jpg"
Enhances the image and returns the base64 data and dimensions using alias.
```

### Invoke-ImageEnhancement -ImagePath "C:\photos\image.jpg" -UseGPU Enhances the image using GPU acceleration for faster processing.

```powershell
Invoke-ImageEnhancement -ImagePath "C:\photos\image.jpg" -UseGPU
Enhances the image using GPU acceleration for faster processing.
```

## Parameter Details

### `-ImagePath <String>`

> The local path to the image file to enhance

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | True (ByValue, ByPropertyName) |
| **Aliases** | `path`, `FullName`, `ImageFile`, `ImageFilePath` |
| **Accept wildcard characters?** | No |

<hr/>

### `-OutputPath <String>`

> Optional path where the enhanced image should be  saved

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `outfile`, `OutputFile`, `EnhancedImagePath` |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoDockerInitialize`

> Skip Docker initialization (used when already  called by parent function)

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

> Force rebuild of Docker container and remove  existing data

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ForceRebuild` |
| **Accept wildcard characters?** | No |

<hr/>

### `-UseGPU`

> Use GPU-accelerated version (requires NVIDIA  GPU)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ContainerName <String>`

> The name for the Docker container

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `'deepstack_face_recognition'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-VolumeName <String>`

> The name for the Docker volume for persistent  storage

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `'deepstack_face_data'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ServicePort <Int32>`

> The port number for the DeepStack service

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `5000` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-HealthCheckTimeout <Int32>`

> Maximum time in seconds to wait for service  health check

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `60` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-HealthCheckInterval <Int32>`

> Interval in seconds between health check  attempts

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `3` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ImageName <String>`

> Custom Docker image name to use

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ShowWindow`

> Show Docker Desktop window during initialization

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `sw` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsent`

> Automatically consent to Docker Desktop  installation and set persistent flag.

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

> Use alternative settings stored in session for  preferences

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

- [Compare-ImageFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Compare-ImageFaces.md)
- [Get-ImageDetectedFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedFaces.md)
- [Get-ImageDetectedObjects](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedObjects.md)
- [Get-ImageDetectedScenes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedScenes.md)
- [Get-RegisteredFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RegisteredFaces.md)
- [Register-AllFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Register-AllFaces.md)
- [Register-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Register-Face.md)
- [Unregister-AllFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-AllFaces.md)
- [Unregister-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-Face.md)
