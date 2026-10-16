using System.Runtime.InteropServices;
using System.Text;

namespace GenXdev.Helpers
{
    /// <summary>
    /// Reads rectangular regions of text directly from the Windows console
    /// screen buffer via the Win32 <c>ReadConsoleOutput</c> API.
    /// </summary>
    public static class ConsoleReader
    {
        private const int StdOutputHandle = -11;

        [StructLayout(LayoutKind.Sequential)]
        private struct CharInfo
        {
            public char UnicodeChar;
            public short Attributes;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct Coord
        {
            public short X;
            public short Y;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct SmallRect
        {
            public short Left;
            public short Top;
            public short Right;
            public short Bottom;
        }

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr GetStdHandle(int nStdHandle);

        [DllImport("kernel32.dll", SetLastError = true, CharSet = CharSet.Unicode)]
        private static extern bool ReadConsoleOutput(
            IntPtr hConsoleOutput,
            [Out] CharInfo[] lpBuffer,
            Coord dwBufferSize,
            Coord dwBufferCoord,
            ref SmallRect lpReadRegion
        );

        /// <summary>
        /// Reads the rectangle of the console screen buffer starting at
        /// (<paramref name="left"/>, <paramref name="top"/>) with the given
        /// <paramref name="width"/> and <paramref name="height"/>, returning
        /// one string per row. Returns an empty array when the region is
        /// invalid or the console handle cannot be acquired.
        /// </summary>
        public static string[] ReadFromBuffer(int left, int top, int width, int height)
        {
            if (width <= 0 || height <= 0)
            {
                return [];
            }

            IntPtr handle = GetStdHandle(StdOutputHandle);

            if (handle == IntPtr.Zero || handle == new IntPtr(-1))
            {
                return [];
            }

            CharInfo[] buffer = new CharInfo[width * height];

            Coord bufferSize = new() { X = (short)width, Y = (short)height };
            Coord bufferCoord = new() { X = 0, Y = 0 };

            SmallRect readRegion = new()
            {
                Left = (short)left,
                Top = (short)top,
                Right = (short)(left + width - 1),
                Bottom = (short)(top + height - 1)
            };

            if (!ReadConsoleOutput(handle, buffer, bufferSize, bufferCoord, ref readRegion))
            {
                return [];
            }

            string[] lines = new string[height];

            for (int row = 0; row < height; row++)
            {
                StringBuilder sb = new(width);

                for (int col = 0; col < width; col++)
                {
                    sb.Append(buffer[(row * width) + col].UnicodeChar);
                }

                lines[row] = sb.ToString();
            }

            return lines;
        }
    }
}
