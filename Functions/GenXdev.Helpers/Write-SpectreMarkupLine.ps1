###############################################################################
<#
.SYNOPSIS
Writes a Spectre.Console markup-formatted line.

.DESCRIPTION
Outputs a line of text to the console that can contain Spectre.Console
markup for styling (colors, bold, italic, etc.). This is a thin wrapper
around the AnsiConsole static class that provides consistent output
formatting across GenXdev cmdlets.

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

.PARAMETER Message
The markup-formatted message to display to the user.

.EXAMPLE
Write-SpectreMarkupLine -Message "[bold green]Success![/] Operation completed."
Writes a styled message to the console using Spectre.Console markup
#>
###############################################################################
function Write-SpectreMarkupLine {
    [CmdletBinding()]
    param(
        ########################################################################
        [parameter(
            Position = 0,
            HelpMessage = 'The markup-formatted message to display to the user',
            Mandatory = $False
        )]
        [string] $Message = ''
        ########################################################################
    )
    [Spectre.Console.AnsiConsole]::MarkupLine($Message)
}