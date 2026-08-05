using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates orbital velocity.
.DESCRIPTION
Uses v = sqrt(G M / r).

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
Get-OrbitalVelocityByRadiusAndMass -RadiusInMeters 6371000 -CentralMassInKilograms 5.972e24 -As ""km/h""
```

Uses Earth's mass and radius for demonstration.
.EXAMPLE
```powershell
Get-OrbitalVelocityByRadiusAndMass 10000000 1e26
```

Simple calculation with default m/s output.
")]
    [Cmdlet(VerbsCommon.Get, "OrbitalVelocityByRadiusAndMass")]
    [OutputType(typeof(double))]
    public class GetOrbitalVelocityByRadiusAndMassCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Orbital radius in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Orbital radius in meters")]
        public double RadiusInMeters { get; set; }

        /// <summary>
        /// Central mass in kg
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Central mass in kg")]
        public double CentralMassInKilograms { get; set; }

        /// <summary>
        /// Output unit for velocity
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Output unit for velocity")]
        [ValidateSet("m/s", "km/h", "mph", "ft/s")]
        public string As { get; set; } = "m/s";

        private const double GravitationalConstant = 6.67430e-11; // m³ kg⁻¹ s⁻²

        /// <summary>
        /// Begin processing - initialize gravitational constant
        /// </summary>
        protected override void BeginProcessing()
        {
            // Gravitational constant is defined as a constant
        }

        /// <summary>
        /// Process record - calculate orbital velocity and convert units
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate orbital velocity using v = sqrt(G * M / r)
            double velocity = Math.Sqrt(GravitationalConstant * CentralMassInKilograms / RadiusInMeters);

            // Convert velocity to desired unit using PowerShell function for compatibility
            var script = $"GenXdev\\Convert-PhysicsUnit -Value {velocity} -FromUnit 'm/s' -ToUnit '{As}'";
            var result = InvokeCommand.InvokeScript(script);

            // Output the converted velocity
            WriteObject(result[0]);
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup required
        }
    }
}
// ###############################################################################