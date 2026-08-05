using System.Drawing.Imaging;
using System.Management.Automation;
using System.Runtime.InteropServices;

namespace GenXdev.Windows
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Captures a screenshot of the specified monitor and saves it to the
specified path.
.DESCRIPTION
* Takes a screenshot of the desktop from the specified monitor and saves
  it as an image file.
* Supports multiple monitors and automatically detects the correct screen
  bounds and scaling factors for high-DPI displays.

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
Save-DesktopScreenShot -Monitor 0 -OutputPath ""C:\Screenshots\primary.png""
```

Captures a screenshot of the primary monitor and saves it as PNG.
.EXAMPLE
```powershell
Save-DesktopScreenShot -Monitor 1 -OutputPath ""C:\Screenshots\monitor2.jpg"" -Quality 95
```

Captures a screenshot of the second monitor with high quality JPEG.
.EXAMPLE
```powershell
Save-DesktopScreenShot -Monitor -1 -OutputPath ""C:\Screenshots\all_monitors.png""
```

Captures all monitors combined into a single screenshot image.
")]
    [Cmdlet("Save", "DesktopScreenShot")]
    [OutputType(typeof(FileInfo))]
    public class SaveDesktopScreenShotCommand : PSGenXdevCmdlet
    {
        // Windows API declarations for direct desktop capture
        [DllImport("user32.dll")]
        private static extern IntPtr GetDesktopWindow();

        // Use GetDC(IntPtr.Zero) to get a DC for the entire screen (virtual screen across monitors)
        [DllImport("user32.dll")]
        private static extern IntPtr GetDC(IntPtr hWnd);

        [DllImport("user32.dll")]
        private static extern int ReleaseDC(IntPtr hWnd, IntPtr hDC);

        [DllImport("user32.dll")]
        private static extern int GetSystemMetrics(int nIndex);

        [DllImport("gdi32.dll")]
        private static extern IntPtr CreateCompatibleDC(IntPtr hdc);

        [DllImport("gdi32.dll")]
        private static extern IntPtr CreateCompatibleBitmap(IntPtr hdc, int cx, int cy);

        [DllImport("gdi32.dll")]
        private static extern IntPtr SelectObject(IntPtr hdc, IntPtr hObject);

        [DllImport("gdi32.dll")]
        private static extern bool BitBlt(IntPtr hdc, int x, int y, int cx, int cy, IntPtr hdcSrc, int x1, int y1, uint rop);

        [DllImport("gdi32.dll")]
        private static extern bool DeleteDC(IntPtr hdc);

        [DllImport("gdi32.dll")]
        private static extern bool DeleteObject(IntPtr hObject);

        // BitBlt operation constants
        private const uint SRCCOPY = 0x00CC0020;

        // System metrics for virtual screen
        private const int SM_XVIRTUALSCREEN = 76;
        private const int SM_YVIRTUALSCREEN = 77;
        private const int SM_CXVIRTUALSCREEN = 78;
        private const int SM_CYVIRTUALSCREEN = 79;

        /// <summary>
        /// Monitor index to capture (0=primary, 1+=specific monitor, -1=all monitors)
        /// </summary>
        [Parameter(
            Position = 0,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Monitor index to capture (0=primary, 1+=specific monitor, -1=all monitors)"
        )]
        public int Monitor { get; set; }

        /// <summary>
        /// Full path where the screenshot will be saved
        /// </summary>
        [Parameter(
            Position = 1,
            Mandatory = true,
            ValueFromPipelineByPropertyName = true,
            HelpMessage = "Full path where the screenshot will be saved"
        )]
        [ValidateNotNullOrEmpty]
        public string OutputPath { get; set; }

        /// <summary>
        /// JPEG quality level (1-100)
        /// </summary>
        [Parameter(
            HelpMessage = "JPEG quality level (1-100), only applies to JPEG format"
        )]
        [ValidateRange(1, 100)]
        public int Quality { get; set; } = 90;

        /// <summary>
        /// Begin processing - initialization and validation
        /// </summary>
        protected override void BeginProcessing()
        {
            WriteVerbose("Starting desktop screenshot capture");

            // Validate output directory exists - use base class ExpandPath for proper path handling
            var expandedPath = ExpandPath(OutputPath, CreateDirectory: true, DeleteExistingFile: true);
            if (string.IsNullOrEmpty(expandedPath))
            {
                throw new ArgumentException($"Could not expand output path: {OutputPath}");
            }

            // Update OutputPath to use the expanded path
            OutputPath = expandedPath;

            // Validate monitor index
            var screenCount = Screen.AllScreens.Length;
            if (Monitor >= 0 && Monitor >= screenCount)
            {
                throw new ArgumentException($"Monitor index {Monitor} is invalid. Available monitors: 0-{screenCount - 1}");
            }

            WriteVerbose($"Available monitors: {screenCount}");
            WriteVerbose($"Target monitor: {Monitor}");
            WriteVerbose($"Output path: {OutputPath}");
        }

        /// <summary>
        /// Process record - main screenshot capture logic using Windows API
        /// </summary>
        protected override void ProcessRecord()
        {
            try
            {
                Rectangle captureArea;

                if (Monitor == -1)
                {
                    // Capture all monitors as single image
                    captureArea = GetVirtualScreenBounds();
                    WriteVerbose($"Capturing all monitors: {captureArea.Width}x{captureArea.Height} at ({captureArea.X}, {captureArea.Y})");
                }
                else
                {
                    // Capture specific monitor
                    var screens = Screen.AllScreens;
                    var targetScreen = Monitor == 0 ? Screen.PrimaryScreen : screens[Monitor];
                    captureArea = targetScreen.Bounds;
                    WriteVerbose($"Capturing monitor {Monitor}: {captureArea.Width}x{captureArea.Height} at ({captureArea.X}, {captureArea.Y})");
                }

                // Capture screenshot using Windows API with full virtual screen DC and offset handling
                Bitmap screenshot = CaptureDesktopUsingAPI(captureArea);

                // Save the screenshot
                SaveScreenshot(screenshot, OutputPath);

                WriteVerbose($"Screenshot saved successfully to: {OutputPath}");

                // Return FileInfo object of the saved file
                WriteObject(new FileInfo(OutputPath));
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "ScreenshotCaptureFailed",
                    ErrorCategory.InvalidOperation,
                    null));
            }
        }

        /// <summary>
        /// Captures desktop using Windows API that actually uses the desktop handle
        /// </summary>
        private Bitmap CaptureDesktopUsingAPI(Rectangle captureArea)
        {
            // Get the virtual screen offsets to map negative coordinates correctly
            int virtualLeft = GetSystemMetrics(SM_XVIRTUALSCREEN);
            int virtualTop = GetSystemMetrics(SM_YVIRTUALSCREEN);

            IntPtr screenDC = IntPtr.Zero;   // DC for full virtual screen
            IntPtr memoryDC = IntPtr.Zero;
            IntPtr hBitmap = IntPtr.Zero;
            IntPtr hOld = IntPtr.Zero;

            try
            {
                // Get a DC for the entire screen (all monitors)
                screenDC = GetDC(IntPtr.Zero);
                if (screenDC == IntPtr.Zero)
                {
                    throw new InvalidOperationException("Failed to get screen device context");
                }

                WriteVerbose($"Virtual screen origin: ({virtualLeft}, {virtualTop})");

                // Create compatible memory DC
                memoryDC = CreateCompatibleDC(screenDC);
                if (memoryDC == IntPtr.Zero)
                {
                    throw new InvalidOperationException("Failed to create compatible device context");
                }

                // Create a bitmap sized to the capture area only (destination size)
                hBitmap = CreateCompatibleBitmap(screenDC, captureArea.Width, captureArea.Height);
                if (hBitmap == IntPtr.Zero)
                {
                    throw new InvalidOperationException("Failed to create compatible bitmap");
                }

                // Select bitmap into memory DC
                hOld = SelectObject(memoryDC, hBitmap);
                if (hOld == IntPtr.Zero)
                {
                    throw new InvalidOperationException("Failed to select bitmap into device context");
                }

                // Compute source coordinates in the screen DC (adjust for virtual origin)
                int srcX = captureArea.X - virtualLeft;
                int srcY = captureArea.Y - virtualTop;

                WriteVerbose($"BitBlt src=({srcX}, {srcY}) size={captureArea.Width}x{captureArea.Height}");

                // Perform the bit-block transfer from full screen DC to memory DC
                bool success = BitBlt(
                    memoryDC, 0, 0, captureArea.Width, captureArea.Height,
                    screenDC, srcX, srcY, SRCCOPY);

                if (!success)
                {
                    throw new InvalidOperationException("BitBlt operation failed");
                }

                // Convert HBITMAP to managed Bitmap
                Bitmap bitmap = Image.FromHbitmap(hBitmap);

                WriteVerbose($"Successfully created bitmap: {bitmap.Width}x{bitmap.Height}");

                return bitmap;
            }
            finally
            {
                // Restore and cleanup GDI objects
                if (hOld != IntPtr.Zero)
                    SelectObject(memoryDC, hOld);

                if (hBitmap != IntPtr.Zero)
                    DeleteObject(hBitmap);

                if (memoryDC != IntPtr.Zero)
                    DeleteDC(memoryDC);

                if (screenDC != IntPtr.Zero)
                    ReleaseDC(IntPtr.Zero, screenDC);
            }
        }

        /// <summary>
        /// Gets the bounds of the virtual screen (all monitors combined)
        /// </summary>
        private Rectangle GetVirtualScreenBounds()
        {
            int left = int.MaxValue;
            int top = int.MaxValue;
            int right = int.MinValue;
            int bottom = int.MinValue;

            foreach (var screen in Screen.AllScreens)
            {
                left = Math.Min(left, screen.Bounds.Left);
                top = Math.Min(top, screen.Bounds.Top);
                right = Math.Max(right, screen.Bounds.Right);
                bottom = Math.Max(bottom, screen.Bounds.Bottom);
            }

            return new Rectangle(left, top, right - left, bottom - top);
        }

        /// <summary>
        /// Saves the screenshot bitmap to the specified path with appropriate format
        /// </summary>
        private void SaveScreenshot(Bitmap bitmap, string path)
        {
            var extension = Path.GetExtension(path).ToLowerInvariant();
            ImageFormat format;
            EncoderParameters encoderParams = null;

            switch (extension)
            {
                case ".jpg":
                case ".jpeg":
                    format = ImageFormat.Jpeg;
                    encoderParams = GetJpegEncoderParams(Quality);
                    WriteVerbose($"Saving as JPEG with quality {Quality}");
                    break;
                case ".bmp":
                    format = ImageFormat.Bmp;
                    WriteVerbose("Saving as BMP");
                    break;
                case ".gif":
                    format = ImageFormat.Gif;
                    WriteVerbose("Saving as GIF");
                    break;
                case ".tiff":
                case ".tif":
                    format = ImageFormat.Tiff;
                    WriteVerbose("Saving as TIFF");
                    break;
                case ".png":
                default:
                    format = ImageFormat.Png;
                    WriteVerbose("Saving as PNG");
                    break;
            }

            if (encoderParams != null)
            {
                var encoder = GetEncoder(format);
                if (encoder != null)
                {
                    bitmap.Save(path, encoder, encoderParams);
                }
                else
                {
                    bitmap.Save(path, format);
                }
                encoderParams.Dispose();
            }
            else
            {
                bitmap.Save(path, format);
            }

            bitmap.Dispose();
        }

        /// <summary>
        /// Gets JPEG encoder parameters for quality setting
        /// </summary>
        private EncoderParameters GetJpegEncoderParams(int quality)
        {
            var encoderParams = new EncoderParameters(1);
            encoderParams.Param[0] = new EncoderParameter(System.Drawing.Imaging.Encoder.Quality, quality);
            return encoderParams;
        }

        /// <summary>
        /// Gets the image codec encoder for the specified format
        /// </summary>
        private ImageCodecInfo GetEncoder(ImageFormat format)
        {
            var codecs = ImageCodecInfo.GetImageEncoders();
            foreach (var codec in codecs)
            {
                if (codec.FormatID == format.Guid)
                {
                    return codec;
                }
            }
            return null;
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            WriteVerbose("Desktop screenshot capture completed");
        }
    }
}