using System.Collections;
using System.Management.Automation;
using Microsoft.Win32;

namespace GenXdev.Webbrowser
{
    [System.ComponentModel.Description(@"
.SYNOPSIS
Returns a collection of installed modern web browsers.
.DESCRIPTION
* Discovers and returns details about modern web browsers installed on the
  system.
* Retrieves information including name, description, icon path, executable
  path and default browser status by querying the Windows registry.
* Only returns browsers that have the required capabilities registered in
  Windows.

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
Get-Webbrowser | Select-Object Name, Description | Format-Table
```

Returns a collection of all installed modern web browsers.
.EXAMPLE
```powershell
Get-Webbrowser | Where-Object { $_.IsDefaultBrowser }
```

Filters to show only the system default browser.
")]
    [Cmdlet(VerbsCommon.Get, "Webbrowser", DefaultParameterSetName = "Default")]
    [OutputType(typeof(Hashtable[]))]
    public class GetWebbrowserCommand : PSGenXdevCmdlet
    {
        /// <summary>
        /// Selects Microsoft Edge browser instances
        /// </summary>
        [Alias("e")]
        [Parameter(
            Mandatory = false,
            ParameterSetName = "Specific",
            HelpMessage = "Selects Microsoft Edge browser instances")]
        public SwitchParameter Edge { get; set; }

        /// <summary>
        /// Selects Google Chrome browser instances
        /// </summary>
        [Alias("ch")]
        [Parameter(
            Mandatory = false,
            ParameterSetName = "Specific",
            HelpMessage = "Selects Google Chrome browser instances")]
        public SwitchParameter Chrome { get; set; }

        /// <summary>
        /// Selects default chromium-based browser
        /// </summary>
        [Alias("c")]
        [Parameter(
            Mandatory = false,
            ParameterSetName = "Specific",
            HelpMessage = "Selects default chromium-based browser")]
        public SwitchParameter Chromium { get; set; }

        /// <summary>
        /// Selects Firefox browser instances
        /// </summary>
        [Alias("ff")]
        [Parameter(
            Mandatory = false,
            ParameterSetName = "Specific",
            HelpMessage = "Selects Firefox browser instances")]
        public SwitchParameter Firefox { get; set; }

        private string urlHandlerId;

        /// <summary>
        /// Begin processing - initialization logic
        /// </summary>
        protected override void BeginProcessing()
        {

            // Get the user's default handler for https URLs from registry settings
            WriteVerbose("Retrieving default browser URL handler ID from registry");

            try
            {
                using (var userChoiceKey = Registry.CurrentUser.OpenSubKey(
                    @"SOFTWARE\Microsoft\Windows\Shell\Associations\UrlAssociations\https\UserChoice"))
                {
                    urlHandlerId = userChoiceKey?.GetValue("ProgId")?.ToString();
                }
            }
            catch
            {
                // If we can't read the default browser setting, continue without it
                urlHandlerId = null;
            }
        }

        /// <summary>
        /// Process record - main cmdlet logic
        /// </summary>
        protected override void ProcessRecord()
        {

            // Enumerate all browser entries in the Windows registry
            WriteVerbose("Enumerating installed browsers from registry");

            var browsers = new List<Hashtable>();

            try
            {
                using (var browsersKey = Registry.LocalMachine.OpenSubKey(
                    @"SOFTWARE\WOW6432Node\Clients\StartMenuInternet"))
                {
                    if (browsersKey != null)
                    {
                        foreach (string browserName in browsersKey.GetSubKeyNames())
                        {
                            var browserInfo = ProcessBrowserEntry(browserName);
                            if (browserInfo != null)
                            {
                                browsers.Add(browserInfo);
                            }
                        }
                    }
                }
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(
                    ex,
                    "RegistryAccessError",
                    ErrorCategory.ReadError,
                    "Registry"));
                return;
            }

            // Write each browser hashtable to the output stream
            foreach (var browser in browsers)
            {
                WriteObject(browser);
            }
        }

        /// <summary>
        /// Process a single browser registry entry
        /// </summary>
        /// <param name="browserName">The browser registry key name</param>
        /// <returns>Browser information hashtable or null if browser should be filtered</returns>
        private Hashtable ProcessBrowserEntry(string browserName)
        {

            var browserRoot = $@"SOFTWARE\WOW6432Node\Clients\StartMenuInternet\{browserName}";

            try
            {
                using (var browserKey = Registry.LocalMachine.OpenSubKey(browserRoot))
                {
                    if (browserKey == null) return null;

                    // Verify browser has required capabilities and command info
                    using (var commandKey = browserKey.OpenSubKey(@"shell\open\command"))
                    using (var capabilitiesKey = browserKey.OpenSubKey("Capabilities"))
                    {
                        if (commandKey == null || capabilitiesKey == null) return null;

                        // Get browser capabilities metadata from registry
                        var applicationName = capabilitiesKey.GetValue("ApplicationName")?.ToString();
                        var applicationDescription = capabilitiesKey.GetValue("ApplicationDescription")?.ToString();
                        var applicationIcon = capabilitiesKey.GetValue("ApplicationIcon")?.ToString();

                        // Extract the browser executable path, removing quotes
                        var browserPath = commandKey.GetValue("")?.ToString()?.Trim('"');

                        // Determine if this browser is set as the system default
                        bool isDefault = false;
                        try
                        {
                            using (var urlAssociationsKey = capabilitiesKey.OpenSubKey("URLAssociations"))
                            {
                                if (urlAssociationsKey != null)
                                {
                                    var httpsHandler = urlAssociationsKey.GetValue("https")?.ToString();
                                    isDefault = !string.IsNullOrEmpty(urlHandlerId) && httpsHandler == urlHandlerId;
                                }
                            }
                        }
                        catch
                        {
                            // If we can't read URL associations, assume not default
                            isDefault = false;
                        }

                        // Create browser info hashtable
                        var browserInfo = new Hashtable
                        {
                            ["Name"] = applicationName,
                            ["Description"] = applicationDescription,
                            ["Icon"] = applicationIcon,
                            ["Path"] = browserPath,
                            ["IsDefaultBrowser"] = isDefault
                        };

                        // Apply browser type filtering
                        if (ShouldIncludeBrowser(applicationName))
                        {
                            return browserInfo;
                        }
                    }
                }
            }
            catch
            {
                // Skip browsers that can't be read
                return null;
            }

            return null;
        }

        /// <summary>
        /// Determine if a browser should be included based on filtering parameters
        /// </summary>
        /// <param name="applicationName">The browser application name</param>
        /// <returns>True if the browser should be included in results</returns>
        private bool ShouldIncludeBrowser(string applicationName)
        {

            if (string.IsNullOrEmpty(applicationName)) return false;

            var isEdge = applicationName.IndexOf("Edge", StringComparison.OrdinalIgnoreCase) >= 0;
            var isChrome = applicationName.IndexOf("Chrome", StringComparison.OrdinalIgnoreCase) >= 0;
            var isFirefox = applicationName.IndexOf("Firefox", StringComparison.OrdinalIgnoreCase) >= 0;
            var isChromium = isEdge || isChrome;

            // If no specific browser is requested (Default parameter set), return all
            if (ParameterSetName == "Default") return true;

            // Filter results based on specific browser parameters
            return (Edge.ToBool() && isEdge) ||
                   (Chrome.ToBool() && isChrome) ||
                   (Chromium.ToBool() && isChromium) ||
                   (Firefox.ToBool() && isFirefox);
        }

        /// <summary>
        /// End processing - cleanup logic
        /// </summary>
        protected override void EndProcessing()
        {
        }
    }
}