<#
.SYNOPSIS
Shows an exception in a nice panel using Spectre.Console

.DESCRIPTION
Uses Spectre.Console to show an exception in a nice panel.

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

.PARAMETER Exception
Exception object to show in the panel.

.EXAMPLE
try {
    throw "This is a test exception"
} catch {

    Show-ExceptionPanel -Exception $_.Exception
}
#>
function Show-ExceptionPanel {

    param(
        [Parameter(Mandatory = $true, Position = 0, HelpMessage = "The exception to show in the panel.")]
        [System.Exception]  $Exception
    )

    $AnsiConsole = [Spectre.Console.AnsiConsole]
    $ExceptionFormats = [Spectre.Console.ExceptionFormats]


    $esc = [char]27

    try {
        if ([System.Console]::WindowHeight) {
            [System.Console]::Out.Flush()
            [System.Console]::WriteLine()

            # Primary positioning via System.Console
            $lastRow = [System.Console]::WindowHeight
            [System.Console]::SetCursorPosition(0, $lastRow)
        }
        else {
            # ANSI fallback for SSH sessions, non-raw, or redirected stdout
            # `\n` pushes down past current border line
            # `$esc[999B` moves cursor down to the physical viewport boundary
            # `$esc[1G` sets cursor column to position 1 (left-aligned)
            [System.Console]::Out.Write("`n$esc[999B$esc[1G")
            [System.Console]::Out.Flush()
        }
    }
    catch {
        # Catch-all ANSI fallback if System.Console calls throw under SSH/PTY drivers
        [System.Console]::Out.Write("`n$esc[999B$esc[1G")
        [System.Console]::Out.Flush()
    }

    # Write the exception using Spectre
    $AnsiConsole::WriteException(
        $Exception,
        $ExceptionFormats::ShortenEverything -bor $ExceptionFormats::ShowLinks
    )
}