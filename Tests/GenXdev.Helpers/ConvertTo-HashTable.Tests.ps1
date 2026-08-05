Pester\Describe 'ConvertTo-HashTable function tests' {

    Pester\BeforeAll {

        $testObject = @(
            @{
                Name  = 'Test'
                Value = 123
                Sub   = @{

                    Name  = 'SubTest'
                    Value = 456
                }
            } | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress | Microsoft.PowerShell.Utility\ConvertFrom-Json
        )

        $testArray = @(
            @{

                Name  = 'Item1'
                Value = 1
            },
            @{

                Name  = 'Item2'
                Value = 2
            }
        ) | Microsoft.PowerShell.Utility\ConvertTo-Json -Compress | Microsoft.PowerShell.Utility\ConvertFrom-Json
    }

    Pester\Context 'Basic functionality' {

        Pester\It 'Should convert PSCustomObject to HashTable' {

            # convert test object to hashtable
            $result = GenXdev\ConvertTo-HashTable -InputObject $testObject

            # verify result is hashtable
            $result | Pester\Should -BeOfType [System.Collections.Hashtable]

            # verify properties are correctly converted
            $result.Name | Pester\Should -Be 'Test'
            $result.Value | Pester\Should -Be 123
        }

        Pester\It 'Should convert array of PSCustomObjects to array of HashTables' {

            # convert test array to hashtable array
            $result = GenXdev\ConvertTo-HashTable -InputObject $testArray

            # verify result is array
            $result | Pester\Should -BeOfType [System.Collections.IEnumerable]

            # verify array items are hashtables
            $result[0] | Pester\Should -BeOfType [System.Collections.Hashtable]
            $result[1] | Pester\Should -BeOfType [System.Collections.Hashtable]

            # verify properties are correctly converted
            $result[0].Name | Pester\Should -Be 'Item1'
            $result[0].Value | Pester\Should -Be 1
            $result[1].Name | Pester\Should -Be 'Item2'
            $result[1].Value | Pester\Should -Be 2
        }
    }

    Pester\Context 'Pipeline input' {

        Pester\It 'Should accept pipeline input' {

            # test pipeline input
            $result = $testObject | GenXdev\ConvertTo-HashTable

            # verify result
            $result | Pester\Should -BeOfType [System.Collections.Hashtable]
            $result.Name | Pester\Should -Be 'Test'
        }
    }

    Pester\Context 'Cloning' {

        Pester\It 'Should accept pipeline input' {

            $a = @{'mies' = @(123, 345) }
            $c = $a | GenXdev\ConvertTo-HashTable
            $c.getType().FullName | Pester\Should -Be "System.Collections.Hashtable"
            $c.mies[1] = 678;
            $a.mies[1] | Pester\Should -Be 345
        }
    }

    Pester\Context 'Null handling' {

        Pester\It 'Should preserve null properties from PSCustomObject' {
            $obj = [PSCustomObject]@{
                Name   = 'Test'
                ApiKey = $null
            }
            $result = GenXdev\ConvertTo-HashTable -InputObject $obj
            $result | Pester\Should -BeOfType [System.Collections.Hashtable]
            $result.Name | Pester\Should -Be 'Test'
            $result.ApiKey | Pester\Should -Be $null
        }

        Pester\It 'Should preserve JSON null values as null (not empty hashtable)' {
            $json = '{"Model":"gemini","ApiKey":null,"Count":0}' |
                Microsoft.PowerShell.Utility\ConvertFrom-Json
            $result = GenXdev\ConvertTo-HashTable -InputObject $json
            $result | Pester\Should -BeOfType [System.Collections.Hashtable]
            $result.Model | Pester\Should -Be 'gemini'
            $result.ApiKey | Pester\Should -Be $null
            $result.Count | Pester\Should -Be 0
        }

        Pester\It 'Should preserve JSON null values in arrays' {
            $json = '[{"Name":"a","Key":null},{"Name":"b","Key":"val"}]' |
                Microsoft.PowerShell.Utility\ConvertFrom-Json
            $result = GenXdev\ConvertTo-HashTable -InputObject $json
            $result.Count | Pester\Should -Be 2
            $result[0].Key | Pester\Should -Be $null
            $result[1].Key | Pester\Should -Be 'val'
        }
    }
}

###############################################################################