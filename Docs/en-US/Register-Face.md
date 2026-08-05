# Register-Face

> **SubModule:** GenXdev.AI.DeepStack | **Type:** Function | **Aliases:** —

## Synopsis

> Registers a new face with the DeepStack face recognition API.

## Description

This function registers a face image with the DeepStack face recognition API by
uploading the image to the local API endpoint. It ensures the DeepStack
service is running and validates the image file before upload. The function
includes retry logic, error handling, and cleanup on failure.


## Syntax

```powershell
Register-Face -Identifier <String> -ImagePath <String[]> [-AutoConsent] [-AutoConsentAllPackages] [-ContainerName <String>] [-Force] [-HealthCheckInterval <Int32>] [-HealthCheckTimeout <Int32>] [-ImageName <String>] [-NoDockerInitialize] [-ServicePort <Int32>] [-SessionOnly] [-ShowWindow] [-UseGPU] [-VolumeName <String>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Identifier` | String | ✅ | The unique identifier for the face  (e.g.,<br>person's name) |
| `-ImagePath` | String[] | ✅ | Array of local paths to image files  (png,<br>jpg, jpeg, or gif) |
| `-ContainerName` | String | ☐ | The name for the Docker container |
| `-VolumeName` | String | ☐ | The name for the Docker volume for persistent<br>storage |
| `-ServicePort` | Int32 | ☐ | The port number for the DeepStack service |
| `-HealthCheckTimeout` | Int32 | ☐ | Maximum time in seconds to wait for service <br>health check |
| `-HealthCheckInterval` | Int32 | ☐ | Interval in seconds between health check <br>attempts |
| `-ImageName` | String | ☐ | Custom Docker image name to use |
| `-NoDockerInitialize` | SwitchParameter | ☐ | Skip Docker initialization (used when already<br>called by parent function) |
| `-Force` | SwitchParameter | ☐ | Force rebuild of Docker container and remove <br>existing data |
| `-UseGPU` | SwitchParameter | ☐ | Use GPU-accelerated version (requires  NVIDIA<br>GPU) |
| `-ShowWindow` | SwitchParameter | ☐ | Show Docker Desktop window during<br>initialization |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to Docker Desktop <br>installation and set persistent flag. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation and set persistent flag for all<br>packages. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences |

## Examples

### Register-Face -Identifier "JohnDoe" -ImagePath @("C:\Users\YourName\faces\john1.jpg", "C:\Users\YourName\faces\john2.jpg")

```powershell
Register-Face -Identifier "JohnDoe" -ImagePath @("C:\Users\YourName\faces\john1.jpg", "C:\Users\YourName\faces\john2.jpg")
```

### Register-Face "JohnDoe" @("C:\Users\YourName\faces\john1.jpg", "C:\Users\YourName\faces\john2.jpg")

```powershell
Register-Face "JohnDoe" @("C:\Users\YourName\faces\john1.jpg", "C:\Users\YourName\faces\john2.jpg")
```

### Register-Face -Identifier "JohnDoe" -ImagePath "C:\Users\YourName\faces\john.jpg"

```powershell
Register-Face -Identifier "JohnDoe" -ImagePath "C:\Users\YourName\faces\john.jpg"
```

## Parameter Details

### `-Identifier <String>`

> The unique identifier for the face  (e.g., person's name)

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ImagePath <String[]>`

> Array of local paths to image files  (png, jpg, jpeg, or gif)

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

> Use GPU-accelerated version (requires  NVIDIA GPU)

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
- [Invoke-ImageEnhancement](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageEnhancement.md)
- [Register-AllFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Register-AllFaces.md)
- [Unregister-AllFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-AllFaces.md)
- [Unregister-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-Face.md)
