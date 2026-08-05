# Register-AllFaces

> **SubModule:** GenXdev.AI.DeepStack | **Type:** Function | **Aliases:** `UpdateFaces`

## Synopsis

> Updates all face recognition profiles from image files in the faces directory.

## Description

This function updates the face recognition database with all images found in
the specified faces directory. The process involves:
1. Ensuring the face recognition service is running
2. Processing all images in each person's folder, registering all faces for
   that person with a single identifier (the folder name) in a batch operation
3. Supporting retry logic for failed registrations
Each person's folder can contain multiple images, and all images will be
registered under the same identifier (person name) in a single API call,
eliminating the need for _1, _2, etc. suffixes.


## Syntax

```powershell
Register-AllFaces [[-FacesDirectory] <String>] [[-MaxRetries] <Int32>] [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [-AutoConsent] [-AutoConsentAllPackages] [-ClearSession] [-Force] [-ForceRebuild] [-NoDockerInitialize] [-PreferencesDatabasePath <String>] [-RenameFailed] [-SessionOnly] [-ShowWindow] [-SkipSession] [-UseGPU] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-FacesDirectory` | String | ☐ | The directory containing face images<br>organized by  person folders. If not<br>specified, uses the  configured faces<br>directory preference. |
| `-MaxRetries` | Int32 | ☐ | Maximum number of retry attempts for failed<br>registrations |
| `-ContainerName` | String | ☐ | The name for the Docker container |
| `-VolumeName` | String | ☐ | The name for the Docker volume for persistent<br>storage |
| `-ServicePort` | Int32 | ☐ | The port number for the DeepStack service |
| `-HealthCheckTimeout` | Int32 | ☐ | Maximum time in seconds to wait for service <br>health check |
| `-HealthCheckInterval` | Int32 | ☐ | Interval in seconds between health check<br>attempts |
| `-ImageName` | String | ☐ | Custom Docker image name to use |
| `-NoDockerInitialize` | SwitchParameter | ☐ | Skip Docker Desktop initialization (used when<br>already called by parent function) |
| `-Force` | SwitchParameter | ☐ | Force re-registration of all faces |
| `-RenameFailed` | SwitchParameter | ☐ | Rename failed image files that could not be <br>processed due to no face found |
| `-ForceRebuild` | SwitchParameter | ☐ | Force rebuild of Docker container and remove<br>existing data |
| `-UseGPU` | SwitchParameter | ☐ | Use GPU-accelerated version (requires NVIDIA<br>GPU) |
| `-ShowWindow` | SwitchParameter | ☐ | Show Docker Desktop window during<br>initialization |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to Docker Desktop <br>installation and set persistent flag. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation and set persistent flag for all<br>packages. |
| `-SessionOnly` | SwitchParameter | ☐ | If specified, only use the session (do not<br>persist changes to preferences database). |
| `-ClearSession` | SwitchParameter | ☐ | If specified, clear the current session<br>preferences before use. |
| `-PreferencesDatabasePath` | String | ☐ | Path to the preferences database to use for<br>known faces root path. |
| `-SkipSession` | SwitchParameter | ☐ | If specified, skip session logic when<br>retrieving known faces root path. |

## Examples

### Register-AllFaces -FacesDirectory "b:\media\faces\" -MaxRetries 3 `     -ContainerName "deepstack_face_recognition" -VolumeName "deepstack_face_data" `     -ServicePort 5000 -HealthCheckTimeout 60 -HealthCheckInterval 3

```powershell
Register-AllFaces -FacesDirectory "b:\media\faces\" -MaxRetries 3 `
    -ContainerName "deepstack_face_recognition" -VolumeName "deepstack_face_data" `
    -ServicePort 5000 -HealthCheckTimeout 60 -HealthCheckInterval 3
```

### Register-AllFaces Uses the configured faces directory from Set-AIKnownFacesRootpath or defaults to "b:\media\faces\"

```powershell
Register-AllFaces
Uses the configured faces directory from Set-AIKnownFacesRootpath or defaults to "b:\media\faces\"
```

### updatefaces -RenameFailed ##############################################################################

```powershell
updatefaces -RenameFailed
##############################################################################
```

## Parameter Details

### `-FacesDirectory <String>`

> The directory containing face images organized by  person folders. If not specified, uses the  configured faces directory preference.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-MaxRetries <Int32>`

> Maximum number of retry attempts for failed registrations

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `3` |
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

> The name for the Docker volume for persistent storage

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

> Interval in seconds between health check attempts

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

### `-Force`

> Force re-registration of all faces

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-RenameFailed`

> Rename failed image files that could not be  processed due to no face found

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

> Force rebuild of Docker container and remove existing data

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

> If specified, only use the session (do not persist changes to preferences database).

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ClearSession`

> If specified, clear the current session preferences before use.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PreferencesDatabasePath <String>`

> Path to the preferences database to use for known faces root path.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DatabasePath` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipSession`

> If specified, skip session logic when retrieving known faces root path.

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

## Related Links

- [Compare-ImageFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Compare-ImageFaces.md)
- [Get-ImageDetectedFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedFaces.md)
- [Get-ImageDetectedObjects](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedObjects.md)
- [Get-ImageDetectedScenes](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-ImageDetectedScenes.md)
- [Get-RegisteredFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-RegisteredFaces.md)
- [Invoke-ImageEnhancement](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Invoke-ImageEnhancement.md)
- [Register-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Register-Face.md)
- [Unregister-AllFaces](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-AllFaces.md)
- [Unregister-Face](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Unregister-Face.md)
