using System.Collections.Concurrent;
using System.Management;
using System.Management.Automation;
using GenXdev.AI.Whisper;

namespace GenXdev.AI
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Converts audio files to text using OpenAI's Whisper speech recognition model.
.DESCRIPTION
Processes audio files and converts speech to text using whisper.cpp, a native implementation of OpenAI's Whisper automatic speech recognition (ASR) system. It supports multiple languages, translation capabilities, and various transcription quality settings. The bundled native libraries are built without AVX so they run on any x64 CPU.

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
Get-SpeechToText -Input ""C:\audio\recording.wav""
```

Transcribes an audio file to text using default settings.
.EXAMPLE
```powershell
Get-ChildItem ""C:\audio\*.wav"" | Get-SpeechToText
```

Transcribes all WAV files in a directory.
.EXAMPLE
```powershell
Get-SpeechToText -Input ""audio.mp3"" -LanguageIn ""es"" -WithTranslate
```

Transcribes Spanish audio and translates it to English.
.EXAMPLE
```powershell
Get-SpeechToText -Input ""recording.wav"" -Passthru -WithTokenTimestamps
```

Returns SegmentData objects with precise timing information.
")]
    [Cmdlet(VerbsCommon.Get, "SpeechToText")]
    [OutputType(typeof(string), typeof(SegmentData))]
    public class GetSpeechToText : PSGenXdevCmdlet
    {

        #region Cmdlet Parameters

        /// <summary>
        /// Directory path where Whisper model files are stored or downloaded
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Path to the model file directory")]
        public string ModelFileDirectoryPath { get; set; }

        /// <summary>
        /// Audio file path, FileInfo object, or any audio format supported by Whisper
        /// </summary>
        [Alias("WaveFile")]
        [Parameter(
            Mandatory = true,
            Position = 0,
            ValueFromPipeline = true,
            HelpMessage = "Audio file path, FileInfo object, or any audio " +
                          "format supported by Whisper.")]
        public object Input { get; set; }

        /// <summary>
        /// Input language code for speech recognition
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Sets the input language to detect, defaults to 'en'")]
        public string LanguageIn { get; set; } = "en";

        /// <summary>
        /// Number of CPU threads to use for processing
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Sets the output language")]
        public int CpuThreads { get; set; } = 0;

        /// <summary>
        /// Temperature for speech detection (0.0-1.0)
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Temperature for speech detection")]
        [ValidateRange(0, 1)]
        public float? Temperature { get; set; } = 0.7f;

        /// <summary>
        /// Temperature increment for fallback attempts
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Temperature increment")]
        [ValidateRange(0, 1)]
        public float? TemperatureInc { get; set; }

        /// <summary>
        /// Threshold for detecting silence vs speech (0.0-1.0)
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "No speech threshold")]
        [ValidateRange(0, 1)]
        public float? NoSpeechThreshold { get; set; } = 0.1f;

        /// <summary>
        /// Optional text prompt to guide the model's transcription style
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Prompt to use for the model")]
        public string Prompt { get; set; }

        /// <summary>
        /// Regular expression pattern to suppress specific tokens from output
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Regex to suppress tokens from the output")]
        public string SuppressRegex { get; set; } = null;

        /// <summary>
        /// Sum threshold for token timestamps when WithTokenTimestamps is enabled
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Sum threshold for token timestamps, defaults to 0.5")]
        public float TokenTimestampsSumThreshold { get; set; } = 0.5f;

        /// <summary>
        /// Maximum number of tokens per transcription segment
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Maximum number of tokens per segment")]
        public int? MaxTokensPerSegment { get; set; }

        /// <summary>
        /// Size of the audio context window for processing
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Size of the audio context")]
        public int? AudioContextSize { get; set; }

        /// <summary>
        /// Maximum duration of audio to process
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Maximum duration of the audio")]
        public TimeSpan? MaxDuration { get; set; }

        /// <summary>
        /// Time offset to start processing audio from
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Offset for the audio")]
        public TimeSpan? Offset { get; set; }

        /// <summary>
        /// Maximum number of last text tokens to consider for context
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Maximum number of last text tokens")]
        public int? MaxLastTextTokens { get; set; }

        /// <summary>
        /// Maximum length of each transcription segment
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Maximum segment length")]
        public int? MaxSegmentLength { get; set; }

        /// <summary>
        /// Start timestamps at this moment in the audio
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Start timestamps at this moment")]
        public TimeSpan? MaxInitialTimestamp { get; set; }

        /// <summary>
        /// Penalty applied to longer segments (0.0-1.0)
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Length penalty")]
        [ValidateRange(0, 1)]
        public float? LengthPenalty { get; set; }

        /// <summary>
        /// Entropy threshold for segment quality assessment (0.0-1.0)
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Entropy threshold")]
        [ValidateRange(0, 1)]
        public float? EntropyThreshold { get; set; }

        /// <summary>
        /// Log probability threshold for filtering low-confidence segments (0.0-1.0)
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Log probability threshold")]
        [ValidateRange(0, 1)]
        public float? LogProbThreshold { get; set; }

        /// <summary>
        /// Whisper model type to use for transcription
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Whisper model type to use, defaults to LargeV3Turbo")]
        public GgmlType ModelType { get; set; } = GgmlType.LargeV3Turbo;

        /// <summary>
        /// Returns SegmentData objects instead of plain text strings
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Returns objects instead of strings")]
        public SwitchParameter Passthru { get; set; }

        /// <summary>
        /// Includes precise timestamps for each token in the output
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Whether to include token timestamps")]
        public SwitchParameter WithTokenTimestamps { get; set; }

        /// <summary>
        /// Splits transcription segments on word boundaries
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Whether to split on word boundaries")]
        public SwitchParameter SplitOnWord { get; set; }

        /// <summary>
        /// Translates non-English audio to English
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Whether to translate the output")]
        public SwitchParameter WithTranslate { get; set; }

        /// <summary>
        /// Shows progress indicator during processing
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Whether to show progress")]
        public SwitchParameter WithProgress { get; set; }

        /// <summary>
        /// Includes blank/silent segments in output
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Whether to NOT suppress blank lines")]
        public SwitchParameter DontSuppressBlank { get; set; }

        /// <summary>
        /// Forces output as a single segment instead of multiple segments
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Whether to use single segment only")]
        public SwitchParameter SingleSegmentOnly { get; set; }

        /// <summary>
        /// Includes special tokens (like timestamps markers) in output
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Whether to print special tokens")]
        public SwitchParameter PrintSpecialTokens { get; set; }

        /// <summary>
        /// Disables context from previous segments
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Don't use context")]
        public SwitchParameter NoContext { get; set; }

        /// <summary>
        /// Uses beam search sampling strategy for improved accuracy
        /// </summary>
        [Parameter(
            Mandatory = false,
            HelpMessage = "Use beam search sampling strategy")]
        public SwitchParameter WithBeamSearchSamplingStrategy { get; set; }

        #endregion

        #region Private Fields

        // Thread-safe queue for storing transcription results
        private readonly ConcurrentQueue<SegmentData> _results = new();

        // Thread-safe queue for storing error records from background processing
        private readonly ConcurrentQueue<ErrorRecord> _errorQueue = new();

        // Thread-safe queue for storing verbose messages from background processing
        private readonly ConcurrentQueue<string> _verboseQueue = new();

        // Thread-safe queue for transcription progress percentages. Whisper raises
        // its progress callback on a native thread, and WriteProgress may only be
        // called on the pipeline thread, so the value is handed over here.
        private readonly ConcurrentQueue<int> _progressQueue = new();

        // Cancellation token source for aborting long-running operations
        private CancellationTokenSource _cts;

        // Whisper processor instance for speech-to-text conversion
        private WhisperProcessor _processor;

        // Whisper factory instance (kept for proper disposal order)
        private WhisperFactory _whisperFactory;

        // Flag to track if resources have been disposed
        private bool _isDisposed = false;

        // Lock object for thread-safe disposal
        private readonly Lock _disposeLock = new();

        #endregion

        #region Lifecycle Methods

        /// <summary>
        /// Begin processing - initializes Whisper model and processor
        /// </summary>
        protected override void BeginProcessing()
        {

            base.BeginProcessing();

             RegisterNativeProbeDirectories();

              if (string.IsNullOrEmpty(ModelFileDirectoryPath) ||
                !Directory.Exists(ModelFileDirectoryPath))
            {

                var localAppData =
                    System.Environment.GetEnvironmentVariable("LOCALAPPDATA");

                if (!string.IsNullOrEmpty(localAppData))
                {

                    ModelFileDirectoryPath =
                        Path.Combine(localAppData, "GenXdev.PowerShell");
                }

                // Create directory if it doesn't exist
                if (!Directory.Exists(ModelFileDirectoryPath))
                {

                    try
                    {

                        Directory.CreateDirectory(ModelFileDirectoryPath);
                    }
                    catch (Exception ex)
                    {

                        ThrowTerminatingError(new ErrorRecord(
                            ex,
                            "ModelPathCreationFailed",
                            ErrorCategory.ResourceUnavailable,
                            ModelFileDirectoryPath));
                    }
                }
            }

            // Set language to auto-detect if not explicitly specified
            if (!MyInvocation.BoundParameters.ContainsKey("LanguageIn"))
            {

                LanguageIn = "auto";
            }

            // Log all user-specified parameters
            WriteVerbose($"ModelFileDirectoryPath: {ModelFileDirectoryPath}");

            if (MyInvocation.BoundParameters.ContainsKey("Input"))
                WriteVerbose($"Input: {Input}");

            if (MyInvocation.BoundParameters.ContainsKey("Passthru"))
                WriteVerbose($"Passthru: {Passthru}");

            if (MyInvocation.BoundParameters.ContainsKey("WithTokenTimestamps"))
                WriteVerbose($"WithTokenTimestamps: {WithTokenTimestamps}");

            if (MyInvocation.BoundParameters.ContainsKey(
                "TokenTimestampsSumThreshold"))
                WriteVerbose(
                    $"TokenTimestampsSumThreshold: {TokenTimestampsSumThreshold}");

            if (MyInvocation.BoundParameters.ContainsKey("SplitOnWord"))
                WriteVerbose($"SplitOnWord: {SplitOnWord}");

            if (MyInvocation.BoundParameters.ContainsKey("MaxTokensPerSegment"))
                WriteVerbose($"MaxTokensPerSegment: {MaxTokensPerSegment}");

            if (MyInvocation.BoundParameters.ContainsKey("LanguageIn"))
                WriteVerbose($"LanguageIn: {LanguageIn}");

            if (MyInvocation.BoundParameters.ContainsKey("CpuThreads"))
                WriteVerbose($"CpuThreads: {CpuThreads}");

            if (MyInvocation.BoundParameters.ContainsKey("Temperature"))
                WriteVerbose($"Temperature: {Temperature}");

            if (MyInvocation.BoundParameters.ContainsKey("TemperatureInc"))
                WriteVerbose($"TemperatureInc: {TemperatureInc}");

            if (MyInvocation.BoundParameters.ContainsKey("WithTranslate"))
                WriteVerbose($"WithTranslate: {WithTranslate}");

            if (MyInvocation.BoundParameters.ContainsKey("Prompt"))
                WriteVerbose($"Prompt: {Prompt}");

            if (MyInvocation.BoundParameters.ContainsKey("SuppressRegex"))
                WriteVerbose($"SuppressRegex: {SuppressRegex}");

            if (MyInvocation.BoundParameters.ContainsKey("WithProgress"))
                WriteVerbose($"WithProgress: {WithProgress}");

            if (MyInvocation.BoundParameters.ContainsKey("AudioContextSize"))
                WriteVerbose($"AudioContextSize: {AudioContextSize}");

            if (MyInvocation.BoundParameters.ContainsKey("DontSuppressBlank"))
                WriteVerbose($"DontSuppressBlank: {DontSuppressBlank}");

            if (MyInvocation.BoundParameters.ContainsKey("MaxDuration"))
                WriteVerbose($"MaxDuration: {MaxDuration}");

            if (MyInvocation.BoundParameters.ContainsKey("Offset"))
                WriteVerbose($"Offset: {Offset}");

            if (MyInvocation.BoundParameters.ContainsKey("MaxLastTextTokens"))
                WriteVerbose($"MaxLastTextTokens: {MaxLastTextTokens}");

            if (MyInvocation.BoundParameters.ContainsKey("SingleSegmentOnly"))
                WriteVerbose($"SingleSegmentOnly: {SingleSegmentOnly}");

            if (MyInvocation.BoundParameters.ContainsKey("PrintSpecialTokens"))
                WriteVerbose($"PrintSpecialTokens: {PrintSpecialTokens}");

            if (MyInvocation.BoundParameters.ContainsKey("MaxSegmentLength"))
                WriteVerbose($"MaxSegmentLength: {MaxSegmentLength}");

            if (MyInvocation.BoundParameters.ContainsKey("MaxInitialTimestamp"))
                WriteVerbose($"MaxInitialTimestamp: {MaxInitialTimestamp}");

            if (MyInvocation.BoundParameters.ContainsKey("LengthPenalty"))
                WriteVerbose($"LengthPenalty: {LengthPenalty}");

            if (MyInvocation.BoundParameters.ContainsKey("EntropyThreshold"))
                WriteVerbose($"EntropyThreshold: {EntropyThreshold}");

            if (MyInvocation.BoundParameters.ContainsKey("LogProbThreshold"))
                WriteVerbose($"LogProbThreshold: {LogProbThreshold}");

            if (MyInvocation.BoundParameters.ContainsKey("NoSpeechThreshold"))
                WriteVerbose($"NoSpeechThreshold: {NoSpeechThreshold}");

            if (MyInvocation.BoundParameters.ContainsKey("NoContext"))
                WriteVerbose($"NoContext: {NoContext}");

            if (MyInvocation.BoundParameters.ContainsKey(
                "WithBeamSearchSamplingStrategy"))
                WriteVerbose(
                    $"WithBeamSearchSamplingStrategy: " +
                    $"{WithBeamSearchSamplingStrategy}");

            if (MyInvocation.BoundParameters.ContainsKey("ModelType"))
                WriteVerbose($"ModelType: {ModelType}");

            // Initialize cancellation token for aborting operations
            _cts = new CancellationTokenSource();

            // Route whisper's native logging into the verbose stream instead of
            // stderr, where it would corrupt the pipeline output
            WhisperInterop.SetLogHandler(message => _verboseQueue.Enqueue(message));

            // Locate the model, downloading it on first use
            var modelFileName = EnsureModelAvailable(ModelType);

            // Initialize Whisper factory and processor
            _whisperFactory = WhisperFactory.FromPath(modelFileName);

            var builder = ConfigureWhisperBuilder(_whisperFactory.CreateBuilder());

            _processor = builder.Build();
        }

        /// <summary>
        /// Process record - transcribes each input audio file
        /// </summary>
        protected override void ProcessRecord()
        {

            base.ProcessRecord();

            // Extract file path from various input types
            string filePath = GetFilePathFromInput(Input);

            if (string.IsNullOrEmpty(filePath))
            {

                WriteError(new ErrorRecord(
                    new ArgumentException(
                        "Input parameter is required and must be a valid " +
                        "file path or FileInfo object."),
                    "MissingInput",
                    ErrorCategory.InvalidArgument,
                    Input));

                return;
            }

            // Validate that the audio file exists
            if (!File.Exists(filePath))
            {

                WriteError(new ErrorRecord(
                    new FileNotFoundException(
                        $"Audio file not found: {filePath}"),
                    "FileNotFound",
                    ErrorCategory.ObjectNotFound,
                    filePath));

                return;
            }

            WriteVerbose($"Processing audio file: {filePath}");

            // Process the audio file using the initialized processor
            ProcessAudioFile(filePath);
        }

        /// <summary>
        /// End processing - cleanup and dispose resources
        /// </summary>
        protected override void EndProcessing()
        {

            lock (_disposeLock)
            {

                if (_isDisposed) return;

                _isDisposed = true;
            }

            try
            {

                // Cancel any ongoing operations
                if (_cts != null && !_cts.IsCancellationRequested)
                {

                    _cts.Cancel();
                }

                // Dispose Whisper processor (must be disposed before factory)
                if (_processor != null)
                {

                    try
                    {

                        // Handle async disposable resources
                        if (_processor is IAsyncDisposable asyncDisposable)
                        {

                            asyncDisposable.DisposeAsync()
                                .AsTask()
                                .Wait(TimeSpan.FromSeconds(50));
                        }
                        else if (_processor is IDisposable disposable)
                        {

                            disposable.Dispose();
                        }
                    }
                    catch (Exception ex)
                    {

                        WriteVerbose(
                            $"Error disposing Whisper processor: {ex.Message}");
                    }
                    finally
                    {

                        _processor = null;
                    }
                }

                // Dispose Whisper factory
                if (_whisperFactory != null)
                {

                    try
                    {

                        _whisperFactory.Dispose();
                    }
                    catch (Exception ex)
                    {

                        WriteVerbose(
                            $"Error disposing Whisper factory: {ex.Message}");
                    }
                    finally
                    {

                        _whisperFactory = null;
                    }
                }

                // Dispose cancellation token source
                if (_cts != null)
                {

                    try
                    {

                        _cts.Dispose();
                    }
                    catch (Exception ex)
                    {

                        WriteVerbose(
                            $"Error disposing cancellation token source: " +
                            $"{ex.Message}");
                    }
                    finally
                    {

                        _cts = null;
                    }
                }
            }
            catch (Exception ex)
            {

                WriteVerbose($"Error in EndProcessing: {ex.Message}");
            }

            base.EndProcessing();
        }

        #endregion

        #region Private Helper Methods

        /// <summary>
        /// Extracts file path from various input object types
        /// </summary>
        /// <param name="input">Input object (string, FileInfo, or PSObject)</param>
        /// <returns>File path string or null if extraction fails</returns>
        private static string GetFilePathFromInput(object input)
        {

            if (input == null) return null;

            // Handle FileInfo objects directly
            if (input is FileInfo fileInfo)
            {

                return fileInfo.FullName;
            }

            // Handle string paths
            if (input is string stringPath)
            {

                return stringPath;
            }

            // Handle PSObject wrappers around FileInfo or strings
            if (input is PSObject psObject)
            {

                var baseObject = psObject.BaseObject;

                if (baseObject is FileInfo fi)
                {

                    return fi.FullName;
                }

                if (baseObject is string str)
                {

                    return str;
                }
            }

            // Fallback: attempt to convert to string
            try
            {

                return input.ToString();
            }
            catch
            {

                return null;
            }
        }

        /// <summary>
        /// Decides how many threads to hand to whisper.
        ///
        /// ggml parallelises with OpenMP, so asking for more threads than the
        /// machine has logical processors does not go faster - the workers contend
        /// for the same cores and the extra scheduling makes it slower.
        /// </summary>
        /// <param name="physicalCoreCount">Physical cores detected via WMI</param>
        /// <returns>Thread count to use</returns>
        private int ResolveThreadCount(int physicalCoreCount)
        {

            var logical = Environment.ProcessorCount;

            // WMI can come back empty on some systems
            if (physicalCoreCount <= 0)
            {

                physicalCoreCount = Math.Max(1, logical / 2);
            }

            if (CpuThreads <= 0)
            {

                return Math.Max(1, Math.Min(physicalCoreCount, logical));
            }

            if (CpuThreads > logical)
            {

                WriteWarning(
                    $"-CpuThreads {CpuThreads} exceeds the {logical} logical " +
                    $"processors on this machine; using {logical}. " +
                    $"Oversubscribing ggml's OpenMP pool slows transcription down.");

                return logical;
            }

            return CpuThreads;
        }

        /// <summary>
        /// Writes any queued transcription progress and native log lines.
        ///
        /// MUST only be called from the pipeline thread - WriteProgress and
        /// WriteVerbose are thread-affine, which is exactly why the producers
        /// (whisper's native progress callback and its log callback) enqueue
        /// instead of writing.
        /// </summary>
        private void DrainProgressAndVerbose()
        {

            // Coalesce progress to the newest value rather than replaying every
            // percentage point that arrived since the last drain
            var latest = -1;

            while (_progressQueue.TryDequeue(out var percent))
            {
                latest = percent;
            }

            if (latest >= 0)
            {

                WriteProgress(new ProgressRecord(
                    1, "Transcribing", $"Progress: {latest}%")
                {
                    PercentComplete = Math.Min(100, Math.Max(0, latest))
                });
            }

            while (_verboseQueue.TryDequeue(out var message))
            {
                WriteVerbose(message);
            }
        }

        /// <summary>
        /// Processes an audio file and transcribes it to text segments
        /// </summary>
        /// <param name="filePath">Path to the audio file</param>
        private void ProcessAudioFile(string filePath)
        {

            using var audioStream = File.OpenRead(filePath);

            // Start async processing task in background
            var processingTask = Task.Run(async () =>
            {

                try
                {

                    // Process audio stream and collect segments
                    await foreach (var segment in
                        _processor.ProcessAsync(audioStream, _cts.Token))
                    {

                        // Check for cancellation or disposal
                        if (_cts.IsCancellationRequested || _isDisposed)
                            break;

                        // Filter out empty or blank audio segments
                        if (!string.IsNullOrWhiteSpace(segment.Text))
                        {

                            if (!(segment.Text.Trim(
                                "\r\n\t ".ToCharArray()) == "[BLANK_AUDIO]"))
                            {

                                _results.Enqueue(segment);
                            }
                        }
                    }
                }
                catch (OperationCanceledException)
                {
                }
                catch (Exception ex)
                {

                    _errorQueue.Enqueue(new ErrorRecord(
                        ex,
                        "ProcessingError",
                        ErrorCategory.OperationStopped,
                        null));
                }
            });

            // Only offer the keyboard abort when there is a real console to read
            // from. Under a redirected stdin - a piped or scripted invocation -
            // Console.KeyAvailable throws, which would otherwise break out of the
            // loop and cancel a still-running transcription.
            var canReadKeys = !System.Console.IsInputRedirected;

            if (canReadKeys)
            {

                System.Console.WriteLine(
                    "Processing audio file. Press Q to abort...");
            }

            // Main processing loop with keyboard interrupt support
            while (!processingTask.IsCompleted)
            {

                try
                {

                    // Check for Q key to abort processing
                    if (canReadKeys &&
                        System.Console.KeyAvailable &&
                        System.Console.ReadKey(true).Key == ConsoleKey.Q)
                    {

                        _cts.Cancel();

                        _errorQueue.Enqueue(new ErrorRecord(
                            new Exception("Processing aborted"),
                            "ProcessingAborted",
                            ErrorCategory.OperationStopped,
                            null));

                        break;
                    }

                    // This is the pipeline thread, so it is the only place the
                    // queued progress and log lines may legally be written
                    DrainProgressAndVerbose();

                    Thread.Sleep(100);
                }
                catch (Exception)
                {

                    // The console became unavailable mid-run; keep transcribing
                    // without the abort key rather than dropping the results.
                    canReadKeys = false;

                    Thread.Sleep(100);
                }
            }

            DrainProgressAndVerbose();

            // Wait for processing task to complete with timeout
            bool taskCompleted = false;

            try
            {

                // First attempt: graceful wait
                taskCompleted = processingTask.Wait(TimeSpan.FromSeconds(10));

                if (!taskCompleted)
                {

                    // Second attempt: cancel and wait again
                    _cts.Cancel();

                    taskCompleted = processingTask.Wait(TimeSpan.FromSeconds(5));
                }
            }
            catch (AggregateException ex)
            {

                // Handle task exceptions
                foreach (var innerEx in ex.InnerExceptions)
                {

                    if (innerEx is not OperationCanceledException)
                    {

                        WriteVerbose(
                            $"Processing task error: {innerEx.Message}");
                    }
                }
            }
            catch (Exception ex)
            {

                WriteVerbose(
                    $"Error waiting for processing task: {ex.Message}");
            }

            // Collect all queued results
            int timeout = 0;

            List<SegmentData> allSegments = [];

            while (timeout < 50)
            {

                bool hasResults = false;

                // Process all queued error records
                while (_errorQueue.TryDequeue(out var errorRecord))
                {

                    WriteError(errorRecord);

                    hasResults = true;
                }

                // Process all queued verbose messages
                while (_verboseQueue.TryDequeue(out var verboseMessage))
                {

                    WriteVerbose(verboseMessage);

                    hasResults = true;
                }

                // Collect all transcription segments
                while (_results.TryDequeue(out var segment))
                {

                    allSegments.Add(segment);

                    hasResults = true;
                }

                // Exit if no more results and task completed
                if (!hasResults && taskCompleted)
                {

                    break;
                }

                Thread.Sleep(100);

                timeout++;
            }

            // Output all collected segments
            foreach (var segment in allSegments)
            {

                WriteObject(Passthru ? segment : segment.Text.Trim());
            }
        }

        /// <summary>
        /// Configures the Whisper processor builder with all specified parameters
        /// </summary>
        /// <param name="builder">Whisper processor builder instance</param>
        /// <returns>Configured builder instance</returns>
        private WhisperProcessorBuilder ConfigureWhisperBuilder(
            WhisperProcessorBuilder builder)
        {

            // Detect physical CPU core count for optimal threading
            int physicalCoreCount = 0;

            var searcher = new ManagementObjectSearcher(
                "select NumberOfCores from Win32_Processor");

            foreach (var item in searcher.Get())
            {

                physicalCoreCount += Convert.ToInt32(item["NumberOfCores"]);
            }

            // Set language and thread count
            builder.WithLanguage(LanguageIn)
                   .WithThreads(ResolveThreadCount(physicalCoreCount));

            // Translation is driven solely by -WithTranslate below; specifying an
            // input language used to silently force translation to English

            // Configure temperature for speech detection consistency
            if (Temperature.HasValue)
            {

                builder.WithTemperature(Temperature.Value);
            }
            else
            {

                builder.WithTemperature(0.0f);
            }

            if (TemperatureInc.HasValue)
                builder.WithTemperatureInc(TemperatureInc.Value);

            if (WithTokenTimestamps.IsPresent)
                builder.WithTokenTimestamps()
                    .WithTokenTimestampsSumThreshold(TokenTimestampsSumThreshold);

            if (WithTranslate.IsPresent)
                builder.WithTranslate();

            if (!string.IsNullOrWhiteSpace(Prompt))
                builder.WithPrompt(Prompt);

            if (!string.IsNullOrWhiteSpace(SuppressRegex))
                builder.WithSuppressRegex(SuppressRegex);

            if (WithProgress.IsPresent)
            {

                // Whisper invokes this from a native thread inside whisper_full,
                // so it may only enqueue - the main loop does the WriteProgress
                builder.WithProgressHandler(
                    progress => _progressQueue.Enqueue(progress));
            }

            if (SplitOnWord.IsPresent)
                builder.SplitOnWord();

            if (MaxTokensPerSegment.HasValue)
                builder.WithMaxTokensPerSegment(MaxTokensPerSegment.Value);

            // Configure silence detection threshold
            if (NoSpeechThreshold.HasValue)
            {

                builder.WithNoSpeechThreshold(NoSpeechThreshold.Value);
            }
            else
            {

                builder.WithNoSpeechThreshold(0.6f);
            }

            if (AudioContextSize.HasValue)
                builder.WithAudioContextSize(AudioContextSize.Value);

            if (DontSuppressBlank.IsPresent)
                builder.WithoutSuppressBlank();

            if (MaxDuration.HasValue)
                builder.WithDuration(MaxDuration.Value);

            if (Offset.HasValue)
                builder.WithOffset(Offset.Value);

            if (MaxLastTextTokens.HasValue)
                builder.WithMaxLastTextTokens(MaxLastTextTokens.Value);

            if (SingleSegmentOnly.IsPresent)
                builder.WithSingleSegment();

            if (PrintSpecialTokens.IsPresent)
                builder.WithPrintSpecialTokens();

            if (MaxSegmentLength.HasValue)
                builder.WithMaxSegmentLength(MaxSegmentLength.Value);

            if (MaxInitialTimestamp.HasValue)
                builder.WithMaxInitialTs(
                    (int)MaxInitialTimestamp.Value.TotalSeconds);

            if (LengthPenalty.HasValue)
                builder.WithLengthPenalty(LengthPenalty.Value);

            if (EntropyThreshold.HasValue)
                builder.WithEntropyThreshold(EntropyThreshold.Value);

            if (LogProbThreshold.HasValue)
                builder.WithLogProbThreshold(LogProbThreshold.Value);

            if (NoContext.IsPresent)
                builder.WithNoContext();

            if (WithBeamSearchSamplingStrategy.IsPresent)
                builder.WithBeamSearchSamplingStrategy();

            return builder;
        }

        /// <summary>
        /// Tells the native loader where this module keeps whisper.dll and the
        /// ggml libraries.
        /// </summary>
        private void RegisterNativeProbeDirectories()
        {

            try
            {

                var moduleBase = MyInvocation?.MyCommand?.Module?.ModuleBase;

                if (string.IsNullOrWhiteSpace(moduleBase))
                {

                    moduleBase = SessionState?.Module?.ModuleBase;
                }

                if (!string.IsNullOrWhiteSpace(moduleBase))
                {

                    WhisperInterop.AddProbeDirectory(moduleBase);

                    WhisperInterop.AddProbeDirectory(
                        Path.Combine(moduleBase, "lib"));
                }
            }
            catch (Exception ex)
            {

                // Not fatal - the resolver still probes the directory holding
                // the assembly itself, which covers the normal layouts
                WriteVerbose($"Could not resolve the module base: {ex.Message}");
            }
        }

        /// <summary>
        /// Resolves the model file for a model type, downloading it on first use
        /// </summary>
        /// <param name="modelType">Whisper model type</param>
        /// <returns>Full path to the model file</returns>
        private string EnsureModelAvailable(GgmlType modelType)
        {

            // Accept a model that is already on disk under either the canonical
            // whisper.cpp name or the older name this cmdlet used to write
            foreach (var candidate in modelType.GetModelFileNameCandidates())
            {

                var existing = Path.GetFullPath(
                    Path.Combine(ModelFileDirectoryPath, candidate));

                if (File.Exists(existing))
                {

                    WriteVerbose($"Using Whisper model: {existing}");

                    return existing;
                }
            }

            var modelFileName = Path.GetFullPath(Path.Combine(
                ModelFileDirectoryPath, modelType.ToModelFileName()));

            WriteVerbose($"Downloading Whisper model {modelType} to {modelFileName}");

            System.Console.WriteLine(
                $"Downloading Whisper model '{modelType.ToCanonicalName()}'...");

            var activity =
                $"Downloading Whisper model '{modelType.ToCanonicalName()}'";

            // WriteProgress is thread-affine - it may only be called on the
            // pipeline thread. So the download runs on a worker, its callback only
            // enqueues, and this thread does the writing while it waits.
            var progressQueue = new ConcurrentQueue<int>();

            var downloadTask = Task.Run(() =>
                WhisperGgmlDownloader.DownloadModelAsync(
                    modelType,
                    modelFileName,
                    percent => progressQueue.Enqueue(percent),
                    _cts.Token));

            var lastReported = -1;

            while (!downloadTask.Wait(200))
            {

                // Coalesce to the newest value - the downloader reports every
                // percent and replaying the backlog would just stutter the bar
                var latest = -1;

                while (progressQueue.TryDequeue(out var percent))
                {
                    latest = percent;
                }

                if (latest >= 0 && latest != lastReported)
                {

                    lastReported = latest;

                    WriteProgress(new ProgressRecord(
                        2, activity, $"{latest}% complete")
                    {
                        PercentComplete = latest
                    });
                }
            }

            // Surface any download failure now that the wait has finished
            downloadTask.GetAwaiter().GetResult();

            WriteProgress(new ProgressRecord(2, activity, "Completed")
            {
                RecordType = ProgressRecordType.Completed
            });

            return modelFileName;
        }

        #endregion
    }
}
