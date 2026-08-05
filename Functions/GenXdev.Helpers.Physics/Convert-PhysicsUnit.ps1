<#
.SYNOPSIS
Converts a value from one physics unit to another within the same category.

.DESCRIPTION
This function converts physical quantities between compatible units in categories
like length, time, speed, etc. It infers the category from the units and throws
an error for incompatible conversions.

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

.PARAMETER Value
The numerical value to convert.

.PARAMETER FromUnit
The unit of the input value.

.PARAMETER ToUnit
The desired output unit.

.EXAMPLE
Convert-PhysicsUnit -Value 100 -FromUnit "meters" -ToUnit "feet"

Converts 100 meters to feet.

.EXAMPLE
Convert-PhysicsUnit 10 "seconds" "minutes"

Converts 10 seconds to minutes using positional parameters.
#>
function Convert-PhysicsUnit {

    [CmdletBinding()]
    [OutputType([double])]

    param(
        ########################################################################
        [parameter(
            Mandatory = $true,
            Position = 0,
            HelpMessage = "The numerical value to convert"
        )]
        [double] $Value,
        ########################################################################
        [parameter(
            Mandatory = $true,
            Position = 1,
            HelpMessage = "The unit of the input value"
        )]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $unitData = @{
                'meters' = @{ Category = 'Length'; Factor = 1 }
                'kilometers' = @{ Category = 'Length'; Factor = 1000 }
                'centimeters' = @{ Category = 'Length'; Factor = 0.01 }
                'millimeters' = @{ Category = 'Length'; Factor = 0.001 }
                'feet' = @{ Category = 'Length'; Factor = 0.3048 }
                'inches' = @{ Category = 'Length'; Factor = 0.0254 }
                'miles' = @{ Category = 'Length'; Factor = 1609.34 }
                'yards' = @{ Category = 'Length'; Factor = 0.9144 }
                'seconds' = @{ Category = 'Time'; Factor = 1 }
                'minutes' = @{ Category = 'Time'; Factor = 60 }
                'hours' = @{ Category = 'Time'; Factor = 3600 }
                'days' = @{ Category = 'Time'; Factor = 86400 }
                'milliseconds' = @{ Category = 'Time'; Factor = 0.001 }
                'm/s' = @{ Category = 'Speed'; Factor = 1 }
                'km/h' = @{ Category = 'Speed'; Factor = 0.277778 }
                'mph' = @{ Category = 'Speed'; Factor = 0.44704 }
                'ft/s' = @{ Category = 'Speed'; Factor = 0.3048 }
                'kilograms' = @{ Category = 'Mass'; Factor = 1 }
                'grams' = @{ Category = 'Mass'; Factor = 0.001 }
                'pounds' = @{ Category = 'Mass'; Factor = 0.453592 }
                'ounces' = @{ Category = 'Mass'; Factor = 0.0283495 }
                'joules' = @{ Category = 'Energy'; Factor = 1 }
                'calories' = @{ Category = 'Energy'; Factor = 4.184 }
                'kilowatthours' = @{ Category = 'Energy'; Factor = 3600000 }
                'kgm/s' = @{ Category = 'Momentum'; Factor = 1 }
                'm/s²' = @{ Category = 'Acceleration'; Factor = 1 }
                'g' = @{ Category = 'Acceleration'; Factor = 9.81 }
                'newtons' = @{ Category = 'Force'; Factor = 1 }
                'poundforce' = @{ Category = 'Force'; Factor = 4.44822 }
                'hertz' = @{ Category = 'Frequency'; Factor = 1 }
                'kilohertz' = @{ Category = 'Frequency'; Factor = 1000 }
                'megahertz' = @{ Category = 'Frequency'; Factor = 1000000 }
                'radians' = @{ Category = 'Angle'; Factor = 1 }
                'degrees' = @{ Category = 'Angle'; Factor = 0.0174533 } # PI/180
                'kg/m³' = @{ Category = 'Density'; Factor = 1 }
                'cubicmeters' = @{ Category = 'Volume'; Factor = 1 }
                'liters' = @{ Category = 'Volume'; Factor = 0.001 }
                'cubiccentimeters' = @{ Category = 'Volume'; Factor = 0.000001 }
                'squaremeters' = @{ Category = 'Area'; Factor = 1 }
                'squarecentimeters' = @{ Category = 'Area'; Factor = 0.0001 }
                'acres' = @{ Category = 'Area'; Factor = 4046.86 }
                'squarefeet' = @{ Category = 'Area'; Factor = 0.092903 }
            }

            $suggestions = @()
            if ($fakeBoundParameters.ContainsKey('ToUnit')) {
                $otherUnit = $fakeBoundParameters['ToUnit']
                if ($unitData.ContainsKey($otherUnit)) {
                    $category = $unitData[$otherUnit].Category
                    $suggestions = $unitData.Keys | Microsoft.PowerShell.Core\Where-Object { $unitData[$_].Category -eq $category -and $_ -like "*$wordToComplete*" }
                }
            } else {
                $suggestions = $unitData.Keys | Microsoft.PowerShell.Core\Where-Object { $_ -like "*$wordToComplete*" }
            }

            $suggestions | Microsoft.PowerShell.Core\ForEach-Object {
                [System.Management.Automation.CompletionResult]::new("'$($_)'", $_, 'ParameterValue', $_)
            }
        })]
        [string] $FromUnit,
        ########################################################################
        [parameter(
            Mandatory = $true,
            Position = 2,
            HelpMessage = "The desired output unit"
        )]
        [ArgumentCompleter({
            param($commandName, $parameterName, $wordToComplete, $commandAst, $fakeBoundParameters)

            $unitData = @{
                'meters' = @{ Category = 'Length'; Factor = 1 }
                'kilometers' = @{ Category = 'Length'; Factor = 1000 }
                'centimeters' = @{ Category = 'Length'; Factor = 0.01 }
                'millimeters' = @{ Category = 'Length'; Factor = 0.001 }
                'feet' = @{ Category = 'Length'; Factor = 0.3048 }
                'inches' = @{ Category = 'Length'; Factor = 0.0254 }
                'miles' = @{ Category = 'Length'; Factor = 1609.34 }
                'yards' = @{ Category = 'Length'; Factor = 0.9144 }
                'seconds' = @{ Category = 'Time'; Factor = 1 }
                'minutes' = @{ Category = 'Time'; Factor = 60 }
                'hours' = @{ Category = 'Time'; Factor = 3600 }
                'days' = @{ Category = 'Time'; Factor = 86400 }
                'milliseconds' = @{ Category = 'Time'; Factor = 0.001 }
                'm/s' = @{ Category = 'Speed'; Factor = 1 }
                'km/h' = @{ Category = 'Speed'; Factor = 0.277778 }
                'mph' = @{ Category = 'Speed'; Factor = 0.44704 }
                'ft/s' = @{ Category = 'Speed'; Factor = 0.3048 }
                'kilograms' = @{ Category = 'Mass'; Factor = 1 }
                'grams' = @{ Category = 'Mass'; Factor = 0.001 }
                'pounds' = @{ Category = 'Mass'; Factor = 0.453592 }
                'ounces' = @{ Category = 'Mass'; Factor = 0.0283495 }
                'joules' = @{ Category = 'Energy'; Factor = 1 }
                'calories' = @{ Category = 'Energy'; Factor = 4.184 }
                'kilowatthours' = @{ Category = 'Energy'; Factor = 3600000 }
                'kgm/s' = @{ Category = 'Momentum'; Factor = 1 }
                'm/s²' = @{ Category = 'Acceleration'; Factor = 1 }
                'g' = @{ Category = 'Acceleration'; Factor = 9.81 }
                'newtons' = @{ Category = 'Force'; Factor = 1 }
                'poundforce' = @{ Category = 'Force'; Factor = 4.44822 }
                'hertz' = @{ Category = 'Frequency'; Factor = 1 }
                'kilohertz' = @{ Category = 'Frequency'; Factor = 1000 }
                'megahertz' = @{ Category = 'Frequency'; Factor = 1000000 }
                'radians' = @{ Category = 'Angle'; Factor = 1 }
                'degrees' = @{ Category = 'Angle'; Factor = 0.0174533 }
                'kg/m³' = @{ Category = 'Density'; Factor = 1 }
                'cubicmeters' = @{ Category = 'Volume'; Factor = 1 }
                'liters' = @{ Category = 'Volume'; Factor = 0.001 }
                'cubiccentimeters' = @{ Category = 'Volume'; Factor = 0.000001 }
                'squaremeters' = @{ Category = 'Area'; Factor = 1 }
                'squarecentimeters' = @{ Category = 'Area'; Factor = 0.0001 }
                'acres' = @{ Category = 'Area'; Factor = 4046.86 }
                'squarefeet' = @{ Category = 'Area'; Factor = 0.092903 }
            }

            $suggestions = @()
            if ($fakeBoundParameters.ContainsKey('FromUnit')) {
                $otherUnit = $fakeBoundParameters['FromUnit']
                if ($unitData.ContainsKey($otherUnit)) {
                    $category = $unitData[$otherUnit].Category
                    $suggestions = $unitData.Keys | Microsoft.PowerShell.Core\Where-Object { $unitData[$_].Category -eq $category -and $_ -like "*$wordToComplete*" }
                }
            } else {
                $suggestions = $unitData.Keys | Microsoft.PowerShell.Core\Where-Object { $_ -like "*$wordToComplete*" }
            }

            $suggestions | Microsoft.PowerShell.Core\ForEach-Object {
                [System.Management.Automation.CompletionResult]::new("'$($_)'", $_, 'ParameterValue', $_)
            }
        })]
        [string] $ToUnit
        ########################################################################
    )

    begin {

        # define unit data with categories and conversion factors to base units
        $unitData = @{
            'meters' = @{ Category = 'Length'; Factor = 1 }
            'kilometers' = @{ Category = 'Length'; Factor = 1000 }
            'centimeters' = @{ Category = 'Length'; Factor = 0.01 }
            'millimeters' = @{ Category = 'Length'; Factor = 0.001 }
            'feet' = @{ Category = 'Length'; Factor = 0.3048 }
            'inches' = @{ Category = 'Length'; Factor = 0.0254 }
            'miles' = @{ Category = 'Length'; Factor = 1609.34 }
            'yards' = @{ Category = 'Length'; Factor = 0.9144 }
            'seconds' = @{ Category = 'Time'; Factor = 1 }
            'minutes' = @{ Category = 'Time'; Factor = 60 }
            'hours' = @{ Category = 'Time'; Factor = 3600 }
            'days' = @{ Category = 'Time'; Factor = 86400 }
            'milliseconds' = @{ Category = 'Time'; Factor = 0.001 }
            'm/s' = @{ Category = 'Speed'; Factor = 1 }
            'km/h' = @{ Category = 'Speed'; Factor = 0.277778 }
            'mph' = @{ Category = 'Speed'; Factor = 0.44704 }
            'ft/s' = @{ Category = 'Speed'; Factor = 0.3048 }
            'kilograms' = @{ Category = 'Mass'; Factor = 1 }
            'grams' = @{ Category = 'Mass'; Factor = 0.001 }
            'pounds' = @{ Category = 'Mass'; Factor = 0.453592 }
            'ounces' = @{ Category = 'Mass'; Factor = 0.0283495 }
            'joules' = @{ Category = 'Energy'; Factor = 1 }
            'calories' = @{ Category = 'Energy'; Factor = 4.184 }
            'kilowatthours' = @{ Category = 'Energy'; Factor = 3600000 }
            'kgm/s' = @{ Category = 'Momentum'; Factor = 1 }
            'm/s²' = @{ Category = 'Acceleration'; Factor = 1 }
            'g' = @{ Category = 'Acceleration'; Factor = 9.81 }
            'newtons' = @{ Category = 'Force'; Factor = 1 }
            'poundforce' = @{ Category = 'Force'; Factor = 4.44822 }
            'hertz' = @{ Category = 'Frequency'; Factor = 1 }
            'kilohertz' = @{ Category = 'Frequency'; Factor = 1000 }
            'megahertz' = @{ Category = 'Frequency'; Factor = 1000000 }
            'radians' = @{ Category = 'Angle'; Factor = 1 }
            'degrees' = @{ Category = 'Angle'; Factor = 0.0174533 }
            'kg/m³' = @{ Category = 'Density'; Factor = 1 }
            'cubicmeters' = @{ Category = 'Volume'; Factor = 1 }
            'liters' = @{ Category = 'Volume'; Factor = 0.001 }
            'cubiccentimeters' = @{ Category = 'Volume'; Factor = 0.000001 }
            'squaremeters' = @{ Category = 'Area'; Factor = 1 }
            'squarecentimeters' = @{ Category = 'Area'; Factor = 0.0001 }
            'acres' = @{ Category = 'Area'; Factor = 4046.86 }
            'squarefeet' = @{ Category = 'Area'; Factor = 0.092903 }
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Converting $Value from $FromUnit to $ToUnit"
        )
    }

    process {

        if (-not $unitData.ContainsKey($FromUnit) -or -not $unitData.ContainsKey($ToUnit)) {
            throw "Unknown unit: $FromUnit or $ToUnit"
        }

        $fromCategory = $unitData[$FromUnit].Category
        $toCategory = $unitData[$ToUnit].Category

        if ($fromCategory -ne $toCategory) {
            throw "Incompatible units: $FromUnit ($fromCategory) and $ToUnit ($toCategory)"
        }

        # convert to base unit
        $baseValue = $Value * $unitData[$FromUnit].Factor

        # convert from base to target
        $result = $baseValue / $unitData[$ToUnit].Factor

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Conversion result: $result $ToUnit"
        )
    }

    end {

        return [Math]::Round($result, 4)
    }
}
################################################################################