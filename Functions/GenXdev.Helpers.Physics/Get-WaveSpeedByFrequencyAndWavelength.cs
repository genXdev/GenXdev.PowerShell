using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates wave speed.
.DESCRIPTION
Uses v = f λ.

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
Get-WaveSpeedByFrequencyAndWavelength -FrequencyInHertz 440 -WavelengthInMeters 0.78 -As ""km/h""
```

Calculates wave speed using v = f * λ.
.EXAMPLE
```powershell
Get-WaveSpeedByFrequencyAndWavelength 1000 0.34
```

Calculates wave speed with positional parameters.
")]
    [Cmdlet(VerbsCommon.Get, "WaveSpeedByFrequencyAndWavelength")]
    [OutputType(typeof(double))]
    public class GetWaveSpeedByFrequencyAndWavelengthCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Frequency in Hz
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Frequency in Hz"
        )]
        public double FrequencyInHertz { get; set; }

        /// <summary>
        /// Wavelength in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Wavelength in meters"
        )]
        public double WavelengthInMeters { get; set; }

        /// <summary>
        /// Output unit for speed
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "Output unit for speed"
        )]
        [ValidateSet("m/s", "km/h", "mph", "ft/s")]
        public string As { get; set; } = "m/s";

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate wave speed using v = f * λ
            double speed = FrequencyInHertz * WavelengthInMeters;

            // Convert the unit using PowerShell function
            string script = $"GenXdev\\Convert-PhysicsUnit -Value {speed} -FromUnit 'm/s' -ToUnit '{As}'";
            var results = InvokeCommand.InvokeScript(script);

            // Extract the result from the script invocation
            object result = results[0].BaseObject;

            // Write the result
            WriteObject(result);
        }
    }
}