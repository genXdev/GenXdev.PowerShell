@{
    Severity              = @('Warning')
    IncludeRules          = @(
        'PSUseFullyQualifiedCmdletNames',
        'PSAvoidDefaultValueSwitchParameter',
        'PSAvoidUsingCmdletAliases',
        'PSAvoidAssignmentToAutomaticVariable',
        'PSAvoidDefaultValueForMandatoryParameter',
        'PSAvoidExclaimOperator',
        'PSAvoidGlobalAliases',
        'PSAvoidGlobalFunctions',
        'PSAvoidGlobalVars',
        'PSAvoidLongLines',
        'PSAvoidNullOrEmptyHelpMessageAttribute',
        'PSAvoidOverwritingBuiltInCmdlets',
        'PSReservedCmdletChar',
        'PSReservedParams',
        'PSAvoidSemicolonsAsLineTerminators',
        'PSAvoidShouldContinueWithoutForce',
        'PSAvoidTrailingWhitespace',
        'PSAvoidUsingDeprecatedManifestFields',
        'PSAvoidUsingDoubleQuotesForConstantString',
        'PSMisleadingBacktick',
        'PSMissingModuleManifestField',
        'PSPlaceOpenBrace',
        'PSPossibleIncorrectComparisonWithNull',
        'PSPossibleIncorrectUsageOfAssignmentOperator',
        'PSPossibleIncorrectUsageOfRedirectionOperator',
        'PSUseApprovedVerbs',
        'PSUseCmdletCorrectly',
        'PSUseCompatibleCmdlets',
        'PSUseConsistentIndentation',
        'PSUseConsistentWhitespace',
        'PSUseDeclaredVarsMoreThanAssignments',
        'PSUseLiteralInitializerForHashtable',
        'PSUseOutputTypeCorrectly',
        'PSUseProcessBlockForPipelineCommand',
        'PSShouldProcess',
        'PSUseShouldProcessForStateChangingFunctions',
        'PSUseSingularNouns',
        'PSUseSupportsShouldProcess',
        'PSUseToExportFieldsInManifest',
        'PSUseUsingScopeModifierInNewRunspaces'
    )
    ExcludeRules          = @(
        'PSUseCorrectCasing',
        'PSUseCompatibleCommands',
        'PSAlignAssignmentStatement',
        'PSAvoidUsingEmptyCatchBlock',
        'PSReviewUnusedParameter',
        'PSAvoidInvokingEmptyMembers',
        'PSAvoidMultipleTypeAttributes',
        'PSAvoidUsingPositionalParameters',
        'PSUseBOMForUnicodeEncodedFile',
        'PSAvoidUsingUsernameAndPasswordParams',
        'PSAvoidUsingAllowUnencryptedAuthentication',
        'PSAvoidUsingBrokenHashAlgorithms',
        'PSAvoidUsingComputerNameHardcoded',
        'PSAvoidUsingConvertToSecureStringWithPlainText',
        'PSAvoidUsingInvokeExpression',
        'PSAvoidUsingPlainTextForPassword',
        'PSAvoidUsingWMICmdlet',
        'PSAvoidUsingWriteHost',
        'PSUseCompatibleSyntax',
        'PSUseCompatibleTypes',
        'PSPlaceCloseBrace',
        'PSProvideCommentHelp',
        'PSUsePSCredentialType',
        'PSUseUTF8EncodingForHelpFile',
        'PSDSCDscExamplesPresent',
        'PSDSCDscTestsPresent',
        'PSDSCReturnCorrectTypesForDSCFunctions',
        'PSDSCUseIdenticalMandatoryParametersForDSC',
        'PSDSCUseIdenticalParametersForDSC',
        'PSDSCStandardDSCFunctionsInResource',
        'PSDSCUseVerboseMessageInDSCResource'
    )
    IncludeDefaultRules   = $true
    RecurseCustomRulePath = $false
    CustomRulePath        = @(
        # "~\Documents\PowerShell\Modules\GenXdev.Coding\3.33.0\Assets\Modules\PSScriptAnalyzer\1.24.0\PSv7\GenXdev.Coding.PowerShell.Modules.ScriptAnalyzer.dll"
    )
    Rules = @{
        PSUseFullyQualifiedCmdletNames = @{
            Enabled  = $true
        }
        PSAvoidDefaultValueSwitchParameter = @{
            Enabled = $true
        }
        PSAvoidUsingCmdletAliases = @{
            Enabled = $true
        }
        PSAvoidAssignmentToAutomaticVariable = @{
            Enabled = $true
        }
        PSAvoidDefaultValueForMandatoryParameter = @{
            Enabled = $true
        }
        PSAvoidExclaimOperator = @{
            Enabled = $true
        }
        PSAvoidGlobalAliases = @{
            Enabled = $true
        }
        PSAvoidGlobalFunctions = @{
            Enabled = $true
        }
        PSAvoidGlobalVars = @{
            Enabled = $true
        }
        PSAvoidLongLines = @{
            Enabled = $true
        }
        PSAvoidNullOrEmptyHelpMessageAttribute = @{
            Enabled = $true
        }
        PSAvoidOverwritingBuiltInCmdlets = @{
            Enabled = $true
        }
        PSReservedCmdletChar = @{
            Enabled = $true
        }
        PSReservedParams = @{
            Enabled = $true
        }
        PSAvoidSemicolonsAsLineTerminators = @{
            Enabled = $true
        }
        PSAvoidShouldContinueWithoutForce = @{
            Enabled = $true
        }
        PSAvoidTrailingWhitespace = @{
            Enabled = $true
        }
        PSAvoidUsingDeprecatedManifestFields = @{
            Enabled = $true
        }
        PSAvoidUsingDoubleQuotesForConstantString = @{
            Enabled = $true
        }
        PSMisleadingBacktick = @{
            Enabled = $true
        }
        PSMissingModuleManifestField = @{
            Enabled = $true
        }
        PSPlaceOpenBrace = @{
            Enabled = $true
        }
        PSPossibleIncorrectComparisonWithNull = @{
            Enabled = $true
        }
        PSPossibleIncorrectUsageOfAssignmentOperator = @{
            Enabled = $true
        }
        PSPossibleIncorrectUsageOfRedirectionOperator = @{
            Enabled = $true
        }
        PSUseApprovedVerbs = @{
            Enabled = $true
        }
        PSUseCmdletCorrectly = @{
            Enabled = $true
        }
        PSUseCompatibleCmdlets = @{
            Enabled = $true
        }
        PSUseConsistentIndentation = @{
            Enabled = $true
        }
        PSUseConsistentWhitespace = @{
            Enabled = $true
        }
        PSUseDeclaredVarsMoreThanAssignments = @{
            Enabled = $true
        }
        PSUseLiteralInitializerForHashtable = @{
            Enabled = $true
        }
        PSUseOutputTypeCorrectly = @{
            Enabled = $true
        }
        PSUseProcessBlockForPipelineCommand = @{
            Enabled = $true
        }
        PSShouldProcess = @{
            Enabled = $true
        }
        PSUseShouldProcessForStateChangingFunctions = @{
            Enabled = $true
        }
        PSUseSingularNouns = @{
            Enabled = $true
        }
        PSUseSupportsShouldProcess = @{
            Enabled = $true
        }
        PSUseToExportFieldsInManifest = @{
            Enabled = $true
        }
        PSUseUsingScopeModifierInNewRunspaces = @{
            Enabled = $true
        }
    }
}