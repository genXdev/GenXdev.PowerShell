# Get-WireGuardStatus

> **SubModule:** GenXdev.Windows.WireGuard | **Type:** Function | **Aliases:** —

## Synopsis

> Gets detailed status information about the WireGuard VPN server.

## Description

This function retrieves detailed status information about the WireGuard VPN
server running in a Docker container, including interface details, listening
port, connected peers, and server health. It provides comprehensive information
about the WireGuard service including server status, peer counts, uptime, and
network configuration details.


## Syntax

```powershell
Get-WireGuardStatus [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [[-PUID] <String>] [[-PGID] <String>] [[-TimeZone] <String>] [[-Width] <Int32>] [[-Height] <Int32>] [[-Left] <Int32>] [[-Right] <Int32>] [[-Bottom] <Int32>] [[-SendKeyDelayMilliSeconds] <Int32>] [-AutoConsent] [-AutoConsentAllPackages] [-Centered] [-ClearSession] [-FocusWindow] [-Force] [-Fullscreen] [-NoBorders] [-NoDockerInitialize] [-RestoreFocus] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-ShowWindow] [-SideBySide] [-SkipSession] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-NoDockerInitialize` | SwitchParameter | ☐ | Skip Docker initialization (used when already<br>called by parent function) |
| `-Force` | SwitchParameter | ☐ | Force rebuild of Docker container and remove<br>existing data |
| `-ContainerName` | String | ☐ | The name for the Docker container |
| `-VolumeName` | String | ☐ | The name for the Docker volume for persistent<br>storage |
| `-ServicePort` | Int32 | ☐ | The port number for the WireGuard service |
| `-HealthCheckTimeout` | Int32 | ☐ | Maximum time in seconds to wait for service<br>health check |
| `-HealthCheckInterval` | Int32 | ☐ | Interval in seconds between health check<br>attempts |
| `-ImageName` | String | ☐ | Custom Docker image name to use |
| `-PUID` | String | ☐ | User ID for permissions in the container |
| `-PGID` | String | ☐ | Group ID for permissions in the container |
| `-TimeZone` | String | ☐ | Timezone to use for the container |
| `-ShowWindow` | SwitchParameter | ☐ | Show the window when running the container<br>(pass-through) |
| `-NoBorders` | SwitchParameter | ☐ | Remove window borders (pass-through) |
| `-Width` | Int32 | ☐ | Window width in characters or pixels<br>(pass-through) |
| `-Height` | Int32 | ☐ | Window height in characters or pixels<br>(pass-through) |
| `-Left` | Int32 | ☐ | Window left position (pass-through) |
| `-Right` | Int32 | ☐ | Window right position (pass-through) |
| `-Bottom` | Int32 | ☐ | Window bottom position (pass-through) |
| `-Centered` | SwitchParameter | ☐ | Center the window (pass-through) |
| `-Fullscreen` | SwitchParameter | ☐ | Open window in fullscreen mode (pass-through) |
| `-RestoreFocus` | SwitchParameter | ☐ | Restore focus to window after operation<br>(pass-through) |
| `-SideBySide` | SwitchParameter | ☐ | Show side-by-side window (pass-through) |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the window after opening (pass-through) |
| `-SetForeground` | SwitchParameter | ☐ | Set window to foreground (pass-through) |
| `-SendKeyEscape` | SwitchParameter | ☐ | Send Escape key to window (pass-through) |
| `-SendKeyHoldKeyboardFocus` | SwitchParameter | ☐ | Hold keyboard focus when sending keys<br>(pass-through) |
| `-SendKeyUseShiftEnter` | SwitchParameter | ☐ | Use Shift+Enter when sending keys<br>(pass-through) |
| `-SendKeyDelayMilliSeconds` | Int32 | ☐ | Delay in milliseconds between sending keys<br>(pass-through) |
| `-SessionOnly` | SwitchParameter | ☐ | Session only mode (pass-through) |
| `-ClearSession` | SwitchParameter | ☐ | Clear session data (pass-through) |
| `-SkipSession` | SwitchParameter | ☐ | Skip session initialization (pass-through) |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to WireGuard<br>installation  and set persistent flag. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation and set persistent flag for all<br>packages. |

## Examples

### Get-WireGuardStatus Returns the status of the WireGuard server with default settings.

```powershell
Get-WireGuardStatus
Returns the status of the WireGuard server with default settings.
```

### Get-WireGuardStatus -NoDockerInitialize -ContainerName "custom_wireguard" Retrieves status for a custom container without initializing Docker.

```powershell
Get-WireGuardStatus -NoDockerInitialize -ContainerName "custom_wireguard"
Retrieves status for a custom container without initializing Docker.
```

## Parameter Details

### `-NoDockerInitialize`

> Skip Docker initialization (used when already called by parent function)

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

> Force rebuild of Docker container and remove existing data

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `ForceRebuild` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ContainerName <String>`

> The name for the Docker container

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 0 |
| **Default value** | `'wireguard'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-VolumeName <String>`

> The name for the Docker volume for persistent storage

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `'wireguard_data'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ServicePort <Int32>`

> The port number for the WireGuard service

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | `51839` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-HealthCheckTimeout <Int32>`

> Maximum time in seconds to wait for service health check

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
| **Default value** | `'linuxserver/wireguard'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PUID <String>`

> User ID for permissions in the container

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 6 |
| **Default value** | `'1000'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-PGID <String>`

> Group ID for permissions in the container

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 7 |
| **Default value** | `'1000'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-TimeZone <String>`

> Timezone to use for the container

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 8 |
| **Default value** | `'Etc/UTC'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-ShowWindow`

> Show the window when running the container (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-NoBorders`

> Remove window borders (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `nb` |
| **Accept wildcard characters?** | No |

<hr/>

### `-Width <Int32>`

> Window width in characters or pixels (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 9 |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Height <Int32>`

> Window height in characters or pixels (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 10 |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Left <Int32>`

> Window left position (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 11 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Right <Int32>`

> Window right position (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 12 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Bottom <Int32>`

> Window bottom position (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 13 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Centered`

> Center the window (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Fullscreen`

> Open window in fullscreen mode (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fs` |
| **Accept wildcard characters?** | No |

<hr/>

### `-RestoreFocus`

> Restore focus to window after operation (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `rf`, `bg` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SideBySide`

> Show side-by-side window (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `sbs` |
| **Accept wildcard characters?** | No |

<hr/>

### `-FocusWindow`

> Focus the window after opening (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fw`, `focus` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SetForeground`

> Set window to foreground (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `fg` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyEscape`

> Send Escape key to window (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `Escape` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyHoldKeyboardFocus`

> Hold keyboard focus when sending keys (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `HoldKeyboardFocus` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyUseShiftEnter`

> Use Shift+Enter when sending keys (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `UseShiftEnter` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SendKeyDelayMilliSeconds <Int32>`

> Delay in milliseconds between sending keys (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 14 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DelayMilliSeconds` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Session only mode (pass-through)

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

> Clear session data (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SkipSession`

> Skip session initialization (pass-through)

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

### `-AutoConsent`

> Automatically consent to WireGuard installation  and set persistent flag.

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

## Related Links

- [Add-WireGuardPeer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Add-WireGuardPeer.md)
- [EnsureWireGuard](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWireGuard.md)
- [Get-WireGuardPeerQRCode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WireGuardPeerQRCode.md)
- [Get-WireGuardPeers](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WireGuardPeers.md)
- [Remove-WireGuardPeer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-WireGuardPeer.md)
- [Reset-WireGuardConfiguration](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Reset-WireGuardConfiguration.md)
