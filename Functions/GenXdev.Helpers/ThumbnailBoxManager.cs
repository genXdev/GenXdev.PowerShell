using System.Collections.Concurrent;
using System.Diagnostics;
using System.Runtime.InteropServices;

namespace GenXdev.Helpers
{
    public sealed class ThumbnailBoxManager : IDisposable
    {
        private sealed class Source
        {
            public int Id;
            public Process Process;
            public bool Managed;
            public string Title;
            public IntPtr Hwnd;
            public IntPtr Thumb;
            public EventHandler ProcessExitedHandler;
            public byte Transparency = 255;
            public uint BorderColor = 0xFFFFFF;
            public uint TitleColor = 0x000000;

            // Layout & Offscreen cache to prevent redundant updates
            public RECT CellRect;
            public RECT TitleRect;
            public int LastOffscreenW;
            public int LastOffscreenH;
        }

        // ------------------------------------------------------------------
        // Constants & Win32
        // ------------------------------------------------------------------
        private const uint WS_POPUP = 0x80000000;
        private const uint WS_CAPTION = 0x00C00000;
        private const uint WS_THICKFRAME = 0x00040000;
        private const uint WS_SYSMENU = 0x00080000;
        private const uint WS_MINIMIZEBOX = 0x00020000;
        private const uint WS_MAXIMIZEBOX = 0x00010000;
        private const uint WS_BORDER = 0x00800000;
        private const uint WS_DLGFRAME = 0x00400000;

        private const uint WS_EX_TRANSPARENT = 0x00000020;
        private const uint WS_EX_TOPMOST = 0x00000008;
        private const uint WS_EX_NOACTIVATE = 0x08000000;
        private const uint WS_EX_TOOLWINDOW = 0x00000080;
        private const uint WS_EX_LAYERED = 0x00080000;

        private const int GWL_STYLE = -16;
        private const int GWL_EXSTYLE = -20;
        private const int GWLP_USERDATA = -21;

        private const uint SWP_NOMOVE = 0x0002;
        private const uint SWP_NOSIZE = 0x0001;
        private const uint SWP_NOZORDER = 0x0004;
        private const uint SWP_NOACTIVATE = 0x0010;
        private const uint SWP_SHOWWINDOW = 0x0040;
        private const uint SWP_FRAMECHANGED = 0x0020;

        private const int SW_SHOWNOACTIVATE = 4;
        private const int SW_HIDE = 0;

        private const uint STARTF_USESHOWWINDOW = 0x00000001;
        private const uint STARTF_USEPOSITION = 0x00000004;
        private const uint CREATE_NEW_CONSOLE = 0x00000010;
        private const uint BELOW_NORMAL_PRIORITY_CLASS = 0x00004000;
        private const uint STATUS_COLOR_RED = 0x000000FF;    // COLORREF red
        private const uint STATUS_COLOR_GREEN = 0x0000FF00;  // COLORREF green

        private const uint WM_DESTROY = 0x0002;
        private const uint WM_PAINT = 0x000F;
        private const uint WM_ERASEBKGND = 0x0014;
        private const uint WM_CLOSE = 0x0010;
        private const uint WM_NCCREATE = 0x0081;
        private const uint WM_NCHITTEST = 0x0084;
        private const uint WM_APP_REFLOW = 0x8001;

        private const int HTTRANSPARENT = -1;
        private const int TRANSPARENT = 1;   // SetBkMode TRANSPARENT
        private const int RGN_OR = 2;        // CombineRgn
        private const uint GW_OWNER = 4;     // GetWindow

        private const int LWA_ALPHA = 0x2;
        private const int LWA_COLORKEY = 0x1;

        private const uint JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE = 0x2000;
        private const int JobObjectExtendedLimitInformation = 9;

        private const int DWM_TNP_RECTDESTINATION = 0x1;
        private const int DWM_TNP_RECTSOURCE = 0x2;
        private const int DWM_TNP_OPACITY = 0x4;
        private const int DWM_TNP_VISIBLE = 0x8;
        private const int DWM_TNP_SOURCECLIENTAREAONLY = 0x10;

        private const uint TH32CS_SNAPPROCESS = 0x00000002;
        private const int SM_CXSCREEN = 0;
        private const int SM_CYSCREEN = 1;
        private const int SM_CYCAPTION = 4;
        private const int SM_CXFRAME = 32;
        private const int SM_CYFRAME = 33;
        private const int SM_CXVIRTUALSCREEN = 78;
        private const int SM_CYVIRTUALSCREEN = 79;

        private const int MinSourceDim = 160;
        private const int OffScreenX = -32000;
        private const int OffScreenY = -32000;

        private static readonly IntPtr INVALID_HANDLE_VALUE = new(-1);
        private static readonly IntPtr HWND_TOPMOST = new(-1);
        private static readonly IntPtr HWND_NOTOPMOST = new(-2);

        [StructLayout(LayoutKind.Sequential)]
        private struct RECT
        {
            public int Left;
            public int Top;
            public int Right;
            public int Bottom;
            public int Width => Right - Left;
            public int Height => Bottom - Top;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct MARGINS
        {
            public int cxLeftWidth;
            public int cxRightWidth;
            public int cyTopHeight;
            public int cyBottomHeight;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct POINT
        {
            public int X;
            public int Y;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct MSG
        {
            public IntPtr hwnd;
            public uint message;
            public IntPtr wParam;
            public IntPtr lParam;
            public uint time;
            public POINT pt;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct DWM_THUMBNAIL_PROPERTIES
        {
            public int dwFlags;
            public RECT rcDestination;
            public RECT rcSource;
            public byte opacity;
            public int fVisible;
            public int fSourceClientAreaOnly;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct PAINTSTRUCT
        {
            public IntPtr hdc;
            public int fErase;
            public RECT rcPaint;
            public int fRestore;
            public int fIncUpdate;
            [MarshalAs(UnmanagedType.ByValArray, SizeConst = 32)]
            public byte[] rgbReserved;
        }

        private delegate IntPtr WNDPROC(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);

        private delegate bool EnumWindowsProc(IntPtr hWnd, IntPtr lParam);

        [StructLayout(LayoutKind.Sequential)]
        private struct WNDCLASSEX
        {
            public uint cbSize;
            public uint style;
            public IntPtr lpfnWndProc;
            public int cbClsExtra;
            public int cbWndExtra;
            public IntPtr hInstance;
            public IntPtr hIcon;
            public IntPtr hCursor;
            public IntPtr hbrBackground;
            public IntPtr lpszMenuName;
            public IntPtr lpszClassName;
            public IntPtr hIconSm;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct CREATESTRUCT
        {
            public IntPtr lpCreateParams;
            public IntPtr hInstance;
            public IntPtr hMenu;
            public IntPtr hwndParent;
            public int cy;
            public int cx;
            public int y;
            public int x;
            public int style;
            public IntPtr lpszName;
            public IntPtr lpszClass;
            public int dwExStyle;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct PROCESSENTRY32W
        {
            public uint dwSize;
            public uint cntUsage;
            public uint th32ProcessID;
            public IntPtr th32DefaultHeapID;
            public uint th32ModuleID;
            public uint cntThreads;
            public uint th32ParentProcessID;
            public int pcPriClassBase;
            public uint dwFlags;
            [MarshalAs(UnmanagedType.ByValTStr, SizeConst = 260)]
            public string szExeFile;
        }

        [StructLayout(LayoutKind.Sequential, CharSet = CharSet.Unicode)]
        private struct STARTUPINFO
        {
            public uint cb;
            public string lpReserved;
            public string lpDesktop;
            public string lpTitle;
            public int dwX;
            public int dwY;
            public int dwXSize;
            public int dwYSize;
            public int dwXCountChars;
            public int dwYCountChars;
            public int dwFillAttribute;
            public uint dwFlags;
            public ushort wShowWindow;
            public ushort cbReserved2;
            public IntPtr lpReserved2;
            public IntPtr hStdInput;
            public IntPtr hStdOutput;
            public IntPtr hStdError;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct PROCESS_INFORMATION
        {
            public IntPtr hProcess;
            public IntPtr hThread;
            public uint dwProcessId;
            public uint dwThreadId;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct IO_COUNTERS
        {
            public ulong ReadOperationCount;
            public ulong WriteOperationCount;
            public ulong OtherOperationCount;
            public ulong ReadTransferCount;
            public ulong WriteTransferCount;
            public ulong OtherTransferCount;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct JOBOBJECT_BASIC_LIMIT_INFORMATION
        {
            public long PerProcessUserTimeLimit;
            public long PerJobUserTimeLimit;
            public uint LimitFlags;
            public UIntPtr MinimumWorkingSetSize;
            public UIntPtr MaximumWorkingSetSize;
            public uint ActiveProcessLimit;
            public UIntPtr Affinity;
            public uint PriorityClass;
            public uint SchedulingClass;
        }

        [StructLayout(LayoutKind.Sequential)]
        private struct JOBOBJECT_EXTENDED_LIMIT_INFORMATION
        {
            public JOBOBJECT_BASIC_LIMIT_INFORMATION BasicLimitInformation;
            public IO_COUNTERS IoInfo;
            public UIntPtr ProcessMemoryLimit;
            public UIntPtr JobMemoryLimit;
            public UIntPtr PeakProcessMemoryUsed;
            public UIntPtr PeakJobMemoryUsed;
        }

        // P/Invoke Declarations
        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern ushort RegisterClassEx(ref WNDCLASSEX lpwcx);

        [DllImport("user32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern IntPtr CreateWindowEx(
            uint dwExStyle, string lpClassName, string lpWindowName, uint dwStyle,
            int x, int y, int nWidth, int nHeight,
            IntPtr hWndParent, IntPtr hMenu, IntPtr hInstance, IntPtr lpParam);

        [DllImport("user32.dll")]
        private static extern IntPtr DefWindowProc(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam);

        [DllImport("user32.dll")]
        private static extern bool DestroyWindow(IntPtr hWnd);

        [DllImport("user32.dll", CharSet = CharSet.Unicode)]
        private static extern bool UnregisterClass(string lpClassName, IntPtr hInstance);

        [DllImport("user32.dll")]
        private static extern int GetMessage(out MSG lpMsg, IntPtr hWnd, uint wMsgFilterMin, uint wMsgFilterMax);

        [DllImport("user32.dll")]
        private static extern bool TranslateMessage(ref MSG lpMsg);

        [DllImport("user32.dll")]
        private static extern IntPtr DispatchMessage(ref MSG lpMsg);

        [DllImport("user32.dll")]
        private static extern void PostQuitMessage(int nExitCode);

        [DllImport("user32.dll")]
        private static extern bool PostMessage(IntPtr hWnd, uint Msg, IntPtr wParam, IntPtr lParam);

        [DllImport("user32.dll", SetLastError = true)]
        private static extern bool SetWindowPos(IntPtr hWnd, IntPtr hWndInsertAfter, int X, int Y, int cx, int cy, uint uFlags);

        [DllImport("user32.dll")]
        private static extern bool GetWindowRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll")]
        private static extern bool GetClientRect(IntPtr hWnd, out RECT lpRect);

        [DllImport("user32.dll")]
        private static extern bool ClientToScreen(IntPtr hWnd, ref POINT lpPoint);

        [DllImport("user32.dll")]
        private static extern bool MoveWindow(IntPtr hWnd, int X, int Y, int nWidth, int nHeight, bool bRepaint);

        [DllImport("user32.dll", EntryPoint = "GetWindowLongPtrW", SetLastError = true)]
        private static extern IntPtr GetWindowLongPtr(IntPtr hWnd, int nIndex);

        [DllImport("user32.dll", EntryPoint = "SetWindowLongPtrW", SetLastError = true)]
        private static extern IntPtr SetWindowLongPtr(IntPtr hWnd, int nIndex, IntPtr dwNewLong);

        [DllImport("user32.dll")]
        private static extern bool ShowWindow(IntPtr hWnd, int nCmdShow);

        [DllImport("user32.dll")]
        private static extern bool SetForegroundWindow(IntPtr hWnd);

        [DllImport("user32.dll")]
        private static extern bool SetLayeredWindowAttributes(IntPtr hwnd, uint crKey, byte bAlpha, uint dwFlags);

        [DllImport("user32.dll")]
        private static extern bool IsIconic(IntPtr hWnd);

        [DllImport("user32.dll")]
        private static extern IntPtr GetForegroundWindow();

        [DllImport("user32.dll")]
        private static extern IntPtr GetWindow(IntPtr hWnd, uint uCmd);

        [DllImport("user32.dll")]
        private static extern bool EnumWindows(EnumWindowsProc lpEnumFunc, IntPtr lParam);

        [DllImport("user32.dll")]
        private static extern uint GetWindowThreadProcessId(IntPtr hWnd, out uint lpdwProcessId);

        [DllImport("user32.dll")]
        private static extern bool IsWindowVisible(IntPtr hWnd);

        [DllImport("user32.dll")]
        private static extern int SetWindowRgn(IntPtr hWnd, IntPtr hRgn, bool bRedraw);

        [DllImport("user32.dll")]
        private static extern IntPtr BeginPaint(IntPtr hwnd, out PAINTSTRUCT lpPaint);

        [DllImport("user32.dll")]
        private static extern bool EndPaint(IntPtr hwnd, ref PAINTSTRUCT lpPaint);

        [DllImport("user32.dll")]
        private static extern bool InvalidateRect(IntPtr hwnd, IntPtr lpRect, bool bErase);

        [DllImport("user32.dll")]
        private static extern int GetSystemMetrics(int nIndex);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode)]
        private static extern IntPtr GetModuleHandle(string lpModuleName);

        [DllImport("kernel32.dll")]
        private static extern IntPtr GetConsoleWindow();

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern IntPtr CreateToolhelp32Snapshot(uint dwFlags, uint th32ProcessID);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool Process32FirstW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool Process32NextW(IntPtr hSnapshot, ref PROCESSENTRY32W lppe);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool CloseHandle(IntPtr hObject);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern IntPtr CreateJobObject(IntPtr lpJobAttributes, string lpName);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool SetInformationJobObject(
            IntPtr hJob,
            int JobObjectInfoClass,
            ref JOBOBJECT_EXTENDED_LIMIT_INFORMATION lpJobObjectInfo,
            uint cbJobObjectInfoLength);

        [DllImport("kernel32.dll", SetLastError = true)]
        private static extern bool AssignProcessToJobObject(IntPtr hJob, IntPtr hProcess);

        [DllImport("kernel32.dll", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern bool CreateProcess(
            string lpApplicationName,
            System.Text.StringBuilder lpCommandLine,
            IntPtr lpProcessAttributes,
            IntPtr lpThreadAttributes,
            bool bInheritHandles,
            uint dwCreationFlags,
            IntPtr lpEnvironment,
            string lpCurrentDirectory,
            ref STARTUPINFO lpStartupInfo,
            out PROCESS_INFORMATION lpProcessInformation);

        [DllImport("gdi32.dll")]
        private static extern IntPtr CreateSolidBrush(uint crColor);

        [DllImport("gdi32.dll")]
        private static extern bool DeleteObject(IntPtr hObject);

        [DllImport("gdi32.dll")]
        private static extern IntPtr CreatePen(int nPenStyle, int nWidth, uint crColor);

        [DllImport("gdi32.dll")]
        private static extern IntPtr SelectObject(IntPtr hdc, IntPtr hgdiobj);

        [DllImport("gdi32.dll")]
        private static extern IntPtr GetStockObject(int fnObject);

        [DllImport("gdi32.dll")]
        private static extern bool Rectangle(IntPtr hdc, int nLeftRect, int nTopRect, int nRightRect, int nBottomRect);

        [DllImport("gdi32.dll")]
        private static extern int SetTextColor(IntPtr hdc, uint crColor);

        [DllImport("gdi32.dll")]
        private static extern int SetBkColor(IntPtr hdc, uint crColor);

        [DllImport("gdi32.dll")]
        private static extern int SetBkMode(IntPtr hdc, int mode);

        [DllImport("gdi32.dll")]
        private static extern IntPtr CreateRectRgn(int nLeftRect, int nTopRect, int nRightRect, int nBottomRect);

        [DllImport("gdi32.dll")]
        private static extern int CombineRgn(IntPtr hrgnDest, IntPtr hrgnSrc1, IntPtr hrgnSrc2, int fnCombineMode);

        [DllImport("user32.dll", EntryPoint = "DrawTextW", CharSet = CharSet.Unicode, SetLastError = true)]
        private static extern int DrawTextW(IntPtr hdc, string lpchText, int cchText, ref RECT lprc, uint format);

        [DllImport("gdi32.dll")]
        private static extern IntPtr CreateCompatibleDC(IntPtr hdc);

        [DllImport("gdi32.dll")]
        private static extern IntPtr CreateCompatibleBitmap(IntPtr hdc, int nWidth, int nHeight);

        [DllImport("gdi32.dll")]
        private static extern bool DeleteDC(IntPtr hdc);

        [DllImport("gdi32.dll")]
        private static extern bool BitBlt(IntPtr hdc, int nXDest, int nYDest, int nWidth, int nHeight, IntPtr hdcSrc, int nXSrc, int nYSrc, uint dwRop);

        [DllImport("user32.dll")]
        private static extern int FillRect(IntPtr hdc, ref RECT lprc, IntPtr hbr);

        [DllImport("dwmapi.dll")]
        private static extern int DwmExtendFrameIntoClientArea(IntPtr hWnd, ref MARGINS pMarInset);

        [DllImport("dwmapi.dll")]
        private static extern int DwmRegisterThumbnail(IntPtr dest, IntPtr src, out IntPtr thumb);

        [DllImport("dwmapi.dll")]
        private static extern int DwmUnregisterThumbnail(IntPtr thumb);

        [DllImport("dwmapi.dll")]
        private static extern int DwmUpdateThumbnailProperties(IntPtr hThumb, ref DWM_THUMBNAIL_PROPERTIES props);

        // ------------------------------------------------------------------
        // Fields
        // ------------------------------------------------------------------
        private readonly ConcurrentDictionary<int, Source> _sources = new();
        private readonly Lock _sync = new();
        private readonly int _refreshMs;

        private int _topMargin;
        private int _bottomMargin;
        private int _leftMargin;
        private int _rightMargin;
        private int _thumbSpacing;

        private Thread _uiThread;
        private Task _reflowTask;
        private CancellationTokenSource _cts;
        private readonly ManualResetEventSlim _windowReady = new(false);

        private IntPtr _hostWnd = IntPtr.Zero;
        private IntPtr _chromeWnd = IntPtr.Zero;
        private IntPtr _hostTarget = IntPtr.Zero;
        private IntPtr _jobHandle = IntPtr.Zero;
        private RECT _lastHostRect;
        private bool _started;
        private bool _disposed;
        private bool _needsRedraw;
        private bool _topmost = true;
        private bool _overlayVisible;

        private static readonly WNDPROC _wndProc = WindowProc;

        public ThumbnailBoxManager(
            int refreshMs = 100,
            int? topMargin = null,
            int? bottomMargin = null,
            int? leftMargin = null,
            int? rightMargin = null,
            int? thumbSpacing = null)
        {
            _refreshMs = Math.Max(16, refreshMs);
            _topMargin = Math.Max(0, topMargin ?? GetCaptionHeight());
            _bottomMargin = Math.Max(0, bottomMargin ?? GetBottomBorderHeight());
            _leftMargin = Math.Max(0, leftMargin ?? GetLeftBorderWidth());
            _rightMargin = Math.Max(0, rightMargin ?? GetRightBorderWidth());
            _thumbSpacing = Math.Max(0, thumbSpacing ?? 0);
        }

        // ------------------------------------------------------------------
        // WndProc
        // ------------------------------------------------------------------
        private static IntPtr WindowProc(IntPtr hWnd, uint msg, IntPtr wParam, IntPtr lParam)
        {
            if (msg == WM_NCCREATE)
            {
                var cs = Marshal.PtrToStructure<CREATESTRUCT>(lParam);
                SetWindowLongPtr(hWnd, GWLP_USERDATA, cs.lpCreateParams);
                return DefWindowProc(hWnd, msg, wParam, lParam);
            }

            IntPtr ptr = GetWindowLongPtr(hWnd, GWLP_USERDATA);
            if (ptr != IntPtr.Zero)
            {
                var gc = GCHandle.FromIntPtr(ptr);
                if (gc.IsAllocated && gc.Target is ThumbnailBoxManager manager)
                {
                    if (msg == WM_APP_REFLOW)
                    {
                        manager.HandleReflow(hWnd);
                        return IntPtr.Zero;
                    }
                    else if (msg == WM_PAINT)
                    {
                        if (hWnd == manager._chromeWnd)
                            manager.HandleChromePaint(hWnd);
                        else
                            HandlePaint(hWnd);
                        return IntPtr.Zero;
                    }
                }
            }

            switch (msg)
            {
                case WM_ERASEBKGND:
                    // Prevent Win32 background erasure to stop white/black flicker completely
                    return new IntPtr(1);

                case WM_NCHITTEST:
                    return new IntPtr(HTTRANSPARENT);

                case WM_DESTROY:
                    PostQuitMessage(0);
                    return IntPtr.Zero;
            }

            return DefWindowProc(hWnd, msg, wParam, lParam);
        }

        // ------------------------------------------------------------------
        // Lifecycle
        // ------------------------------------------------------------------
        public void Start(
            int? topMargin = null,
            int? bottomMargin = null,
            int? leftMargin = null,
            int? rightMargin = null,
            int? thumbSpacing = null)
        {
            if (topMargin.HasValue) _topMargin = Math.Max(0, topMargin.Value);
            if (bottomMargin.HasValue) _bottomMargin = Math.Max(0, bottomMargin.Value);
            if (leftMargin.HasValue) _leftMargin = Math.Max(0, leftMargin.Value);
            if (rightMargin.HasValue) _rightMargin = Math.Max(0, rightMargin.Value);
            if (thumbSpacing.HasValue) _thumbSpacing = Math.Max(0, thumbSpacing.Value);

            if (_started) return;
            lock (_sync)
            {
                if (_started) return;
                _started = true;

                // Reset window-state caches so the freshly created host window
                // is laid out and shown again as if this were the first start.
                _lastHostRect = default;
                _overlayVisible = false;

                if (_jobHandle == IntPtr.Zero)
                {
                    _jobHandle = CreateJobObject(IntPtr.Zero, null);
                    if (_jobHandle != IntPtr.Zero)
                    {
                        var jobInfo = new JOBOBJECT_EXTENDED_LIMIT_INFORMATION
                        {
                            BasicLimitInformation = new JOBOBJECT_BASIC_LIMIT_INFORMATION
                            {
                                LimitFlags = JOB_OBJECT_LIMIT_KILL_ON_JOB_CLOSE
                            }
                        };
                        SetInformationJobObject(_jobHandle, JobObjectExtendedLimitInformation, ref jobInfo,
                            (uint)Marshal.SizeOf<JOBOBJECT_EXTENDED_LIMIT_INFORMATION>());
                    }
                }
                try { _cts?.Dispose(); } catch { }
                _cts = new CancellationTokenSource();
                _windowReady.Reset();
                _uiThread = new Thread(RunMessageLoop)
                {
                    IsBackground = true,
                    Name = "GenXdevThumbnailBoxHost"
                };
                _uiThread.Start();
            }
            _windowReady.Wait();
            _reflowTask = Task.Run(() => ReflowLoopAsync(_cts.Token));
        }

        public async Task StopAsync()
        {
            if (!_started) return;
            _started = false;

            try { _cts?.Cancel(); } catch { }

            if (_reflowTask != null)
            {
                try { await _reflowTask.ConfigureAwait(false); } catch { }
                _reflowTask = null;
            }

            var toRemove = _sources.Keys.ToArray();
            foreach (var id in toRemove)
            {
                _ = UnregisterAsync(id);
            }

            if (_hostWnd != IntPtr.Zero)
                PostMessage(_hostWnd, WM_CLOSE, IntPtr.Zero, IntPtr.Zero);

            if (_uiThread != null && _uiThread.IsAlive && _uiThread != Thread.CurrentThread)
                _uiThread.Join();
            _uiThread = null;

            _hostWnd = IntPtr.Zero;
            _hostTarget = IntPtr.Zero;
        }

        /// <summary>
        /// Kills every tracked process (launched and registered), unregisters
        /// all sources, then stops the thumbnail host.
        /// </summary>
        public async Task StopAll()
        {
            foreach (var src in _sources.Values.ToArray())
            {
                try
                {
                    if (src.Process != null && !src.Process.HasExited)
                        src.Process.Kill(entireProcessTree: true);
                }
                catch { }
            }

            await StopAsync().ConfigureAwait(false);
        }

        /// <summary>
        /// Kills and unregisters only launched (managed) sources. Registered
        /// normal applications remain thumbnailed and the host keeps running.
        /// </summary>
        public async Task StopAllLaunched()
        {
            var launched = _sources.Values
                .Where(s => s.Managed)
                .Select(s => s.Id)
                .ToArray();

            foreach (var id in launched)
            {
                if (_sources.TryGetValue(id, out var src))
                {
                    try
                    {
                        if (src.Process != null && !src.Process.HasExited)
                            src.Process.Kill(entireProcessTree: true);
                    }
                    catch { }
                }

                await UnregisterAsync(id).ConfigureAwait(false);
            }
        }

        public void Dispose()
        {
            if (_disposed) return;
            _disposed = true;
            try { StopAsync().GetAwaiter().GetResult(); } catch { }
            try { _windowReady.Dispose(); } catch { }
            try { _cts?.Dispose(); } catch { }
            if (_jobHandle != IntPtr.Zero)
            {
                CloseHandle(_jobHandle);
                _jobHandle = IntPtr.Zero;
            }
        }

        // ------------------------------------------------------------------
        // Launch / Register / Unregister / Update
        // ------------------------------------------------------------------
        public Process Launch(
            string fileName,
            string arguments,
            string title,
            byte? transparency = null,
            uint? borderColor = null,
            uint? titleColor = null,
            string workingDirectory = null)
        {
            EnsureStarted();

            var si = new STARTUPINFO
            {
                cb = (uint)Marshal.SizeOf<STARTUPINFO>(),
                dwFlags = STARTF_USESHOWWINDOW | STARTF_USEPOSITION,
                wShowWindow = SW_SHOWNOACTIVATE,
                dwX = OffScreenX,
                dwY = OffScreenY
            };

            var commandLine = new System.Text.StringBuilder(1024);
            commandLine.Append('"').Append(fileName).Append("\" ").Append(arguments);
            if (string.IsNullOrWhiteSpace(workingDirectory)) workingDirectory = ".\\";
            bool ok = CreateProcess(
                null, commandLine,
                IntPtr.Zero, IntPtr.Zero, false,
                CREATE_NEW_CONSOLE | BELOW_NORMAL_PRIORITY_CLASS,
                IntPtr.Zero, workingDirectory,
                ref si, out var pi);

            if (!ok)
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());

            if (pi.hThread != IntPtr.Zero) CloseHandle(pi.hThread);

            if (_jobHandle != IntPtr.Zero && pi.hProcess != IntPtr.Zero)
                AssignProcessToJobObject(_jobHandle, pi.hProcess);

            Process process;
            try
            {
                process = Process.GetProcessById((int)pi.dwProcessId);
            }
            finally
            {
                if (pi.hProcess != IntPtr.Zero) CloseHandle(pi.hProcess);
            }

            Register(process, title, transparency, borderColor, titleColor, managed: true);
            SetForegroundWindow(GetConsoleWindow());

            return process;
        }

        // ------------------------------------------------------------------
        // Launch / Register / Unregister / Update
        // ------------------------------------------------------------------
        public static Process LaunchOnly(
            string fileName,
            string arguments,
            string workingDirectory = null)
        {
            var si = new STARTUPINFO
            {
                cb = (uint)Marshal.SizeOf<STARTUPINFO>(),
                dwFlags = STARTF_USESHOWWINDOW | STARTF_USEPOSITION,
                wShowWindow = SW_SHOWNOACTIVATE,
                dwX = OffScreenX,
                dwY = OffScreenY
            };

            var commandLine = new System.Text.StringBuilder(1024);
            commandLine.Append('"').Append(fileName).Append("\" ").Append(arguments);

            bool ok = CreateProcess(
                null, commandLine,
                IntPtr.Zero, IntPtr.Zero, false,
                CREATE_NEW_CONSOLE | BELOW_NORMAL_PRIORITY_CLASS,
                IntPtr.Zero, workingDirectory,
                ref si, out var pi);

            if (!ok)
                throw new System.ComponentModel.Win32Exception(Marshal.GetLastWin32Error());

            if (pi.hThread != IntPtr.Zero) CloseHandle(pi.hThread);

            Process process;
            try
            {
                process = Process.GetProcessById((int)pi.dwProcessId);
            }
            finally
            {
                if (pi.hProcess != IntPtr.Zero) CloseHandle(pi.hProcess);
            }

            return process;
        }

        public void  Register(
            Process process,
            string title,
            byte? transparency = null,
            uint? borderColor = null,
            uint? titleColor = null,
            bool managed = false)
        {
            if (process == null || process.HasExited) return;

            EnsureStarted();

            var id = process.Id;
            var src = new Source
            {
                Id = id,
                Process = process,
                Title = title ?? string.Empty,
                Transparency = transparency ?? 255,
                BorderColor = borderColor ?? 0xFFFFFF,
                TitleColor = titleColor ?? 0x000000,
                Managed = managed
            };

            lock (_sync)
            {
                _sources[id] = src;
                AttachExited(src, id);
            }

            _needsRedraw = true;
            Reflow();
            return;
        }

        public async Task UnregisterAsync(int id)
        {
            if (_sources.TryRemove(id, out var s))
            {
                lock (_sync)
                {
                    if (s.Thumb != IntPtr.Zero)
                    {
                        try { DwmUnregisterThumbnail(s.Thumb); } catch { }
                        s.Thumb = IntPtr.Zero;
                    }
                    DetachExited(s);
                }
            }
            _needsRedraw = true;
            Reflow();

            if (_started && _sources.IsEmpty)
                await StopAsync().ConfigureAwait(false);

            await Task.CompletedTask.ConfigureAwait(false);
        }

        public async Task UnregisterAll()
        {
            foreach (var id in _sources.Keys.ToArray())
            {
                await UnregisterAsync(id).ConfigureAwait(false);
            }
        }

        public void Update(int id, string title = null, byte? transparency = null, uint? borderColor = null, uint? titleColor = null)
        {
            if (_sources.TryGetValue(id, out var src))
            {
                lock (_sync)
                {
                    if (title != null) src.Title = title;
                    if (transparency.HasValue) src.Transparency = transparency.Value;
                    if (borderColor.HasValue) src.BorderColor = borderColor.Value;
                    if (titleColor.HasValue) src.TitleColor = titleColor.Value;
                }
                _needsRedraw = true;
                Reflow();
            }
        }

        // ------------------------------------------------------------------
        // Window frame metrics (GetSystemMetrics)
        // ------------------------------------------------------------------

        /// <summary>
        /// Gets the total pixel height of a window's caption (title bar) area.
        /// </summary>
        public static int GetCaptionHeight() => GetSystemMetrics(SM_CYCAPTION);

        /// <summary>
        /// Gets the total width in pixels of a window's left resize border.
        /// </summary>
        public static int GetLeftBorderWidth() => GetSystemMetrics(SM_CXFRAME);

        /// <summary>
        /// Gets the total width in pixels of a window's right resize border.
        /// </summary>
        public static int GetRightBorderWidth() => GetSystemMetrics(SM_CXFRAME);

        /// <summary>
        /// Gets the total height in pixels of a window's bottom resize border.
        /// </summary>
        public static int GetBottomBorderHeight() => GetSystemMetrics(SM_CYFRAME);

        private void EnsureStarted()
        {
            if (!_started) Start();
        }

        private void AttachExited(Source src, int id)
        {
            if (src.Process == null) return;
            try
            {
                src.Process.EnableRaisingEvents = true;
                EventHandler handler = (s, e) => { _ = OnProcessExitedAsync(src, id); };
                src.ProcessExitedHandler = handler;
                src.Process.Exited += handler;
            }
            catch { }
        }

        private static void DetachExited(Source src)
        {
            if (src.Process != null && src.ProcessExitedHandler != null)
            {
                try { src.Process.Exited -= src.ProcessExitedHandler; } catch { }
            }
        }

        private async Task OnProcessExitedAsync(Source src, int id)
        {
            await UnregisterAsync(id).ConfigureAwait(false);
        }

        // ------------------------------------------------------------------
        // Host window message loop
        // ------------------------------------------------------------------
        private void RunMessageLoop()
        {
            IntPtr hInstance = IntPtr.Zero;
            IntPtr brush = IntPtr.Zero;
            IntPtr classNamePtr = IntPtr.Zero;
            string className = "GenXdevThumbnailBoxHost_" + Guid.NewGuid().ToString("N");

            try
            {
                hInstance = GetModuleHandle(null);
                brush = CreateSolidBrush(0x00000000);
                classNamePtr = Marshal.StringToHGlobalUni(className);

                var wc = new WNDCLASSEX
                {
                    cbSize = (uint)Marshal.SizeOf<WNDCLASSEX>(),
                    style = 0,
                    lpfnWndProc = Marshal.GetFunctionPointerForDelegate(_wndProc),
                    hInstance = hInstance,
                    hCursor = IntPtr.Zero,
                    hIcon = IntPtr.Zero,
                    hIconSm = IntPtr.Zero,
                    hbrBackground = brush,
                    lpszMenuName = IntPtr.Zero,
                    lpszClassName = classNamePtr
                };

                if (RegisterClassEx(ref wc) == 0)
                {
                    _windowReady.Set();
                    return;
                }

                var gc = GCHandle.Alloc(this);
                try
                {
                    _hostWnd = CreateWindowEx(
                        WS_EX_TOPMOST | WS_EX_TRANSPARENT | WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW | WS_EX_LAYERED,
                        className, string.Empty, WS_POPUP,
                        0, 0, 100, 100,
                        IntPtr.Zero, IntPtr.Zero, hInstance, GCHandle.ToIntPtr(gc));

                    if (_hostWnd == IntPtr.Zero)
                    {
                        _windowReady.Set();
                        return;
                    }

                    // Layered + colorkey: black (0x000000) fill becomes fully
                    // transparent while DWM thumbnails composite above it.
                    // Combined with WS_EX_TRANSPARENT this passes mouse input
                    // through to the host window underneath.
                    SetLayeredWindowAttributes(_hostWnd, 0x000000, 0, LWA_COLORKEY);

                    // Opaque chrome window (borders + captions) stacked above the
                    // thumbnail host. Region-clipped so only chrome is visible.
                    _chromeWnd = CreateWindowEx(
                        WS_EX_TOPMOST | WS_EX_TRANSPARENT | WS_EX_NOACTIVATE | WS_EX_TOOLWINDOW | WS_EX_LAYERED,
                        className, string.Empty, WS_POPUP,
                        0, 0, 100, 100,
                        IntPtr.Zero, IntPtr.Zero, hInstance, GCHandle.ToIntPtr(gc));

                    if (_chromeWnd != IntPtr.Zero)
                        SetLayeredWindowAttributes(_chromeWnd, 0, 255, LWA_ALPHA);

                    _windowReady.Set();

                    while (GetMessage(out MSG msg, IntPtr.Zero, 0, 0) > 0)
                    {
                        TranslateMessage(ref msg);
                        DispatchMessage(ref msg);
                    }
                }
                finally
                {
                    if (_chromeWnd != IntPtr.Zero)
                    {
                        DestroyWindow(_chromeWnd);
                        _chromeWnd = IntPtr.Zero;
                    }
                    if (_hostWnd != IntPtr.Zero)
                    {
                        DestroyWindow(_hostWnd);
                        _hostWnd = IntPtr.Zero;
                    }
                    gc.Free();
                }
            }
            finally
            {
                if (hInstance != IntPtr.Zero)
                    UnregisterClass(className, hInstance);
                if (brush != IntPtr.Zero)
                    DeleteObject(brush);
                if (classNamePtr != IntPtr.Zero)
                    Marshal.FreeHGlobal(classNamePtr);
                _windowReady.Set();
            }
        }

        // ------------------------------------------------------------------
        // Reflow / Layout & Rendering
        // ------------------------------------------------------------------
        private async Task ReflowLoopAsync(CancellationToken ct)
        {
            while (!ct.IsCancellationRequested)
            {
                if (_hostWnd != IntPtr.Zero)
                {
                    PostMessage(_hostWnd, WM_APP_REFLOW, IntPtr.Zero, IntPtr.Zero);
                }
                try { await Task.Delay(_refreshMs, ct).ConfigureAwait(false); }
                catch (OperationCanceledException) { break; }
            }
        }

        private void Reflow()
        {
            if (_hostWnd != IntPtr.Zero)
                PostMessage(_hostWnd, WM_APP_REFLOW, IntPtr.Zero, IntPtr.Zero);
        }

        // Fit an unmanaged window's thumbnail into its cell without clipping or
        // distorting: fill the cell height, reduce the width to preserve the
        // source aspect ratio, and left/top align (letterbox on the right).
        private static RECT FitRect(int left, int top, int right, int bottom, int srcW, int srcH)
        {
            int boxW = Math.Max(1, right - left);
            int boxH = Math.Max(1, bottom - top);

            double aspect = (double)srcW / srcH;

            int h = boxH;
            int w = Math.Max(1, (int)Math.Round(h * aspect));

            // If the computed width overflows the cell, cap it and shrink the
            // height proportionally so the whole window still fits.
            if (w > boxW)
            {
                w = boxW;
                h = Math.Max(1, (int)Math.Round(w / aspect));
            }

            return new RECT { Left = left, Top = top, Right = left + w, Bottom = top + h };
        }

        private void HandleReflow(IntPtr hWnd)
        {
            _hostTarget = FindHostWindow();
            RECT r = default;
            bool changed = false;

            if (_hostTarget != IntPtr.Zero)
            {
                POINT pt = new() { X = 0, Y = 0 };
                ClientToScreen(_hostTarget, ref pt);
                GetClientRect(_hostTarget, out var cr);

                r = new RECT { Left = pt.X, Top = pt.Y, Right = pt.X + cr.Width, Bottom = pt.Y + cr.Height };

                if (r.Left != _lastHostRect.Left || r.Top != _lastHostRect.Top ||
                    r.Width != _lastHostRect.Width || r.Height != _lastHostRect.Height)
                {
                    _lastHostRect = r;
                    changed = true;
                }
            }
            else
            {
                int w = GetSystemMetrics(SM_CXSCREEN);
                int h = GetSystemMetrics(SM_CYSCREEN);
                r = new RECT { Left = 0, Top = 0, Right = w, Bottom = h };
                if (r.Width != _lastHostRect.Width || r.Height != _lastHostRect.Height)
                {
                    _lastHostRect = r;
                    changed = true;
                }
            }

            if (changed)
            {
                IntPtr insertAfter = _topmost ? HWND_TOPMOST : HWND_NOTOPMOST;
                SetWindowPos(_hostWnd, insertAfter, r.Left, r.Top, r.Width, r.Height, SWP_NOACTIVATE);
                if (_chromeWnd != IntPtr.Zero)
                    SetWindowPos(_chromeWnd, _hostWnd, r.Left, r.Top, r.Width, r.Height, SWP_NOACTIVATE);
                _needsRedraw = true;
            }

            SyncWindowState(_hostTarget);

            // Discover missing handles
            bool needsMap = false;
            foreach (var s in _sources.Values)
            {
                if (s.Hwnd == IntPtr.Zero && s.Process != null) { needsMap = true; break; }
            }

            Dictionary<int, int> map = null;
            if (needsMap) map = BuildParentMap();

            foreach (var src in _sources.Values)
            {
                if (src.Hwnd == IntPtr.Zero && src.Process != null)
                {
                    try { src.Process.Refresh(); } catch { }
                    if (src.Process.MainWindowHandle != IntPtr.Zero)
                    {
                        src.Hwnd = src.Process.MainWindowHandle;
                    }
                    else if (map != null)
                    {
                        src.Hwnd = FindConsoleWindow(src.Process, map);
                    }

                    // Fallback for ordinary GUI apps whose MainWindowHandle is
                    // still zero (e.g. an elevated Task Manager): enumerate all
                    // top-level windows and pick the largest visible one.
                    if (src.Hwnd == IntPtr.Zero)
                    {
                        src.Hwnd = FindMainWindowForProcess(src.Process.Id);
                    }

                    if (src.Hwnd != IntPtr.Zero)
                    {
                        if (src.Managed)
                            StripChrome(src.Hwnd);
                        _needsRedraw = true;
                    }
                }

                // Register the DWM thumbnail once the window handle is known.
                // Retry on later reflows if registration failed transiently
                // (e.g. the window was still initializing).
                if (src.Hwnd != IntPtr.Zero && src.Thumb == IntPtr.Zero)
                {
                    if (DwmRegisterThumbnail(_hostWnd, src.Hwnd, out IntPtr thumb) == 0)
                    {
                        src.Thumb = thumb;
                        _needsRedraw = true;
                    }
                }
            }

            int n = _sources.Count;
            if (n == 0)
            {
                BuildChromeRegion();
                InvalidateRect(_hostWnd, IntPtr.Zero, false);
                if (_chromeWnd != IntPtr.Zero) InvalidateRect(_chromeWnd, IntPtr.Zero, false);
                return;
            }

            int hostW = _lastHostRect.Width;
            int hostH = _lastHostRect.Height;
            if (hostW <= 0 || hostH <= 0) return;

            int cols = Math.Max(1, (int)Math.Ceiling(Math.Sqrt(n)));
            int rows = Math.Max(1, (int)Math.Ceiling((double)n / cols));

            int contentLeft = _leftMargin;
            int contentTop = _topMargin;
            int contentRight = Math.Max(contentLeft, hostW - _rightMargin);
            int contentBottom = Math.Max(contentTop, hostH - _bottomMargin);
            int contentW = Math.Max(0, contentRight - contentLeft);
            int contentH = Math.Max(0, contentBottom - contentTop);

            int cellW = Math.Max(8, (contentW - (cols - 1) * _thumbSpacing) / cols);
            int cellH = Math.Max(8, (contentH - (rows - 1) * _thumbSpacing) / rows);

            var list = _sources.Values.OrderBy(s => s.Id).ToList();
            for (int i = 0; i < n; i++)
            {
                var src = list[i];
                int cIdx = i % cols;
                int rIdx = i / cols;

                int x = contentLeft + cIdx * (cellW + _thumbSpacing);
                int y = contentTop + rIdx * (cellH + _thumbSpacing);

                int heightForCell = cellH;
                if (i + cols >= n)
                {
                    heightForCell = Math.Max(cellH, contentBottom - y);
                }

                src.CellRect = new RECT { Left = x, Top = y, Right = x + cellW, Bottom = y + heightForCell };
                src.TitleRect = new RECT { Left = x, Top = y, Right = x + cellW, Bottom = y + 16 };

                if (src.Thumb == IntPtr.Zero || src.Hwnd == IntPtr.Zero) continue;

                int thumbLeft = x + 1;
                int thumbTop = y + 16 + 1;
                int thumbRight = x + cellW - 1;
                int thumbBottom = y + heightForCell - 1;

                int thumbW = Math.Max(1, thumbRight - thumbLeft);
                int thumbH = Math.Max(1, thumbBottom - thumbTop);

                RECT srcRect;
                RECT destRect;

                if (src.Managed)
                {
                    double targetAspectRatio = (double)thumbW / thumbH;
                    if (targetAspectRatio <= 0)
                    {
                        continue;
                    }

                    // Keep the source console at terminal width and scale only the
                    // height to match the thumbnail aspect ratio. This preserves the
                    // live scrollback content without clipping the bottom edge.
                    int desiredClientW = Math.Max(MinSourceDim, hostW);
                    int desiredClientH = Math.Max(MinSourceDim,
                        (int)Math.Round(desiredClientW / targetAspectRatio));

                    // Tall cells (which stretch to fill leftover space) can demand a
                    // console taller than the screen. Windows silently clamps the
                    // window to the virtual screen, breaking the aspect ratio and
                    // causing vertical stretching. Shrink the width instead so the
                    // window stays on-screen and keeps the target aspect ratio.
                    int maxScreenW = GetSystemMetrics(SM_CXVIRTUALSCREEN);
                    int maxScreenH = GetSystemMetrics(SM_CYVIRTUALSCREEN);
                    if (maxScreenH > 0 && desiredClientH > maxScreenH)
                    {
                        desiredClientH = maxScreenH;
                        desiredClientW = Math.Max(MinSourceDim,
                            (int)Math.Round(desiredClientH * targetAspectRatio));
                    }
                    if (maxScreenW > 0 && desiredClientW > maxScreenW)
                    {
                        desiredClientW = maxScreenW;
                        desiredClientH = Math.Max(MinSourceDim,
                            (int)Math.Round(desiredClientW / targetAspectRatio));
                    }

                    // MoveWindow sizes the OUTER rect, but DWM thumbnails the
                    // CLIENT area. Compensate for the non-client frame so the
                    // client (not the outer rect) lands on the target aspect.
                    GetClientRect(src.Hwnd, out srcRect);
                    GetWindowRect(src.Hwnd, out var outer);
                    int clientW = Math.Max(1, srcRect.Width);
                    int clientH = Math.Max(1, srcRect.Height);
                    int frameW = Math.Max(0, outer.Width - clientW);
                    int frameH = Math.Max(0, outer.Height - clientH);

                    int outerW = desiredClientW + frameW;
                    int outerH = desiredClientH + frameH;

                    // Only resize offscreen window if dimensions actually changed
                    if (src.LastOffscreenW != outerW || src.LastOffscreenH != outerH)
                    {
                        src.LastOffscreenW = outerW;
                        src.LastOffscreenH = outerH;
                        MoveWindow(src.Hwnd, OffScreenX, OffScreenY, outerW, outerH, false);
                    }

                    destRect = new RECT { Left = thumbLeft, Top = thumbTop, Right = thumbRight, Bottom = thumbBottom };
                }
                else
                {
                    // Unmanaged app: never resize/move the window. Read its real
                    // client area and fit the thumbnail by height, shrinking the
                    // width to preserve aspect ratio (left-aligned, no cropping).
                    GetClientRect(src.Hwnd, out srcRect);
                    int sw = Math.Max(1, srcRect.Width);
                    int sh = Math.Max(1, srcRect.Height);
                    destRect = FitRect(thumbLeft, thumbTop, thumbRight, thumbBottom, sw, sh);
                }

                // Thumbnail the source window's full client area. Omitting
                // rcSource lets DWM compute the region itself, so the whole
                // window content is shown without any cropping.
                var props = new DWM_THUMBNAIL_PROPERTIES
                {
                    dwFlags = DWM_TNP_VISIBLE | DWM_TNP_RECTDESTINATION | DWM_TNP_OPACITY | DWM_TNP_SOURCECLIENTAREAONLY,
                    opacity = src.Transparency,
                    fVisible = 1,
                    fSourceClientAreaOnly = 1,
                    rcDestination = destRect
                };
                DwmUpdateThumbnailProperties(src.Thumb, ref props);
            }

            if (_needsRedraw || changed)
            {
                BuildChromeRegion();
                _needsRedraw = false;
                InvalidateRect(_hostWnd, IntPtr.Zero, false);
                if (_chromeWnd != IntPtr.Zero) InvalidateRect(_chromeWnd, IntPtr.Zero, false);
            }
        }

        private static void HandlePaint(IntPtr hWnd)
        {
            IntPtr hdc = BeginPaint(hWnd, out var ps);
            if (hdc == IntPtr.Zero) return;

            GetClientRect(hWnd, out RECT cr);
            int w = cr.Width;
            int h = cr.Height;

            if (w > 0 && h > 0)
            {
                IntPtr memDC = CreateCompatibleDC(hdc);
                IntPtr memBmp = CreateCompatibleBitmap(hdc, w, h);
                IntPtr oldBmp = SelectObject(memDC, memBmp);

                // Black (0x000000) is colorkey-transparent on the layered window;
                // only the DWM thumbnails live here; chrome is a separate window.
                IntPtr hbrBlack = CreateSolidBrush(0x000000);
                RECT fullRect = new() { Left = 0, Top = 0, Right = w, Bottom = h };
                FillRect(memDC, ref fullRect, hbrBlack);
                DeleteObject(hbrBlack);

                // Blit buffered memory image to screen atomically
                BitBlt(hdc, 0, 0, w, h, memDC, 0, 0, 0x00CC0020); // SRCCOPY

                SelectObject(memDC, oldBmp);
                DeleteObject(memBmp);
                DeleteDC(memDC);
            }

            EndPaint(hWnd, ref ps);
        }

        private void HandleChromePaint(IntPtr hWnd)
        {
            IntPtr hdc = BeginPaint(hWnd, out var ps);
            if (hdc == IntPtr.Zero) return;

            GetClientRect(hWnd, out RECT cr);
            int w = cr.Width;
            int h = cr.Height;

            if (w > 0 && h > 0)
            {
                IntPtr memDC = CreateCompatibleDC(hdc);
                IntPtr memBmp = CreateCompatibleBitmap(hdc, w, h);
                IntPtr oldBmp = SelectObject(memDC, memBmp);

                // Region clips everything outside borders/captions; fill neutral.
                IntPtr hbrFill = CreateSolidBrush(0x000000);
                RECT fullRect = new() { Left = 0, Top = 0, Right = w, Bottom = h };
                FillRect(memDC, ref fullRect, hbrFill);
                DeleteObject(hbrFill);

                uint FixColor(uint c) => (c & 0xFFFFFF) == 0 ? 0x010101 : (c & 0xFFFFFF);

                foreach (var src in _sources.Values)
                {
                    if (src.CellRect.Width <= 0 || src.CellRect.Height <= 0) continue;

                    uint borderColor = FixColor(src.BorderColor);
                    uint titleColor = FixColor(src.TitleColor);

                    IntPtr hpen = CreatePen(0, 1, borderColor);
                    IntPtr oldPen = SelectObject(memDC, hpen);
                    IntPtr oldBrush = SelectObject(memDC, GetStockObject(5)); // NULL_BRUSH

                    Rectangle(memDC, src.CellRect.Left, src.CellRect.Top, src.CellRect.Right, src.CellRect.Bottom);

                    SelectObject(memDC, oldPen);
                    SelectObject(memDC, oldBrush);
                    DeleteObject(hpen);

                    if (!string.IsNullOrEmpty(src.Title))
                    {
                        IntPtr hbrBg = CreateSolidBrush(borderColor);
                        oldBrush = SelectObject(memDC, hbrBg);

                        Rectangle(memDC, src.TitleRect.Left, src.TitleRect.Top, src.TitleRect.Right, src.TitleRect.Bottom);

                        SelectObject(memDC, oldBrush);
                        DeleteObject(hbrBg);

                        // TRANSPARENT bk mode: text background is the caption fill
                        // (no OPAQUE text background), so caption height matches title.
                        int oldBkMode = SetBkMode(memDC, TRANSPARENT);
                        int oldColor = SetTextColor(memDC, titleColor);
                        int oldBkColor = SetBkColor(memDC, borderColor);

                        RECT textRect = src.TitleRect;
                        uint format = 0x0001 | 0x0004 | 0x0020; // DT_CENTER | DT_VCENTER | DT_SINGLELINE
                        DrawTextW(memDC, "-- " + src.Title + " --", -1, ref textRect, format);

                        SetTextColor(memDC, (uint)oldColor);
                        SetBkColor(memDC, (uint)oldBkColor);
                        SetBkMode(memDC, oldBkMode);
                    }
                }

                // Blit buffered memory image to screen atomically
                BitBlt(hdc, 0, 0, w, h, memDC, 0, 0, 0x00CC0020); // SRCCOPY

                SelectObject(memDC, oldBmp);
                DeleteObject(memBmp);
                DeleteDC(memDC);
            }

            EndPaint(hWnd, ref ps);
        }

        // ------------------------------------------------------------------
        // Window state sync (minimize + focus/topmost)
        // ------------------------------------------------------------------
        private void SyncWindowState(IntPtr hostTarget)
        {
            if (_hostWnd == IntPtr.Zero) return;

            bool hostMinimized = hostTarget != IntPtr.Zero && IsIconic(hostTarget);
            bool shouldShow = !hostMinimized;

            if (shouldShow != _overlayVisible)
            {
                _overlayVisible = shouldShow;
                int cmd = shouldShow ? SW_SHOWNOACTIVATE : SW_HIDE;
                ShowWindow(_hostWnd, cmd);
                if (_chromeWnd != IntPtr.Zero) ShowWindow(_chromeWnd, cmd);
            }

            bool hostFocused = hostTarget != IntPtr.Zero && IsHostFocused(hostTarget);
            bool wantTopmost = hostTarget == IntPtr.Zero || hostFocused;

            if (wantTopmost != _topmost)
            {
                _topmost = wantTopmost;
                SetTopmost(_hostWnd, wantTopmost);
                if (_chromeWnd != IntPtr.Zero)
                {
                    SetTopmost(_chromeWnd, wantTopmost);
                    SetWindowPos(_chromeWnd, _hostWnd, 0, 0, 0, 0,
                        SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
                }
            }
        }

        private static bool IsHostFocused(IntPtr hostTarget)
        {
            if (hostTarget == IntPtr.Zero) return false;
            IntPtr fg = GetForegroundWindow();
            if (fg == IntPtr.Zero) return false;
            if (fg == hostTarget) return true;
            // An owned dialog of the host still counts as focused
            IntPtr owner = GetWindow(fg, GW_OWNER);
            return owner != IntPtr.Zero && owner == hostTarget;
        }

        private static void SetTopmost(IntPtr hWnd, bool topmost)
        {
            if (hWnd == IntPtr.Zero) return;
            long exStyle = GetWindowLongPtr(hWnd, GWL_EXSTYLE).ToInt64();
            if (topmost)
                exStyle |= WS_EX_TOPMOST;
            else
                exStyle &= ~(long)WS_EX_TOPMOST;
            SetWindowLongPtr(hWnd, GWL_EXSTYLE, new IntPtr(exStyle));
            SetWindowPos(hWnd, topmost ? HWND_TOPMOST : HWND_NOTOPMOST, 0, 0, 0, 0,
                SWP_NOMOVE | SWP_NOSIZE | SWP_NOACTIVATE);
        }

        private void BuildChromeRegion()
        {
            if (_chromeWnd == IntPtr.Zero) return;

            IntPtr region = CreateRectRgn(0, 0, 0, 0); // empty region

            foreach (var src in _sources.Values)
            {
                if (src.CellRect.Width <= 0 || src.CellRect.Height <= 0) continue;

                region = UnionRect(region, src.CellRect.Left, src.CellRect.Top, src.CellRect.Right, src.CellRect.Top + 1);
                region = UnionRect(region, src.CellRect.Left, src.CellRect.Bottom - 1, src.CellRect.Right, src.CellRect.Bottom);
                region = UnionRect(region, src.CellRect.Left, src.CellRect.Top, src.CellRect.Left + 1, src.CellRect.Bottom);
                region = UnionRect(region, src.CellRect.Right - 1, src.CellRect.Top, src.CellRect.Right, src.CellRect.Bottom);
                region = UnionRect(region, src.TitleRect.Left, src.TitleRect.Top, src.TitleRect.Right, src.TitleRect.Bottom);
            }

            SetWindowRgn(_chromeWnd, region, false);
        }

        private static IntPtr UnionRect(IntPtr region, int left, int top, int right, int bottom)
        {
            IntPtr r = CreateRectRgn(left, top, right, bottom);
            IntPtr combined = CreateRectRgn(0, 0, 0, 0);
            CombineRgn(combined, region, r, RGN_OR);
            DeleteObject(region);
            DeleteObject(r);
            return combined;
        }

        // ------------------------------------------------------------------
        // Window discovery
        // ------------------------------------------------------------------
        private static void StripChrome(IntPtr hwnd)
        {
            if (hwnd == IntPtr.Zero) return;

            long style = GetWindowLongPtr(hwnd, GWL_STYLE).ToInt64();
            style &= ~(long)(WS_CAPTION | WS_THICKFRAME | WS_SYSMENU | WS_MINIMIZEBOX | WS_MAXIMIZEBOX | WS_BORDER | WS_DLGFRAME);
            SetWindowLongPtr(hwnd, GWL_STYLE, new IntPtr(style));

            long exStyle = GetWindowLongPtr(hwnd, GWL_EXSTYLE).ToInt64();
            exStyle |= WS_EX_TOOLWINDOW;
            SetWindowLongPtr(hwnd, GWL_EXSTYLE, new IntPtr(exStyle));

            // Hide then re-show so the shell re-evaluates the window and drops
            // its taskbar / Alt+Tab button. A style change alone (even with
            // SWP_FRAMECHANGED) does not reliably refresh the taskbar entry.
            ShowWindow(hwnd, SW_HIDE);
            SetWindowPos(hwnd, IntPtr.Zero, 0, 0, 0, 0, SWP_NOMOVE | SWP_NOSIZE | SWP_NOZORDER | SWP_FRAMECHANGED | SWP_NOACTIVATE);
            ShowWindow(hwnd, SW_SHOWNOACTIVATE);
        }

        private static IntPtr FindHostWindow()
        {
            IntPtr cw = GetConsoleWindow();
            if (cw != IntPtr.Zero && GetWindowRect(cw, out var cr) && cr.Width > 0 && cr.Height > 0)
                return cw;

            var map = BuildParentMap();
            int cur = Environment.ProcessId;
            int guard = 0;
            while (guard++ < 32 && map.TryGetValue(cur, out int pp) && pp != 0 && pp != cur)
            {
                try
                {
                    using var p = Process.GetProcessById(pp);
                    IntPtr mw = p.MainWindowHandle;
                    if (mw != IntPtr.Zero &&
                        GetWindowRect(mw, out var pr) && pr.Width > 0 && pr.Height > 0 &&
                        !p.ProcessName.Equals("explorer", StringComparison.OrdinalIgnoreCase))
                    {
                        return mw;
                    }
                }
                catch { }
                cur = pp;
            }
            return IntPtr.Zero;
        }

        private static IntPtr FindMainWindowForProcess(int pid)
        {
            IntPtr best = IntPtr.Zero;
            int bestArea = 0;

            EnumWindows((hWnd, _) =>
            {
                GetWindowThreadProcessId(hWnd, out uint windowPid);
                if (windowPid != (uint)pid) return true;
                if (!IsWindowVisible(hWnd)) return true;

                if (GetWindowRect(hWnd, out var r))
                {
                    int area = r.Width * r.Height;
                    if (area > bestArea)
                    {
                        bestArea = area;
                        best = hWnd;
                    }
                }
                return true;
            }, IntPtr.Zero);

            return best;
        }

        private static IntPtr FindConsoleWindow(Process process, Dictionary<int, int> map)
        {
            int target = process.Id;

            try
            {
                process.Refresh();
                if (process.MainWindowHandle != IntPtr.Zero) return process.MainWindowHandle;
            }
            catch { }

            foreach (var p in Process.GetProcesses())
            {
                try
                {
                    if (p.Id == target || p.MainWindowHandle == IntPtr.Zero) continue;

                    bool isConsoleHost = p.ProcessName.Equals("conhost", StringComparison.OrdinalIgnoreCase) ||
                                         p.ProcessName.Equals("openconsole", StringComparison.OrdinalIgnoreCase);

                    if (isConsoleHost)
                    {
                        if (IsAdjacent(p.Id, target, map)) return p.MainWindowHandle;
                    }
                    else if (IsDescendant(p.Id, target, map))
                    {
                        return p.MainWindowHandle;
                    }
                }
                catch { }
            }
            return IntPtr.Zero;
        }

        private static bool IsAdjacent(int a, int b, Dictionary<int, int> map)
        {
            return (map.TryGetValue(a, out int pa) && pa == b) ||
                   (map.TryGetValue(b, out int pb) && pb == a);
        }

        private static bool IsDescendant(int pid, int ancestor, Dictionary<int, int> map)
        {
            int cur = pid;
            int guard = 0;
            while (guard++ < 32 && map.TryGetValue(cur, out int pp) && pp != 0 && pp != cur)
            {
                if (pp == ancestor) return true;
                cur = pp;
            }
            return false;
        }

        private static Dictionary<int, int> BuildParentMap()
        {
            var map = new Dictionary<int, int>();
            IntPtr snap = CreateToolhelp32Snapshot(TH32CS_SNAPPROCESS, 0);
            if (snap == IntPtr.Zero || snap == INVALID_HANDLE_VALUE) return map;
            try
            {
                var pe = new PROCESSENTRY32W { dwSize = (uint)Marshal.SizeOf<PROCESSENTRY32W>() };
                if (Process32FirstW(snap, ref pe))
                {
                    do { map[(int)pe.th32ProcessID] = (int)pe.th32ParentProcessID; }
                    while (Process32NextW(snap, ref pe));
                }
            }
            finally
            {
                CloseHandle(snap);
            }
            return map;
        }
    }
}
