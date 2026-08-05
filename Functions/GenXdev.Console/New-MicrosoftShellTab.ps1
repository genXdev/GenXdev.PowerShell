# don't remove this line [dontrefactor]

###############################################################################
<#
.SYNOPSIS
Creates a new Windows Terminal tab running PowerShell.

.DESCRIPTION
Opens a new Windows Terminal tab by simulating the keyboard shortcut Ctrl+Shift+T.
The function brings the PowerShell window to the foreground, sends the keystroke
combination, and optionally closes the current tab after a delay.

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

.PARAMETER DontCloseThisTab
When specified, prevents the current tab from being closed after creating the new
tab. By default, the current tab will close after 3 seconds.

.PARAMETER WhatIf
Shows what would happen if the cmdlet runs. The cmdlet is not run.

.PARAMETER Confirm
Prompts you for confirmation before running the cmdlet.

.EXAMPLE
New-MicrosoftShellTab -DontCloseThisTab
Creates a new terminal tab while keeping the current tab open.

.EXAMPLE
x
Creates a new terminal tab and closes the current one after 3 seconds.
#>
function New-MicrosoftShellTab {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias('x')]

    param(
        ########################################################################
        [Parameter(
            HelpMessage = 'Keep current tab open after creating new tab',
            Mandatory = $false
        )]
        [switch] $DontCloseThisTab
        ########################################################################
    )

    begin {

        $additionalKeystrokes = [System.Collections.Generic.List[string]]::new();

        while ([console]::KeyAvailable) {

            $key = [console]::ReadKey($true);
            $str = $key.KeyChar;
            switch ($key.Key) {
                13 { $str = "{ENTER}}" }
                9 { $str = "{TAB}" }
                8 { $str = "{BACKSPACE}" }
                27 { $str = "{ESC}" }
                32 { $str = "{SPACE}" }
                112..123 { $str = "{F$($key.Key - 111)}" }
                37 { $str = "{LEFT}" }
                38 { $str = "{UP}" }
                39 { $str = "{RIGHT}" }
                40 { $str = "{DOWN}" }
                36 { $str = "{HOME}" }
                35 { $str = "{END}" }
                33 { $str = "{PGUP}" }
                34 { $str = "{PGDN}" }
                46 { $str = "{DEL}" }
                45 { $str = "{INS}" }

                default { }
            }

            switch ($key.Modifiers) {
                1 { $str = "%$str" }
                2 { $str = "+$str" }
                3 { $str = "+%str" }
                4 { $str = "^$str" }
                5 { $str = "%^$str" }
                6 { $str = "+%$str" }
                7 { $str = "^%$str" }
            }
            $null = $additionalKeystrokes.Add($str);
        }

        # activate the powershell window to enable keyboard input processing
        Microsoft.PowerShell.Utility\Write-Verbose 'Bringing PowerShell window to foreground'
        $w = (GenXdev\Get-PowershellMainWindow);
        if ($w) {
            $null = $w.Focus()
        }

        try {
            # initialize windows script automation object for keyboard simulation
            Microsoft.PowerShell.Utility\Write-Verbose 'Creating WScript.Shell for sending keystrokes'
            $helper = Microsoft.PowerShell.Utility\New-Object -ComObject WScript.Shell

            # check if we should proceed with creating a new tab
            if ($PSCmdlet.ShouldProcess('Windows Terminal', 'Create new tab')) {
                # simulate ctrl+shift+t keystroke to trigger new tab creation
                Microsoft.PowerShell.Utility\Write-Verbose 'Sending Ctrl+Shift+T to create new tab'

                $null = $helper.sendKeys('^+t')
                Microsoft.PowerShell.Utility\Start-Sleep -Milliseconds 2000;

                $additionalKeystrokes | Microsoft.PowerShell.Core\ForEach-Object {

                    $null = $helper.sendKeys($_)
                }

                # handle tab closure if not explicitly prevented
                if ($DontCloseThisTab -ne $true) {

                    Microsoft.PowerShell.Utility\Write-Verbose 'Waiting 3 seconds before closing current tab'
                    Microsoft.PowerShell.Utility\Start-Sleep 3

                    if ($PSCmdlet.ShouldProcess('Current Windows Terminal tab',
                            'Close tab')) {
                        Microsoft.PowerShell.Utility\Write-Verbose 'Exiting current tab'
                        exit
                    }
                }
            }
        }
        catch {
            # suppress any automation-related exceptions
        }
    }


    process {
    }

    end {
    }
}