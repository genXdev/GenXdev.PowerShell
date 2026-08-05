<#
.SYNOPSIS
Checks if Windows is up to date and optionally installs available updates.

.DESCRIPTION
This function checks for Windows updates, winget package updates, and PowerShell
module updates. It can display available updates or automatically install them.
The function requires administrative privileges to install Windows updates and
can optionally reboot the system if updates require a restart.

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

.PARAMETER Install
Automatically install available Windows updates, winget packages, and PowerShell
modules instead of just checking for their availability.

.PARAMETER AutoReboot
Automatically reboot the system if installed updates require a restart. This
parameter only has effect when Install is also specified.

.PARAMETER Criteria
Custom Windows Update search criteria. Defaults to finding all non-hidden,
uninstalled, important updates (excluding optional updates).

.PARAMETER IncludeDrivers
Include drivers in update search. When specified, driver updates will also be
considered in the search results.

.PARAMETER ProcessOptionalUpdates
Include optional updates in the search results that would normally be excluded.
When specified together with -Install, the user will be prompted for each
optional update individually to decide whether to install it. Without -Install,
optional updates are displayed separately from important updates.

.PARAMETER GroupByCategory
Group and color output by update category. This provides a more organized view
of available updates categorized by their type.

.PARAMETER NoBanner
Disable banner and status output. When specified, reduces verbose output and
displays only essential information.

.PARAMETER NoRebootCheck
Skip reboot requirement check and reporting. When specified, the function will
not check if a reboot is needed after installing updates.

.EXAMPLE
Invoke-WindowsUpdate

Checks for available Windows and winget updates without installing them.

.EXAMPLE
Invoke-WindowsUpdate -Install

Automatically installs all available Windows and winget updates.

.EXAMPLE
updatewindows -Install -AutoReboot

Installs all updates and reboots automatically if required using the alias.

.EXAMPLE
Invoke-WindowsUpdate -GroupByCategory

Displays available updates grouped by category for better organization.

.EXAMPLE
Invoke-WindowsUpdate -Install -ProcessOptionalUpdates

Installs all important updates automatically and prompts for each optional
update individually, allowing selective installation of optional updates.

.EXAMPLE
Invoke-WindowsUpdate -IncludeDrivers -Criteria "IsInstalled=0"

Checks for updates including drivers with custom search criteria.
#>
function Invoke-WindowsUpdate {

    [CmdletBinding(SupportsShouldProcess)]
    [Alias("updatewindows")]

    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Automatically install available Windows updates"
        )]
        [switch] $Install,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Automatically reboot if updates require a restart"
        )]
        [switch] $AutoReboot,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Custom Windows Update search criteria"
        )]
        [string] $Criteria = "IsInstalled=0 and IsHidden=0 and AutoSelectOnWebSites=1",
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include drivers in update search"
        )]
        [switch] $IncludeDrivers,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Include optional updates and prompt to install each one"
        )]
        [switch] $ProcessOptionalUpdates,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Group and color output by update category"
        )]
        [switch] $GroupByCategory,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Disable banner/status output"
        )]
        [switch] $NoBanner,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Skip reboot requirement check/reporting"
        )]
        [switch] $NoRebootCheck
        ###############################################################################
    )

    # initialize tracking variable for winget update availability
    [bool] $script:wingetHasUpdates = $false
    [bool] $script:moduleUpdatesAvailable = $false
    $script:updateSession = $null
    $script:updateSearcher = $null

    # verify administrative privileges are available for windows updates
    if (-not (GenXdev\CurrentUserHasElevatedRights)) {

        $json = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev\Invoke-WindowsUpdate" |
            Microsoft.PowerShell.Utility\ConvertTo-Json -Compress

        GenXdev\Invoke-CommandElevated ([ScriptBlock]::Create(@"

            `$params = '$json' | ConvertFrom-Json -AsHashTable
            GenXdev\Invoke-WindowsUpdate @params
"@)) -PauseAfterCompletion:(-not $Install) -JobDescription ($Install ? "Installing Updates" : "Checking for Updates");

        return;
    }

    # initialize com objects for windows update operations
    try {

        # create main session object for update operations
        $script:updateSession = Microsoft.PowerShell.Utility\New-Object `
            -ComObject Microsoft.Update.Session

        # create searcher object to find available updates
        $script:updateSearcher = $script:updateSession.CreateUpdateSearcher()
    }
    catch {

        Microsoft.PowerShell.Utility\Write-Error (
            "Failed to initialize Windows Update session: ${_}")
    }

    # process winget updates if auto-install is requested
    if ($Install) {

        try {

            if (-not $NoBanner) {
                Microsoft.PowerShell.Utility\Write-Progress -Activity "Checking for Updates" -Status "Checking WinGet packages..." -PercentComplete 20
            }

            # get list of packages with updates available
            $packagesWithUpdates = Microsoft.WinGet.Client\Get-WinGetPackage |
                Microsoft.PowerShell.Core\Where-Object { $_.IsUpdateAvailable }

            if ($packagesWithUpdates.Count -gt 0) {

                # request consent before updating winget packages
                $wingetUpdateConsent = GenXdev\Confirm-InstallationConsent `
                    -ApplicationName "WinGet Package Updates" `
                    -Source "WinGet" `
                    -Description "Update existing third-party software packages managed by WinGet package manager" `
                    -Publisher "Various Publishers"

                if (-not $wingetUpdateConsent) {
                    Microsoft.PowerShell.Utility\Write-Warning (
                        "WinGet package updates cancelled - installation consent denied")
                    $script:wingetHasUpdates = $packagesWithUpdates.Count -gt 0
                    return
                }

                # confirm winget update installation with user
                if ($PSCmdlet.ShouldProcess("$($packagesWithUpdates.Count) available winget packages", "Update")) {

                    if (-not $NoBanner) {
                        Microsoft.PowerShell.Utility\Write-Host (
                            "Updating WinGet Packages:") -ForegroundColor Cyan
                        Microsoft.PowerShell.Utility\Write-Host (
                            "=========================") -ForegroundColor Cyan
                    }

                    $successCount = 0
                    $errorCount = 0
                    $updateResults = @()
                    $totalPackages = $packagesWithUpdates.Count
                    $currentPackage = 0

                    # update each package that has updates available
                    foreach ($package in $packagesWithUpdates) {

                        try {

                            $currentPackage++
                            $percentComplete = [math]::Round(($currentPackage / $totalPackages) * 100)

                            if (-not $NoBanner) {
                                Microsoft.PowerShell.Utility\Write-Progress -Activity "Installing WinGet Updates" `
                                    -Status "Updating $($package.Name) ($currentPackage of $totalPackages)" `
                                    -PercentComplete $percentComplete

                                Microsoft.PowerShell.Utility\Write-Host (
                                    "Updating: $($package.Name)") -ForegroundColor Yellow
                            }

                            $updateResult = Microsoft.WinGet.Client\Update-WinGetPackage -Id $package.Id -Mode Silent

                            if ($updateResult.Status -eq 'Ok') {
                                $successCount++
                                if (-not $NoBanner) {
                                    Microsoft.PowerShell.Utility\Write-Host (
                                        "  ✓ $($package.Name) updated successfully") -ForegroundColor Green
                                }
                            }
                            else {
                                $errorCount++
                                Microsoft.PowerShell.Utility\Write-Warning (
                                    "Failed to update $($package.Name): $($updateResult.Status)")
                            }

                            $updateResults += $updateResult
                        }
                        catch {

                            $errorCount++
                            Microsoft.PowerShell.Utility\Write-Warning (
                                "Failed to update package $($package.Name): ${_}")
                        }
                    }

                    if (-not $NoBanner) {
                        Microsoft.PowerShell.Utility\Write-Progress -Activity "Installing WinGet Updates" -Completed
                        Microsoft.PowerShell.Utility\Write-Host ""
                        Microsoft.PowerShell.Utility\Write-Host (
                            "WinGet Update Summary: $successCount successful, $errorCount failed") `
                            -ForegroundColor $(if ($errorCount -eq 0) { 'Green' } else { 'Yellow' })
                        Microsoft.PowerShell.Utility\Write-Host ""
                    }
                }
            }

            # check for remaining winget updates after installation
            $remainingUpdates = Microsoft.WinGet.Client\Get-WinGetPackage |
                Microsoft.PowerShell.Core\Where-Object { $_.IsUpdateAvailable }

            $script:wingetHasUpdates = $remainingUpdates.Count -gt 0
        }
        catch {

            # assume no updates if winget check fails
            $script:wingetHasUpdates = $false

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Failed to check winget updates: ${_}")
        }
    }
    else {

        try {

            if (-not $NoBanner) {
                Microsoft.PowerShell.Utility\Write-Progress -Activity "Checking for Updates" -Status "Checking WinGet packages..." -PercentComplete 20
            }

            # get list of packages with updates available
            $wingetUpdates = Microsoft.WinGet.Client\Get-WinGetPackage |
                Microsoft.PowerShell.Core\Where-Object { $_.IsUpdateAvailable }

            # determine if winget updates are available
            $script:wingetHasUpdates = $wingetUpdates.Count -gt 0

            # display winget updates if found
            if ($script:wingetHasUpdates) {

                if (-not $NoBanner) {
                    Microsoft.PowerShell.Utility\Write-Host (
                        "Available Winget Updates:") -ForegroundColor Yellow

                    Microsoft.PowerShell.Utility\Write-Host (
                        "=========================") -ForegroundColor Yellow

                    # display winget updates in formatted table
                    $wingetUpdates | Microsoft.PowerShell.Utility\Format-Table `
                        Name, Id, InstalledVersion, @{
                        Label      = 'Available'
                        Expression = { $_.AvailableVersions[0] }
                    }, Source -AutoSize |
                        Microsoft.PowerShell.Utility\Out-String |
                        Microsoft.PowerShell.Core\ForEach-Object {
                            Microsoft.PowerShell.Utility\Write-Host $_.TrimEnd() `
                                -ForegroundColor White
                        }

                    Microsoft.PowerShell.Utility\Write-Host ""
                }
                else {
                    # When NoBanner is set, just output basic info without formatting
                    $wingetUpdates | Microsoft.PowerShell.Utility\ForEach-Object {
                        Microsoft.PowerShell.Utility\Write-Output "WinGet Update Available: $($_.Name) ($($_.InstalledVersion) -> $($_.AvailableVersions[0]))"
                    }
                }
            }
        }
        catch {

            # assume no updates if winget check fails
            $script:wingetHasUpdates = $false

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Failed to check winget updates: ${_}")
        }
    }

    # check for outdated PowerShell modules
    try {

        if (-not $NoBanner) {
            Microsoft.PowerShell.Utility\Write-Progress -Activity "Checking for Updates" -Status "Checking PowerShell modules..." -PercentComplete 60
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Checking for outdated PowerShell modules...")

        # get list of installed modules that have updates available
        $installedModules = PowerShellGet\Get-InstalledModule -ErrorAction SilentlyContinue

        if (-not $installedModules) {
            Microsoft.PowerShell.Utility\Write-Verbose "No installed modules found or Get-InstalledModule failed"
            $script:moduleUpdatesAvailable = $false
        }
        else {
            Microsoft.PowerShell.Utility\Write-Verbose "Found $($installedModules.Count) installed modules"

            $outdatedModules = $installedModules | Microsoft.PowerShell.Core\ForEach-Object {
                $installedModule = $_
                Microsoft.PowerShell.Utility\Write-Verbose "Checking module: $($installedModule.Name) version $($installedModule.Version)"

                try {
                    $latestVersion = PowerShellGet\Find-Module -Name $installedModule.Name -ErrorAction SilentlyContinue |
                        Microsoft.PowerShell.Utility\Select-Object -First 1

                        if ($latestVersion) {
                            Microsoft.PowerShell.Utility\Write-Verbose "Latest version for $($installedModule.Name): $($latestVersion.Version)"

                            if ([version]$latestVersion.Version -gt [version]$installedModule.Version) {
                                Microsoft.PowerShell.Utility\Write-Verbose "Update available for $($installedModule.Name): $($installedModule.Version) -> $($latestVersion.Version)"
                                [PSCustomObject]@{
                                    Name             = $installedModule.Name
                                    InstalledVersion = $installedModule.Version
                                    AvailableVersion = $latestVersion.Version
                                    Repository       = $latestVersion.Repository
                                }
                            }
                        }
                        else {
                            Microsoft.PowerShell.Utility\Write-Verbose "No online version found for $($installedModule.Name)"
                        }
                    }
                    catch {
                        Microsoft.PowerShell.Utility\Write-Verbose "Error checking module $($installedModule.Name): $_"
                    }
                }

                # set tracking variable for module updates
                $script:moduleUpdatesAvailable = $outdatedModules.Count -gt 0
                Microsoft.PowerShell.Utility\Write-Verbose "Found $($outdatedModules.Count) modules with updates available"
            }

            # display outdated modules if found and not installing
            if ($script:moduleUpdatesAvailable -and -not $Install) {

                if (-not $NoBanner) {
                    Microsoft.PowerShell.Utility\Write-Host (
                        "Available PowerShell Module Updates:") -ForegroundColor Cyan

                    Microsoft.PowerShell.Utility\Write-Host (
                        "====================================") -ForegroundColor Cyan

                    # display module updates in formatted table
                    $outdatedModules | Microsoft.PowerShell.Utility\Format-Table `
                        Name, InstalledVersion, AvailableVersion, Repository -AutoSize |
                        Microsoft.PowerShell.Utility\Out-String |
                        Microsoft.PowerShell.Core\ForEach-Object {
                            Microsoft.PowerShell.Utility\Write-Host $_.TrimEnd() `
                                -ForegroundColor White
                        }

                Microsoft.PowerShell.Utility\Write-Host ""
            }
            else {
                # When NoBanner is set, just output basic info without formatting
                $outdatedModules | Microsoft.PowerShell.Utility\ForEach-Object {
                    Microsoft.PowerShell.Utility\Write-Output "PowerShell Module Update Available: $($_.Name) ($($_.InstalledVersion) -> $($_.AvailableVersion))"
                }
            }
        }
        elseif (-not $script:moduleUpdatesAvailable) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "All installed PowerShell modules are up to date.")
        }
    }
    catch {

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Failed to check PowerShell module updates: ${_}")

        $script:moduleUpdatesAvailable = $false
    }


    if ($Install) {

        # only prompt for PowerShell module updates if any are available
        if ($script:moduleUpdatesAvailable) {

            # request consent before updating PowerShell modules
            $moduleUpdateConsent = GenXdev\Confirm-InstallationConsent `
                -ApplicationName "PowerShell Module Updates" `
                -Source "PowerShell Gallery" `
                -Description "Update existing PowerShell modules from the PowerShell Gallery repository" `
                -Publisher "Various Publishers"

            if (-not $moduleUpdateConsent) {
                Microsoft.PowerShell.Utility\Write-Warning (
                    "PowerShell module updates cancelled - installation consent denied")
                # Continue with Windows updates even if module updates are declined
            }
            else {
                if ($PSCmdlet.ShouldProcess("PowerShell modules", "Update")) {

                    if (-not $NoBanner) {
                        Microsoft.PowerShell.Utility\Write-Progress -Activity "Installing Updates" -Status "Updating PowerShell modules..." -PercentComplete 10
                        Microsoft.PowerShell.Utility\Write-Host (
                            "Updating PowerShell Modules:") -ForegroundColor Yellow
                        Microsoft.PowerShell.Utility\Write-Host (
                            "=============================") -ForegroundColor Yellow
                    }

                    $oldPolicy = (PowerShellGet\Get-PSRepository -Name 'PSGallery').InstallationPolicy
                    try {
                        if (-not (PowerShellGet\Get-PSRepository -Name 'PSGallery').InstallationPolicy -eq 'Trusted') {
                            PowerShellGet\Set-PSRepository -Name 'PSGallery' -InstallationPolicy Trusted -Confirm:$false
                        }

                        if (-not $NoBanner) {
                            Microsoft.PowerShell.Utility\Write-Host (
                                "Running Update-Module -AcceptLicense...") -ForegroundColor Yellow
                        }

                        PowerShellGet\Update-Module -AcceptLicense -ErrorAction Continue -Confirm:$false

                        if (-not $NoBanner) {
                            Microsoft.PowerShell.Utility\Write-Host (
                                "✓ PowerShell modules update completed") -ForegroundColor Green
                            Microsoft.PowerShell.Utility\Write-Host ""
                        }
                    }
                    finally {
                        if ($oldPolicy -ne (PowerShellGet\Get-PSRepository -Name 'PSGallery').InstallationPolicy) {

                            PowerShellGet\Set-PSRepository -Name 'PSGallery' -InstallationPolicy $oldPolicy -Confirm:$false
                        }
                    }
                }
            }
        }
    }

    # verify COM objects were initialized successfully
    if ($null -eq $script:updateSession -or $null -eq $script:updateSearcher) {
        Microsoft.PowerShell.Utility\Write-Error (
            "Windows Update session was not properly initialized.")
        return
    }

    try {

        # adjust criteria for drivers if requested
        $searchCriteria = $Criteria

        # when processing optional updates with default criteria,
        # remove AutoSelectOnWebSites filter to include optional updates
        if ($ProcessOptionalUpdates -and -not $PSBoundParameters.ContainsKey('Criteria')) {
            $searchCriteria = "IsInstalled=0 and IsHidden=0"
        }

        if ($IncludeDrivers) {

            if ($searchCriteria -notmatch "Type='Driver'" -and $searchCriteria -notmatch "Type!='Driver'") {

                $searchCriteria += " AND DeploymentAction=*"
            }
        }

        if (-not $NoBanner) {
            Microsoft.PowerShell.Utility\Write-Progress -Activity "Checking for Updates" -Status "Searching for Windows updates..." -PercentComplete 80
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Searching for Windows updates with criteria: $searchCriteria")

        # search for available windows updates
        $searchResult = $script:updateSearcher.Search($searchCriteria)

        $updates = $searchResult.Updates

        # separate important and optional updates when processing both
        if ($ProcessOptionalUpdates) {
            $importantUpdates = @($updates | Microsoft.PowerShell.Core\Where-Object {
                    $_.AutoSelectOnWebSites
                })
            $optionalUpdates = @($updates | Microsoft.PowerShell.Core\Where-Object {
                    -not $_.AutoSelectOnWebSites
                })
        }
        else {
            $importantUpdates = @($updates)
            $optionalUpdates = @()
        }

        if (-not $NoBanner) {
            Microsoft.PowerShell.Utility\Write-Progress -Activity "Checking for Updates" -Completed
        }

        # check if no updates are available
        if ($updates.Count -eq 0 -and -not $script:wingetHasUpdates -and -not $script:moduleUpdatesAvailable) {

            if (-not $NoBanner) {

                Microsoft.PowerShell.Utility\Write-Host (
                    "✅ System is up to date!") -ForegroundColor Green
            }

            Microsoft.PowerShell.Utility\Write-Verbose (
                "No updates available. System is up to date.")

            return
        }

        # display available updates without installing them
        if (-not $Install) {

            $totalUpdates = $importantUpdates.Count + $optionalUpdates.Count

            if ($totalUpdates -gt 0) {

                # display updates grouped by category if requested
                if ($GroupByCategory) {

                    $h1 = 'Category'
                    $h2 = 'Title'
                    $h3 = 'Description'
                    $catalog = @()

                    # build catalog of updates with category information
                    foreach ($update in $importantUpdates) {

                        if (-not $update.IsHidden) {

                            $table = '' | Microsoft.PowerShell.Utility\Select-Object $h1, $h2, $h3
                            $index = $update.Categories.Item.count - 1
                            $item = $update.Categories.Item($index)
                            $category = $item.Name
                            $table.$h1 = $category
                            $table.$h2 = $update.Title
                            $table.$h3 = $update.Description
                            $catalog += $table
                        }
                    }

                    # include optional updates with [OPTIONAL] label
                    foreach ($update in $optionalUpdates) {

                        if (-not $update.IsHidden) {

                            $table = '' | Microsoft.PowerShell.Utility\Select-Object $h1, $h2, $h3
                            $index = $update.Categories.Item.count - 1
                            $item = $update.Categories.Item($index)
                            $category = $item.Name
                            $table.$h1 = "${category} [OPTIONAL]"
                            $table.$h2 = $update.Title
                            $table.$h3 = $update.Description
                            $catalog += $table
                        }
                    }

                    # group updates by category and display
                    $group = $catalog | Microsoft.PowerShell.Utility\Group-Object -Property 'Category'

                    foreach ($member in $group) {

                        $title = $member.Name

                        Microsoft.PowerShell.Utility\Write-Host "[${title}]" `
                            -ForegroundColor Yellow

                        $member.Group | Microsoft.PowerShell.Core\ForEach-Object {

                            Microsoft.PowerShell.Utility\Write-Host " - $($_.Title)" `
                                -ForegroundColor Cyan

                            Microsoft.PowerShell.Utility\Write-Host (
                                "    $($_.Description)")

                            Microsoft.PowerShell.Utility\Write-Host ""
                        }

                        Microsoft.PowerShell.Utility\Write-Host ""
                    }
                }
                else {

                    # display important updates in simple list format
                    if ($importantUpdates.Count -gt 0) {
                        Microsoft.PowerShell.Utility\Write-Host (
                            "Available Windows Updates:") -ForegroundColor Cyan

                        Microsoft.PowerShell.Utility\Write-Host (
                            "==========================") -ForegroundColor Cyan

                        foreach ($update in $importantUpdates) {

                            if (-not $update.IsHidden) {

                                Microsoft.PowerShell.Utility\Write-Host (
                                    "• $($update.Title)") -ForegroundColor White

                                Microsoft.PowerShell.Utility\Write-Host (
                                    "  Size: $([math]::Round($update.MaxDownloadSize / 1MB, 2)) MB") `
                                    -ForegroundColor Gray

                                if ($update.Description) {

                                    $description = $update.Description

                                    if ($description.Length -gt 100) {

                                        $description = $description.Substring(0, 97) + "..."
                                    }

                                    Microsoft.PowerShell.Utility\Write-Host (
                                        "  $description") -ForegroundColor Gray
                                }

                                Microsoft.PowerShell.Utility\Write-Host ""
                            }
                        }
                    }

                    # display optional updates separately
                    if ($optionalUpdates.Count -gt 0) {
                        Microsoft.PowerShell.Utility\Write-Host (
                            "Optional Windows Updates:") -ForegroundColor DarkCyan

                        Microsoft.PowerShell.Utility\Write-Host (
                            "=========================") -ForegroundColor DarkCyan

                        foreach ($update in $optionalUpdates) {

                            if (-not $update.IsHidden) {

                                Microsoft.PowerShell.Utility\Write-Host (
                                    "• $($update.Title)") -ForegroundColor Gray

                                Microsoft.PowerShell.Utility\Write-Host (
                                    "  Size: $([math]::Round($update.MaxDownloadSize / 1MB, 2)) MB") `
                                    -ForegroundColor DarkGray

                                if ($update.Description) {

                                    $description = $update.Description

                                    if ($description.Length -gt 100) {

                                        $description = $description.Substring(0, 97) + "..."
                                    }

                                    Microsoft.PowerShell.Utility\Write-Host (
                                        "  $description") -ForegroundColor DarkGray
                                }

                                Microsoft.PowerShell.Utility\Write-Host ""
                            }
                        }

                        if (-not $NoBanner) {
                            Microsoft.PowerShell.Utility\Write-Host (
                                "Use -ProcessOptionalUpdates -Install to be prompted for each") `
                                -ForegroundColor DarkCyan
                            Microsoft.PowerShell.Utility\Write-Host ""
                        }
                    }
                }

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "$($totalUpdates) Windows updates are available but Install is not specified.")
            }

            if ($script:wingetHasUpdates) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Winget updates are available but Install is not specified.")
            }

            if ($script:moduleUpdatesAvailable) {

                Microsoft.PowerShell.Utility\Write-Verbose (
                    "PowerShell module updates are available but Install is not specified.")
            }

            # display usage instructions if updates are available
            if (($totalUpdates -gt 0 -or $script:wingetHasUpdates -or $script:moduleUpdatesAvailable) -and -not $NoBanner) {

                Microsoft.PowerShell.Utility\Write-Host (
                    "To install these updates automatically, use:") `
                    -ForegroundColor Green

                Microsoft.PowerShell.Utility\Write-Host (
                    "  Invoke-WindowsUpdate -Install") -ForegroundColor Cyan

                Microsoft.PowerShell.Utility\Write-Host (
                    "  updatewindows -Install") -ForegroundColor Cyan

                Microsoft.PowerShell.Utility\Write-Host ""

                Microsoft.PowerShell.Utility\Write-Host (
                    "To install and automatically reboot if needed, use:") `
                    -ForegroundColor Green

                Microsoft.PowerShell.Utility\Write-Host (
                    "  Invoke-WindowsUpdate -Install -AutoReboot") `
                    -ForegroundColor Cyan

                Microsoft.PowerShell.Utility\Write-Host (
                    "  updatewindows -Install -AutoReboot") -ForegroundColor Cyan

                Microsoft.PowerShell.Utility\Write-Host ""
            }

            return
        }

        # prepare to install the available updates
        if (-not $NoBanner) {
            Microsoft.PowerShell.Utility\Write-Host (
                "Installing Windows Updates:") -ForegroundColor Cyan
            Microsoft.PowerShell.Utility\Write-Host (
                "============================") -ForegroundColor Cyan
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Found $($importantUpdates.Count) important and $($optionalUpdates.Count) optional updates to consider.")

        # create collection for updates to install
        $updatesToInstall = Microsoft.PowerShell.Utility\New-Object `
            -ComObject Microsoft.Update.UpdateColl

        # add non-hidden important updates to installation collection
        foreach ($update in $importantUpdates) {

            if ($update.IsHidden -eq $false) {

                $null = $updatesToInstall.Add($update)

                if (-not $NoBanner) {
                    Microsoft.PowerShell.Utility\Write-Host (
                        "  • $($update.Title)") -ForegroundColor White
                }
            }
        }

        # prompt for each optional update when ProcessOptionalUpdates is used
        if ($ProcessOptionalUpdates -and $optionalUpdates.Count -gt 0) {

            if (-not $NoBanner) {
                Microsoft.PowerShell.Utility\Write-Host ""
                Microsoft.PowerShell.Utility\Write-Host (
                    "Optional Updates Available:") -ForegroundColor DarkCyan
                Microsoft.PowerShell.Utility\Write-Host (
                    "===========================") -ForegroundColor DarkCyan

                $index = 1
                foreach ($update in $optionalUpdates) {

                    if ($update.IsHidden -eq $false) {
                        Microsoft.PowerShell.Utility\Write-Host (
                            "  $index. $($update.Title)") -ForegroundColor Gray
                        Microsoft.PowerShell.Utility\Write-Host (
                            "     Size: $([math]::Round($update.MaxDownloadSize / 1MB, 2)) MB") `
                            -ForegroundColor DarkGray
                        $index++
                    }
                }
                Microsoft.PowerShell.Utility\Write-Host ""
            }

            foreach ($update in $optionalUpdates) {

                if ($update.IsHidden -eq $false) {

                    $choice = $host.ui.PromptForChoice(
                        'Optional Update',
                        "Install '$($update.Title)'?",
                        @('&No', '&Yes'),
                        0)

                    if ($choice -eq 1) {

                        $null = $updatesToInstall.Add($update)

                        if (-not $NoBanner) {
                            Microsoft.PowerShell.Utility\Write-Host (
                                "  ✓ $($update.Title) [OPTIONAL]") -ForegroundColor DarkCyan
                        }
                    }
                    elseif (-not $NoBanner) {
                        Microsoft.PowerShell.Utility\Write-Host (
                            "  ✗ Skipped: $($update.Title)") -ForegroundColor DarkGray
                    }
                }
            }
        }

        # verify we have valid updates to install
        if ($updatesToInstall.Count -eq 0) {

            Microsoft.PowerShell.Utility\Write-Verbose (
                "No valid updates to install after filtering.")

            return
        }

        # confirm Windows update installation with user
        if (-not $PSCmdlet.ShouldProcess("$($updatesToInstall.Count) Windows updates", "Download and Install")) {
            return
        }

        # create downloader and set updates to download
        $downloader = $updateSession.CreateUpdateDownloader()

        $downloader.Updates = $updatesToInstall

        if (-not $NoBanner) {
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Installing Windows Updates" `
                -Status "Downloading and preparing updates (this may take a while)..." `
                -PercentComplete 30
            Microsoft.PowerShell.Utility\Write-Host (
                "Downloading and preparing updates...") -ForegroundColor Yellow
        }
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Downloading and preparing updates...")

        # download the selected updates (the Windows Update COM API
        # internally bundles download + preparation work; the user may
        # see Windows itself reporting 'Installing' during this phase)
        $downloadResult = $downloader.Download()

        # verify download was successful
        if ($downloadResult.ResultCode -ne 2) {

            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to download updates. Result code: " +
                "$($downloadResult.ResultCode)")

            return
        }

        if (-not $NoBanner) {
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Installing Windows Updates" `
                -Status "Finalizing installation..." `
                -PercentComplete 70
            Microsoft.PowerShell.Utility\Write-Host (
                "✓ Download and preparation completed") -ForegroundColor Green
        }

        # create installer and set updates to install
        $installer = $updateSession.CreateUpdateInstaller()

        $installer.Updates = $updatesToInstall

        if (-not $NoBanner) {
            Microsoft.PowerShell.Utility\Write-Host (
                "Finalizing installation...") -ForegroundColor Yellow
        }
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Finalizing installation...")

        # install the downloaded updates
        $installResult = $installer.Install()

        # verify installation was successful
        if ($installResult.ResultCode -ne 2) {

            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to install updates. Result code: " +
                "$($installResult.ResultCode)")

            return
        }

        if (-not $NoBanner) {
            Microsoft.PowerShell.Utility\Write-Progress `
                -Activity "Installing Windows Updates" -Completed
            Microsoft.PowerShell.Utility\Write-Host (
                "✓ Installation completed successfully") -ForegroundColor Green
            Microsoft.PowerShell.Utility\Write-Host ""
        }

        # handle reboot requirement after installation
        if ($installResult.RebootRequired -and $AutoReboot -and -not $NoRebootCheck) {

            if ($PSCmdlet.ShouldProcess("Computer", "Restart")) {

                if (-not $NoBanner) {
                    Microsoft.PowerShell.Utility\Write-Host (
                        "🔄 Reboot required. Restarting computer...") -ForegroundColor Yellow
                }
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Reboot required. Initiating reboot...")

                Microsoft.PowerShell.Management\Restart-Computer -Force
            }

            return
        }
        elseif ($installResult.RebootRequired -and -not $NoRebootCheck) {

            if (-not $NoBanner) {
                Microsoft.PowerShell.Utility\Write-Host (
                    "⚠️  Reboot required to complete installation") -ForegroundColor Yellow
                Microsoft.PowerShell.Utility\Write-Host (
                    "   Use -AutoReboot to restart automatically") -ForegroundColor Gray
                Microsoft.PowerShell.Utility\Write-Host ""
            }
            Microsoft.PowerShell.Utility\Write-Verbose (
                "Reboot required but AutoReboot not specified.")

            return
        }

        # check for additional updates after installation
        if (-not $NoBanner) {
            Microsoft.PowerShell.Utility\Write-Progress -Activity "Installing Windows Updates" -Status "Checking for additional updates..." -PercentComplete 90
        }

        $newSearchResult = $updateSearcher.Search($searchCriteria)

        # recheck for module updates after Update-Module has run
        $moduleUpdatesStillAvailable = $false
        if ($Install) {
            try {
                $remainingModuleUpdates = PowerShellGet\Get-InstalledModule |
                    Microsoft.PowerShell.Core\ForEach-Object {
                        $installedModule = $_
                        $latestVersion = PowerShellGet\Find-Module -Name $_.Name -ErrorAction SilentlyContinue |
                            Microsoft.PowerShell.Utility\Select-Object -First 1

                            if ($latestVersion -and ([version]$latestVersion.Version -gt [version]$installedModule.Version)) {
                                $installedModule
                            }
                        }
                $moduleUpdatesStillAvailable = $remainingModuleUpdates.Count -gt 0
            }
            catch {
                $moduleUpdatesStillAvailable = $false
            }
        }

        if (-not $NoBanner) {
            Microsoft.PowerShell.Utility\Write-Progress -Activity "Installing Windows Updates" -Completed
        }

        # determine final status of system update state
        if ($newSearchResult.Updates.Count -eq 0 -and -not $script:wingetHasUpdates -and -not $moduleUpdatesStillAvailable) {

            if (-not $NoBanner) {
                Microsoft.PowerShell.Utility\Write-Host (
                    "✅ System is now up to date!") -ForegroundColor Green
                Microsoft.PowerShell.Utility\Write-Host ""
            }
            Microsoft.PowerShell.Utility\Write-Verbose (
                "No more updates available after installation.")

            return
        }
        else {

            if (-not $NoBanner) {
                Microsoft.PowerShell.Utility\Write-Host (
                    "ℹ️  Additional updates may be available") -ForegroundColor Cyan
            }

            if ($newSearchResult.Updates.Count -gt 0) {

                if (-not $NoBanner) {
                    Microsoft.PowerShell.Utility\Write-Host (
                        "   Run updatewindows again to check for more Windows updates") `
                        -ForegroundColor Gray
                }
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Additional Windows updates found after installation.")
            }

            if ($script:wingetHasUpdates) {

                if (-not $NoBanner) {
                    Microsoft.PowerShell.Utility\Write-Host (
                        "   Some WinGet packages still have updates available") `
                        -ForegroundColor Gray
                }
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Winget updates still available.")
            }

            if ($moduleUpdatesStillAvailable) {

                if (-not $NoBanner) {
                    Microsoft.PowerShell.Utility\Write-Host (
                        "   Some PowerShell modules still have updates available") `
                        -ForegroundColor Gray
                }
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "PowerShell module updates still available.")
            }

            if (-not $NoBanner) {
                Microsoft.PowerShell.Utility\Write-Host ""
            }
        }
    }
    catch {

        Microsoft.PowerShell.Utility\Write-Error (
            "Error during update process: ${_}")

    }

    # release com objects to prevent memory leaks
    if ($updateSession) {

        $null = [System.Runtime.InteropServices.Marshal]::ReleaseComObject(
            $updateSession)
    }
}
################################################################################