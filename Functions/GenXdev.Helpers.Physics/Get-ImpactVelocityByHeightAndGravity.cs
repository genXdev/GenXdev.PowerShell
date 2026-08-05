using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates impact velocity from height.
.DESCRIPTION
Uses v = sqrt(2 g h) ignoring air resistance.

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
Get-ImpactVelocityByHeightAndGravity -HeightInMeters 100 -As ""km/h""
```

Calculates impact velocity for a 100 meter fall and outputs in km/h.
.EXAMPLE
```powershell
Get-ImpactVelocityByHeightAndGravity 50
```

Calculates impact velocity for a 50 meter fall using default units.
")]
    [Cmdlet(VerbsCommon.Get, "ImpactVelocityByHeightAndGravity")]
    [OutputType(typeof(double))]
    public class GetImpactVelocityByHeightAndGravityCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Height in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Height in meters")]
        public double HeightInMeters { get; set; }

        /// <summary>
        /// Gravity in m/s²
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = "Gravity in m/s². Default 9.81.")]
        public double GravityInMetersPerSecondSquared { get; set; } = 9.81;

        /// <summary>
        /// Output unit for velocity
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Output unit for velocity. Default 'm/s'.")]
        [ValidateSet("m/s", "km/h", "mph", "ft/s")]
        public string As { get; set; } = "m/s";

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate impact velocity using v = sqrt(2 g h)
            double velocity = Math.Sqrt(2 * GravityInMetersPerSecondSquared * HeightInMeters);

            // Convert velocity to desired unit using GenXdev\\Convert-PhysicsUnit
            var script = $"GenXdev\\Convert-PhysicsUnit -Value {velocity} -FromUnit 'm/s' -ToUnit '{As}'";
            var results = InvokeCommand.InvokeScript(script);

            // Output the converted velocity value
            if (results != null && results.Count > 0)
            {
                WriteObject(results[0]);
            }
        }
    }
}