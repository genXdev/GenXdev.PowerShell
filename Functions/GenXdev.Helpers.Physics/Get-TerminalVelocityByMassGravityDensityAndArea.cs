using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates terminal velocity.
.DESCRIPTION
Uses v = sqrt(2 m g / (ρ A C)).

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
```powershell
Get-TerminalVelocityByMassGravityDensityAndArea -MassInKilograms 80 -DensityInKilogramsPerCubicMeter 1.225 -AreaInSquareMeters 0.7 -DragCoefficient 1.0 -As ""mph""
```

Calculates the terminal velocity for a mass of 80 kg in air with a drag coefficient of 1.0, outputting the result in mph.
.EXAMPLE
```powershell
Get-TerminalVelocityByMassGravityDensityAndArea 70 1.225 0.8 0.8
```

Uses positional parameters to calculate terminal velocity.
")]
    [Cmdlet(VerbsCommon.Get, "TerminalVelocityByMassGravityDensityAndArea")]
    [OutputType(typeof(double))]
    public class GetTerminalVelocityByMassGravityDensityAndAreaCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Mass in kg
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Mass in kg")]
        public double MassInKilograms { get; set; }

        /// <summary>
        /// Gravity in m/s² (default: 9.81)
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = "Gravity in m/s² (default: 9.81)")]
        public double GravityInMetersPerSecondSquared { get; set; } = 9.81;

        /// <summary>
        /// Fluid density in kg/m³
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 2,
            HelpMessage = "Fluid density in kg/m³")]
        public double DensityInKilogramsPerCubicMeter { get; set; }

        /// <summary>
        /// Cross-sectional area in m²
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 3,
            HelpMessage = "Cross-sectional area in m²")]
        public double AreaInSquareMeters { get; set; }

        /// <summary>
        /// Drag coefficient (default: 0.5)
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 4,
            HelpMessage = "Drag coefficient (default: 0.5)")]
        public double DragCoefficient { get; set; } = 0.5;

        /// <summary>
        /// Output unit for velocity
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 5,
            HelpMessage = "Output unit for velocity")]
        [ValidateSet("m/s", "km/h", "mph", "ft/s")]
        public string As { get; set; } = "m/s";

        protected override void BeginProcessing()
        {
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate terminal velocity using the formula v = sqrt(2 m g / (ρ A C))
            double velocity = Math.Sqrt((2 * MassInKilograms * GravityInMetersPerSecondSquared) /
                (DensityInKilogramsPerCubicMeter * AreaInSquareMeters * DragCoefficient));

            // Convert the velocity to the desired unit using GenXdev\\Convert-PhysicsUnit
            var scriptBlock = ScriptBlock.Create(@"
                param($value, $fromUnit, $toUnit)
                GenXdev\\Convert-PhysicsUnit -Value $value -FromUnit $fromUnit -ToUnit $toUnit
            ");
            var result = scriptBlock.Invoke(velocity, "m/s", As);

            // Output the result
            WriteObject(result[0].BaseObject);
        }

        protected override void EndProcessing()
        {
        }
    }
}