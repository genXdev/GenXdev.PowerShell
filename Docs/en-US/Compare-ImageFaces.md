# Compare-ImageFaces

> **SubModule:** GenXdev.AI.DeepStack | **Type:** Function | **Aliases:** `comparefaces`

## Synopsis

> Compares faces in two different images and returns their similarity using
DeepStack.

## Description

This function compares faces between two images to determine similarity. It
uses a local DeepStack face match API running on a configurable port and
returns a similarity score between 0.0 and 1.0. This is typically used for
matching identity documents with pictures of a person or verifying if two
photos show the same person.


## Syntax

```powershell
Compare-ImageFaces -ImagePath1 <String> -ImagePath2 <String> [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [-AutoConsent] [-AutoConsentAllPackages] [-Force] [-NoDockerInitialize] [-SessionOnly] [-ShowWindow] [-UseGPU] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-ImagePath1` | String | ✅ | The local path to the first image file to<br>compare |
| `-ImagePath2` | String | ✅ | The local path to the second image file to<br>compare |
| `-ContainerName` | String | ☐ | The name for the Docker container |
| `-VolumeName` | String | ☐ | The name for the Docker volume for persistent<br>storage |
| `-ServicePort` | Int32 | ☐ | The port number for the DeepStack service |
| `-HealthCheckTimeout` | Int32 | ☐ | Maximum time in seconds to wait for service <br>health check |
| `-HealthCheckInterval` | Int32 | ☐ | Interval in seconds between health check <br>attempts |
| `-ImageName` | String | ☐ | Custom Docker image name to use |
| `-NoDockerInitialize` | SwitchParameter | ☐ | Skip Docker initialization (used when already<br>called by parent function) |
| `-Force` | SwitchParameter | ☐ | Force rebuild of Docker container and remove <br>existing data |
| `-UseGPU` | SwitchParameter | ☐ | Use GPU-accelerated version (requires NVIDIA <br>GPU) |
| `-ShowWindow` | SwitchParameter | ☐ | Show Docker Desktop window during<br>initialization |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to Docker Desktop <br>installation and set persistent flag. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation and set persistent flag for all<br>packages. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences |

## Examples

### Compare-ImageFaces -ImagePath1 "C:\Users\YourName\photo1.jpg" `                    -ImagePath2 "C:\Users\YourName\photo2.jpg" Compares faces between two images using default settings.

```powershell
Compare-ImageFaces -ImagePath1 "C:\Users\YourName\photo1.jpg" `
                   -ImagePath2 "C:\Users\YourName\photo2.jpg"
Compares faces between two images using default settings.
```

### comparefaces "C:\docs\id_photo.jpg" "C:\photos\person.jpg" -UseGPU Compares faces using GPU acceleration for identity verification with alias and positional parameters.

```powershell
comparefaces "C:\docs\id_photo.jpg" "C:\photos\person.jpg" -UseGPU
Compares faces using GPU acceleration for identity verification with alias and
positional parameters.
```

## Parameter Details

### `-ImagePath1 <String>`

> The local path to the first image file to compare

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ImagePath2 <String>`

> The local path to the second image file to compare

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 1 |
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
| **Position?** | 2 |
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
| **Position?** | 3 |
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
| **Position?** | 4 |
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
| **Position?** | 5 |
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
| **Position?** | 6 |
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
| **Position?** | 7 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
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

## Outputs

- `Collections.Hashtable`

## Related Links

- [Get-ImageDetectedFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedFaces.md)
- [Get-ImageDetectedObjects](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedObjects.md)
- [Get-ImageDetectedScenes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedScenes.md)
- [Get-RegisteredFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RegisteredFaces.md)
- [Invoke-ImageEnhancement](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageEnhancement.md)
- [Register-AllFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Register-AllFaces.md)
- [Register-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Register-Face.md)
- [Unregister-AllFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-AllFaces.md)
- [Unregister-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-Face.md)
