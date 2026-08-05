###############################################################################
<#
.SYNOPSIS
Generates MAML XML help files for any PowerShell module.

.DESCRIPTION
Generates MAML XML help files for any PowerShell module by extracting
metadata from all cmdlets in a module using Get-CmdletMetaData and
producing both ModuleName.dll-Help.xml (for C# cmdlets) and
ModuleName-help.xml (for .ps1 script cmdlets) in the output directory
under <ModuleRoot>\<Language>\.

Each help file includes all 9 MAML sections: command details,
description, syntax, parameters, input types, return values, alerts,
examples, and related links. Works with any module that has
discoverable cmdlets — GenXdev modules, community modules, or your
own custom modules.

Cmdlet sources are resolved using the same two-path strategy as
Get-CmdletMetaData:

- Script cmdlets (.ps1): source files under
  Functions\<(Sub)ModuleName>\FileName.ps1, dot-sourced by .psm1 files
  via . "$PSScriptRoot\Functions\<(Sub)ModuleName>\<FileName>".
- Compiled cmdlets (.cs / .dll): identified by their
  [Cmdlet("Verb", "Noun")] attribute and assigned to sub-modules via
  ImplementationType.Namespace (e.g., GenXdev.FileSystem). C# files
  are named Verb-Noun.cs or Verb-Noun.Cmdlet.cs (the .Cmdlet suffix
  is for partial classes sharing a source file with helper types).
  Help text lives in a [System.ComponentModel.Description(@"...")]
  attribute using the same .KEYWORD syntax as comment-based help
  (.SYNOPSIS, .DESCRIPTION, .PARAMETER, .EXAMPLE, .NOTES,
  .LINK). The  .EXAMPLE keyword uses fenced ```powershell blocks
  (description below the fence) vs. unfenced code in .ps1 help.

To see how a C# cmdlet receives its metadata through attributes only,
visit:
  https://github.com/genXdev/GenXdev.PowerShell/blob/main/Functions/GenXdev.FileSystem/Find-Item.Cmdlet.cs

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

.PARAMETER ModuleName
The name of the PowerShell module to generate help for (e.g.,
'Microsoft.WinGet.Client', 'PSReadLine', 'GenXdev.AI').

.PARAMETER Language
The language code for the generated help files. Defaults to 'en' for English.
Uses the language dictionary from Get-WebLanguageDictionary for validation.
Supports 140+ languages.

.PARAMETER Force
Overwrite existing help XML files without prompting.

.PARAMETER SkipTranslation
Skip LLM-based translation even when Language is not 'en'. Help content
remains in the source language (English).

.PARAMETER Model
The model identifier or pattern to use for AI translations.

.PARAMETER ApiEndpoint
The API endpoint URL for AI translations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER PromptForSettings
When specified, launches an interactive prompt to configure the LLM settings

.PARAMETER LinkPrefix
URL prefix for the \"Online Version:\" link in each cmdlet's related links.
When specified, each cmdlet's -Online URL will be
${LinkPrefix}<CmdletName>.md (e.g.,
`https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/` becomes
`https://.../Docs/en-US/Find-Item.md`). When omitted, a placeholder URL
is used for the Online Version link.

.PARAMETER WhatIf
Shows what would happen if the cmdlet runs without actually making changes.

.PARAMETER Confirm
Prompts for confirmation before making changes.

.EXAMPLE
New-ModuleXmlHelp -ModuleName 'Microsoft.WinGet.Client'

Generates English help XML for the WinGet client module in en-US\.

.EXAMPLE
New-ModuleXmlHelp -ModuleName 'GenXdev' -Language 'nl-NL' -Force  -Model 'deepseek-v4-pro' -ApiKey 'your-api-key' -ApiEndpoint 'https://api.deepseek.com/chat/completions'

Generates Dutch help XML for GenXdev, overwriting existing files.

.EXAMPLE
New-ModuleXmlHelp -ModuleName 'PSReadLine' -WhatIf

Shows what files would be created without actually writing them.

.EXAMPLE
New-ModuleXmlHelp -ModuleName 'GenXdev' -LinkPrefix `
    'https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/' -Force

Generates English help XML with per-cmdlet Online Version URLs pointing
to GitHub Markdown docs. Get-Help <cmdlet> -Online opens the browser.
#>
function New-ModuleXmlHelp {
    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.IO.FileInfo[]])]
    param (
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The name of the PowerShell module to generate help for'
        )]
        [ValidateScript({
                $m = Microsoft.PowerShell.Core\Get-Module -Name $_ `
                    -ErrorAction SilentlyContinue
                if (-not $m) {
                    $m = Microsoft.PowerShell.Core\Get-Module -Name $_ `
                        -ListAvailable -ErrorAction SilentlyContinue
                }
                if (-not $m) {
                    throw "Module '$_' not found. " +
                    'Provide a valid module name.'
                }
                $true
            })]
        [string] $ModuleName,
        #######################################################################
        [ValidateSet(
            'ar-SA',
            'bg-BG',
            'bn-IN',
            'ca-ES',
            'cs-CZ',
            'da-DK',
            'de-DE',
            'el-GR',
            'en-US',
            'es-ES',
            'et-EE',
            'fi-FI',
            'fr-FR',
            'gu-IN',
            'he-IL',
            'hi-IN',
            'hr-HR',
            'hu-HU',
            'id-ID',
            'it-IT',
            'ja-JP',
            'kn-IN',
            'ko-KR',
            'lt-LT',
            'lv-LV',
            'ml-IN',
            'mr-IN',
            'ms-MY',
            'nb-NO',
            'nl-NL',
            'pa-IN',
            'pl-PL',
            'pt-BR',
            'ro-RO',
            'ru-RU',
            'sk-SK',
            'sl-SI',
            'sr-RS',
            'sv-SE',
            'ta-IN',
            'te-IN',
            'th-TH',
            'tr-TR',
            'uk-UA',
            'vi-VN',
            'zh-Hans-CN'
        )]
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'BCP 47 language tag for the generated help ' +
            '(e.g., en-US, nl-NL, de-DE)'
        )]
        [string] $Language = 'en-US',
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Overwrite existing help XML files without prompting'
        )]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip LLM translation; keep help in source language'
        )]
        [switch] $SkipTranslation,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('The model identifier or pattern to use for AI translations')
        )]
        [string] $Model,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API endpoint URL for AI translations'
        )]
        [string] $ApiEndpoint,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'The API key for authenticated AI translations'
        )]
        [string] $ApiKey,
        ###################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Launch interactive prompt to configure LLM settings')
        )]
        [switch] $PromptForSettings,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Indicates that LLM has no support for JSON schemas'
        )]
        [switch] $NoSupportForJsonSchema,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('URL prefix for the Online Version link in each ' +
                'cmdlet related links (e.g., ' +
                'https://github.com/genXdev/GenXdev.PowerShell/blob/main/Docs/en-US/)')
        )]
        [string] $LinkPrefix,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Custom instructions for the LLM translation ' +
            '(passed to Get-TextTranslation)'
        )]
        [string] $TranslationInstructions

    )

    begin {
        ###############################################################################
        #region MAML XML Generation
        function GenerateMamlXml {
            param(
                [array]$CmdletMetaList,
                [string]$LinkPrefix = '',
                [hashtable]$SubModuleLinkMap = $null
            )

            $ns = @{
                maml    = 'http://schemas.microsoft.com/maml/2004/10'
                command = 'http://schemas.microsoft.com/maml/dev/command/2004/10'
                dev     = 'http://schemas.microsoft.com/maml/dev/2004/10'
                MSHelp  = 'http://msdn.microsoft.com/mshelp'
            }

            # Build a lookup: cmdlet name -> sub-module name
            $cmdletToSubModule = @{}
            if ($SubModuleLinkMap) {
                foreach ($subModule in $SubModuleLinkMap.Keys) {
                    foreach ($cmdletName in $SubModuleLinkMap[$subModule]) {
                        $cmdletToSubModule[$cmdletName] = $subModule
                    }
                }
            }

            # Use XmlWriter for precise formatting
            $settings = [System.Xml.XmlWriterSettings]::new()
            $settings.Indent = $true
            $settings.IndentChars = '  '
            $settings.Encoding = [System.Text.Encoding]::UTF8
            $settings.OmitXmlDeclaration = $false
            $settings.ConformanceLevel = [System.Xml.ConformanceLevel]::Document

            $stream = [System.IO.MemoryStream]::new()
            $writer = [System.Xml.XmlWriter]::Create($stream, $settings)

            $writer.WriteStartDocument()
            $writer.WriteStartElement('helpItems', 'http://msh')
            $writer.WriteAttributeString('schema', 'maml')
            $writer.WriteAttributeString('xmlns', 'http://msh')

            $i = 0;
            foreach ($meta in $CmdletMetaList) {
                Microsoft.PowerShell.Utility\Write-Progress -Id 426 -Activity "Generating XML Help" -Status "Processing $($meta.CmdletName)" -PercentComplete ([math]::Round((($i + 1) / $CmdletMetaList.Count) * 100, 2))
                $i++;

                $subModule = $cmdletToSubModule[$meta.CmdletName]
                $siblingCmdlets = if ($subModule -and $SubModuleLinkMap.ContainsKey($subModule)) {
                    @($SubModuleLinkMap[$subModule] |
                            Microsoft.PowerShell.Core\Where-Object { $_ -ne $meta.CmdletName } |
                            Microsoft.PowerShell.Utility\Sort-Object)
                }
                else { @() }

                WriteCmdletCommandElement -Writer $writer -Meta $meta -Ns $ns `
                    -SiblingCmdlets $siblingCmdlets -LinkPrefix $LinkPrefix
            }

            $writer.WriteEndElement() # helpItems
            $writer.WriteEndDocument()
            $writer.Flush()

            # Reset stream and load as XDocument
            $stream.Position = 0
            $reader = [System.IO.StreamReader]::new($stream)
            $xml = $reader.ReadToEnd()
            $reader.Dispose()
            $writer.Dispose()
            $stream.Dispose()

            return [xml]$xml
        }

        function WriteCmdletCommandElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                $Meta,
                [hashtable]$Ns,
                [string[]]$SiblingCmdlets = @(),
                [string]$LinkPrefix = ''
            )

            # Derive verb and noun from cmdlet name
            $dashPos = $Meta.CmdletName.IndexOf('-')
            $verb = if ($dashPos -gt 0) { $Meta.CmdletName.Substring(0, $dashPos) } else { $Meta.CmdletName }
            $noun = if ($dashPos -gt 0) { $Meta.CmdletName.Substring($dashPos + 1) } else { $Meta.CmdletName }

            $Writer.WriteStartElement('command', 'command', $Ns['command'])
            $Writer.WriteAttributeString('xmlns', 'maml', $null, $Ns['maml'])
            $Writer.WriteAttributeString('xmlns', 'command', $null, $Ns['command'])
            $Writer.WriteAttributeString('xmlns', 'dev', $null, $Ns['dev'])
            $Writer.WriteAttributeString('xmlns', 'MSHelp', $null, $Ns['MSHelp'])

            WriteDetailsElement -Writer $Writer -CmdletName $Meta.CmdletName -Verb $verb -Noun $noun `
                -Synopsis $Meta.Synopsis -Ns $Ns

            WriteFullDescriptionElement -Writer $Writer -Description $Meta.Description -Ns $Ns

            WriteSyntaxElement -Writer $Writer -CmdletName $Meta.CmdletName -Parameters $Meta.Parameters -Ns $Ns

            WriteParametersElement -Writer $Writer -Parameters $Meta.Parameters -Ns $Ns

            WriteInputTypesElement -Writer $Writer -Parameters $Meta.Parameters -Ns $Ns

            WriteReturnValuesElement -Writer $Writer -OutputType $Meta.OutputType -Ns $Ns

            WriteExamplesElement -Writer $Writer -Examples $Meta.Examples -Ns $Ns

            WriteRelatedLinksElement -Writer $writer -CmdletName $Meta.CmdletName `
                -Ns $ns -SiblingCmdlets $SiblingCmdlets -LinkPrefix $LinkPrefix

            $Writer.WriteEndElement() # command:command
        }
        ###############################################################################
        #region Section Writers

        function WriteDetailsElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                [string]$CmdletName, [string]$Verb, [string]$Noun,
                [string]$Synopsis, [hashtable]$Ns
            )
            $Writer.WriteStartElement('command', 'details', $Ns['command'])
            $Writer.WriteElementString('command', 'name', $Ns['command'], $CmdletName)
            $Writer.WriteElementString('command', 'verb', $Ns['command'], $Verb)
            $Writer.WriteElementString('command', 'noun', $Ns['command'], $Noun)
            $Writer.WriteStartElement('maml', 'description', $Ns['maml'])
            $Writer.WriteElementString('maml', 'para', $Ns['maml'], (Get-SynopsisText $Synopsis))
            $Writer.WriteEndElement() # maml:description
            $Writer.WriteEndElement() # command:details
        }

        function WriteFullDescriptionElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                [string]$Description, [hashtable]$Ns
            )

            $Writer.WriteStartElement('maml', 'description', $Ns['maml'])

            $text = if ([string]::IsNullOrWhiteSpace($Description)) {
                '{{ Fill in the Description }}'
            }
            else { $Description }

            # Split description into paragraphs on double-newlines or sentences
            $paras = $text -split '\r?\n\s*\r?\n' | Microsoft.PowerShell.Core\Where-Object { -not [string]::IsNullOrWhiteSpace($_) }
            if ($paras.Count -eq 0) {
                $Writer.WriteElementString('maml', 'para', $Ns['maml'], $text)
            }
            else {
                foreach ($p in $paras) {
                    $Writer.WriteElementString('maml', 'para', $Ns['maml'], $p.Trim())
                }
            }

            $Writer.WriteEndElement() # maml:description
        }

        function WriteSyntaxElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                [string]$CmdletName,
                [array]$Parameters,
                [hashtable]$Ns
            )

            $Writer.WriteStartElement('command', 'syntax', $Ns['command'])
            $Writer.WriteStartElement('command', 'syntaxItem', $Ns['command'])
            $Writer.WriteElementString('maml', 'name', $Ns['maml'], $CmdletName)

            if ($Parameters -and $Parameters.Count -gt 0) {
                # Group by ParameterSetName; if all are same set, just list all
                $sortedParams = $Parameters |
                    Microsoft.PowerShell.Utility\Sort-Object { if ($_.Position -match '^\d+$') { [int]$_.Position } else { 2147483647 } },
                    @{ Expression = 'Name'; Descending = $false }

                foreach ($p in $sortedParams) {
                    WriteSyntaxParameterElement -Writer $Writer -Param $p -Ns $Ns
                }
            }

            $Writer.WriteEndElement() # command:syntaxItem
            $Writer.WriteEndElement() # command:syntax
        }

        function WriteSyntaxParameterElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                $Param, [hashtable]$Ns
            )

            $aliasesText = if ($Param.Aliases -and $Param.Aliases.Count -gt 0) {
                ($Param.Aliases -join ', ')
            }
            else { 'none' }

            $pipelineText = if ($Param.ValueFromPipeline) {
                if ($Param.ValueFromPipelineByPropertyName) { 'True (ByValue, ByPropertyName)' }
                else { 'True (ByValue)' }
            }
            elseif ($Param.ValueFromPipelineByPropertyName) {
                'True (ByPropertyName)'
            }
            else { 'False' }

            $pos = if ($Param.Position -match '^\d+$') { $Param.Position } else { 'named' }
            $required = if ($Param.Mandatory) { 'true' } else { 'false' }
            $varLen = if ($Param.ValueFromRemainingArguments) { 'true' } else { 'true' }
            $globbing = if ($Param.SupportsWildcards) { 'true' } else { 'false' }

            $Writer.WriteStartElement('command', 'parameter', $Ns['command'])
            $Writer.WriteAttributeString('required', $required)
            $Writer.WriteAttributeString('variableLength', $varLen)
            $Writer.WriteAttributeString('globbing', $globbing)
            $Writer.WriteAttributeString('pipelineInput', $pipelineText)
            $Writer.WriteAttributeString('position', $pos)
            $Writer.WriteAttributeString('aliases', $aliasesText)

            $Writer.WriteElementString('maml', 'name', $Ns['maml'], $Param.Name)
            $Writer.WriteStartElement('maml', 'description', $Ns['maml'])
            $Writer.WriteElementString('maml', 'para', $Ns['maml'],
                (Get-ParamDescription $Param))
            $Writer.WriteEndElement() # maml:description

            # parameterValue (only for non-switch with ValueFromRemainingArguments or
            # for mandatory non-switch params)
            if ($Param.ParameterType -ne 'System.Management.Automation.SwitchParameter') {
                $paramValueType = Get-ParameterValueTypeName $Param.ParameterType
                $Writer.WriteStartElement('command', 'parameterValue', $Ns['command'])
                $Writer.WriteAttributeString('required', 'true')
                $Writer.WriteAttributeString('variableLength', 'false')
                $Writer.WriteString($paramValueType)
                $Writer.WriteEndElement() # command:parameterValue
            }

            # dev:type
            $Writer.WriteStartElement('dev', 'type', $Ns['dev'])
            $Writer.WriteElementString('maml', 'name', $Ns['maml'],
                (Get-MamlTypeName $Param.ParameterType))
            $Writer.WriteElementString('maml', 'uri', $Ns['maml'], '')
            $Writer.WriteEndElement() # dev:type

            # dev:defaultValue
            $defVal = if ($null -ne $Param.DefaultValue -and $Param.DefaultValue -ne '') {
                $Param.DefaultValue
            }
            elseif ($Param.ParameterType -eq 'System.Management.Automation.SwitchParameter') {
                'False'
            }
            else { 'None' }
            $Writer.WriteElementString('dev', 'defaultValue', $Ns['dev'], $defVal)

            $Writer.WriteEndElement() # command:parameter
        }

        function WriteParametersElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                [array]$Parameters,
                [hashtable]$Ns
            )

            $Writer.WriteStartElement('command', 'parameters', $Ns['command'])

            if ($Parameters -and $Parameters.Count -gt 0) {
                $sortedParams = $Parameters |
                    Microsoft.PowerShell.Utility\Sort-Object { if ($_.Position -match '^\d+$') { [int]$_.Position } else { 2147483647 } },
                    @{ Expression = 'Name'; Descending = $false }

                foreach ($p in $sortedParams) {
                    WriteParameterDetailElement -Writer $Writer -Param $p -Ns $Ns
                }
            }

            $Writer.WriteEndElement() # command:parameters
        }

        function WriteParameterDetailElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                $Param, [hashtable]$Ns
            )

            $aliasesText = if ($Param.Aliases -and $Param.Aliases.Count -gt 0) {
                ($Param.Aliases -join ', ')
            }
            else { 'none' }

            $pipelineText = if ($Param.ValueFromPipeline) {
                if ($Param.ValueFromPipelineByPropertyName) { 'True (ByValue, ByPropertyName)' }
                else { 'True (ByValue)' }
            }
            elseif ($Param.ValueFromPipelineByPropertyName) {
                'True (ByPropertyName)'
            }
            else { 'False' }

            $pos = if ($Param.Position -match '^\d+$') { $Param.Position } else { 'named' }
            $required = if ($Param.Mandatory) { 'true' } else { 'false' }
            $varLen = if ($Param.ValueFromRemainingArguments) { 'true' } else { 'true' }
            $globbing = if ($Param.SupportsWildcards) { 'true' } else { 'false' }

            $Writer.WriteStartElement('command', 'parameter', $Ns['command'])
            $Writer.WriteAttributeString('required', $required)
            $Writer.WriteAttributeString('variableLength', $varLen)
            $Writer.WriteAttributeString('globbing', $globbing)
            $Writer.WriteAttributeString('pipelineInput', $pipelineText)
            $Writer.WriteAttributeString('position', $pos)
            $Writer.WriteAttributeString('aliases', $aliasesText)

            $Writer.WriteElementString('maml', 'name', $Ns['maml'], $Param.Name)
            $Writer.WriteStartElement('maml', 'description', $Ns['maml'])
            $Writer.WriteElementString('maml', 'para', $Ns['maml'],
                (Get-ParamDescription $Param))
            $Writer.WriteEndElement() # maml:description

            # parameterValue
            if ($Param.ParameterType -ne 'System.Management.Automation.SwitchParameter') {
                $paramValueType = Get-ParameterValueTypeName $Param.ParameterType
                $Writer.WriteStartElement('command', 'parameterValue', $Ns['command'])
                $Writer.WriteAttributeString('required', 'true')
                $Writer.WriteAttributeString('variableLength', 'false')
                $Writer.WriteString($paramValueType)
                $Writer.WriteEndElement() # command:parameterValue
            }
            else {
                $Writer.WriteStartElement('command', 'parameterValue', $Ns['command'])
                $Writer.WriteAttributeString('required', 'false')
                $Writer.WriteAttributeString('variableLength', 'false')
                $Writer.WriteString('SwitchParameter')
                $Writer.WriteEndElement() # command:parameterValue
            }

            # dev:type
            $Writer.WriteStartElement('dev', 'type', $Ns['dev'])
            $Writer.WriteElementString('maml', 'name', $Ns['maml'],
                (Get-MamlTypeName $Param.ParameterType))
            $Writer.WriteElementString('maml', 'uri', $Ns['maml'], '')
            $Writer.WriteEndElement() # dev:type

            # dev:defaultValue
            $defVal = if ($null -ne $Param.DefaultValue -and $Param.DefaultValue -ne '') {
                $Param.DefaultValue
            }
            elseif ($Param.ParameterType -eq 'System.Management.Automation.SwitchParameter') {
                'False'
            }
            else { 'None' }
            $Writer.WriteElementString('dev', 'defaultValue', $Ns['dev'], $defVal)

            $Writer.WriteEndElement() # command:parameter
        }

        function WriteInputTypesElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                [array]$Parameters,
                [hashtable]$Ns
            )

            $Writer.WriteStartElement('command', 'inputTypes', $Ns['command'])

            # Collect types that accept pipeline input
            $pipelineParams = @($Parameters | Microsoft.PowerShell.Core\Where-Object {
                    $_.ValueFromPipeline -or $_.ValueFromPipelineByPropertyName
                })

            if ($pipelineParams.Count -eq 0) {
                # No pipeline input
                $Writer.WriteStartElement('command', 'inputType', $Ns['command'])
                $Writer.WriteStartElement('dev', 'type', $Ns['dev'])
                $Writer.WriteElementString('maml', 'name', $Ns['maml'], 'None')
                $Writer.WriteEndElement() # dev:type
                $Writer.WriteStartElement('maml', 'description', $Ns['maml'])
                $Writer.WriteElementString('maml', 'para', $Ns['maml'],
                    "You can't pipe input to this cmdlet.")
                $Writer.WriteEndElement() # maml:description
                $Writer.WriteEndElement() # command:inputType
            }
            else {
                foreach ($pp in ($pipelineParams | Microsoft.PowerShell.Utility\Sort-Object ParameterType -Unique)) {
                    $Writer.WriteStartElement('command', 'inputType', $Ns['command'])
                    $Writer.WriteStartElement('dev', 'type', $Ns['dev'])
                    $Writer.WriteElementString('maml', 'name', $Ns['maml'], $pp.ParameterType)
                    $Writer.WriteEndElement() # dev:type
                    $Writer.WriteStartElement('maml', 'description', $Ns['maml'])
                    $Writer.WriteElementString('maml', 'para', $Ns['maml'],
                        "Accepts $($pp.ParameterType) objects via pipeline.")
                    $Writer.WriteEndElement() # maml:description
                    $Writer.WriteEndElement() # command:inputType
                }
            }

            $Writer.WriteEndElement() # command:inputTypes
        }

        function WriteReturnValuesElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                [array]$OutputType,
                [hashtable]$Ns
            )

            $Writer.WriteStartElement('command', 'returnValues', $Ns['command'])

            if ($OutputType -and $OutputType.Count -gt 0) {
                foreach ($ot in $OutputType) {
                    $Writer.WriteStartElement('command', 'returnValue', $Ns['command'])
                    $Writer.WriteStartElement('dev', 'type', $Ns['dev'])
                    $Writer.WriteElementString('maml', 'name', $Ns['maml'], $ot)
                    $Writer.WriteEndElement() # dev:type
                    $Writer.WriteStartElement('maml', 'description', $Ns['maml'])
                    $Writer.WriteElementString('maml', 'para', $Ns['maml'],
                        "Returns $ot objects.")
                    $Writer.WriteEndElement() # maml:description
                    $Writer.WriteEndElement() # command:returnValue
                }
            }
            else {
                $Writer.WriteStartElement('command', 'returnValue', $Ns['command'])
                $Writer.WriteStartElement('dev', 'type', $Ns['dev'])
                $Writer.WriteElementString('maml', 'name', $Ns['maml'], 'None')
                $Writer.WriteEndElement() # dev:type
                $Writer.WriteStartElement('maml', 'description', $Ns['maml'])
                $Writer.WriteElementString('maml', 'para', $Ns['maml'], '')
                $Writer.WriteEndElement() # maml:description
                $Writer.WriteEndElement() # command:returnValue
            }

            $Writer.WriteEndElement() # command:returnValues
        }

        function WriteExamplesElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                [array]$Examples,
                [hashtable]$Ns
            )

            $Writer.WriteStartElement('command', 'examples', $Ns['command'])

            if ($Examples -and $Examples.Count -gt 0) {
                $exNum = 1
                foreach ($ex in $Examples) {
                    $exampleText = "$ex"

                    # Parse fenced code block: ```powershell...``` is code,
                    # first non-blank line after ``` is title, rest is remarks.
                    $code = ''
                    $title = "---------- Example ${exNum} ----------"
                    $remarks = ''

                    if ($exampleText -match '(?s)```powershell\s*\r?\n(.*?)```') {
                        $code = $matches[1].TrimEnd()
                        $afterFence = $exampleText.Substring(
                            $exampleText.IndexOf($matches[0]) + $matches[0].Length).Trim()

                        if ($afterFence) {
                            $afterLines = $afterFence -split '\r?\n' |
                                Microsoft.PowerShell.Core\ForEach-Object { $_.TrimEnd() }
                            # First non-blank line is title
                            $titleIndex = -1
                            for ($i = 0; $i -lt $afterLines.Count; $i++) {
                                if ($afterLines[$i] -ne '') {
                                    $titleIndex = $i
                                    $title = $afterLines[$i]
                                    break
                                }
                            }
                            # Remaining lines are remarks
                            if ($titleIndex -ge 0 -and $titleIndex -lt $afterLines.Count - 1) {
                                $remarks = ($afterLines[($titleIndex + 1)..($afterLines.Count - 1)] |
                                        Microsoft.PowerShell.Core\Where-Object { $_ -ne '' }) -join ' '
                            }
                        }
                    }
                    else {
                        # No fenced code block — use the entire text as code
                        $code = $exampleText
                    }

                    $Writer.WriteStartElement('command', 'example', $Ns['command'])
                    $Writer.WriteElementString('maml', 'title', $Ns['maml'], $title)
                    $Writer.WriteElementString('dev', 'code', $Ns['dev'], $code)
                    $Writer.WriteStartElement('dev', 'remarks', $Ns['dev'])
                    $Writer.WriteElementString('maml', 'para', $Ns['maml'], $remarks)
                    $Writer.WriteEndElement() # dev:remarks
                    $Writer.WriteEndElement() # command:example

                    $exNum++
                }
            }
            else {
                # Placeholder example
                $Writer.WriteStartElement('command', 'example', $Ns['command'])
                $Writer.WriteElementString('maml', 'title', $Ns['maml'],
                    '-------------------------- Example 1 --------------------------')
                $Writer.WriteElementString('dev', 'code', $Ns['dev'],
                    'PS C:\> {{ Add example code here }}')
                $Writer.WriteStartElement('dev', 'remarks', $Ns['dev'])
                $Writer.WriteElementString('maml', 'para', $Ns['maml'],
                    '{{ Add example description here }}')
                $Writer.WriteEndElement() # dev:remarks
                $Writer.WriteEndElement() # command:example
            }

            $Writer.WriteEndElement() # command:examples
        }

        function WriteRelatedLinksElement {
            param(
                [System.Xml.XmlWriter]$Writer,
                [string]$CmdletName,
                [hashtable]$Ns,
                [string[]]$SiblingCmdlets = @(),
                [string]$LinkPrefix = ''
            )

            $Writer.WriteStartElement('command', 'relatedLinks', $Ns['command'])

            # 1. "Online Version:" link for Get-Help -Online
            $Writer.WriteStartElement('maml', 'navigationLink', $Ns['maml'])
            $Writer.WriteElementString('maml', 'linkText', $Ns['maml'], 'Online Version:')
            $onlineUri = if ($LinkPrefix) {
                "${LinkPrefix}${CmdletName}.md"
            }
            else {
                "https://docs.github.com/en/rest/search"
            }
            $Writer.WriteElementString('maml', 'uri', $Ns['maml'], $onlineUri)
            $Writer.WriteEndElement() # maml:navigationLink

            # 2. Sibling cmdlet cross-references (empty URIs, PowerShell convention)
            foreach ($sibling in $SiblingCmdlets) {
                $Writer.WriteStartElement('maml', 'navigationLink', $Ns['maml'])
                $Writer.WriteElementString('maml', 'linkText', $Ns['maml'], $sibling)
                $Writer.WriteElementString('maml', 'uri', $Ns['maml'], '')
                $Writer.WriteEndElement() # maml:navigationLink
            }

            $Writer.WriteEndElement() # command:relatedLinks
        }
        #endregion Section Writers
        ###############################################################################
        #region Helper Functions

        function Get-SynopsisText {
            param([string]$Synopsis)

            if ([string]::IsNullOrWhiteSpace($Synopsis)) {
                return ''
            }
            return $Synopsis
        }

        function Get-ParamDescription {
            param($Param)

            if (-not [string]::IsNullOrWhiteSpace($Param.HelpMessage)) {
                return $Param.HelpMessage
            }
            return "The $($Param.Name) parameter."
        }

        function Get-MamlTypeName {
            param([string]$ParameterType)

            switch -Regex ($ParameterType) {
                'System\.String\[\]' { return 'String[]' }
                'System\.String' { return 'String' }
                'System\.Int32' { return 'Int32' }
                'System\.Int64' { return 'Int64' }
                'System\.Boolean' { return 'Boolean' }
                'System\.Double' { return 'Double' }
                'System\.DateTime' { return 'DateTime' }
                'System\.Object' { return 'Object' }
                'System\.Object\[\]' { return 'Object[]' }
                'Hashtable' { return 'Hashtable' }
                'Hashtable\[\]' { return 'Hashtable[]' }
                'SwitchParameter|System\.Management\.Automation\.SwitchParameter' { return 'SwitchParameter' }
                'System\.Collections\.IEnumerable' { return 'IEnumerable' }
                'System\.Char\[\]' { return 'Char[]' }
                'GenXdev\.Helpers\.' { return ($ParameterType -replace 'GenXdev\.Helpers\.', '') }
                default { return ($ParameterType -replace 'System\.', '') }
            }
        }

        function Get-ParameterValueTypeName {
            param([string]$ParameterType)

            switch -Regex ($ParameterType) {
                'System\.String\[\]' { return 'String[]' }
                'System\.String' { return 'String' }
                'System\.Int32' { return 'Int32' }
                'System\.Int64' { return 'Int64' }
                'System\.Boolean' { return 'Boolean' }
                'System\.Double' { return 'Double' }
                'System\.DateTime' { return 'DateTime' }
                'System\.Object' { return 'Object' }
                'System\.Object\[\]' { return 'Object[]' }
                'Hashtable' { return 'Hashtable' }
                'Hashtable\[\]' { return 'Hashtable[]' }
                'SwitchParameter|System\.Management\.Automation\.SwitchParameter' { return 'SwitchParameter' }
                'System\.Collections\.IEnumerable' { return 'IEnumerable' }
                'System\.Char\[\]' { return 'Char[]' }
                'GenXdev\.Helpers\.' { return ($ParameterType -replace 'GenXdev\.Helpers\.', '') }
                default { return ($ParameterType -replace 'System\.', '') }
            }
        }
        #endregion Helper Functions

        # -- Resolve module --------------------------------------------------
        # Prefer the actually-loaded module (has ExportedCommands).
        # Otherwise fall back to the available module with the highest
        # version number.
        $module = @(Microsoft.PowerShell.Core\Get-Module -Name $ModuleName `
                -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Core\Where-Object {
                    $_.ExportedCommands.Count -gt 0 -and
                    $_.ModuleType -ne 'Binary'
                })[0]

        if (-not $module) {
            $module = @(Microsoft.PowerShell.Core\Get-Module `
                    -Name $ModuleName -ListAvailable `
                    -ErrorAction SilentlyContinue |
                    Microsoft.PowerShell.Utility\Sort-Object Version -Descending)[0]
        }

        if (-not $module) {
            Microsoft.PowerShell.Utility\Write-Error `
                "Module '${ModuleName}' not found."
            return
        }

        $moduleRoot = $module.ModuleBase
        $helpDir = Microsoft.PowerShell.Management\Join-Path $moduleRoot $Language

        Microsoft.PowerShell.Utility\Write-Verbose "Module root: ${moduleRoot}"

        # -- Track generated files for pipeline output -----------------------
        $generatedFiles = [System.Collections.Generic.List[string]]::new()

        # -- Cache module-level metadata params ------------------------------
        $metaModuleParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev\Get-ModuleCmdletMetaData" ;
    }

    process {
        # -- Collect metadata for all cmdlets --------------------------------
        if (-not $PSCmdlet.ShouldProcess(
                $ModuleName,
                'Retrieve cmdlet metadata for all cmdlets')) {
            return
        }

        try {
            $cmdletMeta = @(GenXdev\Get-ModuleCmdletMetaData `
                    @metaModuleParams -ErrorAction Stop)
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to get metadata for module '${ModuleName}': $_")
            return
        }

        if ($cmdletMeta.Count -eq 0) {
            Microsoft.PowerShell.Utility\Write-Warning "No cmdlet metadata retrieved for '${ModuleName}'."
            return
        }

        Microsoft.PowerShell.Utility\Write-Verbose "Retrieved metadata for $($cmdletMeta.Count) cmdlet(s)."

        # -- Build sub-module link map for related links --------------------
        $subModuleLinkMap = @{}
        foreach ($meta in $cmdletMeta) {
            $subModule = if ($meta.SubModuleName) { $meta.SubModuleName } else { 'General' }
            if (-not $subModuleLinkMap.ContainsKey($subModule)) {
                $subModuleLinkMap[$subModule] = @()
            }
            $subModuleLinkMap[$subModule] += $meta.CmdletName
        }
        Microsoft.PowerShell.Utility\Write-Verbose (
            "Built link map with $($subModuleLinkMap.Count) sub-module(s).")

        # Separate into C# and script cmdlets based on CmdletType
        $csCmdlets = @($cmdletMeta | Microsoft.PowerShell.Core\Where-Object { $_.CmdletType -eq 'Cmdlet' })
        $scriptCmdlets = @($cmdletMeta | Microsoft.PowerShell.Core\Where-Object { $_.CmdletType -ne 'Cmdlet' })

        Microsoft.PowerShell.Utility\Write-Verbose "C# cmdlets: $($csCmdlets.Count), Script cmdlets: $($scriptCmdlets.Count)"

        # Generate dll-Help.xml for C# cmdlets
        if ($csCmdlets.Count -gt 0) {
            $dllHelpPath = Microsoft.PowerShell.Management\Join-Path $helpDir "${ModuleName}.dll-Help.xml"
            if ($PSCmdlet.ShouldProcess($dllHelpPath, 'Generate C# help XML')) {
                if ((Microsoft.PowerShell.Management\Test-Path $dllHelpPath -PathType Leaf) -and -not $Force) {
                    Microsoft.PowerShell.Utility\Write-Warning "File '${dllHelpPath}' exists. Use -Force to overwrite."
                }
                else {
                    $xml = GenerateMamlXml -CmdletMetaList $csCmdlets `
                        -LinkPrefix $LinkPrefix -SubModuleLinkMap $subModuleLinkMap
                    $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path $helpDir -Force -ErrorAction SilentlyContinue
                    $xml.Save($dllHelpPath)
                    $null = $generatedFiles.Add($dllHelpPath)
                    Microsoft.PowerShell.Utility\Write-Verbose "Generated: ${dllHelpPath}"
                }
            }
        }

        # Generate help.xml for .ps1 script cmdlets
        if ($scriptCmdlets.Count -gt 0) {
            $scriptHelpPath = Microsoft.PowerShell.Management\Join-Path $helpDir "${ModuleName}-help.xml"
            if ($PSCmdlet.ShouldProcess($scriptHelpPath, 'Generate script help XML')) {
                if ((Microsoft.PowerShell.Management\Test-Path $scriptHelpPath -PathType Leaf) -and -not $Force) {
                    Microsoft.PowerShell.Utility\Write-Warning "File '${scriptHelpPath}' exists. Use -Force to overwrite."
                }
                else {
                    $xml = GenerateMamlXml -CmdletMetaList $scriptCmdlets `
                        -LinkPrefix $LinkPrefix -SubModuleLinkMap $subModuleLinkMap
                    $null = Microsoft.PowerShell.Management\New-Item -ItemType Directory -Path $helpDir -Force -ErrorAction SilentlyContinue
                    $xml.Save($scriptHelpPath)
                    $null = $generatedFiles.Add($scriptHelpPath)
                    Microsoft.PowerShell.Utility\Write-Verbose "Generated: ${scriptHelpPath}"
                }
            }
        }

        if ($generatedFiles.Count -gt 0) { Microsoft.PowerShell.Management\Get-ChildItem $generatedFiles }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Progress -Id 426 -Completed
    }
}