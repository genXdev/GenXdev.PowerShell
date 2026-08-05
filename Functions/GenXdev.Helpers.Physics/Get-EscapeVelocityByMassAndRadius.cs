using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates escape velocity.
.DESCRIPTION
Uses v = sqrt(2 G M / r).

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
Get-EscapeVelocityByMassAndRadius -MassInKilograms 5.972e24 -RadiusInMeters 6371000 -As ""km/h""
```

Calculates the escape velocity for a body with Earth's mass and radius.
.EXAMPLE
```powershell
Get-EscapeVelocityByMassAndRadius 1e26 10000000
```

Calculates escape velocity using default m/s units.
")]
    [Cmdlet(VerbsCommon.Get, "EscapeVelocityByMassAndRadius")]
    [OutputType(typeof(double))]
    public class GetEscapeVelocityByMassAndRadiusCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Mass of body in kg
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Mass of body in kg")]
        public double MassInKilograms { get; set; }

        /// <summary>
        /// Radius in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Radius in meters")]
        public double RadiusInMeters { get; set; }

        /// <summary>
        /// Output unit for velocity
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Output unit for velocity")]
        [ValidateSet("m/s", "km/h", "mph", "ft/s")]
        public string As { get; set; } = "m/s";

        private const double G = 6.67430e-11;

        /// <summary>
        /// Begin processing - initialize gravitational constant
        /// </summary>
        protected override void BeginProcessing()
        {
            // Gravitational constant is defined as a constant
        }

        /// <summary>
        /// Process record - calculate escape velocity and convert units
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate escape velocity using v = sqrt(2 G M / r)
            double velocity = Math.Sqrt(2 * G * MassInKilograms / RadiusInMeters);

            // Convert to desired unit using Convert-PhysicsUnit cmdlet
            var scriptResult = InvokeCommand.InvokeScript(
                $"GenXdev\\Convert-PhysicsUnit -Value {velocity} -FromUnit 'm/s' -ToUnit '{As}'");

            // Output the converted result
            WriteObject(scriptResult[0].BaseObject);
        }

        /// <summary>
        /// End processing - cleanup if needed
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}
// ###############################################################################