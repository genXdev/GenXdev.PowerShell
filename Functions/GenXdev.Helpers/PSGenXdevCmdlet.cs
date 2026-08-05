using System.Collections;
using System.Collections.Concurrent;
using System.Collections.ObjectModel;
using System.Management.Automation;
using System.Text;
using System.Text.Json;

public abstract partial class PSGenXdevCmdlet : PSCmdlet
{
    protected override void BeginProcessing()
    {
        base.BeginProcessing();
    }
    protected override void ProcessRecord()
    {
        base.ProcessRecord();
    }
    protected override void EndProcessing()
    {
        base.EndProcessing();
    }
}

/// <summary>
/// <para type="synopsis">
/// Base class for GenXdev PowerShell cmdlets providing common functionality and utilities.
/// </para>
///
/// <para type="description">
/// This abstract base class extends PSCmdlet and provides shared methods for parameter copying,
/// JSON serialization, script invocation, path expansion, and other common operations used
/// across GenXdev PowerShell modules. It serves as a foundation for implementing PowerShell
/// cmdlets with consistent behavior and utility functions.
/// </para>
///
/// <para type="description">
/// Key features include:
/// - Parameter value copying between cmdlets
/// - JSON serialization/deserialization using System.Text.Json
/// - Safe PowerShell script execution
/// - Path expansion with PowerShell semantics
/// - Installation consent confirmation
/// - Global variable management
/// </para>
///
/// <example>
/// <para>Inherit from this class to create a new GenXdev cmdlet:</para>
/// <code>
/// public class MyCmdlet : PSGenXdevCmdlet
/// {
///     protected override void ProcessRecord()
///     {
///         // Use base class methods here
///         var path = ExpandPath("somepath");
///         WriteObject(path);
///     }
/// }
/// </code>
/// </example>
/// </summary>
public abstract partial class PSGenXdevCmdlet : PSCmdlet
{
    internal static readonly ConcurrentDictionary<string, CommandInfo> CommandInfoCache =
        new ConcurrentDictionary<string, CommandInfo>(StringComparer.OrdinalIgnoreCase);

    private static readonly ScriptBlock ReadJsonWithRetryScript = ScriptBlock.Create(@"
param(
    [string]$FilePath,
    [int]$MaxRetries,
    [int]$RetryDelayMs,
    [switch]$AsHashtable
)
GenXdev\ReadJsonWithRetry `
    -FilePath $FilePath `
    -MaxRetries $MaxRetries `
    -RetryDelayMs $RetryDelayMs `
    -AsHashtable:$AsHashtable
");

    /// <summary>
    /// Holds state for a pending debounced write: the cancellation token
    /// source to cancel on re-invocation, the payload to write, and the
    /// UTC timestamp when this debounce was scheduled. Used to prevent
    /// stale timers from overwriting data written by a more recent call.
    /// </summary>
    private sealed class DebounceState
    {
        public CancellationTokenSource Cts;
        public byte[] Data;
        public int MaxRetries;
        public int RetryDelayMs;
        public DateTime ScheduledAt;
    }

    /// <summary>
    /// Tracks pending debounced writes keyed by normalized (full) file path.
    /// Thread-safe via ConcurrentDictionary; cancel-and-replace on each call.
    /// </summary>
    private static readonly ConcurrentDictionary<string, DebounceState> _debounceWrites =
        new ConcurrentDictionary<string, DebounceState>(StringComparer.OrdinalIgnoreCase);

    /// <summary>
    /// Copies parameter values from the current cmdlet to another cmdlet with identical parameter names.
    /// </summary>
    /// <param name="CmdletName">The name of the target cmdlet whose parameters should be matched.</param>
    /// <returns>A hashtable containing the copied parameter values with their default values where applicable.</returns>
    protected Hashtable CopyIdenticalParamValues(string CmdletName)
    {
        // Get command info for the target function
        var functionInfo = GetCachedCommandInfo(CmdletName);
        if (functionInfo?.Parameters == null)
        {
            throw new ArgumentException($"Function '{CmdletName}' not found");
        }

        var results = new Hashtable();
        var defaults = CreateDefaultsHashtable();

        // Convert bound parameters to dictionary
        var boundParamsDict = ConvertToParameterDictionary(this.MyInvocation.BoundParameters);

        // Process each parameter of the target function
        foreach (var parameterKvp in functionInfo.Parameters)
        {
            var paramName = parameterKvp.Key;
            var paramInfo = parameterKvp.Value;

            if (boundParamsDict.ContainsKey(paramName))
            {
                var paramValue = boundParamsDict[paramName];

                // Handle switch parameters
                if (paramInfo.ParameterType == typeof(SwitchParameter))
                {
                    if (IsTrue(paramValue))
                    {
                        results[paramName] = paramValue;
                    }
                }
                else
                {
                    results[paramName] = paramValue;
                }
            }
            else
            {
                // Use default values
                if (paramInfo.ParameterType != typeof(SwitchParameter))
                {
                    var defaultValue = defaults[paramName];
                    if (defaultValue != null)
                    {
                        results[paramName] = defaultValue;
                    }
                }
                else
                {
                    var defaultValue = defaults[paramName];
                    if (IsTrue(defaultValue))
                    {
                        results[paramName] = true;
                    }
                }
            }
        }

        return results;
    }

    /// <summary>
    /// Convert object to JSON using System.Text.Json
    /// </summary>
    /// <param name="obj">The object to serialize to JSON.</param>
    /// <param name="depth">The maximum depth for serialization (default 20).</param>
    /// <returns>A JSON string representation of the object.</returns>
    protected string ConvertToJson(object obj, int depth = 20)
    {
        return InvokeScript<string>("param ($obj) ConvertTo-Json -Depth " + depth.ToString() + " -Compress $obj", new object[] { obj });
    }

    /// <summary>
    /// Convert JSON to object array using System.Text.Json
    /// </summary>
    /// <param name="json">The JSON string to deserialize.</param>
    /// <returns>An array containing the deserialized object.</returns>
    protected object[] ConvertFromJson(string json)
    {
        var options = new JsonSerializerOptions { MaxDepth = 20 };
        var obj = JsonSerializer.Deserialize<object>(json, options);
        return new object[] { obj };
    }

    /// <summary>
    /// Convert JSON to typed array using System.Text.Json
    /// </summary>
    /// <typeparam name="T">The type to deserialize to.</typeparam>
    /// <param name="json">The JSON string to deserialize.</param>
    /// <returns>An array of the specified type containing the deserialized objects.</returns>
    protected T[] ConvertFromJson<T>(string json)
    {
        var options = new JsonSerializerOptions { MaxDepth = 20 };
        var obj = JsonSerializer.Deserialize<T>(json, options);
        return new T[] { obj };
    }

    /// <summary>
    /// Serializes an object to indented JSON and writes it atomically
    /// via temp-file + rename. Handles byte[], string (JSON), Hashtable,
    /// PSCustomObject, arrays, and any serializable .NET object.
    /// When debounceMs &gt; 0, writes are debounced.
    /// </summary>
    /// <param name="filePath">The path to the JSON file.</param>
    /// <param name="data">The data to serialize.</param>
    /// <param name="maxRetries">Maximum number of retry attempts.</param>
    /// <param name="retryDelayMs">Delay between retries in ms.</param>
    /// <param name="debounceMs">If &gt; 0, coalesce writes within this
    /// window (ms).</param>
    /// <param name="depth">Maximum serialization depth. Default 30,
    /// matching PowerShell's ConvertTo-Json default.</param>
    /// <param name="compact">If true, produce compact JSON without
    /// indentation or extra whitespace.</param>
    protected void WriteJsonAtomic(string filePath, Object data,
        int maxRetries = 10, int retryDelayMs = 1000, int debounceMs = 0,
        int? depth = null, bool? compress = null, bool? enumsAsStrings = null, bool? asArray = null,
        Newtonsoft.Json.StringEscapeHandling? escapeHandling = null)
    {
        string json = this.InvokeScript<string>(@"

param($obj,$depth,$compress,$enumsAsStrings,$asArray?,$escapeHandling)

$params = @{
}

if ($null -ne $depth) { $params.Depth = $depth }
if ($true -eq $compress) { $params.Compress = $true }
if ($true -eq $enumsAsStrings) { $params.EnumsAsStrings = $true }
if ($true -eq $asArray) { $params.AsArray = $true }
if ($null -ne $escapeHandling) { $params.EscapeHandling = $escapeHandling }

$obj | ConvertTo-Json @params",
    new object[] {
        data,
        depth.HasValue ? depth.Value : null,
        compress.HasValue ? compress.Value : null,
        enumsAsStrings.HasValue ? enumsAsStrings.Value : null,
        asArray.HasValue ? asArray.Value : null,
        escapeHandling.HasValue ? escapeHandling.Value : null
    });

        WriteTextFileAtomic(filePath, json, maxRetries, retryDelayMs, debounceMs);
    }

    /// <summary>
    /// Schedules a debounced atomic text-file write. If a write is
    /// already scheduled for the same path, updates its payload under
    /// lock instead of canceling and recreating the timer — only the
    /// last call's content gets written when the timer fires.
    /// If the file's LastWriteTimeUtc is already older than debounceMs,
    /// writes immediately instead of scheduling.
    /// </summary>
    internal static void ScheduleDebouncedWrite(string filePath, byte[] content,
        int maxRetries, int retryDelayMs, int debounceMs)
    {
        string normalizedPath = Path.GetFullPath(filePath);

        // Compute how long since the file was last written to disk
        var elapsedSinceLastWrite = int.MaxValue;
        if (File.Exists(filePath))
        {
            var lastWrite = File.GetLastWriteTimeUtc(filePath);
            elapsedSinceLastWrite = (int)(DateTime.UtcNow - lastWrite).TotalMilliseconds;
        }

        // If the debounce window has already passed (or file doesn't
        // exist yet), write immediately — no need to wait
        if (elapsedSinceLastWrite >= debounceMs)
        {
            if (_debounceWrites.TryRemove(normalizedPath, out var pending))
            {
                pending.Cts.Cancel();
                pending.Cts.Dispose();
            }
            if (!WriteFileAtomicInternal(filePath, content, maxRetries, retryDelayMs))
            {
                // Immediate write failed — reschedule as debounced
                if (maxRetries > 1)
                {
                    ScheduleDebouncedWrite(filePath, content, maxRetries - 1, retryDelayMs, retryDelayMs);
                }
            }
            return;
        }

        int remainingMs = debounceMs - elapsedSinceLastWrite;

        // AddOrUpdate is atomic per-key — avoids race with timer's
        // TryRemove. If key exists: lock the existing state and update
        // its payload (timer keeps running, writes the latest content
        // when it fires). If key doesn't exist: create state + timer.
        _debounceWrites.AddOrUpdate(normalizedPath,
            _ =>
            {
                var cts = new CancellationTokenSource();
                var state = new DebounceState
                {
                    Cts = cts,
                    Data = content,
                    MaxRetries = maxRetries,
                    RetryDelayMs = retryDelayMs,
                    ScheduledAt = DateTime.UtcNow
                };
                StartDebounceTimer(normalizedPath, filePath, state, remainingMs);
                return state;
            },
            (_, existing) =>
            {
                lock (existing)
                {
                    existing.Data = content;
                    existing.MaxRetries = maxRetries;
                    existing.ScheduledAt = DateTime.UtcNow;
                }
                return existing;
            });
    }

    /// <summary>
    /// Starts the debounce timer for a DebounceState. When the timer
    /// fires, the latest payload is written to disk. On failure,
    /// retries in-place by decrementing MaxRetries under lock and
    /// restarting the timer — the state stays in the dictionary so
    /// ScheduleDebouncedWrite can still update it with fresh data.
    /// Only removes from dictionary on success or exhaustion.
    /// </summary>
    private static void StartDebounceTimer(string normalizedPath, string filePath,
        DebounceState state, int delayMs)
    {
        var token = state.Cts.Token;
        var scheduledAt = state.ScheduledAt;

        Task.Delay(delayMs, token).ContinueWith(t =>
        {
            if (t.IsCanceled) return;

            byte[] bytesToWrite;
            int maxRetries, retryDelayMs;
            lock (state)
            {
                // Guard against stale-timer overwrite: if the file was
                // written after we were scheduled, a more recent call
                // already wrote it — don't overwrite.
                if (File.Exists(filePath))
                {
                    var fileWriteTime = File.GetLastWriteTimeUtc(filePath);
                    if (fileWriteTime > scheduledAt)
                    {
                        _debounceWrites.TryRemove(normalizedPath, out _);
                        state.Cts.Dispose();
                        return;
                    }
                }

                bytesToWrite = state.Data;
                maxRetries = state.MaxRetries;
                retryDelayMs = state.RetryDelayMs;
            }

            if (WriteFileAtomicInternal(filePath, bytesToWrite, maxRetries, retryDelayMs))
            {
                // Success — we're done
                _debounceWrites.TryRemove(normalizedPath, out _);
                state.Cts.Dispose();
                return;
            }

            // Write failed — retry in-place. State stays in the
            // dictionary so ScheduleDebouncedWrite can atomically
            // update payload + reset MaxRetries under the same lock.
            lock (state)
            {
                state.MaxRetries--;
                if (state.MaxRetries <= 0)
                {
                    _debounceWrites.TryRemove(normalizedPath, out _);
                    state.Cts.Dispose();
                    return;
                }
            }

            // Restart the timer with a fresh CancellationTokenSource
            var oldCts = state.Cts;
            var newCts = new CancellationTokenSource();
            state.Cts = newCts;
            oldCts.Dispose();
            StartDebounceTimer(normalizedPath, filePath, state, retryDelayMs);
        }, TaskContinuationOptions.NotOnCanceled);
    }

    /// <summary>
    /// Performs the actual atomic byte-array write using a temp-file +
    /// rename strategy. Returns true on success, false if the write
    /// failed. Callers handle retry/reschedule.
    /// Pure .NET — no PowerShell dependency, no lock files needed.
    /// </summary>
    protected static bool WriteFileAtomicInternal(string filePath, byte[] content,
        int maxRetries, int retryDelayMs)
    {
        string directory = Path.GetDirectoryName(filePath);
        if (!string.IsNullOrEmpty(directory) && !Directory.Exists(directory))
        {
            Directory.CreateDirectory(directory);
        }

        string tmpFile = filePath + "." + Guid.NewGuid().ToString("N") + ".tmp";

        try
        {
            File.WriteAllBytes(tmpFile, content);

            // Atomic rename on the same volume — file stays consistent
            File.Move(tmpFile, filePath, overwrite: true);
            return true;
        }
        catch
        {
            // Clean up temp file — caller handles retry/reschedule
            try { if (File.Exists(tmpFile)) File.Delete(tmpFile); } catch { }
            return false;
        }
    }

    /// <summary>
    /// Writes a byte array to a file atomically. When debounceMs &gt; 0,
    /// rapid writes to the same file are coalesced via
    /// ScheduleDebouncedWrite. This is the preferred entry point for
    /// cmdlets — it handles debounce routing internally.
    /// </summary>
    /// <param name="filePath">The path to the file.</param>
    /// <param name="content">The bytes to write.</param>
    /// <param name="maxRetries">Maximum number of retry attempts.</param>
    /// <param name="retryDelayMs">Delay between retries in ms.</param>
    /// <param name="debounceMs">If &gt; 0, coalesce writes within this
    /// window (ms).</param>
    public static void WriteFileAtomic(string filePath, byte[] content,
        int maxRetries, int retryDelayMs, int debounceMs)
    {
        if (debounceMs > 0)
        {
            ScheduleDebouncedWrite(filePath, content, maxRetries,
                retryDelayMs, debounceMs);
            return;
        }

        WriteFileAtomicInternal(filePath, content, maxRetries, retryDelayMs);
    }

    /// <summary>
    /// Writes a string to a text file atomically with optional encoding
    /// and debounce support. Encodes the string and delegates to
    /// WriteFileAtomic(bytes, maxRetries, retryDelayMs, debounceMs).
    /// This is the preferred entry point for cmdlets.
    /// </summary>
    /// <param name="filePath">The path to the file.</param>
    /// <param name="content">The text to write.</param>
    /// <param name="maxRetries">Maximum number of retry attempts.</param>
    /// <param name="retryDelayMs">Delay between retries in ms.</param>
    /// <param name="debounceMs">If &gt; 0, coalesce writes within this
    /// window (ms).</param>
    /// <param name="encoding">The text encoding to use. Defaults to
    /// UTF-8 if null.</param>
    public static void WriteTextFileAtomic(string filePath, string content,
        int maxRetries, int retryDelayMs, int debounceMs,
        Encoding encoding = null)
    {
        byte[] bytes = (encoding ?? Encoding.UTF8).GetBytes(content);

        WriteFileAtomic(filePath, bytes, maxRetries, retryDelayMs,
            debounceMs);
    }

    /// <summary>
    /// Reads JSON file with retry logic
    /// </summary>
    /// <param name="filePath">The path to the JSON file.</param>
    /// <param name="maxRetries">Maximum number of retry attempts (default 10).</param>
    /// <param name="retryDelayMs">Delay between retries in milliseconds (default 200).</param>
    /// <param name="asHashtable">Whether to return the result as a hashtable.</param>
    /// <returns>The deserialized object or hashtable from the JSON file.</returns>
    protected object ReadJsonWithRetry(string filePath, int maxRetries = 10,
        int retryDelayMs = 200, bool asHashtable = false)
    {
        Collection<PSObject> results = ReadJsonWithRetryScript.Invoke(
            filePath,
            maxRetries,
            retryDelayMs,
            new SwitchParameter(asHashtable)
        );

        if (results == null || results.Count == 0)
        {
            return asHashtable ? new Hashtable() : null;
        }

        return results[0]?.BaseObject;
    }

    /// <summary>
    /// Executes a PowerShell script and returns the result of type T, handling
    /// any errors that occur.
    /// </summary>
    /// <typeparam name="T">The type of the result to return.</typeparam>
    /// <param name="script">The script to execute.</param>
    /// <param name="args">Optional arguments to pass to the script.</param>
    /// <returns>The result as type T.</returns>
    protected T InvokeScript<T>(string script, object[] args = null)
    {
        // execute the PowerShell script and collect all output objects
        Collection<PSObject> results = InvokeCommand.InvokeScript(script, args);

        // check if the entire results collection is of type T
        // handles cases where script returns a single collection
        if (results is T)
        {
            return (T)(object)results;
        }

        // check if first result's base object is of type T
        // handles cases where script returns wrapped PSObjects
        if (results.Count > 0 && results[0].BaseObject is T)
        {
            return (T)results[0].BaseObject;
        }

        // return default value if no matching type found
        return default(T);
    }

    /// <summary>
    /// Executes a PowerShell script and yields results of type T, unwrapping
    /// PSObjects to their BaseObject where needed.
    /// </summary>
    /// <typeparam name="T">The type of objects to return.</typeparam>
    /// <param name="script">The script to execute.</param>
    /// <param name="args">Optional arguments to pass to the script.</param>
    /// <returns>An enumerable of results of type T.</returns>
    protected IEnumerable<T> InvokeScriptEnumerable<T>(
        string script, object[] args = null)
    {
        Collection<PSObject> results =
            InvokeCommand.InvokeScript(script, args);

        foreach (var result in results)
        {
            if (result is T obj1)
            {
                yield return obj1;
            }
            else if (result?.BaseObject is T obj2)
            {
                yield return obj2;
            }
        }
    }

    /// <summary>
    /// Executes a PowerShell script and returns a list of results of type T,
    /// unwrapping PSObjects to their BaseObject where needed.
    /// </summary>
    /// <typeparam name="T">The type of objects in the list.</typeparam>
    /// <param name="script">The script to execute.</param>
    /// <param name="args">Optional arguments to pass to the script.</param>
    /// <returns>A list containing all results of type T.</returns>
    protected List<T> InvokeScriptList<T>(
        string script, object[] args = null)
    {
        var list = new List<T>();
        foreach (var result in
            InvokeScriptEnumerable<T>(script, args))
        {
            list.Add(result);
        }
        return list;
    }

    /// <summary>
    /// Invokes a PowerShell cmdlet and returns an enumerable of results of type T.
    /// </summary>
    /// <typeparam name="T">The type of objects to return.</typeparam>
    /// <param name="Cmdlet">The name of the cmdlet to invoke.</param>
    /// <param name="parameters">Optional hashtable of parameters to pass.</param>
    /// <param name="includeIdenticalParamValues">Whether to include identical parameter values from current cmdlet.</param>
    /// <param name="paramsToExclude">Array of parameter names to exclude.</param>
    /// <returns>An enumerable of results of type T.</returns>
    protected IEnumerable<T> InvokeCmdlet<T>(
        string Cmdlet,
        Hashtable parameters = null,
        bool includeIdenticalParamValues = false,
        params string[] paramsToExclude
    )
    {
        StringBuilder script = new StringBuilder();
        script.AppendLine("param($invocationArgs)");
        script.AppendLine("function go {");
        script.AppendLine("  param(");
        bool first = true;
        parameters = parameters ?? new Hashtable();

        if (includeIdenticalParamValues)
        {
            var old = parameters;
            parameters = CopyIdenticalParamValues(Cmdlet);
            foreach (DictionaryEntry entry in old)
            {
                parameters[entry.Key] = entry.Value;
            }
        }

        // filter parameters collection
        if (paramsToExclude != null && paramsToExclude.Length > 0)
        {
            var filtered = new Hashtable();

            foreach (DictionaryEntry entry in parameters)
            {
                if (!Array.Exists(paramsToExclude, p => p.Equals(entry.Key.ToString(),
                    StringComparison.OrdinalIgnoreCase)))
                {
                    filtered[entry.Key] = entry.Value;
                }
            }

            parameters = filtered;
        }

        foreach (DictionaryEntry entry in parameters)
        {
            if (!first)
            {
                script.AppendLine(", ");
            }
            script.AppendFormat("${0}", entry.Key);
            first = false;
        }

        script.AppendLine(") ");
        script.AppendFormat("{0} ", Cmdlet);
        first = true;

        foreach (DictionaryEntry entry in parameters)
        {
            if (!first)
            {
                script.Append(" ");
            }
            script.AppendFormat("-{0}:${0}", entry.Key);
            first = false;
        }

        script.AppendLine(" ; ");
        script.AppendLine("} ");
        script.AppendLine("go @invocationArgs ; ");

        var scriptBlock = ScriptBlock.Create(script.ToString());

        foreach (var result in scriptBlock.Invoke(parameters))
        {
            if (result is T obj1)
            {
                yield return obj1;
            }
            else if (result?.BaseObject is T obj2)
            {
                yield return obj2;
            }
        }
    }

    /// <summary>
    /// Invokes a PowerShell cmdlet and returns a single result of type T.
    /// </summary>
    /// <typeparam name="T">The type of object to return.</typeparam>
    /// <param name="Cmdlet">The name of the cmdlet to invoke.</param>
    /// <param name="parameters">Optional hashtable of parameters to pass.</param>
    /// <param name="includeIdenticalParamValues">Whether to include identical parameter values from current cmdlet.</param>
    /// <param name="paramsToExclude">Array of parameter names to exclude.</param>
    /// <returns>The first result of type T, or default if none found.</returns>
    protected T InvokeCmdletSingle<T>(
       string Cmdlet,
       Hashtable parameters = null,
       bool includeIdenticalParamValues = false,
       params string[] paramsToExclude
   )
    {
        foreach (var result in InvokeCmdlet<T>(Cmdlet, parameters, includeIdenticalParamValues,
            paramsToExclude))
        {
            return result;
        }
        return default(T);
    }

    /// <summary>
    /// Invokes a PowerShell cmdlet and returns a list of results of type T.
    /// </summary>
    /// <typeparam name="T">The type of objects in the list.</typeparam>
    /// <param name="Cmdlet">The name of the cmdlet to invoke.</param>
    /// <param name="parameters">Optional hashtable of parameters to pass.</param>
    /// <param name="includeIdenticalParamValues">Whether to include identical parameter values from current cmdlet.</param>
    /// <param name="paramsToExclude">Array of parameter names to exclude.</param>
    /// <returns>A list containing all results of type T.</returns>
    protected System.Collections.Generic.List<T> InvokeCmdletList<T>(
       string Cmdlet,
       Hashtable parameters = null,
       bool includeIdenticalParamValues = false,
       params string[] paramsToExclude
   )
    {
        var list = new List<T>();
        foreach (var result in InvokeCmdlet<T>(Cmdlet, parameters, includeIdenticalParamValues,
            paramsToExclude))
        {
            list.Add(result);
        }
        return list;
    }

    #region Private
    /// <summary>
    /// Retrieves cached command information for a given function name.
    /// </summary>
    /// <param name="functionName">The name of the function to get command info for.</param>
    /// <returns>The CommandInfo object for the function, or null if not found.</returns>
    protected CommandInfo GetCachedCommandInfo(string functionName)
    {
        if (CommandInfoCache.TryGetValue(functionName, out var cachedInfo))
        {
            return cachedInfo;
        }

        var getCommandScript = $"Microsoft.PowerShell.Core\\Get-Command -Name '{functionName}' " +
            "-ErrorAction SilentlyContinue";
        var commandResults = InvokeCommand.InvokeScript(getCommandScript);

        CommandInfo commandInfo = null;
        if (commandResults?.Any() == true)
        {
            commandInfo = commandResults.FirstOrDefault()?.BaseObject as CommandInfo;
        }

        CommandInfoCache.TryAdd(functionName, commandInfo);
        return commandInfo;
    }

    /// <summary>
    /// Expands a file path using PowerShell semantics, with optional directory creation and validation.
    /// </summary>
    /// <param name="Path">The path to expand.</param>
    /// <param name="CreateDirectory">Whether to create the directory if it doesn't exist.</param>
    /// <param name="CreateFile">Whether to create the file if it doesn't exist.</param>
    /// <param name="DeleteExistingFile">Whether to delete the existing file.</param>
    /// <param name="FileMustExist">Whether the file must exist.</param>
    /// <param name="DirectoryMustExist">Whether the directory must exist.</param>
    /// <returns>The expanded path string.</returns>
    protected string ExpandPath(string Path,
    bool CreateDirectory = false,
    bool CreateFile = false,
    bool DeleteExistingFile = false,
    bool FileMustExist = false,
    bool DirectoryMustExist = false)
    {
        // Build the Expand-Path command with conditional parameters
        var scriptBuilder = new System.Text.StringBuilder();
        scriptBuilder.Append("param($Path) GenXdev\\Expand-Path -FilePath $Path");
        if (CreateDirectory)
        {
            scriptBuilder.Append(" -CreateDirectory");
        }
        if (CreateFile)
        {
            scriptBuilder.Append(" -CreateFile");
        }
        if (DeleteExistingFile)
        {
            scriptBuilder.Append(" -DeleteExistingFile");
        }
        if (FileMustExist)
        {
            scriptBuilder.Append(" -FileMustExist");
        }
        if (DirectoryMustExist)
        {
            scriptBuilder.Append(" -DirectoryMustExist");
        }
        var expandPathScript = ScriptBlock.Create(scriptBuilder.ToString());
        var result = expandPathScript.Invoke(Path);
        if (result?.Count > 0 && result[0]?.BaseObject != null)
        {
            return result[0].BaseObject.ToString();
        }
        return Path;
    }

    /// <summary>
    /// Confirms user consent for installing third-party software
    /// </summary>
    /// <param name="applicationName">The name of the application to install.</param>
    /// <param name="source">The source of the installation.</param>
    /// <param name="description">Optional description of the software.</param>
    /// <param name="publisher">Optional publisher name.</param>
    /// <param name="forceConsent">Automatically consent to this installation type and set persistent flag..</param>
    /// <param name="consentToThirdPartySoftwareInstallation">Whether consent is for third-party software.</param>
    /// <returns>True if consent is granted, false otherwise.</returns>
    protected bool ConfirmInstallationConsent(string applicationName, string source,
        string description = null, string publisher = null, bool forceConsent = false,
        bool consentToThirdPartySoftwareInstallation = false)
    {
        var scriptBuilder = new System.Text.StringBuilder();
        scriptBuilder.Append("param($ApplicationName, $Source, $Description, $Publisher, " +
            "$AutoConsent, $AutoConsentAllPackages) ");
        scriptBuilder.Append("GenXdev\\Confirm-InstallationConsent ");
        scriptBuilder.Append("-ApplicationName $ApplicationName ");
        scriptBuilder.Append("-Source $Source");
        if (!string.IsNullOrEmpty(description))
        {
            scriptBuilder.Append(" -Description $Description");
        }
        if (!string.IsNullOrEmpty(publisher))
        {
            scriptBuilder.Append(" -Publisher $Publisher");
        }
        if (forceConsent)
        {
            scriptBuilder.Append(" -AutoConsent");
        }
        if (consentToThirdPartySoftwareInstallation)
        {
            scriptBuilder.Append(" -AutoConsentAllPackages");
        }
        var confirmConsentScript = ScriptBlock.Create(scriptBuilder.ToString());
        var result = confirmConsentScript.Invoke(
            applicationName,
            source,
            description ?? "This software is required for certain features in the GenXdev modules.",
            publisher ?? "Third-party vendor",
            forceConsent,
            consentToThirdPartySoftwareInstallation
        );
        if (result?.Count > 0 && result[0]?.BaseObject != null)
        {
            return (bool)result[0].BaseObject;
        }
        return false;
    }

    /// <summary>
    /// Creates a hashtable of default parameter values from the current cmdlet instance.
    /// </summary>
    /// <returns>A hashtable containing default parameter values.</returns>
    protected Hashtable CreateDefaultsHashtable()
    {
        var defaultsHash = new Hashtable();
        var cmdletType = this.GetType();

        try
        {
            // Create a new instance to get default values
            var newInstance = System.Activator.CreateInstance(cmdletType);

            foreach (var property in cmdletType.GetProperties(System.Reflection.BindingFlags.Public |
                System.Reflection.BindingFlags.Instance))
            {
                // Only consider properties that are cmdlet parameters
                if (property.CanRead && property.CanWrite &&
                    System.Attribute.IsDefined(property, typeof(ParameterAttribute)))
                {
                    try
                    {
                        var value = property.GetValue(newInstance);
                        if (value != null)
                        {
                            defaultsHash[property.Name] = value;
                        }
                    }
                    catch
                    {
                        // Skip properties that can't be accessed
                    }
                }
            }
        }
        catch
        {
            // If we can't create instance or access properties, return empty defaults
        }

        return defaultsHash;
    }

    /// <summary>
    /// Converts bound parameters object to a parameter dictionary.
    /// </summary>
    /// <param name="boundParamsObject">The bound parameters object to convert.</param>
    /// <returns>A dictionary containing the parameter names and values.</returns>
    private Dictionary<string, object> ConvertToParameterDictionary(object boundParamsObject)
    {
        var result = new Dictionary<string, object>(StringComparer.OrdinalIgnoreCase);

        if (boundParamsObject is IDictionary dict)
        {
            foreach (DictionaryEntry entry in dict)
            {
                if (entry.Key is string key)
                {
                    result[key] = entry.Value;
                }
            }
        }
        else if (boundParamsObject is PSObject psObj)
        {
            foreach (var property in psObj.Properties)
            {
                result[property.Name] = property.Value;
            }
        }

        return result;
    }

    /// <summary>
    /// Determines if an object represents a true value, including SwitchParameter handling.
    /// </summary>
    /// <param name="value">The value to check.</param>
    /// <returns>True if the value represents true, false otherwise.</returns>
    protected bool IsTrue(object value)
    {
        if (value == null) return false;
        if (value is bool boolValue) return boolValue;
        if (value is SwitchParameter switchParam) return switchParam.ToBool();
        return false;
    }

    /// <summary>
    /// Gets the path to the GenXdev application data directory.
    /// </summary>
    /// <param name="additional">Optional additional path component.</param>
    /// <returns>The full path to the GenXdev app data directory.</returns>
    protected string GetGenXdevAppDataPath(string additional = null)
    {
        if (string.IsNullOrWhiteSpace(additional))
        {
            return ExpandPath(
                Path.Combine(
                    Environment.GetEnvironmentVariable("LOCALAPPDATA"),
                    "GenXdev.PowerShell"
                ) + "\\",
                CreateDirectory: true,
                DeleteExistingFile: true
            );
        }

        return ExpandPath(
            Path.Combine(
                Environment.GetEnvironmentVariable("LOCALAPPDATA"),
                "GenXdev.PowerShell",
                additional
            ) + "\\",
            CreateDirectory: true,
            DeleteExistingFile: true
        );
    }

    /// <summary>
    /// Gets the base path of a GenXdev module.
    /// </summary>
    /// <param name="ModuleName">The name of the module.</param>
    /// <returns>The base path of the module.</returns>
    protected string GetGenXdevModuleBase(string ModuleName)
    {
        return ExpandPath((
            System.IO.Path.GetDirectoryName(
                InvokeScript<string>("(Get-Module '" + ModuleName + "').Path")
            ) + "\\"),
            CreateDirectory: true,
            DeleteExistingFile: true
        );
    }

    /// <summary>
    /// Gets the base path for all GenXdev modules.
    /// </summary>
    /// <returns>The base path for GenXdev modules.</returns>
    protected string GetGenXdevModulesBase()
    {
        return ExpandPath(
            Path.Combine(
                GetGenXdevModuleBase("GenXdev"),
                "..",
                ".."
            ) + "\\",
            CreateDirectory: true,
            DeleteExistingFile: true
        );
    }

    /// <summary>
    /// Gets the path to the PowerShell profile directory.
    /// </summary>
    /// <returns>The path to the PowerShell profile directory.</returns>
    protected string GetPowerShellProfilePath()
    {
        return ExpandPath(
            System.IO.Path.GetDirectoryName(
                InvokeScript<string>("$Profile")

            ) + "\\",
            CreateDirectory: true,
            DeleteExistingFile: true
        );
    }

    /// <summary>
    /// Gets the path to the PowerShell scripts directory.
    /// </summary>
    /// <returns>The path to the PowerShell scripts directory.</returns>
    protected string GetPowerShellScriptsPath()
    {
        return ExpandPath(
            Path.Combine(
                GetPowerShellProfilePath(),
                "Scripts"
            ) + "\\",
            CreateDirectory: true,
            DeleteExistingFile: true
        );
    }

    /// <summary>
    /// Sets a global variable in the PowerShell session
    /// </summary>
    /// <param name="name">Variable name</param>
    /// <param name="value">Variable value</param>
    protected void SetGlobalVariable(string name, object value)
    {

        var setVariableScript = ScriptBlock.Create(
            "param($name, $value) " +
            "Microsoft.PowerShell.Utility\\Set-Variable " +
            "-Scope Global -Name $name -Value $value");

        setVariableScript.Invoke(name, value);
    }

    #endregion
}


