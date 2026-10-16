<#
.SYNOPSIS
Confirms user consent for installing third-party software, using
preferences for persistent choices.

.DESCRIPTION
This function acts as a custom ShouldProcess mechanism specifically for
software installations. It checks a user preference to determine if
automatic installation is allowed for the specified application. If no
preference is set, it prompts the user with a clear explanation of what
will be installed, the source, potential risks, and options to allow or
deny the installation (with options for one-time or persistent choices).

This ensures explicit user consent before proceeding with any installation,
helping to mitigate potential legal risks by requiring affirmative action
from the user. The prompt clearly states that the module author (GenXdev)
is not responsible for third-party software, and that the user is
consenting to the installation at their own risk.

Preferences are stored using the GenXdev preferences system
(Get-GenXdevPreference / Set-GenXdevPreference), allowing users to set
"always allow" for a specific application or for every GenXdev
third-party installation. Each of those can be scoped to this machine
only, or to all machines through the preferences database inside the
OneDrive folder, making it convenient while remaining legally sound.

If consent is denied (or preference is set to deny), the function returns $false and does not
proceed with installation. If allowed, it returns $true.

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

.PARAMETER ApplicationName
The name of the application or software being installed (e.g., "Docker
Desktop", "Sysinternals Suite"). This is used to create a unique
preference key like "AllowInstall_DockerDesktop".

.PARAMETER Source
The source of the installation (e.g., "Winget", "PowerShell Gallery",
"apt-get in WSL", "DotNet CLI"). This is included in the explanation
prompt for transparency.

.PARAMETER Description
Optional detailed description of what the software does and why it's
being installed. If not provided, a generic message is used.

.PARAMETER Publisher
Optional publisher or vendor of the software (e.g., "Microsoft", "Docker
Inc."). Included in the prompt for clarity.

.PARAMETER AutoConsent
Automatically consent to this installation type and set persistent flag..

.EXAMPLE
if (Confirm-InstallationConsent -ApplicationName "Docker Desktop" `
        -Source "Winget") {
    # Proceed with installation
    Microsoft.WinGet.Client\Install-WinGetPackage `
        -Id "Docker.DockerDesktop"
}

This checks consent before installing Docker Desktop via Winget.

.EXAMPLE
Confirm-InstallationConsent -ApplicationName "Pester" `
    -Source "PowerShell Gallery" -Publisher "Pester Team" `
    -Description "Required for unit testing in PowerShell modules."

Prompts with detailed information before installing the Pester module.

.NOTES
- Preference keys are formatted as "AllowInstall_<ApplicationName>" (spaces
  removed for simplicity).
- Global consent key is "AllowInstall_GenXdevGlobal" which applies to all
  third-party installations.
- Choices scoped to this machine are stored in the local preferences
  database. Choices scoped to all machines are stored under the same key in
  the preferences database inside the OneDrive folder, so they travel with
  the user (see Get-GenXdevPreferencesDatabasePath and the
  -PreferencesDatabasePath parameter).
- The prompt offers consent for this session, always for just this
  application, or always for every application, each of the latter two
  either on this machine only or on all machines, plus No and Help.
- If denied, no installation occurs, and the function returns $false.
- For legal soundness: The prompt explicitly requires user consent,
  disclaims liability, and explains risks (e.g., third-party software may
  have its own terms, potential security implications).
- Integrate this into your Ensure* functions by replacing automatic
  installations with a check like: if (-not (Confirm-InstallationConsent
  ...)) { throw "Installation consent denied." }
- This function does not perform the installation itself—it's purely for
  consent checking.
#>
function Confirm-InstallationConsent {

    [CmdletBinding()]
    [OutputType([System.Boolean])]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The name of the application or software being installed."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $ApplicationName,

        ###############################################################################
        [Parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "The source of the installation (e.g., Winget, PowerShell Gallery)."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Source,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Optional description of the software and its purpose."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Description = "This software is required for certain features in the GenXdev modules.",

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Optional publisher or vendor of the software."
        )]
        [ValidateNotNullOrEmpty()]
        [string] $Publisher = "Third-party vendor",

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Automatically consent to this installation type and set persistent flag.."
        )]
        [switch] $AutoConsent,

        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Automatically consent to ALL third-party software installations and set persistent flag."
        )]
        [switch] $AutoConsentAllPackages
    )

    begin {

        # normalize application name by removing spaces to create safe key
        $safeAppName = $ApplicationName -replace '\s+', ''

        # create preference key for this application
        $preferenceKey = "AllowInstall_${safeAppName}"

        # the choices scoped to all machines live in the same preferences database
        # name underneath OneDrive, so they travel with the user
        $syncedPreferencesPath = $null
        if (-not [string]::IsNullOrEmpty($env:OneDrive)) {
            $syncedPreferencesPath = Microsoft.PowerShell.Management\Join-Path $env:OneDrive `
                'GenXdev.PowerShell\Preferences'
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Checking consent for installing '${ApplicationName}' from '${Source}'."
    }

    process {

        $autoConcent = $AutoConsent -or $AutoConsentAllPackages

        # build splatted params for preference cmdlets to forward
        # PreferencesDatabasePath, SessionOnly etc. (when available)
        $getPreferencesParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-GenXdevPreference'

        # check the global and the per application consent in both stores
        $globalConsentKey = "AllowInstall_GenXdevGlobal"
        $globalConsent = GenXdev\Get-GenXdevPreference @getPreferencesParams -Name $globalConsentKey

        if (-not $autoConcent) {

            if ($globalConsent -eq 'true') {

                Microsoft.PowerShell.Utility\Write-Verbose "Stored global GenXdev consent allows installation of '${ApplicationName}'."
                $autoConcent = $true
            }

            if (-not $autoConcent) {

                # check existing preference for this application
                $existingPref = GenXdev\Get-GenXdevPreference @getPreferencesParams -Name $preferenceKey

                if ($existingPref -eq 'true') {

                    Microsoft.PowerShell.Utility\Write-Verbose "Stored consent allows installation of '${ApplicationName}'."
                    $autoConcent = $true
                }
            }

            # the synced store carries the allowances granted for all machines
            if (-not $autoConcent -and $null -ne $syncedPreferencesPath) {

                $syncedGlobalConsent = GenXdev\Get-GenXdevPreference @getPreferencesParams `
                    -Name $globalConsentKey -PreferencesDatabasePath $syncedPreferencesPath

                if ($syncedGlobalConsent -eq 'true') {

                    Microsoft.PowerShell.Utility\Write-Verbose "Synced global consent allows installation of '${ApplicationName}'."
                    $autoConcent = $true
                }
                else {

                    $syncedAppConsent = GenXdev\Get-GenXdevPreference @getPreferencesParams `
                        -Name $preferenceKey -PreferencesDatabasePath $syncedPreferencesPath

                    if ($syncedAppConsent -eq 'true') {

                        Microsoft.PowerShell.Utility\Write-Verbose "Synced consent allows installation of '${ApplicationName}'."
                        $autoConcent = $true
                    }
                }
            }
        }

        $setPreferencesParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Set-GenXdevPreference';

        $syncedSetParams = @{}
        if ($null -ne $syncedPreferencesPath) {
            $syncedSetParams['PreferencesDatabasePath'] = $syncedPreferencesPath
        }

        if ($autoConcent) {

            if ($AutoConsentAllPackages) {

                GenXdev\Set-GenXdevPreference @setPreferencesParams -Name $globalConsentKey -Value 'true'
                Microsoft.PowerShell.Utility\Write-Verbose "Automatic global consent granted and persistent allowance set for ALL third party software'."
                return $true
            }

            if ($AutoConsent) {

                GenXdev\Set-GenXdevPreference @setPreferencesParams -Name $preferenceKey -Value 'true'
                Microsoft.PowerShell.Utility\Write-Verbose "Automatic consent granted and persistent allowance set for '${ApplicationName}'."
                return $true
            }

            Microsoft.PowerShell.Utility\Write-Verbose "Allowance for '${ApplicationName}' was already stored."
            return $true
        }

        # prepare to prompt user for consent
        # display header for the consent prompt
        Microsoft.PowerShell.Utility\Write-Host "`n" -NoNewline
        Microsoft.PowerShell.Utility\Write-Host "### " -ForegroundColor Cyan -NoNewline
        Microsoft.PowerShell.Utility\Write-Host "Installation Consent Required" -ForegroundColor Cyan -NoNewline
        Microsoft.PowerShell.Utility\Write-Host " ###`n" -ForegroundColor Cyan

        # display software details
        Microsoft.PowerShell.Utility\Write-Host (
            "This PowerShell module (GenXdev) needs to install third-party software:"
        ) -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host "  Software: " -ForegroundColor White -NoNewline
        Microsoft.PowerShell.Utility\Write-Host "${ApplicationName}" -ForegroundColor Green
        Microsoft.PowerShell.Utility\Write-Host "  Publisher: " -ForegroundColor White -NoNewline
        Microsoft.PowerShell.Utility\Write-Host "${Publisher}" -ForegroundColor Green
        Microsoft.PowerShell.Utility\Write-Host "  Source: " -ForegroundColor White -NoNewline
        Microsoft.PowerShell.Utility\Write-Host "${Source}" -ForegroundColor Green
        Microsoft.PowerShell.Utility\Write-Host "  Purpose: " -ForegroundColor White -NoNewline
        Microsoft.PowerShell.Utility\Write-Host "${Description}" -ForegroundColor Cyan

        # display legal notes
        Microsoft.PowerShell.Utility\Write-Host "`nImportant Legal and Safety Notes:" -ForegroundColor Yellow
        Microsoft.PowerShell.Utility\Write-Host (
            "• This software is provided by a third party (${Publisher}), not by GenXdev or its author."
        ) -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host (
            "• By consenting, you agree to download and install this software at your own risk."
        ) -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host (
            "• GenXdev makes no warranties about the software's safety, functionality, or compliance."
        ) -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host (
            "• Third-party software may have its own license terms, privacy policies, and potential risks."
        ) -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host (
            "• You are responsible for reviewing the software's terms and ensuring compliance."
        ) -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host (
            "• No liability: The author of GenXdev assumes no responsibility for any issues."
        ) -ForegroundColor White
        Microsoft.PowerShell.Utility\Write-Host ""

        # warn when the all machines choices cannot travel with the user
        if ($null -eq $syncedPreferencesPath) {
            Microsoft.PowerShell.Utility\Write-Warning (
                'OneDrive is not available, so the choices for all machines are ' +
                'stored on this machine only.'
            )
        }

        # keep asking until a decision is made, so Help can be requested
        while ($true) {

            # set up prompt for user choice
            $title = "Installation Consent for '${ApplicationName}'"
            $message = "Do you consent to install this third-party software?"

            $choices = @(
                Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&Yes, this session", "Yes (this session only)"
                Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&Always — this app, this machine", "Always allow this application on this machine"
                Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&Every machine — this app", "Always allow this application on all machines, through OneDrive"
                Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&System-wide — all apps, this machine", "Always allow all third-party software on this machine"
                Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&Global — all apps, every machine", "Always allow all third-party software on all machines, through OneDrive"
                Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&No, just this time", "No (this time only)"
                Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&Help", "Show additional help information"
            )

            $defaultChoice = 5  # Default to "No"
            # queued keystrokes must not answer this prompt on your behalf
            if (-not [Console]::IsInputRedirected) {
                while ([Console]::KeyAvailable) { $null = [Console]::ReadKey() }
            }

            $choice = $Host.UI.PromptForChoice($title, $message, $choices, $defaultChoice)

            # handle user choice
            switch ($choice) {
                0 {
                    # Yes, this session
                    GenXdev\Set-GenXdevPreference @setPreferencesParams -Name $preferenceKey -Value 'true' -SessionOnly
                    Microsoft.PowerShell.Utility\Write-Verbose "User consented for this session only."
                    return $true
                }
                1 {
                    # Always, this application, this machine
                    GenXdev\Set-GenXdevPreference @setPreferencesParams -Name $preferenceKey -Value 'true'
                    Microsoft.PowerShell.Utility\Write-Host (
                        "Allowance for '${ApplicationName}' stored on this machine."
                    ) -ForegroundColor Green
                    return $true
                }
                2 {
                    # Always, this application, all machines
                    GenXdev\Set-GenXdevPreference @setPreferencesParams @syncedSetParams `
                        -Name $preferenceKey -Value 'true'
                    Microsoft.PowerShell.Utility\Write-Host (
                        "Allowance for '${ApplicationName}' stored for all machines."
                    ) -ForegroundColor Green
                    return $true
                }
                3 {
                    # Always, all applications, this machine
                    GenXdev\Set-GenXdevPreference @setPreferencesParams `
                        -Name $globalConsentKey -Value 'true'
                    Microsoft.PowerShell.Utility\Write-Host (
                        "Allowance for all third-party software stored on this machine."
                    ) -ForegroundColor Green
                    return $true
                }
                4 {
                    # Always, all applications, all machines
                    GenXdev\Set-GenXdevPreference @setPreferencesParams @syncedSetParams `
                        -Name $globalConsentKey -Value 'true'
                    Microsoft.PowerShell.Utility\Write-Host (
                        "Allowance for all third-party software stored for all machines."
                    ) -ForegroundColor Green
                    return $true
                }
                5 {
                    # No
                    Microsoft.PowerShell.Utility\Write-Host "Installation denied for this time." -ForegroundColor Yellow
                    return $false
                }
                6 {
                    # Help
                    Microsoft.PowerShell.Utility\Write-Host "`nAdditional Help:" -ForegroundColor Cyan
                    Microsoft.PowerShell.Utility\Write-Host (
                        "• 'Yes, this session' allows this installation until the session ends."
                    ) -ForegroundColor White
                    Microsoft.PowerShell.Utility\Write-Host (
                        "• The two 'this app' choices allow just this application, either on this machine only or on every machine through OneDrive."
                    ) -ForegroundColor White
                    Microsoft.PowerShell.Utility\Write-Host (
                        "• The two 'all apps' choices allow every third-party installation, again either on this machine only or on every machine through OneDrive."
                    ) -ForegroundColor White
                    Microsoft.PowerShell.Utility\Write-Host (
                        "• Allowances for all machines are stored in the preferences database underneath your OneDrive folder, so they follow you between machines."
                    ) -ForegroundColor White
                    Microsoft.PowerShell.Utility\Write-Host (
                        "• Manage them with Get-GenXdevPreference, Get-GenXdevPreferenceNames and Remove-GenXdevPreference."
                    ) -ForegroundColor White
                    Microsoft.PowerShell.Utility\Write-Host (
                        "• Preference key for this application: ${preferenceKey}"
                    ) -ForegroundColor White
                    Microsoft.PowerShell.Utility\Write-Host (
                        "• Preference key for all applications: ${globalConsentKey}"
                    ) -ForegroundColor White
                }
                default {
                    Microsoft.PowerShell.Utility\Write-Warning "Invalid choice. Treating as denial."
                    return $false
                }
            }
        }
    }

    end {
    }
}