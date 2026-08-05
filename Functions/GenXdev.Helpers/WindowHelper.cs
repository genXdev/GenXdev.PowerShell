using System.Collections;
using System.Diagnostics;
using System.Runtime.InteropServices;
using System.Text;
using Point = System.Windows.Point;
using Size = System.Windows.Size;

namespace GenXdev.Helpers
{
    public enum DeviceCap
    {
        VERTRES = 10,
        DESKTOPVERTRES = 117,

        // http://pinvoke.net/default.aspx/gdi32/GetDeviceCaps.html
    }

    /// <summary>
    /// Static class providing desktop and monitor information utilities.
    /// Includes scaling factor calculations and window positioning constants.
    /// </summary>
    public static class DesktopInfo
    {
        // Place these at the top of WindowObj, near your other constants and P/Invokes
        public const int SWP_NOMOVE = 0x0002;
        public const int SWP_NOSIZE = 0x0001;
        public const int SWP_NOZORDER = 0x0004;
        private static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
        private static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);
        [DllImport("gdi32.dll")]
        public static extern int GetDeviceCaps(IntPtr hdc, int nIndex);

        [PreserveSig()]
        [DllImport("gdi32.dll")]
        public static extern IntPtr CreateDC(
            string lpszDriver,
            string lpszDevice,
            IntPtr lpszOutput,
            IntPtr lpInitData
        );

        /// <summary>
        /// Calculates the display scaling factor for a specific monitor.
        /// The scaling factor represents how much the display is scaled (e.g., 1.25 for 125% scaling).
        /// </summary>
        /// <param name="monitor">The monitor index to get scaling for</param>
        /// <returns>The scaling factor as a float (1.0 = 100% scaling)</returns>
        public static float getScalingFactor(int monitor)
        {
            //Graphics g = Graphics.FromHwnd(IntPtr.Zero);
            var AllScreens = (from q in WpfScreenHelper.Screen.AllScreens select q).ToArray();
            IntPtr desktop = CreateDC(
                AllScreens[monitor].DeviceName,
                AllScreens[monitor].DeviceName,
                IntPtr.Zero,
                IntPtr.Zero
            );
            int LogicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.VERTRES);
            int PhysicalScreenHeight = GetDeviceCaps(desktop, (int)DeviceCap.DESKTOPVERTRES);

            float ScreenScalingFactor = (float)PhysicalScreenHeight / (float)LogicalScreenHeight;

            return ScreenScalingFactor; // 1.25 = 125%
        }

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool SetWindowPos(
            IntPtr hWnd,
            IntPtr hWndInsertAfter,
            int X,
            int Y,
            int cx,
            int cy,
            uint uFlags
        );
    }

    public class WindowObj
    {
        /// <summary>
        /// Represents a Windows window with methods for manipulation and state management.
        /// Provides functionality to control window position, size, visibility, and various window states.
        /// </summary>
        private const int SWP_NOMOVE = 0x0002;
        private const int SWP_NOSIZE = 0x0001;
        private static readonly IntPtr HWND_TOPMOST = new IntPtr(-1);
        private static readonly IntPtr HWND_NOTOPMOST = new IntPtr(-2);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool SetWindowPos(
            IntPtr hWnd,
            IntPtr hWndInsertAfter,
            int X,
            int Y,
            int cx,
            int cy,
            uint uFlags
        );

        /// <summary>
        /// Windows handle to identify the current window. This is a unique identifier
        /// assigned by the Windows operating system to each window instance.
        /// </summary>
        public IntPtr Handle { get; private set; }
        /// <summary>
        /// Name/title of the window as displayed in the title bar.
        /// </summary>
        public string Title { get; private set; }
        /// <summary>
        /// Collection of child windows belonging to this window.
        /// Child windows are windows that are contained within this window's client area.
        /// </summary>
        public ICollection<WindowObj> Children { get; private set; }

        /// <summary>
        /// Get a custom representation of the window class base on https://docs.microsoft.com/en-us/windows/win32/winmsg/about-window-classes documentation
        /// </summary>
        public string WindowType { get; private set; }

        /// <summary>
        /// Get the name of the class that represents the windows
        /// </summary>
        public string WindowClassName { get; private set; }

        private const UInt32 WM_CLOSE = 0x0010;
        public static int Amount = 0;

        // Constants for window styling
        private const int GWL_STYLE = -16;
        private const int GWL_EXSTYLE = -20;
        private const uint WS_CAPTION = 0x00C00000;
        private const uint WS_THICKFRAME = 0x00040000;
        private const uint WS_MINIMIZEBOX = 0x00020000;
        private const uint WS_MAXIMIZEBOX = 0x00010000;
        private const uint WS_SYSMENU = 0x00080000;
        private const uint WS_EX_TOPMOST = 0x00000008;
        private const uint WS_EX_LAYERED = 0x00080000;
        private const uint LWA_ALPHA = 0x00000002;

        // For window transparency
        [DllImport("user32.dll")]
        private static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

        [DllImport("user32.dll")]
        private static extern int SetWindowLong(IntPtr hWnd, int nIndex, uint dwNewLong);

        [DllImport("user32.dll")]
        private static extern uint GetWindowLong(IntPtr hWnd, int nIndex);

        /// <summary>
        /// Creates a window object with a handle and a window title.
        /// Initializes the window properties and enumerates child windows.
        /// </summary>
        /// <param name="handle">The Windows handle (HWND) of the window</param>
        /// <param name="title">The title/caption of the window</param>
        public WindowObj(IntPtr handle, string title)
        {
            Handle = handle;
            Title = title;

            // Initialize string builder for window class name retrieval
            StringBuilder stringBuilder = new StringBuilder(256);
            GetClassName(handle, stringBuilder, stringBuilder.Capacity);
            WindowType = GetWindowClass(stringBuilder.ToString());
            WindowClassName = stringBuilder.ToString();

            // Initialize children collection and enumerate child windows
            Children = new List<WindowObj>();
            ArrayList handles = new ArrayList();
            EnumedWindow childProc = GetWindowHandle;

            EnumChildWindows(handle, childProc, handles);
            foreach (IntPtr item in handles)
            {
                // Get capacity for child window text
                int capacityChild = GetWindowTextLength(handle) * 2;

                StringBuilder stringBuilderChild = new StringBuilder(capacityChild);
                GetWindowText(handle, stringBuilder, stringBuilderChild.Capacity);

                // Get class name for child window
                StringBuilder stringBuilderChild2 = new StringBuilder(256);
                GetClassName(handle, stringBuilderChild2, stringBuilderChild2.Capacity);

                // Create child window object
                WindowObj win = new WindowObj(item, stringBuilder.ToString());
                win.WindowClassName = stringBuilderChild2.ToString();
                win.WindowType = GetWindowClass(stringBuilderChild2.ToString());
                Children.Add(win);
            }
        }

        [DllImport("user32.dll")]
        public static extern void mouse_event(Int32 dwFlags, Int32 dx, Int32 dy, Int32 dwData, UIntPtr dwExtraInfo);

        private const int MOUSEEVENTF_MOVE = 0x0001;
        private const int WM_SYSCOMMAND = 0x0112;
        private const int SC_MONITORPOWER = 0xF170;
        private const int MonitorTurnOn = -1;
        private const int MonitorShutoff = 2;


        /// <summary>
        /// Sends a message to wake the monitor/display from sleep mode.
        /// Uses Windows API to simulate monitor power on command.
        /// </summary>
        public static void WakeMonitor()
        {
            // Send message to turn monitors on
            PostMessage((IntPtr)0xffff, WM_SYSCOMMAND, SC_MONITORPOWER, MonitorTurnOn);
            System.Threading.Thread.Sleep(150);

            // Simulate mouse movement to ensure monitor stays awake
            mouse_event(MOUSEEVENTF_MOVE, 0, 1, 0, UIntPtr.Zero);
            System.Threading.Thread.Sleep(40);
            mouse_event(MOUSEEVENTF_MOVE, 0, -1, 0, UIntPtr.Zero);
        }

        /// <summary>
        /// Sends a message to put the monitor/display into sleep mode.
        /// Uses Windows API to simulate monitor power off command.
        /// </summary>
        public static void SleepMonitor()
        {
            // Send message to turn monitors off
            PostMessage((IntPtr)0xffff, WM_SYSCOMMAND, SC_MONITORPOWER, MonitorShutoff);
        }
        [DllImport("user32.dll")]
        public static extern bool PostMessage(IntPtr hWnd, uint Msg, int wParam, int lParam);

        [DllImport("kernel32.dll")]
        public static extern IntPtr GetConsoleWindow();


        /// <summary>
        /// Callback method for enumerating child windows.
        /// Adds each window handle to the provided collection.
        /// </summary>
        /// <param name="windowHandle">Handle of the enumerated window</param>
        /// <param name="windowHandles">Collection to add the handle to</param>
        /// <returns>Always returns true to continue enumeration</returns>
        public static bool GetWindowHandle(IntPtr windowHandle, ArrayList windowHandles)
        {
            windowHandles.Add(windowHandle);
            return true;
        }

        ///<summary>A class to have better manipulation of windows sizes</summary>
        public struct RectStruct
        {
            public int Left { get; set; }
            public int Top { get; set; }
            public int Right { get; set; }
            public int Bottom { get; set; }
            public int Width { get; set; }
            public int Height { get; set; }

        }

        /// <summary>
        /// Opens a new process with the given file path and returns a window object
        /// if the process has a user interface, otherwise returns null.
        /// </summary>
        /// <param name="filePath">Path of the file to execute</param>
        /// <param name="timeToWait">Time in seconds to wait for the process to start
        /// (default -1 means wait for input idle)</param>
        /// <returns>WindowObj if process has a main window, null otherwise</returns>
        public static WindowObj Open(string filePath, int timeToWait = -1)
        {
            // Validate file exists
            if (!File.Exists(filePath))
                throw new Exception(string.Format("The filePath {0} is not valid", filePath));

            // Start the process
            Process newProcess = Process.Start(filePath);

            // Wait for process to be ready for input
            if (timeToWait == -1)
                newProcess.WaitForInputIdle();
            else
                newProcess.WaitForInputIdle(timeToWait * 1000);

            // Return window object if process has a main window
            if (newProcess != null && newProcess.MainWindowHandle != IntPtr.Zero)
                return new WindowObj(newProcess.MainWindowHandle, newProcess.MainWindowTitle);

            return null;
        }

        /// <summary>
        /// Searches for the existence of a process with the given name and returns
        /// the first occurrence as a WindowObj. Performs multiple attempts if needed.
        /// </summary>
        /// <param name="name">Exact name of the process to find</param>
        /// <param name="attempts">Number of attempts to find the window (default 1)</param>
        /// <param name="waitInterval">Milliseconds to wait between attempts (default 1000)</param>
        /// <returns>WindowObj if found, null otherwise</returns>
        public static WindowObj GetWindow(string name, int attempts = 1, int waitInterval = 1000)
        {
            // Get current processes
            IEnumerable<Process> currentProcesses = Process.GetProcesses();
            int counter = 0;

            // Try multiple times if needed
            while (counter < attempts)
            {
                // Search for process with matching main window title
                foreach (Process p in currentProcesses)
                    if (p.MainWindowHandle != IntPtr.Zero && p.MainWindowTitle == name)
                        return new WindowObj(p.MainWindowHandle, p.MainWindowTitle);

                // Wait and refresh process list
                System.Threading.Thread.Sleep(waitInterval);
                currentProcesses = Process.GetProcesses();
                counter++;
            }
            return null;
        }

        /// <summary>
        /// Gets the currently focused window.
        /// Returns a WindowObj representing the window that currently has keyboard focus.
        /// </summary>
        /// <returns>WindowObj of the focused window, or null if none</returns>
        public static WindowObj GetFocusedWindow()
        {
            // Get handle of foreground window
            var sb = new StringBuilder();
            var handle = GetForegroundWindow();

            // Return window object with title
            return new WindowObj(handle, GetWindowTitle(handle));
        }

        /// <summary>
        /// Searches for processes with the given name and returns all occurrences
        /// as WindowObj instances. Case-sensitive search by process name.
        /// </summary>
        /// <param name="name">Process name to search for</param>
        /// <param name="attempts">Number of attempts to find windows (default 1)</param>
        /// <param name="waitInterval">Milliseconds to wait between attempts (default 1000)</param>
        /// <returns>Collection of WindowObj instances for matching processes</returns>
        public static IEnumerable<WindowObj> GetWindows(string name, int attempts = 1, int waitInterval = 1000)
        {
            // Get current processes
            IEnumerable<Process> currentProcesses = Process.GetProcesses();
            ICollection<WindowObj> windows = new List<WindowObj>();
            int counter = 0;

            // Try multiple times if needed
            while (counter < attempts)
            {
                // Find processes with matching name and main window
                foreach (Process p in currentProcesses)
                    if (p.MainWindowHandle != IntPtr.Zero && p.ProcessName == name)
                        windows.Add(new WindowObj(p.MainWindowHandle, p.MainWindowTitle));

                // Stop if we found windows
                if (windows.Count > 0)
                    break;

                // Wait and refresh process list
                System.Threading.Thread.Sleep(waitInterval);
                currentProcesses = Process.GetProcesses();
                counter++;
            }
            return windows;
        }

        /// <summary>
        /// Gets the main window of a specific process.
        /// Searches for the main window handle of the given process.
        /// </summary>
        /// <param name="p">The process to get the main window for</param>
        /// <param name="attempts">Number of attempts to find the window (default 1)</param>
        /// <param name="waitInterval">Milliseconds to wait between attempts (default 1000)</param>
        /// <returns>Collection containing the main window if found</returns>
        public static IEnumerable<WindowObj> GetMainWindow(Process p, int attempts = 1, int waitInterval = 1000)
        {
            // Get current processes
            IEnumerable<Process> currentProcesses = Process.GetProcesses();
            ICollection<WindowObj> windows = new List<WindowObj>();
            int counter = 0;

            // Try multiple times if needed
            while (counter < attempts)
            {
                // Check if process has a main window
                if (p.MainWindowHandle != IntPtr.Zero)
                {
                    try
                    {
                        // Create window object for main window
                        windows.Add(new WindowObj(p.MainWindowHandle, p.MainWindowTitle));
                    }
                    catch
                    {
                        // Break on error
                        break;
                    }
                }

                // Stop if we found windows
                if (windows.Count > 0)
                    break;

                // Wait and refresh process list
                System.Threading.Thread.Sleep(waitInterval);
                currentProcesses = Process.GetProcesses();
                counter++;
            }

            return windows;
        }

        /// <summary>
        /// Gets the main window for a given window handle.
        /// Creates a WindowObj for the specified handle.
        /// </summary>
        /// <param name="windowHandle">The window handle to create object for</param>
        /// <param name="attempts">Number of attempts (not used in this overload)</param>
        /// <param name="waitInterval">Wait interval (not used in this overload)</param>
        /// <returns>Collection containing the window object</returns>
        public static IEnumerable<WindowObj> GetMainWindow(IntPtr windowHandle, int attempts = 1, int waitInterval = 1000)
        {
            // Get current processes
            IEnumerable<Process> currentProcesses = Process.GetProcesses();
            ICollection<WindowObj> windows = new List<WindowObj>();

            // Create window object if handle is valid
            if (windowHandle != IntPtr.Zero)
            {
                try
                {
                    // Create window object with empty title (will be populated by constructor)
                    windows.Add(new WindowObj(windowHandle, ""));
                }
                catch { }
            }

            return windows;
        }
        /// <summary>
        /// Searches for a process whose window title contains the given name (partial match).
        /// Returns the first matching window. Case-insensitive search.
        /// </summary>
        /// <param name="name">Partial name to search for in window titles</param>
        /// <param name="attempts">Number of attempts to find the window (default 1)</param>
        /// <param name="waitInterval">Milliseconds to wait between attempts (default 1000)</param>
        /// <returns>WindowObj if found, null otherwise</returns>
        public static WindowObj GetWindowWithPartialName(string name, int attempts = 1, int waitInterval = 1000)
        {
            // Get current processes
            IEnumerable<Process> currentProcesses = Process.GetProcesses();
            int counter = 0;

            // Try multiple times if needed
            while (counter < attempts)
            {
                // Search for process with partial title match
                foreach (Process p in currentProcesses)
                    if (p.MainWindowHandle != IntPtr.Zero && p.MainWindowTitle.ToLower().Contains(name.ToLower()))
                        return new WindowObj(p.MainWindowHandle, p.MainWindowTitle);

                // Wait and refresh process list
                System.Threading.Thread.Sleep(waitInterval);
                currentProcesses = Process.GetProcesses();
                counter++;
            }
            return null;
        }

        /// <summary>
        /// Searches for processes whose window titles contain the given name (partial match).
        /// Returns all matching windows. Case-insensitive search.
        /// </summary>
        /// <param name="name">Partial name to search for in window titles</param>
        /// <param name="attempts">Number of attempts to find windows (default 1)</param>
        /// <param name="waitInterval">Milliseconds to wait between attempts (default 1000)</param>
        /// <returns>Collection of WindowObj instances for matching processes</returns>
        public static IEnumerable<WindowObj> GetWindowsWithPartialName(string name, int attempts = 1, int waitInterval = 1000)
        {
            // Get current processes
            IEnumerable<Process> currentProcesses = Process.GetProcesses();
            ICollection<WindowObj> windows = new List<WindowObj>();
            int counter = 0;

            // Try multiple times if needed
            while (counter < attempts)
            {
                // Find processes with partial title match
                foreach (Process p in currentProcesses)
                    if (p.MainWindowHandle != IntPtr.Zero && p.MainWindowTitle.ToLower().Contains(name.ToLower()))
                        windows.Add(new WindowObj(p.MainWindowHandle, p.MainWindowTitle));

                // Stop if we found windows
                if (windows.Count > 0)
                    break;

                // Wait and refresh process list
                System.Threading.Thread.Sleep(waitInterval);
                currentProcesses = Process.GetProcesses();
                counter++;
            }
            return windows;
        }

        /// <summary>
        /// Gets the currently active window (the one with keyboard focus).
        /// Searches through all processes to find the one matching the active window handle.
        /// </summary>
        /// <returns>WindowObj of the active window, or null if not found</returns>
        public static WindowObj GetActive()
        {
            // Get handle of active window
            IntPtr handle = GetActiveWindow();

            // Find matching process
            if (handle != IntPtr.Zero)
            {
                foreach (Process p in Process.GetProcesses())
                    if (p.MainWindowHandle == handle)
                        return new WindowObj(p.MainWindowHandle, p.MainWindowTitle);
            }
            return null;
        }

        /// <summary>
        /// Brings focus to the current window by setting it as foreground.
        /// Temporarily allows the process to set foreground window if needed.
        /// </summary>
        public void Focus()
        {
            // Allow this process to set foreground window
            AllowSetForegroundWindow(-1);

            // Set this window as foreground and focus
            SetForegroundWindow(this.Handle);
            SetFocus(Handle);
        }

        /// <summary>
        /// Sets the current window as the foreground window with enhanced reliability.
        /// Handles minimized/maximized states and ensures proper activation.
        /// </summary>
        public void SetForeground()
        {
            // Temporarily set as topmost if not already

            // Show the window (SW_SHOW = 5)
            if (IsMinimized())
            {
                ShowWindowAsync(Handle, (int)ShowWindowCommands.Restore);
                System.Threading.Thread.Sleep(50);
            }

            // Ensure window is visible but don't activate it
            if (!IsVisible())
            {
                ShowWindowAsync(Handle, (int)ShowWindowCommands.ShowNoActivate);
            }

            SetForegroundWindow(Handle);
            BringWindowToTop(Handle);

            // Ensure the window is the active window and has keyboard focus
            SetActiveWindow(Handle);
            SetFocus(Handle);
        }

        /// <summary>Maximize the current window</summary>
        public bool Maximize()
        {
            return ShowWindowAsync(this.Handle, (int)ShowWindowCommands.Maximize);
        }

        /// <summary>Minimize the current window</summary>
        public bool Minimize()
        {
            return ShowWindowAsync(this.Handle, (int)ShowWindowCommands.Minimize);
        }

        /// <summary>Return the current windows at its first state when the windows was created</summary>
        public bool Restore()
        {
            return ShowWindowAsync(this.Handle, (int)ShowWindowCommands.Restore);
        }

        /// <summary>Return the current windows at its default state</summary>
        public bool DefaultState()
        {
            return ShowWindowAsync(this.Handle, (int)ShowWindowCommands.ShowDefault);
        }

        /// <summary>
        /// Gets the title/caption text of a window given its handle.
        /// </summary>
        /// <param name="hWnd">The window handle to get the title for</param>
        /// <returns>The window title as a string</returns>
        public static string GetWindowTitle(IntPtr hWnd)
        {
            var length = GetWindowTextLength(hWnd) + 1;
            var title = new StringBuilder(length);
            GetWindowText(hWnd, title, length);
            return title.ToString();
        }

        /// <summary>Hide the current window
        /// *If the application close with a hide process, this will not be close unless close method
        /// calls or manually kill the process*</summary>
        public bool Hide()
        {
            return ShowWindowAsync(this.Handle, (int)ShowWindowCommands.Hide);
        }

        /// <summary>Shows the current windows if it was hide</summary>
        public bool Show()
        {
            return ShowWindowAsync(this.Handle, (int)ShowWindowCommands.Show);
        }

        /// <summary>Close the current windows</summary>
        public bool Close()
        {
            return SendMessage(this.Handle, WM_CLOSE, IntPtr.Zero, IntPtr.Zero) == IntPtr.Zero;
        }
        public bool SendMessage(UInt32 Msg, IntPtr wParam, IntPtr lParam)
        {
            return SendMessage(this.Handle, Msg, wParam, lParam) == IntPtr.Zero;
        }

        /// <summary>Resize the current window with the given params</summary>
        /// <param name="width">New width of the current windows</param>
        /// <param name="height">New height of the current windows</param>
        public bool Resize(int width, int height)
        {
            return MoveWindow(this.Handle, 0, 0, width, height, true);
        }

        /// <summary>Resize the current window with the given params</summary>
        /// <param name="pixels">this will use as new width and new height of the windows</param>
        public bool Resize(int pixels)
        {
            return MoveWindow(this.Handle, 0, 0, pixels, pixels, true);
        }

        /// <summary>Move the current window with the given params</summary>
        /// <param name="X">New X coordinate of the current windows</param>
        /// <param name="Y">New Y coordinate of the current windows</param>
        public bool Move(int X, int Y)
        {
            RectStruct rect = new RectStruct();
            GetWindowRect(this.Handle, ref rect);

            rect.Width = rect.Right - rect.Left + Amount;
            rect.Height = rect.Bottom - rect.Top + Amount;
            return MoveWindow(this.Handle, X, Y, rect.Width, rect.Height, true);
        }
        public bool Move(int X, int Y, int W, int H)
        {
            return MoveWindow(this.Handle, X, Y, W, H, true);
        }

        /// <summary>Return the position of the windows as X, Y coordinates</summary>
        public Point Position()
        {
            RectStruct rect = new RectStruct();
            GetWindowRect(this.Handle, ref rect);

            return new Point(rect.Left, rect.Top);
        }

        public int Left
        {

            get
            {
                return (int) Position().X;
            }

            set
            {
                Move(value, (int)Position().Y);
            }
        }
        public int Top
        {

            get
            {
                return (int)Position().Y;
            }

            set
            {
                Move((int)Position().X, value);
            }
        }

        public int Width
        {

            get
            {
                return (int)Size().Width;
            }

            set
            {
                Resize(value, (int)Size().Height);
            }
        }
        public int Height
        {

            get
            {
                return (int)Size().Height;
            }

            set
            {
                Resize((int)Size().Width, value);
            }
        }

        /// <summary>Return the Size of the windows as width, height coordinates</summary>
        public Size Size()
        {
            RectStruct rect = new RectStruct();
            GetWindowRect(this.Handle, ref rect);

            rect.Width = rect.Right - rect.Left + Amount;
            rect.Height = rect.Bottom - rect.Top + Amount;
            return new Size(rect.Width, rect.Height);
        }

        /// <summary>Return the position and size of the windows as X, Y, with, height coordinates</summary>
        /*
        public Rect Area()
        {
            RectStruct rect = new RectStruct();
            GetWindowRect(this.Handle, ref rect);

            rect.Width = rect.Right - rect.Left + Amount;
            rect.Height = rect.Bottom - rect.Top + Amount;
            return new System.Windows.(rect.Left, rect.Top, rect.Width, rect.Height);
        }
        */

        /// <summary>Check if the current windows is visible</summary>
        public bool IsVisible()
        {
            return IsWindowVisible(this.Handle);
        }
        [DllImport("user32.dll")]
        public static extern bool AllowSetForegroundWindow(int dwProcessId);

        [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
        public static extern int GetClassName(IntPtr hWnd, StringBuilder lpClassName, int nMaxCount);

        [DllImport("user32.dll")]
        public static extern IntPtr GetActiveWindow();

        [DllImport("user32.dll")]
        public static extern bool IsWindowVisible(IntPtr hWnd);

        [DllImport("user32.dll")]
        public static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        public static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll")]
        public static extern bool ShowWindowAsync(IntPtr hWnd, int nCmdShow);

        [DllImport("user32.dll")]
        public static extern IntPtr SendMessage(IntPtr hWnd, UInt32 Msg, IntPtr wParam, IntPtr lParam);

        [DllImport("user32.dll")]
        public static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

        [DllImport("user32.dll")]
        public static extern bool GetWindowRect(IntPtr hWnd, ref RectStruct rectangle);

        [DllImport("kernel32.dll")]
        public static extern int GetProcessId(IntPtr handle);

        [DllImport("user32.dll")]
        public static extern uint GetWindowThreadProcessId(IntPtr hWnd, IntPtr ProcessId);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint processId);

        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        public static extern int GetWindowText(IntPtr hWnd, StringBuilder lpString, int nMaxCount);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern IntPtr SetActiveWindow(IntPtr hWnd);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        static extern bool SetFocus(IntPtr hWnd);

        [DllImport("user32.dll", SetLastError = true)]
        public static extern void SwitchToThisWindow(IntPtr hWnd, bool fAltTab);

        [DllImport("user32.dll")]
        public static extern IntPtr GetFocus();

        [DllImport("user32.dll")]
        public static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        public delegate bool EnumedWindow(IntPtr handleWindow, ArrayList handles);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        public static extern bool EnumChildWindows(IntPtr window, EnumedWindow callback, ArrayList lParam);

        [DllImport("user32.dll", CharSet = CharSet.Auto)]
        public static extern int GetWindowTextLength(IntPtr hWnd);

        private enum ShowWindowCommands
        {
            /// <summary>
            /// Hides the window and activates another window.
            /// </summary>
            Hide = 0,
            /// <summary>
            /// Activates and displays a window. If the window is minimized or
            /// maximized, the system restores it to its original size and position.
            /// An application should specify this flag when displaying the window
            /// for the first time.
            /// </summary>
            Normal = 1,
            /// <summary>
            /// Activates the window and displays it as a minimized window.
            /// </summary>
            ShowMinimized = 2,
            /// <summary>
            /// Maximizes the specified window.
            /// </summary>
            Maximize = 3, // is this the right value?
            /// <summary>
            /// Activates the window and displays it as a maximized window.
            /// </summary>
            ShowMaximized = 3,
            /// <summary>
            /// Displays a window in its most recent size and position. This value
            /// is similar to <see cref="Win32.ShowWindowCommand.Normal"/>, except
            /// the window is not activated.
            /// </summary>
            ShowNoActivate = 4,
            /// <summary>
            /// Activates the window and displays it in its current size and position.
            /// </summary>
            Show = 5,
            /// <summary>
            /// Minimizes the specified window and activates the next top-level
            /// window in the Z order.
            /// </summary>
            Minimize = 6,
            /// <summary>
            /// Displays the window as a minimized window. This value is similar to
            /// <see cref="Win32.ShowWindowCommand.ShowMinimized"/>, except the
            /// window is not activated.
            /// </summary>
            ShowMinNoActive = 7,
            /// <summary>
            /// Displays the window in its current size and position. This value is
            /// similar to <see cref="Win32.ShowWindowCommand.Show"/>, except the
            /// window is not activated.
            /// </summary>
            ShowNA = 8,
            /// <summary>
            /// Activates and displays the window. If the window is minimized or
            /// maximized, the system restores it to its original size and position.
            /// An application should specify this flag when restoring a minimized window.
            /// </summary>
            Restore = 9,
            /// <summary>
            /// Sets the show state based on the SW_* value specified in the
            /// STARTUPINFO structure passed to the CreateProcess function by the
            /// program that started the application.
            /// </summary>
            ShowDefault = 10,
            /// <summary>
            ///  <b>Windows 2000/XP:</b> Minimizes a window, even if the thread
            /// that owns the window is not responding. This flag should only be
            /// used when minimizing windows from a different thread.
            /// </summary>
            ForceMinimize = 11
        }
        private string GetWindowClass(string windowClass)
        {
            List<string> values = new List<string>(){
                "ComboLBox","DDEMLEvent","Message","#32768",
                "#32769","#32770","#32771","#32772","Button","Edit","ListBox","MDIClient",
                "ScrollBar","Static",""
            };

            if (windowClass == "#32768")
                return "Menu";
            else if (windowClass == "#32769")
                return "DektopWindow";
            else if (windowClass == "#32770")
                return "DialogBox";
            else if (windowClass == "#32771")
                return "TaskSwitchWindowClass";
            else if (windowClass == "#32772")
                return "IconTitlesClass";
            return values.SingleOrDefault(s => s == windowClass);
        }

        /// <summary>
        /// Sets or removes the "Always On Top" state of the window
        /// </summary>
        /// <param name="alwaysOnTop">True to set the window always on top, false otherwise</param>
        /// <returns>True if successful</returns>
        public bool SetAlwaysOnTop(bool alwaysOnTop)
        {
            uint exStyle = GetWindowLong(Handle, GWL_EXSTYLE);

            if (alwaysOnTop)
                exStyle |= WS_EX_TOPMOST;
            else
                exStyle &= ~WS_EX_TOPMOST;

            return SetWindowLong(Handle, GWL_EXSTYLE, exStyle) != 0;
        }

        /// <summary>
        /// Sets the opacity/transparency level of the window
        /// </summary>
        /// <param name="opacity">Opacity level from 0 (transparent) to 255 (opaque)</param>
        /// <returns>True if successful</returns>
        public bool SetOpacity(byte opacity)
        {
            uint exStyle = GetWindowLong(Handle, GWL_EXSTYLE);
            exStyle |= WS_EX_LAYERED;
            SetWindowLong(Handle, GWL_EXSTYLE, exStyle);
            return SetLayeredWindowAttributes(Handle, 0, opacity, LWA_ALPHA);
        }

        // Struct to save window position and state
        /// <summary>
        /// Serializable class that stores the complete state of a window,
        /// including position, size, and various window states.
        /// </summary>
        [Serializable]
        public class WindowState
        {
            public int X { get; set; }
            public int Y { get; set; }
            public int Width { get; set; }
            public int Height { get; set; }
            public bool IsMaximized { get; set; }
            public bool IsMinimized { get; set; }
            public bool IsAlwaysOnTop { get; set; }
            public byte Opacity { get; set; }
            public string Title { get; set; }
        }

        /// <summary>
        /// Captures the current state of the window
        /// </summary>
        /// <returns>A WindowState object containing the window's current state</returns>
        public WindowState CaptureState()
        {
            RectStruct rect = new RectStruct();
            GetWindowRect(Handle, ref rect);

            return new WindowState
            {
                X = rect.Left,
                Y = rect.Top,
                Width = rect.Right - rect.Left,
                Height = rect.Bottom - rect.Top,
                IsMaximized = IsMaximized(),
                IsMinimized = IsMinimized(),
                IsAlwaysOnTop = IsAlwaysOnTop(),
                Opacity = GetOpacity(),
                Title = Title
            };
        }

        /// <summary>
        /// Restores a previously captured window state
        /// </summary>
        /// <param name="state">The WindowState to restore</param>
        public void RestoreState(WindowState state)
        {
            if (state.IsMaximized)
                Maximize();
            else if (state.IsMinimized)
                Minimize();
            else
                Move(state.X, state.Y, state.Width, state.Height);

            SetAlwaysOnTop(state.IsAlwaysOnTop);
            SetOpacity(state.Opacity);
        }

        /// <summary>
        /// Checks if the window is currently maximized
        /// </summary>
        public bool IsMaximized()
        {
            return IsZoomed(Handle);
        }

        /// <summary>
        /// Checks if the window is currently minimized
        /// </summary>
        public bool IsMinimized()
        {
            return IsIconic(Handle);
        }

        /// <summary>
        /// Checks if the window is set to always be on top
        /// </summary>
        public bool IsAlwaysOnTop()
        {
            uint exStyle = GetWindowLong(Handle, GWL_EXSTYLE);
            return (exStyle & WS_EX_TOPMOST) != 0;
        }

        /// <summary>
        /// Gets the current opacity of the window
        /// </summary>
        public byte GetOpacity()
        {
            uint exStyle = GetWindowLong(Handle, GWL_EXSTYLE);
            if ((exStyle & WS_EX_LAYERED) == 0)
                return 255;

            byte opacity = 255;
            uint flags = 0;
            uint key = 0;
            GetLayeredWindowAttributes(Handle, ref key, ref opacity, ref flags);
            return opacity;
        }

        /// <summary>
        /// Fades the window in or out with animation
        /// </summary>
        /// <param name="fadeIn">True to fade in, false to fade out</param>
        /// <param name="duration">Duration of the animation in milliseconds</param>
        public void FadeWindow(bool fadeIn, int duration = 200)
        {
            byte startOpacity = fadeIn ? (byte)0 : (byte)255;
            byte endOpacity = fadeIn ? (byte)255 : (byte)0;
            int steps = 10;
            int delay = duration / steps;

            SetOpacity(startOpacity);
            if (fadeIn) Show();

            for (int i = 1; i <= steps; i++)
            {
                byte currentOpacity = (byte)(startOpacity + ((endOpacity - startOpacity) * i / steps));
                SetOpacity(currentOpacity);
                System.Threading.Thread.Sleep(delay);
            }

            if (!fadeIn) Hide();
        }

        /// <summary>
        /// Snaps the window to the nearest screen edge
        /// </summary>
        public void SnapToEdge()
        {
            var position = Position();
            var size = Size();
            var screen = ScreenFromPoint(new Point((int)position.X, (int)position.Y));

            int snapDistance = 20; // pixels
            var workArea = screen.WorkingArea;

            int x = (int)position.X;
            int y = (int)position.Y;

            // Snap to left edge
            if (System.Math.Abs(position.X - workArea.Left) < snapDistance)
                x = (int)workArea.Left;

            // Snap to right edge
            if (Math.Abs((position.X + size.Width) - workArea.Right) < snapDistance)
                x = (int)(workArea.Right - size.Width);

            // Snap to top edge
            if (System.Math.Abs(position.Y - workArea.Top) < snapDistance)
                y = (int)workArea.Top;

            // Snap to bottom edge
            if (System.Math.Abs((position.Y + size.Height) - workArea.Bottom) < snapDistance)
                y = (int)(workArea.Bottom - size.Height);

            Move(x, y);
        }

        private WpfScreenHelper.Screen ScreenFromPoint(Point point)
        {
            var p = new System.Windows.Point();
            p.X = point.X;
            p.Y = point.Y;  

            return WpfScreenHelper.Screen.FromPoint(p);
        }

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool IsZoomed(IntPtr hWnd);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool IsIconic(IntPtr hWnd);

        [DllImport("user32.dll")]
        [return: MarshalAs(UnmanagedType.Bool)]
        private static extern bool GetLayeredWindowAttributes(IntPtr hwnd, ref uint crKey, ref byte bAlpha, ref uint dwFlags);

        /// <summary>
        /// Removes the window border and title bar by modifying window styles.
        /// This creates a borderless window appearance.
        /// </summary>
        public void RemoveBorder()
        {
            uint style = GetWindowLong(this.Handle, GWL_STYLE);
            style &= ~(WS_CAPTION | WS_THICKFRAME | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_SYSMENU);
            SetWindowLong(this.Handle, GWL_STYLE, style);
        }

        /// <summary>
        /// Positions the window on the left half of the screen
        /// </summary>
        public bool PositionLeft()
        {
            try
            {
                // First restore the window if it's maximized or minimized
                if (IsMaximized() || IsMinimized())
                {
                    Restore();
                    System.Threading.Thread.Sleep(50); // Give OS time to complete operation
                }

                var screen = ScreenFromHandle(Handle);
                int width = (int) screen.WorkingArea.Width / 2;
                int height = (int)screen.WorkingArea.Height;

                // Special handling for known problematic window classes or Electron apps
                bool isElectronApp = IsElectronApp();
                if (isElectronApp)
                {
                    // For Electron apps like VS Code, do an extra step to ensure it works
                    // First set a different size to force a refresh
                    MoveWindow(Handle, (int)screen.WorkingArea.X, (int)screen.WorkingArea.Y, width - 1, height, true);
                    System.Threading.Thread.Sleep(10);
                }

                return MoveWindow(Handle, (int)screen.WorkingArea.X, (int)screen.WorkingArea.Y, width, height, true);
            }
            catch
            {
                // Fallback to basic implementation if anything goes wrong
                try
                {
                    var screen = ScreenFromHandle(Handle);
                    int width = (int)screen.WorkingArea.Width / 2;
                    int height = (int)screen.WorkingArea.Height;
                    return MoveWindow(Handle, (int)screen.WorkingArea.X, (int)screen.WorkingArea.Y, width, height, true);
                }
                catch
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// Positions the window on the right half of the screen
        /// </summary>
        public bool PositionRight()
        {
            try
            {
                // First restore the window if it's maximized or minimized
                if (IsMaximized() || IsMinimized())
                {
                    Restore();
                    System.Threading.Thread.Sleep(50); // Give OS time to complete operation
                }

                var screen = ScreenFromHandle(Handle);
                int width = (int)screen.WorkingArea.Width / 2;
                int height = (int)screen.WorkingArea.Height;
                int x = (int)(screen.WorkingArea.X + screen.WorkingArea.Width - width);

                // Special handling for known problematic window classes or Electron apps
                bool isElectronApp = IsElectronApp();
                if (isElectronApp)
                {
                    // For Electron apps like VS Code, do an extra step to ensure it works
                    // First set a different size to force a refresh
                    MoveWindow(Handle, x, (int)screen.WorkingArea.Y, width - 1, height, true);
                    System.Threading.Thread.Sleep(10);
                }

                return MoveWindow(Handle, x, (int)screen.WorkingArea.Y, width, height, true);
            }
            catch
            {
                // Fallback to basic implementation if anything goes wrong
                try
                {
                    var screen = ScreenFromHandle(Handle);
                    int width = (int)screen.WorkingArea.Width / 2;
                    int height = (int)screen.WorkingArea.Height;
                    int x = (int)(screen.WorkingArea.X + screen.WorkingArea.Width - width);
                    return MoveWindow(Handle, x, (int)screen.WorkingArea.Y, width, height, true);
                }
                catch
                {
                    return false;
                }
            }
        }

        /// <summary>
        /// Positions the window on the top half of the screen
        /// </summary>
        public bool PositionTop()
        {
            var screen = ScreenFromHandle(Handle);
            int width = (int)screen.WorkingArea.Width;
            int height = (int)screen.WorkingArea.Height / 2;
            return MoveWindow(Handle, (int)screen.WorkingArea.X, (int)screen.WorkingArea.Y, width, height, true);
        }

        /// <summary>
        /// Positions the window on the bottom half of the screen
        /// </summary>
        public bool PositionBottom()
        {
            var screen = ScreenFromHandle(Handle);
            int width = (int)screen.WorkingArea.Width;
            int height = (int)screen.WorkingArea.Height / 2;
            int y = (int) (screen.WorkingArea.Y + screen.WorkingArea.Height - height);
            return MoveWindow(Handle, (int)screen.WorkingArea.X, y, width, height, true);
        }

        /// <summary>
        /// Positions the window in the top-left corner of the screen (quarter screen)
        /// </summary>
        public bool PositionTopLeft()
        {
            var screen = ScreenFromHandle(Handle);
            int width = (int)screen.WorkingArea.Width / 2;
            int height = (int)screen.WorkingArea.Height / 2;
            return MoveWindow(Handle, (int)screen.WorkingArea.X, (int)screen.WorkingArea.Y, width, height, true);
        }

        /// <summary>
        /// Positions the window in the top-right corner of the screen (quarter screen)
        /// </summary>
        public bool PositionTopRight()
        {
            var screen = ScreenFromHandle(Handle);
            int width = (int)screen.WorkingArea.Width / 2;
            int height = (int)screen.WorkingArea.Height / 2;
            int x = (int) (screen.WorkingArea.X + screen.WorkingArea.Width - width);
            return MoveWindow(Handle, x, (int)screen.WorkingArea.Y, width, height, true);
        }

        /// <summary>
        /// Positions the window in the bottom-left corner of the screen (quarter screen)
        /// </summary>
        public bool PositionBottomLeft()
        {
            var screen = ScreenFromHandle(Handle);
            int width = (int)screen.WorkingArea.Width / 2;
            int height = (int)screen.WorkingArea.Height / 2;
            int y = (int) (screen.WorkingArea.Y + screen.WorkingArea.Height - height);
            return MoveWindow(Handle, (int)screen.WorkingArea.X, y, width, height, true);
        }

        /// <summary>
        /// Positions the window in the bottom-right corner of the screen (quarter screen)
        /// </summary>
        public bool PositionBottomRight()
        {
            var screen = ScreenFromHandle(Handle);
            int width = (int)screen.WorkingArea.Width / 2;
            int height = (int)screen.WorkingArea.Height / 2;
            int x = (int) (screen.WorkingArea.X + screen.WorkingArea.Width - width);
            int y = (int) (screen.WorkingArea.Y + screen.WorkingArea.Height - height);
            return MoveWindow(Handle, x, y, width, height, true);
        }

        /// <summary>
        /// Positions the window in the center of the screen
        /// </summary>
        public bool PositionCentered()
        {
            var screen = ScreenFromHandle(Handle);
            int width = (int)(screen.WorkingArea.Width * 0.8);
            int height = (int)(screen.WorkingArea.Height * 0.8);
            int x = (int) (screen.WorkingArea.X + (screen.WorkingArea.Width - width) / 2);
            int y = (int) (screen.WorkingArea.Y + (screen.WorkingArea.Height - height) / 2);
            return MoveWindow(Handle, x, y, width, height, true);
        }

        private WpfScreenHelper.Screen ScreenFromHandle(IntPtr handle)
        {
            return WpfScreenHelper.Screen.FromHandle(handle);
        }

        /// <summary>
        /// Positions the window to fill the entire screen (without maximizing)
        /// </summary>
        public bool PositionFullscreen()
        {
            var screen = ScreenFromHandle(Handle);
            return MoveWindow(Handle, (int)screen.WorkingArea.X, (int)screen.WorkingArea.Y,
                             (int)screen.WorkingArea.Width, (int)(int)screen.WorkingArea.Height, true);
        }

        /// <summary>
        /// Moves the window to a specified monitor
        /// </summary>
        /// <param name="monitorIndex">Monitor index: 0=primary, 1+=specific monitor (1-based index), -2=secondary monitor</param>
        /// <param name="preserveState">If true, preserves maximized/minimized state after moving</param>
        /// <returns>True if successful</returns>
        public bool MoveToMonitor(int monitorIndex, bool preserveState = true)
        {
            // Save current window state
            bool wasMaximized = IsMaximized();
            bool wasMinimized = IsMinimized();

            // Need to restore window before moving if it's maximized/minimized
            if (wasMaximized || wasMinimized)
            {
                Restore();
                System.Threading.Thread.Sleep(100); // Give OS time to complete the operation
            }

            // Get current size
            var size = Size();

            // Get all available screens
            var allScreens = WpfScreenHelper.Screen.AllScreens.ToList();
            WpfScreenHelper.Screen targetScreen = null;

            // Determine target monitor
            if (monitorIndex == 0)
            {
                // Primary monitor
                targetScreen = WpfScreenHelper.Screen.PrimaryScreen;
            }
            else if (monitorIndex == -2)
            {
                // Try to get from global variable in PowerShell
                // Default to secondary monitor if available, or current monitor
                try
                {
                    // We can't access PowerShell variables directly, so we'll rely on the caller
                    // to translate the -2 value appropriately
                    if (allScreens.Count > 1)
                    {
                        // Use second monitor as default secondary
                        targetScreen = allScreens[1];
                    }
                    else
                    {
                        // Fall back to primary if only one monitor
                        targetScreen = WpfScreenHelper.Screen.PrimaryScreen;
                    }
                }
                catch
                {
                    // Default to primary if anything goes wrong
                    targetScreen = WpfScreenHelper.Screen.PrimaryScreen;
                }
            }
            else if (monitorIndex > 0 && monitorIndex <= allScreens.Count)
            {
                // Specific monitor (1-based index)
                targetScreen = allScreens[monitorIndex - 1];
            }
            else
            {
                // Invalid monitor index, use current
                targetScreen = WpfScreenHelper.Screen.FromHandle(Handle);
            }

            // Center window on target monitor's working area
            int newX = (int)targetScreen.WorkingArea.X + (int)((targetScreen.WorkingArea.Width - size.Width) / 2.0);
            int newY = (int)targetScreen.WorkingArea.Y + (int)((targetScreen.WorkingArea.Height - size.Height) / 2.0);

            // Move window to new position
            bool result = Move(newX, newY);

            // Restore previous state if requested
            if (preserveState)
            {
                if (wasMaximized)
                {
                    Maximize();
                }
                else if (wasMinimized)
                {
                    Minimize();
                }
            }

            return result;
        }

        /// <summary>
        /// Gets the index of the monitor that the window is currently on
        /// </summary>
        /// <returns>
        /// Monitor index where the window is located:
        /// 0 = primary monitor
        /// 1+ = specific monitor (1-based index)
        /// -1 = unable to determine
        /// </returns>
        public int GetCurrentMonitor()
        {
            try
            {
                // Get window position (center point of the window)
                var windowRect = new RectStruct();
                GetWindowRect(Handle, ref windowRect);
                int centerX = windowRect.Left + ((windowRect.Right - windowRect.Left) / 2);
                int centerY = windowRect.Top + ((windowRect.Bottom - windowRect.Top) / 2);

                // Get all screens
                var allScreens = WpfScreenHelper.Screen.AllScreens.ToList();

                // Find which screen contains this point
                for (int i = 0; i < allScreens.Count; i++)
                {
                    var screen = allScreens[i];
                    if (centerX >= screen.Bounds.Left && centerX <= screen.Bounds.Right &&
                        centerY >= screen.Bounds.Top && centerY <= screen.Bounds.Bottom)
                    {
                        return i;
                    }
                }

                // If we reach here, try a different approach using FromHandle
                return 0;
            }
            catch
            {
                return 0;
            }
        }

        // Add helper method to detect Electron apps like VS Code
        /// <summary>
        /// Determines if the window belongs to an Electron-based application.
        /// Electron apps have specific window class names and process names.
        /// </summary>
        /// <returns>True if the window is from an Electron app</returns>
        private bool IsElectronApp()
        {
            // Check window class name first
            if (WindowClassName.Contains("Chrome_WidgetWin") ||
                WindowClassName.Contains("Electron") ||
                Title.Contains("Visual Studio Code"))
            {
                return true;
            }

            // Try to get process name as additional check
            try
            {
                uint processId = 0;
                GetWindowThreadProcessId(Handle, out processId);
                if (processId != 0)
                {
                    var process = System.Diagnostics.Process.GetProcessById((int)processId);
                    string procName = process?.ProcessName?.ToLowerInvariant() ?? "";
                    return procName.Contains("code") || procName.Contains("electron");
                }
            }
            catch
            {
                // Ignore errors in process identification
            }

            return false;
        }

        // Helper struct for docked state
        /// <summary>
        /// Structure that tracks which edges and corners of the screen
        /// the window is docked to.
        /// </summary>
        private struct DockedState
        {
            public bool Left;
            public bool Top;
            public bool Right;
            public bool Bottom;
            public bool LeftTop;
            public bool TopRight;
            public bool BottomLeft;
            public bool BottomRight;
        }

        // Helper method to calculate docked state
        /// <summary>
        /// Calculates the current docking state of the window based on its position
        /// and size relative to the monitor's work area.
        /// </summary>
        /// <returns>A DockedState struct indicating which edges/corners are docked</returns>
        private DockedState GetDockedState()
        {
            var state = new DockedState();

            if (IsMaximized()) return state;  // Maximized windows are not considered docked

            // Get current screen
            var allScreens = WpfScreenHelper.Screen.AllScreens.ToList();
            var monitorIndex = GetCurrentMonitor();
            if (monitorIndex < 0 || monitorIndex >= allScreens.Count)
                return state;

            var currentScreen = allScreens[monitorIndex];

            // Get window position and size
            var position = Position();
            var size = Size();

            // Calculate relative position within monitor's work area
            var workArea = currentScreen.WorkingArea;
            var relativeX = (position.X - workArea.X) / (double)workArea.Width;
            var relativeY = (position.Y - workArea.Y) / (double)workArea.Height;
            var relativeWidth = size.Width / (double)workArea.Width;
            var relativeHeight = size.Height / (double)workArea.Height;

            double tolerance = 0.02; // 2% tolerance for position detection
            double sizeTolerance = 0.4; // 40% minimum size to consider positioned

            // Detect docking based on relative position and size
            if (relativeWidth >= sizeTolerance)
            {
                if (relativeX <= tolerance)
                {
                    state.Left = true;
                }
                else if ((relativeX + relativeWidth) >= (1.0 - tolerance))
                {
                    state.Right = true;
                }
            }
            if (relativeHeight >= sizeTolerance)
            {
                if (relativeY <= tolerance)
                {
                    state.Top = true;
                }
                else if ((relativeY + relativeHeight) >= (1.0 - tolerance))
                {
                    state.Bottom = true;
                }
            }

            // Detect corner docking
            if (state.Left && state.Top)
            {
                state.LeftTop = true;
            }
            if (state.Top && state.Right)
            {
                state.TopRight = true;
            }
            if (state.Bottom && state.Left)
            {
                state.BottomLeft = true;
            }
            if (state.Bottom && state.Right)
            {
                state.BottomRight = true;
            }

            return state;
        }

        // Properties for Get-WindowPosition hashtable compatibility
        public int MonitorIndex
        {
            get { return GetCurrentMonitor(); }
            set
            {
                // Get current docked state before moving
                var dockedState = GetDockedState();
                bool wasDocked = dockedState.Left || dockedState.Top || dockedState.Right || dockedState.Bottom;

                // Move to new monitor
                MoveToMonitor(value);

                // If was docked, restore docking on new monitor
                if (wasDocked)
                {
                    if (dockedState.LeftTop)
                        PositionTopLeft();
                    else if (dockedState.TopRight)
                        PositionTopRight();
                    else if (dockedState.BottomLeft)
                        PositionBottomLeft();
                    else if (dockedState.BottomRight)
                        PositionBottomRight();
                    else if (dockedState.Left)
                        PositionLeft();
                    else if (dockedState.Right)
                        PositionRight();
                    else if (dockedState.Top)
                        PositionTop();
                    else if (dockedState.Bottom)
                        PositionBottom();
                }
                else
                {
                    int currentMonitor = GetCurrentMonitor();
                    if (value == currentMonitor) return;
                    var allScreens = WpfScreenHelper.Screen.AllScreens.ToList();
                    if (value < 0 || value >= allScreens.Count) return;
                    var currentScreen = allScreens[currentMonitor];
                    var newScreen = allScreens[value];
                    // Get current position and size
                    var position = Position();
                    var size = Size();
                    // Current work area
                    var currentWorkArea = currentScreen.WorkingArea;
                    // Calculate relative
                    double relativeX = (position.X - currentWorkArea.X) / (double)currentWorkArea.Width;
                    double relativeY = (position.Y - currentWorkArea.Y) / (double)currentWorkArea.Height;
                    double relativeWidth = size.Width / (double)currentWorkArea.Width;
                    double relativeHeight = size.Height / (double)currentWorkArea.Height;
                    // New work area
                    var newWorkArea = newScreen.WorkingArea;
                    // New position and size
                    int newX = (int)Math.Round(newWorkArea.X + relativeX * newWorkArea.Width);
                    int newY = (int)Math.Round(newWorkArea.Y + relativeY * newWorkArea.Height);
                    int newWidth = (int)Math.Round(relativeWidth * newWorkArea.Width);
                    int newHeight = (int)Math.Round(relativeHeight * newWorkArea.Height);
                    // Set position and size
                    SetWindowPos(Handle, IntPtr.Zero, newX, newY, newWidth, newHeight, DesktopInfo.SWP_NOZORDER);
                }
            }
        }

        public int Monitor
        {
            get { return MonitorIndex + 1; }
            set { MonitorIndex = value - 1; }
        }

        public bool DockedLeft
        {
            get { return GetDockedState().Left; }
            set
            {
                if (value)
                {
                    PositionLeft();
                }
                else
                {
                    var ds = GetDockedState();
                    if (ds.LeftTop)
                    {
                        PositionTop();

                    }
                    else if (ds.BottomLeft)
                    {
                        PositionBottom();
                    }
                    else if (ds.Left)
                    {                                              // Move to center if only left docked
                        PositionCentered();
                    }
                }
            }
        }

        public bool DockedTop
        {
            get { return GetDockedState().Top; }
            set
            {
                if (value)
                {
                    PositionTop();
                }
                else
                {
                    var ds = GetDockedState();
                    if (ds.LeftTop)
                    {
                        PositionLeft();
                    }
                    else if (ds.TopRight)
                    {
                        PositionRight();
                    }
                    else if (ds.Top)
                    {                                              // Move to center if only top docked
                        PositionCentered();
                    }
                }
            }
        }

        public bool DockedRight
        {
            get { return GetDockedState().Right; }
            set
            {
                if (value)
                {
                    PositionRight();
                }
                else
                {
                    var ds = GetDockedState();
                    if (ds.TopRight)
                    {
                        PositionTop();
                    }
                    else if (ds.BottomRight)
                    {
                        PositionBottom();
                    }
                    else if (ds.Right)
                    {                                              // Move to center if only right docked
                        PositionCentered();
                    }
                }
            }
        }

        public bool DockedBottom
        {
            get { return GetDockedState().Bottom; }
            set
            {
                if (value)
                {
                    PositionBottom();
                }
                else
                {
                    var ds = GetDockedState();
                    if (ds.BottomLeft)
                    {
                        PositionLeft();
                    }
                    else if (ds.BottomRight)
                    {
                        PositionRight();
                    }
                    else if (ds.Bottom)
                    {                                              // Move to center if only bottom docked
                        PositionCentered();
                    }
                }
            }
        }

        public bool DockedLeftTop
        {
            get { return GetDockedState().LeftTop; }
            set
            {
                if (value)
                {
                    PositionTopLeft();
                }
                else
                {
                    var ds = GetDockedState();
                    if (ds.LeftTop)
                    {
                        PositionCentered();
                    }
                }
            }
        }

        public bool DockedTopRight
        {
            get { return GetDockedState().TopRight; }
            set
            {
                if (value)
                {
                    PositionTopRight();
                }
                else
                {
                    var ds = GetDockedState();
                    if (ds.TopRight)
                    {
                        PositionCentered();
                    }
                }
            }
        }

        public bool DockedBottomLeft
        {
            get { return GetDockedState().BottomLeft; }
            set
            {
                if (value)
                {
                    PositionBottomLeft();
                }
                else
                {
                    var ds = GetDockedState();
                    if (ds.BottomLeft)
                    {
                        PositionCentered();
                    }
                }

            }
        }

        public bool DockedBottomRight
        {
            get { return GetDockedState().BottomRight; }
            set
            {
                if (value)
                {
                    PositionBottomRight();
                }
                else
                {
                    var ds = GetDockedState();
                    if (ds.BottomRight)
                    {
                        PositionCentered();
                    }
                }
            }
        }

        public bool IsRestored
        {
            get { return !IsMinimized() && !IsMaximized(); }
            set
            {
                if (value)
                {
                    Restore();
                }
                else
                {
                    Minimize();
                }
            }
        }

        public bool IsHidden
        {
            get { return !IsVisible(); }
            set
            {
                if (value)
                {
                    Hide();
                }
                else
                {
                    Show();
                }
            }
        }

        public Process Process
        {
            get
            {
                try
                {
                    uint processId = 0;
                    GetWindowThreadProcessId(Handle, out processId);
                    return Process.GetProcessById((int)processId);
                }
                catch
                {
                    return null;
                }
            }
        }

        public bool HasFocus
        {
            get
            {
                var focused = GetFocusedWindow();
                return focused != null && focused.Handle == Handle;
            }
            set
            {
                if (value)
                {
                    Focus();
                }
            }
        }

        public bool IsInForeground
        {
            get { return HasFocus; }
            set
            {
                if (value)
                {
                    SetForeground();
                }
                else
                {
                    SetBackground();
                }
            }
        }

        /// <summary>
        /// Sends the window to the background by positioning it at the bottom of the Z-order.
        /// </summary>
        private void SetBackground()
        {
            // Send window to back using SetWindowPos with HWND_BOTTOM
            SetWindowPos(this.Handle, new IntPtr(1), 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE);
        }

        [DllImport("user32.dll")]
        public static extern bool AttachThreadInput(uint idAttach, uint idAttachTo, bool fAttach);

        [DllImport("user32.dll")]
        public static extern bool BringWindowToTop(IntPtr hWnd);

        /// <summary>
        /// Gets the parent process of the specified process
        /// </summary>
        /// <param name="process">The process to find the parent for</param>
        /// <returns>The parent process, or null if not found</returns>
        private static Process GetParentProcess(Process process)
        {
            try
            {
                var parentId = GetParentProcessId(process.Id);
                return parentId > 0 ? Process.GetProcessById(parentId) : null;
            }
            catch
            {
                return null;
            }
        }

        /// <summary>
        /// Gets the parent process ID using WMI
        /// </summary>
        /// <param name="processId">The process ID to find the parent for</param>
        /// <returns>The parent process ID, or 0 if not found</returns>
        private static int GetParentProcessId(int processId)
        {
            try
            {
                using (var searcher = new System.Management.ManagementObjectSearcher(
                    $"SELECT ParentProcessId FROM Win32_Process WHERE ProcessId = {processId}"))
                {
                    using (var results = searcher.Get())
                    {
                        var result = results.Cast<System.Management.ManagementObject>().FirstOrDefault();
                        return result != null ? Convert.ToInt32(result["ParentProcessId"]) : 0;
                    }
                }
            }
            catch
            {
                return 0;
            }
        }

        /// <summary>
        /// Determines if a process name suggests it's likely a terminal or host application
        /// </summary>
        /// <param name="processName">The process name to check</param>
        /// <returns>True if the process name indicates a terminal/host app</returns>
        private static bool IsLikelyHostProcess(string processName)
        {
            if (string.IsNullOrEmpty(processName))
                return false;

            var name = processName.ToLowerInvariant();

            // Common terminal/host process names
            return name.Contains("terminal") ||
                   name.Contains("console") ||
                   name.Contains("cmd") ||
                   name.Contains("conhost") ||
                   name.Contains("wsl") ||
                   name.Contains("bash") ||
                   name.Contains("ssh") ||
                   name.Contains("cursor") ||
                   name.Contains("putty") ||
                   name.Contains("code") ||          // VS Code
                   name.Contains("code - insiders") ||          // VS Code
                   name.Contains("idea") ||          // IntelliJ
                   name.Contains("eclipse") ||       // Eclipse
                   name.Contains("cmder") ||         // Cmder
                   name.Contains("conemu") ||        // ConEmu
                   name.Contains("hyper") ||         // Hyper terminal
                   name.Contains("alacritty") ||     // Alacritty
                   name.Contains("kitty") ||         // Kitty terminal
                   name.Contains("iterm") ||         // iTerm (if running on Windows via compatibility)
                   name.Contains("mintty");          // MinTTY (Git Bash, etc.)
        }
    }
}

