###############################################################################
<#
.SYNOPSIS
Removes a WireGuard VPN peer configuration.

.DESCRIPTION
This function removes a WireGuard VPN peer configuration from the server running
in a Docker container. It deletes the peer's configuration files and updates the
WireGuard server to stop accepting connections from this peer. The function
validates peer existence before removal and provides confirmation prompts unless
the Force parameter is specified.

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

.PARAMETER PeerName
The name of the peer to remove from the WireGuard configuration.

.PARAMETER Force
If specified, bypasses confirmation prompts when removing the peer.

.PARAMETER NoDockerInitialize
Skip Docker initialization when already called by parent function.

.PARAMETER ContainerName
The name for the Docker container running the WireGuard service.

.PARAMETER VolumeName
The name for the Docker volume used for persistent storage.

.PARAMETER ServicePort
The port number for the WireGuard service.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for service health check.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts.

.PARAMETER ImageName
Custom Docker image name to use for the WireGuard container.

.PARAMETER PUID
User ID for permissions in the container.

.PARAMETER PGID
Group ID for permissions in the container.

.PARAMETER TimeZone
Timezone to use for the container.

.EXAMPLE
Remove-WireGuardPeer -PeerName "MyPhone"

Removes the peer named "MyPhone" with confirmation prompt.

.EXAMPLE
Remove-WireGuardPeer -PeerName "Tablet" -Force

Removes the peer named "Tablet" without confirmation prompt.

.EXAMPLE
Remove-WireGuardPeer "WorkLaptop"

Removes the peer using positional parameter syntax.

.NOTES
This function interacts with the linuxserver/wireguard Docker container to manage
WireGuard peers. It requires the container to be running (use EnsureWireGuard
first). The function will validate peer existence before attempting removal and
provides detailed error handling for failed operations.
###############################################################################>
function Remove-WireGuardPeer {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The name of the peer to remove'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PeerName,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'wireguard',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The name for the Docker volume for persistent storage'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'wireguard_data',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The port number for the WireGuard service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 51839,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Maximum time in seconds to wait for service health check'
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Interval in seconds between health check attempts'
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName = 'linuxserver/wireguard',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'User ID for permissions in the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PUID = '1000',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Group ID for permissions in the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PGID = '1000',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Timezone to use for the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $TimeZone = 'Etc/UTC',
        #######################################################################
        [Alias('ForceRebuild')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Force removal without confirmation'
        )]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip Docker initialization when called by parent function'
        )]
        [switch] $NoDockerInitialize,
        #######################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Show Docker Desktop window during initialization')]
        [switch] $ShowWindow,
        #######################################################################
        [Alias('nb')]
        [Parameter(Mandatory = $false, HelpMessage = 'Removes the borders of the window')]
        [switch] $NoBorders,
        #######################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'The initial width of the window')]
        [int] $Width = -1,
        #######################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'The initial height of the window')]
        [int] $Height = -1,
        #######################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Place window on the left side of the screen')]
        [switch] $Left,
        #######################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Place window on the right side of the screen')]
        [switch] $Right,
        #######################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Place window on the bottom side of the screen')]
        [switch] $Bottom,
        #######################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Place window in the center of the screen')]
        [switch] $Centered,
        #######################################################################
        [Alias('fs')]
        [Parameter(Mandatory = $false, HelpMessage = 'Maximize the window')]
        [switch] $Fullscreen,
        #######################################################################
        [Alias('rf', 'bg')]
        [Parameter(Mandatory = $false, HelpMessage = 'Restore PowerShell window focus')]
        [switch] $RestoreFocus,
        #######################################################################
        [Alias('sbs')]
        [Parameter(Mandatory = $false, HelpMessage = 'Will either set the window fullscreen on a different monitor than Powershell, or side by side with Powershell on the same monitor')]
        [switch] $SideBySide,
        #######################################################################
        [Alias('fw','focus')]
        [Parameter(Mandatory = $false, HelpMessage = 'Focus the window after opening')]
        [switch] $FocusWindow,
        #######################################################################
        [Alias('fg')]
        [Parameter(Mandatory = $false, HelpMessage = 'Set the window to foreground after opening')]
        [switch] $SetForeground,
        #######################################################################
        [Alias('Escape')]
        [Parameter(Mandatory = $false, HelpMessage = 'Escape control characters and modifiers when sending keys')]
        [switch] $SendKeyEscape,
        #######################################################################
        [Alias('HoldKeyboardFocus')]
        [Parameter(Mandatory = $false, HelpMessage = 'Hold keyboard focus on target window when sending keys')]
        [switch] $SendKeyHoldKeyboardFocus,
        #######################################################################
        [Alias('UseShiftEnter')]
        [Parameter(Mandatory = $false, HelpMessage = 'Use Shift+Enter instead of Enter when sending keys')]
        [switch] $SendKeyUseShiftEnter,
        #######################################################################
        [Alias('DelayMilliSeconds')]
        [Parameter(Mandatory = $false, HelpMessage = 'Delay between different input strings in milliseconds when sending keys')]
        [int] $SendKeyDelayMilliSeconds,
        #######################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Use alternative settings stored in session for AI preferences')]
        [switch] $SessionOnly,
        #######################################################################
        [Parameter(Mandatory = $false, HelpMessage = 'Clear alternative settings stored in session for AI preferences')]
        [switch] $ClearSession,
        #######################################################################
        [Alias('FromPreferences')]
        [Parameter(Mandatory = $false, HelpMessage = 'Store settings only in persistent preferences without affecting session')]
        [switch] $SkipSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to WireGuard installation ' +
                'and set persistent flag.')
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
    )
    begin {

        # ensure the wireguard service is running if not skipped
        if (-not $NoDockerInitialize) {
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Ensuring WireGuard service is available'

            # copy matching parameters to pass to ensurewireguard function
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

        # define helper function to check if peer configuration exists
        function Test-PeerExist {
            param([string]$peerName)

            try {
                # check for existing peer configuration folder using docker exec
                $result = docker exec $ContainerName sh -c ("[ -d /config/peer_$peerName ] && " +
                    "echo 'exists' || echo 'not exists'")

                if ($result -eq 'exists') {
                    return $true
                }

                return $false
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Unable to verify peer existence: $_"

                # if we cannot verify assume it exists for safety
                return $true
            }
        }
    }    process {

        try {
            # check if peer exists before attempting removal
            if (-not (Test-PeerExist -peerName $PeerName)) {
                throw "Peer '$PeerName' does not exist"
            }

            # get the peer's public key for wireguard configuration removal
            $publicKey = docker exec $ContainerName sh -c ("cat /config/peer_$PeerName/publickey " +
                '2>/dev/null')

            if ($LASTEXITCODE -ne 0 -or [string]::IsNullOrEmpty($publicKey)) {
                Microsoft.PowerShell.Utility\Write-Warning ('Could not retrieve public key for ' +
                    "peer '$PeerName', but will attempt removal anyway")
                $publicKey = $null
            }
            else {
                # trim whitespace from the public key
                $publicKey = $publicKey.Trim()
            }

            # confirm the removal if force is not specified
            $confirmMessage = "Are you sure you want to remove the WireGuard peer '$PeerName'?"
            $operationName = "Removing WireGuard peer '$PeerName'"

            if ($Force -or $PSCmdlet.ShouldProcess($confirmMessage, $operationName)) {
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Removing WireGuard peer: $PeerName"

                # remove from wireguard configuration if we have the public key
                if (-not [string]::IsNullOrEmpty($publicKey)) {
                    $removeResult = docker exec $ContainerName sh -c ('wg set wg0 peer ' +
                        "$publicKey remove")

                    if ($LASTEXITCODE -ne 0) {
                        Microsoft.PowerShell.Utility\Write-Warning `
                            "Failed to remove peer from WireGuard: $removeResult"
                    }
                    else {
                        Microsoft.PowerShell.Utility\Write-Verbose `
                            'Peer removed from WireGuard configuration'
                    }
                }

                # remove peer directory from container filesystem
                $deleteResult = docker exec $ContainerName sh -c "rm -rf /config/peer_$PeerName"

                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to remove peer directory: $deleteResult"
                }

                # save wireguard configuration to persist changes
                $saveResult = docker exec $ContainerName sh -c 'wg-quick save wg0'

                if ($LASTEXITCODE -ne 0) {
                    Microsoft.PowerShell.Utility\Write-Warning `
                        "Failed to save WireGuard configuration: $saveResult"
                }

                Microsoft.PowerShell.Utility\Write-Host -ForegroundColor Green `
                    "Peer '$PeerName' removed successfully"

                # return success information for pipeline use
                return [PSCustomObject]@{
                    PeerName  = $PeerName
                    PublicKey = $publicKey
                    Success   = $true
                    Message   = "Peer '$PeerName' removed successfully"
                }
            }

            # return cancellation information when user declines
            return [PSCustomObject]@{
                PeerName  = $PeerName
                PublicKey = $publicKey
                Success   = $false
                Message   = 'Peer removal was canceled by user'
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to remove WireGuard peer '$PeerName': $_"
            throw
        }
    }    end {
    }
}