using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates Doppler shifted frequency.
.DESCRIPTION
Uses f' = f * (v + vo) / (v - vs), speeds positive towards each other.

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
Get-DopplerFrequencyShiftBySourceSpeedAndObserverSpeed -OriginalFrequencyInHertz 440 -SourceSpeedInMetersPerSecond 10 -ObserverSpeedInMetersPerSecond 5 -Medium ""water"" -As ""kilohertz""
```

Calculates the Doppler shifted frequency for a 440 Hz tone with source moving at 10 m/s towards observer, observer moving at 5 m/s towards source, in water medium, output in kilohertz.
.EXAMPLE
```powershell
Get-DopplerFrequencyShiftBySourceSpeedAndObserverSpeed 440 10 0 -SpeedOfSoundInMetersPerSecond 1480
```

Calculates the Doppler shifted frequency for a 440 Hz tone with source moving at 10 m/s, observer stationary, speed of sound 1480 m/s.
")]
    [Cmdlet(VerbsCommon.Get, "DopplerFrequencyShiftBySourceSpeedAndObserverSpeed")]
    [OutputType(typeof(double))]
    public class GetDopplerFrequencyShiftBySourceSpeedAndObserverSpeedCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Original frequency in Hz
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Original frequency in Hz"
        )]
        public double OriginalFrequencyInHertz { get; set; }

        /// <summary>
        /// Source speed in m/s (positive towards observer)
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Source speed in m/s (positive towards observer)"
        )]
        public double SourceSpeedInMetersPerSecond { get; set; }

        /// <summary>
        /// Observer speed in m/s (positive towards source)
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 2,
            HelpMessage = "Observer speed in m/s (positive towards source)"
        )]
        public double ObserverSpeedInMetersPerSecond { get; set; }

        /// <summary>
        /// Speed of sound in m/s (default: 343)
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 3,
            ParameterSetName = "BySpeed",
            HelpMessage = "Speed of sound in m/s (default: 343)"
        )]
        public double SpeedOfSoundInMetersPerSecond { get; set; } = 343;

        /// <summary>
        /// The medium
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 3,
            ParameterSetName = "ByMedium",
            HelpMessage = "The medium"
        )]
        [ValidateSet("air", "water", "seawater", "steel", "glass", "lead", "gold", "copper", "rubber", "vacuum", "helium", "co2", "methane")]
        public string Medium { get; set; }

        /// <summary>
        /// Output unit for frequency
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 4,
            HelpMessage = "Output unit for frequency"
        )]
        [ValidateSet("hertz", "kilohertz", "megahertz")]
        public string As { get; set; } = "hertz";

        /// <summary>
        /// Begin processing - set speed of sound based on medium if specified
        /// </summary>
        protected override void BeginProcessing()
        {
            if (ParameterSetName == "ByMedium")
            {
                switch (Medium)
                {
                    case "air":
                        SpeedOfSoundInMetersPerSecond = 343;
                        break;
                    case "water":
                        SpeedOfSoundInMetersPerSecond = 1480;
                        break;
                    case "seawater":
                        SpeedOfSoundInMetersPerSecond = 1530;
                        break;
                    case "steel":
                        SpeedOfSoundInMetersPerSecond = 5960;
                        break;
                    case "glass":
                        SpeedOfSoundInMetersPerSecond = 4540;
                        break;
                    case "lead":
                        SpeedOfSoundInMetersPerSecond = 1210;
                        break;
                    case "gold":
                        SpeedOfSoundInMetersPerSecond = 3240;
                        break;
                    case "copper":
                        SpeedOfSoundInMetersPerSecond = 4600;
                        break;
                    case "rubber":
                        SpeedOfSoundInMetersPerSecond = 60;
                        break;
                    case "vacuum":
                        SpeedOfSoundInMetersPerSecond = 0;
                        break;
                    case "helium":
                        SpeedOfSoundInMetersPerSecond = 965;
                        break;
                    case "co2":
                        SpeedOfSoundInMetersPerSecond = 259;
                        break;
                    case "methane":
                        SpeedOfSoundInMetersPerSecond = 430;
                        break;
                }

                WriteVerbose($"Using speed of sound in {Medium}: {SpeedOfSoundInMetersPerSecond} m/s");

                if (SpeedOfSoundInMetersPerSecond == 0)
                {
                    ThrowTerminatingError(new ErrorRecord(
                        new Exception("No sound propagation in vacuum"),
                        "VacuumError",
                        ErrorCategory.InvalidArgument,
                        null
                    ));
                }
            }
        }

        /// <summary>
        /// Process record - calculate Doppler shift and convert unit
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate the shifted frequency
            double shifted = OriginalFrequencyInHertz * (SpeedOfSoundInMetersPerSecond + ObserverSpeedInMetersPerSecond) / (SpeedOfSoundInMetersPerSecond - SourceSpeedInMetersPerSecond);

            // Convert to desired unit using PowerShell function
            var convertScript = ScriptBlock.Create("param($value, $fromUnit, $toUnit) GenXdev\\Convert-PhysicsUnit -Value $value -FromUnit $fromUnit -ToUnit $toUnit");
            var result = convertScript.Invoke(shifted, "hertz", As);

            WriteObject(result[0]);
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}