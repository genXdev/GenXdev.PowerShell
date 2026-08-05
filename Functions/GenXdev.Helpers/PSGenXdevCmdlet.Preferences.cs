using System.Management.Automation;
using System.Collections;
using System.Linq;
using System.Management.Automation.Runspaces;
public abstract partial class PSGenXdevCmdlet : PSCmdlet
{
    /// <summary>
    /// Detects whether the current PowerShell session is running inside a
    /// Pester test by inspecting the debugger call stack for frames whose
    /// script path contains the Pester installation directory.
    /// </summary>
    public static bool IsRunningUnderPester()
    {
        var runspace = Runspace.DefaultRunspace;
        if (runspace == null)
            return false;

        var dbg = runspace.Debugger;
        if (dbg == null)
            return false;

        var frames = dbg.GetCallStack();

        return frames.Any(f =>
            f.GetScriptLocation() != null &&
            f.GetScriptLocation().IndexOf("Pester.psm1", System.StringComparison.OrdinalIgnoreCase) >= 0
        );
    }
    
    /// <summary>
    /// Gets the OneDrive path for the defaults preferences store.
    /// </summary>
    protected string GetOneDriveDefaultsStorePath()
    {
        string oneDrive = InvokeScript<string>("GenXdev\\Get-KnownFolderPath -KnownFolder 'OneDrive'");
        return ExpandPath(Path.Combine(oneDrive, "GenXdev\\Defaults_Preferences.json"), CreateDirectory: true);
    }

    protected string GetGenXdevPreference(string Name, string DefaultValue, string PreferencesDatabasePath, bool SessionOnly, bool ClearSession, bool SkipSession)
    {
        /// <summary>
        /// Retrieves a GenXdev preference value using a five-tier lookup:
        /// session, local prefs, local defaults, OneDrive, then fallback default.
        /// </summary>
        /// <param name="Name">The name of the preference to retrieve.</param>
        /// <param name="DefaultValue">The default value to return if the preference is not found.</param>
        /// <param name="PreferencesDatabasePath">Optional path to the preferences database.</param>
        /// <param name="SessionOnly">If true, only check session storage.</param>
        /// <param name="ClearSession">If true, clear the session preference.</param>
        /// <param name="SkipSession">If true, skip checking session storage.</param>
        /// <returns>The preference value or the default value if not found.</returns>

        // Normalize to lowercase for case-insensitive preference names
        Name = Name?.ToLowerInvariant();
        string globalVariableName = "GenXdevPreference_" + Name;

        if (ClearSession)
        {
            if (ShouldProcess("GenXdev.Data Module Configuration", "Clear session preference setting (Global variable)"))
            {
                // Use parameterized script to avoid escaping issues
                var clearVarScript = ScriptBlock.Create("param($VarName) Microsoft.PowerShell.Utility\\Set-Variable -Name $VarName -Value $null -Scope Global -Force");
                clearVarScript.Invoke(globalVariableName);

                WriteVerbose("Cleared session preference setting: " + globalVariableName);
            }
        }

        if (!SkipSession)
        {
            WriteVerbose("Checking session storage for preference '" + Name + "'");

            // Get global variable using Get-Variable cmdlet
            var getVarScript = ScriptBlock.Create("param($VarName) Microsoft.PowerShell.Utility\\Get-Variable -Name $VarName -Scope Global -ValueOnly -ErrorAction SilentlyContinue");
            var globalResult = getVarScript.Invoke(globalVariableName);

            if (globalResult.Count > 0 && globalResult[0] != null &&
                !string.IsNullOrWhiteSpace(globalResult[0].ToString()))
            {
                string value2 = globalResult[0].ToString();
                WriteVerbose("Returning session value: " + value2);
                return value2;
            }
        }

        if (SessionOnly)
        {
            WriteVerbose("Using provided default value: " + DefaultValue);
            return DefaultValue;
        }

        var preferencesDatabasePath = GetPreferencesDatabasePath(PreferencesDatabasePath, SessionOnly, ClearSession, SkipSession);

        WriteVerbose("Using database path: " + preferencesDatabasePath);

        string value = null;

        try
        {
            // Tier 2: Local preferences
            WriteVerbose("Checking local store for preference '" + Name + "'");

            value = GetValueByKeyFromStore("GenXdev.PowerShell.Preferences", Name, null, preferencesDatabasePath)?.ToString();

            // Tier 3: Local defaults
            if (string.IsNullOrEmpty(value))
            {
                WriteVerbose("Preference not found locally, checking local defaults store");
                value = GetValueByKeyFromStore("GenXdev.PowerShell.Defaults", Name, null, preferencesDatabasePath)?.ToString();
            }

            // Tier 4: OneDrive defaults
            if (string.IsNullOrEmpty(value))
            {
                WriteVerbose("Preference not found in local defaults, checking OneDrive defaults");
                try
                {
                    string oneDrivePath = GetOneDriveDefaultsStorePath();
                    var oneDriveData = (Hashtable)ReadJsonWithRetry(oneDrivePath, asHashtable: true);
                    if (oneDriveData.ContainsKey(Name))
                    {
                        var entry = oneDriveData[Name];
                        if (entry is Hashtable hashtable && hashtable.ContainsKey("value"))
                        {
                            string oneDriveValue = hashtable["value"]?.ToString();
                            if (!string.IsNullOrEmpty(oneDriveValue))
                            {
                                WriteVerbose("Returning OneDrive default value: " + oneDriveValue);
                                return oneDriveValue;
                            }
                        }
                        else if (entry is string strValue && !string.IsNullOrEmpty(strValue))
                        {
                            WriteVerbose("Returning OneDrive default value: " + strValue);
                            return strValue;
                        }
                    }
                }
                catch (Exception ex)
                {
                    WriteVerbose("OneDrive defaults not available: " + ex.Message);
                }
            }

            if (!string.IsNullOrEmpty(value))
            {
                WriteVerbose("Returning persistent value: " + value);
                return value;
            }
        }
        catch (Exception ex)
        {
            WriteVerbose("Error accessing preference stores: " + ex.Message);
        }

        // Case-insensitive fallback: scan all stored keys when the
        // lowercased name doesn't match an existing mixed-case entry
        if (string.IsNullOrEmpty(value))
        {
            WriteVerbose(
                "Exact (lowercase) key not found, " +
                "trying case-insensitive scan of local preferences");

            try
            {
                string[] localKeys = GetStoreKeys(
                    "GenXdev.PowerShell.Preferences", preferencesDatabasePath);
                string matchedKey = null;
                foreach (string key in localKeys)
                {
                    if (string.Equals(key, Name,
                        StringComparison.OrdinalIgnoreCase))
                    {
                        matchedKey = key;
                        break;
                    }
                }
                if (matchedKey != null)
                {
                    value = GetValueByKeyFromStore(
                        "GenXdev.PowerShell.Preferences",
                        matchedKey, null, preferencesDatabasePath)
                        ?.ToString();
                    WriteVerbose(
                        "Found via case-insensitive " +
                        "match in local preferences: '" +
                        matchedKey + "'");
                }
            }
            catch (Exception ex)
            {
                WriteVerbose(
                    "Case-insensitive scan of local " +
                    "preferences failed: " + ex.Message);
            }
        }

        if (string.IsNullOrEmpty(value))
        {
            WriteVerbose(
                "Trying case-insensitive scan of local defaults");

            try
            {
                string[] defaultKeys = GetStoreKeys(
                    "GenXdev.PowerShell.Defaults", preferencesDatabasePath);
                string matchedKey = null;
                foreach (string key in defaultKeys)
                {
                    if (string.Equals(key, Name,
                        StringComparison.OrdinalIgnoreCase))
                    {
                        matchedKey = key;
                        break;
                    }
                }
                if (matchedKey != null)
                {
                    value = GetValueByKeyFromStore(
                        "GenXdev.PowerShell.Defaults",
                        matchedKey, null, preferencesDatabasePath)
                        ?.ToString();
                    WriteVerbose(
                        "Found via case-insensitive " +
                        "match in local defaults: '" +
                        matchedKey + "'");
                }
            }
            catch (Exception ex)
            {
                WriteVerbose(
                    "Case-insensitive scan of local " +
                    "defaults failed: " + ex.Message);
            }
        }

        if (string.IsNullOrEmpty(value))
        {
            WriteVerbose(
                "Trying case-insensitive scan of OneDrive defaults");

            try
            {
                string oneDrivePath = GetOneDriveDefaultsStorePath();
                var oneDriveData = (Hashtable)ReadJsonWithRetry(
                    oneDrivePath, asHashtable: true);
                foreach (string key in oneDriveData.Keys)
                {
                    if (string.Equals(key, Name,
                        StringComparison.OrdinalIgnoreCase))
                    {
                        var entry = oneDriveData[key];
                        if (entry is Hashtable ht &&
                            ht.ContainsKey("value"))
                        {
                            string odValue =
                                ht["value"]?.ToString();
                            if (!string.IsNullOrEmpty(odValue))
                            {
                                value = odValue;
                                break;
                            }
                        }
                        else if (entry is string s &&
                            !string.IsNullOrEmpty(s))
                        {
                            value = s;
                            break;
                        }
                    }
                }
                if (!string.IsNullOrEmpty(value))
                {
                    WriteVerbose(
                        "Found via case-insensitive " +
                        "match in OneDrive defaults");
                }
            }
            catch (Exception ex)
            {
                WriteVerbose(
                    "OneDrive case-insensitive " +
                    "fallback failed: " + ex.Message);
            }
        }

        if (!string.IsNullOrEmpty(value))
        {
            WriteVerbose(
                "Returning value from case-insensitive fallback: " +
                value);
            return value;
        }

        WriteVerbose("Using provided default value: " + DefaultValue);
        return DefaultValue;
    }

    protected void SetGenXdevPreference(string Name, string Value, string PreferencesDatabasePath, bool SessionOnly, bool ClearSession, bool SkipSession, bool AllMachines = false)
    {
        /// <summary>
        /// Sets a GenXdev preference value in session or persistent storage.
        /// When AllMachines is true, also writes the value to OneDrive for
        /// cross-machine sharing.
        /// </summary>
        /// <param name="Name">The name of the preference to set.</param>
        /// <param name="Value">The value to set for the preference.</param>
        /// <param name="PreferencesDatabasePath">Optional path to the preferences database.</param>
        /// <param name="SessionOnly">If true, only set in session storage.</param>
        /// <param name="ClearSession">If true, clear the session preference.</param>
        /// <param name="SkipSession">If true, skip session storage operations.</param>
        /// <param name="AllMachines">If true, also write to OneDrive for all machines.</param>

        // Normalize to lowercase for case-insensitive preference names
        Name = Name?.ToLowerInvariant();
        string globalVariableName = "GenXdevPreference_" + Name;

        if (ClearSession)
        {
            if (ShouldProcess(Name, "Clear session variable"))
            {
                // Use parameterized script to avoid escaping issues
                var removeVarScript = ScriptBlock.Create("param($VarName) Microsoft.PowerShell.Utility\\Remove-Variable -Name $VarName -Scope Global -ErrorAction SilentlyContinue");
                removeVarScript.Invoke(globalVariableName);
            }
            return;
        }

        if (SessionOnly)
        {
            if (ShouldProcess(Name, "Set session-only preference"))
            {
                // Use parameterized script to avoid escaping issues
                var setVarScript = ScriptBlock.Create("param($VarName, $VarValue) Microsoft.PowerShell.Utility\\Set-Variable -Name $VarName -Value $VarValue -Scope Global -Force");
                setVarScript.Invoke(globalVariableName, Value);

                WriteVerbose("Set session-only preference: " + globalVariableName + " = " + Value);
            }
            return;
        }

        PreferencesDatabasePath = GetPreferencesDatabasePath(PreferencesDatabasePath, SessionOnly, ClearSession, SkipSession);

        WriteVerbose("Using database path: " + PreferencesDatabasePath);

        if (string.IsNullOrWhiteSpace(Value))
        {
            if (ShouldProcess(Name, "Remove preference from persistent storage"))
            {
                RemoveGenXdevPreference(Name, false, PreferencesDatabasePath, SessionOnly, ClearSession, true, AllMachines);
                WriteVerbose("Successfully removed preference '" + Name + "'");
            }
            return;
        }

        if (ShouldProcess(Name, "Set preference"))
        {
            SetValueByKeyInStore("GenXdev.PowerShell.Preferences", Name, Value, PreferencesDatabasePath);
            WriteVerbose("Successfully configured preference '" + Name + "' in GenXdev.Data module: [" + Value + "]");

            // Write to OneDrive for cross-machine sharing
            if (AllMachines)
            {
                WriteVerbose("Writing preference to OneDrive for all machines");
                try
                {
                    string oneDrivePath = GetOneDriveDefaultsStorePath();
                    var oneDriveData = (Hashtable)ReadJsonWithRetry(oneDrivePath, asHashtable: true);
                    oneDriveData[Name] = Value;
                    WriteJsonAtomic(oneDrivePath, oneDriveData);
                    WriteVerbose($"Written '{Name}' = '{Value}' to OneDrive defaults");
                }
                catch (Exception ex)
                {
                    WriteVerbose("Failed to write to OneDrive: " + ex.Message);
                }
            }
        }
    }

    protected void RemoveGenXdevPreference(string Name, bool RemoveDefault, string PreferencesDatabasePath, bool SessionOnly, bool ClearSession, bool SkipSession, bool AllMachines = false)
    {
        /// <summary>
        /// Removes a GenXdev preference from session and/or persistent storage.
        /// When AllMachines is true, also removes the key from OneDrive.
        /// </summary>
        /// <param name="Name">The name of the preference to remove.</param>
        /// <param name="RemoveDefault">If true, also remove from default storage.</param>
        /// <param name="PreferencesDatabasePath">Optional path to the preferences database.</param>
        /// <param name="SessionOnly">If true, only remove from session storage.</param>
        /// <param name="ClearSession">If true, clear the session preference.</param>
        /// <param name="SkipSession">If true, skip session storage operations.</param>
        /// <param name="AllMachines">If true, also remove from OneDrive.</param>

        // Normalize to lowercase for case-insensitive preference names
        Name = Name?.ToLowerInvariant();
        string globalVariableName = "GenXdevPreference_" + Name;

        PreferencesDatabasePath = GetPreferencesDatabasePath(PreferencesDatabasePath, SessionOnly, ClearSession, SkipSession);

        WriteVerbose("Using database path: " + PreferencesDatabasePath);
        WriteVerbose("Starting preference removal for: " + Name);

        if (ClearSession)
        {
            if (ShouldProcess(Name, "Clear session variable"))
            {
                // Use parameterized script to avoid escaping issues
                var removeVarScript = ScriptBlock.Create("param($VarName) Microsoft.PowerShell.Utility\\Remove-Variable -Name $VarName -Scope Global -ErrorAction SilentlyContinue");
                removeVarScript.Invoke(globalVariableName);
            }
        }

        if (SessionOnly)
        {
            if (ShouldProcess(Name, "Remove session-only preference"))
            {
                // Use parameterized script to avoid escaping issues
                var removeVarScript = ScriptBlock.Create("param($VarName) Microsoft.PowerShell.Utility\\Remove-Variable -Name $VarName -Scope Global -ErrorAction SilentlyContinue");
                removeVarScript.Invoke(globalVariableName);
            }
            return;
        }

        if (ShouldProcess(Name, "Remove preference"))
        {
            if (!SkipSession)
            {
                // Use parameterized script to avoid escaping issues
                var removeVarScript = ScriptBlock.Create("param($VarName) Microsoft.PowerShell.Utility\\Remove-Variable -Name $VarName -Scope Global -ErrorAction SilentlyContinue");
                removeVarScript.Invoke(globalVariableName);
            }

            WriteVerbose("Removing preference " + Name + " from local store");
            RemoveKeyFromStore("GenXdev.PowerShell.Preferences", Name, PreferencesDatabasePath);

            if (RemoveDefault)
            {
                WriteVerbose("Removing preference " + Name + " from local defaults store");
                RemoveKeyFromStore("GenXdev.PowerShell.Defaults", Name, PreferencesDatabasePath);
            }

            // Remove from OneDrive for cross-machine sharing
            if (AllMachines)
            {
                WriteVerbose("Removing preference from OneDrive defaults");
                try
                {
                    string oneDrivePath = GetOneDriveDefaultsStorePath();
                    var oneDriveData = (Hashtable)ReadJsonWithRetry(oneDrivePath, asHashtable: true);
                    if (oneDriveData.ContainsKey(Name))
                    {
                        oneDriveData.Remove(Name);
                        WriteJsonAtomic(oneDrivePath, oneDriveData);
                        WriteVerbose($"Removed '{Name}' from OneDrive defaults");
                    }
                }
                catch (Exception ex)
                {
                    WriteVerbose("Failed to remove from OneDrive: " + ex.Message);
                }
            }
        }
    }

    protected string GetPreferencesDatabasePath(string PreferencesDatabasePath, bool SessionOnly, bool ClearSession, bool SkipSession)
    {
        /// <summary>
        /// Determines the path to the preferences database, checking provided path, session, or using defaults.
        /// </summary>
        /// <param name="PreferencesDatabasePath">Optional explicit path to the database.</param>
        /// <param name="SessionOnly">If true, only consider session settings.</param>
        /// <param name="ClearSession">If true, clear session database path.</param>
        /// <param name="SkipSession">If true, skip session checks.</param>
        /// <returns>The resolved database path.</returns>
        if (ClearSession)
        {
            if (ShouldProcess("GenXdev.Data Module Configuration", "Clear session database path setting (Global variable)"))
            {
                // Use parameterized script to avoid escaping issues
                var clearVarScript = ScriptBlock.Create("Microsoft.PowerShell.Utility\\Set-Variable -Name 'PreferencesDatabasePath' -Value $null -Scope Global -Force");
                clearVarScript.Invoke();

                WriteVerbose("Cleared session database path setting: PreferencesDatabasePath");
            }
        }

        string resolvedDatabasePath = null;

        if (!string.IsNullOrWhiteSpace(PreferencesDatabasePath))
        {
            // Remove .db extension if present using native string operation
            string cleanPath = PreferencesDatabasePath.EndsWith(".db", StringComparison.OrdinalIgnoreCase)
                ? PreferencesDatabasePath.Substring(0, PreferencesDatabasePath.Length - 3)
                : PreferencesDatabasePath;

            resolvedDatabasePath = ExpandPath(cleanPath, true);
            WriteVerbose("Using provided database path: " + resolvedDatabasePath);
            return resolvedDatabasePath;
        }


        if (!SkipSession)
        {
            // Get global variable using Get-Variable cmdlet
            var getVarScript = ScriptBlock.Create("Microsoft.PowerShell.Utility\\Get-Variable -Name 'PreferencesDatabasePath' -Scope Global -ValueOnly -ErrorAction SilentlyContinue");
            var globalResult = getVarScript.Invoke();

            if (globalResult.Count > 0 && globalResult[0] != null &&
                !string.IsNullOrWhiteSpace(globalResult[0].ToString()))
            {
                resolvedDatabasePath = ExpandPath(globalResult[0].ToString(), true);
                WriteVerbose("Using session database path: " + resolvedDatabasePath);
                return resolvedDatabasePath;
            }
        }

        if (!SessionOnly)
        {
            string defaultPath = System.IO.Path.Combine(System.Environment.GetFolderPath(System.Environment.SpecialFolder.LocalApplicationData), "GenXdev.PowerShell", "Preferences");
            resolvedDatabasePath = ExpandPath(defaultPath, true);
            WriteVerbose("Using default database path: " + resolvedDatabasePath);
            return resolvedDatabasePath;
        }

        // When running inside a Pester test and no explicit path was given,
        // auto-isolate preferences in TEMP so tests never touch real user data
        if (IsRunningUnderPester())
        {
            string testPath = System.IO.Path.Combine(
                System.IO.Path.GetTempPath(),
                "GenXdev.PowerShell.Tests",
                "Preferences");
            resolvedDatabasePath = ExpandPath(testPath, true);
            WriteVerbose(
                "Pester detected — using isolated test database path: " +
                resolvedDatabasePath);
            return resolvedDatabasePath;
        }

        string fallbackPath = System.IO.Path.Combine(System.Environment.GetFolderPath(System.Environment.SpecialFolder.LocalApplicationData), "GenXdev.PowerShell", "Preferences");
        resolvedDatabasePath = ExpandPath(fallbackPath, true);
        WriteVerbose("Using fallback database path: " + resolvedDatabasePath);
        return resolvedDatabasePath;
    }

    protected void SetPreferencesDatabasePath(string PreferencesDatabasePath, bool SkipSession, bool SessionOnly, bool ClearSession)
    {
        /// <summary>
        /// Sets the path to the preferences database in session storage.
        /// </summary>
        /// <param name="PreferencesDatabasePath">The path to set for the database.</param>
        /// <param name="SkipSession">If true, skip session operations.</param>
        /// <param name="SessionOnly">If true, only affect session.</param>
        /// <param name="ClearSession">If true, clear the session path.</param>
        if (ClearSession)
        {
            if (ShouldProcess("GenXdev.Data Module Configuration", "Clear session database path setting (Global variable)"))
            {
                // Use parameterized script to avoid escaping issues
                var clearVarScript = ScriptBlock.Create("Microsoft.PowerShell.Utility\\Set-Variable -Name 'PreferencesDatabasePath' -Value $null -Scope Global -Force");
                clearVarScript.Invoke();

                WriteVerbose("Cleared session database path setting: PreferencesDatabasePath");
            }
            return;
        }

        if (string.IsNullOrWhiteSpace(PreferencesDatabasePath))
        {
            throw new ArgumentException("PreferencesDatabasePath parameter is required when not using -ClearSession");
        }

        PreferencesDatabasePath = ExpandPath(PreferencesDatabasePath, true);
        WriteVerbose("Setting database path for GenXdev.Data module: [" + PreferencesDatabasePath + "]");

        if (ShouldProcess("GenXdev.Data Module Configuration", "Set database path to: [" + PreferencesDatabasePath + "]"))
        {
            // Use parameterized script to avoid escaping issues
            var setVarScript = ScriptBlock.Create("param($PathValue) Microsoft.PowerShell.Utility\\Set-Variable -Name 'PreferencesDatabasePath' -Value $PathValue -Scope Global -Force");
            setVarScript.Invoke(PreferencesDatabasePath);

            WriteVerbose("Set database path: PreferencesDatabasePath = " + PreferencesDatabasePath);
        }
    }

    protected void SetGenXdevDefaultPreference(string Name, string Value, string PreferencesDatabasePath, bool SessionOnly, bool ClearSession, bool SkipSession, bool AllMachines = false)
    {
        /// <summary>
        /// Sets a default preference value in the local defaults store.
        /// When AllMachines is true, also writes to OneDrive for cross-machine
        /// sharing.
        /// </summary>
        /// <param name="Name">The name of the default preference to set.</param>
        /// <param name="Value">The default value to set.</param>
        /// <param name="PreferencesDatabasePath">Optional path to the preferences database.</param>
        /// <param name="SessionOnly">If true, only affect session.</param>
        /// <param name="ClearSession">If true, clear session settings.</param>
        /// <param name="SkipSession">If true, skip session operations.</param>
        /// <param name="AllMachines">If true, also write to OneDrive.</param>

        // Normalize to lowercase for case-insensitive preference names
        Name = Name?.ToLowerInvariant();
        PreferencesDatabasePath = GetPreferencesDatabasePath(PreferencesDatabasePath, SessionOnly, ClearSession, SkipSession);

        WriteVerbose("Using database path: " + PreferencesDatabasePath);
        WriteVerbose("Starting Set-GenXdevDefaultPreference for '" + Name + "'");

        if (string.IsNullOrWhiteSpace(Value))
        {
            WriteVerbose("Removing default preference '" + Name + "' as value is empty");

            if (ShouldProcess(Name, "Remove default preference"))
            {
                RemoveGenXdevPreference(Name, true, PreferencesDatabasePath, SessionOnly, ClearSession, SkipSession, AllMachines);
            }
            return;
        }

        WriteVerbose("Setting default preference '" + Name + "' to: " + Value);

        if (ShouldProcess(Name, "Set default preference"))
        {
            SetValueByKeyInStore("GenXdev.PowerShell.Defaults", Name, Value, PreferencesDatabasePath);
            WriteVerbose("Successfully stored preference '" + Name + "'");

            // Write to OneDrive for cross-machine sharing
            if (AllMachines)
            {
                WriteVerbose("Writing default preference to OneDrive for all machines");
                try
                {
                    string oneDrivePath = GetOneDriveDefaultsStorePath();
                    var oneDriveData = (Hashtable)ReadJsonWithRetry(oneDrivePath, asHashtable: true);
                    oneDriveData[Name] = Value;
                    WriteJsonAtomic(oneDrivePath, oneDriveData);
                    WriteVerbose($"Written '{Name}' = '{Value}' to OneDrive defaults");
                }
                catch (Exception ex)
                {
                    WriteVerbose("Failed to write to OneDrive: " + ex.Message);
                }
            }
        }
    }

    protected string[] GetGenXdevPreferenceNames(string PreferencesDatabasePath, bool SessionOnly, bool ClearSession, bool SkipSession)
    {
        /// <summary>
        /// Retrieves all available GenXdev preference names from session and persistent stores.
        /// </summary>
        /// <param name="PreferencesDatabasePath">Optional path to the preferences database.</param>
        /// <param name="SessionOnly">If true, only check session storage.</param>
        /// <param name="ClearSession">If true, clear session preferences.</param>
        /// <param name="SkipSession">If true, skip session checks.</param>
        /// <returns>An array of unique preference names.</returns>
        var allKeys = new System.Collections.Generic.List<string>();

        if (ClearSession)
        {
            if (ShouldProcess("GenXdev.Data Module Configuration", "Clear session preference variables"))
            {
                // Use wildcard pattern for removing multiple variables
                var clearScript = ScriptBlock.Create("Microsoft.PowerShell.Utility\\Get-Variable -Name 'GenXdevPreference_*' -Scope Global -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\\Remove-Variable -Force");
                clearScript.Invoke();

                WriteVerbose("Cleared session preference variables");
            }
        }

        if (!SkipSession)
        {
            WriteVerbose("Retrieving session variables for preference names");

            // Get variable names directly from Get-Variable
            var sessionVarsScript = ScriptBlock.Create("Microsoft.PowerShell.Utility\\Get-Variable -Name 'GenXdevPreference_*' -Scope Global -ErrorAction SilentlyContinue | Microsoft.PowerShell.Utility\\Select-Object -ExpandProperty Name");
            var sessionVars = sessionVarsScript.Invoke();

            var sessionKeys = new System.Collections.Generic.List<string>();
            foreach (var pvar in sessionVars)
            {
                string varName = pvar?.ToString();
                if (!string.IsNullOrEmpty(varName) && varName.StartsWith("GenXdevPreference_"))
                {
                    // Extract the preference name after the prefix
                    string key = varName.Substring("GenXdevPreference_".Length);
                    sessionKeys.Add(key);
                }
            }

            if (sessionKeys.Count > 0)
            {
                WriteVerbose("Found " + sessionKeys.Count + " preference names in session storage");
                allKeys.AddRange(sessionKeys);
            }
        }

        if (!SessionOnly)
        {
            WriteVerbose("Retrieving preference names from database stores");
            PreferencesDatabasePath = GetPreferencesDatabasePath(PreferencesDatabasePath, SessionOnly, ClearSession, SkipSession);

            WriteVerbose("Retrieving keys from local preferences store");
            var localKeys = GetStoreKeys("GenXdev.PowerShell.Preferences", PreferencesDatabasePath);
            if (localKeys != null && localKeys.Length > 0)
            {
                allKeys.AddRange(localKeys);
            }

            WriteVerbose("Retrieving keys from local defaults store");
            var defaultKeys = GetStoreKeys("GenXdev.PowerShell.Defaults", PreferencesDatabasePath);
            if (defaultKeys != null && defaultKeys.Length > 0)
            {
                allKeys.AddRange(defaultKeys);
            }
        }

        WriteVerbose("Merging and deduplicating keys from all sources");
        var uniqueKeys = allKeys.Distinct().OrderBy(key => key).ToArray();
        WriteVerbose("Found " + uniqueKeys.Length + " unique preference names");

        return uniqueKeys;
    }
}
