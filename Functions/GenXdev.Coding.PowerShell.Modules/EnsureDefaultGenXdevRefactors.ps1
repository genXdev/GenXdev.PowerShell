<#
.SYNOPSIS
Ensures default GenXdev refactoring definitions are available.

.DESCRIPTION
This function creates and maintains default refactoring definitions for GenXdev
PowerShell modules. It sets up refactors for documentation and formatting,
C# conversion, and installation consent prompts.

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

.PARAMETER Force
Forces recreation of existing refactor definitions.

.EXAMPLE
EnsureDefaultGenXdevRefactors

.EXAMPLE
EnsureDefaultGenXdevRefactors -Force
#>
function EnsureDefaultGenXdevRefactors {

    [CmdletBinding()]

    param
    (
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = "Forces recreation of existing refactor definitions"
        )]
        [switch] $Force,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to refactoring definitions ' +
                'and set persistent flag.')
        )]
        [switch] $AutoConsent,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Automatically consent to third-party software ' +
                'installation and set persistent flag for all packages.')
        )]
        [switch] $AutoConsentAllPackages,
        #######################################################################
        [Parameter(
            Mandatory = $false,
            HelpMessage = ('Only auto consent during session')
        )]
        [switch]$SessionOnly
        #######################################################################
    )

    begin {
    }

    process {

        # expand the root path to the workspace directory
        $rootPath = GenXdev\Expand-Path "$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\..\"

        # list of deprecated refactor names to remove
        $depricated = @("MissingDocumentation", "OnlyDocumentation", "TooManyParameters", "DocumentationAndFormatting", "DocumentationAndFormattingCSharp", "IncompleteDocumentationCSharp")

        # remove any deprecated refactors that still exist
        foreach ($name in $depricated) {

            # try to get the refactor object
            $obj = GenXdev\Get-Refactor -Name $name -ErrorAction SilentlyContinue

            # if the refactor exists, remove it
            if ($null -ne $obj) {

                # remove the deprecated refactor
                Microsoft.PowerShell.Utility\Write-Verbose "Removing deprecated refactor: ${name}"
                $null = GenXdev\Remove-Refactor -Name $obj.Name
            }
        }

        # Documentation refactor setup
        $obj = GenXdev\Get-Refactor -Name "Documentation" `
            -ErrorAction SilentlyContinue

        # if force is specified and refactor exists, remove it first
        if ($Force -and ($null -ne $obj)) {

            # remove existing refactor when force is used
            $null = GenXdev\Remove-Refactor -Name $obj.Name
            $obj = $null
        }

        # create the refactor if it doesn't exist
        if (-not $obj) {

            # create a refactor definition for recently modified files
            # this refactor will only include files that have been modified
            # in the last 7 days and will not prompt the user for any input.
            Microsoft.PowerShell.Utility\Write-Verbose "Creating Documentation refactor"
            $null = GenXdev\New-Refactor `
                -Name "Documentation" `
                -PromptKey "OnlyDocumentation" `
                -SelectionScript "GenXdev\Find-Item `"$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\GenXdev.*\3.34.0\functions\*.ps1`" -PassThru -Exclude `"*\_*`" | Sort-Object -property LastWriteTime" `
                -AutoAddModifiedFiles `
                -Priority 0
        }

        # DocumentationCSharp refactor setup
        $obj = GenXdev\Get-Refactor -Name "DocumentationCSharp" `
            -ErrorAction SilentlyContinue

        # if force is specified and refactor exists, remove it first
        if ($Force -and ($null -ne $obj)) {

            # remove existing refactor when force is used
            $null = GenXdev\Remove-Refactor -Name $obj.Name
            $obj = $null
        }

        # create the refactor if it doesn't exist
        if (-not $obj) {

            # create a refactor definition for recently modified files
            # this refactor will only include files that have been modified
            # in the last 7 days and will not prompt the user for any input.
            Microsoft.PowerShell.Utility\Write-Verbose "Creating DocumentationCSharp refactor"
            $null = GenXdev\New-Refactor `
                -Name "DocumentationCSharp" `
                -PromptKey "OnlyCSharpDocumentation" `
                -SelectionScript "GenXdev\Find-Item `"$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\GenXdev.*\3.34.0\functions\*.cs`" -PassThru -Exclude `"*\_*`" | Sort-Object -property LastWriteTime" `
                -AutoAddModifiedFiles `
                -Priority 0
        }
        ####

        # Documentation refactor setup
        $obj = GenXdev\Get-Refactor -Name "MissingDocumentation" `
            -ErrorAction SilentlyContinue

        # if force is specified and refactor exists, remove it first
        if ($Force -and ($null -ne $obj)) {

            # remove existing refactor when force is used
            $null = GenXdev\Remove-Refactor -Name $obj.Name
            $obj = $null
        }

        # create the refactor if it doesn't exist
        if (-not $obj) {

            # create a refactor definition for files missing synopsis
            # entirely — automatically wraps recently modified files
            Microsoft.PowerShell.Utility\Write-Verbose "Creating MissingDocumentation refactor"
            $null = GenXdev\New-Refactor `
                -Name "MissingDocumentation" `
                -PromptKey "OnlyDocumentation" `
                -SelectionScript "GenXdev\Find-Item `"$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\GenXdev.*\3.34.0\functions\*.ps1`" -PassThru -Exclude `"*\_*`" -Quiet -NotMatch -Content `"SYNOPSIS`" | Sort-Object -property LastWriteTime" `
                -AutoAddModifiedFiles `
                -Priority 2000
        }

        # DocumentationCSharp refactor setup
        $obj = GenXdev\Get-Refactor -Name "MissingDocumentationCSharp" `
            -ErrorAction SilentlyContinue

        # if force is specified and refactor exists, remove it first
        if ($Force -and ($null -ne $obj)) {

            # remove existing refactor when force is used
            $null = GenXdev\Remove-Refactor -Name $obj.Name
            $obj = $null
        }

        # create the refactor if it doesn't exist
        if (-not $obj) {

            # create a refactor definition for C# files missing synopsis
            # entirely — automatically wraps recently modified files
            Microsoft.PowerShell.Utility\Write-Verbose "Creating MissingDocumentationCSharp refactor"
            $null = GenXdev\New-Refactor `
                -Name "MissingDocumentationCSharp" `
                -PromptKey "OnlyCSharpDocumentation" `
                -SelectionScript "GenXdev\Find-Item `"$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\GenXdev.*\3.34.0\functions\*.cs`" -PassThru -Exclude `"*\_*`" -Quiet -NotMatch -Content `"SYNOPSIS`" | Sort-Object -property LastWriteTime" `
                -AutoAddModifiedFiles `
                -Priority 2000
        }

        ####
        # IncompleteDocumentation refactor — highest priority: cmdlets
        # (both .ps1 and C#) with missing Description, Synopsis, or
        # parameter HelpMessage, detected via Get-GenXDevCmdlet.
        $obj = GenXdev\Get-Refactor -Name "IncompleteDocumentation" `
            -ErrorAction SilentlyContinue

        if ($Force -and ($null -ne $obj)) {
            $null = GenXdev\Remove-Refactor -Name $obj.Name
            $obj = $null
        }

        if (-not $obj) {

            # Find cmdlets (Function + Cmdlet) with incomplete
            # documentation: missing Description, Synopsis, or
            # parameter HelpMessage.
            Microsoft.PowerShell.Utility\Write-Verbose "Creating IncompleteDocumentation refactor"
            $null = GenXdev\New-Refactor `
                -Name "IncompleteDocumentation" `
                -PromptKey "OnlyDocumentation" `
                -SelectionScript "GenXdev\Get-GenXDevCmdlet | Where-Object { [string]::IsNullOrWhitespace(`$_.Description) -or [string]::IsNullOrWhitespace(`$_.Synopsis) -or @(`$_.Parameters | Where-Object { [string]::IsNullOrWhitespace(`$_.HelpMessage) }).Count -gt 0 } | ForEach-Object { `$_.ScriptFilePath } | Where-Object { Test-Path `$_ } | ForEach-Object { Get-Item `$_ } | Sort-Object LastWriteTime" `
                -AutoAddModifiedFiles `
                -Priority 5000
        }

        ####
        # ConvertToCSharp refactor setup
        $obj = GenXdev\Get-Refactor -Name "ConvertToCSharp" -ErrorAction SilentlyContinue

        # if force is specified and refactor exists, remove it first
        if ($Force -and ($null -ne $obj)) {

            # remove existing refactor when force is used
            $null = GenXdev\Remove-Refactor -Name $obj.Name
            $obj = $null
        }

        # create the refactor if it doesn't exist
        if (-not $obj) {

            # create a refactor definition for all cmdlets prioritized for C# conversion
            # this refactor uses the cmdlet usage analysis to identify all functions
            # and prioritizes them for conversion to C# with most used first.
            Microsoft.PowerShell.Utility\Write-Verbose "Creating ConvertToCSharp refactor"
            $null = GenXdev\New-Refactor `
                -Name "ConvertToCSharp" `
                -PromptKey "ConvertToCSharp" `
                -SelectionScript "GenXdev\Find-Item `"$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\GenXdev.*\3.34.0\functions\*-*.ps1`" -PassThru -Exclude `"*\_*`", `"*Ensure*`" | ? { `$dir = [io.path]::GetDirectoryName(`$_); `$fn = [io.path]::GetFileNameWithoutExtension(`$_); if (-not (Test-Path -LiteralPath `"`$dir\`${fn}.cs`")) { if (-not ([IO.file]::ReadAllText(`$_).Contains('dontrefactor'))) { `$_ } } } | Sort-Object Length" `
                -AutoAddModifiedFiles:$false `
                -Priority 1000
        }

        # AddInstallationConsentPrompt refactor setup
        $obj = GenXdev\Get-Refactor -Name "AddInstallationConsentPrompt" `
            -ErrorAction SilentlyContinue

        # if force is specified and refactor exists, remove it first
        if ($Force -and ($null -ne $obj)) {

            # remove existing refactor when force is used
            $null = GenXdev\Remove-Refactor -Name $obj.Name
            $obj = $null
        }

        # create the refactor if it doesn't exist
        if (-not $obj) {

            # create a refactor definition for all cmdlets prioritized for C# conversion
            # this refactor uses the cmdlet usage analysis to identify all functions
            # and prioritizes them for conversion to C# with most used first.
            Microsoft.PowerShell.Utility\Write-Verbose "Creating AddInstallationConsentPrompt refactor"
            $null = GenXdev\New-Refactor `
                -Name "AddInstallationConsentPrompt" `
                -PromptKey "AddInstallationConsentPrompt" `
                -SelectionScript "GenXdev\Find-Item `"$rootPath\Modules\GenXdev.*\*.ps1`" 'winget' -PassThru -Quiet | Where-Object { -not (([IO.File]::ReadAllText(`$_.FullName)) | Select-String 'Confirm-InstallationConsent' -Quiet) }" `
                -AutoAddModifiedFiles:$false `
                -Priority 10
        }

        # CheckCSharpInvocations refactor setup
        $obj = GenXdev\Get-Refactor -Name "CheckCSharpInvocations" `
            -ErrorAction SilentlyContinue

        # if force is specified and refactor exists, remove it first
        if ($Force -and ($null -ne $obj)) {

            # remove existing refactor when force is used
            $null = GenXdev\Remove-Refactor -Name $obj.Name
            $obj = $null
        }

        # create the refactor if it doesn't exist
        if (-not $obj) {

            # create a refactor definition for C# files that may contain old script invocations
            # that should be replaced with base class methods from PSGenXdevCmdlet
            Microsoft.PowerShell.Utility\Write-Verbose "Creating CheckCSharpInvocations refactor"
            $null = GenXdev\New-Refactor `
                -Name "CheckCSharpInvocations" `
                -PromptKey "CheckCSharpInvocations" `
                -SelectionScript "GenXdev\Find-Item `"$($MyInvocation.MyCommand.Module.ModuleBase)\..\..\GenXdev.*\3.34.0\functions\*.cs`" -PassThru -Exclude `"*\_*`" -Quiet -Content 'Confirm-InstallationConsent|Get-Variable|Copy-IdenticalParamValues|Expand-Path|LOCALAPPDATA|\.\.\\\.\.\\|\\Scripts' | Sort-Object Length" `
                -AutoAddModifiedFiles:$false `
                -Priority 1500
        }

        # return all available refactors
        GenXdev\Get-Refactor
    }

    end {
    }
}
################################################################################