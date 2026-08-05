###############################################################################
<#
.SYNOPSIS
Gets information about all WireGuard VPN peers configured on the system.

.DESCRIPTION
This function retrieves comprehensive information about all WireGuard VPN peers
configured on the server running in a Docker container. It provides detailed
information including peer names, public keys, allowed IP addresses, connection
endpoints, handshake status, data transfer statistics, and current connection
status. The function can operate in conjunction with parent functions or
independently manage Docker container initialization.

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

.PARAMETER NoDockerInitialize
Skip Docker initialization process when this function is called by a parent
function that has already handled container setup.

.PARAMETER Force
Force complete rebuild of the Docker container and remove all existing
persistent data before starting fresh.

.PARAMETER ContainerName
The name identifier for the Docker container running the WireGuard service.
Must be a valid Docker container name.

.PARAMETER VolumeName
The name identifier for the Docker volume used for persistent storage of
WireGuard configuration and peer data.

.PARAMETER ServicePort
The UDP port number on which the WireGuard service listens for VPN connections.
Must be within valid port range.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for the WireGuard service to respond to health
check attempts before considering it failed.

.PARAMETER HealthCheckInterval
Interval in seconds between consecutive health check attempts when waiting for
the service to become ready.

.PARAMETER ImageName
Custom Docker image name to use instead of the default linuxserver/wireguard
image for the container.

.PARAMETER PUID
User ID for file permissions and process ownership within the Docker container.
Used for security and permission management.

.PARAMETER PGID
Group ID for file permissions and process ownership within the Docker container.
Used for security and permission management.

.PARAMETER TimeZone
Timezone setting to use for the container's system clock and log timestamps.
Should be a valid timezone identifier.

.EXAMPLE
Get-WireGuardPeers

.EXAMPLE
Get-WireGuardPeers -NoDockerInitialize -ContainerName "custom_wireguard" `
                   -ServicePort 55555

.NOTES
This function interacts with the linuxserver/wireguard Docker container to
retrieve information about configured WireGuard peers. The container must be
running and accessible. Use EnsureWireGuard function first if container setup
is required.
###############################################################################>
function Get-WireGuardPeers {



    [CmdletBinding()]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip Docker initialization (used when already called ' +
                'by parent function)')
        )]
        [switch] $NoDockerInitialize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Force rebuild of Docker container and remove existing ' +
                'data')
        )]
        [Alias('ForceRebuild')]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'wireguard',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The name for the Docker volume for persistent storage'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'wireguard_data',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The port number for the WireGuard service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 51839,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service health ' +
                'check')
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Interval in seconds between health check attempts'
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName = 'linuxserver/wireguard',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'User ID for permissions in the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PUID = '1000',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Group ID for permissions in the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PGID = '1000',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Timezone to use for the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $TimeZone = 'Etc/UTC',
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the Docker window when running WireGuard'
        )]
        [switch] $ShowWindow,
        ###############################################################################
        [Alias('nb')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Remove window borders for the Docker window'
        )]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the width of the Docker window'
        )]
        [int] $Width = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the height of the Docker window'
        )]
        [int] $Height = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the left position of the Docker window'
        )]
        [int] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the right position of the Docker window'
        )]
        [int] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the bottom position of the Docker window'
        )]
        [int] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Center the Docker window on the screen'
        )]
        [switch] $Centered,
        ###############################################################################
        [Alias('fs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Run the Docker window in fullscreen mode'
        )]
        [switch] $Fullscreen,
        ###############################################################################
        [Alias('rf','bg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore focus to the previous window after running Docker'
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Alias('sbs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show Docker window side by side with other windows'
        )]
        [switch] $SideBySide,
        ###############################################################################
        [Alias('fw','focus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the Docker window after launching'
        )]
        [switch] $FocusWindow,
        ###############################################################################
        [Alias('fg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the Docker window as foreground window'
        )]
        [switch] $SetForeground,
        ###############################################################################
        [Alias('Escape')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Send Escape key to the Docker window after launch'
        )]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Alias('HoldKeyboardFocus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus in the Docker window after launch'
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Alias('UseShiftEnter')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter when sending keys to Docker window'
        )]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Alias('DelayMilliSeconds')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds between sending keys to Docker window'
        )]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use session only for Docker window'
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear session for Docker window before running'
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Alias('FromPreferences')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip session for Docker window'
        )]
        [switch] $SkipSession,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to WireGuard installation ' +
                'and set persistent flag.')
        )]
        [switch] $AutoConsent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages
        ###############################################################################

    )

    begin {

        # ensure the WireGuard service is running
        if (-not $NoDockerInitialize) {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Ensuring WireGuard service is available'

            # copy matching parameters to pass to EnsureWireGuard function
            $ensureParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\EnsureWireGuard' `
                -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                    -Scope Local `
                    -ErrorAction SilentlyContinue)

            # initialize WireGuard service with specified parameters
            $null = GenXdev\EnsureWireGuard @ensureParams
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Skipping Docker initialization as requested'
        }
    }

    process {

        try {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Retrieving WireGuard peers'

            # get peer information from WireGuard container using wg show command
            $wgOutput = docker exec $ContainerName wg show

            # check if the docker command executed successfully
            if ($LASTEXITCODE -ne 0) {

                throw "Failed to retrieve WireGuard peers: $wgOutput"
            }

            # parse the wg show output and convert to objects
            $peers = @()
            $currentPeer = $null

            # process each line of the wg show output
            foreach ($line in $wgOutput -split "`n") {

                # check if line contains peer public key information
                if ($line -match '^peer: (.+)$') {

                    # save previous peer if it exists
                    if ($null -ne $currentPeer) {

                        $peers += $currentPeer
                    }

                    # create new peer object with default values
                    $currentPeer = @{
                        PublicKey           = $matches[1]
                        Name                = $null
                        AllowedIPs          = $null
                        Endpoint            = $null
                        LatestHandshake     = $null
                        TransferRx          = $null
                        TransferTx          = $null
                        PersistentKeepalive = $null
                        Status              = $null
                    }
                }
                elseif ($null -ne $currentPeer) {

                    # check if line contains allowed IPs information
                    if ($line -match '^\s+allowed ips: (.+)$') {

                        $currentPeer.AllowedIPs = $matches[1]
                    }
                    # check if line contains endpoint information
                    elseif ($line -match '^\s+endpoint: (.+)$') {

                        $currentPeer.Endpoint = $matches[1]
                    }
                    # check if line contains latest handshake information
                    elseif ($line -match '^\s+latest handshake: (.+)$') {

                        $currentPeer.LatestHandshake = $matches[1]

                        # determine status based on handshake time
                        if ($matches[1] -match 'Never') {

                            $currentPeer.Status = 'Disconnected'
                        }
                        else {

                            # calculate time since last handshake
                            $handshakeTime = if ($matches[1] -match '(\d+) minutes? ago') {

                                [int]$matches[1]
                            }
                            elseif ($matches[1] -match '(\d+) seconds? ago') {

                                0  # Less than a minute
                            }
                            else {

                                9999  # Some other format, assume old
                            }

                            # if handshake was less than 3 minutes ago, consider connected
                            $currentPeer.Status = if ($handshakeTime -le 3) {

                                'Connected'
                            }
                            else {

                                'Inactive'
                            }
                        }
                    }                    # check if line contains transfer statistics information
                    elseif ($line -match ('^\\s+transfer: (\\d+\\.?\\d* \\w+) received, ' +
                            '(\\d+\\.?\\d* \\w+) sent$')) {

                        $currentPeer.TransferRx = $matches[1]
                        $currentPeer.TransferTx = $matches[2]
                    }
                    # check if line contains persistent keepalive information
                    elseif ($line -match '^\s+persistent keepalive: (.+)$') {

                        $currentPeer.PersistentKeepalive = $matches[1]
                    }
                }
            }

            # add the last peer if it exists
            if ($null -ne $currentPeer) {

                $peers += $currentPeer
            }

            # get peer names from configuration folders
            $peerFolders = docker exec $ContainerName sh -c 'ls -1d /config/peer_*' `
                2>$null

            # process peer folders if command was successful
            if ($LASTEXITCODE -eq 0 -and -not [string]::IsNullOrEmpty($peerFolders)) {

                # iterate through each peer folder
                foreach ($folder in $peerFolders -split "`n") {

                    # extract peer name from folder path
                    if ($folder -match '/config/peer_(.+)$') {

                        $peerName = $matches[1]

                        # get the public key for this peer
                        $publicKey = docker exec $ContainerName sh -c `
                            "cat /config/peer_$peerName/publickey" 2>$null

                        # process if public key was retrieved successfully
                        if ($LASTEXITCODE -eq 0 -and `
                                -not [string]::IsNullOrEmpty($publicKey)) {

                            # find the peer with this public key and add the name
                            foreach ($peer in $peers) {

                                if ($peer.PublicKey -eq $publicKey.Trim()) {

                                    $peer.Name = $peerName
                                    break
                                }
                            }

                            # if not found in peers list (disconnected), add it
                            if (-not ($peers | `
                                            Microsoft.PowerShell.Core\Where-Object { `
                                                $_.PublicKey -eq $publicKey.Trim() })) {

                                $peers += @{
                                    PublicKey           = $publicKey.Trim()
                                    Name                = $peerName
                                    AllowedIPs          = 'Unknown'
                                    Endpoint            = 'Unknown'
                                    LatestHandshake     = 'Never'
                                    TransferRx          = '0 B'
                                    TransferTx          = '0 B'
                                    PersistentKeepalive = 'Off'
                                    Status              = 'Disconnected'
                                }
                            }
                        }
                    }
                }
            }

            # convert to custom objects
            $peerObjects = $peers | `
                    Microsoft.PowerShell.Core\ForEach-Object {

                    [PSCustomObject]@{
                        Name                = $_.Name
                        PublicKey           = $_.PublicKey
                        AllowedIPs          = $_.AllowedIPs
                        Endpoint            = $_.Endpoint
                        LatestHandshake     = $_.LatestHandshake
                        TransferReceived    = $_.TransferRx
                        TransferSent        = $_.TransferTx
                        PersistentKeepalive = $_.PersistentKeepalive
                        Status              = $_.Status
                    }
                }

            # return the results
            return $peerObjects
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to retrieve WireGuard peers: $_"
            throw
        }
    }

    end {
    }
}