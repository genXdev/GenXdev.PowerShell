###############################################################################

<#
.SYNOPSIS
Returns a string (with altered indentation) of a provided scriptblock string

.DESCRIPTION
Changes the indentation of a scriptblock string while respecting the original code-block identations

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

.PARAMETER script
The scriptblock string

.PARAMETER spaces
The minimum number of spaces for each line
#>
function alignScript([string] $script, [int] $spaces = 0) {

    $lines = @($script.Replace("`r`n", "`n").Replace("`t", '    ').Split("`n"));

    [int] $NrOfSpacesToTrim = [int]::MaxValue;

    $lines | Microsoft.PowerShell.Core\ForEach-Object -ErrorAction SilentlyContinue {

        $c = 0;
        $s = $PSItem
        while (($s.Length -gt 0) -and ($s.substring(0, 1) -eq ' ')) {

            $c++;
            if ($s.Length -gt 1) {

                $s = $s.substring(1);
            }
            else {

                $s = '';
            }
        }

        $NrOfSpacesToTrim = [Math]::Min($NrOfSpacesToTrim, $c);
    }

    if ($NrOfSpacesToTrim -eq [int]::MaxValue) {

        $NrOfSpacesToTrim = 0;
    }

    @($lines | Microsoft.PowerShell.Core\ForEach-Object -ErrorAction SilentlyContinue {

            [int] $c = $NrOfSpacesToTrim;
            $a = $PSItem

            while (($a.Length -gt 0) -and ($a.substring(0, 1) -eq ' ') -and ($c -gt 0)) {

                $c--;

                if ($a.Length -gt 1) {

                    $a = $a.substring(1);
                }
                else {

                    $a = '';
                }
            }

            for ($i = 0; $i -lt $spaces; $i++) {

                $a = " $a"
            }

            $a
        }) -Join "`r`n"
}