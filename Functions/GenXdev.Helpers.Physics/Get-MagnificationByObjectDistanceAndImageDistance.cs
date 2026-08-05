using System.Management.Automation;

namespace GenXdev.Helpers.Physics
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates magnification for a lens.
.DESCRIPTION
Uses m = - (image distance / object distance).

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
Get-MagnificationByObjectDistanceAndImageDistance -ObjectDistanceInMeters 0.5 -ImageDistanceInMeters 1
```

Calculates magnification with object distance 0.5m and image distance 1m.
.EXAMPLE
```powershell
Get-MagnificationByObjectDistanceAndImageDistance 0.3 0.6
```

Calculates magnification using positional parameters.
")]
    [Cmdlet(VerbsCommon.Get, "MagnificationByObjectDistanceAndImageDistance")]
    [OutputType(typeof(double))]
    public class GetMagnificationByObjectDistanceAndImageDistanceCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Object distance in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "Object distance in meters")]
        public double ObjectDistanceInMeters { get; set; }

        /// <summary>
        /// Image distance in meters
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Image distance in meters")]
        public double ImageDistanceInMeters { get; set; }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Calculate magnification using the formula m = - (image distance / object distance)
            double magnification = -(ImageDistanceInMeters / ObjectDistanceInMeters);

            // Round to 4 decimal places and output the result
            WriteObject(System.Math.Round(magnification, 4));
        }
    }
}
// ###############################################################################