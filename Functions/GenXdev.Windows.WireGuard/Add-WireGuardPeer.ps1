###############################################################################
<#
.SYNOPSIS
Adds a new WireGuard VPN peer (client) configuration to the server.

.DESCRIPTION
This function adds a new peer to the WireGuard VPN server running in a Docker
container. It generates a new client configuration with a unique IP address,
creates necessary cryptographic keys, and returns the configuration details.
The function can optionally save the configuration to a file or generate a QR
code for easy mobile device setup. The function validates peer names, checks
for duplicates, and handles various error conditions gracefully.

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
A unique name for the peer that will be used to identify the peer in the
WireGuard configuration and for the generated configuration filename. The name
must be less than 100 characters and cannot contain invalid characters like
< > " / \ | ? * :

.PARAMETER AllowedIPs
The IP ranges that will be routed through the VPN for this peer. Specify
multiple ranges separated by commas. Default is "0.0.0.0/0, ::/0" which
routes all IPv4 and IPv6 traffic through the VPN tunnel.

.PARAMETER DNS
DNS servers to use for this peer when connected to the VPN. Specify multiple
servers separated by commas. Default is "1.1.1.1, 1.0.0.1" which uses
Cloudflare's secure DNS servers.

.PARAMETER OutputPath
The directory path where the peer configuration file should be saved when
SaveConfig is enabled. The directory will be created if it doesn't exist.
Default is "$env:USERPROFILE\WireGuardConfigs".

.PARAMETER ContainerName
The name of the Docker container running the WireGuard service. Must match
the container name used when initializing the service. Default is "wireguard".

.PARAMETER VolumeName
The name of the Docker volume used for persistent storage of WireGuard
configurations and keys. Must match the volume name used during
initialization. Default is "wireguard_data".

.PARAMETER ServicePort
The UDP port number that the WireGuard service listens on for VPN
connections. Must be a valid port number between 1 and 65535. Default is
51839 which is the standard WireGuard port.

.PARAMETER HealthCheckTimeout
Maximum time in seconds to wait for the WireGuard service health check to
complete. Valid range is 10 to 300 seconds. Default is 60 seconds.

.PARAMETER HealthCheckInterval
Interval in seconds between health check attempts when waiting for the
service to become ready. Valid range is 1 to 10 seconds. Default is 3
seconds.

.PARAMETER ImageName
The Docker image name to use for the WireGuard container. Default is
"linuxserver/wireguard" which is the official LinuxServer.io WireGuard image.

.PARAMETER PUID
User ID for file permissions inside the Docker container. Should match the
host user ID to avoid permission issues with volume mounts. Default is "1000".

.PARAMETER PGID
Group ID for file permissions inside the Docker container. Should match the
host group ID to avoid permission issues with volume mounts. Default is
"1000".

.PARAMETER TimeZone
Timezone to use for the container logs and scheduling. Should be a valid
timezone identifier. Default is "Etc/UTC" for consistent UTC timestamps.

.PARAMETER SaveConfig
When specified, saves the generated peer configuration to a .conf file in the
OutputPath directory. The file will be named with the peer name followed by
.conf extension.

.PARAMETER ShowQRCode
When specified, generates a PNG QR code that can be scanned by the WireGuard
mobile app for easy configuration import. The QR code is saved to the
OutputPath directory.

.PARAMETER NoDockerInitialize
When specified, skips the Docker container initialization check. Use this
when the function is called by another function that has already ensured the
WireGuard service is running.

.PARAMETER Force
When specified, forces a rebuild of the Docker container and removes existing
data. This will destroy all existing peer configurations and server keys.

.PARAMETER WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

.PARAMETER Confirm
Prompts you for confirmation before running the cmdlet.

.EXAMPLE
Add-WireGuardPeer -PeerName "MyPhone" -AllowedIPs "0.0.0.0/0, ::/0" `
    -DNS "1.1.1.1, 1.0.0.1" -SaveConfig -OutputPath `
    "$env:USERPROFILE\WireGuardConfigs" -ShowQRCode -ContainerName "wireguard" `
    -VolumeName "wireguard_data" -ServicePort 51839 -HealthCheckTimeout 60 `
    -HealthCheckInterval 3 -ImageName "linuxserver/wireguard" -PUID "1000" `
    -PGID "1000" -TimeZone "Etc/UTC"

.EXAMPLE
Add-WireGuardPeer "MyTablet" -ShowQRCode

.NOTES
This function interacts with the linuxserver/wireguard Docker container to
manage WireGuard peers. It requires Docker to be installed and the WireGuard
container to be running. Use EnsureWireGuard function first to initialize the
service if needed.
#>
function Add-WireGuardPeer {

    [CmdletBinding(SupportsShouldProcess)]
    [Diagnostics.CodeAnalysis.SuppressMessageAttribute('PSUseSingularNouns', '')]

    param(
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'A unique name for the peer'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PeerName,
        #######################################################################
        [Parameter(
            Position = 1,
            Mandatory = $false,
            HelpMessage = ('The IP ranges that will be routed through the ' +
                'VPN')
        )]
        [ValidateNotNullOrEmpty()]
        [string] $AllowedIPs = '0.0.0.0/0, ::/0',
        #######################################################################
        [Parameter(
            Position = 2,
            Mandatory = $false,
            HelpMessage = 'DNS servers to use for this peer'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $DNS = '1.1.1.1, 1.0.0.1',
        #######################################################################
        [Parameter(
            Position = 3,
            Mandatory = $false,
            HelpMessage = ('The path where the peer configuration file ' +
                'should be saved')
        )]
        [ValidateNotNullOrEmpty()]
        [Alias('outfile', 'OutputFile')]
        [string] $OutputPath = "$env:USERPROFILE\WireGuardConfigs",
        #######################################################################
        [Parameter(
            Position = 4,
            Mandatory = $false,
            HelpMessage = 'The name for the Docker container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ContainerName = 'wireguard',
        #######################################################################
        [Parameter(
            Position = 5,
            Mandatory = $false,
            HelpMessage = ('The name for the Docker volume for persistent ' +
                'storage')
        )]
        [ValidateNotNullOrEmpty()]
        [string] $VolumeName = 'wireguard_data',
        #######################################################################
        [Parameter(
            Position = 6,
            Mandatory = $false,
            HelpMessage = 'The port number for the WireGuard service'
        )]
        [ValidateRange(1, 65535)]
        [int] $ServicePort = 51839,
        #######################################################################
        [Parameter(
            Position = 7,
            Mandatory = $false,
            HelpMessage = ('Maximum time in seconds to wait for service ' +
                'health check')
        )]
        [ValidateRange(10, 300)]
        [int] $HealthCheckTimeout = 60,
        #######################################################################
        [Parameter(
            Position = 8,
            Mandatory = $false,
            HelpMessage = ('Interval in seconds between health check ' +
                'attempts')
        )]
        [ValidateRange(1, 10)]
        [int] $HealthCheckInterval = 3,
        #######################################################################
        [Parameter(
            Position = 9,
            Mandatory = $false,
            HelpMessage = 'Custom Docker image name to use'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ImageName = 'linuxserver/wireguard',
        #######################################################################
        [Parameter(
            Position = 10,
            Mandatory = $false,
            HelpMessage = 'User ID for permissions in the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PUID = '1000',
        #######################################################################
        [Parameter(
            Position = 11,
            Mandatory = $false,
            HelpMessage = 'Group ID for permissions in the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $PGID = '1000',
        #######################################################################
        [Parameter(
            Position = 12,
            Mandatory = $false,
            HelpMessage = 'Timezone to use for the container'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $TimeZone = 'Etc/UTC',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Save the peer configuration to a file'
        )]
        [switch] $SaveConfig,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the WireGuard window when initializing the service'
        )]
        [switch] $ShowWindow,
        ###############################################################################
        [Alias('nb')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Remove window borders when initializing the service'
        )]
        [switch] $NoBorders,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window width when initializing the service'
        )]
        [int] $Width = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window height when initializing the service'
        )]
        [int] $Height = -1,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window left position when initializing the service'
        )]
        [int] $Left,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window right position when initializing the service'
        )]
        [int] $Right,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window bottom position when initializing the service'
        )]
        [int] $Bottom,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Center the window when initializing the service'
        )]
        [switch] $Centered,
        ###############################################################################
        [Alias('fs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Start the service in fullscreen mode'
        )]
        [switch] $Fullscreen,
        ###############################################################################
        [Alias('rf','bg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Restore focus to the window after initializing the service'
        )]
        [switch] $RestoreFocus,
        ###############################################################################
        [Alias('sbs')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Show the window side by side when initializing the service'
        )]
        [switch] $SideBySide,
        ###############################################################################
        [Alias('fw','focus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Focus the window after initializing the service'
        )]
        [switch] $FocusWindow,
        ###############################################################################
        [Alias('fg')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Set the window to foreground after initializing the service'
        )]
        [switch] $SetForeground,
        ###############################################################################
        [Alias('Escape')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Send Escape key to the window after initializing the service'
        )]
        [switch] $SendKeyEscape,
        ###############################################################################
        [Alias('HoldKeyboardFocus')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Hold keyboard focus when sending keys after initializing the service'
        )]
        [switch] $SendKeyHoldKeyboardFocus,
        ###############################################################################
        [Alias('UseShiftEnter')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use Shift+Enter when sending keys after initializing the service'
        )]
        [switch] $SendKeyUseShiftEnter,
        ###############################################################################
        [Alias('DelayMilliSeconds')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Delay in milliseconds when sending keys after initializing the service'
        )]
        [int] $SendKeyDelayMilliSeconds,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Use session only for the WireGuard service'
        )]
        [switch] $SessionOnly,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Clear session when initializing the service'
        )]
        [switch] $ClearSession,
        ###############################################################################
        [Alias('FromPreferences')]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip session when initializing the service'
        )]
        [switch] $SkipSession,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Generate QR code for easy mobile setup')
        )]
        [switch] $ShowQRCode,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Skip Docker initialization (used when already ' +
                'called by parent function)')
        )]
        [switch] $NoDockerInitialize,
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

        # ensure the wireguard service is running unless explicitly skipped
        if (-not $NoDockerInitialize) {

            # log verbose message about ensuring service availability
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

            # log verbose message about skipping docker initialization
            Microsoft.PowerShell.Utility\Write-Verbose `
                'Skipping Docker initialization as requested'
        }

        #######################################################################
        # define helper function to validate peer name format and constraints
        function TestPeerNameFormat {

            param([string]$peerName)

            # check for null or whitespace peer name
            if ([string]::IsNullOrWhiteSpace($peerName)) {
                throw 'Peer name cannot be empty or whitespace'
            }

            # check for peer name length exceeding maximum allowed
            if ($peerName.Length -gt 100) {
                throw ('Peer name is too long. Maximum length is 100 ' +
                    'characters')
            }

            # define list of characters that are invalid for peer names
            $invalidChars = @('<', '>', '"', '/', '\', '|', '?', '*', ':')

            # check each character in peer name for invalid characters
            foreach ($char in $invalidChars) {

                # throw error if invalid character is found
                if ($peerName.Contains($char)) {
                    throw "Peer name contains invalid character '$char'"
                }
            }

            return $true
        }

        #######################################################################
        # define helper function to check if peer configuration already exists
        function TestPeerExist {

            param([string]$peerName)

            try {

                # determine peer id format (peer_<name> for named peers)
                $peerId = "peer_${peerName}"

                # check if peer directory exists in container
                $peerExists = docker exec $ContainerName sh -c `
                    "test -d /config/$peerId && echo 'exists' || echo 'not found'"

                # check if main server config exists and contains peer reference
                $serverConfigExists = docker exec $ContainerName sh -c `
                    "test -f /config/wg_confs/wg0.conf && echo 'exists' || echo 'not found'"

                if ($serverConfigExists -eq 'exists') {
                    $peerInConfig = docker exec $ContainerName sh -c `
                        "grep -q '# $peerId' /config/wg_confs/wg0.conf && echo 'found' || echo 'not found'"

                    return ($peerExists -eq 'exists' -or $peerInConfig -eq 'found')
                }

                return ($peerExists -eq 'exists')
            }
            catch {

                # log warning if unable to verify peer existence
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Unable to verify peer existence: $_"

                # proceed with creation attempt if verification fails
                return $false
            }
        }

        #######################################################################
        # define helper function to ensure server configuration exists
        function EnsureServerConfig {

            try {
                # check if server config exists
                $serverConfigExists = docker exec $ContainerName sh -c `
                    "test -f /config/wg_confs/wg0.conf && echo 'exists' || echo 'not found'"

                if ($serverConfigExists -eq 'not found') {
                    # create server keys if they don't exist
                    docker exec $ContainerName sh -c `
                        "mkdir -p /config/server"

                    docker exec $ContainerName sh -c `
                        "wg genkey | tee /config/server/privatekey-server | wg pubkey > /config/server/publickey-server"

                    # set permissions on server keys
                    docker exec $ContainerName sh -c `
                        "chmod 600 /config/server/privatekey-server /config/server/publickey-server"

                    # create basic server configuration
                    $serverConfig = @"
[Interface]
Address = 10.13.13.1/24
ListenPort = $ServicePort
PrivateKey = $(docker exec $ContainerName sh -c "cat /config/server/privatekey-server")
PostUp = iptables -A FORWARD -i %i -j ACCEPT; iptables -A FORWARD -o %i -j ACCEPT; iptables -t nat -A POSTROUTING -o eth+ -j MASQUERADE
PostDown = iptables -D FORWARD -i %i -j ACCEPT; iptables -D FORWARD -o %i -j ACCEPT; iptables -t nat -D POSTROUTING -o eth+ -j MASQUERADE
"@

                    # clean up server config for Unix compatibility
                    $serverConfig = $serverConfig -replace "`r`n", "`n"
                    $serverConfig = $serverConfig.Trim()

                    # escape special characters in server config
                    $escapedConfig = $serverConfig -replace "'", "'\\''" -replace '\$', '\\$' -replace '\\', '\\\\'

                    # write server config to container
                    docker exec $ContainerName sh -c `
                        "echo '$escapedConfig' > /config/wg_confs/wg0.conf && chmod 600 /config/wg_confs/wg0.conf"

                    # restart wireguard interface
                    docker exec $ContainerName sh -c `
                        "wg-quick down wg0 2>/dev/null || true; wg-quick up wg0"
                }

                return $true
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning `
                    "Failed to ensure server configuration: $_"
                return $false
            }
        }

        #######################################################################
        # define helper function to get next available IP address
        function GetNextClientIP {

            try {
                # get existing client IPs from server config
                $existingIPs = docker exec $ContainerName sh -c `
                    "grep -o '10\.13\.13\.[0-9]\+' /config/wg_confs/wg0.conf || true"

                # find next available IP (starting from 10.13.13.2)
                for ($i = 2; $i -le 254; $i++) {
                    $testIP = "10.13.13.$i"
                    if ($existingIPs -notcontains $testIP) {
                        return $testIP
                    }
                }

                throw "No available IP addresses in range 10.13.13.2-254"
            }
            catch {
                throw "Failed to determine next client IP: $_"
            }
        }
    }

    process {

        try {

            # validate peer name format using helper function
            TestPeerNameFormat -peerName $PeerName

            # check if peer already exists using helper function
            if (TestPeerExist -peerName $PeerName) {
                throw "A peer with name '$PeerName' already exists"
            }

            # ensure server configuration exists
            if (-not (EnsureServerConfig)) {
                throw "Failed to ensure WireGuard server configuration"
            }

            # ask for confirmation before creating the peer
            if ($PSCmdlet.ShouldProcess("WireGuard peer '$PeerName'",
                    'Add peer')) {

                # log verbose message about adding new peer
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Adding new WireGuard peer: $PeerName"

                # determine peer ID and get next available IP
                $peerId = "peer_${PeerName}"
                $clientIP = GetNextClientIP
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Assigned IP: $clientIP for peer $PeerName"

                # create peer directory in container
                docker exec $ContainerName sh -c `
                    "mkdir -p /config/$peerId"

                # generate peer keys
                docker exec $ContainerName sh -c `
                    "wg genkey | tee /config/$peerId/privatekey-$peerId | wg pubkey > /config/$peerId/publickey-$peerId"

                # set permissions on peer keys
                docker exec $ContainerName sh -c `
                    "chmod 600 /config/$peerId/privatekey-$peerId /config/$peerId/publickey-$peerId"

                # generate preshared key
                docker exec $ContainerName sh -c `
                    "wg genpsk > /config/$peerId/presharedkey-$peerId"

                # set permissions on preshared key
                docker exec $ContainerName sh -c `
                    "chmod 600 /config/$peerId/presharedkey-$peerId"

                # get server public key
                $serverPublicKey = docker exec $ContainerName sh -c `
                    "cat /config/server/publickey-server"

                # get peer public key
                $peerPublicKey = docker exec $ContainerName sh -c `
                    "cat /config/$peerId/publickey-$peerId"

                # get external IP for endpoint
                try {
                    $externalIP = Microsoft.PowerShell.Utility\Invoke-RestMethod `
                        -Verbose:$false `
                        -ProgressAction Continue `
                        -Uri "https://api.ipify.org" `
                        -TimeoutSec 10
                } catch {
                    $externalIP = "YOUR_SERVER_IP"
                    Microsoft.PowerShell.Utility\Write-Warning `
                        "Could not determine external IP address. Please replace YOUR_SERVER_IP in the configuration."
                }

                # create peer configuration file
                $peerConfig = @"
[Interface]
Address = $clientIP/24
PrivateKey = $(docker exec $ContainerName sh -c "cat /config/$peerId/privatekey-$peerId")
DNS = $DNS

[Peer]
PublicKey = $serverPublicKey
PresharedKey = $(docker exec $ContainerName sh -c "cat /config/$peerId/presharedkey-$peerId")
Endpoint = ${externalIP}:$ServicePort
AllowedIPs = $AllowedIPs
"@

                # clean up peer config for Unix compatibility
                $peerConfig = $peerConfig -replace "`r`n", "`n"
                $peerConfig = $peerConfig.Trim()

                # escape special characters in peer config
                $escapedConfig = $peerConfig -replace "'", "'\\''" -replace '\$', '\\$' -replace '\\', '\\\\'

                # save peer configuration in container
                docker exec $ContainerName sh -c `
                    "echo -n '$escapedConfig' > /config/$peerId/$peerId.conf && chmod 600 /config/$peerId/$peerId.conf"

                # create peer section for server configuration
                $peerSection = @"

# $peerId
[Peer]
PublicKey = $peerPublicKey
PresharedKey = $(docker exec $ContainerName sh -c "cat /config/$peerId/presharedkey-$peerId")
AllowedIPs = $clientIP/32
"@

                # clean up peer section for Unix compatibility
                $peerSection = $peerSection -replace "`r`n", "`n"
                $peerSection = $peerSection.Trim()

                # escape special characters in peer section
                $escapedSection = $peerSection -replace "'", "'\\''" -replace '\$', '\\$' -replace '\\', '\\\\'

                # append peer to server config
                docker exec $ContainerName sh -c `
                    "echo '$escapedSection' >> /config/wg_confs/wg0.conf && chmod 600 /config/wg_confs/wg0.conf"

                # verify peer section was added
                $peerInConfig = docker exec $ContainerName sh -c `
                    "grep -q '# $peerId' /config/wg_confs/wg0.conf && echo 'found' || echo 'not found'"
                if ($peerInConfig -ne 'found') {
                    throw "Failed to verify peer '$PeerName' in server configuration"
                }

                # restart wireguard to apply changes
                docker exec $ContainerName sh -c `
                    "wg-quick down wg0 2>/dev/null || true; wg-quick up wg0"

                # check if peer creation was successful
                if ($LASTEXITCODE -ne 0) {
                    throw "Failed to restart WireGuard with new peer configuration"
                }

                # log verbose message about successful peer addition
                Microsoft.PowerShell.Utility\Write-Verbose `
                    "Peer $PeerName added successfully with IP $clientIP"

                # verify configurations
                Microsoft.PowerShell.Utility\Write-Verbose "Generated peer configuration:`n$peerConfig"
                docker exec $ContainerName cat /config/$peerId/$peerId.conf | Microsoft.PowerShell.Utility\Write-Verbose
                Microsoft.PowerShell.Utility\Write-Verbose "Updated server configuration:`n$peerSection"
                docker exec $ContainerName cat /config/wg_confs/wg0.conf | Microsoft.PowerShell.Utility\Write-Verbose

                # save configuration to file if requested by user
                if ($SaveConfig) {

                    # ask for confirmation before saving configuration file
                    if ($PSCmdlet.ShouldProcess(
                            "Configuration file for peer '$PeerName'",
                            "Save to $OutputPath")) {

                        # create output directory if it doesn't exist
                        if (-not (Microsoft.PowerShell.Management\Test-Path `
                                    -LiteralPath $OutputPath)) {

                            # create directory with force flag to create parent dirs
                            $null = Microsoft.PowerShell.Management\New-Item `
                                -ItemType Directory `
                                -Path $OutputPath `
                                -Force
                        }

                        # build full path for configuration file
                        $configFile = Microsoft.PowerShell.Management\Join-Path `
                            -Path $OutputPath `
                            -ChildPath "$PeerName.conf"

                        # write peer configuration to file with utf8 encoding
                        $peerConfig | Microsoft.PowerShell.Utility\Out-File `
                            -FilePath $configFile `
                            -Encoding utf8 `
                            -Force

                        # set permissions on local config file
                        if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $configFile) {
                            $acl = Microsoft.PowerShell.Security\Get-Acl $configFile
                            $acl.SetAccessRuleProtection($true, $false)
                            $rule = Microsoft.PowerShell.Utility\New-Object System.Security.AccessControl.FileSystemAccessRule(
                                [System.Security.Principal.WindowsIdentity]::GetCurrent().Name,
                                "FullControl",
                                "Allow"
                            )
                            $acl.SetAccessRule($rule)
                            Microsoft.PowerShell.Security\Set-Acl $configFile $acl
                        }

                        # display success message with configuration file location
                        Microsoft.PowerShell.Utility\Write-Host `
                            -ForegroundColor Green `
                            "Peer configuration saved to: $configFile"
                    }
                }

                # show qr code if requested by user
                if ($ShowQRCode) {

                   $params = GenXdev\Copy-IdenticalParamValues `
                    -BoundParameters $PSBoundParameters `
                    -FunctionName "GenXdev\Get-WireGuardPeerQRCode" `
                    -DefaultValues (Microsoft.PowerShell.Utility\Get-Variable `
                        -Scope Local `
                        -ErrorAction SilentlyContinue)

                    GenXdev\Get-WireGuardPeerQRCode @params
                }

                # create hash table with peer details for return object
                $peerDetails = @{
                    PeerName          = $PeerName
                    ClientIP          = $clientIP
                    Configuration     = $peerConfig
                    ConfigurationPath = if ($SaveConfig) { $configFile } else { $null }
                    QRCodeGenerated   = $ShowQRCode
                }

                # return peer details as powershell custom object
                return [PSCustomObject]$peerDetails
            }
        }
        catch [System.Net.WebException] {

            # log error for network-related exceptions
            Microsoft.PowerShell.Utility\Write-Error `
                "Network error when adding WireGuard peer: $_"
            throw
        }
        catch [System.TimeoutException] {

            # log error for timeout-related exceptions
            Microsoft.PowerShell.Utility\Write-Error `
                "Timeout when adding WireGuard peer: $_"
            throw
        }
        catch {

            # log error for all other exceptions
            Microsoft.PowerShell.Utility\Write-Error `
                "Failed to add WireGuard peer: $_"
            throw
        }
    }

    end {

    }
}