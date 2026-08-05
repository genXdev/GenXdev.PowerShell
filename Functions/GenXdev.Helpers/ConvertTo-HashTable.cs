using System.Collections;
using System.Management.Automation;

namespace GenXdev.Helpers
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Converts a PSCustomObject to a HashTable recursively.
.DESCRIPTION
* This function converts a PSCustomObject and all its nested PSCustomObject
  properties into HashTables.
* It handles arrays and other collection types by processing each element
  recursively.

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
$object = [PSCustomObject]@{
    Name = ""John""
    Age = 30
    Details = [PSCustomObject]@{
        City = ""New York""
    }
}
$hashTable = ConvertTo-HashTable -InputObject $object
```

Convert a PSCustomObject to a HashTable with nested properties.
")]
    [Cmdlet(VerbsData.ConvertTo, "HashTable")]
    [OutputType(typeof(Hashtable), typeof(System.Collections.IEnumerable), typeof(System.ValueType), typeof(string))]
    public class ConvertToHashTableCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The PSCustomObject to convert into a HashTable
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            HelpMessage = "The PSCustomObject to convert into a HashTable"
        )]
        [ValidateNotNull]
        public object InputObject { get; set; }

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            //WriteVerbose("Starting PSCustomObject to HashTable conversion");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            WriteObject(ConvertToHashTable(InputObject));
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            //WriteVerbose("Completed HashTable conversion");
        }

        private object ConvertToHashTable(object input)
        {

            if (input == null)
            {
                return null;
            }

            // handle simple value types directly
            if (input is System.ValueType || input is string)
            {
                return input;
            }

            // handle Hashtable
            if (input is System.Collections.Hashtable || (input is PSObject pso && pso.BaseObject is Hashtable))
            {
                // return empty hashtable if input is null
                if (input is PSObject psObject)
                {
                    input = psObject.BaseObject;
                }

                Hashtable hashTable = (Hashtable)input;

                System.Collections.Hashtable newTable = (System.Collections.Hashtable ) hashTable.Clone();
                foreach (var key in hashTable.Keys)
                {
                    newTable[key] = ConvertToHashTable(newTable[key]);
                }
                return newTable;
            }

            // handle PSCustomObject
            var psObj = input as PSObject;
            if (psObj != null)
            {
                // PSObject wrapping null (e.g. from ConvertFrom-Json parsing
                // JSON null) should stay null, not become an empty hashtable
                if (psObj.BaseObject == null)
                {
                    return null;
                }

                var resultTable = new Dictionary<string, object>();

                // process each property of the current object
                foreach (var property in psObj.Properties)
                {
                    var value = property.Value;

                    // PSObject wrapping null (from JSON null values) → keep
                    // as null rather than recursively converting to empty {}
                    if (value is PSObject psoVal && psoVal.BaseObject == null)
                    {
                        value = null;
                    }
                    // handle nested PSCustomObject properties
                    else if (value is PSObject)
                    {
                        value = ConvertToHashTable(value);
                    }
                    // handle collection properties
                    else if (value is System.Collections.IEnumerable && !(value is string))
                    {
                        var list = new List<object>();
                        foreach (var element in (System.Collections.IEnumerable)value)
                        {
                            if (element is PSObject)
                            {
                                list.Add(ConvertToHashTable(element));
                            }
                            else
                            {
                                list.Add(element);
                            }
                        }
                        value = list.ToArray();
                    }
                    // handle simple value properties
                    else
                    {
                        // value remains as is
                    }

                    resultTable[property.Name] = value;
                }

                // create final hashtable with sorted keys
                var finalResultTable = new Hashtable(StringComparer.OrdinalIgnoreCase);
                foreach (var key in resultTable.Keys.OrderBy(k => k, StringComparer.Ordinal))
                {
                    finalResultTable[key] = resultTable[key];
                }

                return finalResultTable;
            }

            // handle collection types
            else if (input is System.Collections.IEnumerable && !(input is string))
            {
                var list = new List<object>();
                foreach (var element in (System.Collections.IEnumerable)input)
                {
                    list.Add(ConvertToHashTable(element));
                }

                return list.ToArray();
            }

            // handle other types
            else
            {
                return input;
            }
        }
    }
}