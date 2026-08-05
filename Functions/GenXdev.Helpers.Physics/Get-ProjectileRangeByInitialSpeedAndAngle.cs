using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates the range of a projectile.
.DESCRIPTION
Uses the formula R = (v² sin(2θ)) / g for ideal projectile motion.

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
Get-ProjectileRangeByInitialSpeedAndAngle -InitialSpeedInMetersPerSecond 20 -AngleInDegrees 45 -As ""feet""
```

Calculates the range using the projectile motion formula.
.EXAMPLE
```powershell
Get-ProjectileRangeByInitialSpeedAndAngle 30 30
```

Calculates the range with positional parameters.
")]
    [Cmdlet(VerbsCommon.Get, "ProjectileRangeByInitialSpeedAndAngle")]
    [OutputType(typeof(double))]
    public class GetProjectileRangeByInitialSpeedAndAngleCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Initial speed in m/s
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Initial speed in m/s"
        )]
        public double InitialSpeedInMetersPerSecond { get; set; }

        /// <summary>
        /// Launch angle in degrees
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Launch angle in degrees"
        )]
        public double AngleInDegrees { get; set; }

        /// <summary>
        /// Gravity in m/s²
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Gravity in m/s² (default: 9.81)"
        )]
        public double GravityInMetersPerSecondSquared { get; set; } = 9.81;

        /// <summary>
        /// Output unit for range
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 3,
            HelpMessage = "Output unit for range"
        )]
        [ValidateSet("meters", "kilometers", "centimeters", "millimeters", "feet", "inches", "miles", "yards")]
        public string As { get; set; } = "meters";

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
            double thetaRad = AngleInDegrees * Math.PI / 180;

            // Calculate range using R = (v² sin(2θ)) / g
            double range = (InitialSpeedInMetersPerSecond * InitialSpeedInMetersPerSecond * Math.Sin(2 * thetaRad)) / GravityInMetersPerSecondSquared;

            // Convert the unit using PowerShell function
            string script = $"GenXdev\\Convert-PhysicsUnit -Value {range} -FromUnit 'meters' -ToUnit '{As}'";
            var results = InvokeCommand.InvokeScript(script);

            // Extract the result from the script invocation
            object result = results[0].BaseObject;

            // Write the result
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