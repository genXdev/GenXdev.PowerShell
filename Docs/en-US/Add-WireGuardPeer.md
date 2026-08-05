# Add-WireGuardPeer

> **SubModule:** GenXdev.Windows.WireGuard | **Type:** Function | **Aliases:** —

## Synopsis

> Adds a new WireGuard VPN peer (client) configuration to the server.

## Description

This function adds a new peer to the WireGuard VPN server running in a Docker
container. It generates a new client configuration with a unique IP address,
creates necessary cryptographic keys, and returns the configuration details.
The function can optionally save the configuration to a file or generate a QR
code for easy mobile device setup. The function validates peer names, checks
for duplicates, and handles various error conditions gracefully.


## Syntax

```powershell
Add-WireGuardPeer -PeerName <String> [[-AllowedIPs] <String>] [[-DNS] <String>] [[-OutputPath] <String>] [[-ContainerName] <String>] [[-VolumeName] <String>] [[-ServicePort] <Int32>] [[-HealthCheckTimeout] <Int32>] [[-HealthCheckInterval] <Int32>] [[-ImageName] <String>] [[-PUID] <String>] [[-PGID] <String>] [[-TimeZone] <String>] [-AutoConsent] [-AutoConsentAllPackages] [-Bottom <Int32>] [-Centered] [-ClearSession] [-FocusWindow] [-Force] [-Fullscreen] [-Height <Int32>] [-Left <Int32>] [-NoBorders] [-NoDockerInitialize] [-RestoreFocus] [-Right <Int32>] [-SaveConfig] [-SendKeyDelayMilliSeconds <Int32>] [-SendKeyEscape] [-SendKeyHoldKeyboardFocus] [-SendKeyUseShiftEnter] [-SessionOnly] [-SetForeground] [-ShowQRCode] [-ShowWindow] [-SideBySide] [-SkipSession] [-Width <Int32>] [<CommonParameters>]
```

## Parameters

| Name | Type | Required | Description |
|:---|:---|:---:|:---|
| `-PeerName` | String | ✅ | A unique name for the peer |
| `-AllowedIPs` | String | ☐ | The IP ranges that will be routed through the<br>VPN |
| `-DNS` | String | ☐ | DNS servers to use for this peer |
| `-OutputPath` | String | ☐ | The path where the peer configuration file <br>should be saved |
| `-ContainerName` | String | ☐ | The name for the Docker container |
| `-VolumeName` | String | ☐ | The name for the Docker volume for persistent<br>storage |
| `-ServicePort` | Int32 | ☐ | The port number for the WireGuard service |
| `-HealthCheckTimeout` | Int32 | ☐ | Maximum time in seconds to wait for service <br>health check |
| `-HealthCheckInterval` | Int32 | ☐ | Interval in seconds between health check <br>attempts |
| `-ImageName` | String | ☐ | Custom Docker image name to use |
| `-PUID` | String | ☐ | User ID for permissions in the container |
| `-PGID` | String | ☐ | Group ID for permissions in the container |
| `-TimeZone` | String | ☐ | Timezone to use for the container |
| `-SaveConfig` | SwitchParameter | ☐ | Save the peer configuration to a file |
| `-ShowWindow` | SwitchParameter | ☐ | Show the WireGuard window when initializing<br>the service |
| `-NoBorders` | SwitchParameter | ☐ | Remove window borders when initializing the<br>service |
| `-Width` | Int32 | ☐ | Set the window width when initializing the<br>service |
| `-Height` | Int32 | ☐ | Set the window height when initializing the<br>service |
| `-Left` | Int32 | ☐ | Set the window left position when<br>initializing the service |
| `-Right` | Int32 | ☐ | Set the window right position when<br>initializing the service |
| `-Bottom` | Int32 | ☐ | Set the window bottom position when<br>initializing the service |
| `-Centered` | SwitchParameter | ☐ | Center the window when initializing the<br>service |
| `-Fullscreen` | SwitchParameter | ☐ | Start the service in fullscreen mode |
| `-RestoreFocus` | SwitchParameter | ☐ | Restore focus to the window after<br>initializing the service |
| `-SideBySide` | SwitchParameter | ☐ | Show the window side by side when<br>initializing the service |
| `-FocusWindow` | SwitchParameter | ☐ | Focus the window after initializing the<br>service |
| `-SetForeground` | SwitchParameter | ☐ | Set the window to foreground after<br>initializing the service |
| `-SendKeyEscape` | SwitchParameter | ☐ | Send Escape key to the window after<br>initializing the service |
| `-SendKeyHoldKeyboardFocus` | SwitchParameter | ☐ | Hold keyboard focus when sending keys after<br>initializing the service |
| `-SendKeyUseShiftEnter` | SwitchParameter | ☐ | Use Shift+Enter when sending keys after<br>initializing the service |
| `-SendKeyDelayMilliSeconds` | Int32 | ☐ | Delay in milliseconds when sending keys after<br>initializing the service |
| `-SessionOnly` | SwitchParameter | ☐ | Use session only for the WireGuard service |
| `-ClearSession` | SwitchParameter | ☐ | Clear session when initializing the service |
| `-SkipSession` | SwitchParameter | ☐ | Skip session when initializing the service |
| `-ShowQRCode` | SwitchParameter | ☐ | Generate QR code for easy mobile setup |
| `-NoDockerInitialize` | SwitchParameter | ☐ | Skip Docker initialization (used when already<br>called by parent function) |
| `-Force` | SwitchParameter | ☐ | Force rebuild of Docker container and remove <br>existing data |
| `-AutoConsent` | SwitchParameter | ☐ | Automatically consent to WireGuard<br>installation  and set persistent flag. |
| `-AutoConsentAllPackages` | SwitchParameter | ☐ | Automatically consent to third-party software<br>installation and set persistent flag for all<br>packages. |

## Examples

### Add-WireGuardPeer -PeerName "MyPhone" -AllowedIPs "0.0.0.0/0, ::/0" `     -DNS "1.1.1.1, 1.0.0.1" -SaveConfig -OutputPath `     "$env:USERPROFILE\WireGuardConfigs" -ShowQRCode -ContainerName "wireguard" `     -VolumeName "wireguard_data" -ServicePort 51839 -HealthCheckTimeout 60 `     -HealthCheckInterval 3 -ImageName "linuxserver/wireguard" -PUID "1000" `     -PGID "1000" -TimeZone "Etc/UTC"

```powershell
Add-WireGuardPeer -PeerName "MyPhone" -AllowedIPs "0.0.0.0/0, ::/0" `
    -DNS "1.1.1.1, 1.0.0.1" -SaveConfig -OutputPath `
    "$env:USERPROFILE\WireGuardConfigs" -ShowQRCode -ContainerName "wireguard" `
    -VolumeName "wireguard_data" -ServicePort 51839 -HealthCheckTimeout 60 `
    -HealthCheckInterval 3 -ImageName "linuxserver/wireguard" -PUID "1000" `
    -PGID "1000" -TimeZone "Etc/UTC"
```

### Add-WireGuardPeer "MyTablet" -ShowQRCode

```powershell
Add-WireGuardPeer "MyTablet" -ShowQRCode
```

## Parameter Details

### `-PeerName <String>`

> A unique name for the peer

| Property | Value |
|:---|:---|
| **Required?** | Yes |
| **Position?** | 0 |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-AllowedIPs <String>`

> The IP ranges that will be routed through the  VPN

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 1 |
| **Default value** | `'0.0.0.0/0, ::/0'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-DNS <String>`

> DNS servers to use for this peer

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 2 |
| **Default value** | `'1.1.1.1, 1.0.0.1'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-OutputPath <String>`

> The path where the peer configuration file  should be saved

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 3 |
| **Default value** | `"$env:USERPROFILE\WireGuardConfigs"` |
| **Accept pipeline input?** | False |
| **Aliases** | `outfile`, `OutputFile` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ContainerName <String>`

> The name for the Docker container

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 4 |
| **Default value** | `'wireguard'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-VolumeName <String>`

> The name for the Docker volume for persistent  storage

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 5 |
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
| **Position?** | 6 |
| **Default value** | `51839` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-HealthCheckTimeout <Int32>`

> Maximum time in seconds to wait for service  health check

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | 7 |
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
| **Position?** | 8 |
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
| **Position?** | 9 |
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
| **Position?** | 10 |
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
| **Position?** | 11 |
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
| **Position?** | 12 |
| **Default value** | `'Etc/UTC'` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-SaveConfig`

> Save the peer configuration to a file

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

> Show the WireGuard window when initializing the service

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

> Remove window borders when initializing the service

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

> Set the window width when initializing the service

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Height <Int32>`

> Set the window height when initializing the service

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | `-1` |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Left <Int32>`

> Set the window left position when initializing the service

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Right <Int32>`

> Set the window right position when initializing the service

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Bottom <Int32>`

> Set the window bottom position when initializing the service

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | *(none)* |
| **Accept wildcard characters?** | No |

<hr/>

### `-Centered`

> Center the window when initializing the service

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

> Start the service in fullscreen mode

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

> Restore focus to the window after initializing the service

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

> Show the window side by side when initializing the service

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

> Focus the window after initializing the service

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

> Set the window to foreground after initializing the service

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

> Send Escape key to the window after initializing the service

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

> Hold keyboard focus when sending keys after initializing the service

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

> Use Shift+Enter when sending keys after initializing the service

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

> Delay in milliseconds when sending keys after initializing the service

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `DelayMilliSeconds` |
| **Accept wildcard characters?** | No |

<hr/>

### `-SessionOnly`

> Use session only for the WireGuard service

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

> Clear session when initializing the service

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

> Skip session when initializing the service

| Property | Value |
|:---|:---|
| **Required?** | No |
| **Position?** | Named |
| **Default value** | *(none)* |
| **Accept pipeline input?** | False |
| **Aliases** | `FromPreferences` |
| **Accept wildcard characters?** | No |

<hr/>

### `-ShowQRCode`

> Generate QR code for easy mobile setup

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

- [EnsureWireGuard](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/EnsureWireGuard.md)
- [Get-WireGuardPeerQRCode](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WireGuardPeerQRCode.md)
- [Get-WireGuardPeers](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WireGuardPeers.md)
- [Get-WireGuardStatus](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Get-WireGuardStatus.md)
- [Remove-WireGuardPeer](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Remove-WireGuardPeer.md)
- [Reset-WireGuardConfiguration](https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/Reset-WireGuardConfiguration.md)
