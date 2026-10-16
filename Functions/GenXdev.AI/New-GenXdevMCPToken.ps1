<#
.SYNOPSIS
    Generates a secure random Bearer token for GenXdev MCP server
    authentication.

.DESCRIPTION
    Creates a cryptographically secure random token and optionally stores
    it in the user environment variable GENXDEV_MCP_TOKEN. The token is
    used to authenticate requests to the GenXdev MCP server from clients on
    the local network.

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

.PARAMETER Length
    The length of the token in bytes. Default is 32 bytes (256 bits),
    which produces a 44-character base64 string. Minimum is 16 bytes (128
    bits).

.PARAMETER SetProtectedFile
    If specified, stores the generated token in a DPAPI protected token file.
    The Windows Data Protection API encrypts it to the current user and
    machine, so it decrypts silently without ever prompting for a password,
    and other users cannot read it. This is the recommended store. Any token
    still held in the GENXDEV_MCP_TOKEN environment variable is removed, since
    that variable leaks the token into every process running as this user.

.PARAMETER ProtectedFilePath
    Path of the DPAPI protected token file. Defaults to
    %LOCALAPPDATA%\GenXdev\mcp-token.clixml.

.PARAMETER SetEnvironmentVariable
    If specified, stores the generated token in the GENXDEV_MCP_TOKEN user
    environment variable. This makes the token available to the MCP server
    and VS Code MCP client automatically, but the value is readable by every
    process running as the current user, including any child process.

.PARAMETER Force
    If specified, overwrites an existing GENXDEV_MCP_TOKEN environment
    variable without prompting. Only used with -SetEnvironmentVariable.

.EXAMPLE
    New-GenXdevMCPToken

    Generates and displays a new random token without storing it.

.EXAMPLE
    New-GenXdevMCPToken -SetProtectedFile

    Generates a new token and stores it in the DPAPI protected token file,
    which the MCP server reads without prompting.

.EXAMPLE
    New-GenXdevMCPToken -SetEnvironmentVariable

    Generates a new token and stores it in the GENXDEV_MCP_TOKEN user
    environment variable. Prompts if a token already exists.

.EXAMPLE
    New-GenXdevMCPToken -Length 64 -SetEnvironmentVariable -Force

    Generates a longer 64-byte token, stores it in the environment
    variable, and overwrites any existing token without prompting.

.EXAMPLE
    $token = New-GenXdevMCPToken
    Start-GenXdevMCPServer -Token $token

    Generates a token and passes it directly to the MCP server without
    storing in environment.

.OUTPUTS
    System.String. The generated Bearer token as a base64-encoded string.

.NOTES
    - Token is cryptographically random using
        System.Security.Cryptography.RandomNumberGenerator
    - Default 32-byte token provides 256 bits of entropy (highly secure)
    - Stored tokens persist across PowerShell sessions and system reboots
    - To remove the token, use:
        [System.Environment]::SetEnvironmentVariable('GENXDEV_MCP_TOKEN',
        $null, 'User')
#>

function New-GenXdevMCPToken {
    [CmdletBinding(SupportsShouldProcess)]
    param(
        [Parameter(Mandatory = $false, HelpMessage = "The length of the token in bytes (default: 32, minimum: 16)")]
        [ValidateRange(16, 128)]
        [int]$Length = 32,

        [Parameter(Mandatory = $false, HelpMessage = "Store the token in the DPAPI protected token file")]
        [switch]$SetProtectedFile,

        [Parameter(Mandatory = $false, HelpMessage = "Path of the DPAPI protected token file")]
        [ValidateNotNullOrEmpty()]
        [string]$ProtectedFilePath = "$env:LOCALAPPDATA\GenXdev\mcp-token.clixml",

        [Parameter(Mandatory = $false, HelpMessage = "Store the token in GENXDEV_MCP_TOKEN user environment variable")]
        [switch]$SetEnvironmentVariable,

        [Parameter(Mandatory = $false, HelpMessage = "Overwrite an existing token without prompting")]
        [switch]$Force
    )

    # Generate cryptographically secure random bytes
    $randomBytes = [byte[]]::new($Length)
    $rng = [System.Security.Cryptography.RandomNumberGenerator]::Create()
    try {
        $rng.GetBytes($randomBytes)
    }
    finally {
        $rng.Dispose()
    }

    # Convert to base64 for safe transmission (URL-safe characters)
    $token = [System.Convert]::ToBase64String($randomBytes)

    # Display token information
    Microsoft.PowerShell.Utility\Write-Host "Generated secure MCP token ($Length bytes, $($token.Length) characters):" -ForegroundColor Green
    Microsoft.PowerShell.Utility\Write-Host $token -ForegroundColor Cyan

    # resolve which store the token should go into
    $storeTarget = $null
    if ($SetProtectedFile) {
        $storeTarget = $ProtectedFilePath
    }
    elseif ($SetEnvironmentVariable) {
        $storeTarget = 'GENXDEV_MCP_TOKEN'
    }

    if ($null -eq $storeTarget) {

        Microsoft.PowerShell.Utility\Write-Host "`nTo use this token:" -ForegroundColor Gray
        Microsoft.PowerShell.Utility\Write-Host "  1. Store it: New-GenXdevMCPToken -SetProtectedFile" -ForegroundColor Gray
        Microsoft.PowerShell.Utility\Write-Host "  2. Or pass it: Start-GenXdevMCPServer -Token `"$token`"" -ForegroundColor Gray

        return $token
    }

    # a token that is already stored is only replaced on request
    $existingToken = if ($SetProtectedFile) {

        GenXdev\Get-GenXdevMCPToken -ProtectedFilePath $ProtectedFilePath `
            -ProtectedFileOnly
    }
    else {

        [System.Environment]::GetEnvironmentVariable('GENXDEV_MCP_TOKEN', 'User')
    }

    if (-not [string]::IsNullOrEmpty($existingToken) -and -not $Force) {

        $message = "An MCP token is already configured in ${storeTarget}. Overwrite it?"
        $title = 'Confirm Token Replacement'
        $yes = Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription '&Yes', 'Replace the existing token'
        $no = Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription '&No', 'Keep the existing token'
        $options = [System.Management.Automation.Host.ChoiceDescription[]]($yes, $no)
        # queued keystrokes must not replace or keep the token on your behalf
        if (-not [Console]::IsInputRedirected) {
            while ([Console]::KeyAvailable) { $null = [Console]::ReadKey() }
        }

        $result = $host.UI.PromptForChoice($title, $message, $options, 1)

        if ($result -eq 1) {

            Microsoft.PowerShell.Utility\Write-Host 'Keeping existing token.' -ForegroundColor Yellow
            return $existingToken
        }
    }

    if ($SetProtectedFile) {

        if (-not $PSCmdlet.ShouldProcess($ProtectedFilePath, 'Write DPAPI protected token file')) {
            return $token
        }

        try {
            $tokenDirectory = [System.IO.Path]::GetDirectoryName($ProtectedFilePath)

            if (-not [System.IO.Directory]::Exists($tokenDirectory)) {
                $null = [System.IO.Directory]::CreateDirectory($tokenDirectory)
            }

            # the Windows Data Protection API encrypts the secret to this user on
            # this machine, so reading it back never prompts for a password
            Microsoft.PowerShell.Security\ConvertTo-SecureString -String $token -AsPlainText -Force |
                Microsoft.PowerShell.Utility\Export-Clixml -Path $ProtectedFilePath -Force

            Microsoft.PowerShell.Utility\Write-Host "`nToken stored in ${ProtectedFilePath}." -ForegroundColor Green
            Microsoft.PowerShell.Utility\Write-Host 'The token will be available to:' -ForegroundColor Gray
            Microsoft.PowerShell.Utility\Write-Host '  - GenXdev MCP Server (via Start-GenXdevMCPServer)' -ForegroundColor Gray
            Microsoft.PowerShell.Utility\Write-Host '  - VS Code MCP Client (paste it once at the first prompt)' -ForegroundColor Gray

            # a token left in the environment variable would leak into every child
            # process, so the stale value is removed now the protected file holds one
            if (-not [string]::IsNullOrEmpty(
                    [System.Environment]::GetEnvironmentVariable(
                        'GENXDEV_MCP_TOKEN', 'User'))) {

                [System.Environment]::SetEnvironmentVariable(
                    'GENXDEV_MCP_TOKEN', $null, 'User')

                Microsoft.PowerShell.Management\Remove-Item -Path 'Env:\GENXDEV_MCP_TOKEN' `
                    -ErrorAction SilentlyContinue

                Microsoft.PowerShell.Utility\Write-Host `
                    'Removed the now stale GENXDEV_MCP_TOKEN environment variable.' `
                    -ForegroundColor Yellow
            }
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to write the protected token file: $($_.Exception.Message)"
        }
    }
    else {

        if (-not $PSCmdlet.ShouldProcess('GENXDEV_MCP_TOKEN', 'Set user environment variable')) {
            return $token
        }

        try {
            [System.Environment]::SetEnvironmentVariable('GENXDEV_MCP_TOKEN', $token, 'User')
            Microsoft.PowerShell.Utility\Write-Host "`nToken stored in GENXDEV_MCP_TOKEN user environment variable." -ForegroundColor Green
            Microsoft.PowerShell.Utility\Write-Host "The token will be available to:" -ForegroundColor Gray
            Microsoft.PowerShell.Utility\Write-Host "  - GenXdev MCP Server (via Start-GenXdevMCPServer)" -ForegroundColor Gray
            Microsoft.PowerShell.Utility\Write-Host "  - VS Code MCP Client (via .vscode/mcp.json)" -ForegroundColor Gray
            Microsoft.PowerShell.Utility\Write-Host "`nRestart VS Code to apply the new token to the MCP client." -ForegroundColor Yellow
            Microsoft.PowerShell.Utility\Write-Host "Restart the MCP server task to apply the new token to the server." -ForegroundColor Yellow
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error "Failed to set environment variable: $($_.Exception.Message)"
        }
    }

    # Return the token
    return $token
}