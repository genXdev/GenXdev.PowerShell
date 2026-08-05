using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates resonant frequency for a closed pipe.
.DESCRIPTION
Uses f = v / (4 L) for fundamental frequency.

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
Get-ResonantFrequencyByLengthAndSpeed -LengthInMeters 0.5 -Medium ""air"" -As ""kilohertz""
```

Calculates the resonant frequency for a 0.5 meter pipe in air, output in kilohertz.
.EXAMPLE
```powershell
Get-ResonantFrequencyByLengthAndSpeed 1 -SpeedInMetersPerSecond 343
```

Calculates the resonant frequency for a 1 meter pipe with wave speed 343 m/s.
")]
    [Cmdlet(VerbsCommon.Get, "ResonantFrequencyByLengthAndSpeed")]
    [OutputType(typeof(double))]
    public class GetResonantFrequencyByLengthAndSpeedCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Length in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Length in meters")]
        public double LengthInMeters { get; set; }

        /// <summary>
        /// Wave speed in m/s
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            ParameterSetName = "BySpeed",
            HelpMessage = "Wave speed in m/s")]
        public double SpeedInMetersPerSecond { get; set; }

        /// <summary>
        /// The medium
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            ParameterSetName = "ByMedium",
            HelpMessage = "The medium")]
        [ValidateSet("air", "water", "seawater", "steel", "glass", "lead", "gold", "copper", "rubber", "vacuum", "helium", "co2", "methane")]
        public string Medium { get; set; }

        /// <summary>
        /// Output unit for frequency
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Output unit for frequency")]
        [ValidateSet("hertz", "kilohertz", "megahertz")]
        public string As { get; set; } = "hertz";

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Check if using ByMedium parameter set
            if (ParameterSetName == "ByMedium")
            {
                // Set speed based on medium
                switch (Medium.ToLower())
                {
                    case "air":
                        SpeedInMetersPerSecond = 343;
                        break;
                    case "water":
                        SpeedInMetersPerSecond = 1480;
                        break;
                    case "seawater":
                        SpeedInMetersPerSecond = 1530;
                        break;
                    case "steel":
                        SpeedInMetersPerSecond = 5960;
                        break;
                    case "glass":
                        SpeedInMetersPerSecond = 4540;
                        break;
                    case "lead":
                        SpeedInMetersPerSecond = 1210;
                        break;
                    case "gold":
                        SpeedInMetersPerSecond = 3240;
                        break;
                    case "copper":
                        SpeedInMetersPerSecond = 4600;
                        break;
                    case "rubber":
                        SpeedInMetersPerSecond = 60;
                        break;
                    case "vacuum":
                        SpeedInMetersPerSecond = 0;
                        break;
                    case "helium":
                        SpeedInMetersPerSecond = 965;
                        break;
                    case "co2":
                        SpeedInMetersPerSecond = 259;
                        break;
                    case "methane":
                        SpeedInMetersPerSecond = 430;
                        break;
                }

                // Write verbose message
                WriteVerbose($"Using wave speed in {Medium}: {SpeedInMetersPerSecond} m/s");

                // Check for vacuum
                if (SpeedInMetersPerSecond == 0)
                {
                    // Throw terminating error for vacuum
                    ThrowTerminatingError(new ErrorRecord(
                        new Exception("No wave propagation in vacuum"),
                        "VacuumError",
                        ErrorCategory.InvalidArgument,
                        null));
                }
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate frequency using f = v / (4 * L)
            double frequency = SpeedInMetersPerSecond / (4.0 * LengthInMeters);

            // Store frequency for end processing
            this.frequency = frequency;
        }

        /// <summary>
        /// End processing - cleanup and output logic
        /// </summary>
        protected override void EndProcessing()
        {
            // Convert frequency using GenXdev\\Convert-PhysicsUnit
            var scriptBlock = ScriptBlock.Create(
                "param($value, $fromUnit, $toUnit) " +
                "GenXdev\\Convert-PhysicsUnit -Value $value -FromUnit $fromUnit -ToUnit $toUnit");

            // Invoke the script block
            var results = scriptBlock.Invoke(frequency, "hertz", As);

            // Get the result as double
            double result = (double)results[0].BaseObject;

            // Write the result
            WriteObject(result);
        }

        // Private field to store frequency between ProcessRecord and EndProcessing
        private double frequency;
    }
}
// ###############################################################################