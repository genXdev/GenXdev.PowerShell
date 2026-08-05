using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates the time of flight for a projectile.
.DESCRIPTION
Uses T = (2 v sinθ) / g for ideal motion.

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
Get-TimeOfFlightByInitialVelocityAndAngle -InitialVelocityInMetersPerSecond 20 -AngleInDegrees 45 -As ""minutes""
```

Calculates time of flight for a projectile launched at 20 m/s at 45 degrees, output in minutes.
.EXAMPLE
```powershell
Get-TimeOfFlightByInitialVelocityAndAngle 30 30
```

Calculates time of flight for a projectile launched at 30 m/s at 30 degrees.
")]
    [Cmdlet(VerbsCommon.Get, "TimeOfFlightByInitialVelocityAndAngle")]
    [OutputType(typeof(double))]
    public class GetTimeOfFlightByInitialVelocityAndAngleCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Initial velocity in m/s
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Initial velocity in m/s")]
        public double InitialVelocityInMetersPerSecond { get; set; }

        /// <summary>
        /// Launch angle in degrees
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Launch angle in degrees")]
        public double AngleInDegrees { get; set; }

        /// <summary>
        /// Gravity in m/s² (default: 9.81)
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Gravity in m/s² (default: 9.81)")]
        public double GravityInMetersPerSecondSquared { get; set; } = 9.81;

        /// <summary>
        /// Output unit for time
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 3,
            HelpMessage = "Output unit for time")]
        [ValidateSet("seconds", "minutes", "hours", "milliseconds", "days")]
        public string As { get; set; } = "seconds";

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
            // Convert angle from degrees to radians
            double thetaRad = AngleInDegrees * Math.PI / 180.0;

            // Calculate time of flight using T = (2 v sinθ) / g
            double time = (2.0 * InitialVelocityInMetersPerSecond * Math.Sin(thetaRad)) / GravityInMetersPerSecondSquared;

            // Convert the result to the desired unit using Convert-PhysicsUnit
            var result = InvokeCommand.InvokeScript($"GenXdev\\Convert-PhysicsUnit -Value {time} -FromUnit 'seconds' -ToUnit '{As}'");

            // Output the result
            WriteObject(result);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}
// ###############################################################################