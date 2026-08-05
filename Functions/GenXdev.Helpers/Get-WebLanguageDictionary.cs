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
            var result = new Dictionary<string, string>();

            // Add all language mappings to the dictionary
            result.Add("Afrikaans", "af");
            result.Add("Akan", "ak");
            result.Add("Albanian", "sq");
            result.Add("Amharic", "am");
            result.Add("Arabic", "ar");
            result.Add("Armenian", "hy");
            result.Add("Azerbaijani", "az");
            result.Add("Basque", "eu");
            result.Add("Belarusian", "be");
            result.Add("Bemba", "bem");
            result.Add("Bengali", "bn");
            result.Add("Bihari", "bh");
            result.Add("Bork, bork, bork!", "xx-bork");
            result.Add("Bosnian", "bs");
            result.Add("Breton", "br");
            result.Add("Bulgarian", "bg");
            result.Add("Cambodian", "km");
            result.Add("Catalan", "ca");
            result.Add("Cherokee", "chr");
            result.Add("Chichewa", "ny");
            result.Add("Chinese (Simplified)", "zh-Hans-CN");
            result.Add("Chinese (Traditional)", "zh-TW");
            result.Add("Corsican", "co");
            result.Add("Croatian", "hr");
            result.Add("Czech", "cs");
            result.Add("Danish", "da");
            result.Add("Dutch", "nl");
            result.Add("Elmer Fudd", "xx-elmer");
            result.Add("English", "en");
            result.Add("Esperanto", "eo");
            result.Add("Estonian", "et");
            result.Add("Ewe", "ee");
            result.Add("Faroese", "fo");
            result.Add("Filipino", "tl");
            result.Add("Finnish", "fi");
            result.Add("French", "fr");
            result.Add("Frisian", "fy");
            result.Add("Ga", "gaa");
            result.Add("Galician", "gl");
            result.Add("Georgian", "ka");
            result.Add("German", "de");
            result.Add("Greek", "el");
            result.Add("Guarani", "gn");
            result.Add("Gujarati", "gu");
            result.Add("Hacker", "xx-hacker");
            result.Add("Haitian Creole", "ht");
            result.Add("Hausa", "ha");
            result.Add("Hawaiian", "haw");
            result.Add("Hebrew", "iw");
            result.Add("Hindi", "hi");
            result.Add("Hungarian", "hu");
            result.Add("Icelandic", "is");
            result.Add("Igbo", "ig");
            result.Add("Indonesian", "id");
            result.Add("Interlingua", "ia");
            result.Add("Irish", "ga");
            result.Add("Italian", "it");
            result.Add("Japanese", "ja");
            result.Add("Javanese", "jw");
            result.Add("Kannada", "kn");
            result.Add("Kazakh", "kk");
            result.Add("Kinyarwanda", "rw");
            result.Add("Kirundi", "rn");
            result.Add("Klingon", "xx-klingon");
            result.Add("Kongo", "kg");
            result.Add("Korean", "ko");
            result.Add("Krio (Sierra Leone)", "kri");
            result.Add("Kurdish", "ku");
            result.Add("Kurdish (Soranî)", "ckb");
            result.Add("Kyrgyz", "ky");
            result.Add("Laothian", "lo");
            result.Add("Latin", "la");
            result.Add("Latvian", "lv");
            result.Add("Lingala", "ln");
            result.Add("Lithuanian", "lt");
            result.Add("Lozi", "loz");
            result.Add("Luganda", "lg");
            result.Add("Luo", "ach");
            result.Add("Macedonian", "mk");
            result.Add("Malagasy", "mg");
            result.Add("Malay", "ms");
            result.Add("Malayalam", "ml");
            result.Add("Maltese", "mt");
            result.Add("Maori", "mi");
            result.Add("Marathi", "mr");
            result.Add("Mauritian Creole", "mfe");
            result.Add("Moldavian", "mo");
            result.Add("Mongolian", "mn");
            result.Add("Montenegrin", "sr-ME");
            result.Add("Nepali", "ne");
            result.Add("Nigerian Pidgin", "pcm");
            result.Add("Northern Sotho", "nso");
            result.Add("Norwegian", "no");
            result.Add("Norwegian (Nynorsk)", "nn");
            result.Add("Occitan", "oc");
            result.Add("Oriya", "or");
            result.Add("Oromo", "om");
            result.Add("Pashto", "ps");
            result.Add("Persian", "fa");
            result.Add("Pirate", "xx-pirate");
            result.Add("Polish", "pl");
            result.Add("Portuguese (Brazil)", "pt-BR");
            result.Add("Portuguese (Portugal)", "pt-PT");
            result.Add("Punjabi", "pa");
            result.Add("Quechua", "qu");
            result.Add("Romanian", "ro");
            result.Add("Romansh", "rm");
            result.Add("Runyakitara", "nyn");
            result.Add("Russian", "ru");
            result.Add("Scots Gaelic", "gd");
            result.Add("Serbian", "sr");
            result.Add("Serbo-Croatian", "sh");
            result.Add("Sesotho", "st");
            result.Add("Setswana", "tn");
            result.Add("Seychellois Creole", "crs");
            result.Add("Shona", "sn");
            result.Add("Sindhi", "sd");
            result.Add("Sinhalese", "si");
            result.Add("Slovak", "sk");
            result.Add("Slovenian", "sl");
            result.Add("Somali", "so");
            result.Add("Spanish", "es");
            result.Add("Spanish (Latin American)", "es-419");
            result.Add("Sundanese", "su");
            result.Add("Swahili", "sw");
            result.Add("Swedish", "sv");
            result.Add("Tajik", "tg");
            result.Add("Tamil", "ta");
            result.Add("Tatar", "tt");
            result.Add("Telugu", "te");
            result.Add("Thai", "th");
            result.Add("Tigrinya", "ti");
            result.Add("Tonga", "to");
            result.Add("Tshiluba", "lua");
            result.Add("Tumbuka", "tum");
            result.Add("Turkish", "tr");
            result.Add("Turkmen", "tk");
            result.Add("Twi", "tw");
            result.Add("Uighur", "ug");
            result.Add("Ukrainian", "uk");
            result.Add("Urdu", "ur");
            result.Add("Uzbek", "uz");
            result.Add("Vietnamese", "vi");
            result.Add("Welsh", "cy");
            result.Add("Wolof", "wo");
            result.Add("Xhosa", "xh");
            result.Add("Yiddish", "yi");
            result.Add("Yoruba", "yo");
            result.Add("Zulu", "zu");

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