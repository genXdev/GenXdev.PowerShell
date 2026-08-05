###############################################################################
<#
.SYNOPSIS
Converts text to speech using Microsoft Edge's neural TTS engine.

.DESCRIPTION
Uses Microsoft Edge's neural TTS engine (via EdgeTTS.DotNet) to convert text
to speech with natural-sounding voices. This function provides flexible
text-to-speech capabilities with support for different voices, locales,
prosody adjustments (rate, volume, pitch), and synchronous/asynchronous
playback options. It can handle both single strings and arrays of text.

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

.PARAMETER Lines
The text to be spoken. Accepts single string or array of strings. Each line
will be processed sequentially for speech synthesis.

.PARAMETER Locale
The language locale ID to use (e.g., 'en-US', 'es-ES'). When specified, the
function will attempt to use a voice matching this locale.

.PARAMETER VoiceName
The specific voice name to use for speech synthesis. If specified, the
function will attempt to find and use a matching voice from available
Edge TTS voices.

.PARAMETER Rate
The speech rate as a relative value (e.g. "+0%", "-20%", "+50%"). Positive
values speed up speech, negative values slow it down. Default is "+0%".

.PARAMETER Volume
The volume level as a relative value (e.g. "+0%", "-25%", "+100%").
Positive values increase volume, negative values decrease it.
Default is "+0%".

.PARAMETER Pitch
The pitch shift in Hz (e.g. "+0Hz", "-10Hz", "+20Hz"). Positive values
raise the pitch, negative values lower it. Default is "+0Hz".

.PARAMETER PassThru
When specified, outputs the text being spoken to the pipeline, allowing for
text processing while speaking.

.PARAMETER Wait
When specified, waits for speech to complete before continuing execution.
Useful for synchronous operations.

.PARAMETER Force
Interrupts any currently playing or queued speech, speaks the given text
immediately (blocking), and then resumes the interrupted speech queue.
This implies synchronous behavior regardless of the -Wait parameter.

.EXAMPLE
Start-TextToSpeech -Lines "Hello World" -Locale "en-US" -Wait

.EXAMPLE
"Hello World" | say

.EXAMPLE
say "Hello World" -Rate "+50%" -Pitch "-5Hz"

.EXAMPLE
say "Alert!" -Force
<# Interrupts any ongoing speech to immediately speak "Alert!",
   then continues with the interrupted speech afterwards. #>
#>
function Start-TextToSpeech {

    [CmdletBinding(SupportsShouldProcess = $true)]
    [Alias('say')]
    param(
        ########################################################################
        [Parameter(
            Mandatory = $true,
            Position = 0,
            ValueFromPipeline = $true,
            ValueFromRemainingArguments = $false,
            ParameterSetName = 'strings',
            HelpMessage = 'Text to be spoken'
        )]
        [AllowNull()]
        [AllowEmptyCollection()]
        [AllowEmptyString()]
        [string[]] $Lines,

        ########################################################################
        [ValidateSet(
            'af-ZA-AdriNeural',
            'af-ZA-WillemNeural',
            'am-ET-AmehaNeural',
            'am-ET-MekdesNeural',
            'ar-AE-FatimaNeural',
            'ar-AE-HamdanNeural',
            'ar-BH-AliNeural',
            'ar-BH-LailaNeural',
            'ar-DZ-AminaNeural',
            'ar-DZ-IsmaelNeural',
            'ar-EG-SalmaNeural',
            'ar-EG-ShakirNeural',
            'ar-IQ-BasselNeural',
            'ar-IQ-RanaNeural',
            'ar-JO-SanaNeural',
            'ar-JO-TaimNeural',
            'ar-KW-FahedNeural',
            'ar-KW-NouraNeural',
            'ar-LB-LaylaNeural',
            'ar-LB-RamiNeural',
            'ar-LY-ImanNeural',
            'ar-LY-OmarNeural',
            'ar-MA-JamalNeural',
            'ar-MA-MounaNeural',
            'ar-OM-AbdullahNeural',
            'ar-OM-AyshaNeural',
            'ar-QA-AmalNeural',
            'ar-QA-MoazNeural',
            'ar-SA-HamedNeural',
            'ar-SA-ZariyahNeural',
            'ar-SY-AmanyNeural',
            'ar-SY-LaithNeural',
            'ar-TN-HediNeural',
            'ar-TN-ReemNeural',
            'ar-YE-MaryamNeural',
            'ar-YE-SalehNeural',
            'az-AZ-BabekNeural',
            'az-AZ-BanuNeural',
            'bg-BG-BorislavNeural',
            'bg-BG-KalinaNeural',
            'bn-BD-NabanitaNeural',
            'bn-BD-PradeepNeural',
            'bn-IN-BashkarNeural',
            'bn-IN-TanishaaNeural',
            'bs-BA-GoranNeural',
            'bs-BA-VesnaNeural',
            'ca-ES-EnricNeural',
            'ca-ES-JoanaNeural',
            'cs-CZ-AntoninNeural',
            'cs-CZ-VlastaNeural',
            'cy-GB-AledNeural',
            'cy-GB-NiaNeural',
            'da-DK-ChristelNeural',
            'da-DK-JeppeNeural',
            'de-AT-IngridNeural',
            'de-AT-JonasNeural',
            'de-CH-JanNeural',
            'de-CH-LeniNeural',
            'de-DE-AmalaNeural',
            'de-DE-ConradNeural',
            'de-DE-FlorianMultilingualNeural',
            'de-DE-KatjaNeural',
            'de-DE-KillianNeural',
            'de-DE-SeraphinaMultilingualNeural',
            'el-GR-AthinaNeural',
            'el-GR-NestorasNeural',
            'en-AU-NatashaNeural',
            'en-AU-WilliamMultilingualNeural',
            'en-CA-ClaraNeural',
            'en-CA-LiamNeural',
            'en-GB-LibbyNeural',
            'en-GB-MaisieNeural',
            'en-GB-RyanNeural',
            'en-GB-SoniaNeural',
            'en-GB-ThomasNeural',
            'en-HK-SamNeural',
            'en-HK-YanNeural',
            'en-IE-ConnorNeural',
            'en-IE-EmilyNeural',
            'en-IN-NeerjaExpressiveNeural',
            'en-IN-NeerjaNeural',
            'en-IN-PrabhatNeural',
            'en-KE-AsiliaNeural',
            'en-KE-ChilembaNeural',
            'en-NG-AbeoNeural',
            'en-NG-EzinneNeural',
            'en-NZ-MitchellNeural',
            'en-NZ-MollyNeural',
            'en-PH-JamesNeural',
            'en-PH-RosaNeural',
            'en-SG-LunaNeural',
            'en-SG-WayneNeural',
            'en-TZ-ElimuNeural',
            'en-TZ-ImaniNeural',
            'en-US-AnaNeural',
            'en-US-AndrewMultilingualNeural',
            'en-US-AndrewNeural',
            'en-US-AriaNeural',
            'en-US-AvaMultilingualNeural',
            'en-US-AvaNeural',
            'en-US-BrianMultilingualNeural',
            'en-US-BrianNeural',
            'en-US-ChristopherNeural',
            'en-US-EmmaMultilingualNeural',
            'en-US-EmmaNeural',
            'en-US-EricNeural',
            'en-US-GuyNeural',
            'en-US-JennyNeural',
            'en-US-MichelleNeural',
            'en-US-RogerNeural',
            'en-US-SteffanNeural',
            'en-ZA-LeahNeural',
            'en-ZA-LukeNeural',
            'es-AR-ElenaNeural',
            'es-AR-TomasNeural',
            'es-BO-MarceloNeural',
            'es-BO-SofiaNeural',
            'es-CL-CatalinaNeural',
            'es-CL-LorenzoNeural',
            'es-CO-GonzaloNeural',
            'es-CO-SalomeNeural',
            'es-CR-JuanNeural',
            'es-CR-MariaNeural',
            'es-CU-BelkysNeural',
            'es-CU-ManuelNeural',
            'es-DO-EmilioNeural',
            'es-DO-RamonaNeural',
            'es-EC-AndreaNeural',
            'es-EC-LuisNeural',
            'es-ES-AlvaroNeural',
            'es-ES-ElviraNeural',
            'es-ES-XimenaNeural',
            'es-GQ-JavierNeural',
            'es-GQ-TeresaNeural',
            'es-GT-AndresNeural',
            'es-GT-MartaNeural',
            'es-HN-CarlosNeural',
            'es-HN-KarlaNeural',
            'es-MX-DaliaNeural',
            'es-MX-JorgeNeural',
            'es-NI-FedericoNeural',
            'es-NI-YolandaNeural',
            'es-PA-MargaritaNeural',
            'es-PA-RobertoNeural',
            'es-PE-AlexNeural',
            'es-PE-CamilaNeural',
            'es-PR-KarinaNeural',
            'es-PR-VictorNeural',
            'es-PY-MarioNeural',
            'es-PY-TaniaNeural',
            'es-SV-LorenaNeural',
            'es-SV-RodrigoNeural',
            'es-US-AlonsoNeural',
            'es-US-PalomaNeural',
            'es-UY-MateoNeural',
            'es-UY-ValentinaNeural',
            'es-VE-PaolaNeural',
            'es-VE-SebastianNeural',
            'et-EE-AnuNeural',
            'et-EE-KertNeural',
            'fa-IR-DilaraNeural',
            'fa-IR-FaridNeural',
            'fi-FI-HarriNeural',
            'fi-FI-NooraNeural',
            'fil-PH-AngeloNeural',
            'fil-PH-BlessicaNeural',
            'fr-BE-CharlineNeural',
            'fr-BE-GerardNeural',
            'fr-CA-AntoineNeural',
            'fr-CA-JeanNeural',
            'fr-CA-SylvieNeural',
            'fr-CA-ThierryNeural',
            'fr-CH-ArianeNeural',
            'fr-CH-FabriceNeural',
            'fr-FR-DeniseNeural',
            'fr-FR-EloiseNeural',
            'fr-FR-HenriNeural',
            'fr-FR-RemyMultilingualNeural',
            'fr-FR-VivienneMultilingualNeural',
            'ga-IE-ColmNeural',
            'ga-IE-OrlaNeural',
            'gl-ES-RoiNeural',
            'gl-ES-SabelaNeural',
            'gu-IN-DhwaniNeural',
            'gu-IN-NiranjanNeural',
            'he-IL-AvriNeural',
            'he-IL-HilaNeural',
            'hi-IN-MadhurNeural',
            'hi-IN-SwaraNeural',
            'hr-HR-GabrijelaNeural',
            'hr-HR-SreckoNeural',
            'hu-HU-NoemiNeural',
            'hu-HU-TamasNeural',
            'id-ID-ArdiNeural',
            'id-ID-GadisNeural',
            'is-IS-GudrunNeural',
            'is-IS-GunnarNeural',
            'it-IT-DiegoNeural',
            'it-IT-ElsaNeural',
            'it-IT-GiuseppeMultilingualNeural',
            'it-IT-IsabellaNeural',
            'iu-Cans-CA-SiqiniqNeural',
            'iu-Cans-CA-TaqqiqNeural',
            'iu-Latn-CA-SiqiniqNeural',
            'iu-Latn-CA-TaqqiqNeural',
            'ja-JP-KeitaNeural',
            'ja-JP-NanamiNeural',
            'jv-ID-DimasNeural',
            'jv-ID-SitiNeural',
            'ka-GE-EkaNeural',
            'ka-GE-GiorgiNeural',
            'kk-KZ-AigulNeural',
            'kk-KZ-DauletNeural',
            'km-KH-PisethNeural',
            'km-KH-SreymomNeural',
            'kn-IN-GaganNeural',
            'kn-IN-SapnaNeural',
            'ko-KR-HyunsuMultilingualNeural',
            'ko-KR-InJoonNeural',
            'ko-KR-SunHiNeural',
            'lo-LA-ChanthavongNeural',
            'lo-LA-KeomanyNeural',
            'lt-LT-LeonasNeural',
            'lt-LT-OnaNeural',
            'lv-LV-EveritaNeural',
            'lv-LV-NilsNeural',
            'mk-MK-AleksandarNeural',
            'mk-MK-MarijaNeural',
            'ml-IN-MidhunNeural',
            'ml-IN-SobhanaNeural',
            'mn-MN-BataaNeural',
            'mn-MN-YesuiNeural',
            'mr-IN-AarohiNeural',
            'mr-IN-ManoharNeural',
            'ms-MY-OsmanNeural',
            'ms-MY-YasminNeural',
            'mt-MT-GraceNeural',
            'mt-MT-JosephNeural',
            'my-MM-NilarNeural',
            'my-MM-ThihaNeural',
            'nb-NO-FinnNeural',
            'nb-NO-PernilleNeural',
            'ne-NP-HemkalaNeural',
            'ne-NP-SagarNeural',
            'nl-BE-ArnaudNeural',
            'nl-BE-DenaNeural',
            'nl-NL-ColetteNeural',
            'nl-NL-FennaNeural',
            'nl-NL-MaartenNeural',
            'pl-PL-MarekNeural',
            'pl-PL-ZofiaNeural',
            'ps-AF-GulNawazNeural',
            'ps-AF-LatifaNeural',
            'pt-BR-AntonioNeural',
            'pt-BR-FranciscaNeural',
            'pt-BR-ThalitaMultilingualNeural',
            'pt-PT-DuarteNeural',
            'pt-PT-RaquelNeural',
            'ro-RO-AlinaNeural',
            'ro-RO-EmilNeural',
            'ru-RU-DmitryNeural',
            'ru-RU-SvetlanaNeural',
            'si-LK-SameeraNeural',
            'si-LK-ThiliniNeural',
            'sk-SK-LukasNeural',
            'sk-SK-ViktoriaNeural',
            'sl-SI-PetraNeural',
            'sl-SI-RokNeural',
            'so-SO-MuuseNeural',
            'so-SO-UbaxNeural',
            'sq-AL-AnilaNeural',
            'sq-AL-IlirNeural',
            'sr-RS-NicholasNeural',
            'sr-RS-SophieNeural',
            'su-ID-JajangNeural',
            'su-ID-TutiNeural',
            'sv-SE-MattiasNeural',
            'sv-SE-SofieNeural',
            'sw-KE-RafikiNeural',
            'sw-KE-ZuriNeural',
            'sw-TZ-DaudiNeural',
            'sw-TZ-RehemaNeural',
            'ta-IN-PallaviNeural',
            'ta-IN-ValluvarNeural',
            'ta-LK-KumarNeural',
            'ta-LK-SaranyaNeural',
            'ta-MY-KaniNeural',
            'ta-MY-SuryaNeural',
            'ta-SG-AnbuNeural',
            'ta-SG-VenbaNeural',
            'te-IN-MohanNeural',
            'te-IN-ShrutiNeural',
            'th-TH-NiwatNeural',
            'th-TH-PremwadeeNeural',
            'tr-TR-AhmetNeural',
            'tr-TR-EmelNeural',
            'uk-UA-OstapNeural',
            'uk-UA-PolinaNeural',
            'ur-IN-GulNeural',
            'ur-IN-SalmanNeural',
            'ur-PK-AsadNeural',
            'ur-PK-UzmaNeural',
            'uz-UZ-MadinaNeural',
            'uz-UZ-SardorNeural',
            'vi-VN-HoaiMyNeural',
            'vi-VN-NamMinhNeural',
            'zh-Hans-CN-XiaoxiaoNeural',
            'zh-Hans-CN-XiaoyiNeural',
            'zh-Hans-CN-YunjianNeural',
            'zh-Hans-CN-YunxiNeural',
            'zh-Hans-CN-YunxiaNeural',
            'zh-Hans-CN-YunyangNeural',
            'zh-Hans-CN-liaoning-XiaobeiNeural',
            'zh-Hans-CN-shaanxi-XiaoniNeural',
            'zh-HK-HiuGaaiNeural',
            'zh-HK-HiuMaanNeural',
            'zh-HK-WanLungNeural',
            'zh-TW-HsiaoChenNeural',
            'zh-TW-HsiaoYuNeural',
            'zh-TW-YunJheNeural',
            'zu-ZA-ThandoNeural',
            'zu-ZA-ThembaNeural'
        )]
        [Parameter(
            Mandatory = $false,
            Position = 1,
            HelpMessage = 'Name of the voice to use for speech'
        )]
        [string] $VoiceName = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "The language locale id to use, e.g. 'en-US'"
        )]
        [string] $Locale = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Speech rate, e.g. "+0%", "-20%", "+50%"'
        )]
        [string] $Rate = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Volume level, e.g. "+0%", "-25%", "+100%"'
        )]
        [string] $Volume = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Pitch shift, e.g. "+0Hz", "-10Hz", "+20Hz"'
        )]
        [string] $Pitch = $null,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Output the text being spoken to the pipeline'
        )]
        [Alias('pt')]
        [switch]$PassThru,

        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Wait for speech to complete before continuing'
        )]
        [switch] $Wait,
        ########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Interrupt current speech, speak now (blocking),' +
            ' then resume interrupted speech'
        )]
        [switch] $Force,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to this installation type and set persistent flag..')
        )]
        [switch]$AutoConsent,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installations. Useful for unattended or CI/CD scenarios.')
        )]
        [switch]$AutoConsentAllPackages,
        ###############################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Use alternative settings stored in session for ' +
                'preferences')
        )]
        [switch]$SessionOnly
        ########################################################################
    )

    process {

        if (-not [IO.File]::Exists([IO.Path]::Combine((GenXdev\Get-KnownFolderPath System), 'mfplat.dll'))) {

            $ensureParams = GenXdev\Copy-IdenticalParamValues `
                -BoundParameters $PSBoundParameters `
                -FunctionName 'GenXdev\EnsureWindowsMediaFeaturePack'
            GenXdev\EnsureWindowsMediaFeaturePack @ensureParams
        }

        if (-not [IO.File]::Exists([IO.Path]::Combine((GenXdev\Get-KnownFolderPath System), 'mfplat.dll'))) {

            throw "Your system is missing the Windows Media Feature Pack which is required for Edge Text-To-Speech."
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Initializing text-to-speech with Locale: $Locale, " +
            "Voice: $VoiceName, Rate: $Rate, Volume: $Volume, " +
            "Pitch: $Pitch")

        # Configure prosody on the customized synthesizer
        if ($Rate) {
            [GenXdev.Helpers.Misc]::SpeechCustomized.SetRate($Rate)
        }
        if ($Volume) {
            [GenXdev.Helpers.Misc]::SpeechCustomized.SetVolume($Volume)
        }
        if ($Pitch) {
            [GenXdev.Helpers.Misc]::SpeechCustomized.SetPitch($Pitch)
        }
        @($Lines) | Microsoft.PowerShell.Core\Where-Object {
            # Filter out $null and whitespace-only lines
            $null -ne $PSItem -and '' -ne "$PSItem".Trim()
        } | Microsoft.PowerShell.Core\ForEach-Object {

            $text = $PSItem

            if ($text -isnot [string]) { $text = "$text" }

            try {
                if ($PassThru) { $text }

                $text = $text.Replace("`r", ' ').Replace("`n", ' ').
                Replace("`t", ' ')
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Processing text: $text")

                # Resolve voice: locale + voice name matching
                if (-not [string]::IsNullOrWhiteSpace($VoiceName) -or
                    -not [string]::IsNullOrWhiteSpace($Locale)) {

                    $voices = [GenXdev.Helpers.Misc]::SpeechCustomized.
                    GetInstalledVoices()

                    if (-not [string]::IsNullOrWhiteSpace($Locale)) {
                        $voices = $voices |
                            Microsoft.PowerShell.Core\Where-Object {
                                $PSItem.Locale -like "$Locale*"
                            }
                        }

                        if (-not [string]::IsNullOrWhiteSpace($VoiceName)) {
                            $voices = $voices |
                                Microsoft.PowerShell.Core\Where-Object {
                                    $PSItem.Name -like "*$VoiceName*"
                                }
                            }

                            $voice = $voices |
                                Microsoft.PowerShell.Utility\Select-Object -First 1

                                if ($voice) {
                                    [GenXdev.Helpers.Misc]::SpeechCustomized.
                                    SelectVoice($voice)
                                    Microsoft.PowerShell.Utility\Write-Verbose (
                                        "Selected voice: $($voice.Name)")
                                }
                                else {
                                    Microsoft.PowerShell.Utility\Write-Warning (
                                        "No matching voice found for Locale=$Locale" +
                                        " VoiceName=$VoiceName")
                                }
                            }

                            # Speak via the customized synthesizer
                            if ($PSCmdlet.ShouldProcess($text, 'Speak')) {
                                if ($Force) {
                                    $null = [GenXdev.Helpers.Misc]::SpeechCustomized.
                                    InterruptAndSpeak($text)
                                }
                                elseif ($Wait) {
                                    $null = [GenXdev.Helpers.Misc]::SpeechCustomized.
                                    Speak($text)
                                }
                                else {
                                    $null = [GenXdev.Helpers.Misc]::SpeechCustomized.
                                    SpeakAsyncQueued($text)
                                }
                            }
                        }
                        catch {
                            Microsoft.PowerShell.Utility\Write-Error (
                                "Speech synthesis failed: $($PSItem.Exception.Message)")
                        }
        }
    }

    end {
    }
}