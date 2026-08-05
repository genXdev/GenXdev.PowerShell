using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates gravitational potential energy.
.DESCRIPTION
Uses PE = m g h.

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
Get-PotentialEnergyByMassHeightAndGravity -MassInKilograms 10 -HeightInMeters 5 -As ""calories""
```

Calculates the gravitational potential energy for a 10kg mass at a height of 5 meters, outputting the result in calories.
.EXAMPLE
```powershell
Get-PotentialEnergyByMassHeightAndGravity 5 10
```

Demonstrates using positional parameters to calculate potential energy.
")]
    [Cmdlet(VerbsCommon.Get, "PotentialEnergyByMassHeightAndGravity")]
    [OutputType(typeof(double))]
    public class GetPotentialEnergyByMassHeightAndGravityCommand : PSGenXdevCmdlet
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
        /// Height in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Height in meters"
        )]
        public double HeightInMeters { get; set; }

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
        /// Output unit for energy
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 3,
            HelpMessage = "Output unit for energy"
        )]
        [ValidateSet("joules", "calories", "kilowatthours")]
        public string As { get; set; } = "joules";

        protected override void ProcessRecord()
        {
            // Calculate the potential energy in joules
            double energy = MassInKilograms * GravityInMetersPerSecondSquared * HeightInMeters;

            // Convert the energy to the desired unit using the PowerShell function
            var results = InvokeCommand.InvokeScript(
                $"GenXdev\\Convert-PhysicsUnit -Value {energy} -FromUnit 'joules' -ToUnit '{As}'"
            );

            // Output the result
            WriteObject(results[0]);
        }
    }
}