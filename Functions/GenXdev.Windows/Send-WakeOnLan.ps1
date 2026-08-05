################################################################################
<#
.SYNOPSIS
Sends a Wake-on-LAN magic packet to wake up remote computers on the network.

.DESCRIPTION
Constructs and broadcasts a Wake-on-LAN (WOL) magic packet to the specified
MAC address(es). The magic packet is a UDP broadcast containing the target
MAC address repeated 16 times, which triggers supported network interfaces to
power on the computer. Supports custom broadcast addresses and ports.

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

.PARAMETER MacAddress
One or more MAC addresses to send the magic packet to. Accepts both colon (:)
and dash (-) separated formats (e.g., 00:11:22:33:44:55 or 00-11-22-33-44-55).

.PARAMETER BroadcastAddress
The broadcast IP address to send the magic packet to. Default is
255.255.255.255 which broadcasts to the local network.

.PARAMETER Port
The UDP port to send the magic packet to. Default is port 4000.

.EXAMPLE
Send-WakeOnLan -MacAddress "00:11:22:33:44:55"

Sends a magic packet to wake the computer with the specified MAC address.

.EXAMPLE
"00:11:22:33:44:55", "AA:BB:CC:DD:EE:FF" | Send-WakeOnLan -Port 9

Sends magic packets to multiple computers on port 9 via pipeline input.
#>
function Send-WakeOnLan {
    param
    (
        #######################################################################
        [Parameter(
            Mandatory = $true,
            ValueFromPipeline = $true,
            ValueFromPipelineByPropertyName = $true,
            HelpMessage = 'One or more MAC addresses to send the magic ' +
                'packet to (e.g., 00:11:22:33:44:55)'
        )]
        [ValidatePattern('^([0-9A-F]{2}[:-]){5}([0-9A-F]{2})$')]
        [string[]]
        $MacAddress,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The broadcast IP address to send the magic ' +
                'packet to (default: 255.255.255.255)'
        )]
        [ValidatePattern('^([0-9]{1,3}\.){3}([0-9]{1,3})$')]
        [string]$BroadcastAddress = "255.255.255.255",
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The UDP port to send the magic packet to ' +
                '(default: 4000)'
        )]
        [ValidateRange(1, 65535)]
        [int]$Port = 4000
    )

    begin {
        # instantiate a UDP client:
        $UDPclient = [System.Net.Sockets.UdpClient]::new()
    }
    process {
        foreach ($m in $MacAddress) {
            try {
                $currentMacAddress = $m

                # get byte array from mac address:
                $mac = $currentMacAddress -split '[:-]' |
                    # convert the hex number into byte:
                    Microsoft.PowerShell.Core\ForEach-Object {
                        [System.Convert]::ToByte($_, 16)
                    }

                #region compose the "magic packet"

                # create a byte array with 102 bytes initialized to 255 each:
                $packet = [byte[]](, 0xFF * 102)

                # leave the first 6 bytes untouched, and
                # repeat the target mac address bytes in bytes 7 through 102:
                6..101 | Microsoft.PowerShell.Core\ForEach-Object {
                    # $_ is indexing in the byte array,
                    # $_ % 6 produces repeating indices between 0 and 5
                    # (modulo operator)
                    $packet[$_] = $mac[($_ % 6)]
                }

                #endregion

                # connect to port 400 on broadcast address:
                $UDPclient.Connect(([System.Net.IPAddress]::Parse($BroadcastAddress)), $Port)

                # send the magic packet to the broadcast address:
                $null = $UDPclient.Send($packet, $packet.Length)
                Microsoft.PowerShell.Utility\Write-Verbose "sent magic packet to $currentMacAddress..."
            }
            catch {
                Microsoft.PowerShell.Utility\Write-Warning "Unable to send ${mac}: $_"
            }
        }
    }
    end {
        # release the UDF client and free its memory:
        $UDPclient.Close()
        $UDPclient.Dispose()
    }
}