using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates the height fallen during free fall for a given time duration.
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
Get-FreeFallHeight -DurationInSeconds 10 -TerminalVelocityInMs 53
```

Calculates the height fallen in 10 seconds with default human terminal velocity.
.EXAMPLE
```powershell
Get-FreeFallHeight 5
```

Calculates the height fallen in 5 seconds using positional parameter and default terminal velocity.
.EXAMPLE
```powershell
Get-FreeFallHeight -DurationInSeconds 10 -As ""feet""
```

Calculates the height fallen in 10 seconds and returns the result in feet.
")]
    [Cmdlet(VerbsCommon.Get, "FreeFallHeight")]
    [OutputType(typeof(double))]
    public class GetFreeFallHeightCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The time duration of the fall in seconds
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The time duration of the fall in seconds"
        )]
        public double DurationInSeconds { get; set; }

        /// <summary>
        /// The terminal velocity in meters per second (default: 53 m/s for human)
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            HelpMessage = ("The terminal velocity in meters per second " +
                "(default: 53 m/s for human)")
        )]
        public double TerminalVelocityInMs { get; set; } = 53;

        /// <summary>
        /// The unit for the output height
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "The unit for the output height"
        )]
        [ValidateSet("meters", "kilometers", "centimeters", "millimeters", "feet", "inches", "miles", "yards")]
        public string As { get; set; } = "meters";

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose(
                "Starting free fall calculation for " + DurationInSeconds + " seconds " +
                "with terminal velocity " + TerminalVelocityInMs + " m/s"
            );
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // define the acceleration due to gravity in meters per second squared
            double gravity = 9.81;

            // set up numerical integration parameters for accurate calculation
            double dt = 0.01;

            // initialize time tracking variable
            double time = 0;

            // initialize height accumulator
            double height = 0;

            // initialize velocity tracker
            double velocity = 0;

            // perform numerical integration using small time steps
            while (time < DurationInSeconds)
            {
                // apply air resistance model by capping velocity at terminal velocity
                if (velocity >= TerminalVelocityInMs)
                {
                    // maintain constant terminal velocity when reached
                    velocity = TerminalVelocityInMs;
                }
                else
                {
                    // accelerate under gravity when below terminal velocity
                    velocity += gravity * dt;
                }

                // calculate distance traveled in this time step
                height += velocity * dt;

                // advance time by one step
                time += dt;

                // prevent infinite loops with safety timeout
                if (time > 1000)
                {
                    WriteError(new ErrorRecord(
                        new Exception("Calculation timeout exceeded 1000 seconds"),
                        "CalculationTimeout",
                        ErrorCategory.OperationTimeout,
                        null
                    ));

                    WriteObject(0.0);
                    return;
                }
            }

            WriteVerbose("Calculated fall height: " + height + " meters");

            // convert to desired unit
            var scriptBlock = ScriptBlock.Create(
                "param($Value, $FromUnit, $ToUnit) " +
                "GenXdev\\Convert-PhysicsUnit -Value $Value -FromUnit $FromUnit -ToUnit $ToUnit"
            );

            var results = scriptBlock.Invoke(height, "meters", As);

            double result = (double)((PSObject)results[0]).BaseObject;

            // return the calculated height as double
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