using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates the apparent size of an object at arm's length.
.DESCRIPTION
Computes the apparent size using small angle approximation.

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
Get-ApparentSizeAtArmLength -DistanceInMeters 10 -SizeInMeters 1 -As ""centimeters""
```

Calculates the apparent size of a 1 meter object at 10 meters distance.
.EXAMPLE
```powershell
Get-ApparentSizeAtArmLength 10 1
```

Calculates the apparent size using positional parameters.
")]
    [Cmdlet(VerbsCommon.Get, "ApparentSizeAtArmLength")]
    [OutputType(typeof(double))]
    public class GetApparentSizeAtArmLengthCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The distance to the object in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "The distance to the object in meters")]
        public double DistanceInMeters { get; set; }

        /// <summary>
        /// The actual size of the object in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "The actual size of the object in meters")]
        public double SizeInMeters { get; set; }

        /// <summary>
        /// The arm length in meters (default: 0.7)
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 2,
            HelpMessage = "The arm length in meters (default: 0.7)")]
        public double ArmLengthInMeters { get; set; } = 0.7;

        /// <summary>
        /// The unit for the output size
        /// </summary>
        [Parameter(
            Mandatory = false,
            Position = 3,
            HelpMessage = "The unit for the output size")]
        [ValidateSet("millimeters", "centimeters", "meters", "inches", "feet")]
        public string As { get; set; } = "millimeters";

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Check if distance is valid
            if (DistanceInMeters <= 0)
            {
                // Create error record matching PowerShell behavior
                var exception = new ArgumentException("DistanceInMeters must be greater than zero.");
                var errorRecord = new ErrorRecord(exception, "InvalidDistance", ErrorCategory.InvalidArgument, DistanceInMeters);
                ThrowTerminatingError(errorRecord);
            }

            // Calculate angular size in radians
            double angularSize = SizeInMeters / DistanceInMeters;

            // Calculate apparent size in meters
            double apparentSizeMeters = angularSize * ArmLengthInMeters;

            // Convert to desired unit using the existing Convert-PhysicsUnit cmdlet
            var script = $"GenXdev\\Convert-PhysicsUnit -Value {apparentSizeMeters} -FromUnit 'meters' -ToUnit '{As}'";
            var results = InvokeCommand.InvokeScript(script);

            // Output the result
            WriteObject(results[0].BaseObject);
        }
    }
}
// ###############################################################################