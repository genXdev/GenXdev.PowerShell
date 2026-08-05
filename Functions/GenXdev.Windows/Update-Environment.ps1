<#
.SYNOPSIS
Updates the environment variables in the current session.

.DESCRIPTION
Ensures that the environment variables are up to date in the current session.

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

#>

function Update-Environment {

    [CmdletBinding()]
    param ()

    [string] $oldPath = "$($Env:PATH)"
    [string] $oldPSModulePath = "$($Env:PSModulePath)"
    $null = & {
        [System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::Machine).GetEnumerator() | Microsoft.PowerShell.Core\ForEach-Object -ErrorAction SilentlyContinue {
            try {
                Microsoft.PowerShell.Utility\Invoke-Expression "`$ENV:$($_.Key) = '$($_.Value.Replace('''', ''''''))'" -ErrorAction SilentlyContinue
            }
            catch {}
        }
        [System.Environment]::GetEnvironmentVariables([System.EnvironmentVariableTarget]::User).GetEnumerator() | Microsoft.PowerShell.Core\ForEach-Object -ErrorAction SilentlyContinue {
            try {
                Microsoft.PowerShell.Utility\Invoke-Expression "`$ENV:$($_.Key) = '$($_.Value.Replace('''', ''''''))'" -ErrorAction SilentlyContinue
            }
            catch {}
        }
    } 1> $null 2>$null 3> $null 4> $null

    [string] $NewPath = "$($Env:PATH)"

    $Env:PATH = @(
        @(
            $NewPath.Split([System.IO.Path]::PathSeparator, [StringSplitOptions]::RemoveEmptyEntries) +
            $oldPath.Split([System.IO.Path]::PathSeparator, [StringSplitOptions]::RemoveEmptyEntries)
        ) |
            Microsoft.PowerShell.Core\ForEach-Object { GenXdev\Expand-Path "$_\" } |
            Microsoft.PowerShell.Utility\Select-Object -Unique
    ) -join [System.IO.Path]::PathSeparator

    [string] $NewPSModulePath = "$($Env:PSModulePath)"

    $Env:PSModulePath = @(
        @(
            $NewPSModulePath.Split([System.IO.Path]::PathSeparator, [StringSplitOptions]::RemoveEmptyEntries) +
            $oldPSModulePath.Split([System.IO.Path]::PathSeparator, [StringSplitOptions]::RemoveEmptyEntries)
        ) |
            Microsoft.PowerShell.Core\ForEach-Object { GenXdev\Expand-Path "$_\" } |
            Microsoft.PowerShell.Utility\Select-Object -Unique
    ) -join [System.IO.Path]::PathSeparator
}