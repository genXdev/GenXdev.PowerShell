Pester\Describe 'Invoke-CommandFromToolCall cmdlet tests' {

    Pester\BeforeAll {
        # store test variables in script scope
        $Script:testFunctions = @(
            @{
                function = @{
                    name       = 'Get-Movies'
                    parameters = @{
                        required   = @('path')
                        properties = @{
                            path = @{ type = 'string' }
                        }
                    }
                    # fixed callback to return proper movie data
                    callback   = {
                        param($path)
                        return @{
                            movies = @(
                                'Movie1',
                                'Movie2'
                            )
                            path   = $path
                        } | Microsoft.PowerShell.Utility\ConvertTo-Json
                    }
                }
            }
        )

        $Script:testCmdlets = @(
            [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name          = 'Get-Movies'
                AllowedParams = @('path')
                Confirm       = $false
            }
        )

        $Script:testToolCall = @{
            function = @{
                name      = 'Get-Movies'
                arguments = '{"path":"B:\\"}'
            }
        }
    }

    Pester\It 'Should reject invalid parameters' {
        # create test call with invalid parameter
        $invalidCall = @{
            function = @{
                name      = 'Get-Movies'
                arguments = '{"invalidParam":"test"}'
            }
        }

        $result = GenXdev\Invoke-CommandFromToolCall `
            -ToolCall $invalidCall `
            -Functions $Script:testFunctions

        $result.CommandExposed | Pester\Should -Be $false
        $result.Reason | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It 'Should require confirmation by default' {
        # mock host UI for confirmation prompt
        Pester\Mock -CommandName 'Read-Host' -ModuleName 'GenXdev' -MockWith { return 'y' }

        $result = GenXdev\Invoke-CommandFromToolCall `
            -ToolCall $Script:testToolCall `
            -Functions $Script:testFunctions `
            -ExposedCmdLets $Script:testCmdlets

        $result.CommandExposed | Pester\Should -Be $true
        $result.Output | Pester\Should -Not -BeNullOrEmpty
    }

    Pester\It 'Should handle missing required parameters' {
        # create test call without required parameter
        $invalidCall = @{
            function = @{
                name      = 'Get-Movies'
                arguments = '{}'
            }
        }

        $result = GenXdev\Invoke-CommandFromToolCall `
            -ToolCall $invalidCall `
            -Functions $Script:testFunctions

        $result.CommandExposed | Pester\Should -Be $false
        $result.Reason | Pester\Should -BeLike '*Missing required parameter*'
    }

    Pester\It 'Should execute command with proper output format' {
        $result = GenXdev\Invoke-CommandFromToolCall `
            -ToolCall $Script:testToolCall `
            -Functions $Script:testFunctions `
            -ExposedCmdLets $Script:testCmdlets `
            -NoConfirmationToolFunctionNames @('Get-Movies')

        # verify successful execution
        $result.CommandExposed | Pester\Should -Be $true
        $result.Output | Pester\Should -Not -BeNullOrEmpty

        # parse and verify JSON output
        $jsonOutput = $result.Output | Microsoft.PowerShell.Utility\ConvertFrom-Json
        $jsonOutput.movies | Pester\Should -Not -BeNullOrEmpty
        $jsonOutput.movies.Count | Pester\Should -Be 2
        $jsonOutput.movies[0] | Pester\Should -Be 'Movie1'
        $jsonOutput.movies[1] | Pester\Should -Be 'Movie2'
        $jsonOutput.path | Pester\Should -Be 'B:\'
    }

    Pester\Describe 'Output streams' {

        Pester\BeforeAll {
            # callback that writes every diagnostic stream and returns an object
            $Script:streamFunctions = @(
                @{
                    function = @{
                        name       = 'Stream-Probe'
                        parameters = @{
                            required   = @()
                            properties = @{
                                IncludeAllOutputStreams = @{ type = 'boolean' }
                            }
                        }
                        callback   = {
                            Microsoft.PowerShell.Utility\Write-Information 'server said hi'
                            Microsoft.PowerShell.Utility\Write-Warning 'careful'
                            Microsoft.PowerShell.Utility\Write-Verbose 'detail'
                            [pscustomobject]@{ Id = 1 }
                        }
                    }
                }
            )

            # callback that writes a non terminating error and still returns output
            $Script:errorFunctions = @(
                @{
                    function = @{
                        name       = 'Stream-Probe'
                        parameters = @{
                            required   = @()
                            properties = @{
                                IncludeAllOutputStreams = @{ type = 'boolean' }
                            }
                        }
                        callback   = {
                            Microsoft.PowerShell.Utility\Write-Error 'boom'
                            'kept output'
                        }
                    }
                }
            )

            $Script:jsonCmdlet = [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name          = 'Stream-Probe'
                AllowedParams = @()
                Confirm       = $false
                OutputText    = $false
                JsonDepth     = 3
            }

            $Script:textCmdlet = [GenXdev.Helpers.ExposedCmdletDefinition]@{
                Name          = 'Stream-Probe'
                AllowedParams = @()
                Confirm       = $false
                OutputText    = $true
                JsonDepth     = 3
            }

            # invoke the probe with the given tool call arguments
            $Script:invokeProbe = {
                param([string] $ArgumentsJson, $ExposedCmdlet, $Functions)

                GenXdev\Invoke-CommandFromToolCall `
                    -ToolCall @{
                        function = @{
                            name      = 'Stream-Probe'
                            arguments = $ArgumentsJson
                        }
                    } `
                    -Functions $Functions `
                    -ExposedCmdLets @($ExposedCmdlet) `
                    -NoConfirmationToolFunctionNames @('Stream-Probe') |
                    Microsoft.PowerShell.Utility\Select-Object -First 1
            }
        }

        Pester\It 'Should always return errors, without the stream switch' {
            $result = & $Script:invokeProbe -ArgumentsJson '{}' `
                -ExposedCmdlet $Script:jsonCmdlet -Functions $Script:errorFunctions

            $result.Errors.Count | Pester\Should -Be 1
            $result.Errors[0] | Pester\Should -Be 'boom'
            $result.Information.Count | Pester\Should -Be 0
        }

        Pester\It 'Should leave the diagnostic streams empty without the switch' {
            $result = & $Script:invokeProbe -ArgumentsJson '{}' `
                -ExposedCmdlet $Script:jsonCmdlet -Functions $Script:streamFunctions

            $result.Information.Count | Pester\Should -Be 0
            $result.Warnings.Count | Pester\Should -Be 0
            $result.Verbose.Count | Pester\Should -Be 0
            $result.Errors.Count | Pester\Should -Be 0
        }

        Pester\It 'Should capture the diagnostic streams when the switch is set' {
            $result = & $Script:invokeProbe `
                -ArgumentsJson '{"IncludeAllOutputStreams":true}' `
                -ExposedCmdlet $Script:jsonCmdlet -Functions $Script:streamFunctions

            $result.Information[0] | Pester\Should -Be 'server said hi'
            $result.Warnings[0] | Pester\Should -Be 'careful'
            $result.Verbose[0] | Pester\Should -Be 'detail'
        }

        Pester\It 'Should consume the switch instead of passing it to the callback' {
            $result = & $Script:invokeProbe `
                -ArgumentsJson '{"IncludeAllOutputStreams":true}' `
                -ExposedCmdlet $Script:jsonCmdlet -Functions $Script:streamFunctions

            # a leaked switch would fail to bind and land in the errors
            $result.Errors.Count | Pester\Should -Be 0
            $result.FilteredArguments.ContainsKey(
                'IncludeAllOutputStreams') | Pester\Should -BeFalse
        }

        Pester\It 'Should not enable the streams for a textual false' {
            $result = & $Script:invokeProbe `
                -ArgumentsJson '{"IncludeAllOutputStreams":"false"}' `
                -ExposedCmdlet $Script:jsonCmdlet -Functions $Script:streamFunctions

            $result.Information.Count | Pester\Should -Be 0
            $result.Verbose.Count | Pester\Should -Be 0
        }

        Pester\It 'Should return json output with a named property per stream' {
            $result = & $Script:invokeProbe `
                -ArgumentsJson '{"IncludeAllOutputStreams":true}' `
                -ExposedCmdlet $Script:jsonCmdlet -Functions $Script:streamFunctions

            $wrapped = $result.Output | Microsoft.PowerShell.Utility\ConvertFrom-Json

            $wrapped.PSObject.Properties.Name | Pester\Should -Contain 'output'
            $wrapped.PSObject.Properties.Name | Pester\Should -Contain 'errors'
            $wrapped.PSObject.Properties.Name | Pester\Should -Contain 'warnings'
            $wrapped.PSObject.Properties.Name | Pester\Should -Contain 'information'
            $wrapped.PSObject.Properties.Name | Pester\Should -Contain 'verbose'
            $wrapped.information[0] | Pester\Should -Be 'server said hi'
            $wrapped.output.Id | Pester\Should -Be 1
        }

        Pester\It 'Should append labelled sections to text output' {
            $result = & $Script:invokeProbe `
                -ArgumentsJson '{"IncludeAllOutputStreams":true}' `
                -ExposedCmdlet $Script:textCmdlet -Functions $Script:streamFunctions

            $result.Output | Pester\Should -Match '--- INFORMATION ---'
            $result.Output | Pester\Should -Match 'server said hi'
            $result.Output | Pester\Should -Match '--- WARNINGS ---'
            $result.Output | Pester\Should -Match '--- VERBOSE ---'
        }
    }
}