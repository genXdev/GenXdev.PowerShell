using System.Collections;
using System.Management.Automation;

public abstract partial class PSGenXdevCmdlet : PSCmdlet
{
    /// <summary>
    /// <para type="synopsis">
    /// Provides local key-value store functionality for PowerShell cmdlets in the
    /// GenXdev framework.
    /// </para>
    ///
    /// <para type="description">
    /// This partial class extends the base PSGenXdevCmdlet to include methods for
    /// managing persistent local key-value stores using JSON files. Stores are
    /// organized by store names with automatic directory initialization.
    /// </para>
    ///
    /// <para type="description">
    /// Key features include:
    /// - Persistent storage of key-value pairs with metadata (last modified, user,
    ///   deletion status)
    /// - Automatic initialization of store directories
    /// - Atomic writes with retry logic
    /// - Store enumeration and key queries
    /// </para>
    /// </summary>

    /// <summary>
    /// Retrieves an array of unique store names from the local key-value store
    /// directory.
    /// </summary>
    /// <param name="DatabasePath">
    /// Optional custom path for the key-value store database. If not provided,
    /// uses the default GenXdev application data path.
    /// </param>
    /// <returns>An array of unique store names.</returns>
    protected string[] GetKeyValueStoreNames(string DatabasePath = null)
    {
        // Determine base path
        string basePath = string.IsNullOrWhiteSpace(DatabasePath) ?
            GetGenXdevAppDataPath("KeyValueStore") : DatabasePath;

        WriteVerbose($"Using KeyValueStore directory: {basePath}");

        // Ensure store directory exists
        if (!System.IO.Directory.Exists(basePath))
        {
            WriteVerbose("Store directory not found, creating...");
            ExpandPath(basePath, CreateDirectory: true);
        }

        WriteVerbose("Scanning for stores");

        // Get all JSON files in the store directory
        var jsonFiles = new System.Collections.Generic.List<string>();
        try
        {
            var files = System.IO.Directory.GetFiles(basePath, "*.json");
            foreach (var file in files)
            {
                jsonFiles.Add(System.IO.Path.GetFileName(file));
            }
        }
        catch (System.IO.DirectoryNotFoundException)
        {
            // Directory doesn't exist, return empty list
        }

        // Create dictionary to collect unique store names
        var storeNames = new System.Collections.Generic.Dictionary<string, bool>();

        // Parse filenames to extract store names
        foreach (var fileName in jsonFiles)
        {
            // Filename format: Local_StoreName.json
            var match = System.Text.RegularExpressions.Regex.Match(fileName,
                @"^(.+?)_(.+?)\.json$");
            if (match.Success)
            {
                // Extract the store name from the filename
                var fileStoreName = match.Groups[2].Value;

                // Add to unique store names collection
                if (!storeNames.ContainsKey(fileStoreName))
                {
                    storeNames[fileStoreName] = true;
                }
            }
        }

        // Return sorted unique store names
        return storeNames.Keys.OrderBy(name => name).ToArray();
    }

    /// <summary>
    /// Constructs the full file path for a key-value store based on synchronization key and store name.
    /// </summary>
    /// <param name="SynchronizationKey">
    /// The synchronization key for the store (e.g., "Local", "Global").
    /// </param>
    /// <param name="StoreName">
    /// The name of the key-value store.
    /// </param>
    /// <param name="BasePath">
    /// Optional base path for the store. If not provided, uses the default GenXdev app data path.
    /// </param>
    /// <returns>The full file path to the JSON store file.</returns>
    protected string GetKeyValueStorePath(string SynchronizationKey, string StoreName,
        string BasePath = null)
    {
        // Use default path if not provided
        if (string.IsNullOrWhiteSpace(BasePath))
        {
            BasePath = GetGenXdevAppDataPath("KeyValueStore");
        }

        WriteVerbose($"Constructing store file path for store '{StoreName}' with sync key " +
            $"'{SynchronizationKey}'");

        // Sanitize the sync key to remove invalid filename characters
        string safeSyncKey = System.Text.RegularExpressions.Regex.Replace(SynchronizationKey,
            @"[\\/:*?""<>|]", "_");

        // Sanitize the store name to remove invalid filename characters
        string safeStoreName = System.Text.RegularExpressions.Regex.Replace(StoreName,
            @"[\\/:*?""<>|]", "_");

        // Construct the filename by combining safe sync key and store name
        string filename = $"{safeSyncKey}_{safeStoreName}.json";

        // Return the full path by combining base path with filename
        return System.IO.Path.Combine(BasePath, filename);
    }

    /// <summary>
    /// Retrieves all active (non-deleted) keys from a local key-value store.
    /// </summary>
    /// <param name="StoreName">
    /// The name of the key-value store to query.
    /// </param>
    /// <param name="DatabasePath">
    /// Optional custom database path. Uses default if not specified.
    /// </param>
    /// <returns>An array of active key names in the store.</returns>
    protected string[] GetStoreKeys(string StoreName, string DatabasePath = null)
    {
        // Determine base path
        string basePath = string.IsNullOrWhiteSpace(DatabasePath) ?
            GetGenXdevAppDataPath("KeyValueStore") : DatabasePath;

        WriteVerbose($"Using KeyValueStore directory: {basePath}");

        // Ensure store directory exists
        if (!System.IO.Directory.Exists(basePath))
        {
            WriteVerbose("Store directory not found, creating...");
            ExpandPath(basePath, CreateDirectory: true);
        }

        // Get the local store file path
        string storeFilePath = GetKeyValueStorePath("Local", StoreName, basePath);

        WriteVerbose($"Querying keys from store file: {storeFilePath}");

        // Read the JSON store data with retry logic
        var storeData = (Hashtable)ReadJsonWithRetry(storeFilePath, asHashtable: true);

        var keys = new System.Collections.Generic.List<string>();

        // Return active (non-deleted) key names
        foreach (string keyName in storeData.Keys)
        {
            var entry = storeData[keyName];

            // Check if entry has metadata structure
            if (entry is Hashtable hashtable && hashtable.ContainsKey("deletedDate"))
            {
                // Entry has metadata, check if not deleted
                if (hashtable["deletedDate"] == null)
                {
                    keys.Add(keyName);
                }
            }
            else
            {
                // Legacy format without metadata, return key name
                keys.Add(keyName);
            }
        }

        return keys.ToArray();
    }

    /// <summary>
    /// Retrieves the value associated with a specific key from a local
    /// key-value store.
    /// </summary>
    /// <param name="StoreName">
    /// The name of the key-value store.
    /// </param>
    /// <param name="KeyName">
    /// The key whose value to retrieve.
    /// </param>
    /// <param name="DefaultValue">
    /// The default value to return if the key is not found or is deleted.
    /// </param>
    /// <param name="DatabasePath">
    /// Optional custom database path.
    /// </param>
    /// <returns>The value associated with the key, or the default value if not found.</returns>
    protected object GetValueByKeyFromStore(string StoreName, string KeyName,
        string DefaultValue = null, string DatabasePath = null)
    {
        // Determine base path
        string basePath = string.IsNullOrWhiteSpace(DatabasePath) ?
            GetGenXdevAppDataPath("KeyValueStore") : DatabasePath;

        WriteVerbose($"Using KeyValueStore directory: {basePath}");

        // Ensure store directory exists
        if (!System.IO.Directory.Exists(basePath))
        {
            WriteVerbose("Store directory not found, creating...");
            ExpandPath(basePath, CreateDirectory: true);
        }

        // Get JSON file path for this store
        string storeFilePath = GetKeyValueStorePath("Local", StoreName, basePath);

        // Log the query operation details
        WriteVerbose($"Querying store '{StoreName}' for key '{KeyName}' at: {storeFilePath}");

        // Read the JSON store data with retry logic
        var storeData = (Hashtable)ReadJsonWithRetry(storeFilePath, asHashtable: true);

        // Check if key exists and is not deleted
        if (storeData.ContainsKey(KeyName))
        {
            var entry = storeData[KeyName];

            // Check if entry has metadata structure
            if (entry is Hashtable hashtable && hashtable.ContainsKey("deletedDate"))
            {
                // Entry has metadata, check if deleted
                if (hashtable["deletedDate"] == null || hashtable["deletedDate"].ToString() == "")
                {
                    // Log successful value retrieval
                    WriteVerbose("Value found");

                    // Return the value from the entry
                    return hashtable["value"];
                }
            }
            else if (entry is Hashtable hashtable2)
            {
                // Return the value from the entry
                return hashtable2["value"];
            }
            else
            {
                // Legacy format without metadata, return directly
                WriteVerbose("Value found (legacy format)");
                return entry;
            }
        }

        // Log fallback to default value
        WriteVerbose("No value found, returning default");

        // Return the specified default value
        return DefaultValue;
    }

    /// <summary>
    /// Removes a key from a local key-value store by marking it as deleted.
    /// </summary>
    /// <param name="StoreName">
    /// The name of the key-value store.
    /// </param>
    /// <param name="KeyName">
    /// The key to remove.
    /// </param>
    /// <param name="DatabasePath">
    /// Optional custom database path.
    /// </param>
    protected void RemoveKeyFromStore(string StoreName, string KeyName,
        string DatabasePath = null)
    {
        // Determine base path
        string basePath = string.IsNullOrWhiteSpace(DatabasePath) ?
            GetGenXdevAppDataPath("KeyValueStore") : DatabasePath;

        WriteVerbose($"Using KeyValueStore directory: {basePath}");

        // Ensure store directory exists
        if (!System.IO.Directory.Exists(basePath))
        {
            WriteVerbose("Store directory not found, creating...");
            ExpandPath(basePath, CreateDirectory: true);
        }

        // Get current user info for audit trail
        string computerName = Environment.GetEnvironmentVariable("COMPUTERNAME");
        string userName = Environment.GetEnvironmentVariable("USERNAME");
        string lastModifiedBy = $"{computerName}\\{userName}";

        WriteVerbose($"Preparing to remove key '{KeyName}' from store '{StoreName}'");

        // Get JSON file path for this store
        string storeFilePath = GetKeyValueStorePath("Local", StoreName, basePath);

        // Read existing store data with retry logic
        var storeData = (Hashtable)ReadJsonWithRetry(storeFilePath, asHashtable: true);

        // Check if key exists
        if (storeData.ContainsKey(KeyName))
        {
            // Mark as deleted
            WriteVerbose("Marking key as deleted");

            var keyValue = storeData[KeyName];
            if (keyValue is Hashtable keyHashtable)
            {
                keyHashtable["deletedDate"] = DateTime.UtcNow.ToString("o");
                keyHashtable["lastModified"] = DateTime.UtcNow.ToString("o");
                keyHashtable["lastModifiedBy"] = lastModifiedBy;
            }
            else
            {
                // Legacy format, convert to new format with deletion
                var newValue = new Hashtable
                {
                    ["value"] = keyValue,
                    ["lastModified"] = DateTime.UtcNow.ToString("o"),
                    ["lastModifiedBy"] = lastModifiedBy,
                    ["deletedDate"] = DateTime.UtcNow.ToString("o")
                };
                storeData[KeyName] = newValue;
            }

            // Write updated store data atomically with retry logic
            WriteJsonAtomic(storeFilePath, storeData);
        }
        else
        {
            WriteVerbose($"Key '{KeyName}' not found in store '{StoreName}'");
        }
    }

    /// <summary>
    /// Removes an entire local key-value store by physically deleting its
    /// JSON file.
    /// </summary>
    /// <param name="StoreName">
    /// The name of the store to remove.
    /// </param>
    /// <param name="DatabasePath">
    /// Optional custom database path.
    /// </param>
    protected void RemoveKeyValueStore(string StoreName, string DatabasePath = null)
    {
        // Determine base path
        string basePath = string.IsNullOrWhiteSpace(DatabasePath) ?
            GetGenXdevAppDataPath("KeyValueStore") : DatabasePath;

        WriteVerbose($"Using KeyValueStore directory: {basePath}");

        // Get JSON file path for this store
        string storeFilePath = GetKeyValueStorePath("Local", StoreName, basePath);

        // Physically remove the file
        if (System.IO.File.Exists(storeFilePath))
        {
            WriteVerbose($"Permanently deleting store file: {storeFilePath}");
            System.IO.File.Delete(storeFilePath);
        }
        else
        {
            WriteVerbose($"Store file not found: {storeFilePath}");
        }
    }

    /// <summary>
    /// Sets or updates a value for a specific key in a local key-value store.
    /// </summary>
    /// <param name="StoreName">
    /// The name of the key-value store.
    /// </param>
    /// <param name="KeyName">
    /// The key to set or update.
    /// </param>
    /// <param name="Value">
    /// The value to store.
    /// </param>
    /// <param name="DatabasePath">
    /// Optional custom database path.
    /// </param>
    protected void SetValueByKeyInStore(string StoreName, string KeyName, string Value,
        string DatabasePath = null)
    {
        // Determine base path
        string basePath = string.IsNullOrWhiteSpace(DatabasePath) ?
            GetGenXdevAppDataPath("KeyValueStore") : DatabasePath;

        WriteVerbose("Using KeyValueStore directory: " + basePath);

        // Ensure store directory exists
        if (!System.IO.Directory.Exists(basePath))
        {
            WriteVerbose("Store directory not found. Creating...");
            ExpandPath(basePath, CreateDirectory: true);
        }

        // Get current user identity for audit trail purposes
        string lastModifiedBy = Environment.MachineName + "\\" + Environment.UserName;

        WriteVerbose("Setting value as user: " + lastModifiedBy);

        WriteVerbose("Executing upsert for key '" + KeyName + "' in store '" + StoreName + "'");

        // Get JSON file path for this store
        string storeFilePath = GetKeyValueStorePath("Local", StoreName, basePath);

        // Read existing store data with retry logic
        var storeData = (Hashtable)ReadJsonWithRetry(storeFilePath, asHashtable: true);

        // Create or update the entry with metadata
        var entry = new Hashtable
        {
            ["value"] = Value,
            ["lastModified"] = DateTime.UtcNow.ToString("o"),
            ["lastModifiedBy"] = lastModifiedBy,
            ["deletedDate"] = null
        };

        storeData[KeyName] = entry;

        // Write updated store data atomically with retry logic
        WriteJsonAtomic(storeFilePath, storeData);
    }

}