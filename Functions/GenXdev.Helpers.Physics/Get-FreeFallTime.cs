using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates the time required for an object to fall a given height during free fall.
.DESCRIPTION
Calculates the time duration required for an object to fall a specified height using a numerical method that accounts for air resistance and terminal velocity. The calculation uses small time steps to accurately model the physics of falling objects with realistic terminal velocity constraints.

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
Get-FreeFallTime -HeightInMeters 100 -TerminalVelocityInMs 53
```

Calculates the time required to fall 100 meters with default human terminal velocity.
.EXAMPLE
```powershell
Get-FreeFallTime 50
```

Calculates the time required to fall 50 meters using positional parameter and default terminal velocity.
.EXAMPLE
```powershell
Get-FreeFallTime -HeightInMeters 100 -As ""minutes""
```

Calculates the time required to fall 100 meters and returns the result in minutes.
")]
    [Cmdlet(VerbsCommon.Get, "FreeFallTime")]
    [OutputType(typeof(double))]
    public class GetFreeFallTimeCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The height to fall in meters for which to calculate the time duration.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The height to fall in meters"
        )]
        public double HeightInMeters { get; set; }

        /// <summary>
        /// The terminal velocity in meters per second (default: 53 m/s for human).
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = ("The terminal velocity in meters per second " +
                "(default: 53 m/s for human)")
        )]
        public double TerminalVelocityInMs { get; set; } = 53;

        /// <summary>
        /// The unit for the output time.
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "The unit for the output time"
        )]
        [ValidateSet("seconds", "minutes", "hours", "milliseconds", "days")]
        public string As { get; set; } = "seconds";

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose(
                "Starting free fall time calculation for " + HeightInMeters + " meters " +
                "with terminal velocity " + TerminalVelocityInMs + " m/s"
            );
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Define the acceleration due to gravity in meters per second squared
            double gravity = 9.81;

            // Set up numerical integration parameters for accurate calculation
            double dt = 0.01;

            // Initialize time tracking variable
            double time = 0;

            // Initialize height accumulator
            double height = 0;

            // Initialize velocity tracker
            double velocity = 0;

            // Perform numerical integration using small time steps until height is reached
            while (height < HeightInMeters)
            {
                // Apply air resistance model by capping velocity at terminal velocity
                if (velocity >= TerminalVelocityInMs)
                {
                    // Maintain constant terminal velocity when reached
                    velocity = TerminalVelocityInMs;
                }
                else
                {
                    // Accelerate under gravity when below terminal velocity
                    velocity += gravity * dt;
                }

                // Calculate distance traveled in this time step
                height += velocity * dt;

                // Advance time by one step
                time += dt;

                // Prevent infinite loops with safety timeout
                if (time > 1000)
                {
                    WriteError(new ErrorRecord(
                        new Exception("Calculation timeout exceeded 1000 seconds"),
                        "CalculationTimeout",
                        ErrorCategory.OperationTimeout,
                        null
                    ));

                    WriteObject((double)0);
                    return;
                }
            }

            WriteVerbose("Calculated fall time: " + time + " seconds");

            // Convert to desired unit using PowerShell function
            var scriptBlock = ScriptBlock.Create(
                "param($Value, $FromUnit, $ToUnit) " +
                "GenXdev\\Convert-PhysicsUnit -Value $Value -FromUnit $FromUnit -ToUnit $ToUnit"
            );

            var results = scriptBlock.Invoke(time, "seconds", As);

            // Extract the result from PSObject
            double result = 0;
            if (results.Count > 0 && results[0].BaseObject is double)
            {
                result = (double)results[0].BaseObject;
            }

            // Return the calculated time as double
            WriteObject(result);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}