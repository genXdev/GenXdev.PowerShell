using System.Collections;
using System.Globalization;
using System.Management.Automation;

namespace GenXdev.Helpers
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets the default web language key based on the system's current language
settings.
.DESCRIPTION
* Retrieves the current system language and culture settings and maps them
  to the corresponding web language dictionary key used by translation
  services.

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
Get-DefaultWebLanguage
```

Returns ""English"" for an English system, ""Dutch"" for a Dutch system, etc.
")]
    [Cmdlet(VerbsCommon.Get, "DefaultWebLanguage")]
    [OutputType(typeof(string))]
    public class GetDefaultWebLanguageCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Get the current system culture info
            var systemCulture = CultureInfo.CurrentUICulture;
            WriteVerbose($"System culture: {systemCulture.Name}");

            // Get the dictionary of supported languages
            var webLanguagesResult = InvokeCommand.InvokeScript("GenXdev\\Get-WebLanguageDictionary");
            WriteVerbose("t:" + webLanguagesResult[0].BaseObject.GetType().FullName);
            var webLanguages = webLanguagesResult[0].BaseObject as Dictionary<string, string>;

            if (webLanguages == null)
            {
                throw new InvalidOperationException("Failed to retrieve wzeb language dictionary");
            }

            // Get the reversed dictionary (language codes to names)
            var reversedDict = new Hashtable();
            foreach (var key in webLanguages.Keys)
            {
                reversedDict[webLanguages[key]] = key;
            }

            // Try to find exact match first (e.g. "pt-BR" for Brazilian Portuguese)
            if (reversedDict.ContainsKey(systemCulture.Name))
            {
                WriteObject(reversedDict[systemCulture.Name]);
                return;
            }

            // Try to match just the language part (e.g. "pt" for Portuguese)
            var languageCode = systemCulture.TwoLetterISOLanguageName;
            foreach (var key in webLanguages.Keys)
            {
                if (webLanguages[key].Equals(languageCode))
                {
                    WriteObject(key);
                    return;
                }
            }

            // Default to English if no match found
            WriteVerbose("No matching language found, defaulting to English");
            WriteObject("English");
        }
    }
}