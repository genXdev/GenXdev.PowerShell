using System.Management.Automation;

namespace GenXdev.Helpers
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Returns a reversed dictionary for all languages supported by Google Search.
.DESCRIPTION
* Returns a dictionary mapping language names to their corresponding
  language codes for all languages supported by Google Search.
* Useful for language code lookups in web queries and translation tasks.

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
Get-WebLanguageDictionary
```

Retrieves the dictionary mapping language names to their codes.
")]
    [Cmdlet(VerbsCommon.Get, "WebLanguageDictionary")]
    [OutputType(typeof(Dictionary<string, string>))]
    public class GetWebLanguageDictionaryCommand : PSGenXdevCmdlet
    {
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
            // Create the dictionary to hold language mappings
            var result = new Dictionary<string, string>
            {
                // Add all language mappings to the dictionary
                { "Afrikaans", "af" },
                { "Akan", "ak" },
                { "Albanian", "sq" },
                { "Amharic", "am" },
                { "Arabic", "ar" },
                { "Armenian", "hy" },
                { "Azerbaijani", "az" },
                { "Basque", "eu" },
                { "Belarusian", "be" },
                { "Bemba", "bem" },
                { "Bengali", "bn" },
                { "Bihari", "bh" },
                { "Bork, bork, bork!", "xx-bork" },
                { "Bosnian", "bs" },
                { "Breton", "br" },
                { "Bulgarian", "bg" },
                { "Cambodian", "km" },
                { "Catalan", "ca" },
                { "Cherokee", "chr" },
                { "Chichewa", "ny" },
                { "Chinese (Simplified)", "zh-Hans-CN" },
                { "Chinese (Traditional)", "zh-TW" },
                { "Corsican", "co" },
                { "Croatian", "hr" },
                { "Czech", "cs" },
                { "Danish", "da" },
                { "Dutch", "nl" },
                { "Elmer Fudd", "xx-elmer" },
                { "English", "en" },
                { "Esperanto", "eo" },
                { "Estonian", "et" },
                { "Ewe", "ee" },
                { "Faroese", "fo" },
                { "Filipino", "tl" },
                { "Finnish", "fi" },
                { "French", "fr" },
                { "Frisian", "fy" },
                { "Ga", "gaa" },
                { "Galician", "gl" },
                { "Georgian", "ka" },
                { "German", "de" },
                { "Greek", "el" },
                { "Guarani", "gn" },
                { "Gujarati", "gu" },
                { "Hacker", "xx-hacker" },
                { "Haitian Creole", "ht" },
                { "Hausa", "ha" },
                { "Hawaiian", "haw" },
                { "Hebrew", "iw" },
                { "Hindi", "hi" },
                { "Hungarian", "hu" },
                { "Icelandic", "is" },
                { "Igbo", "ig" },
                { "Indonesian", "id" },
                { "Interlingua", "ia" },
                { "Irish", "ga" },
                { "Italian", "it" },
                { "Japanese", "ja" },
                { "Javanese", "jw" },
                { "Kannada", "kn" },
                { "Kazakh", "kk" },
                { "Kinyarwanda", "rw" },
                { "Kirundi", "rn" },
                { "Klingon", "xx-klingon" },
                { "Kongo", "kg" },
                { "Korean", "ko" },
                { "Krio (Sierra Leone)", "kri" },
                { "Kurdish", "ku" },
                { "Kurdish (Soranî)", "ckb" },
                { "Kyrgyz", "ky" },
                { "Laothian", "lo" },
                { "Latin", "la" },
                { "Latvian", "lv" },
                { "Lingala", "ln" },
                { "Lithuanian", "lt" },
                { "Lozi", "loz" },
                { "Luganda", "lg" },
                { "Luo", "ach" },
                { "Macedonian", "mk" },
                { "Malagasy", "mg" },
                { "Malay", "ms" },
                { "Malayalam", "ml" },
                { "Maltese", "mt" },
                { "Maori", "mi" },
                { "Marathi", "mr" },
                { "Mauritian Creole", "mfe" },
                { "Moldavian", "mo" },
                { "Mongolian", "mn" },
                { "Montenegrin", "sr-ME" },
                { "Nepali", "ne" },
                { "Nigerian Pidgin", "pcm" },
                { "Northern Sotho", "nso" },
                { "Norwegian", "no" },
                { "Norwegian (Nynorsk)", "nn" },
                { "Occitan", "oc" },
                { "Oriya", "or" },
                { "Oromo", "om" },
                { "Pashto", "ps" },
                { "Persian", "fa" },
                { "Pirate", "xx-pirate" },
                { "Polish", "pl" },
                { "Portuguese (Brazil)", "pt-BR" },
                { "Portuguese (Portugal)", "pt-PT" },
                { "Punjabi", "pa" },
                { "Quechua", "qu" },
                { "Romanian", "ro" },
                { "Romansh", "rm" },
                { "Runyakitara", "nyn" },
                { "Russian", "ru" },
                { "Scots Gaelic", "gd" },
                { "Serbian", "sr" },
                { "Serbo-Croatian", "sh" },
                { "Sesotho", "st" },
                { "Setswana", "tn" },
                { "Seychellois Creole", "crs" },
                { "Shona", "sn" },
                { "Sindhi", "sd" },
                { "Sinhalese", "si" },
                { "Slovak", "sk" },
                { "Slovenian", "sl" },
                { "Somali", "so" },
                { "Spanish", "es" },
                { "Spanish (Latin American)", "es-419" },
                { "Sundanese", "su" },
                { "Swahili", "sw" },
                { "Swedish", "sv" },
                { "Tajik", "tg" },
                { "Tamil", "ta" },
                { "Tatar", "tt" },
                { "Telugu", "te" },
                { "Thai", "th" },
                { "Tigrinya", "ti" },
                { "Tonga", "to" },
                { "Tshiluba", "lua" },
                { "Tumbuka", "tum" },
                { "Turkish", "tr" },
                { "Turkmen", "tk" },
                { "Twi", "tw" },
                { "Uighur", "ug" },
                { "Ukrainian", "uk" },
                { "Urdu", "ur" },
                { "Uzbek", "uz" },
                { "Vietnamese", "vi" },
                { "Welsh", "cy" },
                { "Wolof", "wo" },
                { "Xhosa", "xh" },
                { "Yiddish", "yi" },
                { "Yoruba", "yo" },
                { "Zulu", "zu" }
            };

            // Output the dictionary
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