using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates the distance fallen during free fall for a given time duration.
.DESCRIPTION
Calculates the distance fallen during free fall using a numerical method that accounts for air resistance and terminal velocity.

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
Get-FreeFallDistance -DurationInSeconds 10 -TerminalVelocityInMetersPerSecond 53 -As ""feet""
```

Calculates the distance fallen in 10 seconds in feet.
.EXAMPLE
```powershell
Get-FreeFallDistance 5
```

Calculates the distance in 5 seconds in meters.
")]
    [Cmdlet(VerbsCommon.Get, "FreeFallDistance")]
    [OutputType(typeof(double))]
    public class GetFreeFallDistanceCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The time duration of the fall in seconds
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The time duration of the fall in seconds")]
        public double DurationInSeconds { get; set; }

        /// <summary>
        /// The terminal velocity in meters per second (default: 53)
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = "The terminal velocity in meters per second (default: 53)")]
        public double TerminalVelocityInMetersPerSecond { get; set; } = 53;

        /// <summary>
        /// The acceleration due to gravity in m/s² (default: 9.81)
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "The acceleration due to gravity in m/s² (default: 9.81)")]
        public double GravityInMetersPerSecondSquared { get; set; } = 9.81;

        /// <summary>
        /// The unit for the output distance
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 3,
            HelpMessage = "The unit for the output distance")]
        [ValidateSet("meters", "kilometers", "centimeters", "millimeters", "feet", "inches", "miles", "yards")]
        public string As { get; set; } = "meters";

        private double time;
        private double distance;
        private double velocity;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // set up numerical integration parameters
            // initialize variables
            time = 0;
            distance = 0;
            velocity = 0;

            WriteVerbose(
                "Starting free fall distance calculation for " + DurationInSeconds + " seconds " +
                "with terminal velocity " + TerminalVelocityInMetersPerSecond + " m/s");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            double dt = 0.01;

            while (time < DurationInSeconds)
            {
                // cap velocity at terminal
                if (velocity >= TerminalVelocityInMetersPerSecond)
                {
                    velocity = TerminalVelocityInMetersPerSecond;
                }
                else
                {
                    velocity += GravityInMetersPerSecondSquared * dt;
                }

                // accumulate distance
                distance += velocity * dt;

                time += dt;

                if (time > 1000)
                {
                    throw new Exception("Calculation timeout exceeded");
                }
            }

            WriteVerbose("Calculated distance: " + distance + " meters");
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // convert to desired unit
            var scriptBlock = ScriptBlock.Create(@"
param($Value, $FromUnit, $ToUnit)
GenXdev.Helpers\Convert-PhysicsUnit -Value $Value -FromUnit $FromUnit -ToUnit $ToUnit
");
            var result = scriptBlock.Invoke(distance, "meters", As);

            WriteObject(result[0].BaseObject);
        }
    }
}
