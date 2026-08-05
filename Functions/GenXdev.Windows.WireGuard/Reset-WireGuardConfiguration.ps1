###############################################################################
<#
.SYNOPSIS
Resets the WireGuard VPN server configuration, removing all peers.

.DESCRIPTION
This function resets the WireGuard VPN server configuration running in a Docker
container by removing all peers and generating a fresh server configuration.
This is a destructive operation that cannot be undone and will permanently
remove all peer configurations. The function stops the WireGuard service,
removes all peer directories and configuration files, removes server keys,
restarts the container, and verifies that a new configuration is generated.

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
The name for the Docker container. Defaults to 'wireguard' if not specified.
Used to identify which container to operate on.

.PARAMETER VolumeName
The name for the Docker volume for persistent storage. Defaults to
'wireguard_data' if not specified. Used for data persistence across container
restarts.

.PARAMETER ServicePort
The port number for the WireGuard service. Must be between 1 and 65535.
Defaults to 51839. This is the UDP port WireGuard will listen on.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check. Must be between 10
and 300 seconds. Defaults to 60 seconds. Used when verifying service health.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts. Must be between 1 and 10
seconds. Defaults to 3 seconds. Controls how often health checks are performed.

.PARAMETER ImageName
Custom Docker image name to use. Defaults to 'linuxserver/wireguard'. This
allows using alternative WireGuard Docker images if needed.

.PARAMETER PUID
User ID for permissions in the container. Defaults to '1000'. This controls
file ownership and permissions within the container.

.PARAMETER PGID
Group ID for permissions in the container. Defaults to '1000'. This controls
group ownership and permissions within the container.

.PARAMETER TimeZone
Timezone to use for the container. Defaults to 'Etc/UTC'. This sets the
container's timezone for logging and scheduling purposes.

.PARAMETER NoDockerInitialize
Skip Docker initialization (used when already called by parent function).
When specified, assumes Docker and WireGuard are already initialized.

.PARAMETER Force
If specified, bypasses confirmation prompts when removing all peer
configurations. Use with caution as this is a destructive operation.

.EXAMPLE
Reset-WireGuardConfiguration

Resets the WireGuard configuration with default settings and prompts for
confirmation before proceeding.

.EXAMPLE
Reset-WireGuardConfiguration -Force -ContainerName "my-wireguard"

Resets the WireGuard configuration for a custom container name without
confirmation prompts.

.NOTES
This function interacts with the linuxserver/wireguard Docker container to reset
the WireGuard server configuration. It requires the container to be running
(use EnsureWireGuard first). This operation will remove all peer configurations
and cannot be undone. The function will restart the container to regenerate
a fresh configuration.
###############################################################################>
function Reset-WireGuardConfiguration {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'High')]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseDeclaredVarsMoreThanAssignments', '')]

    param(
        ###########################################################################
        [Parameter(
            Position = 0,
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'wireguard',
        ###########################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = 'The name for the Docker volume for persistent storage'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'wireguard_data',
        ###########################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'The port number for the WireGuard service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 51839,
        ###########################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = 'Maximum time in seconds to wait for service health check'
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        ###########################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'Interval in seconds between health check attempts'
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        ###########################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName = 'linuxserver/wireguard',
        ###########################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = 'User ID for permissions in the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PUID = '1000',
        ###########################################################################
        [Parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = 'Group ID for permissions in the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PGID = '1000',
        ###########################################################################
        [Parameter(
            Position = 8,
            Mandatory = $false,
            HelpMessage = 'Timezone to use for the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $TimeZone = 'Etc/UTC',
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip Docker initialization (used when already called by parent function)'
        )]
        [switch] $NoDockerInitialize,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force reset without confirmation'
        )]
        [switch] $Force,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to WireGuard installation ' +
                'and set persistent flag.')
        )]
        [switch] $AutoConsent,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
        ###########################################################################

    )

    begin {

        # check if docker initialization should be skipped
        if (-not $NoDockerInitialize) {

            # output verbose message about ensuring wireguard service
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

        } else {

            # output verbose message about skipping docker initialization
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Skipping Docker initialization as requested'
        }
    }

    process {

        try {

            # count existing peers to show in warning message
            $peerFolders = docker exec $ContainerName sh -c `
                'ls -1d /config/peer_* 2>/dev/null | wc -l'

            # initialize peer count variable
            $peerCount = 0

            # check if peer count command was successful
            if ($LASTEXITCODE -eq 0) {

                # convert peer folders output to integer count
                $peerCount = [int]$peerFolders
            }

            # check if server configuration file exists for reporting
            $serverConfigExists = docker exec $ContainerName sh -c `
                "[ -f /config/wg0.conf ] && echo 'exists' || echo 'not exists'"

            # determine if server configuration is present
            $hasServerConfig = ($serverConfigExists -eq 'exists')

            # build confirmation message with peer count information
            $confirmMessage = ('WARNING: You are about to reset the WireGuard ' +
                "configuration. This will remove all $peerCount " +
                'peer configurations and cannot be undone. Are ' +
                'you sure you want to proceed?')

            # define operation name for shouldprocess
            $operationName = 'Resetting WireGuard configuration'

            # check if user confirmed the operation or force flag is set
            if ($Force -or $PSCmdlet.ShouldProcess($confirmMessage,
                    $operationName)) {

                # output verbose message about starting reset process
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Resetting WireGuard configuration, removing all peers...'

                # stop wireguard service in the container gracefully
                $null = docker exec $ContainerName sh -c `
                    'wg-quick down wg0 2>/dev/null || true'

                # wait for service to stop completely
                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 2

                # remove all peer directories from configuration
                $null = docker exec $ContainerName sh -c `
                    'rm -rf /config/peer_* 2>/dev/null || true'

                # check if peer removal was successful
                $peersRemoved = ($LASTEXITCODE -eq 0)

                # remove wireguard configuration file
                $null = docker exec $ContainerName sh -c `
                    'rm -f /config/wg0.conf 2>/dev/null || true'

                # check if configuration removal was successful
                $configRemoved = ($LASTEXITCODE -eq 0)

                # remove server private and public keys
                $null = docker exec $ContainerName sh -c `
                    'rm -f /config/server_* 2>/dev/null || true'

                # check if key removal was successful
                $keysRemoved = ($LASTEXITCODE -eq 0)

                # output verbose message about restarting container
                Microsoft.PowerShell.Utility\Write-Verbose `
                    'Restarting WireGuard container to regenerate configuration...'

                # restart the container to regenerate fresh configuration
                docker restart $ContainerName

                # check if container restart was successful
                if ($LASTEXITCODE -ne 0) {

                    # throw error if container restart failed
                    throw 'Failed to restart WireGuard container'
                }

                # wait for container to fully initialize after restart
                Microsoft.PowerShell.Utility\Start-Sleep -Seconds 10

                # verify container is running after restart
                $containerStatus = docker ps -q -f name=$ContainerName

                # check if container is actually running
                if (-not $containerStatus) {

                    # throw error if container failed to restart
                    throw 'WireGuard container failed to restart'
                }

                # check if new configuration was generated successfully
                $newConfigExists = docker exec $ContainerName sh -c `
                    "[ -f /config/wg0.conf ] && echo 'exists' || echo 'not exists'"

                # verify new configuration file was created
                if ($newConfigExists -ne 'exists') {

                    # throw error if configuration generation failed
                    throw 'Failed to generate new WireGuard configuration'
                }

                # display success message to user
                Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green `
                ('WireGuard configuration reset successfully. All peers ' +
                    'have been removed.')

                # provide guidance for next steps
                Microsoft.PowerShell.Utility\Write-Host `
                    'Use Add-WireGuardPeer to create new peer configurations.'

                # return success information object
                return [PSCustomObject]@{
                    Success             = $true
                    Message             = 'WireGuard configuration reset successfully'
                    PeersRemoved        = $peerCount
                    InitialConfig       = $hasServerConfig
                    PeersRemoveSuccess  = $peersRemoved
                    ConfigRemoveSuccess = $configRemoved
                    KeysRemoveSuccess   = $keysRemoved
                }
            }

            # return cancellation information if user declined
            return [PSCustomObject]@{
                Success      = $false
                Message      = 'WireGuard configuration reset was canceled by user'
                PeersRemoved = 0
            }

        } catch {

            # output error message for any failures during reset
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to reset WireGuard configuration: $_"

            # re-throw the exception to caller
            throw
        }
    }

    end {
    }
}