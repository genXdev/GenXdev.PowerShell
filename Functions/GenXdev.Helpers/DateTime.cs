using System.Globalization;
using System.Text;

namespace GenXdev.Helpers
{
    /// <summary>
    /// Provides static helper methods for date and time operations, including conversions between different formats and utility functions.
    /// </summary>
    public static class DateTime
    {
        /// <summary>
        /// Converts a DateTimeOffset to a string in RFC 822 date format.
        /// </summary>
        /// <param name="dateTime">The DateTimeOffset to convert.</param>
        /// <returns>A string representing the date in RFC 822 format.</returns>
        public static string DateToRfc822Date(DateTimeOffset dateTime)
        {
            // If the offset is zero, use UTC format
            if (dateTime.Offset == TimeSpan.Zero)
            {
                return dateTime.ToUniversalTime().ToString("ddd, dd MMM yyyy HH:mm:ss Z", CultureInfo.InvariantCulture);
            }

            // For non-zero offset, format with timezone and remove the colon from the offset
            StringBuilder builder = new StringBuilder(dateTime.ToString("ddd, dd MMM yyyy HH:mm:ss zzz", CultureInfo.InvariantCulture));

            builder.Remove(builder.Length - 3, 1);

            return builder.ToString();
        }

        /// <summary>
        /// Converts a DateTime to a string in UTC format (yyyy-MM-dd HH:mm:ssZ).
        /// </summary>
        /// <param name="Date">The DateTime to convert.</param>
        /// <returns>A string representing the date in UTC format.</returns>
        public static string UtcDateToString(System.DateTime Date)
        {
            return Date.ToString("yyyy'-'MM'-'dd HH':'mm':'ss'Z'");
        }

        /// <summary>
        /// Parses a string to a DateTime, returning MinValue on failure.
        /// </summary>
        /// <param name="Date">The string to parse.</param>
        /// <returns>The parsed DateTime or DateTime.MinValue if parsing fails.</returns>
        public static System.DateTime StringToUtcDate(String Date)
        {
            // Attempt to parse the date string
            try
            {
                return System.DateTime.Parse(Date);
            }
            catch
            {
                // Return minimum value if parsing fails
                return System.DateTime.MinValue;
            }
        }

        /// <summary>
        /// Parses a string to a nullable DateTime, returning null on failure or empty input.
        /// </summary>
        /// <param name="Date">The string to parse.</param>
        /// <returns>The parsed DateTime or null if parsing fails or input is empty.</returns>
        public static System.DateTime? StringToUtcDateOrNull(String Date)
        {
            // Check if the input string is null or whitespace
            if (String.IsNullOrWhiteSpace(Date))
                return null;

            // Attempt to parse the date string
            try
            {
                return System.DateTime.Parse(Date);
            }
            catch
            {
                // Return null if parsing fails
                return null;
            }
        }

        /// <summary>
        /// Returns the maximum of two DateTime values.
        /// </summary>
        /// <param name="D1">The first DateTime.</param>
        /// <param name="D2">The second DateTime.</param>
        /// <returns>The later of the two DateTime values.</returns>
        public static System.DateTime Max(System.DateTime D1, System.DateTime D2)
        {
            // Compare the two dates and return the greater one
            if (D1 > D2)
                return D1;

            return D2;
        }

        /// <summary>
        /// Returns the maximum of two nullable DateTime values.
        /// </summary>
        /// <param name="D1">The first nullable DateTime.</param>
        /// <param name="D2">The second nullable DateTime.</param>
        /// <returns>The later of the two DateTime values, or null if both are null.</returns>
        public static System.DateTime? Max(System.DateTime? D1, System.DateTime? D2)
        {
            // Check if D1 is null
            if (!D1.HasValue)
                return D2;

            // Check if D2 is null
            if (!D2.HasValue)
                return D1;

            // Compare the values and return the greater one
            if (D1.Value > D2.Value)
                return D1.Value;

            return D2.Value;
        }

        /// <summary>
        /// Converts a JavaScript timestamp (milliseconds since epoch) to a DateTime.
        /// </summary>
        /// <param name="jsMiliSeconds">The JavaScript timestamp in milliseconds.</param>
        /// <returns>The corresponding DateTime.</returns>
        public static System.DateTime GetDateTimeFromJavascriptLong(long jsMiliSeconds)
        {
            // Convert JavaScript milliseconds to .NET ticks and create DateTime
            return new System.DateTime(((jsMiliSeconds * 10000) + 621355968000000000));
        }

        /// <summary>
        /// Converts a DateTime to a JavaScript timestamp (milliseconds since epoch).
        /// </summary>
        /// <param name="date">The DateTime to convert.</param>
        /// <returns>The JavaScript timestamp in milliseconds.</returns>
        public static long GetJavascriptLongFromDateTime(System.DateTime date)
        {
            // Convert .NET ticks to JavaScript milliseconds
            return (date.Ticks - 621355968000000000) / 10000;// (((jsMiliSeconds * 10000) + 621355968000000000));
        }

        /// <summary>
        /// Converts a DateTime to a custom APOP date format string.
        /// </summary>
        /// <param name="dateTime">The DateTime to convert.</param>
        /// <returns>A string in the custom APOP date format.</returns>
        public static string DateToAPOPDateThingy(System.DateTime dateTime)
        {
            // Convert ticks to a custom decimal format
            return (dateTime.Ticks / 100000000000000d).ToString("0.00000000000");
        }
    }
}
