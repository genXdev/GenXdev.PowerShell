###############################################################################
<#
.SYNOPSIS
Configures the GitHub Copilot Chat keyboard shortcuts in Visual Studio Code.

.DESCRIPTION
This function ensures that GitHub Copilot Chat's file attachment feature has a proper
keyboard shortcut (Ctrl+Shift+Alt+F12) configured in Visual Studio Code.

It will remove any existing Copilot attachment shortcuts and replace them with the
current correct command (github.copilot.chat.attachFile).

Also adds Alt+` (backtick) shortcut for toggling the maximized panel.

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

.EXAMPLE
EnsureCopilotKeyboardShortCut
#>
function EnsureCopilotKeyboardShortCut {

    [CmdletBinding()]
    param(
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to keyboard shortcut ' +
                'configuration and set persistent flag.')
        )]
        [switch] $AutoConsent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only auto consent during session')
        )]
        [switch]$SessionOnly
        ###############################################################################
    )

    begin {

        # construct the full path to vscode's keybindings configuration file
        $keybindingsPath = @(
            (GenXdev\Expand-Path "$env:APPDATA\Code\User\keybindings.json" -CreateDirectory),
            (GenXdev\Expand-Path "$env:APPDATA\Code - insiders\User\keybindings.json" -CreateDirectory)
        )

        $secondNewKeybinding =
        @{
            'key'     = 'alt+oem_3'
            'command' = 'workbench.action.toggleMaximizedPanel'
        }
    }

    process {

        # ensure the directory for keybindings exists
        foreach ($path in $keybindingsPath) {
            # Define the new keyboard shortcut configuration for copilot chat
            $newKeybinding = @{
                'key'     = 'ctrl+shift+alt+f12'
                'command' = 'workbench.action.chat.attachFile'  # Command for attaching files to Copilot chat
                'when'    = "resourceScheme == 'file' || resourceScheme == 'untitled'" +
                " || resourceScheme == 'vscode-remote' || " +
                "resourceScheme == 'vscode-userdata'"
            }            # load existing keybindings or initialize new array if file doesn't exist
            if (Microsoft.PowerShell.Management\Test-Path -LiteralPath $path) {
                Microsoft.PowerShell.Utility\Write-Verbose 'Loading existing keybindings configuration'
                $keybindingsContent = Microsoft.PowerShell.Management\Get-Content -LiteralPath $path -Raw
                if ([string]::IsNullOrWhiteSpace($keybindingsContent)) {
                    $keybindings = @()
                } else {
                    $keybindings = @(Microsoft.PowerShell.Utility\ConvertFrom-Json -InputObject $keybindingsContent -ErrorAction SilentlyContinue)
                    # Ensure we have an array to work with
                    if ($null -eq $keybindings) {
                        $keybindings = @()
                    }
                }
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose 'Initializing new keybindings configuration'
                $keybindings = @()
            }

            # Find and remove any existing Copilot attachment bindings
            $copilotShortcutsExist = $false
            foreach ($binding in $keybindings) {
                if ($binding.command -like 'workbench.action.chat.attachFile') {
                    $copilotShortcutsExist = $true
                    break
                }
            }

            if ($copilotShortcutsExist) {
                Microsoft.PowerShell.Utility\Write-Verbose 'Removing existing Copilot attachment shortcuts'
                $newBindings = @()
                foreach ($binding in $keybindings) {
                    if (-not ($binding.command -like 'workbench.action.chat.attachFile')) {
                        $newBindings += $binding
                    }
                }
                $keybindings = $newBindings
                $modified = $true
            }

            # check if the focus editor shortcut is already configured
            $existsFocus = $keybindings | Microsoft.PowerShell.Core\Where-Object {
                $_.key -eq $secondNewKeybinding.key -and $_.command -eq $secondNewKeybinding.command
            }

            # We'll always add the current correct attachment command
            $modified = $true            # Always add the Copilot chat attachment shortcut
            Microsoft.PowerShell.Utility\Write-Verbose 'Adding/Updating Copilot chat attachment shortcut (Ctrl+Shift+Alt+F12)'
            $keybindings = @($keybindings) + @($newKeybinding)

            if (-not $existsFocus) {
                Microsoft.PowerShell.Utility\Write-Verbose "Adding Panel Toggle keyboard shortcut (Alt+`)"
                $keybindings = @($keybindings) + @($secondNewKeybinding)
                $modified = $true
            }
            else {
                Microsoft.PowerShell.Utility\Write-Verbose 'Panel Toggle keyboard shortcut already exists'
            }

            # Save changes if any modifications were made
            if ($modified) {
                $keybindings |
                    Microsoft.PowerShell.Utility\ConvertTo-Json -Depth 10 |
                    Microsoft.PowerShell.Management\Set-Content -LiteralPath $path
            }
        }
    }

    end {
    }
}