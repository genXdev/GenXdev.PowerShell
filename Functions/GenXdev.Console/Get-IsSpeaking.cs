using System.Management.Automation;

namespace GenXdev.Console
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Returns true if the text-to-speech engine is speaking.
.DESCRIPTION
Checks the state of both the default and customized speech synthesizers to determine if either is currently speaking. Returns true if speech is in progress, false otherwise.

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
Get-IsSpeaking
```

Returns true if the text-to-speech engine is speaking.

.EXAMPLE
```powershell
iss
```

Returns true if the text-to-speech engine is speaking (using alias).
")]
    [Cmdlet(VerbsCommon.Get, "IsSpeaking")]
    [Alias("iss")]
    [OutputType(typeof(System.Boolean))]
    public class GetIsSpeakingCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Checking speech synthesizer states...");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                // Execute the same PowerShell logic to maintain exact compatibility
                var results = InvokeCommand.InvokeScript(
                    "([GenXdev.Helpers.Misc]::Speech.IsSpeaking) -or " +
                    "([GenXdev.Helpers.Misc]::SpeechCustomized.IsSpeaking)");

                // Return the boolean result
                WriteObject(results[0].BaseObject);
            }
            catch (Exception ex)
            {
                // Return false if unable to check speech state, matching original behavior
                WriteVerbose("Failed to check speech state: " + ex.Message);
                WriteObject(false);
            }
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}