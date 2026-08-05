using System.Management.Automation;

namespace GenXdev.Webbrowser.Playwright
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Gets the Playwright browser profile directory for persistent sessions.
.DESCRIPTION
* Creates and manages browser profile directories for Playwright automated
  testing.
* Profiles are stored in LocalAppData under
  GenXdev.Powershell\Playwright.profiles.
* Each BrowserType value gets its own subdirectory, keeping real-browser
  profiles (ChromeNormal, EdgeNormal) separate from bundled Playwright
  profiles (ChromiumPlaywright, FirefoxPlaywright, WebKitPlaywright).

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
Get-PlaywrightProfileDirectory -BrowserType ChromeNormal
```

Creates or returns path for the OS-installed Chrome browser profile.
.EXAMPLE
```powershell
Get-PlaywrightProfileDirectory -BrowserType ChromiumNormal
```

Creates or returns path for the auto-detected Chromium browser profile.
.EXAMPLE
```powershell
Get-PlaywrightProfileDirectory -BrowserType ChromiumPlaywright
```

Creates or returns path for the bundled Playwright Chromium profile.
")]
    [Cmdlet(VerbsCommon.Get, "PlaywrightProfileDirectory")]
    [OutputType(typeof(string))]
    public class GetPlaywrightProfileDirectoryCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Specifies the browser type to create/get a profile directory for
        /// </summary>
        [Parameter(
            Position = 0,
            HelpMessage = "The browser type: ChromeNormal, EdgeNormal, ChromiumNormal, ChromiumPlaywright, FirefoxPlaywright, or WebKitPlaywright")]
        [ValidateSet("ChromeNormal", "EdgeNormal", "ChromiumNormal", "ChromiumPlaywright", "FirefoxPlaywright", "WebKitPlaywright")]
        public string BrowserType { get; set; } = "ChromiumNormal";

        private string baseDir;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {
            // Construct the base directory path for all browser profiles
            baseDir = Path.Combine(GetGenXdevAppDataPath(), "Playwright.profiles");

            WriteVerbose($"Base profile directory: {baseDir}");
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {
            // Generate the specific browser profile directory path.
            // Each BrowserType value gets its own subdirectory.
            string browserDir = ExpandPath(
                Path.Combine(baseDir, BrowserType) + "\\",
                CreateDirectory: true);

            WriteVerbose($"Browser profile directory: {browserDir}");

            // Return the full profile directory path
            WriteObject(browserDir);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
            // No cleanup needed
        }
    }
}