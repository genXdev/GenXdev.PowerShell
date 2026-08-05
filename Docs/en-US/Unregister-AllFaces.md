# Unregister-AllFaces

> **SubModule:** GenXdev.AI.DeepStack | **Type:** Function | **Aliases:** —

## Synopsis

> Removes all registered faces from the DeepStack face recognition system.

## Description

This function clears all registered faces from the DeepStack face recognition
database by removing all face files from the datastore directory and restarting
the service to reload an empty face registry. This is a destructive operation
that cannot be undone and will permanently remove all registered face data.


## Syntax

```powershell
Unregister-AllFaces [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [-AutoConsent] [-AutoConsentAllPackages] [-Force] [-ForceRebuild] [-NoDockerInitialize] [-SessionOnly] [-ShowWindow] [-UseGPU] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-Force` | SwitchParameter | ☐ | Bypass confirmation prompts when removing all<br>registered faces |
| `-NoDockerInitialize` | SwitchParameter | ☐ | Skip Docker Desktop initialization (used when<br>already called by parent function) |
| `-ForceRebuild` | SwitchParameter | ☐ | Force rebuild of Docker container and remove <br>existing data |
| `-UseGPU` | SwitchParameter | ☐ | Use GPU-accelerated version (requires NVIDIA<br>GPU) |
| `-ContainerName` | String | ☐ | The name for the Docker container |
| `-VolumeName` | String | ☐ | The name for the Docker volume for persistent<br>storage |
| `-ServicePort` | Int32 | ☐ | The port number for the DeepStack service |
| `-HealthCheckTimeout` | Int32 | ☐ | Maximum time in seconds to wait for service<br>health  check |
| `-HealthCheckInterval` | Int32 | ☐ | Interval in seconds between health check<br>attempts |
| `-ImageName` | String | ☐ | Custom Docker image name to use |
| `-ShowWindow` | SwitchParameter | ☐ | Show Docker Desktop window during<br>initialization |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to Docker Desktop <br>installation and set persistent flag. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation and set persistent flag for all<br>packages. |
| `-SessionOnly` | SwitchParameter | ☐ | Use alternative settings stored in session<br>for  preferences |

## Examples

### Unregister-AllFaces Removes all registered faces with confirmation prompt.

```powershell
Unregister-AllFaces
Removes all registered faces with confirmation prompt.
```

### Unregister-AllFaces -Force Removes all registered faces without confirmation prompt.

```powershell
Unregister-AllFaces -Force
Removes all registered faces without confirmation prompt.
```

### unregall -Force Uses alias to remove all faces without confirmation.

```powershell
unregall -Force
Uses alias to remove all faces without confirmation.
```

## Parameter Details

### `-Force`

> Bypass confirmation prompts when removing all  registered faces

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

> Skip Docker Desktop initialization (used when  already called by parent function)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ForceRebuild`

> Force rebuild of Docker container and remove  existing data

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-UseGPU`

> Use GPU-accelerated version (requires NVIDIA GPU)

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
| **Position?** | 0 |
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
| **Position?** | 1 |
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
| **Position?** | 2 |
| **Default value** | `5000` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-HealthCheckTimeout <Int32>`

> Maximum time in seconds to wait for service health  check

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 3 |
| **Default value** | `60` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-HealthCheckInterval <Int32>`

> Interval in seconds between health check attempts

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 4 |
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
| **Position?** | 5 |
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
- [Register-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Register-Face.md)
- [Unregister-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-Face.md)
