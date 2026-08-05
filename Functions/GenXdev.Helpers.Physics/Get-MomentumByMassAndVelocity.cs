using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates linear momentum.
.DESCRIPTION
Uses p = m v.

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
    [Cmdlet(VerbsCommon.Get, "MomentumByMassAndVelocity")]
    [OutputType(typeof(double))]
    public class GetMomentumByMassAndVelocityCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Mass in kg
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Mass in kg"
        )]
        public double MassInKilograms { get; set; }

        /// <summary>
        /// Velocity in m/s
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Velocity in m/s"
        )]
        public double VelocityInMetersPerSecond { get; set; }

        /// <summary>
        /// Output unit for momentum
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Output unit for momentum"
        )]
        [ValidateSet("kgm/s")]
        public string As { get; set; } = "kgm/s";

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate momentum using p = m * v
            double momentum = MassInKilograms * VelocityInMetersPerSecond;

            // Convert the unit using PowerShell function
            string script = $"GenXdev\\Convert-PhysicsUnit -Value {momentum} -FromUnit 'kgm/s' -ToUnit '{As}'";
            var results = InvokeCommand.InvokeScript(script);

            // Extract the result from the script invocation
            object result = results[0].BaseObject;

            // Write the result
            WriteObject(result);
        }
    }
}