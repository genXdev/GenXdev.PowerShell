###############################################################################
<#
.SYNOPSIS
Ensures WireGuard VPN service is installed and running via Docker container.

.DESCRIPTION
This function sets up and manages the WireGuard VPN service using Docker
Desktop. It automatically ensures Docker Desktop is running, pulls the latest
WireGuard Docker image, creates persistent storage volumes, and manages the
container lifecycle including health monitoring and restart capabilities.

WireGuard is a simple, fast, and modern VPN that utilizes state-of-the-art
cryptography. It offers superior performance and simplicity compared to
traditional VPN solutions like OpenVPN, with minimal configuration overhead
and excellent cross-platform support.

.LICENSE
Copyright (C) 2026 René Vaessen / GenXdev

This program is free software: you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation, either version 3 of the License, or
(at your option) any later version.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with this program. If not, see <https://www.gnu.org/licenses/gpl-3.0.txt>.

.PARAMETER ContainerName
The name for the Docker container. Default: "wireguard"

.PARAMETER VolumeName
The name for the Docker volume for persistent storage of configuration files
and client certificates. Default: "wireguard_data"

.PARAMETER ServicePort
The UDP port number for the WireGuard service to listen on. Must be between
1-65535. Default: 51839

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check before timing out.
Must be between 10-300 seconds. Default: 60

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts during startup validation.
Must be between 1-10 seconds. Default: 3

.PARAMETER ImageName
Custom Docker image name to use instead of the default. If not specified,
uses the official "linuxserver/wireguard" image from Docker Hub.

.PARAMETER PUID
User ID for file permissions inside the container. Should match your host
system user ID for proper file access. Default: "1000"

.PARAMETER PGID
Group ID for file permissions inside the container. Should match your host
system group ID for proper file access. Default: "1000"

.PARAMETER TimeZone
Timezone identifier to use for container logging and timestamps. Uses standard
timezone database format. Default: "Etc/UTC"

.PARAMETER Force
Forces complete rebuilding of Docker container and removes all existing data.
This will stop and remove existing containers and volumes, pull the latest
WireGuard image, and create a fresh container with clean configuration.

.EXAMPLE
EnsureWireGuard

.EXAMPLE
EnsureWireGuard -ContainerName "my_wireguard" -ServicePort 51821

.EXAMPLE
EnsureWireGuard -VolumeName "custom_vpn_data" -HealthCheckTimeout 120

.EXAMPLE
EnsureWireGuard -PUID 1001 -PGID 1001 -TimeZone "America/New_York"

.EXAMPLE
EnsureWireGuard -Force

.NOTES
To generate client configurations after setup:
- Run: docker exec -it wireguard /app/show-peer 1

For Android 10 and above:
- Install the official WireGuard app from Google Play Store
- Scan the QR code or import the config file to connect

For more information, see: https://www.wireguard.com/
###############################################################################>
function EnsureWireGuard {

    [CmdletBinding()]
    [OutputType([System.Boolean])]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'wireguard',
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('The name for the Docker volume for persistent ' +
                'storage')
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'wireguard_data',
        #######################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The port number for the WireGuard service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 51839,
        #######################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service ' +
                'health check')
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'Interval in seconds between health check attempts'
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName = 'linuxserver/wireguard',
        #######################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = 'User ID for permissions in the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PUID = '1000',
        #######################################################################
        [Parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = 'Group ID for permissions in the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PGID = '1000',
        #######################################################################
        [Parameter(
            Position = 8,
            Mandatory = $false,
            HelpMessage = 'Timezone to use for the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $TimeZone = 'Etc/UTC',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show Docker Desktop window during initialization'
        )]
        [switch] $ShowWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Removes the borders of the window'
        )]
        [Alias('nb')]
        [switch] $NoBorders,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial width of the window'
        )]
        [int] $Width = -1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The initial height of the window'
        )]
        [int] $Height = -1,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the left side of the screen'
        )]
        [switch] $Left,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the right side of the screen'
        )]
        [switch] $Right,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window on the bottom side of the screen'
        )]
        [switch] $Bottom,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Place window in the center of the screen'
        )]
        [switch] $Centered,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximize the window'
        )]
        [Alias('fs')]
        [switch] $Fullscreen,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore PowerShell window focus'
        )]
        [Alias('rf', 'bg')]
        [switch] $RestoreFocus,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Will either set the window fullscreen on a ' +
                'different monitor than Powershell, or side by side with ' +
                'Powershell on the same monitor')
        )]
        [Alias('sbs')]
        [switch] $SideBySide,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening'
        )]
        [Alias('fw','focus')]
        [switch] $FocusWindow,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after opening'
        )]
        [Alias('fg')]
        [switch] $SetForeground,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Escape control characters and modifiers when sending keys'
        )]
        [Alias('Escape')]
        [switch] $SendKeyEscape,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus on target window when sending keys'
        )]
        [Alias('HoldKeyboardFocus')]
        [switch] $SendKeyHoldKeyboardFocus,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter instead of Enter when sending keys'
        )]
        [Alias('UseShiftEnter')]
        [switch] $SendKeyUseShiftEnter,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Delay between different input strings in ' +
                'milliseconds when sending keys')
        )]
        [Alias('DelayMilliSeconds')]
        [int] $SendKeyDelayMilliSeconds,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only auto consent during session')
        )]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Clear alternative settings stored in session for ' +
                'AI preferences')
        )]
        [switch] $ClearSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Store settings only in persistent preferences ' +
                'without affecting session')
        )]
        [Alias('FromPreferences')]
        [switch] $SkipSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force rebuild of Docker container and remove ' +
                'existing data')
        )]
        [Alias('ForceRebuild')]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to WireGuard / Docker ' +
                'installation and set persistent flag.')
        )]
        [switch] $AutoConsent,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages
        #######################################################################

    )    begin {

        # set script-scoped variables from parameters for container management
    $script:wireguardContainerName = $ContainerName

    # set docker image name for pulling and container creation
    $script:wireguardImageName = $ImageName

    # set script-scoped variables for docker volume and networking
    $script:wireguardVolumeName = $VolumeName

    # set script-scoped variables for service configuration
    $script:wireguardServicePort = $ServicePort

    # set script-scoped variables for health monitoring timeouts
    $script:wireguardHealthCheckTimeout = $HealthCheckTimeout

    # set script-scoped variable for health check retry intervals
    $script:wireguardHealthCheckInterval = $HealthCheckInterval

    # set script-scoped variables for container environment settings
    $script:wireguardPuid = $PUID

    $script:wireguardPgid = $PGID

    $script:wireguardTimezone = $TimeZone

    # store original location for cleanup at the end of the function
    $script:wireguardOriginalLocation = (Microsoft.PowerShell.Management\Get-Location).Path

        #######################################################################
        <#
        .SYNOPSIS
        Tests if Docker is available and responsive to commands.

        .DESCRIPTION
        Verifies Docker Desktop is running by attempting to query the Docker
        version. Returns true if Docker responds successfully, false otherwise.
        #>
        function Test-DockerAvailability {

            try {

                # attempt to get docker version to verify docker is running
                $null = docker version --format '{{.Server.Version}}' 2>$null

                return $LASTEXITCODE -eq 0
            }
            catch {

                return $false
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Tests if a Docker image exists locally.

        .DESCRIPTION
        Queries Docker for the existence of a specific image by name. Returns
        true if the image is found locally, false if not found or on error.

        .PARAMETER ImageName
        The Docker image name to search for in the local image repository.
        #>
        function Test-DockerImage {

            param([string]$ImageName)

            try {

                # query docker for existing images matching the specified name
                $images = docker images $ImageName --format '{{.Repository}}' `
                    2>$null

                return -not [string]::IsNullOrWhiteSpace($images)
            }
            catch {

                return $false
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Tests if a Docker container exists (running or stopped).

        .DESCRIPTION
        Searches for a Docker container by exact name match, including both
        running and stopped containers. Returns true if found, false otherwise.

        .PARAMETER ContainerName
        The exact container name to search for in Docker container list.
        #>
        function Test-DockerContainer {

            param([string]$ContainerName)

            try {

                # search for containers with exact name match including stopped ones
                $containers = docker ps -a --filter "name=^${ContainerName}$" `
                    --format '{{.ID}}' 2>$null

                return -not [string]::IsNullOrWhiteSpace($containers)
            }
            catch {

                return $false
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Tests if a Docker container is currently running.

        .DESCRIPTION
        Checks specifically for running containers with the given name. Returns
        true if the container exists and is actively running, false otherwise.

        .PARAMETER ContainerName
        The exact container name to check for running status.
        #>
        function Test-DockerContainerRunning {

            param([string]$ContainerName)

            try {

                # search for running containers with exact name match
                $containers = docker ps --filter "name=^${ContainerName}$" `
                    --format '{{.ID}}' 2>$null

                return -not [string]::IsNullOrWhiteSpace($containers)
            }
            catch {

                return $false
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Safely removes a Docker container with proper error handling.

        .DESCRIPTION
        Stops and removes a Docker container if it exists. Uses ShouldProcess
        for confirmation and provides verbose logging. Handles errors gracefully
        without throwing exceptions.

        .PARAMETER ContainerName
        The name of the container to stop and remove from Docker.
        #>
        function Remove-DockerContainer {

            [CmdletBinding(SupportsShouldProcess)]
            param([string]$ContainerName)

            try {

                # check if container exists before attempting removal
                if (Test-DockerContainer $ContainerName) {

                    if ($PSCmdlet.ShouldProcess($ContainerName,
                            'Stop and remove Docker container')) {

                        # output verbose information about container removal
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "Stopping and removing container: $ContainerName"

                        # stop the container gracefully before removal
                        $null = docker stop $ContainerName 2>$null

                        # remove the container completely from docker
                        $null = docker rm $ContainerName 2>$null
                    }
                }
            }
            catch {

                # warn about container removal failures without throwing
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Failed to remove container ${ContainerName}: $_"
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Safely removes a Docker volume with proper error handling.

        .DESCRIPTION
        Removes a Docker volume if it exists. Uses ShouldProcess for
        confirmation and provides verbose logging. Handles errors gracefully
        without throwing exceptions.

        .PARAMETER VolumeName
        The name of the Docker volume to remove from the system.
        #>
        function Remove-DockerVolume {

            [CmdletBinding(SupportsShouldProcess)]

            param([string]$VolumeName)

            try {

                if ($PSCmdlet.ShouldProcess($VolumeName,
                        'Remove Docker volume')) {

                    # output verbose information about volume removal
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Removing Docker volume: $VolumeName"

                    # remove the docker volume and discard output
                    $null = docker volume rm $VolumeName 2>$null
                }
            }
            catch {

                # warn about volume removal failures without throwing
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Failed to remove volume ${VolumeName}: $_"
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Tests if the WireGuard service is healthy and responding.

        .DESCRIPTION
        Performs health checks on the WireGuard container by examining container
        logs for startup indicators and checking if the service port is
        listening. Returns true if healthy, false otherwise.
        #>
        function Test-ServiceHealth {
            [CmdletBinding()]
            [OutputType([System.Boolean])]
            param()
            try {

                # first check if container is running before health tests
                $containerRunning = Test-DockerContainerRunning `
                    $script:wireguardContainerName

                if (-not $containerRunning) {

                    return $false
                }

                # check container logs for successful startup messages
                $logs = docker logs $script:wireguardContainerName 2>&1

                # look for indications that wireguard is running properly
                # linuxserver/wireguard outputs these specific messages when ready
                if ($logs -match 'All tunnels are now active' -or
                    $logs -match '\[ls\.io-init\] done\.' -or
                    $logs -match 'ip link add wg0 type wireguard') {

                    # log successful health check for debugging
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'WireGuard service health check passed'

                    return $true
                }

                # alternatively check if the port is listening using netstat
                $netstatOutput = & netstat -an |
                    Microsoft.PowerShell.Utility\Select-String `
                        -Pattern ":$($script:wireguardServicePort) "

                if (-not [string]::IsNullOrEmpty($netstatOutput)) {

                    # log successful health check for debugging
                    Microsoft.PowerShell.Utility\Write-Verbose `
                    ('WireGuard service health check passed ' +
                        '(port is listening)')

                    return $true
                }

                return $false
            }
            catch {

                # log failed health check with error details for debugging
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "WireGuard service health check failed: $_"

                return $false
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Waits for the WireGuard service to become healthy and ready.

        .DESCRIPTION
        Repeatedly checks service health until it becomes ready or timeout is
        reached. Uses configurable timeout and interval settings for retry
        logic. Returns true if service becomes ready, false on timeout.
        #>
        function Wait-ServiceReady {
            [CmdletBinding()]
            [OutputType([System.Boolean])]
            param()
            # output verbose information about waiting for service readiness
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Waiting for WireGuard service to become ready...'

            # initialize retry counter for health check attempts
            $retryCount = 0

            # calculate maximum retry attempts based on timeout and interval
        $maxRetries = [math]::Floor($script:wireguardHealthCheckTimeout / `
            $script:wireguardHealthCheckInterval)

            while ($retryCount -lt $maxRetries) {

                # test service health and return success if ready
                if (Test-ServiceHealth) {

                    # log successful service readiness
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'WireGuard service is ready and responding'

                    return $true
                }

                # increment retry counter for next attempt
                $retryCount++

                # output verbose information about retry attempt progress
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Service not ready yet, attempt $retryCount/$maxRetries..."

                # wait between health check attempts as configured
                Microsoft.PowerShell.Utility\Start-Sleep `
                    -Seconds $script:wireguardHealthCheckInterval
            }

            # warn about service readiness timeout after all retries
            Microsoft.PowerShell.Utility\Write-Warning `
            ('WireGuard service did not become ready within ' +
                "$script:wireguardHealthCheckTimeout seconds")

            return $false
        }
        #######################################################################
        <#
        .SYNOPSIS
        Gets a list of existing WireGuard peer from the container.

        .DESCRIPTION
        Queries the WireGuard container for existing peer configurations by
        examining the /config directory structure. Returns an array of peer
        names found in the container.
        #>
        function Get-ExistingPeer {
            try {
                # list peer directories in the container's config folder
                $peerDirs = docker exec $script:wireguardContainerName sh -c "ls -d /config/peer_* 2>/dev/null | grep -o 'peer_[^/]*' | sed 's/peer_//'" 2>$null
                if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($peerDirs)) {
                    # split the output into individual peer names
                    $peers = $peerDirs -split "`n" |
                        Microsoft.PowerShell.Core\Where-Object { -not [string]::IsNullOrWhiteSpace($_) } |
                        Microsoft.PowerShell.Core\ForEach-Object { $_.Trim() }
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Found existing peer: $($peers -join ', ')"
                    return $peers
                }
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'No existing peer found'
                return @()
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Failed to get existing peer: $_"
                return @()
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Checks the status of a WireGuard peer and activates it if inactive.

        .DESCRIPTION
        Uses the container's /app/show-peer script to check peer status and
        attempts to activate inactive peers by restarting the WireGuard service
        or reloading the configuration files.

        .PARAMETER PeerName
        The name of the peer to check and potentially activate.
        #>
        function Enable-PeerIfNeeded {
            [CmdletBinding()]
            [OutputType([System.Boolean])]

            param([string]$PeerName)

            try {

                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Checking status of peer: $PeerName"

                # check peer status using container's show-peer script
                $peerStatus = docker exec $script:wireguardContainerName /app/show-peer $PeerName 2>&1

                # check if peer is marked as inactive
                if ($peerStatus -match 'is not active') {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Peer '$PeerName' is inactive, attempting to activate..."

                    # try multiple approaches to activate the peer

                    # approach 1: restart the entire container to reload all configs
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "Restarting WireGuard container to reload configurations..."

                    docker restart $script:wireguardContainerName 2>&1

                    if ($LASTEXITCODE -eq 0) {

                        # wait for container to fully restart
                        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 15

                        # wait for service to become ready after restart
                        $serviceReady = Wait-ServiceReady

                        if ($serviceReady) {

                            # check peer status again after container restart
                            $newStatus = docker exec $script:wireguardContainerName /app/show-peer $PeerName 2>&1

                            if ($newStatus -notmatch 'is not active') {

                                Microsoft.PowerShell.Utility\Write-Verbose `
                                    "✅ Peer '$PeerName' is now active after container restart"

                                return $true
                            }
                        }
                    }

                    Microsoft.PowerShell.Utility\Write-Warning `
                        ("Peer '$PeerName' appears to be configured but inactive. " +
                         "This may be normal for peers that haven't connected yet, " +
                         "or the peer configuration may need to be regenerated.")

                    return $false
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        "✅ Peer '$PeerName' status check completed"

                    return $true
                }
            }
            catch {

                Microsoft.PowerShell.Utility\Write-Warning `
                    "Failed to check/activate peer '${PeerName}': $_"

                return $false
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Resets the WireGuard server configuration to include all existing peer.

        .DESCRIPTION
        This function resets the main WireGuard server configuration file
        (/config/wg_confs/wg0.conf) to include all peer configurations found
        in the persistent storage, then restarts the WireGuard interface.
        #>
        function Reset-WireGuardConfiguration {
            [CmdletBinding(SupportsShouldProcess)]
            [OutputType([System.Boolean])]
            param()
            try {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Resetting WireGuard configuration to include all existing peer..."
                # get list of existing peer
                $existingPeer = Get-ExistingPeer
                if ($existingPeer.Count -eq 0) {
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'No peer to add to configuration'
                    return $true
                }
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Found $($existingPeer.Count) peer(s) to include in configuration"
                # read the current server configuration
                $serverConfig = docker exec $script:wireguardContainerName cat /config/wg_confs/wg0.conf 2>$null
                if ($LASTEXITCODE -ne 0) {
                    Microsoft.PowerShell.Utility\Write-Warning "Could not read server configuration"
                    return $false
                }
                # split into server section and peer sections
                $configLines = $serverConfig -split "`n"
                $serverSection = @()
                foreach ($line in $configLines) {
                    if ($line.Trim() -match '^\[Peer\]') {
                        break
                    }
                    $serverSection += $line
                }
                # build new configuration with all existing peer
                $newConfig = $serverSection -join "`n"
                foreach ($peerName in $existingPeer) {
                    # read peer configuration
                    $peerConfigPath = "/config/peer_$peerName/peer_$peerName.conf"
                    $peerConfig = docker exec $script:wireguardContainerName cat $peerConfigPath 2>$null
                    if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrWhiteSpace($peerConfig)) {
                        # extract peer public key and allowed IPs for server config
                        $publicKey = $null
                        $allowedIPs = $null
                        foreach ($line in $peerConfig -split "`n") {
                            if ($line -match '^PublicKey\s*=\s*(.+)$') {
                                $publicKey = $matches[1].Trim()
                            }
                            elseif ($line -match '^Address\s*=\s*(.+)$') {
                                $allowedIPs = $matches[1].Trim()
                            }
                        }
                        if ($publicKey -and $allowedIPs) {
                            Microsoft.PowerShell.Utility\Write-Verbose `
                                "Adding peer '$peerName' to server configuration"
                            $newConfig += "`n`n[Peer]"
                            $newConfig += "`nPublicKey = $publicKey"
                            $newConfig += "`nAllowedIPs = $allowedIPs"
                        }
                    }
                }
                # write the new configuration
                $tempConfigPath = "/tmp/wg0_rebuilt.conf"
                docker exec $script:wireguardContainerName sh -c "cat > $tempConfigPath << 'EOL'`n$newConfig`nEOL"
                if ($LASTEXITCODE -eq 0) {
                    # backup current config and replace with new one
                    docker exec $script:wireguardContainerName cp /config/wg_confs/wg0.conf /config/wg_confs/wg0.conf.backup 2>$null
                    docker exec $script:wireguardContainerName cp $tempConfigPath /config/wg_confs/wg0.conf
                    if ($LASTEXITCODE -eq 0) {
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "Successfully reset WireGuard configuration"
                        # restart WireGuard interface
                        docker exec $script:wireguardContainerName wg-quick down wg0 2>$null
                        docker exec $script:wireguardContainerName wg-quick up wg0 2>$null
                        if ($LASTEXITCODE -eq 0) {
                            Microsoft.PowerShell.Utility\Write-Verbose `
                                "✅ WireGuard interface restarted with new configuration"
                            return $true
                        }
                    }
                }
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Failed to reset WireGuard configuration"
                return $false
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Error resetting WireGuard configuration: $_"
                return $false
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Ensures all existing peer are active and operational.

        .DESCRIPTION
        Scans for existing peer configurations and ensures they are all
        properly loaded and active in the WireGuard interface. If inactive
        peer are found, resets the WireGuard configuration to include them.
        #>
        function Confirm-AllPeerActive {
             [CmdletBinding()]
            [OutputType([System.Boolean])]
            param()
            try {
                # get list of existing peer from container
                $existingPeer = Get-ExistingPeer
                if ($existingPeer.Count -eq 0) {
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'No existing peer to validate'
                    return $true
                }
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Validating $($existingPeer.Count) existing peer(s)..."
                $inactivePeerFound = $false
                # check each peer's status
                foreach ($peer in $existingPeer) {
                    $peerActive = Enable-PeerIfNeeded -PeerName $peer
                    if (-not $peerActive) {
                        $inactivePeerFound = $true
                    }
                }
                # if inactive peer were found, reset the configuration
                if ($inactivePeerFound) {
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'Inactive peer detected - resetting WireGuard configuration...'
                    $resetSuccessful = GenXdev\Reset-WireGuardConfiguration
                    if ($resetSuccessful) {
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            '✅ WireGuard configuration reset successfully'
                        # wait for interface to stabilize
                        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 5
                        # verify peer are now active
                        foreach ($peer in $existingPeer) {
                            $peerStatus = docker exec $script:wireguardContainerName /app/show-peer $peer 2>&1
                            if ($peerStatus -match 'is not active') {
                                Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Yellow `
                                    "ℹ️  Peer '$peer' still shows as inactive (normal for clients that haven't connected)"
                            }
                            else {
                                Microsoft.PowerShell.Utility\Write-Verbose `
                                    "✅ Peer '$peer' is now properly configured"
                            }
                        }
                        Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green `
                            '✅ All existing peer configurations have been restored to WireGuard interface'
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Warning `
                            'Failed to reset WireGuard configuration - some peer may remain inactive'
                    }
                }
                else {
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        '✅ All existing peer have been validated'
                }
                # always return true since the configuration has been reset
                return $true
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Failed to validate peer: $_"
                return $false
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Pulls the latest WireGuard Docker image from registry.

        .DESCRIPTION
        Downloads the specified WireGuard Docker image from Docker Hub or
        configured registry. Provides verbose logging and error handling.
        Returns true on success, false on failure.
        #>
        function Get-WireGuardImage {
            [CmdletBinding()]
            [OutputType([System.Boolean])]
            param()
            try {

                # output verbose information about docker image pull operation
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Pulling WireGuard image: $script:wireguardImageName"

                # pull the specified docker image from registry
                $pullResult = docker pull $script:wireguardImageName 2>&1

                # check if docker pull command failed
                if ($LASTEXITCODE -ne 0) {

                    throw "Failed to pull WireGuard image: $pullResult"
                }

                # log successful image pull completion
                Microsoft.PowerShell.Utility\Write-Verbose `
                    '✅ WireGuard image pulled successfully'

                return $true
            }
            catch {

                # log error details for image pull failure
                Microsoft.PowerShell.Utility\Write-Error `
                    "Failed to pull WireGuard image: $_"

                return $false
            }
        }
        #######################################################################
        <#
        .SYNOPSIS
        Creates and starts a new WireGuard Docker container.

        .DESCRIPTION
        Creates a new WireGuard container with proper configuration including
        networking capabilities, persistent volume mounting, environment
        variables, and restart policies. Uses ShouldProcess for confirmation.
        #>
        function New-WireGuardContainer {

            [CmdletBinding(SupportsShouldProcess)]
            [OutputType([System.Boolean])]
            param()

            try {

                # output verbose information about container creation process
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Creating WireGuard container...'

                # check if docker volume already exists in the system
                $volumeExists = docker volume ls `
                    --filter "name=^${script:wireguardVolumeName}$" `
                    --format '{{.Name}}' 2>$null

                # create docker volume if it doesn't exist yet
                if ([string]::IsNullOrWhiteSpace($volumeExists)) {

                    # use shouldprocess to confirm volume creation
            if ($PSCmdlet.ShouldProcess("$script:wireguardVolumeName",
                'Create Docker volume')) {

                        # output verbose information about volume creation
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            "Creating Docker volume: $script:wireguardVolumeName"

                        # create the docker volume for persistent storage
                        $volumeResult = docker volume create $script:wireguardVolumeName `
                            2>&1

                        # check if volume creation failed
                        if ($LASTEXITCODE -ne 0) {

                            throw ('Failed to create Docker volume ' +
                                "$script:volumeName`: $volumeResult")
                        }
                    }
                }

                # prepare docker run arguments for container creation
                $dockerArgs = @(
                    'run', '-d'
                    '--name', $script:wireguardContainerName
                    '--cap-add', 'NET_ADMIN'
                    '--cap-add', 'SYS_MODULE'
                    '-e', "PUID=$($script:wireguardPuid)"
                    '-e', "PGID=$($script:wireguardPgid)"
                    '-e', "TZ=$($script:wireguardTimezone)"
                    '-e', "SERVERURL=auto"
                    '-e', "SERVERPORT=$($script:wireguardServicePort)"
                    '-e', "PEERS=1"
                    '-e', "PEERDNS=auto"
                    '-e', "INTERNAL_SUBNET=10.13.13.0"
                    '-e', "ALLOWEDIPS=0.0.0.0/0",
                    '-e', "UPNP=on",
                    '-p', "$($script:wireguardServicePort):51839/udp"
                    '-v', "$($script:wireguardVolumeName):/config"
                    '--restart', 'unless-stopped'
                )

                # add the docker image name as final argument
                $dockerArgs += $script:wireguardImageName

                # output verbose information about docker command execution
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Docker command: docker $($dockerArgs -join ' ')"

                # use shouldprocess to confirm container creation
        if ($PSCmdlet.ShouldProcess("$script:wireguardContainerName",
            'Create WireGuard container')) {

                    # execute docker run command to create container
                    $result = & docker @dockerArgs 2>&1

                    # check if container creation failed
                    if ($LASTEXITCODE -ne 0) {

                        throw "Failed to create container: $result"
                    }
                }

                # wait for container to initialize properly after creation
                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 5

                # log successful container creation
                Microsoft.PowerShell.Utility\Write-Verbose `
                    '✅ WireGuard container created successfully'

                return $true
            }
            catch {

                # log error details for container creation failure
                Microsoft.PowerShell.Utility\Write-Error `
                    "Failed to create WireGuard container: $_"

                return $false
            }
        }
        #######################################################################
    }

    process {

        try {

            # ensure docker desktop is available and running properly
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Ensuring Docker Desktop is available...'

            # Copy identical parameters between functions
            $params = GenXdev\Copy-IdenticalParamValues `
                -FunctionName 'GenXdev\EnsureDockerDesktop' `
                -BoundParameters $PSBoundParameters `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable -Scope Local -ErrorAction SilentlyContinue)

            GenXdev\EnsureDockerDesktop @params

            # verify docker is responding to commands after ensuring it's running
            if (-not (Test-DockerAvailability)) {

                throw 'Docker is not available or not responding'
            }

            # handle force cleanup if requested by user for fresh installation
            if ($Force) {

                # output verbose information about forced cleanup process
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Force flag specified - cleaning up existing resources...'

                # remove existing container and volume for clean slate
                Remove-DockerContainer $script:wireguardContainerName

                Remove-DockerVolume $script:wireguardVolumeName
            }

            # ensure we have the latest wireguard image available locally
            if (-not (Test-DockerImage $script:wireguardImageName) -or $Force) {

                # pull the docker image if not present or force specified
                if (-not (Get-WireGuardImage)) {

                    throw 'Failed to obtain WireGuard Docker image'
                }
            }
            else {

                # log that image is already available locally
                Microsoft.PowerShell.Utility\Write-Verbose `
                    '✅ WireGuard image already available'
            }

            # check current container state for appropriate action
            $containerExists = Test-DockerContainer $script:wireguardContainerName

            $containerRunning = Test-DockerContainerRunning $script:wireguardContainerName

            # handle existing container scenarios based on current state
            if ($containerExists) {

                # check if container is currently running
                if ($containerRunning) {

                    # verify container health for running container
                    if (Test-ServiceHealth) {

                        # log successful health check result
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            '✅ WireGuard container is healthy and responding'
                    }
                    else {

                        # restart unhealthy running container to fix issues
                        Microsoft.PowerShell.Utility\Write-Verbose `
                        ('Container is running but not responding - ' +
                            'restarting...')

                        # restart the container to fix health issues
                        $null = docker restart $script:wireguardContainerName 2>$null

                        # wait for container to restart properly
                        Microsoft.PowerShell.Utility\Start-Sleep -Seconds 10

                        # wait for service to become ready after restart
                        $serviceReady = Wait-ServiceReady

                        # warn if service is not ready after restart attempt
                        if (-not $serviceReady) {

                            Microsoft.PowerShell.Utility\Write-Warning `
                            ('WireGuard service may not be fully ready ' +
                                'after restart')
                        }
                    }
                }
                else {

                    # start existing stopped container
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'Starting existing container...'

                    # start the stopped container
                    $null = docker start $script:wireguardContainerName 2>$null

                    # wait for container to start properly
                    Microsoft.PowerShell.Utility\Start-Sleep -Seconds 10

                    # wait for service to become ready after start
                    $serviceReady = Wait-ServiceReady

                    # log or warn about service readiness after start
                    if ($serviceReady) {

                        Microsoft.PowerShell.Utility\Write-Verbose `
                            '✅ WireGuard service is ready after container start'
                    }
                    else {

                        Microsoft.PowerShell.Utility\Write-Warning `
                        ('WireGuard service may not be fully ready ' +
                            'after start')
                    }
                }
            }
            else {

                # create and start new container when none exists
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'No existing container found - creating fresh installation...'

                # clean up any existing volume for a fresh start
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Removing any existing volumes for clean installation...'

                Remove-DockerVolume $script:wireguardVolumeName

                # attempt to create new wireguard container
                if (-not (New-WireGuardContainer)) {

                    throw 'Failed to create WireGuard container'
                }

                # wait for service to be ready after creation
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Waiting for WireGuard service to be ready...'

                $serviceReady = Wait-ServiceReady

                # log or warn about service readiness after creation
                if ($serviceReady) {

                    Microsoft.PowerShell.Utility\Write-Verbose `
                        '✅ WireGuard service is ready'
                }
                else {

                    Microsoft.PowerShell.Utility\Write-Warning `
                    ('WireGuard service may not be fully ready ' +
                        'after creation')
                }
            }

            # perform final validation of service state before returning
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Performing final validation...'

            # check if container is running and service is healthy
            if ((Test-DockerContainerRunning $script:wireguardContainerName) -and `
                (Test-ServiceHealth)) {

                # only validate peers if container already existed (not fresh install)
                if ($containerExists) {
                    Microsoft.PowerShell.Utility\Write-Verbose `
                        'Validating existing peer configurations...'
                    Confirm-AllPeerActive
                }

                # log successful service operation
                Microsoft.PowerShell.Utility\Write-Verbose `
                ('✅ WireGuard VPN service is fully ' +
                    "operational on port $script:wireguardServicePort")

                # display instructions for client configuration to user
                Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green @"

To generate client configurations:
- Run: docker exec -it $script:wireguardContainerName /app/show-peer 1
This will display a QR code or config file for the client.

For Android 10 and above:
1. Install the official WireGuard app from Google Play Store
2. Scan the QR code or import the config file to connect
"@

                return $true
            }
            else {

                # warn about potential service issues
                Microsoft.PowerShell.Utility\Write-Warning `
                    'WireGuard service may not be fully operational'

                return $false
            }
        }
        catch {

            # log error details for any failures in the process
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to ensure WireGuard service: $_"

            throw
        }
    }

    end {

        Microsoft.PowerShell.Management\Set-Location -LiteralPath $script:wireguardOriginalLocation
    }
}