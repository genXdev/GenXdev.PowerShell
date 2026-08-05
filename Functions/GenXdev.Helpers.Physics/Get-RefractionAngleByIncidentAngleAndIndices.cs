using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates refraction angle using Snell's law.
.DESCRIPTION
Uses θ2 = arcsin( (n1 / n2) sin θ1 ).

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
Get-RefractionAngleByIncidentAngleAndIndices -IncidentAngleInDegrees 30 -IndexOfRefraction1 1 -IndexOfRefraction2 1.33 -As ""radians""
```

Calculates the refraction angle when light passes from air (n=1) to water (n=1.33) at 30 degrees incidence.
.EXAMPLE
```powershell
Get-RefractionAngleByIncidentAngleAndIndices 45 1 1.5
```

Calculates the refraction angle when light passes from air (n=1) to glass (n=1.5) at 45 degrees incidence.
")]
    [Cmdlet(VerbsCommon.Get, "RefractionAngleByIncidentAngleAndIndices")]
    [OutputType(typeof(double))]
    public class GetRefractionAngleByIncidentAngleAndIndicesCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Incident angle in degrees
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Incident angle in degrees")]
        public double IncidentAngleInDegrees { get; set; }

        /// <summary>
        /// Refractive index of first medium
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Refractive index of first medium")]
        public double IndexOfRefraction1 { get; set; }

        /// <summary>
        /// Refractive index of second medium
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 2,
            HelpMessage = "Refractive index of second medium")]
        public double IndexOfRefraction2 { get; set; }

        /// <summary>
        /// Output unit for angle
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 3,
            HelpMessage = "Output unit for angle")]
        [ValidateSet("degrees", "radians")]
        public string As { get; set; } = "degrees";

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Convert incident angle from degrees to radians
            double theta1Rad = IncidentAngleInDegrees * Math.PI / 180.0;

            // Calculate sine of refraction angle using Snell's law
            double sinTheta2 = (IndexOfRefraction1 / IndexOfRefraction2) * Math.Sin(theta1Rad);

            // Check for total internal reflection
            if (sinTheta2 > 1.0)
            {
                // Create error record for total internal reflection
                var errorRecord = new ErrorRecord(
                    new InvalidOperationException("Total internal reflection - no refraction"),
                    "TotalInternalReflection",
                    ErrorCategory.InvalidOperation,
                    null);

                // Throw terminating error to match original PowerShell behavior
                ThrowTerminatingError(errorRecord);
            }

            // Calculate refraction angle in radians
            double theta2Rad = Math.Asin(sinTheta2);

            // Convert refraction angle to degrees
            double angle = theta2Rad * 180.0 / Math.PI;

            // Use InvokeCommand to call Convert-PhysicsUnit for unit conversion
            var script = $"GenXdev\\Convert-PhysicsUnit -Value {angle} -FromUnit 'degrees' -ToUnit '{As}'";

            // Invoke the script and get the result
            var results = InvokeCommand.InvokeScript(script);

            // Extract the double result from the collection
            double result = (double)results[0].BaseObject;

            // Write the result to the pipeline
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