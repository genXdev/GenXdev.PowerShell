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
"always allow" for specific applications or enable global consent for
all GenXdev third-party installations, making it convenient while
remaining legally sound. Preferences are stored locally only and are not
synced with OneDrive.

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
"apt-get in WSL", "dotnet CLI"). This is included in the explanation
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
- Preferences are stored locally using the GenXdev preferences system
  (Get-GenXdevPreference / Set-GenXdevPreference) and are not synced
  with OneDrive.
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

        Microsoft.PowerShell.Utility\Write-Verbose "Checking consent for installing '${ApplicationName}' from '${Source}'."
    }

    process {

        $autoConcent = $AutoConsent -or $AutoConsentAllPackages

        # build splatted params for preference cmdlets to forward
        # PreferencesDatabasePath, SessionOnly etc. (when available)
        $getPreferencesParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-GenXdevPreference'

        # check if global genxdev consent is set
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
        }

        $setPreferencesParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Set-GenXdevPreference';


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

        # set up prompt for user choice
        $title = "Installation Consent for '${ApplicationName}'"
        $message = "Do you consent to install this third-party software?"

        $choices = @(
            Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&Yes", "Yes (this time only)"
            Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&Always", "Always allow (set persistent preference)"
            Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&Global", "Always consent with GenXdev (allow all GenXdev third-party installations)"
            Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&No", "No (this time only)"
            Microsoft.PowerShell.Utility\New-Object System.Management.Automation.Host.ChoiceDescription "&Help", "Show additional help information"
        )

        $defaultChoice = 3  # Default to "No"
        $choice = $Host.UI.PromptForChoice($title, $message, $choices, $defaultChoice)

        # handle user choice
        switch ($choice) {
            0 {
                # Yes
                GenXdev\Set-GenXdevPreference @setPreferencesParams -Name $preferenceKey -Value 'true' -SessionOnly
                Microsoft.PowerShell.Utility\Write-Verbose "User consented for this installation only."
                return $true
            }
            1 {
                # Always
                GenXdev\Set-GenXdevPreference @setPreferencesParams -Name $preferenceKey -Value 'true'
                Microsoft.PowerShell.Utility\Write-Host "Persistent allowance set for '${ApplicationName}'." -ForegroundColor Green
                Microsoft.PowerShell.Utility\Write-Verbose "User set persistent allowance for '${ApplicationName}'."
                return $true
            }
            2 {
                # Global
                GenXdev\Set-GenXdevPreference @setPreferencesParams -Name $globalConsentKey -Value 'true'
                Microsoft.PowerShell.Utility\Write-Host (
                    "Global GenXdev consent enabled for all third-party software installations."
                ) -ForegroundColor Green
                Microsoft.PowerShell.Utility\Write-Verbose "User enabled global GenXdev consent for all third-party installations."
                return $true
            }
            3 {
                # No
                Microsoft.PowerShell.Utility\Write-Host "Installation denied for this time." -ForegroundColor Yellow
                return $false
            }
            4 {
                # Help
                Microsoft.PowerShell.Utility\Write-Host "`nAdditional Help:" -ForegroundColor Cyan
                Microsoft.PowerShell.Utility\Write-Host (
                    "• Choosing 'Always' options saves your preference via the GenXdev preferences system."
                ) -ForegroundColor White
                Microsoft.PowerShell.Utility\Write-Host (
                    "• 'Global' option enables automatic consent for ALL GenXdev third-party installations."
                ) -ForegroundColor White
                Microsoft.PowerShell.Utility\Write-Host (
                    "• You can manage preferences with Get-GenXdevPreference and Set-GenXdevPreference."
                ) -ForegroundColor White
                Microsoft.PowerShell.Utility\Write-Host (
                    "• This prompt ensures your explicit consent to avoid any automatic installations."
                ) -ForegroundColor White
                Microsoft.PowerShell.Utility\Write-Host (
                    "• The preference key for this application is: ${preferenceKey}"
                ) -ForegroundColor White
                Microsoft.PowerShell.Utility\Write-Host (
                    "• The global preference key is: ${globalConsentKey}"
                ) -ForegroundColor White
            }
            default {
                Microsoft.PowerShell.Utility\Write-Warning "Invalid choice. Treating as denial."
                return $false
            }
        }
    }

    end {
    }
}