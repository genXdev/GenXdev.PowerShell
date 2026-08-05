using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates centripetal acceleration.
.DESCRIPTION
Uses a = v² / r.

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
Get-CentripetalAccelerationByVelocityAndRadius -VelocityInMetersPerSecond 10 -RadiusInMeters 5 -As ""g""
```

Calculates centripetal acceleration for velocity 10 m/s and radius 5 m, output in g units.
.EXAMPLE
```powershell
Get-CentripetalAccelerationByVelocityAndRadius 20 10
```

Calculates centripetal acceleration for velocity 20 m/s and radius 10 m using positional parameters.
")]
    [Cmdlet(VerbsCommon.Get, "CentripetalAccelerationByVelocityAndRadius")]
    [OutputType(typeof(double))]
    public class GetCentripetalAccelerationByVelocityAndRadiusCommand : PSGenXdevCmdlet
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
        /// Radius in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Radius in meters")]
        public double RadiusInMeters { get; set; }

        /// <summary>
        /// Output unit for acceleration
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Output unit for acceleration")]
        [ValidateSet("m/s²", "g")]
        public string As { get; set; } = "m/s²";

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate centripetal acceleration using a = v² / r
            double acceleration = (VelocityInMetersPerSecond * VelocityInMetersPerSecond) / RadiusInMeters;

            // Convert acceleration to desired unit using GenXdev\\Convert-PhysicsUnit
            var script = $"GenXdev\\Convert-PhysicsUnit -Value {acceleration} -FromUnit 'm/s²' -ToUnit '{As}'";
            var results = InvokeCommand.InvokeScript(script);

            // Output the converted acceleration value
            if (results != null && results.Count > 0)
            {
                WriteObject(results[0]);
            }
        }
    }
}