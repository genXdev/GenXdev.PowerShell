###############################################################################
# Part of PowerShell module : GenXdev.AI
# Original cmdlet filename  : Invoke-AILLMSettingsPrompt.Tests.ps1
# Original author           : René Vaessen / GenXdev
# Version                   : 3.33.0
###############################################################################

Pester\Describe 'Invoke-AILLMSettingsPrompt' {

    Pester\BeforeEach {

        GenXdev\Set-GenXdevPreferencesDatabasePath (GenXdev\Expand-Path "$($ENV:TEMP)\$((GenXdev\UtcNow).Ticks)" -CreateDirectory)

        $script:testRoot = GenXdev\Expand-Path (
            [System.IO.Path]::GetTempPath() +
            "\$([DateTime]::UtcNow.Ticks.ToString())\") -CreateDirectory
        $script:testDbDir = GenXdev\Expand-Path "$($script:testRoot)prefs\" -CreateDirectory
        $script:testDbPath = "$($script:testDbDir)GenXdev-test.db"

        # Clear all 6 LLM query types' session variables first, so that
        # leftover state from Get-AILLMSettings / Set-AILLMSettings tests
        # (which may run before us in a full test suite) does not cause
        # Get-AILLMSettings inside Invoke-AILLMSettingsPrompt to resolve
        # through different code-paths than when run in isolation.
        $allTypes = @(
            'SimpleIntelligence', 'Knowledge', 'Pictures',
            'TextTranslation', 'Coding', 'ToolUse'
        )
        foreach ($type in $allTypes) {
            $null = GenXdev\Set-AILLMSettings -LLMQueryType $type `
                -ClearSession
        }

        # Explicitly pre-configure all 6 LLM query types in the temp
        # preferences DB with non-null ApiKeys.  This guarantees that
        # Get-AILLMSettings always succeeds directly via the preference
        # lookup path and never falls through to cross-type-fallback or
        # auto-prompt — even when the real %LOCALAPPDATA% store (read
        # by ShowCurrentSettings / Get-AnyConfiguredLLMQueryType) has
        # leftover entries from Get-AILLMSettings or Set-AILLMSettings
        # tests that ran earlier in the same module suite.
        foreach ($type in $allTypes) {
            $null = GenXdev\Set-AILLMSettings -LLMQueryType $type `
                -Model 'test-bootstrap-model' `
                -ApiEndpoint 'https://test-bootstrap.example.com/v1' `
                -ApiKey 'sk-test-bootstrap'
        }

        # reusable test provider for ConfigureViaProviderPick tests
        $script:testProvider = @{
            DisplayName             = 'TestCorp LLM v1'
            Provider                = 'TestCorp'
            Model                   = 'test-model-v1'
            ApiEndpoint             = 'https://test.example.com/v1'
            NoSupportForJsonSchema  = $false
            NoSupportForImageUpload = $false
            NoSupportForToolCalls   = $false
        }
    }

    Pester\AfterEach {
        GenXdev\Remove-AllItems -Confirm:$False $script:testRoot `
            -DeleteFolder -ErrorAction SilentlyContinue
        GenXdev\Remove-AllItems -Confirm:$false (GenXdev\Get-GenXdevPreferencesDatabasePath) -DeleteFolder
    }

    Pester\Context 'Check Pester detection' {

        Pester\It "should detect" {

            [PSGenXdevCmdlet]::IsRunningUnderPester() |
            Pester\Should-Be $true
        }
    }


    ###########################################################################
    # P7: Cancel at mode selection (LLMQueryType provided, cancel immediately)
    ###########################################################################
    Pester\Context 'Cancel at first opportunity' {

        Pester\BeforeEach {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
            }
        }

        Pester\It 'P7: Returns without error when user cancels at mode selection' {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Invoke-SpectrePrompt -MockWith { '.. Cancel' }
                Pester\Mock Invoke-SpectreAsk -MockWith { '' }
                Pester\Mock Invoke-SpectreConfirm -MockWith { $true }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # Type selection menu (no -LLMQueryType)
    ###########################################################################
    Pester\Context 'Type selection menu' {

        Pester\BeforeEach {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
            }
        }

        # P1: Cancel at type selection menu
        Pester\It 'P1: Cancel at type menu returns without error' {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Invoke-SpectrePrompt -MockWith { '.. Cancel' }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }

        # P2: Pick a single type, then cancel at mode selection
        Pester\It 'P2: Pick single type then cancel at mode returns without error' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'SimpleIntelligence', '.. Cancel' | Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { '' }
                Pester\Mock Invoke-SpectreConfirm -MockWith { $true }
            }

            try {
                GenXdev\Invoke-AILLMSettingsPrompt -ErrorAction Stop
            } catch {
                Microsoft.PowerShell.Utility\Write-Host "P2 CRASH: $($_.Exception.Message)"
                Microsoft.PowerShell.Utility\Write-Host "P2 STACK: $($_.ScriptStackTrace)"
                throw
            }
        }
    }

    ###########################################################################
    # ALL mode sub-menu
    ###########################################################################
    Pester\Context 'ALL mode sub-menu' {

        Pester\BeforeEach {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
            }
        }

        # P3: Type menu -> ALL -> Cancel at ALL sub-menu
        Pester\It 'P3: Cancel at ALL sub-menu returns without error' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'ALL', '.. Cancel' | Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }

        # P4: Type menu -> ALL -> Back -> then cancel at type menu
        Pester\It 'P4: Back from ALL sub-menu then cancel at type menu' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'ALL', '.. Back', '.. Cancel' | Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # ConfigureSingleType: Skip (P8)
    ###########################################################################
    Pester\Context 'ConfigureSingleType - Skip' {

        Pester\BeforeEach {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
            }
        }

        # P8: Mode menu -> Skip. Tested via multi-type: pick ALL->individual,
        # then skip each type. Since ALL means 6 types, skipping all 6
        # should complete without error.
        Pester\It 'P8: Skip all types in multi-type mode completes without error' {
            $responses = @('ALL', 'Configure each type individually')
            $responses += @('.. Skip this type (keep current settings)') * 6
            $q = [System.Collections.Generic.Queue[string]]::new()
            $responses | Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # ConfigureViaProviderPick - no saved keys (P9 + P18)
    ###########################################################################
    Pester\Context 'ConfigureViaProviderPick - no saved keys' {

        Pester\BeforeEach {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
                Pester\Mock Get-AIDefaultLLMSettings -MockWith { , @($script:testProvider) }
                Pester\Mock Get-GenXdevPreferenceNames -MockWith { @() }
            }
        }

        # P9+P18: Pick provider -> no saved keys -> enter name + key -> save
        Pester\It 'P9+P18: Pick provider with no saved keys configures successfully' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'Pick a default provider (API key only)', 'TestCorp LLM v1' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'TestKey', 'sk-test-provider-key' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # ConfigureViaManualEntry - no saved keys (P10 + P23)
    ###########################################################################
    Pester\Context 'ConfigureViaManualEntry - no saved keys' {

        Pester\BeforeEach {
            $script:hintProvider = @{
                DisplayName = 'HintProvider'
                Provider    = 'CustomCorp'
                Model       = 'hint-model'
                ApiEndpoint = 'https://custom.example.com/v1'
            }
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:hintProvider) }
            }
        }

        # P10+P23: Manual entry -> no saved keys -> enter all fields -> save
        Pester\It 'P10+P23: Manual entry with no saved keys configures successfully' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'Enter all settings manually' | Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'my-custom-model', 'https://my-api.example.com/v1',
            'WorkKey', 'sk-manual-entry-key' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
                Pester\Mock Invoke-SpectreConfirm -MockWith { $true }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType Knowledge `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }

        # Capabilities set to $false
        Pester\It 'P10: Manual entry with all capabilities disabled saves correctly' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'Enter all settings manually' | Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'basic-model', 'https://basic.example.com/v1',
            'BasicKey', 'sk-basic' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
                Pester\Mock Invoke-SpectreConfirm -MockWith { $false }
                Pester\Mock Get-GenXdevPreferenceNames -MockWith { @() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType TextTranslation `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # ConfigureViaProviderPick - with saved keys (P16, P17)
    ###########################################################################
    Pester\Context 'ConfigureViaProviderPick - with saved keys' {

        Pester\BeforeEach {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
                Pester\Mock Get-AIDefaultLLMSettings -MockWith { , @($script:testProvider) }
            }
        }

        # P16: Pick provider -> choose saved key
        Pester\It 'P16: Use saved key from provider pick configures successfully' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'Pick a default provider (API key only)',
            'TestCorp LLM v1', 'Use saved key: Work' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-GenXdevPreferenceNames `
                    -MockWith { @('AILLMProviderApiKey_TestCorp_Work') }
                Pester\Mock Get-GenXdevPreference `
                    -MockWith { 'sk-saved-testcorp-key' }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType ToolUse `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }

        # P17: Pick provider -> has saved keys -> choose "Enter a new API key"
        Pester\It 'P17: Enter new key from saved-key menu in provider pick' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'Pick a default provider (API key only)',
            'TestCorp LLM v1', 'Enter a new API key' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'Home', 'sk-new-home-key' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-GenXdevPreferenceNames `
                    -MockWith { @('AILLMProviderApiKey_TestCorp_Work') }
                Pester\Mock Get-GenXdevPreference `
                    -MockWith { 'sk-saved-testcorp-key' }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # Cancel in sub-menus (P11, P14, P19)
    ###########################################################################
    Pester\Context 'Cancel in sub-menus' {

        Pester\BeforeEach {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
                Pester\Mock Invoke-SpectreAsk -MockWith { '' }
                Pester\Mock Invoke-SpectreConfirm -MockWith { $true }
            }
        }

        # P11: Cancel at provider selection
        Pester\It 'P11: Cancel at provider selection returns without error' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'Pick a default provider (API key only)', '.. Cancel' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }

        # P14: Pick provider -> has saved keys -> Cancel at key menu
        Pester\It 'P14: Cancel at saved key menu in provider pick' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'Pick a default provider (API key only)',
            'TestCorp LLM v1', '.. Cancel' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Get-GenXdevPreferenceNames `
                    -MockWith { @('AILLMProviderApiKey_TestCorp_Work') }
                Pester\Mock Get-GenXdevPreference -MockWith { 'sk-saved' }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }

        # P19: Manual entry -> has saved keys -> Cancel at key menu
        Pester\It 'P19: Cancel at saved key menu in manual entry' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'Enter all settings manually', '.. Cancel' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'my-model', 'https://custom.example.com/v1' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Get-GenXdevPreferenceNames `
                    -MockWith { @('AILLMProviderApiKey_Custom_Work') }
                Pester\Mock Get-GenXdevPreference -MockWith { 'sk-saved' }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # Multi-type shortcut (P6, P24)
    ###########################################################################
    Pester\Context 'Multi-type shortcut' {

        # P6: ALL -> individual -> shortcut "Yes" -> apply to remaining
        Pester\It 'P6: ALL individually then shortcut Yes applies to remaining' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'ALL', 'Configure each type individually',
            'Pick a default provider (API key only)',
            'TestCorp LLM v1', 'Yes, apply to all remaining types' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            'Key1', 'sk-first-type-key' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Get-GenXdevPreferenceNames -MockWith { @() }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
                Pester\Mock Get-AILLMSettings -MockWith {
                    return @{
                        Model                   = 'gpt-4o'
                        ApiEndpoint             = 'https://api.openai.com/v1'
                        ApiKey                  = 'sk-shortcut-test'
                        NoSupportForJsonSchema  = $false
                        NoSupportForImageUpload = $false
                        NoSupportForToolCalls   = $false
                    }
                }
                Pester\Mock Set-AILLMSettings -MockWith {}
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }

        # P24: ALL -> individual -> shortcut -> Cancel (partial save summary)
        Pester\It 'P24: Shortcut cancel shows partial save summary without error' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'ALL', 'Configure each type individually',
            'Pick a default provider (API key only)',
            'TestCorp LLM v1', '.. Cancel' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            'Key1', 'sk-partial-key' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Get-GenXdevPreferenceNames -MockWith { @() }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
                Pester\Mock Get-AILLMSettings -MockWith {
                    return @{
                        Model                   = 'gpt-4o'
                        ApiEndpoint             = 'https://api.openai.com/v1'
                        ApiKey                  = 'sk-shortcut-test'
                        NoSupportForJsonSchema  = $false
                        NoSupportForImageUpload = $false
                        NoSupportForToolCalls   = $false
                    }
                }
                Pester\Mock Set-AILLMSettings -MockWith {}
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # ConfigureViaManualEntry - with saved keys (P21, P22)
    ###########################################################################
    Pester\Context 'ConfigureViaManualEntry - with saved keys' {

        Pester\BeforeEach {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
                Pester\Mock Invoke-SpectreConfirm -MockWith { $true }
            }
        }

        # P21: Manual entry -> has saved keys -> use saved key
        Pester\It 'P21: Use saved key in manual entry configures successfully' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'Enter all settings manually', 'Use saved key: Work' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            'my-model', 'https://custom.example.com/v1' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Get-GenXdevPreferenceNames `
                    -MockWith { @('AILLMProviderApiKey_Custom_Work') }
                Pester\Mock Get-GenXdevPreference -MockWith { 'sk-custom-saved' }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }

        # P22: Manual entry -> has saved keys -> enter new key
        Pester\It 'P22: Enter new key from saved-key menu in manual entry' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'Enter all settings manually', 'Enter a new API key' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            'v2-model', 'https://custom.example.com/v2',
            'NewKey', 'sk-new-custom' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Get-GenXdevPreferenceNames `
                    -MockWith { @('AILLMProviderApiKey_Custom_Old') }
                Pester\Mock Get-GenXdevPreference -MockWith { 'sk-old' }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # Back navigation (P12, P15, P20)
    ###########################################################################
    Pester\Context 'Back navigation' {

        Pester\BeforeEach {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
                Pester\Mock Invoke-SpectreConfirm -MockWith { $true }
            }
        }

        # P12: Provider pick -> Back -> then cancel at mode menu
        Pester\It 'P12: Back from provider pick then cancel at mode menu' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'Pick a default provider (API key only)',
            '.. Back', '.. Cancel' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }

        # P15: Pick provider -> saved keys -> Back -> then cancel at provider menu
        Pester\It 'P15: Back from saved key menu in provider pick' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            'Pick a default provider (API key only)',
            'TestCorp LLM v1', '.. Back', '.. Cancel' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Get-GenXdevPreferenceNames `
                    -MockWith { @('AILLMProviderApiKey_TestCorp_Work') }
                Pester\Mock Get-GenXdevPreference -MockWith { 'sk-saved' }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }

        # P20: Manual entry -> saved keys -> Back -> then cancel at mode menu
        Pester\It 'P20: Back from saved key menu in manual entry' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'Enter all settings manually', '.. Back', '.. Cancel' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            'model1', 'https://custom.example.com/v1',
            'model1', 'https://custom.example.com/v1' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Get-GenXdevPreferenceNames `
                    -MockWith { @('AILLMProviderApiKey_Custom_Work') }
                Pester\Mock Get-GenXdevPreference -MockWith { 'sk-saved' }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt `
                    -LLMQueryType SimpleIntelligence `
                    -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # ALL -> Apply one provider to all types (P5)
    ###########################################################################
    Pester\Context 'ALL - Apply one provider to all types' {

        Pester\BeforeEach {
            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Write-SpectreLine -MockWith {}
                Pester\Mock Write-SpectreMarkupLine -MockWith {}
                Pester\Mock Get-AIDefaultLLMSettings `
                    -MockWith { , @($script:testProvider) }
                Pester\Mock Invoke-SpectreConfirm -MockWith { $true }
            }
        }

        # P5: ALL -> Apply one provider -> configure -> all 6 types saved
        Pester\It 'P5: Apply one provider to ALL types configures successfully' {
            $q = [System.Collections.Generic.Queue[string]]::new()
            $aq = [System.Collections.Generic.Queue[string]]::new()
            'ALL', 'Apply one provider to ALL types at once',
            'TestCorp LLM v1' |
                Microsoft.PowerShell.Core\ForEach-Object { $q.Enqueue($_) }
            'AllKey', 'sk-all-types' |
                Microsoft.PowerShell.Core\ForEach-Object { $aq.Enqueue($_) }

            Pester\InModuleScope 'GenXdev' {
                Pester\Mock Get-GenXdevPreferenceNames -MockWith { @() }
                Pester\Mock Invoke-SpectrePrompt -MockWith { $q.Dequeue() }
                Pester\Mock Invoke-SpectreAsk -MockWith { $aq.Dequeue() }
            }

            {
                GenXdev\Invoke-AILLMSettingsPrompt -ErrorAction Stop
            } | Pester\Should -Not -Throw
        }
    }

    ###########################################################################
    # NonInteractive guard (sanity check)
    ###########################################################################
    Pester\Context 'NonInteractive guard' {

        Pester\It 'Throws when -NonInteractive is specified' {
            {
                GenXdev\Invoke-AILLMSettingsPrompt -NonInteractive -ErrorAction Stop
            } | Pester\Should -Throw
        }
    }
}
###############################################################################