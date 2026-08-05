using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates time for light to travel a distance.
.DESCRIPTION
Uses t = d / c, with c depending on medium.

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
Get-LightTravelTimeByDistance -DistanceInMeters 149597870700 -Medium ""water"" -As ""minutes""
```

Calculates the time for light to travel the distance to the sun through water, in minutes.
.EXAMPLE
```powershell
Get-LightTravelTimeByDistance 300000000 -SpeedOfLightInMetersPerSecond 225000000
```

Calculates time for light to travel 300000000 meters at 225000000 m/s.
")]
    [Cmdlet(VerbsCommon.Get, "LightTravelTimeByDistance")]
    [OutputType(typeof(double))]
    public class GetLightTravelTimeByDistanceCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Distance in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Distance in meters"
        )]
        public double DistanceInMeters { get; set; }

        /// <summary>
        /// Speed of light in m/s (default: 299792458)
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 1,
            ParameterSetName = "BySpeed",
            HelpMessage = "Speed of light in m/s (default: 299792458)"
        )]
        public double SpeedOfLightInMetersPerSecond { get; set; } = 299792458;

        /// <summary>
        /// The medium through which light travels
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            ParameterSetName = "ByMedium",
            HelpMessage = "The medium through which light travels"
        )]
        [ValidateSet("vacuum", "air", "water", "glass", "diamond")]
        public string Medium { get; set; }

        /// <summary>
        /// Output unit for time
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Output unit for time"
        )]
        [ValidateSet("seconds", "minutes", "hours", "milliseconds", "days")]
        public string As { get; set; } = "seconds";

        private double speedOfLight;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            if (ParameterSetName == "ByMedium")
            {
                switch (Medium)
                {
                    case "vacuum":
                        speedOfLight = 299792458;
                        break;
                    case "air":
                        speedOfLight = 299702547;
                        break;
                    case "water":
                        speedOfLight = 225000000;
                        break;
                    case "glass":
                        speedOfLight = 200000000;
                        break;
                    case "diamond":
                        speedOfLight = 124000000;
                        break;
                }

                WriteVerbose($"Using speed of light in {Medium}: {speedOfLight} m/s");
            }
            else
            {
                speedOfLight = SpeedOfLightInMetersPerSecond;
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            double time = DistanceInMeters / speedOfLight;

            var scriptBlock = ScriptBlock.Create("param($value, $fromUnit, $toUnit) GenXdev\\Convert-PhysicsUnit -Value $value -FromUnit $fromUnit -ToUnit $toUnit");

            var result = scriptBlock.Invoke(time, "seconds", As);

            WriteObject(result[0]);
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