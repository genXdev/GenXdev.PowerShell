using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates kinetic energy.
.DESCRIPTION
Uses KE = 1/2 m v².

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
Get-KineticEnergyByMassAndVelocity -MassInKilograms 10 -VelocityInMetersPerSecond 5 -As ""calories""
```

Calculates kinetic energy for a 10kg mass moving at 5 m/s and outputs in calories.
.EXAMPLE
```powershell
Get-KineticEnergyByMassAndVelocity 5 10
```

Calculates kinetic energy for a 5kg mass moving at 10 m/s using positional parameters.
")]
    [Cmdlet(VerbsCommon.Get, "KineticEnergyByMassAndVelocity")]
    [OutputType(typeof(double))]
    public class GetKineticEnergyByMassAndVelocityCommand : PSGenXdevCmdlet
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
        /// Velocity in m/s
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Velocity in m/s")]
        public double VelocityInMetersPerSecond { get; set; }

        /// <summary>
        /// Output unit for energy
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Output unit for energy")]
        [ValidateSet("joules", "calories", "kilowatthours")]
        public string As { get; set; } = "joules";

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate kinetic energy using KE = 1/2 m v²
            double energy = 0.5 * MassInKilograms * VelocityInMetersPerSecond * VelocityInMetersPerSecond;

            // Convert energy to desired unit using GenXdev\\Convert-PhysicsUnit
            var script = $"GenXdev\\Convert-PhysicsUnit -Value {energy} -FromUnit 'joules' -ToUnit '{As}'";
            var results = InvokeCommand.InvokeScript(script);

            // Output the converted energy value
            if (results != null && results.Count > 0)
            {
                WriteObject(results[0]);
            }
        }
    }
}