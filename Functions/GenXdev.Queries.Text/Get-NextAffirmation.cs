using System.Text.Json;
using System.Management.Automation;

namespace GenXdev.Queries.Text
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Returns a random affirmation text from the affirmations.dev API.
.DESCRIPTION
* Retrieves a random affirmation from the affirmations.dev API and
  optionally speaks it using text-to-speech.

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
Get-NextAffirmation
```

Retrieves a random affirmation from the API.
.EXAMPLE
```powershell
Get-NextAffirmation -Speak
```

Retrieves a random affirmation and speaks it using text-to-speech.
")]
    [Cmdlet(VerbsCommon.Get, "NextAffirmation")]
    [Alias("WhatAboutIt")]
    [OutputType(typeof(string))]
    public class GetNextAffirmationCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// When specified, uses text-to-speech to speak the affirmation out loud.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Use text-to-speech to speak the affirmation"
        )]
        public SwitchParameter Speak { get; set; }

        /// <summary>
        /// Begin processing - initialize API endpoint
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Using API endpoint: https://www.affirmations.dev/");
        }

        /// <summary>
        /// Process record - fetch and process affirmation
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                WriteVerbose("Fetching affirmation from API...");

                using (var client = new HttpClient())
                {
                    client.Timeout = TimeSpan.FromSeconds(2);

                    var response = client.GetStringAsync("https://www.affirmations.dev/").Result;
                    var jsonDoc = JsonDocument.Parse(response);
                    var affirmation = jsonDoc.RootElement.GetProperty("affirmation").GetString();

                    if (Speak)
                    {
                        WriteVerbose("Speaking affirmation using text-to-speech");
                        var speechScript = ScriptBlock.Create("param($affirmation) GenXdev\\Start-TextToSpeech $affirmation");
                        speechScript.Invoke(affirmation);
                    }

                    WriteObject(affirmation);
                }
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(ex, "FailedToRetrieveAffirmation", ErrorCategory.ConnectionError, null));
            }
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}