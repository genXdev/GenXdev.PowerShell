using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates drag force.
.DESCRIPTION
Uses F = 1/2 C ρ A v².

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
Get-DragForceByVelocityDensityAreaAndCoefficient -VelocityInMetersPerSecond 10 -DensityInKilogramsPerCubicMeter 1.225 -AreaInSquareMeters 1 -Coefficient 0.5 -As ""poundforce""
```

Calculates drag force using velocity 10 m/s, air density 1.225 kg/m³, area 1 m², and coefficient 0.5, outputting in poundforce.
.EXAMPLE
```powershell
Get-DragForceByVelocityDensityAreaAndCoefficient 20 1.225 2 0.3
```

Calculates drag force using positional parameters: velocity 20 m/s, density 1.225 kg/m³, area 2 m², coefficient 0.3.
")]
    [Cmdlet(VerbsCommon.Get, "DragForceByVelocityDensityAreaAndCoefficient")]
    [OutputType(typeof(double))]
    public class GetDragForceByVelocityDensityAreaAndCoefficientCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Velocity in m/s
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Velocity in m/s")]
        public double VelocityInMetersPerSecond { get; set; }

        /// <summary>
        /// Fluid density in kg/m³
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Fluid density in kg/m³")]
        public double DensityInKilogramsPerCubicMeter { get; set; }

        /// <summary>
        /// Cross-sectional area in m²
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 2,
            HelpMessage = "Cross-sectional area in m²")]
        public double AreaInSquareMeters { get; set; }

        /// <summary>
        /// Drag coefficient
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 3,
            HelpMessage = "Drag coefficient")]
        public double Coefficient { get; set; }

        /// <summary>
        /// Output unit for force
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 4,
            HelpMessage = "Output unit for force")]
        [ValidateSet("newtons", "poundforce")]
        public string As { get; set; } = "newtons";

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate the drag force using the formula F = 1/2 C ρ A v²
            double force = 0.5 * Coefficient * DensityInKilogramsPerCubicMeter * AreaInSquareMeters * VelocityInMetersPerSecond * VelocityInMetersPerSecond;

            // Convert the force to the desired unit using the Convert-PhysicsUnit cmdlet
            var script = $"GenXdev\\Convert-PhysicsUnit -Value {force} -FromUnit 'newtons' -ToUnit '{As}'";
            var results = InvokeCommand.InvokeScript(script);

            // Output the converted force value
            WriteObject(results[0].BaseObject);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}