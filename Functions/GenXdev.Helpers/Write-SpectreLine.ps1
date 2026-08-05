###############################################################################
<#
.SYNOPSIS
Writes a blank line via Spectre.Console.

.DESCRIPTION
Outputs a blank line to the console using Spectre.Console's native line
writing method. This is a thin wrapper around the AnsiConsole static
class that provides consistent output formatting.

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
Write-SpectreLine
Writes a single blank line to the console
#>
###############################################################################
function Write-SpectreLine {
    [CmdletBinding()]
    param()
    [Spectre.Console.AnsiConsole]::WriteLine()
}