using System.Management.Automation;

namespace GenXdev.AI
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Calculates the cosine similarity between two vectors.
.DESCRIPTION
Takes two numerical vectors (arrays) as input and computes their cosine similarity. The result indicates how closely related the vectors are, with 0 meaning completely dissimilar and 1 meaning identical.

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
$v1 = @(0.12, -0.45, 0.89)
$v2 = @(0.15, -0.40, 0.92)
Get-VectorSimilarity -Vector1 $v1 -Vector2 $v2
```

Returns approximately 0.998, indicating high similarity.
")]
    [Cmdlet(VerbsCommon.Get, "VectorSimilarity")]
    [OutputType(typeof(double))]
    public class GetVectorSimilarityCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// The first vector as an array of numbers (e.g., [0.12, -0.45, 0.89]). Must be the same length as Vector2.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 0,
            HelpMessage = "First vector array of numbers")]
        public double[] Vector1 { get; set; }

        /// <summary>
        /// The second vector as an array of numbers (e.g., [0.15, -0.40, 0.92]). Must be the same length as Vector1.
        /// </summary>
        [Parameter(
            Mandatory = true,
            Position = 1,
            HelpMessage = "Second vector array of numbers")]
        public double[] Vector2 { get; set; }

        /// <summary>
        /// Begin processing - validate input vectors
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Validating input vectors...");

            // Check for null vectors
            if (Vector1 == null || Vector2 == null)
            {
                WriteError(new ErrorRecord(
                    new ArgumentException("Both Vector1 and Vector2 must contain values."),
                    "NullVector",
                    ErrorCategory.InvalidArgument,
                    null));
                return;
            }

            // Verify vectors have matching lengths
            if (Vector1.Length != Vector2.Length)
            {
                WriteError(new ErrorRecord(
                    new ArgumentException("Vector1 and Vector2 must have the same length."),
                    "LengthMismatch",
                    ErrorCategory.InvalidArgument,
                    null));
                return;
            }

            // Ensure vectors are not empty
            if (Vector1.Length == 0)
            {
                WriteError(new ErrorRecord(
                    new ArgumentException("Vectors cannot be empty."),
                    "EmptyVector",
                    ErrorCategory.InvalidArgument,
                    null));
                return;
            }
        }

        /// <summary>
        /// Process record - calculate vector similarity
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                WriteVerbose("Calculating vector similarity...");

                // Compute the dot product of the two vectors
                double dotProduct = 0.0;
                for (int i = 0; i < Vector1.Length; i++)
                {
                    dotProduct += Vector1[i] * Vector2[i];
                }

                // Calculate the magnitude (euclidean norm) of each vector
                double magnitude1 = 0.0;
                double magnitude2 = 0.0;
                for (int i = 0; i < Vector1.Length; i++)
                {
                    magnitude1 += Math.Pow(Vector1[i], 2);
                    magnitude2 += Math.Pow(Vector2[i], 2);
                }
                magnitude1 = Math.Sqrt(magnitude1);
                magnitude2 = Math.Sqrt(magnitude2);

                // Prevent division by zero for zero-magnitude vectors
                if (magnitude1 == 0 || magnitude2 == 0)
                {
                    WriteVerbose("One or both vectors have zero magnitude. Similarity is undefined.");
                    WriteObject(0.0);
                    return;
                }

                // Calculate final cosine similarity
                double similarity = dotProduct / (magnitude1 * magnitude2);

                // Normalize result to 0-1 range
                double normalizedSimilarity = Math.Min(Math.Max(similarity, -1), 1);
                normalizedSimilarity = (normalizedSimilarity + 1) / 2;

                WriteVerbose("Similarity calculation complete");
                WriteObject(Math.Round(normalizedSimilarity, 6));
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "SimilarityCalculationError",
                    ErrorCategory.InvalidOperation,
                    null));
            }
        }

        /// <summary>
        /// End processing - no cleanup needed
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}