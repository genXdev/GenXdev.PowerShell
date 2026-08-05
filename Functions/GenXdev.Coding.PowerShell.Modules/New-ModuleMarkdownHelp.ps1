###############################################################################
<#
.SYNOPSIS
Generates rich Markdown help files for any PowerShell module.

.DESCRIPTION
Generates a comprehensive Markdown help site for any PowerShell module:
one .md file per cmdlet with all metadata sections, plus a README.md
index with per-sub-module tables linking to each cmdlet file.

Sub-module discovery uses two independent paths:

- Script cmdlets (.ps1): source file path is matched against .psm1
  dot-source directory mappings. The convention is:
  . "$PSScriptRoot\Functions\<(Sub)ModuleName>\<FileName>.ps1"
  where the sub-folder name becomes the (sub-)module name (e.g.,
  Functions\GenXdev.FileSystem -> GenXdev.FileSystem). For modules
  without nested .psm1 files, the Functions\*\ directory structure
  is scanned directly.
- Compiled cmdlets (.cs / .dll): the namespace from
  ImplementationType.Namespace (e.g., GenXdev.FileSystem) identifies
  the sub-module. C# files are named Verb-Noun.cs or
  Verb-Noun.Cmdlet.cs (the .Cmdlet suffix marks a partial class).
  Help text lives in a [System.ComponentModel.Description(@"...")]
  attribute using the same .KEYWORD syntax as PowerShell
  comment-based help (.SYNOPSIS, .DESCRIPTION, .PARAMETER,
   .EXAMPLE, .NOTES, .LINK). The .EXAMPLE keyword uses fenced
  triple-backquoted powershell blocks in C# vs. unfenced code in .ps1 help.

To see how a C# cmdlet receives its metadata through attributes only,
visit:
  https://github.com/genXdev/GenXdev.PowerShell/blob/main/Functions/GenXdev.FileSystem/Find-Item.Cmdlet.cs

Output is written to <ModuleRoot>\Docs\<Language>\. Each cmdlet .md
includes Synopsis, Description, Syntax, a compact Parameters table,
Examples, and per-parameter detail sections with property tables. A
README.md index groups cmdlets by sub-module.

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
'Microsoft.WinGet.Client', 'PSReadLine', 'GenXdev').

.PARAMETER OutputPath
Custom output directory for generated .md files. Defaults to
<moduleRoot>\Docs\. The directory is created if it doesn't exist.

.PARAMETER Language
BCP 47 language tag for translation. Defaults to 'en-US' which skips
translation.

.PARAMETER Force
Overwrite existing .md files without prompting.

.PARAMETER SkipTranslation
Skip LLM-based translation; keep help text in the source language.

.PARAMETER Model
The model identifier or pattern to use for AI translations.

.PARAMETER ApiEndpoint
The API endpoint URL for AI translations.

.PARAMETER ApiKey
The API key for authenticated AI operations.

.PARAMETER PromptForSettings
When specified, launches an interactive prompt to configure the LLM settings

.PARAMETER LinkPrefix
URL prefix for README index links. When specified, cmdlet links use
absolute URLs (e.g., https://github.com/<githubuser>/<reponame>/blob/main/Docs/en-US/CmdletName.md).
When omitted, links use relative paths (./CmdletName.md).

.PARAMETER TranslationInstructions
Custom instructions for the AI translation model.

.PARAMETER NoLicense
Will exclude license info from cmdlet help markdown

.EXAMPLE
New-ModuleMarkdownHelp -ModuleName 'Microsoft.WinGet.Client' -SkipTranslation

Generates Docs\ folder with one .md per WinGet cmdlet + README.md index.

.EXAMPLE
New-ModuleMarkdownHelp -ModuleName 'GenXdev' -Language 'nl-NL' -Force -Model 'deepseek-v4-pro' -ApiKey 'your-api-key' -ApiEndpoint 'https://api.deepseek.com/chat/completions'

Generates Dutch-translated markdown help, overwriting existing files.

.EXAMPLE
New-ModuleMarkdownHelp -ModuleName 'GenXdev' -LinkPrefix `
    'https://github.com/genXdev/GenXdev.PowerShell/Docs/' -SkipTranslation

Generates help with absolute GitHub links in the README index.
#>
function New-ModuleMarkdownHelp {

    [CmdletBinding(SupportsShouldProcess, ConfirmImpact = 'Medium')]
    [OutputType([System.String[]])]
    param (
        #######################################################################
        [Parameter(
            Position = 0,
            Mandatory = $true,
            HelpMessage = 'The name of the PowerShell module to generate ' +
            'help for'
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
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Custom output directory for .md files. ' +
            'Defaults to <moduleRoot>\Docs\<language>.'
        )]
        [ValidateNotNullOrEmpty()]
        [string] $OutputPath,
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
            HelpMessage = 'Overwrite existing .md files without prompting'
        )]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Skip LLM translation; keep help in source ' +
            'language'
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
            HelpMessage = 'URL prefix for README index links (e.g., ' +
            'https://github.com/<githubuser>/<reponame>/blob/main/Docs/en-US/)'
        )]
        [string] $LinkPrefix,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Custom AI translation instructions'
        )]
        [string] $TranslationInstructions,
        ###########################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = 'Will exclude license info from cmdlet help markdown'
        )]
        [switch] $NoLicense
    )

    begin {

        function BuildSyntaxLine {
            param(
                [string] $CmdletName,
                [object[]] $Parameters,
                [string] $SetName
            )

            # Filter to parameters that belong to this set.
            $setParams = $Parameters | Microsoft.PowerShell.Core\Where-Object {
                if ($_.ParameterSetNames) {
                    $_.ParameterSetNames -contains $SetName
                }
                elseif ($_.ParameterSetName) {
                    $_.ParameterSetName -eq $SetName
                }
                else { $SetName -eq 'All' }
            }

            if (-not $setParams -or $setParams.Count -eq 0) {
                return "${CmdletName} [<CommonParameters>]"
            }

            # Sort: positional first (by numeric Position), then alpha.
            $sortedParams = $setParams |
                Microsoft.PowerShell.Utility\Sort-Object -Property @{
                    Expression = {
                        $pos = $_.Position
                        if ($pos -and $pos -ne 'Named') {
                            try { return [int]$pos } catch { }
                        }
                        return [int]::MaxValue
                    }
                }, 'Name'

            $line = $CmdletName
            foreach ($p in $sortedParams) {
                if ($p.DontShow) { continue }

                $shortType = if ($p.ParameterType) {
                    ($p.ParameterType `
                        -replace '^System\.', '' `
                        -replace 'Management\.Automation\.', '' `
                        -replace 'Collections\.Generic\.', '' `
                        -replace '``1', '')
                }
                else { 'Object' }

                $isPositional = ($p.Position -and $p.Position -ne 'Named')
                $isMandatory = $p.Mandatory
                $isSwitch = ($shortType -eq 'SwitchParameter')

                if ($isSwitch) {
                    $line += if ($isMandatory) {
                        " -$($p.Name)"
                    }
                    else { " [-$($p.Name)]" }
                }
                elseif ($isMandatory) {
                    $line += " -$($p.Name) <$shortType>"
                }
                elseif ($isPositional) {
                    $line += " [[-$($p.Name)] <$shortType>]"
                }
                else {
                    $line += " [-$($p.Name) <$shortType>]"
                }
            }
            $line += ' [<CommonParameters>]'

            return $line
        }

        function RenderCmdletMarkdown {
            param(
                [hashtable] $Meta,
                [string] $ModuleName,
                [string] $SubModuleName,
                [object[]] $SiblingCmdlets = @(),
                [string] $LinkPrefix = ''
            )

            $cmdletName = if ($Meta['CmdletName']) {
                $Meta['CmdletName']
            }
            else {
                ($Meta['Definition'] -split '\s+')[0]
            }

            $cmdletType = if ($Meta['CmdletType']) {
                $Meta['CmdletType']
            }
            else { 'Function' }

            $aliases = if ($Meta['Aliases'] -and $Meta['Aliases'].Count -gt 0) {
                ($Meta['Aliases'] | Microsoft.PowerShell.Core\ForEach-Object { "``${_}``" }) -join ', '
            }
            else { '—' }

            [System.Text.StringBuilder] $sb = [System.Text.StringBuilder]::new()

            # Helper: word-wrap text to a maximum line length, joining
            # lines with <br> (GitHub table cells).
            $maxDescWidth = 45
            function WrapDescription {
                param([string]$Text, [int]$MaxWidth = $maxDescWidth)
                if ($Text.Length -le $MaxWidth) { return $Text }
                $words = $Text -split ' '
                $lines = [System.Collections.Generic.List[string]]::new()
                $current = ''
                foreach ($w in $words) {
                    if ($current.Length + $w.Length + 1 -le $MaxWidth) {
                        if ($current) { $current += ' ' + $w } else { $current = $w }
                    }
                    else {
                        if ($current.Length -gt 0) { $lines.Add($current) }
                        $current = $w
                    }
                }
                if ($current.Length -gt 0) { $lines.Add($current) }
                return $lines -join '<br>'
            }

            # -- Header --------------------------------------------------------------
            $null = $sb.AppendLine("# ${cmdletName}")
            $null = $sb.AppendLine()
            $null = $sb.AppendLine(
                "> **$($SubModuleName -eq $ModuleName ? '' : "$($markdownLabels['Sub'])")$($markdownLabels['Module:'])** ${SubModuleName} | **$($markdownLabels['Type:'])** ${cmdletType} | " +
                "**$($markdownLabels['Aliases:'])** ${aliases}")
            $null = $sb.AppendLine()

            # -- Synopsis ------------------------------------------------------------
            $synopsis = if (-not [string]::IsNullOrWhiteSpace($Meta['Synopsis'])) {
                $Meta['Synopsis']
            }
            else { $markdownLabels['*(No synopsis provided)*'] }

            $null = $sb.AppendLine("## $($markdownLabels['Synopsis'])")
            $null = $sb.AppendLine()
            $null = $sb.AppendLine("> ${synopsis}")
            $null = $sb.AppendLine()

            # -- Description ---------------------------------------------------------
            if (-not [string]::IsNullOrWhiteSpace($Meta['Description'])) {
                $null = $sb.AppendLine("## $($markdownLabels['Description'])")
                $null = $sb.AppendLine()

                $desc = $Meta['Description'].Trim()

                # Detect structured/indented content (bulleted lists, nested
                # indentation) that would lose formatting in plain markdown.
                # When detected, wrap in a fenced code block to preserve
                # line breaks and indentation exactly as authored.
                $isStructured = $desc -match '(?m)^\s{2,}(\*|-)'

                if ($isStructured) {
                    $null = $sb.AppendLine('```text')
                    $null = $sb.AppendLine($desc)
                    $null = $sb.AppendLine('```')
                }
                else {
                    # Use <details> for long descriptions (> 3 paragraphs).
                    $paragraphs = $desc -split '\r?\n\s*\r?\n'
                    if ($paragraphs.Count -gt 3) {
                        $null = $sb.AppendLine('<details>')
                        $null = $sb.AppendLine(
                            "<summary><b>$($markdownLabels['Expand description'])</b></summary>")
                        $null = $sb.AppendLine()
                        foreach ($p in $paragraphs) {
                            $null = $sb.AppendLine($p.Trim())
                            $null = $sb.AppendLine()
                        }
                        $null = $sb.AppendLine('</details>')
                    }
                    else {
                        foreach ($p in $paragraphs) {
                            $null = $sb.AppendLine($p.Trim())
                            $null = $sb.AppendLine()
                        }
                    }
                }
            }

            # -- License -------------------------------------------------------------
            if ((-not $NoLicense) -and (-not [string]::IsNullOrWhiteSpace($Meta['License']))) {
                $null = $sb.AppendLine()
                $null = $sb.AppendLine("## $($markdownLabels['License'])")
                $null = $sb.AppendLine()

                $licenseText = $Meta['License'].Trim()

                # For long GPLv3 license texts, use collapsible details
                $licenseLines = $licenseText -split '\r?\n' |
                    Microsoft.PowerShell.Core\Where-Object { $_ -match '\S' }

                if ($licenseLines.Count -gt 6) {
                    $null = $sb.AppendLine('<details>')
                    $null = $sb.AppendLine(
                        "<summary><b>$($markdownLabels['Show license'])</b></summary>")
                    $null = $sb.AppendLine()
                    $null = $sb.AppendLine('```text')
                    $null = $sb.AppendLine($licenseText)
                    $null = $sb.AppendLine('```')
                    $null = $sb.AppendLine()
                    $null = $sb.AppendLine('</details>')
                }
                else {
                    $null = $sb.AppendLine($licenseText)
                }

                $null = $sb.AppendLine()
            }

            # -- Syntax --------------------------------------------------------------
            $null = $sb.AppendLine()
            $null = $sb.AppendLine("## $($markdownLabels['Syntax'])")
            $null = $sb.AppendLine()

            $parameters = $Meta['Parameters']

            # Build syntax from parameter metadata for all cmdlet types.
            if ($parameters -and $parameters.Count -gt 0) {

                # Collect all unique parameter set names across all parameters.
                $allSetNames = [System.Collections.Generic.List[string]]::new()
                foreach ($p in $parameters) {
                    $sets = if ($p.ParameterSetNames) {
                        $p.ParameterSetNames
                    }
                    elseif ($p.ParameterSetName) {
                        @($p.ParameterSetName)
                    }
                    else { @('All') }

                    foreach ($sn in $sets) {
                        if ($sn -notin $allSetNames) {
                            $null = $allSetNames.Add($sn)
                        }
                    }
                }

                $null = $sb.AppendLine('```powershell')

                if ($allSetNames.Count -le 1) {
                    # Single set — render inline.
                    $singleSetName = if ($allSetNames.Count -eq 1) {
                        $allSetNames[0]
                    }
                    else { 'All' }
                    $null = $sb.AppendLine(
                        (BuildSyntaxLine $cmdletName $parameters $singleSetName))
                }
                else {
                    # Multiple sets — one line per set, first line is default.
                    $isFirst = $true
                    foreach ($setName in $allSetNames) {
                        if (-not $isFirst) {
                            $null = $sb.AppendLine()
                        }
                        $isFirst = $false

                        $null = $sb.AppendLine(
                            (BuildSyntaxLine $cmdletName $parameters $setName))
                    }
                }
                $null = $sb.AppendLine('```')
            }
            else {
                # No parameters — minimal syntax line.
                $null = $sb.AppendLine('```powershell')
                $null = $sb.AppendLine("${cmdletName} [<CommonParameters>]")
                $null = $sb.AppendLine('```')
            }
            $null = $sb.AppendLine()

            # -- Parameters ----------------------------------------------------------
            $parameters = $Meta['Parameters']
            if ($parameters -and $parameters.Count -gt 0) {
                $null = $sb.AppendLine("## $($markdownLabels['Parameters'])")
                $null = $sb.AppendLine()

                # Column headers (no Pipeline, Position, Default — too wide).
                $null = $sb.AppendLine(
                    "| $($markdownLabels['Name']) | $($markdownLabels['Type']) | $($markdownLabels['Required']) | $($markdownLabels['Description']) |")
                $null = $sb.AppendLine(
                    '|:---|:---|:---:|:---|')

                foreach ($p in $parameters) {
                    $pName = "``-$($p.Name)``"

                    # Type — shorten common types.
                    $pType = $p.ParameterType
                    if ($pType) {
                        $pType = $pType `
                            -replace '^System\.', '' `
                            -replace 'Management\.Automation\.', '' `
                            -replace 'Collections\.Generic\.', '' `
                            -replace '``1', ''
                    }
                    else { $pType = '—' }

                    # Required.
                    $pRequired = if ($p.Mandatory) { '✅' } else { '☐' }

                    # Description.
                    $pDesc = if (-not [string]::IsNullOrWhiteSpace(
                            $p.HelpMessage)) {
                        $p.HelpMessage
                    }
                    else { "The ${pName} $($markdownLabels['parameter'])." }

                    # Normalize to a single line.
                    $pDesc = $pDesc -replace '\r?\n', ' '
                    $pDesc = $pDesc -replace '\s{2,}', ' '
                    # Remove PowerShell string concatenation artifacts.
                    $pDesc = $pDesc -replace '["'']\s*\+\s*["'']', ' '
                    # Remove leading '(' + quote, trailing quote + ')'.
                    $pDesc = $pDesc -replace '^\s*\(\s*["'']', '' -replace '["'']\s*\)\s*$', ''
                    $pDesc = $pDesc.Trim()

                    # Append wildcards note.
                    if ($p.SupportsWildcards) {
                        $pDesc += $markdownLabels[' 🌐 wildcards']
                    }

                    # Append hidden note.
                    if ($p.DontShow) {
                        $pDesc += $markdownLabels[' (hidden)']
                    }

                    # Word-wrap for GitHub table readability.
                    $pDesc = WrapDescription $pDesc

                    $null = $sb.AppendLine(
                        "| ${pName} | ${pType} | ${pRequired} | ${pDesc} |")
                }
                $null = $sb.AppendLine()
            }

            # -- Examples ------------------------------------------------------------
            $examples = $Meta['Examples']
            if ($examples -and $examples.Count -gt 0) {
                $null = $sb.AppendLine("## $($markdownLabels['Examples'])")
                $null = $sb.AppendLine()

                $exampleNum = 1
                foreach ($ex in $examples) {
                    $exText = $ex.ToString().Trim()
                    if ([string]::IsNullOrWhiteSpace($exText)) { continue }

                    # Try to extract a title from the first non-code line.
                    $title = ''
                    $hasFence = $exText -match '```'

                    if ($hasFence) {
                        # Everything before first ``` is the title/description.
                        $fencePos = $exText.IndexOf('```')
                        if ($fencePos -gt 0) {
                            $title = $exText.Substring(0, $fencePos).Trim()
                        }
                    }
                    else {
                        # First non-blank line until first blank line.
                        $lines = $exText -split '\r?\n'
                        $titleLines = @()
                        foreach ($line in $lines) {
                            if ([string]::IsNullOrWhiteSpace($line)) { break }
                            $titleLines += $line
                        }
                        $title = ($titleLines -join ' ').Trim()
                    }

                    if ([string]::IsNullOrWhiteSpace($title)) {
                        $title = "$($markdownLabels['Examples']) ${exampleNum}"
                    }

                    $null = $sb.AppendLine("### ${title}")
                    $null = $sb.AppendLine()

                    # Render the example text with code fences.
                    if ($hasFence) {
                        # Left-trim trailing text after the closing fence to
                        # prevent accidental indented code blocks in markdown
                        # (e.g., indented .LINK entries from C# metadata).
                        $lastFencePos = $exText.LastIndexOf('```')
                        if ($lastFencePos -ge 0) {
                            $fencedPart = $exText.Substring(0, $lastFencePos + 3)
                            $trailing = $exText.Substring($lastFencePos + 3)
                            $trimmedTrailing = ($trailing -split '\r?\n' |
                                    Microsoft.PowerShell.Core\ForEach-Object { $_.TrimStart() }) -join "`r`n"
                            $null = $sb.AppendLine(
                                ($fencedPart + $trimmedTrailing).TrimEnd())
                        }
                        else {
                            $null = $sb.AppendLine($exText)
                        }
                    }
                    else {
                        $blankMatch = [regex]::Match(
                            $exText, '\r?\n\s*\r?\n')
                        if ($blankMatch.Success) {
                            $codePart = $exText.Substring(
                                0, $blankMatch.Index).TrimEnd()
                            $descPart = $exText.Substring(
                                $blankMatch.Index + $blankMatch.Length).Trim()

                            $null = $sb.AppendLine('```powershell')
                            $null = $sb.AppendLine($codePart)
                            $null = $sb.AppendLine('```')
                            $null = $sb.AppendLine()
                            if ($descPart) {
                                # Left-trim each line to prevent accidental
                                # indented code blocks in markdown.
                                $trimmedDesc = ($descPart -split '\r?\n' |
                                        Microsoft.PowerShell.Core\ForEach-Object { $_.TrimStart() }) -join "`r`n"
                                $null = $sb.AppendLine($trimmedDesc)
                            }
                        }
                        else {
                            $null = $sb.AppendLine('```powershell')
                            $null = $sb.AppendLine($exText)
                            $null = $sb.AppendLine('```')
                        }
                    }
                    $null = $sb.AppendLine()
                    $exampleNum++
                }
            }

            # -- Parameter Details ---------------------------------------------------
            $parameters = $Meta['Parameters']
            if ($parameters -and $parameters.Count -gt 0) {
                $null = $sb.AppendLine("## $($markdownLabels['Parameter Details'])")
                $null = $sb.AppendLine()

                foreach ($p in $parameters) {
                    if ($p.DontShow) { continue }

                    # Normalize aliases: C# cmdlets may have string instead of
                    # array.
                    $pAliases = if ($p.Aliases) {
                        if ($p.Aliases -is [string]) { @($p.Aliases) }
                        else { @($p.Aliases) }
                    }
                    else { @() }

                    $pAliases = @($pAliases |
                            Microsoft.PowerShell.Core\Where-Object { -not [string]::IsNullOrWhiteSpace($_) })

                    $shortType = if ($p.ParameterType) {
                        ($p.ParameterType `
                            -replace '^System\.', '' `
                            -replace 'Management\.Automation\.', '' `
                            -replace 'Collections\.Generic\.', '' `
                            -replace '``1', '')
                    }
                    else { 'Object' }

                    $isSwitch = ($shortType -eq 'SwitchParameter')

                    if ($isSwitch) {
                        $null = $sb.AppendLine("### ``-$($p.Name)``")
                    }
                    else {
                        $null = $sb.AppendLine(
                            "### ``-$($p.Name) <${shortType}>``")
                    }
                    $null = $sb.AppendLine()

                    # Description (prefer HelpMessage, fallback to parameter
                    # name).
                    $pDesc = if (-not [string]::IsNullOrWhiteSpace(
                            $p.HelpMessage)) {
                        $p.HelpMessage
                    }
                    else { "The ``-$($p.Name)`` parameter." }

                    # Normalize: collapse newlines, merge whitespace, strip
                    # PowerShell string concatenation and parenthesization.
                    $pDesc = $pDesc -replace '\r?\n', ' '
                    $pDesc = $pDesc -replace '\s{2,}', ' '
                    $pDesc = $pDesc -replace '["'']\s*\+\s*["'']', ' '
                    $pDesc = $pDesc -replace '^\s*\(\s*["'']', '' -replace '["'']\s*\)\s*$', ''
                    $pDesc = $pDesc.Trim()

                    $null = $sb.AppendLine("> ${pDesc}")
                    $null = $sb.AppendLine()

                    # Detail table.
                    $null = $sb.AppendLine("| $($markdownLabels['Property']) | $($markdownLabels['Value']) |")
                    $null = $sb.AppendLine('|:---|:---|')

                    # Required?
                    $reqText = if ($p.Mandatory) { $markdownLabels['Yes'] } else { $markdownLabels['No'] }
                    $null = $sb.AppendLine(
                        "| **$($markdownLabels['Required?'])** | ${reqText} |")

                    # Position?
                    $posText = if ($p.Position `
                            -and $p.Position -ne 'Named') {
                        $p.Position
                    }
                    else { 'Named' }
                    $null = $sb.AppendLine(
                        "| **$($markdownLabels['Position?'])** | ${posText} |")

                    # Default value.
                    $defText = if ($null -ne $p.DefaultValue) {
                        if ($p.DefaultValue -is `
                                [System.Collections.IDictionary] -and `
                                $p.DefaultValue.Contains('IsPresent')) {
                            if ($p.DefaultValue['IsPresent']) {
                                '`$true`'
                            }
                            else { '`$false`' }
                        }
                        elseif (-not [string]::IsNullOrWhiteSpace(
                                [string]$p.DefaultValue)) {
                            "``$($p.DefaultValue)``"
                        }
                        else { $markdownLabels['*(none)*'] }
                    }
                    else { $markdownLabels['*(none)*'] }
                    $null = $sb.AppendLine(
                        "| **$($markdownLabels['Default value'])** | ${defText} |")

                    # Pipeline input.
                    $pipelineParts = @()
                    if ($p.ValueFromPipeline) {
                        $pipelineParts += 'ByValue'
                    }
                    if ($p.ValueFromPipelineByPropertyName) {
                        $pipelineParts += 'ByPropertyName'
                    }
                    $pipelineText = if ($pipelineParts.Count -gt 0) {
                        'True (' + ($pipelineParts -join ', ') + ')'
                    }
                    else { 'False' }
                    $null = $sb.AppendLine(
                        "| **$($markdownLabels['Accept pipeline input?'])** | ${pipelineText} |")

                    # Aliases.
                    $aliasText = if ($pAliases.Count -gt 0) {
                        ($pAliases |
                            Microsoft.PowerShell.Core\ForEach-Object { "``${_}``" }) -join ', '
                    }
                    else { $markdownLabels['*(none)*'] }
                    $null = $sb.AppendLine(
                        "| **$($markdownLabels['Aliases'])** | ${aliasText} |")

                    # Wildcards.
                    $wcText = if ($p.SupportsWildcards) {
                        $markdownLabels['Yes']
                    }
                    else { $markdownLabels['No'] }
                    $null = $sb.AppendLine(
                        "| **$($markdownLabels['Accept wildcard characters?'])** | ${wcText} |")

                    # Parameter set name (if not default).
                    $setName = if ($p.ParameterSetNames) {
                        $p.ParameterSetNames[0]
                    }
                    elseif ($p.ParameterSetName) {
                        $p.ParameterSetName
                    }
                    else { 'All' }
                    if ($setName -ne 'All' -and
                        $setName -ne '__AllParameterSets') {
                        $null = $sb.AppendLine(
                            "| **$($markdownLabels['Parameter set'])** | ${setName} |")
                    }

                    $null = $sb.AppendLine()

                    # Add Remaining Arguments note if applicable.
                    if ($p.ValueFromRemainingArguments) {
                        $null = $sb.AppendLine(
                            "> $($markdownLabels['This parameter accepts all remaining arguments.'])")
                        $null = $sb.AppendLine()
                    }

                    $null = $sb.AppendLine("<hr/>")
                    $null = $sb.AppendLine()
                }
            }

            # -- Outputs -------------------------------------------------------------
            $outputs = $Meta['OutputType']
            if ($outputs -and $outputs.Count -gt 0) {
                $null = $sb.AppendLine("## $($markdownLabels['Outputs'])")
                $null = $sb.AppendLine()
                foreach ($o in $outputs) {
                    if (-not $o) { continue }
                    $typeName = $o.ToString() `
                        -replace '^System\.', '' `
                        -replace 'Management\.Automation\.', '' `
                        -replace 'Collections\.Generic\.', ''
                    $null = $sb.AppendLine("- ``${typeName}``")
                }
                $null = $sb.AppendLine()
            }

            # -- Related Links -------------------------------------------------------
            $null = $sb.AppendLine("## $($markdownLabels['Related Links'])")
            $null = $sb.AppendLine()

            if ($SiblingCmdlets.Count -gt 0) {
                # Build link URL prefix — same logic as README.md index.
                $linkPrefix = if ($LinkPrefix) {
                    $LinkPrefix
                }
                else { './' }

                foreach ($s in $SiblingCmdlets) {
                    $sName = $s['Name']
                    $null = $sb.AppendLine(
                        "- [${sName}](${linkPrefix}${sName}.md)")
                }
            }
            $null = $sb.AppendLine()

            return $sb.ToString().TrimEnd() + "`r`n"
        }

        ###############################################################################
        # README index renderer
        ###############################################################################
        function RenderReadmeIndex {
            param(
                [string] $ModuleName,
                [System.Collections.IDictionary] $LinkMap,
                [string] $LinkPrefix
            )

            [System.Text.StringBuilder] $sb = [System.Text.StringBuilder]::new()

            # -- Header --------------------------------------------------------------
            $null = $sb.AppendLine("# ${ModuleName}$($markdownLabels[' — Cmdlet Reference'])")
            $null = $sb.AppendLine()
            $null = $sb.AppendLine(
                $markdownLabels['Auto-generated cmdlet reference documentation. '] +
                "$($markdownLabels['Last updated: '])$(Microsoft.PowerShell.Utility\Get-Date -Format 'yyyy-MM-dd').")
            $null = $sb.AppendLine()

            # -- Per sub-module tables -----------------------------------------------
            $sortedKeys = @($LinkMap.Keys | Microsoft.PowerShell.Utility\Sort-Object)
            $first = $true

            foreach ($subModule in $sortedKeys) {
                $cmdlets = $LinkMap[$subModule]

                if (-not $first) {
                    $null = $sb.AppendLine('---')
                    $null = $sb.AppendLine()
                }
                $first = $false

                $null = $sb.AppendLine("## ${subModule}")
                $null = $sb.AppendLine()
                $null = $sb.AppendLine("| $($markdownLabels['Command']) | $($markdownLabels['Aliases']) | $($markdownLabels['Description']) |")
                $null = $sb.AppendLine('|:---|:---|:---|')

                foreach ($c in $cmdlets) {
                    $name = $c['Name']
                    $synopsis = if ($c['Synopsis']) { $c['Synopsis'] } else { '' }
                    $aliases = if ($c['Aliases'] -and $c['Aliases'].Count -gt 0) {
                        ($c['Aliases'] -join ', ')
                    }
                    else { '' }

                    # Build link URL.
                    if ($LinkPrefix) {
                        $url = "${LinkPrefix}${name}.md"
                    }
                    else {
                        $url = "./${name}.md"
                    }

                    # Empty cells → &nbsp; strip line breaks to keep table intact
                    $aliasCell = if ($aliases) {
                        $aliases -replace '\r?\n', ' '
                    }
                    else { '&nbsp;' }
                    $synopsisCell = if ($synopsis) {
                        $synopsis -replace '\r?\n', ' '
                    }
                    else { '&nbsp;' }

                    $null = $sb.AppendLine(
                        "| [${name}](${url}) | ${aliasCell} | ${synopsisCell} |")
                }
                $null = $sb.AppendLine()
            }

            return $sb.ToString().TrimEnd() + "`r`n"
        }
        ################################################################################

        # -- Resolve module --------------------------------------------------
        # Prefer the actually-loaded module (has ExportedCommands).
        # Otherwise fall back to the available module with the highest
        # version number.
        $module = @(Microsoft.PowerShell.Core\Get-Module -Name $ModuleName `
                -ErrorAction SilentlyContinue |
                Microsoft.PowerShell.Core\Where-Object {
                    $_.ExportedCommands.Count -gt 0 })[0]

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

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Module root: ${moduleRoot}")

        # -- Determine output path -------------------------------------------
        if (-not $OutputPath) {
            $OutputPath = [System.IO.Path]::Combine($moduleRoot, 'Docs', $Language)
        }

        # Resolve and create output directory.
        $docsDir = $ExecutionContext.SessionState.Path.GetUnresolvedProviderPathFromPSPath(
            $OutputPath)
        if (-not (Microsoft.PowerShell.Management\Test-Path $docsDir)) {
            $null = Microsoft.PowerShell.Management\New-Item `
                -ItemType Directory -Path $docsDir -Force `
                -ErrorAction Stop
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Output directory: ${docsDir}")

        # -- Track generated files for pipeline output -----------------------
        $generatedFiles = [System.Collections.Generic.List[string]]::new()

        # -- Cache module-level metadata params ------------------------------
        $metaModuleParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName "GenXdev\Get-ModuleCmdletMetaData" ;

        # -- Cache translatable markdown UI labels ---------------------------
        # Build translation params for Get-TextTranslation.
        $transParams = GenXdev\Copy-IdenticalParamValues `
            -BoundParameters $PSBoundParameters `
            -FunctionName 'GenXdev\Get-TextTranslation'

        # Set translation instructions, following the same pattern as
        # Get-CmdletMetaData.  Without instructions, the LLM misinterprets
        # single-word UI labels (e.g. "Sub" → "duikboot" instead of "Sub").
        if (-not $PSBoundParameters.ContainsKey("TranslationInstructions")) {
            $transParams.Instructions = @"

Translate these documentation UI labels into $Language.

These are standalone labels (section headers, column headers, table
captions) from a PowerShell cmdlet markdown document.

- Translate each label literally as a standalone word or short phrase.
- Do NOT interpret labels as commands, instructions, or sentences.
- Keep translations concise — prefer the shortest accurate translation.
- Output ONLY the translated label — no explanations or formatting.

"@
            $transParams.NoDefaultInstructions = $true
        }
        else {
            $transParams.Instructions = $TranslationInstructions
            $transParams.NoDefaultInstructions = $true
        }

        # -- Hardcoded translations for 19 supported languages -----------------
        # These provide accurate, consistent translations for markdown UI
        # labels without relying on LLM calls. Only languages NOT in this
        # lookup table fall through to Get-TextTranslation.
        $hardcodedLabelTranslations = @{
            'ar-SA' = @{
                # Section headers
                'Synopsis'                      = 'ملخص'
                'Description'                   = 'الوصف'
                'License'                       = 'الترخيص'
                'Syntax'                        = 'الصيغة'
                'Parameters'                    = 'المعاملات'
                'Examples'                      = 'أمثلة'
                'Parameter Details'             = 'تفاصيل المعامل'
                'Outputs'                       = 'المخرجات'
                'Related Links'                 = 'روابط ذات صلة'
                # Column headers — parameters table
                'Name'                          = 'الاسم'
                'Type'                          = 'النوع'
                'Required'                      = 'مطلوب'
                # Column headers — parameter details table
                'Property'                      = 'الخاصية'
                'Value'                         = 'القيمة'
                # Column headers — README table
                'Command'                       = 'الأمر'
                # Row labels — parameter details
                'Required?'                     = 'مطلوب؟'
                'Position?'                     = 'الموضع؟'
                'Default value'                 = 'القيمة الافتراضية'
                'Accept pipeline input?'        = 'إدخال التوجيه؟'
                'Aliases'                       = 'الأسماء المستعارة'
                'Accept wildcard characters?'   = 'أحرف البدل؟'
                'Parameter set'                 = 'مجموعة المعاملات'
                # Values
                'Yes'                           = 'نعم'
                'No'                            = 'لا'
                # Fallback text
                '*(No synopsis provided)*'      = '*(لا يوجد ملخص)*'
                '*(none)*'                      = '*(لا شيء)*'
                'parameter'                     = 'معامل'
                # HTML labels
                'Show license'                  = 'إظهار الترخيص'
                'Expand description'            = 'توسيع الوصف'
                # README page
                ' — Cmdlet Reference'           = ' — مرجع الأوامر'
                'Auto-generated cmdlet reference documentation. ' = 'وثائق مرجع الأوامر المنشأة تلقائيًا. '
                'Last updated: '                = 'آخر تحديث: '
                # Meta line labels
                'Sub'                           = 'وحدة فرعية'
                'Module:'                       = 'الوحدة:'
                'Type:'                         = 'النوع:'
                'Aliases:'                      = 'الأسماء المستعارة:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 أحرف البدل'
                ' (hidden)'                     = ' (مخفي)'
                'This parameter accepts all remaining arguments.' = 'هذا المعامل يقبل جميع الوسائط المتبقية.'
            }
            'de-DE' = @{
                # Section headers
                'Synopsis'                      = 'Zusammenfassung'
                'Description'                   = 'Beschreibung'
                'License'                       = 'Lizenz'
                'Syntax'                        = 'Syntax'
                'Parameters'                    = 'Parameter'
                'Examples'                      = 'Beispiele'
                'Parameter Details'             = 'Parameterdetails'
                'Outputs'                       = 'Ausgaben'
                'Related Links'                 = 'Verwandte Links'
                # Column headers — parameters table
                'Name'                          = 'Name'
                'Type'                          = 'Typ'
                'Required'                      = 'Erforderlich'
                # Column headers — parameter details table
                'Property'                      = 'Eigenschaft'
                'Value'                         = 'Wert'
                # Column headers — README table
                'Command'                       = 'Befehl'
                # Row labels — parameter details
                'Required?'                     = 'Erforderlich?'
                'Position?'                     = 'Position?'
                'Default value'                 = 'Standardwert'
                'Accept pipeline input?'        = 'Pipeline-Eingabe?'
                'Aliases'                       = 'Aliase'
                'Accept wildcard characters?'   = 'Platzhalterzeichen?'
                'Parameter set'                 = 'Parametersatz'
                # Values
                'Yes'                           = 'Ja'
                'No'                            = 'Nein'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Keine Zusammenfassung)*'
                '*(none)*'                      = '*(keine)*'
                'parameter'                     = 'Parameter'
                # HTML labels
                'Show license'                  = 'Lizenz anzeigen'
                'Expand description'            = 'Beschreibung erweitern'
                # README page
                ' — Cmdlet Reference'           = ' — Cmdlet-Referenz'
                'Auto-generated cmdlet reference documentation. ' = 'Automatisch generierte Cmdlet-Referenzdokumentation. '
                'Last updated: '                = 'Zuletzt aktualisiert: '
                # Meta line labels
                'Sub'                           = 'Untermodul'
                'Module:'                       = 'Modul:'
                'Type:'                         = 'Typ:'
                'Aliases:'                      = 'Aliase:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 Platzhalter'
                ' (hidden)'                     = ' (ausgeblendet)'
                'This parameter accepts all remaining arguments.' = 'Dieser Parameter akzeptiert alle verbleibenden Argumente.'
            }
            'es-ES' = @{
                # Section headers
                'Synopsis'                      = 'Resumen'
                'Description'                   = 'Descripción'
                'License'                       = 'Licencia'
                'Syntax'                        = 'Sintaxis'
                'Parameters'                    = 'Parámetros'
                'Examples'                      = 'Ejemplos'
                'Parameter Details'             = 'Detalles del parámetro'
                'Outputs'                       = 'Salidas'
                'Related Links'                 = 'Enlaces relacionados'
                # Column headers — parameters table
                'Name'                          = 'Nombre'
                'Type'                          = 'Tipo'
                'Required'                      = 'Requerido'
                # Column headers — parameter details table
                'Property'                      = 'Propiedad'
                'Value'                         = 'Valor'
                # Column headers — README table
                'Command'                       = 'Comando'
                # Row labels — parameter details
                'Required?'                     = '¿Requerido?'
                'Position?'                     = '¿Posición?'
                'Default value'                 = 'Valor predeterminado'
                'Accept pipeline input?'        = '¿Entrada de canalización?'
                'Aliases'                       = 'Alias'
                'Accept wildcard characters?'   = '¿Caracteres comodín?'
                'Parameter set'                 = 'Conjunto de parámetros'
                # Values
                'Yes'                           = 'Sí'
                'No'                            = 'No'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Sin resumen)*'
                '*(none)*'                      = '*(ninguno)*'
                'parameter'                     = 'parámetro'
                # HTML labels
                'Show license'                  = 'Mostrar licencia'
                'Expand description'            = 'Expandir descripción'
                # README page
                ' — Cmdlet Reference'           = ' — Referencia de cmdlets'
                'Auto-generated cmdlet reference documentation. ' = 'Documentación de referencia de cmdlets generada automáticamente. '
                'Last updated: '                = 'Última actualización: '
                # Meta line labels
                'Sub'                           = 'Submódulo'
                'Module:'                       = 'Módulo:'
                'Type:'                         = 'Tipo:'
                'Aliases:'                      = 'Alias:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 comodines'
                ' (hidden)'                     = ' (oculto)'
                'This parameter accepts all remaining arguments.' = 'Este parámetro acepta todos los argumentos restantes.'
            }
            'fr-FR' = @{
                # Section headers
                'Synopsis'                      = 'Résumé'
                'Description'                   = 'Description'
                'License'                       = 'Licence'
                'Syntax'                        = 'Syntaxe'
                'Parameters'                    = 'Paramètres'
                'Examples'                      = 'Exemples'
                'Parameter Details'             = 'Détails des paramètres'
                'Outputs'                       = 'Sorties'
                'Related Links'                 = 'Liens connexes'
                # Column headers — parameters table
                'Name'                          = 'Nom'
                'Type'                          = 'Type'
                'Required'                      = 'Requis'
                # Column headers — parameter details table
                'Property'                      = 'Propriété'
                'Value'                         = 'Valeur'
                # Column headers — README table
                'Command'                       = 'Commande'
                # Row labels — parameter details
                'Required?'                     = 'Requis ?'
                'Position?'                     = 'Position ?'
                'Default value'                 = 'Valeur par défaut'
                'Accept pipeline input?'        = 'Entrée de pipeline ?'
                'Aliases'                       = 'Alias'
                'Accept wildcard characters?'   = 'Caractères génériques ?'
                'Parameter set'                 = 'Jeu de paramètres'
                # Values
                'Yes'                           = 'Oui'
                'No'                            = 'Non'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Aucun résumé fourni)*'
                '*(none)*'                      = '*(aucun)*'
                'parameter'                     = 'paramètre'
                # HTML labels
                'Show license'                  = 'Afficher la licence'
                'Expand description'            = 'Développer la description'
                # README page
                ' — Cmdlet Reference'           = ' — Référence des cmdlets'
                'Auto-generated cmdlet reference documentation. ' = 'Documentation de référence des cmdlets générée automatiquement. '
                'Last updated: '                = 'Dernière mise à jour : '
                # Meta line labels
                'Sub'                           = 'Sous-module'
                'Module:'                       = 'Module :'
                'Type:'                         = 'Type :'
                'Aliases:'                      = 'Alias :'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 caractères génériques'
                ' (hidden)'                     = ' (masqué)'
                'This parameter accepts all remaining arguments.' = 'Ce paramètre accepte tous les arguments restants.'
            }
            'hi-IN' = @{
                # Section headers
                'Synopsis'                      = 'सारांश'
                'Description'                   = 'विवरण'
                'License'                       = 'लाइसेंस'
                'Syntax'                        = 'सिंटैक्स'
                'Parameters'                    = 'पैरामीटर'
                'Examples'                      = 'उदाहरण'
                'Parameter Details'             = 'पैरामीटर विवरण'
                'Outputs'                       = 'आउटपुट'
                'Related Links'                 = 'संबंधित लिंक'
                # Column headers — parameters table
                'Name'                          = 'नाम'
                'Type'                          = 'प्रकार'
                'Required'                      = 'आवश्यक'
                # Column headers — parameter details table
                'Property'                      = 'गुण'
                'Value'                         = 'मान'
                # Column headers — README table
                'Command'                       = 'कमांड'
                # Row labels — parameter details
                'Required?'                     = 'आवश्यक?'
                'Position?'                     = 'स्थिति?'
                'Default value'                 = 'डिफ़ॉल्ट मान'
                'Accept pipeline input?'        = 'पाइपलाइन इनपुट?'
                'Aliases'                       = 'उपनाम'
                'Accept wildcard characters?'   = 'वाइल्डकार्ड वर्ण?'
                'Parameter set'                 = 'पैरामीटर सेट'
                # Values
                'Yes'                           = 'हाँ'
                'No'                            = 'नहीं'
                # Fallback text
                '*(No synopsis provided)*'      = '*(कोई सारांश नहीं)*'
                '*(none)*'                      = '*(कोई नहीं)*'
                'parameter'                     = 'पैरामीटर'
                # HTML labels
                'Show license'                  = 'लाइसेंस दिखाएँ'
                'Expand description'            = 'विवरण विस्तृत करें'
                # README page
                ' — Cmdlet Reference'           = ' — कमांडलेट संदर्भ'
                'Auto-generated cmdlet reference documentation. ' = 'स्वचालित रूप से जनरेट किया गया कमांडलेट संदर्भ दस्तावेज़। '
                'Last updated: '                = 'अंतिम अपडेट: '
                # Meta line labels
                'Sub'                           = 'उप-मॉड्यूल'
                'Module:'                       = 'मॉड्यूल:'
                'Type:'                         = 'प्रकार:'
                'Aliases:'                      = 'उपनाम:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 वाइल्डकार्ड'
                ' (hidden)'                     = ' (छिपा हुआ)'
                'This parameter accepts all remaining arguments.' = 'यह पैरामीटर सभी शेष तर्क स्वीकार करता है।'
            }
            'id-ID' = @{
                # Section headers
                'Synopsis'                      = 'Ringkasan'
                'Description'                   = 'Deskripsi'
                'License'                       = 'Lisensi'
                'Syntax'                        = 'Sintaks'
                'Parameters'                    = 'Parameter'
                'Examples'                      = 'Contoh'
                'Parameter Details'             = 'Detail Parameter'
                'Outputs'                       = 'Keluaran'
                'Related Links'                 = 'Tautan Terkait'
                # Column headers — parameters table
                'Name'                          = 'Nama'
                'Type'                          = 'Tipe'
                'Required'                      = 'Diperlukan'
                # Column headers — parameter details table
                'Property'                      = 'Properti'
                'Value'                         = 'Nilai'
                # Column headers — README table
                'Command'                       = 'Perintah'
                # Row labels — parameter details
                'Required?'                     = 'Diperlukan?'
                'Position?'                     = 'Posisi?'
                'Default value'                 = 'Nilai default'
                'Accept pipeline input?'        = 'Input pipeline?'
                'Aliases'                       = 'Alias'
                'Accept wildcard characters?'   = 'Karakter wildcard?'
                'Parameter set'                 = 'Set parameter'
                # Values
                'Yes'                           = 'Ya'
                'No'                            = 'Tidak'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Tidak ada ringkasan)*'
                '*(none)*'                      = '*(tidak ada)*'
                'parameter'                     = 'parameter'
                # HTML labels
                'Show license'                  = 'Tampilkan lisensi'
                'Expand description'            = 'Perluas deskripsi'
                # README page
                ' — Cmdlet Reference'           = ' — Referensi Cmdlet'
                'Auto-generated cmdlet reference documentation. ' = 'Dokumentasi referensi cmdlet yang dibuat otomatis. '
                'Last updated: '                = 'Terakhir diperbarui: '
                # Meta line labels
                'Sub'                           = 'Submodul'
                'Module:'                       = 'Modul:'
                'Type:'                         = 'Tipe:'
                'Aliases:'                      = 'Alias:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 wildcard'
                ' (hidden)'                     = ' (tersembunyi)'
                'This parameter accepts all remaining arguments.' = 'Parameter ini menerima semua argumen yang tersisa.'
            }
            'it-IT' = @{
                # Section headers
                'Synopsis'                      = 'Riepilogo'
                'Description'                   = 'Descrizione'
                'License'                       = 'Licenza'
                'Syntax'                        = 'Sintassi'
                'Parameters'                    = 'Parametri'
                'Examples'                      = 'Esempi'
                'Parameter Details'             = 'Dettagli parametro'
                'Outputs'                       = 'Output'
                'Related Links'                 = 'Collegamenti correlati'
                # Column headers — parameters table
                'Name'                          = 'Nome'
                'Type'                          = 'Tipo'
                'Required'                      = 'Richiesto'
                # Column headers — parameter details table
                'Property'                      = 'Proprietà'
                'Value'                         = 'Valore'
                # Column headers — README table
                'Command'                       = 'Comando'
                # Row labels — parameter details
                'Required?'                     = 'Richiesto?'
                'Position?'                     = 'Posizione?'
                'Default value'                 = 'Valore predefinito'
                'Accept pipeline input?'        = 'Input pipeline?'
                'Aliases'                       = 'Alias'
                'Accept wildcard characters?'   = 'Caratteri jolly?'
                'Parameter set'                 = 'Set di parametri'
                # Values
                'Yes'                           = 'Sì'
                'No'                            = 'No'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Nessun riepilogo)*'
                '*(none)*'                      = '*(nessuno)*'
                'parameter'                     = 'parametro'
                # HTML labels
                'Show license'                  = 'Mostra licenza'
                'Expand description'            = 'Espandi descrizione'
                # README page
                ' — Cmdlet Reference'           = ' — Riferimento cmdlet'
                'Auto-generated cmdlet reference documentation. ' = 'Documentazione di riferimento cmdlet generata automaticamente. '
                'Last updated: '                = 'Ultimo aggiornamento: '
                # Meta line labels
                'Sub'                           = 'Sottomodulo'
                'Module:'                       = 'Modulo:'
                'Type:'                         = 'Tipo:'
                'Aliases:'                      = 'Alias:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 caratteri jolly'
                ' (hidden)'                     = ' (nascosto)'
                'This parameter accepts all remaining arguments.' = 'Questo parametro accetta tutti gli argomenti rimanenti.'
            }
            'ja-JP' = @{
                # Section headers
                'Synopsis'                      = '概要'
                'Description'                   = '説明'
                'License'                       = 'ライセンス'
                'Syntax'                        = '構文'
                'Parameters'                    = 'パラメーター'
                'Examples'                      = '例'
                'Parameter Details'             = 'パラメーター詳細'
                'Outputs'                       = '出力'
                'Related Links'                 = '関連リンク'
                # Column headers — parameters table
                'Name'                          = '名前'
                'Type'                          = '型'
                'Required'                      = '必須'
                # Column headers — parameter details table
                'Property'                      = 'プロパティ'
                'Value'                         = '値'
                # Column headers — README table
                'Command'                       = 'コマンド'
                # Row labels — parameter details
                'Required?'                     = '必須？'
                'Position?'                     = '位置？'
                'Default value'                 = '既定値'
                'Accept pipeline input?'        = 'パイプライン入力？'
                'Aliases'                       = 'エイリアス'
                'Accept wildcard characters?'   = 'ワイルドカード？'
                'Parameter set'                 = 'パラメーターセット'
                # Values
                'Yes'                           = 'はい'
                'No'                            = 'いいえ'
                # Fallback text
                '*(No synopsis provided)*'      = '*(概要なし)*'
                '*(none)*'                      = '*(なし)*'
                'parameter'                     = 'パラメーター'
                # HTML labels
                'Show license'                  = 'ライセンスを表示'
                'Expand description'            = '説明を展開'
                # README page
                ' — Cmdlet Reference'           = ' — コマンドレットリファレンス'
                'Auto-generated cmdlet reference documentation. ' = '自動生成されたコマンドレットリファレンスドキュメント。 '
                'Last updated: '                = '最終更新日： '
                # Meta line labels
                'Sub'                           = 'サブモジュール'
                'Module:'                       = 'モジュール：'
                'Type:'                         = '種類：'
                'Aliases:'                      = 'エイリアス：'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 ワイルドカード'
                ' (hidden)'                     = ' （非表示）'
                'This parameter accepts all remaining arguments.' = 'このパラメーターは残りのすべての引数を受け入れます。'
            }
            'ko-KR' = @{
                # Section headers
                'Synopsis'                      = '개요'
                'Description'                   = '설명'
                'License'                       = '라이선스'
                'Syntax'                        = '구문'
                'Parameters'                    = '매개 변수'
                'Examples'                      = '예제'
                'Parameter Details'             = '매개 변수 세부 정보'
                'Outputs'                       = '출력'
                'Related Links'                 = '관련 링크'
                # Column headers — parameters table
                'Name'                          = '이름'
                'Type'                          = '유형'
                'Required'                      = '필수'
                # Column headers — parameter details table
                'Property'                      = '속성'
                'Value'                         = '값'
                # Column headers — README table
                'Command'                       = '명령'
                # Row labels — parameter details
                'Required?'                     = '필수?'
                'Position?'                     = '위치?'
                'Default value'                 = '기본값'
                'Accept pipeline input?'        = '파이프라인 입력?'
                'Aliases'                       = '별칭'
                'Accept wildcard characters?'   = '와일드카드?'
                'Parameter set'                 = '매개 변수 집합'
                # Values
                'Yes'                           = '예'
                'No'                            = '아니요'
                # Fallback text
                '*(No synopsis provided)*'      = '*(개요 없음)*'
                '*(none)*'                      = '*(없음)*'
                'parameter'                     = '매개 변수'
                # HTML labels
                'Show license'                  = '라이선스 표시'
                'Expand description'            = '설명 펼치기'
                # README page
                ' — Cmdlet Reference'           = ' — Cmdlet 참조'
                'Auto-generated cmdlet reference documentation. ' = '자동 생성된 cmdlet 참조 설명서. '
                'Last updated: '                = '마지막 업데이트: '
                # Meta line labels
                'Sub'                           = '하위 모듈'
                'Module:'                       = '모듈:'
                'Type:'                         = '유형:'
                'Aliases:'                      = '별칭:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 와일드카드'
                ' (hidden)'                     = ' (숨김)'
                'This parameter accepts all remaining arguments.' = '이 매개 변수는 나머지 모든 인수를 허용합니다.'
            }
            'nl-NL' = @{
                # Section headers
                'Synopsis'                      = 'Samenvatting'
                'Description'                   = 'Beschrijving'
                'License'                       = 'Licentie'
                'Syntax'                        = 'Syntaxis'
                'Parameters'                    = 'Parameters'
                'Examples'                      = 'Voorbeelden'
                'Parameter Details'             = 'Parameterdetails'
                'Outputs'                       = 'Uitvoer'
                'Related Links'                 = 'Gerelateerde links'
                # Column headers — parameters table
                'Name'                          = 'Naam'
                'Type'                          = 'Type'
                'Required'                      = 'Vereist'
                # Column headers — parameter details table
                'Property'                      = 'Eigenschap'
                'Value'                         = 'Waarde'
                # Column headers — README table
                'Command'                       = 'Opdracht'
                # Row labels — parameter details
                'Required?'                     = 'Vereist?'
                'Position?'                     = 'Positie?'
                'Default value'                 = 'Standaardwaarde'
                'Accept pipeline input?'        = 'Pijplijninvoer?'
                'Aliases'                       = 'Aliassen'
                'Accept wildcard characters?'   = 'Jokertekens?'
                'Parameter set'                 = 'Parameterset'
                # Values
                'Yes'                           = 'Ja'
                'No'                            = 'Nee'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Geen samenvatting)*'
                '*(none)*'                      = '*(geen)*'
                'parameter'                     = 'parameter'
                # HTML labels
                'Show license'                  = 'Licentie tonen'
                'Expand description'            = 'Beschrijving uitvouwen'
                # README page
                ' — Cmdlet Reference'           = ' — Cmdlet-referentie'
                'Auto-generated cmdlet reference documentation. ' = 'Automatisch gegenereerde cmdlet-referentiedocumentatie. '
                'Last updated: '                = 'Laatst bijgewerkt: '
                # Meta line labels
                'Sub'                           = 'Sub'
                'Module:'                       = 'Module:'
                'Type:'                         = 'Type:'
                'Aliases:'                      = 'Aliassen:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 jokertekens'
                ' (hidden)'                     = ' (verborgen)'
                'This parameter accepts all remaining arguments.' = 'Deze parameter accepteert alle resterende argumenten.'
            }
            'pl-PL' = @{
                # Section headers
                'Synopsis'                      = 'Streszczenie'
                'Description'                   = 'Opis'
                'License'                       = 'Licencja'
                'Syntax'                        = 'Składnia'
                'Parameters'                    = 'Parametry'
                'Examples'                      = 'Przykłady'
                'Parameter Details'             = 'Szczegóły parametru'
                'Outputs'                       = 'Dane wyjściowe'
                'Related Links'                 = 'Powiązane linki'
                # Column headers — parameters table
                'Name'                          = 'Nazwa'
                'Type'                          = 'Typ'
                'Required'                      = 'Wymagany'
                # Column headers — parameter details table
                'Property'                      = 'Właściwość'
                'Value'                         = 'Wartość'
                # Column headers — README table
                'Command'                       = 'Polecenie'
                # Row labels — parameter details
                'Required?'                     = 'Wymagany?'
                'Position?'                     = 'Pozycja?'
                'Default value'                 = 'Wartość domyślna'
                'Accept pipeline input?'        = 'Dane wejściowe potoku?'
                'Aliases'                       = 'Aliasy'
                'Accept wildcard characters?'   = 'Znaki wieloznaczne?'
                'Parameter set'                 = 'Zestaw parametrów'
                # Values
                'Yes'                           = 'Tak'
                'No'                            = 'Nie'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Brak streszczenia)*'
                '*(none)*'                      = '*(brak)*'
                'parameter'                     = 'parametr'
                # HTML labels
                'Show license'                  = 'Pokaż licencję'
                'Expand description'            = 'Rozwiń opis'
                # README page
                ' — Cmdlet Reference'           = ' — Dokumentacja poleceń'
                'Auto-generated cmdlet reference documentation. ' = 'Automatycznie wygenerowana dokumentacja poleceń. '
                'Last updated: '                = 'Ostatnia aktualizacja: '
                # Meta line labels
                'Sub'                           = 'Podmoduł'
                'Module:'                       = 'Moduł:'
                'Type:'                         = 'Typ:'
                'Aliases:'                      = 'Aliasy:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 znaki wieloznaczne'
                ' (hidden)'                     = ' (ukryty)'
                'This parameter accepts all remaining arguments.' = 'Ten parametr akceptuje wszystkie pozostałe argumenty.'
            }
            'pt-BR' = @{
                # Section headers
                'Synopsis'                      = 'Resumo'
                'Description'                   = 'Descrição'
                'License'                       = 'Licença'
                'Syntax'                        = 'Sintaxe'
                'Parameters'                    = 'Parâmetros'
                'Examples'                      = 'Exemplos'
                'Parameter Details'             = 'Detalhes do parâmetro'
                'Outputs'                       = 'Saídas'
                'Related Links'                 = 'Links relacionados'
                # Column headers — parameters table
                'Name'                          = 'Nome'
                'Type'                          = 'Tipo'
                'Required'                      = 'Obrigatório'
                # Column headers — parameter details table
                'Property'                      = 'Propriedade'
                'Value'                         = 'Valor'
                # Column headers — README table
                'Command'                       = 'Comando'
                # Row labels — parameter details
                'Required?'                     = 'Obrigatório?'
                'Position?'                     = 'Posição?'
                'Default value'                 = 'Valor padrão'
                'Accept pipeline input?'        = 'Entrada de pipeline?'
                'Aliases'                       = 'Aliases'
                'Accept wildcard characters?'   = 'Caracteres curinga?'
                'Parameter set'                 = 'Conjunto de parâmetros'
                # Values
                'Yes'                           = 'Sim'
                'No'                            = 'Não'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Nenhum resumo)*'
                '*(none)*'                      = '*(nenhum)*'
                'parameter'                     = 'parâmetro'
                # HTML labels
                'Show license'                  = 'Mostrar licença'
                'Expand description'            = 'Expandir descrição'
                # README page
                ' — Cmdlet Reference'           = ' — Referência de cmdlets'
                'Auto-generated cmdlet reference documentation. ' = 'Documentação de referência de cmdlets gerada automaticamente. '
                'Last updated: '                = 'Última atualização: '
                # Meta line labels
                'Sub'                           = 'Submódulo'
                'Module:'                       = 'Módulo:'
                'Type:'                         = 'Tipo:'
                'Aliases:'                      = 'Aliases:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 curingas'
                ' (hidden)'                     = ' (oculto)'
                'This parameter accepts all remaining arguments.' = 'Este parâmetro aceita todos os argumentos restantes.'
            }
            'ru-RU' = @{
                # Section headers
                'Synopsis'                      = 'Краткое описание'
                'Description'                   = 'Описание'
                'License'                       = 'Лицензия'
                'Syntax'                        = 'Синтаксис'
                'Parameters'                    = 'Параметры'
                'Examples'                      = 'Примеры'
                'Parameter Details'             = 'Сведения о параметре'
                'Outputs'                       = 'Выходные данные'
                'Related Links'                 = 'Связанные ссылки'
                # Column headers — parameters table
                'Name'                          = 'Имя'
                'Type'                          = 'Тип'
                'Required'                      = 'Обязательный'
                # Column headers — parameter details table
                'Property'                      = 'Свойство'
                'Value'                         = 'Значение'
                # Column headers — README table
                'Command'                       = 'Команда'
                # Row labels — parameter details
                'Required?'                     = 'Обязательный?'
                'Position?'                     = 'Позиция?'
                'Default value'                 = 'Значение по умолчанию'
                'Accept pipeline input?'        = 'Вход конвейера?'
                'Aliases'                       = 'Псевдонимы'
                'Accept wildcard characters?'   = 'Подстановочные знаки?'
                'Parameter set'                 = 'Набор параметров'
                # Values
                'Yes'                           = 'Да'
                'No'                            = 'Нет'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Краткое описание отсутствует)*'
                '*(none)*'                      = '*(нет)*'
                'parameter'                     = 'параметр'
                # HTML labels
                'Show license'                  = 'Показать лицензию'
                'Expand description'            = 'Развернуть описание'
                # README page
                ' — Cmdlet Reference'           = ' — Справка по командлетам'
                'Auto-generated cmdlet reference documentation. ' = 'Автоматически созданная документация по командлетам. '
                'Last updated: '                = 'Последнее обновление: '
                # Meta line labels
                'Sub'                           = 'Подмодуль'
                'Module:'                       = 'Модуль:'
                'Type:'                         = 'Тип:'
                'Aliases:'                      = 'Псевдонимы:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 подстановочные знаки'
                ' (hidden)'                     = ' (скрыто)'
                'This parameter accepts all remaining arguments.' = 'Этот параметр принимает все оставшиеся аргументы.'
            }
            'sv-SE' = @{
                # Section headers
                'Synopsis'                      = 'Sammanfattning'
                'Description'                   = 'Beskrivning'
                'License'                       = 'Licens'
                'Syntax'                        = 'Syntax'
                'Parameters'                    = 'Parametrar'
                'Examples'                      = 'Exempel'
                'Parameter Details'             = 'Parameterdetaljer'
                'Outputs'                       = 'Utdata'
                'Related Links'                 = 'Relaterade länkar'
                # Column headers — parameters table
                'Name'                          = 'Namn'
                'Type'                          = 'Typ'
                'Required'                      = 'Obligatorisk'
                # Column headers — parameter details table
                'Property'                      = 'Egenskap'
                'Value'                         = 'Värde'
                # Column headers — README table
                'Command'                       = 'Kommando'
                # Row labels — parameter details
                'Required?'                     = 'Obligatorisk?'
                'Position?'                     = 'Position?'
                'Default value'                 = 'Standardvärde'
                'Accept pipeline input?'        = 'Pipeline-indata?'
                'Aliases'                       = 'Alias'
                'Accept wildcard characters?'   = 'Jokertecken?'
                'Parameter set'                 = 'Parameteruppsättning'
                # Values
                'Yes'                           = 'Ja'
                'No'                            = 'Nej'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Ingen sammanfattning)*'
                '*(none)*'                      = '*(ingen)*'
                'parameter'                     = 'parameter'
                # HTML labels
                'Show license'                  = 'Visa licens'
                'Expand description'            = 'Expandera beskrivning'
                # README page
                ' — Cmdlet Reference'           = ' — Cmdlet-referens'
                'Auto-generated cmdlet reference documentation. ' = 'Automatiskt genererad cmdlet-referensdokumentation. '
                'Last updated: '                = 'Senast uppdaterad: '
                # Meta line labels
                'Sub'                           = 'Delmodul'
                'Module:'                       = 'Modul:'
                'Type:'                         = 'Typ:'
                'Aliases:'                      = 'Alias:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 jokertecken'
                ' (hidden)'                     = ' (dold)'
                'This parameter accepts all remaining arguments.' = 'Denna parameter accepterar alla återstående argument.'
            }
            'th-TH' = @{
                # Section headers
                'Synopsis'                      = 'สรุป'
                'Description'                   = 'คำอธิบาย'
                'License'                       = 'ใบอนุญาต'
                'Syntax'                        = 'ไวยากรณ์'
                'Parameters'                    = 'พารามิเตอร์'
                'Examples'                      = 'ตัวอย่าง'
                'Parameter Details'             = 'รายละเอียดพารามิเตอร์'
                'Outputs'                       = 'ผลลัพธ์'
                'Related Links'                 = 'ลิงก์ที่เกี่ยวข้อง'
                # Column headers — parameters table
                'Name'                          = 'ชื่อ'
                'Type'                          = 'ชนิด'
                'Required'                      = 'จำเป็น'
                # Column headers — parameter details table
                'Property'                      = 'คุณสมบัติ'
                'Value'                         = 'ค่า'
                # Column headers — README table
                'Command'                       = 'คำสั่ง'
                # Row labels — parameter details
                'Required?'                     = 'จำเป็น?'
                'Position?'                     = 'ตำแหน่ง?'
                'Default value'                 = 'ค่าเริ่มต้น'
                'Accept pipeline input?'        = 'อินพุตไปป์ไลน์?'
                'Aliases'                       = 'นามแฝง'
                'Accept wildcard characters?'   = 'อักขระตัวแทน?'
                'Parameter set'                 = 'ชุดพารามิเตอร์'
                # Values
                'Yes'                           = 'ใช่'
                'No'                            = 'ไม่'
                # Fallback text
                '*(No synopsis provided)*'      = '*(ไม่มีสรุป)*'
                '*(none)*'                      = '*(ไม่มี)*'
                'parameter'                     = 'พารามิเตอร์'
                # HTML labels
                'Show license'                  = 'แสดงใบอนุญาต'
                'Expand description'            = 'ขยายคำอธิบาย'
                # README page
                ' — Cmdlet Reference'           = ' — เอกสารอ้างอิง Cmdlet'
                'Auto-generated cmdlet reference documentation. ' = 'เอกสารอ้างอิง cmdlet ที่สร้างโดยอัตโนมัติ '
                'Last updated: '                = 'อัปเดตล่าสุด: '
                # Meta line labels
                'Sub'                           = 'โมดูลย่อย'
                'Module:'                       = 'โมดูล:'
                'Type:'                         = 'ชนิด:'
                'Aliases:'                      = 'นามแฝง:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 อักขระตัวแทน'
                ' (hidden)'                     = ' (ซ่อน)'
                'This parameter accepts all remaining arguments.' = 'พารามิเตอร์นี้ยอมรับอาร์กิวเมนต์ที่เหลือทั้งหมด'
            }
            'tr-TR' = @{
                # Section headers
                'Synopsis'                      = 'Özet'
                'Description'                   = 'Açıklama'
                'License'                       = 'Lisans'
                'Syntax'                        = 'Sözdizimi'
                'Parameters'                    = 'Parametreler'
                'Examples'                      = 'Örnekler'
                'Parameter Details'             = 'Parametre Detayları'
                'Outputs'                       = 'Çıktılar'
                'Related Links'                 = 'İlgili Bağlantılar'
                # Column headers — parameters table
                'Name'                          = 'Ad'
                'Type'                          = 'Tür'
                'Required'                      = 'Gerekli'
                # Column headers — parameter details table
                'Property'                      = 'Özellik'
                'Value'                         = 'Değer'
                # Column headers — README table
                'Command'                       = 'Komut'
                # Row labels — parameter details
                'Required?'                     = 'Gerekli?'
                'Position?'                     = 'Konum?'
                'Default value'                 = 'Varsayılan değer'
                'Accept pipeline input?'        = 'İşlem hattı girişi?'
                'Aliases'                       = 'Diğer adlar'
                'Accept wildcard characters?'   = 'Joker karakterler?'
                'Parameter set'                 = 'Parametre kümesi'
                # Values
                'Yes'                           = 'Evet'
                'No'                            = 'Hayır'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Özet sağlanmadı)*'
                '*(none)*'                      = '*(yok)*'
                'parameter'                     = 'parametre'
                # HTML labels
                'Show license'                  = 'Lisansı göster'
                'Expand description'            = 'Açıklamayı genişlet'
                # README page
                ' — Cmdlet Reference'           = ' — Cmdlet Başvurusu'
                'Auto-generated cmdlet reference documentation. ' = 'Otomatik oluşturulmuş cmdlet başvuru belgeleri. '
                'Last updated: '                = 'Son güncelleme: '
                # Meta line labels
                'Sub'                           = 'Alt Modül'
                'Module:'                       = 'Modül:'
                'Type:'                         = 'Tür:'
                'Aliases:'                      = 'Diğer adlar:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 joker karakterler'
                ' (hidden)'                     = ' (gizli)'
                'This parameter accepts all remaining arguments.' = 'Bu parametre kalan tüm argümanları kabul eder.'
            }
            'uk-UA' = @{
                # Section headers
                'Synopsis'                      = 'Короткий опис'
                'Description'                   = 'Опис'
                'License'                       = 'Ліцензія'
                'Syntax'                        = 'Синтаксис'
                'Parameters'                    = 'Параметри'
                'Examples'                      = 'Приклади'
                'Parameter Details'             = 'Відомості про параметр'
                'Outputs'                       = 'Вихідні дані'
                'Related Links'                 = 'Пов''язані посилання'
                # Column headers — parameters table
                'Name'                          = 'Ім''я'
                'Type'                          = 'Тип'
                'Required'                      = 'Обов''язковий'
                # Column headers — parameter details table
                'Property'                      = 'Властивість'
                'Value'                         = 'Значення'
                # Column headers — README table
                'Command'                       = 'Команда'
                # Row labels — parameter details
                'Required?'                     = 'Обов''язковий?'
                'Position?'                     = 'Позиція?'
                'Default value'                 = 'Значення за замовчуванням'
                'Accept pipeline input?'        = 'Вхід конвеєра?'
                'Aliases'                       = 'Псевдоніми'
                'Accept wildcard characters?'   = 'Символи підстановки?'
                'Parameter set'                 = 'Набір параметрів'
                # Values
                'Yes'                           = 'Так'
                'No'                            = 'Ні'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Короткий опис відсутній)*'
                '*(none)*'                      = '*(немає)*'
                'parameter'                     = 'параметр'
                # HTML labels
                'Show license'                  = 'Показати ліцензію'
                'Expand description'            = 'Розгорнути опис'
                # README page
                ' — Cmdlet Reference'           = ' — Довідка командлетів'
                'Auto-generated cmdlet reference documentation. ' = 'Автоматично створена довідкова документація командлетів. '
                'Last updated: '                = 'Останнє оновлення: '
                # Meta line labels
                'Sub'                           = 'Підмодуль'
                'Module:'                       = 'Модуль:'
                'Type:'                         = 'Тип:'
                'Aliases:'                      = 'Псевдоніми:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 символи підстановки'
                ' (hidden)'                     = ' (приховано)'
                'This parameter accepts all remaining arguments.' = 'Цей параметр приймає всі залишені аргументи.'
            }
            'vi-VN' = @{
                # Section headers
                'Synopsis'                      = 'Tóm tắt'
                'Description'                   = 'Mô tả'
                'License'                       = 'Giấy phép'
                'Syntax'                        = 'Cú pháp'
                'Parameters'                    = 'Tham số'
                'Examples'                      = 'Ví dụ'
                'Parameter Details'             = 'Chi tiết tham số'
                'Outputs'                       = 'Đầu ra'
                'Related Links'                 = 'Liên kết liên quan'
                # Column headers — parameters table
                'Name'                          = 'Tên'
                'Type'                          = 'Loại'
                'Required'                      = 'Bắt buộc'
                # Column headers — parameter details table
                'Property'                      = 'Thuộc tính'
                'Value'                         = 'Giá trị'
                # Column headers — README table
                'Command'                       = 'Lệnh'
                # Row labels — parameter details
                'Required?'                     = 'Bắt buộc?'
                'Position?'                     = 'Vị trí?'
                'Default value'                 = 'Giá trị mặc định'
                'Accept pipeline input?'        = 'Đầu vào pipeline?'
                'Aliases'                       = 'Bí danh'
                'Accept wildcard characters?'   = 'Ký tự đại diện?'
                'Parameter set'                 = 'Bộ tham số'
                # Values
                'Yes'                           = 'Có'
                'No'                            = 'Không'
                # Fallback text
                '*(No synopsis provided)*'      = '*(Không có tóm tắt)*'
                '*(none)*'                      = '*(không có)*'
                'parameter'                     = 'tham số'
                # HTML labels
                'Show license'                  = 'Hiển thị giấy phép'
                'Expand description'            = 'Mở rộng mô tả'
                # README page
                ' — Cmdlet Reference'           = ' — Tham khảo Cmdlet'
                'Auto-generated cmdlet reference documentation. ' = 'Tài liệu tham khảo cmdlet được tạo tự động. '
                'Last updated: '                = 'Cập nhật lần cuối: '
                # Meta line labels
                'Sub'                           = 'Mô-đun con'
                'Module:'                       = 'Mô-đun:'
                'Type:'                         = 'Loại:'
                'Aliases:'                      = 'Bí danh:'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 ký tự đại diện'
                ' (hidden)'                     = ' (ẩn)'
                'This parameter accepts all remaining arguments.' = 'Tham số này chấp nhận tất cả các đối số còn lại.'
            }
            'zh-Hans-CN' = @{
                # Section headers
                'Synopsis'                      = '摘要'
                'Description'                   = '说明'
                'License'                       = '许可证'
                'Syntax'                        = '语法'
                'Parameters'                    = '参数'
                'Examples'                      = '示例'
                'Parameter Details'             = '参数详情'
                'Outputs'                       = '输出'
                'Related Links'                 = '相关链接'
                # Column headers — parameters table
                'Name'                          = '名称'
                'Type'                          = '类型'
                'Required'                      = '必需'
                # Column headers — parameter details table
                'Property'                      = '属性'
                'Value'                         = '值'
                # Column headers — README table
                'Command'                       = '命令'
                # Row labels — parameter details
                'Required?'                     = '必需？'
                'Position?'                     = '位置？'
                'Default value'                 = '默认值'
                'Accept pipeline input?'        = '管道输入？'
                'Aliases'                       = '别名'
                'Accept wildcard characters?'   = '通配符？'
                'Parameter set'                 = '参数集'
                # Values
                'Yes'                           = '是'
                'No'                            = '否'
                # Fallback text
                '*(No synopsis provided)*'      = '*（未提供摘要）*'
                '*(none)*'                      = '*（无）*'
                'parameter'                     = '参数'
                # HTML labels
                'Show license'                  = '显示许可证'
                'Expand description'            = '展开说明'
                # README page
                ' — Cmdlet Reference'           = ' — Cmdlet 参考'
                'Auto-generated cmdlet reference documentation. ' = '自动生成的 Cmdlet 参考文档。 '
                'Last updated: '                = '最后更新： '
                # Meta line labels
                'Sub'                           = '子模块'
                'Module:'                       = '模块：'
                'Type:'                         = '类型：'
                'Aliases:'                      = '别名：'
                # Appended notes
                ' 🌐 wildcards'                  = ' 🌐 通配符'
                ' (hidden)'                     = ' （隐藏）'
                'This parameter accepts all remaining arguments.' = '此参数接受所有剩余参数。'
            }
        }

        # Pre-populate with English defaults — always available as fallback.
        $markdownLabels = @{
            # Section headers
            'Synopsis'                             = 'Synopsis'
            'Description'                          = 'Description'
            'License'                              = 'License'
            'Syntax'                               = 'Syntax'
            'Parameters'                           = 'Parameters'
            'Examples'                             = 'Examples'
            'Parameter Details'                    = 'Parameter Details'
            'Outputs'                              = 'Outputs'
            'Related Links'                        = 'Related Links'
            # Column headers — parameters table
            'Name'                                 = 'Name'
            'Type'                                 = 'Type'
            'Required'                             = 'Required'
            # Column headers — parameter details table
            'Property'                             = 'Property'
            'Value'                                = 'Value'
            # Column headers — README table
            'Command'                              = 'Command'
            # Row labels — parameter details
            'Required?'                            = 'Required?'
            'Position?'                            = 'Position?'
            'Default value'                        = 'Default value'
            'Accept pipeline input?'               = 'Accept pipeline input?'
            'Aliases'                              = 'Aliases'
            'Accept wildcard characters?'          = 'Accept wildcard characters?'
            'Parameter set'                        = 'Parameter set'
            # Values
            'Yes'                                  = 'Yes'
            'No'                                   = 'No'
            # Fallback text
            '*(No synopsis provided)*'             = '*(No synopsis provided)*'
            '*(none)*'                             = '*(none)*'
            'parameter'                            = 'parameter'
            # HTML labels
            'Show license'                         = 'Show license'
            'Expand description'                   = 'Expand description'
            # README page
            ' — Cmdlet Reference'                  = ' — Cmdlet Reference'
            'Auto-generated cmdlet reference documentation. ' = 'Auto-generated cmdlet reference documentation. '
            'Last updated: '                       = 'Last updated: '
            # Meta line labels
            'Sub'                                  = 'Sub'
            'Module:'                              = 'Module:'
            'Type:'                                = 'Type:'
            'Aliases:'                             = 'Aliases:'
            # Appended notes
            ' 🌐 wildcards'                        = ' 🌐 wildcards'
            ' (hidden)'                            = ' (hidden)'
            'This parameter accepts all remaining arguments.' = 'This parameter accepts all remaining arguments.'
        }

        # Translate all labels when not skipped and not English.
        if (-not $SkipTranslation -and $Language -ne 'en-US') {
            if ($hardcodedLabelTranslations.ContainsKey($Language)) {
                # Use hardcoded translations for known languages.
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Using hardcoded markdown UI labels for '${Language}'...")
                $langDict = $hardcodedLabelTranslations[$Language]
                foreach ($key in @($markdownLabels.Keys)) {
                    if ($langDict.ContainsKey($key)) {
                        $markdownLabels[$key] = $langDict[$key]
                    }
                }
            }
            else {
                # Fall back to LLM translation for unknown languages.
                Microsoft.PowerShell.Utility\Write-Verbose (
                    'Translating markdown UI labels via LLM...')
                $labelKeys = @($markdownLabels.Keys)
                foreach ($labelKey in $labelKeys) {
                    $translated = GenXdev\Get-TextTranslation @transParams `
                        -Text $labelKey
                    if ($translated) {
                        $markdownLabels[$labelKey] = $translated
                    }
                }
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Translated $($labelKeys.Count) markdown UI labels.")
            }
        }
    }

    process {
        # -- Collect metadata for all cmdlets --------------------------------
        if (-not $PSCmdlet.ShouldProcess(
                $ModuleName,
                'Retrieve cmdlet metadata for all cmdlets')) {
            return
        }

        try {
            $cmdletMetaData = @(GenXdev\Get-ModuleCmdletMetaData `
                    @metaModuleParams -ErrorAction Stop)
        }
        catch {
            Microsoft.PowerShell.Utility\Write-Error (
                "Failed to get metadata for module '${ModuleName}': $_")
            return
        }

        if ($cmdletMetaData.Count -eq 0) {
            Microsoft.PowerShell.Utility\Write-Warning (
                "No cmdlet metadata retrieved for '${ModuleName}'.")
            return
        }

        $cmdletMetaDataList = `
            [System.Collections.Generic.List[hashtable]]::new()
        foreach ($meta in $cmdletMetaData) {
            $null = $cmdletMetaDataList.Add($meta)
        }

        Microsoft.PowerShell.Utility\Write-Verbose (
            "Retrieved metadata for $($cmdletMetaDataList.Count) " +
            'cmdlet(s).')

        # -- Phase 1: Generate per-cmdlet .md files --------------------------
        $relativeLinkMap = @{}

        # Pass 1: collect all cmdlet metadata into the link map (no
        # rendering yet) so that each cmdlet can reference all its siblings.
        $i = 0;
        foreach ($meta in $cmdletMetaDataList) {

            Microsoft.PowerShell.Utility\Write-Progress -Id 426 -Activity "Generating Markdown Help" -Status "Processing $($meta.CmdletName)" -PercentComplete ([math]::Round((($i + 1) / $cmdletMetaDataList.Count) * 100, 2))
            $i++;

            $cmdletName = if ($meta['CmdletName']) {
                $meta['CmdletName']
            }
            elseif ($meta['Definition']) {
                ($meta['Definition'] -split '\s+')[0]
            }
            else {
                ''
            }

            if ([string]::IsNullOrWhiteSpace($cmdletName)) {
                continue
            }

            # Store for README linking.
            $subModule = if ($meta.ContainsKey('SubModuleName')) {
                $meta['SubModuleName']
            }
            else { $module.Name }

            if (-not $relativeLinkMap.ContainsKey($subModule)) {
                $relativeLinkMap[$subModule] = `
                    [System.Collections.Generic.List[hashtable]]::new()
            }

            $null = $relativeLinkMap[$subModule].Add(@{
                    Name     = $cmdletName
                    Synopsis = $meta['Synopsis']
                    Aliases  = $meta['Aliases']
                })
        }

        # Pass 2: render each cmdlet, now that sibling lists are complete.
        foreach ($meta in $cmdletMetaDataList) {
            $cmdletName = if ($meta['CmdletName']) {
                $meta['CmdletName']
            }
            elseif ($meta['Definition']) {
                ($meta['Definition'] -split '\s+')[0]
            }
            else {
                ''
            }

            if ([string]::IsNullOrWhiteSpace($cmdletName)) {
                continue
            }

            $mdFilePath = [System.IO.Path]::Combine(
                $docsDir, "${cmdletName}.md")

            $subModule = if ($meta.ContainsKey('SubModuleName')) {
                $meta['SubModuleName']
            }
            else { $module.Name }

            # Build sibling cmdlets list (all cmdlets in same submodule
            # except the current one).
            $siblingCmdlets = if ($relativeLinkMap.ContainsKey($subModule)) {
                @($relativeLinkMap[$subModule] |
                        Microsoft.PowerShell.Core\Where-Object { $_['Name'] -ne $cmdletName })
            }
            else { @() }

            # Skip if file exists and -Force not specified.
            if (-not $Force -and [System.IO.File]::Exists($mdFilePath)) {
                Microsoft.PowerShell.Utility\Write-Verbose (
                    "Skipping existing file: ${mdFilePath} " +
                    '(use -Force to overwrite)')
                $null = $generatedFiles.Add($mdFilePath)
                continue
            }

            if (-not $PSCmdlet.ShouldProcess(
                    $cmdletName,
                    "Generate ${cmdletName}.md")) {
                continue
            }

            $markdown = RenderCmdletMarkdown -Meta $meta `
                -ModuleName ($module.Name) `
                -SubModuleName $subModule `
                -SiblingCmdlets $siblingCmdlets `
                -LinkPrefix $LinkPrefix

            [System.IO.File]::WriteAllText($mdFilePath, $markdown)
            $null = $generatedFiles.Add($mdFilePath)

            Microsoft.PowerShell.Utility\Write-Verbose (
                "Wrote: ${cmdletName}.md")
        }

        # -- Phase 2: Generate README.md index -------------------------------
        $readmePath = [System.IO.Path]::Combine($docsDir, 'README.md')

        if (-not $Force -and [System.IO.File]::Exists($readmePath)) {
            Microsoft.PowerShell.Utility\Write-Verbose (
                'Skipping existing README.md (use -Force to overwrite)')
        }
        elseif ($PSCmdlet.ShouldProcess(
                'README.md',
                'Generate module README index')) {

            $readmeMarkdown = RenderReadmeIndex `
                -ModuleName $module.Name `
                -LinkMap $relativeLinkMap `
                -LinkPrefix $LinkPrefix

            [System.IO.File]::WriteAllText($readmePath, $readmeMarkdown)
            $null = $generatedFiles.Add($readmePath)

            Microsoft.PowerShell.Utility\Write-Verbose (
                'Wrote: README.md')
        }

        if ($generatedFiles.Count -gt 0) { Microsoft.PowerShell.Management\Get-ChildItem $generatedFiles }
    }

    end {
        Microsoft.PowerShell.Utility\Write-Progress -Id 426 -Completed
    }

}