###############################################################################
<#
.SYNOPSIS
Gets detailed status information about the WireGuard VPN server.

.DESCRIPTION
This function retrieves detailed status information about the WireGuard VPN
server running in a Docker container, including interface details, listening
port, connected peers, and server health. It provides comprehensive information
about the WireGuard service including server status, peer counts, uptime, and
network configuration details.

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
Skip Docker initialization (used when already called by parent function).

.PARAMETER Force
Force rebuild of Docker container and remove existing data.

.PARAMETER ContainerName
The name for the Docker container.

.PARAMETER VolumeName
The name for the Docker volume for persistent storage.

.PARAMETER ServicePort
The port number for the WireGuard service.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts.

.PARAMETER ImageName
Custom Docker image name to use.

.PARAMETER PUID
User ID for permissions in the container.

.PARAMETER PGID
Group ID for permissions in the container.

.PARAMETER TimeZone
Timezone to use for the container.

.EXAMPLE
Get-WireGuardStatus

Returns the status of the WireGuard server with default settings.

.EXAMPLE
Get-WireGuardStatus -NoDockerInitialize -ContainerName "custom_wireguard"

Retrieves status for a custom container without initializing Docker.

.NOTES
This function interacts with the linuxserver/wireguard Docker container to
retrieve status information about the WireGuard server. It requires the
container to be running (use EnsureWireGuard first).
#>
function Get-WireGuardStatus {

    [CmdletBinding()]

    param(        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip Docker initialization (used when already called by parent function)'
        )]
        [switch] $NoDockerInitialize,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force rebuild of Docker container and remove existing data'
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
            HelpMessage = 'Maximum time in seconds to wait for service health check'
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
            HelpMessage = 'Show the window when running the container (pass-through)'
        )]
        [switch] $ShowWindow,
        ###############################################################################
        [Alias('nb')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Remove window borders (pass-through)'
        )]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Window width in characters or pixels (pass-through)'
        )]
        [int] $Width = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Window height in characters or pixels (pass-through)'
        )]
        [int] $Height = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Window left position (pass-through)'
        )]
        [int] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Window right position (pass-through)'
        )]
        [int] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Window bottom position (pass-through)'
        )]
        [int] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Center the window (pass-through)'
        )]
        [switch] $Centered,
        ###############################################################################
        [Alias('fs')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Open window in fullscreen mode (pass-through)'
        )]
        [switch] $Fullscreen,
        ###############################################################################
        [Alias('rf','bg')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore focus to window after operation (pass-through)'
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Alias('sbs')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show side-by-side window (pass-through)'
        )]
        [switch] $SideBySide,
        ###############################################################################
        [Alias('fw','focus')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after opening (pass-through)'
        )]
        [switch] $FocusWindow,
        ###############################################################################
        [Alias('fg')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set window to foreground (pass-through)'
        )]
        [switch] $SetForeground,
        ###############################################################################
        [Alias('Escape')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Send Escape key to window (pass-through)'
        )]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Alias('HoldKeyboardFocus')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus when sending keys (pass-through)'
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Alias('UseShiftEnter')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter when sending keys (pass-through)'
        )]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Alias('DelayMilliSeconds')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds between sending keys (pass-through)'
        )]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Session only mode (pass-through)'
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear session data (pass-through)'
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Alias('FromPreferences')]
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip session initialization (pass-through)'
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

        # ensure the wireguard service is running
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

            # initialize wireguard service with specified parameters
            $null = GenXdev\EnsureWireGuard @ensureParams
        }
        else {

            Microsoft.PowerShell.Utility\Write-Verbose `
                'Skipping Docker initialization as requested'
        }
    }    process {

        try {

            Microsoft.PowerShell.Utility\Write-Verbose 'Retrieving WireGuard status'

            # check container status
            $containerRunning = docker ps -q -f name=$ContainerName

            if (-not $containerRunning) {

                throw 'WireGuard container is not running'
            }

            # get container uptime
            $containerInfo = docker inspect --format '{{.State.StartedAt}}' `
                $ContainerName

            $startTime = [DateTime]::Parse($containerInfo)

            $uptime = [DateTime]::UtcNow - $startTime

            # get interface details
            $interfaceInfo = docker exec $ContainerName wg show wg0

            if ($LASTEXITCODE -ne 0) {

                throw 'Failed to retrieve WireGuard interface information'
            }

            # get server ip address
            $serverIP = $null

            $ipInfo = docker exec $ContainerName sh -c `
                'ip -o addr show wg0 | grep -v inet6'

            if ($LASTEXITCODE -eq 0) {

                if ($ipInfo -match 'inet\s+(\d+\.\d+\.\d+\.\d+)') {

                    $serverIP = $matches[1]
                }
            }

            # get server configuration
            $serverConfig = docker exec $ContainerName sh -c `
                'cat /config/wg0.conf 2>/dev/null'

            $listenPort = if ($serverConfig -match 'ListenPort\s*=\s*(\d+)') {
                $matches[1]
            } else {
                $ServicePort
            }

            # count peers
            $peerFolders = docker exec $ContainerName sh -c `
                'ls -1d /config/peer_* 2>/dev/null | wc -l'

            $peerCount = if ($LASTEXITCODE -eq 0) {
                [int]$peerFolders
            } else {
                0
            }

            # get connected peers
            $connectedPeers = 0

            if ($interfaceInfo -match 'peer:') {

                $handshakes = [regex]::Matches($interfaceInfo, 'latest handshake:')

                foreach ($handshake in $handshakes) {

                    $line = $interfaceInfo.Substring($handshake.Index)

                    if ($line -match `
                            'latest handshake: (\d+) (second|minute|hour)s? ago') {

                        $connectedPeers++
                    }
                }
            }

            # generate external url
            $externalIP = docker exec $ContainerName sh -c `
                "curl -s https://api.ipify.org || echo 'unknown'"

            $externalEndpoint = if ($externalIP -ne 'unknown') {
                ('{0}:{1}' -f $externalIP, $listenPort)
            } else {
                'unknown'
            }

            # create status object
            $status = [PSCustomObject]@{
                ServerStatus     = 'Running'
                ServerIP         = $serverIP
                ListenPort       = $listenPort
                TotalPeers       = $peerCount
                ConnectedPeers   = $connectedPeers
                ContainerUptime  = ('{0}d {1:D2}h {2:D2}m {3:D2}s' -f `
                        $uptime.Days, $uptime.Hours, $uptime.Minutes, $uptime.Seconds)
                ExternalEndpoint = $externalEndpoint
                Interface        = 'wg0'
                ServerPublicKey  = if ($interfaceInfo -match 'public key: (.+)') {
                    $matches[1]
                } else {
                    'unknown'
                }
                ContainerName    = $ContainerName
                ServicePort      = $ServicePort
            }

            # display status information
            Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan `
                'WireGuard Server Status'

            Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Cyan `
                '======================='

            Microsoft.PowerShell.Utility\Write-Host 'Server Status    : ' `
                -NoNewline

            Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green `
                'Running'

            Microsoft.PowerShell.Utility\Write-Host 'Interface        : wg0'

            Microsoft.PowerShell.Utility\Write-Host `
                "Server IP        : $serverIP"

            Microsoft.PowerShell.Utility\Write-Host `
                "Listen Port      : $listenPort"

            Microsoft.PowerShell.Utility\Write-Host `
                "External Endpoint: $externalEndpoint"

            Microsoft.PowerShell.Utility\Write-Host `
                "Server Public Key: $($status.ServerPublicKey)"

            Microsoft.PowerShell.Utility\Write-Host `
                "Container Uptime : $($status.ContainerUptime)"

            Microsoft.PowerShell.Utility\Write-Host `
                "Total Peers      : $peerCount"

            Microsoft.PowerShell.Utility\Write-Host `
                "Connected Peers  : $connectedPeers"

            Microsoft.PowerShell.Utility\Write-Host ''

            Microsoft.PowerShell.Utility\Write-Host `
            ('Use Get-WireGuardPeers for detailed information about ' + `
                    'peer connections.')

            # return the status object
            return $status
        }
        catch {

            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to retrieve WireGuard status: $_"

            throw
        }
    }    end {

    }
}