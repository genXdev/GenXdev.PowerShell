using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates buoyant force.
.DESCRIPTION
Uses F = ρ V g.

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

")]
    [Cmdlet(VerbsCommon.Get, "BuoyantForceByDisplacedVolumeAndDensity")]
    [OutputType(typeof(double))]
    public class GetBuoyantForceByDisplacedVolumeAndDensityCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Displaced volume in m³
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Displaced volume in m³"
        )]
        public double DisplacedVolumeInCubicMeters { get; set; }

        /// <summary>
        /// Fluid density in kg/m³
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Fluid density in kg/m³"
        )]
        public double FluidDensityInKilogramsPerCubicMeter { get; set; }

        /// <summary>
        /// Gravity in m/s² (default: 9.81)
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Gravity in m/s² (default: 9.81)"
        )]
        public double GravityInMetersPerSecondSquared { get; set; } = 9.81;

        /// <summary>
        /// Output unit for force
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 3,
            HelpMessage = "Output unit for force"
        )]
        [ValidateSet("newtons", "poundforce")]
        public string As { get; set; } = "newtons";

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate the buoyant force using F = ρ V g
            double force = FluidDensityInKilogramsPerCubicMeter * DisplacedVolumeInCubicMeters * GravityInMetersPerSecondSquared;

            // Convert the force to the desired unit using the existing PowerShell function
            var scriptBlock = ScriptBlock.Create($"GenXdev\\Convert-PhysicsUnit -Value {force} -FromUnit 'newtons' -ToUnit '{As}'");
            var results = scriptBlock.Invoke();

            // Output the converted result
            WriteObject(results[0]);
        }
    }
}
// ###############################################################################