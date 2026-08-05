using System.Management.Automation;

namespace GenXdev.AI.Queries
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets the configured default language for image metadata operations.
.DESCRIPTION
* This cmdlet retrieves the default language used by the GenXdev.AI module
  for image metadata operations.
* It checks Global variables first (unless SkipSession is specified), then
  falls back to persistent preferences, and finally uses system defaults.

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
Get-AIMetaLanguage
```

Get the currently configured language from Global variables or preferences.
.EXAMPLE
```powershell
Get-AIMetaLanguage -SkipSession
```

Get the configured language from persistent preferences, ignoring session.
.EXAMPLE
```powershell
Get-AIMetaLanguage -ClearSession
```

Clear the session setting and get language from persistent preferences.
")]
    [Cmdlet(VerbsCommon.Get, "AIMetaLanguage")]
    [OutputType(typeof(string))]
    [Alias("getimgmetalang")]
    public partial class GetAIMetaLanguageCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Optional language override. If specified, this language will be returned
        /// instead of retrieving from configuration.
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = false,
            HelpMessage = "The default language for image metadata operations")]
        [ValidateSet(
            "Afrikaans",
            "Akan",
            "Albanian",
            "Amharic",
            "Arabic",
            "Armenian",
            "Azerbaijani",
            "Basque",
            "Belarusian",
            "Bemba",
            "Bengali",
            "Bihari",
            "Bosnian",
            "Breton",
            "Bulgarian",
            "Cambodian",
            "Catalan",
            "Cherokee",
            "Chichewa",
            "Chinese (Simplified)",
            "Chinese (Traditional)",
            "Corsican",
            "Croatian",
            "Czech",
            "Danish",
            "Dutch",
            "English",
            "Esperanto",
            "Estonian",
            "Ewe",
            "Faroese",
            "Filipino",
            "Finnish",
            "French",
            "Frisian",
            "Ga",
            "Galician",
            "Georgian",
            "German",
            "Greek",
            "Guarani",
            "Gujarati",
            "Haitian Creole",
            "Hausa",
            "Hawaiian",
            "Hebrew",
            "Hindi",
            "Hungarian",
            "Icelandic",
            "Igbo",
            "Indonesian",
            "Interlingua",
            "Irish",
            "Italian",
            "Japanese",
            "Javanese",
            "Kannada",
            "Kazakh",
            "Kinyarwanda",
            "Kirundi",
            "Kongo",
            "Korean",
            "Krio (Sierra Leone)",
            "Kurdish",
            "Kurdish (Soranî)",
            "Kyrgyz",
            "Laothian",
            "Latin",
            "Latvian",
            "Lingala",
            "Lithuanian",
            "Lozi",
            "Luganda",
            "Luo",
            "Macedonian",
            "Malagasy",
            "Malay",
            "Malayalam",
            "Maltese",
            "Maori",
            "Marathi",
            "Mauritian Creole",
            "Moldavian",
            "Mongolian",
            "Montenegrin",
            "Nepali",
            "Nigerian Pidgin",
            "Northern Sotho",
            "Norwegian",
            "Norwegian (Nynorsk)",
            "Occitan",
            "Oriya",
            "Oromo",
            "Pashto",
            "Persian",
            "Polish",
            "Portuguese (Brazil)",
            "Portuguese (Portugal)",
            "Punjabi",
            "Quechua",
            "Romanian",
            "Romansh",
            "Runyakitara",
            "Russian",
            "Scots Gaelic",
            "Serbian",
            "Serbo-Croatian",
            "Sesotho",
            "Setswana",
            "Seychellois Creole",
            "Shona",
            "Sindhi",
            "Sinhalese",
            "Slovak",
            "Slovenian",
            "Somali",
            "Spanish",
            "Spanish (Latin American)",
            "Sundanese",
            "Swahili",
            "Swedish",
            "Tajik",
            "Tamil",
            "Tatar",
            "Telugu",
            "Thai",
            "Tigrinya",
            "Tonga",
            "Tshiluba",
            "Tumbuka",
            "Turkish",
            "Turkmen",
            "Twi",
            "Uighur",
            "Ukrainian",
            "Urdu",
            "Uzbek",
            "Vietnamese",
            "Welsh",
            "Wolof",
            "Xhosa",
            "Yiddish",
            "Yoruba",
            "Zulu")]
        public string Language { get; set; }

        /// <summary>
        /// Database path for preference data files.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Database path for preference data files")]
        [Alias("DatabasePath")]
        public string PreferencesDatabasePath { get; set; }

        /// <summary>
        /// Use alternative settings stored in session for AI preferences like Language,
        /// Image collections, etc.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Use alternative settings stored in session for AI " +
                "preferences like Language, Image collections, etc")]
        public SwitchParameter SessionOnly { get; set; }

        /// <summary>
        /// Clear the session setting (Global variable) before retrieving.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Clear the session setting (Global variable) " +
                "before retrieving")]
        public SwitchParameter ClearSession { get; set; }

        /// <summary>
        /// Dont use alternative settings stored in session for AI preferences like
        /// Language, Image collections, etc.
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Dont use alternative settings stored in session " +
                "for AI preferences like Language, Image collections, etc")]
        [Alias("FromPreferences")]
        public SwitchParameter SkipSession { get; set; }

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
            // Check if Language is provided and not empty
            if (!string.IsNullOrWhiteSpace(Language))
            {
                WriteObject(Language);
                return;
            }

            // Copy identical parameters to Get-GenXdevPreference
            var invocationParams = CopyIdenticalParamValues("GenXdev\\Get-GenXdevPreference");

            // Add specific parameters
            invocationParams["Name"] = "AIMetaLanguage";

            // Compute default value: invoke Get-DefaultWebLanguage since Language is null
            var gdwlParams = CopyIdenticalParamValues("GenXdev\\Get-DefaultWebLanguage");
            var defaultValueScript = ScriptBlock.Create("param ($gdwlParams) GenXdev\\Get-DefaultWebLanguage @gdwlParams");
            var defaultValueResult = defaultValueScript.Invoke(gdwlParams);
            var defaultValue = ((PSObject)defaultValueResult[0]).BaseObject.ToString();

            invocationParams["DefaultValue"] = defaultValue;

            // Invoke Get-GenXdevPreference with the param
            // eters

            var script = ScriptBlock.Create("param($params) GenXdev\\Get-GenXdevPreference @params");
            var results = script.Invoke(invocationParams);

            // Write the result as string
            var result = ((PSObject)results[0]).BaseObject.ToString();
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