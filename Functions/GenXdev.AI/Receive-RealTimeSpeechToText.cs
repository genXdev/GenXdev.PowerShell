using NAudio.Wave;
using System.Collections.Concurrent;
using System.Management;
using System.Management.Automation;
using GenXdev.AI.Whisper;

namespace GenXdev.AI
{

    [System.ComponentModel.Description(@"
.SYNOPSIS
Converts real-time audio input to text using Whisper AI model.
.DESCRIPTION
This cmdlet captures audio from microphone or desktop and transcribes it to text in real-time using the Whisper AI model. It supports various audio sources, silence detection, and multiple configuration options for speech recognition.

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
Receive-RealTimeSpeechToText
```

Basic usage with microphone.

.EXAMPLE
```powershell
Receive-RealTimeSpeechToText -UseDesktopAudioCapture
```

Using desktop audio capture.

.EXAMPLE
```powershell
Receive-RealTimeSpeechToText -AudioDevice ""Microphone*""
```

Using specific audio device.

.EXAMPLE
```powershell
Receive-RealTimeSpeechToText -MaxDurationOfSilence ""00:00:05""
```

With silence detection.
")]
    [Cmdlet(VerbsCommunications.Receive, "RealTimeSpeechToText")]
    public class ReceiveRealTimeSpeechToText : PSGenXdevCmdlet
    {
        #region Cmdlet Parameters
        /// <summary>
        /// Specifies the path to the directory containing Whisper model files.
        /// If not specified, defaults to the GenXdev app data directory.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Path to the model file")]
        public string ModelFileDirectoryPath { get; set; }
        /// <summary>
        /// Indicates whether to use desktop audio capture instead of microphone.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to use desktop audio capture instead of microphone")]
        public SwitchParameter UseDesktopAudioCapture { get; set; }
        /// <summary>
        /// Indicates whether to use both desktop audio capture and recording device simultaneously.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to use both desktop audio capture and recording device simultaneously")]
        public SwitchParameter UseDesktopAndRecordingDevice { get; set; }
        /// <summary>
        /// Specifies the audio device to use by name or GUID (supports wildcards).
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Use both desktop and recording device")]
        public string AudioDevice { get; set; }
        /// <summary>
        /// Indicates whether to return objects instead of strings.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Returns objects instead of strings")]
        public SwitchParameter Passthru { get; set; }
        /// <summary>
        /// Indicates whether to include token timestamps.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to include token timestamps")]
        public SwitchParameter WithTokenTimestamps { get; set; }
        /// <summary>
        /// Specifies the sum threshold for token timestamps, defaults to 0.5.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Sum threshold for token timestamps, defaults to 0.5")]
        public float TokenTimestampsSumThreshold { get; set; } = 0.5f;
        /// <summary>
        /// Indicates whether to split on word boundaries.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to split on word boundaries")]
        public SwitchParameter SplitOnWord { get; set; }
        /// <summary>
        /// Specifies the maximum number of tokens per segment.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Maximum number of tokens per segment")]
        public int? MaxTokensPerSegment { get; set; }
        /// <summary>
        /// Indicates whether to ignore silence (will mess up timestamps).
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to ignore silence (will mess up timestamps)")]
        public SwitchParameter IgnoreSilence { get; set; }
        /// <summary>
        /// Specifies the maximum duration of silence before automatically stopping recording.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Maximum duration of silence before automatically stopping recording")]
        public TimeSpan? MaxDurationOfSilence { get; set; }
        /// <summary>
        /// Specifies the silence detect threshold (0..32767 defaults to 30).
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Silence detect threshold (0..32767 defaults to 30)")]
        [ValidateRange(0, 32767)]
        public int? SilenceThreshold { get; set; }
        /// <summary>
        /// Sets the input language to detect, defaults to 'en'.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Sets the input language to detect, defaults to 'en'")]
        public string LanguageIn { get; set; } = "en";
        /// <summary>
        /// Specifies the number of CPU threads to use for processing.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Sets the output language")]
        public int CpuThreads { get; set; } = 0;
        /// <summary>
        /// Specifies the temperature for speech detection (0-1).
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Temperature for speech detection")]
        [ValidateRange(0, 1)]
        public float? Temperature { get; set; }
        /// <summary>
        /// Specifies the temperature increment (0-1).
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Temperature increment")]
        [ValidateRange(0, 1)]
        public float? TemperatureInc { get; set; }
        /// <summary>
        /// Indicates whether to translate the output.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to translate the output")]
        public SwitchParameter WithTranslate { get; set; }
        /// <summary>
        /// Specifies the prompt to use for the model.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Prompt to use for the model")]
        public string Prompt { get; set; }
        /// <summary>
        /// Specifies the regex to suppress tokens from the output.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Regex to suppress tokens from the output")]
        public string SuppressRegex { get; set; } = null;
        /// <summary>
        /// Indicates whether to show progress.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to show progress")]
        public SwitchParameter WithProgress { get; set; }
        /// <summary>
        /// Specifies the size of the audio context.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Size of the audio context")]
        public int? AudioContextSize { get; set; }
        /// <summary>
        /// Indicates whether to NOT suppress blank lines.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to NOT suppress blank lines")]
        public SwitchParameter DontSuppressBlank { get; set; }
        /// <summary>
        /// Specifies the maximum duration of the audio.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Maximum duration of the audio")]
        public TimeSpan? MaxDuration { get; set; }
        /// <summary>
        /// Specifies the offset for the audio.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Offset for the audio")]
        public TimeSpan? Offset { get; set; }
        /// <summary>
        /// Specifies the maximum number of last text tokens.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Maximum number of last text tokens")]
        public int? MaxLastTextTokens { get; set; }
        /// <summary>
        /// Indicates whether to use single segment only.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to use single segment only")]
        public SwitchParameter SingleSegmentOnly { get; set; }
        /// <summary>
        /// Indicates whether to print special tokens.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whether to print special tokens")]
        public SwitchParameter PrintSpecialTokens { get; set; }
        /// <summary>
        /// Specifies the maximum segment length.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Maximum segment length")]
        public int? MaxSegmentLength { get; set; }
        /// <summary>
        /// Specifies the moment to start timestamps at.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Start timestamps at this moment")]
        public TimeSpan? MaxInitialTimestamp { get; set; }
        /// <summary>
        /// Specifies the length penalty (0-1).
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Length penalty")]
        [ValidateRange(0, 1)]
        public float? LengthPenalty { get; set; }
        /// <summary>
        /// Specifies the entropy threshold (0-1).
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Entropy threshold")]
        [ValidateRange(0, 1)]
        public float? EntropyThreshold { get; set; }
        /// <summary>
        /// Specifies the log probability threshold (0-1).
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Log probability threshold")]
        [ValidateRange(0, 1)]
        public float? LogProbThreshold { get; set; }
        /// <summary>
        /// Specifies the no speech threshold (0-1).
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "No speech threshold")]
        [ValidateRange(0, 1)]
        public float? NoSpeechThreshold { get; set; }
        /// <summary>
        /// Indicates not to use context.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Don't use context")]
        public SwitchParameter NoContext { get; set; }
        /// <summary>
        /// Indicates to use beam search sampling strategy.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Use beam search sampling strategy")]
        public SwitchParameter WithBeamSearchSamplingStrategy { get; set; }
        /// <summary>
        /// Specifies the Whisper model type to use, defaults to Small.
        /// </summary>
        [Parameter(Mandatory = false, HelpMessage = "Whisper model type to use, defaults to Small")]
        public GgmlType ModelType { get; set; } = GgmlType.Small;
        #endregion
        private readonly ConcurrentQueue<SegmentData> _results = new();
        private readonly ConcurrentQueue<byte[]> _bufferQueue = new();
        private readonly ConcurrentQueue<ErrorRecord> _errorQueue = new();
        private readonly ConcurrentQueue<string> _verboseQueue = new();

        // Transcription progress percentages. Whisper raises its progress callback
        // on a native thread and WriteProgress may only be called on the pipeline
        // thread, so the value is handed over here and written by the main loop.
        private readonly ConcurrentQueue<int> _progressQueue = new();
        private CancellationTokenSource _cts;
        private WhisperProcessor _processor;
        private WhisperFactory _whisperFactory; // Keep reference for proper disposal
        private bool _isRecordingStarted = true;
        private bool _isDisposed = false;
        private readonly Lock _disposeLock = new();
        private Task _processingTask;
        // Fields for dual audio stream support
        private IWaveIn _primaryWaveIn;
        private WaveIn _secondaryWaveIn;
        private readonly ConcurrentQueue<byte[]> _primaryQueue = new();
        private readonly ConcurrentQueue<byte[]> _secondaryQueue = new();
        private Task _mixingTask;
        private readonly Lock _audioMixingLock = new();
        private int _audioCallbackCount = 0;
        private int _bufferQueueCount = 0;

        // The format the capture device actually settled on. Not necessarily what
        // was requested: WasapiLoopbackCapture dictates its own, and some mics
        // reject 16kHz mono. The buffered bytes are converted from this.
        private NAudio.Wave.WaveFormat _captureFormat;
        private bool hadAudio;
        private bool everHadAudio;
        private double totalSilenceSeconds;
        private double seconds;
        private double sumSq;
        private long count;
        private int threshold;
        private MemoryStream wavBufferStream;
        private bool _isFallback = false;
        /// <summary>
        /// Initializes cmdlet parameters and sets up audio processing environment.
        /// </summary>
        protected override void BeginProcessing()
        {
            
            // Expand ModelFileDirectoryPath if provided
            if (!string.IsNullOrEmpty(ModelFileDirectoryPath))
            {
                ModelFileDirectoryPath = ExpandPath(ModelFileDirectoryPath);
            }
            if (string.IsNullOrEmpty(ModelFileDirectoryPath) || !Directory.Exists(ModelFileDirectoryPath))
            {
                 var localAppData = System.Environment.GetEnvironmentVariable("LOCALAPPDATA");
                ModelFileDirectoryPath = Path.Combine(localAppData, "GenXdev.PowerShell");
                if (!Directory.Exists(ModelFileDirectoryPath))
                {
                    Directory.CreateDirectory(ModelFileDirectoryPath);
                }
            }
            if (!MyInvocation.BoundParameters.ContainsKey("LanguageIn"))
            {
                LanguageIn = "auto";
            }
            // Only log parameters that were actually set by the user
            WriteVerbose($"ModelFileDirectoryPath: {ModelFileDirectoryPath}");
            if (MyInvocation.BoundParameters.ContainsKey("UseDesktopAudioCapture"))
                WriteVerbose($"UseDesktopAudioCapture: {UseDesktopAudioCapture}");
            if (MyInvocation.BoundParameters.ContainsKey("UseDesktopAndRecordingDevice"))
                WriteVerbose($"UseDesktopAndRecordingDevice: {UseDesktopAndRecordingDevice}");
            if (MyInvocation.BoundParameters.ContainsKey("AudioDevice"))
                WriteVerbose($"AudioDevice: {AudioDevice}");
            if (MyInvocation.BoundParameters.ContainsKey("Passthru"))
                WriteVerbose($"Passthru: {Passthru}");
            if (MyInvocation.BoundParameters.ContainsKey("WithTokenTimestamps"))
                WriteVerbose($"WithTokenTimestamps: {WithTokenTimestamps}");
            if (MyInvocation.BoundParameters.ContainsKey("TokenTimestampsSumThreshold"))
                WriteVerbose($"TokenTimestampsSumThreshold: {TokenTimestampsSumThreshold}");
            if (MyInvocation.BoundParameters.ContainsKey("SplitOnWord"))
                WriteVerbose($"SplitOnWord: {SplitOnWord}");
            if (MyInvocation.BoundParameters.ContainsKey("MaxTokensPerSegment"))
                WriteVerbose($"MaxTokensPerSegment: {MaxTokensPerSegment}");
            if (MyInvocation.BoundParameters.ContainsKey("IgnoreSilence"))
                WriteVerbose($"IgnoreSilence: {IgnoreSilence}");
            if (MyInvocation.BoundParameters.ContainsKey("MaxDurationOfSilence"))
                WriteVerbose($"MaxDurationOfSilence: {MaxDurationOfSilence}");
            if (MyInvocation.BoundParameters.ContainsKey("SilenceThreshold"))
                WriteVerbose($"SilenceThreshold: {SilenceThreshold}");
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
            if (MyInvocation.BoundParameters.ContainsKey("WithBeamSearchSamplingStrategy"))
                WriteVerbose($"WithBeamSearchSamplingStrategy: {WithBeamSearchSamplingStrategy}");
            if (MyInvocation.BoundParameters.ContainsKey("ModelType"))
                WriteVerbose($"ModelType: {ModelType}");
            _cts = new CancellationTokenSource();
        }
        /// <summary>
        /// Processes the audio input and performs real-time speech-to-text conversion.
        /// </summary>
        protected override void ProcessRecord()
        {
            base.ProcessRecord();
            // Point the native loader at the module's own folders before any
            // whisper call, so whisper.dll and the ggml libraries resolve no
            // matter where the module was imported from
            RegisterNativeProbeDirectories();

            // Route whisper's native logging into the verbose stream instead of
            // stderr, where it would corrupt the pipeline output
            WhisperInterop.SetLogHandler(message => _verboseQueue.Enqueue(message));

            // Locate the model, downloading it on first use
            var modelFileName = EnsureModelAvailable(ModelType);

            _whisperFactory = WhisperFactory.FromPath(modelFileName);
            var builder = ConfigureWhisperBuilder(_whisperFactory.CreateBuilder());
            _processor = builder.Build();


            // Create audio input(s) based on parameters
            if (UseDesktopAndRecordingDevice.ToBool())
            {
                CreateDualAudioInputs();
            }
            else
            {
                _primaryWaveIn = CreateAudioInput();
            }
            // Handle single or dual audio inputs
            if (_secondaryWaveIn != null)
            {
                ProcessDualAudioInputs();
            }
            else
            {
                ProcessSingleAudioInput(_primaryWaveIn);
            }
        }

        /// <summary>
        /// Sets up dual audio inputs combining desktop audio capture and microphone recording.
        /// </summary>
        private void CreateDualAudioInputs()
        {
            WriteVerbose("Setting up dual audio inputs: desktop audio capture and recording device");
            try
            {
                // Create desktop audio capture
                _primaryWaveIn = new WasapiLoopbackCapture();
                WriteVerbose("Desktop audio capture initialized");
                // Create recording device input
                _secondaryWaveIn = CreateRecordingDeviceInput();
                WriteVerbose("Recording device input initialized");
            }
            catch (Exception ex)
            {
                WriteError(new ErrorRecord(ex, "DualAudioSetupError", ErrorCategory.DeviceError, null));
                // Fallback to single input
                _primaryWaveIn?.Dispose();
                _secondaryWaveIn?.Dispose();
                _primaryWaveIn = CreateAudioInput();
                _secondaryWaveIn = null;
            }
        }
        private WaveIn CreateRecordingDeviceInput()
        {
            if (!string.IsNullOrWhiteSpace(AudioDevice))
            {
                // Find microphone device by name/GUID with wildcard support
                WriteVerbose($"Looking for microphone device matching: {AudioDevice}");
                for (int i = 0; i < WaveIn.DeviceCount; i++)
                {
                    try
                    {
                        var deviceInfo = WaveIn.GetCapabilities(i);
                        if (IsDeviceMatch(deviceInfo.ProductName, AudioDevice) ||
                            IsDeviceMatch(deviceInfo.ProductGuid.ToString(), AudioDevice))
                        {
                            WriteVerbose($"Selected microphone device: {deviceInfo.ProductName}");
                            var waveIn = new WaveIn { DeviceNumber = i };
                            return waveIn;
                        }
                    }
                    catch (Exception ex)
                    {
                        WriteVerbose($"Could not check device {i}: {ex.Message}");
                    }
                }
                WriteWarning($"Microphone device '{AudioDevice}' not found, using default");
            }
            return new WaveIn();
        }
        /// <summary>
        /// Configures and starts recording from dual audio inputs (primary and secondary), sets up event handlers for audio data,
        /// initializes silence detection variables, and begins the main processing loop for mixed audio streams.
        /// </summary>
        private void ProcessDualAudioInputs()
        {
            _primaryWaveIn.WaveFormat = new WaveFormat(16000, 1);
            _secondaryWaveIn.WaveFormat = new WaveFormat(16000, 1);

            // The mixer emits in the primary's format, so that is what the
            // buffered bytes must be interpreted as
            _captureFormat = _primaryWaveIn.WaveFormat;

            _verboseQueue.Enqueue(
                $"Capture (dual): {_captureFormat.SampleRate} Hz, " +
                $"{_captureFormat.Channels} ch, {_captureFormat.BitsPerSample} bit, " +
                $"{_captureFormat.Encoding}");

            var processingTask = Task.Run(() => ProcessAudioBuffer());
            _processingTask = processingTask;
            _mixingTask = Task.Run(() => MixAudioBuffers());
            // Variables for silence detection
            hadAudio = false;
            everHadAudio = false;
            totalSilenceSeconds = 0;
            seconds = 0;
            sumSq = 0;
            count = 0;
            threshold = SilenceThreshold ?? 30;
            wavBufferStream = new MemoryStream();
            // Set up event handlers for both audio inputs
            _primaryWaveIn.DataAvailable += (sender, args) =>
            {
                if (!_isRecordingStarted || _isDisposed) return;
                lock (_audioMixingLock)
                {
                    if (args.BytesRecorded > 0)
                    {
                        var buffer = new byte[args.BytesRecorded];
                        Array.Copy(args.Buffer, buffer, args.BytesRecorded);
                        _primaryQueue.Enqueue(buffer);
                        _audioCallbackCount++;
                    }
                }
            };
            _secondaryWaveIn.DataAvailable += (sender, args) =>
            {
                if (!_isRecordingStarted || _isDisposed) return;
                lock (_audioMixingLock)
                {
                    if (args.BytesRecorded > 0)
                    {
                        var buffer = new byte[args.BytesRecorded];
                        Array.Copy(args.Buffer, buffer, args.BytesRecorded);
                        _secondaryQueue.Enqueue(buffer);
                        _audioCallbackCount++;
                    }
                }
            };
            try
            {
                _primaryWaveIn.StartRecording();
                _secondaryWaveIn.StartRecording();
                ProcessMainLoop();
            }
            finally
            {
                try
                {
                    _primaryWaveIn?.StopRecording();
                    _secondaryWaveIn?.StopRecording();
                }
                catch (Exception ex)
                {
                    WriteVerbose($"Error stopping dual audio inputs: {ex.Message}");
                }
                WaitForProcessingCompletion();
            }
        }
        /// <summary>
        /// Continuously mixes audio buffers from primary and secondary queues, applies silence detection if enabled,
        /// and enqueues mixed audio data for speech processing. Handles buffer synchronization and volume normalization.
        /// </summary>
        private async Task MixAudioBuffers()
        {
            while (!_cts.IsCancellationRequested && !_isDisposed)
            {
                byte[] primaryBuffer = null;
                byte[] secondaryBuffer = null;
                // Try to dequeue from both, with timeout
                var dequeueTasks = new[]
                {
                    Task.Run(() => _primaryQueue.TryDequeue(out primaryBuffer)),
                    Task.Run(() => _secondaryQueue.TryDequeue(out secondaryBuffer))
                };
                await Task.WhenAny(Task.WhenAll(dequeueTasks), Task.Delay(100, _cts.Token));
                if (primaryBuffer == null && secondaryBuffer == null)
                {
                    await Task.Delay(50, _cts.Token);
                    continue;
                }
                // If only one is available, create a zero buffer for the other
                int targetLength = System.Math.Max(primaryBuffer?.Length ?? 0, secondaryBuffer?.Length ?? 0);
                if (primaryBuffer == null)
                {
                    primaryBuffer = new byte[targetLength];
                }
                else if (secondaryBuffer == null)
                {
                    secondaryBuffer = new byte[targetLength];
                }
                else if (primaryBuffer.Length != secondaryBuffer.Length)
                {
                    // Resize to max and pad with zeros
                    if (primaryBuffer.Length < targetLength)
                    {
                        Array.Resize(ref primaryBuffer, targetLength);
                    }
                    else if (secondaryBuffer.Length < targetLength)
                    {
                        Array.Resize(ref secondaryBuffer, targetLength);
                    }
                }
                // Mix
                var mixedBuffer = MixAudioStreams(primaryBuffer, secondaryBuffer);
                WriteVerbose($"Mixed buffer length: {mixedBuffer.Length}, primary: {primaryBuffer.Length}, secondary: {secondaryBuffer.Length}");
                // Process the mixed buffer
                lock (_audioMixingLock)
                {
                    if (!_isRecordingStarted || _isDisposed) return;
                    if (MaxDurationOfSilence.HasValue || IgnoreSilence.ToBool())
                    {
                        seconds += mixedBuffer.Length / 32000d;
                        count += mixedBuffer.Length / 2;
                        unsafe
                        {
                            fixed (byte* buffer = mixedBuffer)
                            {
                                var floatBuffer = (Int16*)buffer;
                                var sampleCount = mixedBuffer.Length / 2;
                                for (var i = 0; i < sampleCount; i++)
                                {
                                    sumSq += floatBuffer[i] * floatBuffer[i];
                                }
                            }
                        }
                        wavBufferStream.Write(mixedBuffer, 0, mixedBuffer.Length);
                        wavBufferStream.Flush();
                        var rms = System.Math.Sqrt(sumSq / count);
                        if (rms > threshold)
                        {
                            hadAudio = true;
                            totalSilenceSeconds = 0;
                            everHadAudio = true;
                        }
                        if (seconds > 0.85)
                        {
                            if (!_isRecordingStarted) return;
                            if (rms < threshold)
                            {
                                totalSilenceSeconds += seconds;
                                if (everHadAudio && MaxDurationOfSilence.HasValue && (totalSilenceSeconds > MaxDurationOfSilence.Value.TotalSeconds))
                                {
                                    _isRecordingStarted = false;
                                    _cts.Cancel();
                                    return;
                                }
                                if (IgnoreSilence.ToBool() && !hadAudio)
                                {
                                    count = 0;
                                    sumSq = 0;
                                    seconds = 0;
                                    hadAudio = false;
                                    wavBufferStream.Position = 0;
                                    wavBufferStream.SetLength(0);
                                    return;
                                }
                                hadAudio = false;
                            }
                            // Add buffer to queue for processing
                            wavBufferStream.Position = 0;
                            var buffer = new byte[wavBufferStream.Length];
                            wavBufferStream.Read(buffer, 0, buffer.Length);
                            _bufferQueue.Enqueue(buffer);
                            _bufferQueueCount++;
                            wavBufferStream.Position = 0;
                            wavBufferStream.SetLength(0);
                            count = 0;
                            sumSq = 0;
                            seconds = 0;
                        }
                    }
                    else
                    {
                        // When not using silence detection, directly add to buffer queue
                        if (mixedBuffer.Length > 0)
                        {
                            _bufferQueue.Enqueue(mixedBuffer);
                            _bufferQueueCount++;
                        }
                    }
                }
            }
        }
        /// <summary>
        /// Mixes two audio streams by adding their samples together, applies volume normalization based on RMS levels,
        /// and clamps the result to 16-bit range to prevent clipping. Returns the mixed audio buffer.
        /// </summary>
        /// <param name="primaryBuffer">The primary audio buffer to mix.</param>
        /// <param name="secondaryBuffer">The secondary audio buffer to mix.</param>
        /// <returns>A byte array containing the mixed audio data.</returns>
        private byte[] MixAudioStreams(byte[] primaryBuffer, byte[] secondaryBuffer)
        {
            int length = System.Math.Min(primaryBuffer.Length, secondaryBuffer.Length);
            var mixedBuffer = new byte[length];
            unsafe
            {
                fixed (byte* primaryPtr = primaryBuffer)
                fixed (byte* secondaryPtr = secondaryBuffer)
                fixed (byte* mixedPtr = mixedBuffer)
                {
                    var primarySamples = (Int16*)primaryPtr;
                    var secondarySamples = (Int16*)secondaryPtr;
                    var mixedSamples = (Int16*)mixedPtr;
                    int sampleCount = length / 2;
                    for (int i = 0; i < sampleCount; i++)
                    {
                        int mixed = (int)primarySamples[i] + (int)secondarySamples[i];
                        // Clamp to 16-bit range
                        if (mixed > Int16.MaxValue) mixed = Int16.MaxValue;
                        if (mixed < Int16.MinValue) mixed = Int16.MinValue;
                        mixedSamples[i] = (Int16)mixed;
                    }
                }
            }
            // Simple volume normalization: compute RMS and scale if too loud/quiet
            double rmsSum = 0;
            unsafe
            {
                fixed (byte* mixedPtr = mixedBuffer)
                {
                    var samples = (Int16*)mixedPtr;
                    for (int i = 0; i < length / 2; i++)
                    {
                        rmsSum += samples[i] * samples[i];
                    }
                }
            }
            double rms = System.Math.Sqrt(rmsSum / (length / 2));
            double targetRms = 10000; // Arbitrary target, ~30% of max amplitude
            if (rms > 0)
            {
                double gain = targetRms / rms;
                if (gain < 1.0 || gain > 2.0) // Limit gain to avoid amplifying noise too much
                {
                    gain = System.Math.Clamp(gain, 0.5, 2.0);
                    unsafe
                    {
                        fixed (byte* mixedPtr = mixedBuffer)
                        {
                            var samples = (Int16*)mixedPtr;
                            for (int i = 0; i < length / 2; i++)
                            {
                                int adjusted = (int)(samples[i] * gain);
                                if (adjusted > Int16.MaxValue) adjusted = Int16.MaxValue;
                                if (adjusted < Int16.MinValue) adjusted = Int16.MinValue;
                                samples[i] = (Int16)adjusted;
                            }
                        }
                    }
                }
            }
            return mixedBuffer;
        }
        /// <summary>
        /// Processes audio input from a single wave input device, sets up event handlers for data availability,
        /// handles silence detection, and manages the recording lifecycle including fallback to desktop audio if needed.
        /// </summary>
        /// <param name="waveIn">The wave input device to process audio from.</param>
        private void ProcessSingleAudioInput(IWaveIn waveIn)
        {
            using (waveIn)
            {
                // WasapiLoopbackCapture ignores or rejects this - always read back
                // what the device actually settled on rather than assuming
                try
                {
                    waveIn.WaveFormat = new WaveFormat(16000, 1);
                }
                catch (Exception ex)
                {
                    _verboseQueue.Enqueue(
                        $"Capture device refused 16kHz mono ({ex.Message}); using its own format");
                }

                _captureFormat = waveIn.WaveFormat;

                _verboseQueue.Enqueue(
                    $"Capture: {waveIn.GetType().Name} @ {_captureFormat.SampleRate} Hz, " +
                    $"{_captureFormat.Channels} ch, {_captureFormat.BitsPerSample} bit, " +
                    $"{_captureFormat.Encoding}");

                var processingTask = Task.Run(() => ProcessAudioBuffer());
                _processingTask = processingTask;
                // Variables for silence detection
                hadAudio = false;
                everHadAudio = false;
                totalSilenceSeconds = 0;
                seconds = 0;
                sumSq = 0;
                count = 0;
                threshold = SilenceThreshold ?? 30;
                wavBufferStream = new MemoryStream();
                waveIn.DataAvailable += (sender, args) =>
                {
                    if (!_isRecordingStarted || _isDisposed) return;
                    _audioCallbackCount++;
                    lock (_audioMixingLock)
                    {
                        if (!_isRecordingStarted || _isDisposed) return;
                        // Validate buffer bounds before processing
                        if (args.Buffer == null || args.BytesRecorded <= 0 || args.BytesRecorded > args.Buffer.Length)
                        {
                            return;
                        }
                        if (MaxDurationOfSilence.HasValue || IgnoreSilence.ToBool())
                        {
                            seconds += args.BytesRecorded / 32000d;
                            count += args.BytesRecorded / 2;
                            unsafe
                            {
                                fixed (byte* buffer = args.Buffer)
                                {
                                    var floatBuffer = (Int16*)buffer;
                                    var sampleCount = System.Math.Min(args.BytesRecorded / 2, args.Buffer.Length / 2);
                                    for (var i = 0; i < sampleCount; i++)
                                    {
                                        sumSq += floatBuffer[i] * floatBuffer[i];
                                    }
                                }
                            }
                            wavBufferStream.Write(args.Buffer, 0, args.BytesRecorded);
                            wavBufferStream.Flush();
                            var rms = System.Math.Sqrt(sumSq / count);
                            if (rms > threshold)
                            {
                                hadAudio = true;
                                totalSilenceSeconds = 0;
                                everHadAudio = true;
                            }
                            if (seconds > 0.85)
                            {
                                if (!_isRecordingStarted) return;
                                if (rms < threshold)
                                {
                                    totalSilenceSeconds += seconds;
                                    if (everHadAudio && MaxDurationOfSilence.HasValue && (totalSilenceSeconds > MaxDurationOfSilence.Value.TotalSeconds))
                                    {
                                        _isRecordingStarted = false;
                                        _cts.Cancel();
                                        return;
                                    }
                                    if (IgnoreSilence.ToBool() && !hadAudio)
                                    {
                                        // Ignoring silence
                                        count = 0;
                                        sumSq = 0;
                                        seconds = 0;
                                        hadAudio = false;
                                        wavBufferStream.Position = 0;
                                        wavBufferStream.SetLength(0);
                                        return;
                                    }
                                    hadAudio = false;
                                }
                                // Add buffer to queue for processing
                                wavBufferStream.Position = 0;
                                var buffer = new byte[wavBufferStream.Length];
                                wavBufferStream.Read(buffer, 0, buffer.Length);
                                _bufferQueue.Enqueue(buffer);
                                _bufferQueueCount++;
                                wavBufferStream.Position = 0;
                                wavBufferStream.SetLength(0);
                                count = 0;
                                sumSq = 0;
                                seconds = 0;
                            }
                        }
                        else
                        {
                            // When not using silence detection, directly add to buffer queue
                            if (args.BytesRecorded > 0 && args.Buffer != null)
                            {
                                var buffer = new byte[args.BytesRecorded];
                                Array.Copy(args.Buffer, buffer, args.BytesRecorded);
                                _bufferQueue.Enqueue(buffer);
                                _bufferQueueCount++;
                            }
                        }
                    }
                };
                try
                {
                    waveIn.StartRecording();
                    ProcessMainLoop();
                }
                catch (Exception ex)
                {
                    if (!_isFallback && !UseDesktopAudioCapture.ToBool() && string.IsNullOrWhiteSpace(AudioDevice))
                    {
                        WriteWarning("No standard input device was found and switching to desktop audio.");
                        waveIn.Dispose();
                        _isFallback = true;
                        var desktopAudio = new WasapiLoopbackCapture();
                        ProcessSingleAudioInput(desktopAudio);
                        return;
                    }
                    WriteError(new ErrorRecord(ex, "AudioInputError", ErrorCategory.DeviceError, null));
                    throw;
                }
                finally
                {
                    try
                    {
                        waveIn.StopRecording();
                    }
                    catch (Exception ex)
                    {
                        WriteVerbose($"Error stopping wave input: {ex.Message}");
                    }
                    WaitForProcessingCompletion();
                }
            }
        }
        /// <summary>
        /// Runs the main processing loop that monitors for user input (Q to quit), enforces recording duration limits,
        /// and processes queued messages, errors, verbose output, and transcription results in the main thread.
        /// </summary>
        private void ProcessMainLoop()
        {
            System.Console.WriteLine("Recording started. Press Q to stop...");
            var startTime = System.DateTime.UtcNow;
            // Periodic pipeline heartbeat. Without it, "no output" is indistinguishable
            // between no audio arriving, audio arriving but never reaching the chunk
            // threshold, and whisper returning only blanks.
            var lastHeartbeat = System.DateTime.UtcNow;
            while (!_cts.IsCancellationRequested && _isRecordingStarted)
            {
                try
                {
                    if (System.Console.KeyAvailable)
                    {
                        var keyInfo = System.Console.ReadKey(true);
                        if (keyInfo.Key == ConsoleKey.Q)
                        {
                            _isRecordingStarted = false;
                            _cts.Cancel();
                            break;
                        }
                    }
                    if (MaxDuration.HasValue && (System.DateTime.UtcNow - startTime) > MaxDuration.Value)
                    {
                        System.Console.WriteLine($"Max recording time of {MaxDuration.Value.TotalSeconds} seconds reached.");
                        _isRecordingStarted = false;
                        _cts.Cancel();
                        break;
                    }
                    if ((System.DateTime.UtcNow - lastHeartbeat).TotalSeconds >= 3)
                    {
                        lastHeartbeat = System.DateTime.UtcNow;
                        WriteVerbose(
                            $"audio callbacks={_audioCallbackCount}, buffers queued={_bufferQueueCount}, " +
                            $"pending={_bufferQueue.Count}, segments={_results.Count}");
                    }
                    // Process all queued messages in the main thread
                    while (_errorQueue.TryDequeue(out var errorRecord))
                    {
                        WriteError(errorRecord);
                    }
                    while (_verboseQueue.TryDequeue(out var verboseMessage))
                    {
                        WriteVerbose(verboseMessage);
                    }
                    // Coalesce progress to the newest value rather than replaying
                    // every percentage point queued by the native callback
                    var latestProgress = -1;
                    while (_progressQueue.TryDequeue(out var percent))
                    {
                        latestProgress = percent;
                    }
                    if (latestProgress >= 0)
                    {
                        WriteProgress(new ProgressRecord(1, "Transcribing", $"Progress: {latestProgress}%")
                        {
                            PercentComplete = Math.Min(100, Math.Max(0, latestProgress))
                        });
                    }
                    while (_results.TryDequeue(out var segment))
                    {
                        WriteObject(Passthru ? segment : segment.Text.Trim());
                    }
                    Thread.Sleep(100);
                }
                catch (InvalidOperationException)
                {
                    // Console input not available, continue
                    Thread.Sleep(100);
                }
                catch (Exception ex)
                {
                    WriteError(new ErrorRecord(ex, "MainLoopError", ErrorCategory.OperationStopped, null));
                    break;
                }
            }
        }
        /// <summary>
        /// Waits for audio processing and mixing tasks to complete with proper timeout handling,
        /// processes any remaining queued results, errors, and verbose messages during cleanup.
        /// </summary>
        private void WaitForProcessingCompletion()
        {
            // Wait for processing to complete with proper timeout and error handling
            bool taskCompleted = false;
            try
            {
                // First try to wait gracefully
                taskCompleted = _processingTask.Wait(TimeSpan.FromSeconds(5));
                if (!taskCompleted)
                {
                    // If task doesn't complete, cancel and wait a bit more
                    _cts.Cancel();
                    taskCompleted = _processingTask.Wait(TimeSpan.FromSeconds(3));
                }
            }
            catch (AggregateException ex)
            {
                // Handle task exceptions
                foreach (var innerEx in ex.InnerExceptions)
                {
                    if (innerEx is not OperationCanceledException)
                    {
                        WriteVerbose($"Processing task error: {innerEx.Message}");
                    }
                }
            }
            catch (Exception ex)
            {
                WriteVerbose($"Error waiting for processing task: {ex.Message}");
            }
            // Wait for mixing task if exists
            if (_mixingTask != null)
            {
                try
                {
                    _mixingTask.Wait(TimeSpan.FromSeconds(5));
                }
                catch (Exception ex)
                {
                    WriteVerbose($"Error waiting for mixing task: {ex.Message}");
                }
            }
            // Process any remaining results regardless of task completion
            int timeout = 0;
            while (timeout < 50) // Max 5 seconds
            {
                bool hasResults = false;
                // Process all queued messages in the main thread during cleanup
                while (_errorQueue.TryDequeue(out var errorRecord))
                {
                    WriteError(errorRecord);
                    hasResults = true;
                }

                while (_verboseQueue.TryDequeue(out _))
                {
                    hasResults = true;
                }
                while (_results.TryDequeue(out var segment))
                {
                    WriteObject(Passthru ? segment : segment.Text.Trim());
                    hasResults = true;
                }
                if (!hasResults && taskCompleted)
                {
                    break; // No more results and task is done
                }
                Thread.Sleep(100);
                timeout++;
            }
        }
        /// <summary>
        /// Creates an appropriate audio input device based on configuration: desktop audio capture via WASAPI loopback
        /// or microphone input with optional device selection by name/GUID.
        /// </summary>
        /// <returns>An IWaveIn instance configured for the selected audio input.</returns>
        private IWaveIn CreateAudioInput()
        {
            if (UseDesktopAudioCapture.ToBool())
            {
                if (!string.IsNullOrWhiteSpace(AudioDevice))
                {
                    WriteVerbose($"Looking for desktop audio device matching: {AudioDevice}");
                    // For desktop audio capture, we use the default device but can log the attempt
                    WriteWarning($"Desktop audio device selection by name is not supported in this NAudio version. Using default desktop audio capture.");
                }
                return new WasapiLoopbackCapture();
            }
            else
            {
                if (!string.IsNullOrWhiteSpace(AudioDevice))
                {
                    // Find microphone device by name/GUID with wildcard support
                    WriteVerbose($"Looking for microphone device matching: {AudioDevice}");
                    for (int i = 0; i < WaveIn.DeviceCount; i++)
                    {
                        try
                        {
                            var deviceInfo = WaveIn.GetCapabilities(i);
                            if (IsDeviceMatch(deviceInfo.ProductName, AudioDevice) ||
                                IsDeviceMatch(deviceInfo.ProductGuid.ToString(), AudioDevice))
                            {
                                WriteVerbose($"Selected microphone device: {deviceInfo.ProductName}");
                                var waveIn = new WaveIn { DeviceNumber = i };
                                return waveIn;
                            }
                        }
                        catch (Exception ex)
                        {
                            WriteVerbose($"Could not check device {i}: {ex.Message}");
                        }
                    }
                    WriteWarning($"Microphone device '{AudioDevice}' not found, using default");
                }
                return new WaveIn();
            }
        }
        /// <summary>
        /// Checks if a device name matches a given pattern using wildcard support (* and ?).
        /// Performs case-insensitive regex matching after converting wildcards to regex patterns.
        /// </summary>
        /// <param name="deviceName">The device name to check.</param>
        /// <param name="pattern">The pattern to match against, supporting wildcards.</param>
        /// <returns>True if the device name matches the pattern, false otherwise.</returns>
        private static bool IsDeviceMatch(string deviceName, string pattern)
        {
            if (string.IsNullOrWhiteSpace(deviceName) || string.IsNullOrWhiteSpace(pattern))
                return false;
            // Convert wildcards to regex pattern
            string regexPattern = "^" + System.Text.RegularExpressions.Regex.Escape(pattern)
                .Replace("\\*", ".*")
                .Replace("\\?", ".") + "$";
            return System.Text.RegularExpressions.Regex.IsMatch(deviceName, regexPattern,
                System.Text.RegularExpressions.RegexOptions.IgnoreCase);
        }
        /// <summary>
        /// Configures the Whisper processor builder with all specified parameters including language, threads,
        /// temperature settings, token timestamps, translation, prompts, and various processing options.
        /// Detects physical CPU cores for optimal threading and applies silence/speech detection thresholds.
        /// </summary>
        /// <param name="builder">The WhisperProcessorBuilder to configure.</param>
        /// <returns>The configured WhisperProcessorBuilder instance.</returns>
        private WhisperProcessorBuilder ConfigureWhisperBuilder(WhisperProcessorBuilder builder)
        {
            int physicalCoreCount = 0;
            var searcher = new ManagementObjectSearcher("select NumberOfCores from Win32_Processor");
            foreach (var item in searcher.Get())
            {
                physicalCoreCount += Convert.ToInt32(item["NumberOfCores"]);
            }
            builder.WithLanguage(LanguageIn)
                   .WithThreads(ResolveThreadCount(physicalCoreCount));
            // Translation is driven solely by -WithTranslate below; specifying an
            // input language used to silently force translation to English
            // Improved speech detection settings
            if (Temperature.HasValue)
            {
                builder.WithTemperature(Temperature.Value);
            }
            else
            {
                builder.WithTemperature(0.0f); // Lower temperature for more consistent results
            }
            if (TemperatureInc.HasValue) builder.WithTemperatureInc(TemperatureInc.Value);
            if (WithTokenTimestamps.ToBool()) builder.WithTokenTimestamps().WithTokenTimestampsSumThreshold(TokenTimestampsSumThreshold);
            if (WithTranslate.ToBool()) builder.WithTranslate();
            if (!string.IsNullOrWhiteSpace(Prompt)) builder.WithPrompt(Prompt);
            if (!string.IsNullOrWhiteSpace(SuppressRegex)) builder.WithSuppressRegex(SuppressRegex);
            if (WithProgress.ToBool())
            {
                // Whisper invokes this from a native thread inside whisper_full, and
                // WriteProgress is thread-affine, so it may only enqueue here - the
                // main loop below does the actual writing
                builder.WithProgressHandler(progress => _progressQueue.Enqueue(progress));
            }
            if (SplitOnWord.ToBool()) builder.SplitOnWord();
            if (MaxTokensPerSegment.HasValue) builder.WithMaxTokensPerSegment(MaxTokensPerSegment.Value);
            // Improved silence/speech detection
            if (IgnoreSilence.ToBool())
            {
                builder.WithNoSpeechThreshold(0.4f); // More sensitive to speech (lower = more sensitive)
            }
            else if (NoSpeechThreshold.HasValue)
            {
                builder.WithNoSpeechThreshold(NoSpeechThreshold.Value);
            }
            else
            {
                builder.WithNoSpeechThreshold(0.6f); // Default Whisper threshold
            }
            if (AudioContextSize.HasValue) builder.WithAudioContextSize(AudioContextSize.Value);
            if (DontSuppressBlank.ToBool()) builder.WithoutSuppressBlank();
            if (MaxDuration.HasValue) builder.WithDuration(MaxDuration.Value);
            if (Offset.HasValue) builder.WithOffset(Offset.Value);
            if (MaxLastTextTokens.HasValue) builder.WithMaxLastTextTokens(MaxLastTextTokens.Value);
            if (SingleSegmentOnly.ToBool()) builder.WithSingleSegment();
            if (PrintSpecialTokens.ToBool()) builder.WithPrintSpecialTokens();
            if (MaxSegmentLength.HasValue) builder.WithMaxSegmentLength(MaxSegmentLength.Value);
            if (MaxInitialTimestamp.HasValue) builder.WithMaxInitialTs((int)MaxInitialTimestamp.Value.TotalSeconds);
            if (LengthPenalty.HasValue) builder.WithLengthPenalty(LengthPenalty.Value);
            if (EntropyThreshold.HasValue) builder.WithEntropyThreshold(EntropyThreshold.Value);
            if (LogProbThreshold.HasValue) builder.WithLogProbThreshold(LogProbThreshold.Value);
            if (NoContext.ToBool()) builder.WithNoContext();
            if (WithBeamSearchSamplingStrategy.ToBool()) builder.WithBeamSearchSamplingStrategy();
            return builder;
        }
        /// <summary>
        /// Processes audio buffers from the queue, converts PCM data to WAV format, and feeds it to the Whisper processor
        /// for speech-to-text transcription. Handles segmentation, cancellation, and error queuing for thread safety.
        /// Accumulates audio data until sufficient for processing (3+ seconds) or when recording stops.
        /// </summary>
        private async Task ProcessAudioBuffer()
        {
            using var processingStream = new MemoryStream();
            bool isProcessing = false;

            // Trigger a transcription every ~3 seconds of captured audio, matching
            // the step_ms default of whisper.cpp's own streaming example.
            //
            // The step size is the single biggest CPU lever here. whisper's encoder
            // always runs over a fixed 2*n_ctx by n_mels tensor (3000 x 80), so a
            // call costs the same whether it carries 1.5 seconds of audio or 30.
            // Halving the number of calls therefore halves encoder work outright:
            // 3s steps mean 20 encoder passes per minute of speech instead of 40,
            // and each pass sees more context, so accuracy improves too. The cost
            // is latency - text appears up to a step behind the speaker.
            //
            // Derived from the device's actual byte rate rather than hard-coded:
            // 48000 bytes is 1.5s only at 16kHz mono 16-bit, but just 0.125s at
            // 48kHz stereo float, which would fire far too often to keep up.
            var bytesPerSecond = _captureFormat?.AverageBytesPerSecond ?? 32000;
            var chunkSeconds = 3;
            var minChunkBytes = Math.Max(16000, bytesPerSecond * chunkSeconds);

            _verboseQueue.Enqueue(
                $"Buffering {minChunkBytes} bytes (~{chunkSeconds}s) per transcription at " +
                $"{bytesPerSecond} bytes/sec");
            try
            {
                while ((!_cts.IsCancellationRequested || !_bufferQueue.IsEmpty) && !_isDisposed)
                {
                    try
                    {
                        if (_bufferQueue.TryDequeue(out var buffer))
                        {
                            // Validate buffer before processing
                            if (buffer == null || buffer.Length == 0)
                            {
                                continue;
                            }
                            processingStream.Write(buffer, 0, buffer.Length);
                            // Increased threshold for better speech recognition
                            // 48000 bytes = ~3 seconds of audio (16kHz * 1 channel * 2 bytes * 3 seconds)
                            if (!isProcessing && processingStream.Length >= minChunkBytes)
                            {
                                var audioDurationSeconds = processingStream.Length / (double)bytesPerSecond;
                                isProcessing = true;
                                // Convert from the device's actual format - it is not
                                // necessarily the 16kHz mono 16-bit that was requested
                                var pcmBytes = processingStream.ToArray();
                                var samples = AudioDecoder.ConvertToPcm16KMono(pcmBytes, pcmBytes.Length, _captureFormat);
                                _verboseQueue.Enqueue(
                                    $"Transcribing {audioDurationSeconds:F2}s chunk ({samples.Length} samples)");
                                try
                                {
                                    int segmentCount = 0;
                                    await foreach (var segment in _processor.ProcessAsync(samples, _cts.Token))
                                    {
                                        if (_cts.IsCancellationRequested || _isDisposed)
                                        {
                                            break;
                                        }
                                        segmentCount++;
                                        if (!string.IsNullOrWhiteSpace(segment.Text))
                                        {
                                            if (!(segment.Text.Trim("\r\n\t ".ToCharArray()) == "[BLANK_AUDIO]"))
                                            {
                                                _results.Enqueue(segment);
                                            }
                                        }
                                    }
                                }
                                catch (OperationCanceledException)
                                {
                                    break;
                                }
                                catch (Exception ex) when (!_isDisposed)
                                {
                                    // Queue error for main thread to process
                                    _errorQueue.Enqueue(new ErrorRecord(ex, "WhisperProcessingError", ErrorCategory.OperationStopped, null));
                                }
                                processingStream.SetLength(0);
                                isProcessing = false;
                            }
                        }
                        else
                        {
                            // If we have data but not enough for a full segment, process it anyway when stopping
                            if (!_isRecordingStarted && processingStream.Length > 0 && !isProcessing && !_isDisposed)
                            {
                                var audioDurationSeconds = processingStream.Length / (double)bytesPerSecond;
                                isProcessing = true;
                                // Final partial buffer, same format-aware conversion
                                var pcmBytes = processingStream.ToArray();
                                var samples = AudioDecoder.ConvertToPcm16KMono(pcmBytes, pcmBytes.Length, _captureFormat);
                                try
                                {
                                    int segmentCount = 0;
                                    await foreach (var segment in _processor.ProcessAsync(samples, _cts.Token))
                                    {
                                        if (_cts.IsCancellationRequested || _isDisposed)
                                        {
                                            break;
                                        }
                                        segmentCount++;
                                        if (!string.IsNullOrWhiteSpace(segment.Text))
                                        {
                                            _results.Enqueue(segment);
                                        }
                                    }
                                }
                                catch (OperationCanceledException)
                                {
                                    break;
                                }
                                catch (Exception ex) when (!_isDisposed)
                                {
                                    // Queue error for main thread to process
                                    _errorQueue.Enqueue(new ErrorRecord(ex, "FinalProcessingError", ErrorCategory.OperationStopped, null));
                                }
                                processingStream.SetLength(0);
                                isProcessing = false;
                            }
                            await Task.Delay(50, _cts.Token);
                        }
                    }
                    catch (OperationCanceledException)
                    {
                        break;
                    }
                    catch (Exception ex) when (ex is not OperationCanceledException && !_isDisposed)
                    {
                        // Queue error for main thread to process instead of calling WriteError directly
                        _errorQueue.Enqueue(new ErrorRecord(ex, "ProcessingError", ErrorCategory.OperationStopped, null));
                        break;
                    }
                }
            }
            catch when (!_isDisposed)
            {
            }
        }
        /// <summary>
        /// Cleans up resources and disposes of audio components.
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
                // Stop recording first to prevent new audio data
                _isRecordingStarted = false;
                // Cancel any ongoing operations
                if (_cts != null && !_cts.IsCancellationRequested)
                {
                    _cts.Cancel();
                }
                // Wait for processing task to complete with timeout
                if (_processingTask != null && !_processingTask.IsCompleted)
                {
                    try
                    {
                        var completed = _processingTask.Wait(TimeSpan.FromSeconds(50));
                        if (!completed)
                        {
                            WriteVerbose("Processing task did not complete within timeout");
                        }
                    }
                    catch (AggregateException ex)
                    {
                        // Expected when task is cancelled
                        WriteVerbose($"Processing task cancelled: {ex.InnerExceptions.FirstOrDefault()?.Message}");
                    }
                    catch (Exception ex)
                    {
                        WriteVerbose($"Error waiting for processing task: {ex.Message}");
                    }
                }
                // Wait for mixing task if exists
                if (_mixingTask != null && !_mixingTask.IsCompleted)
                {
                    try
                    {
                        _mixingTask.Wait(TimeSpan.FromSeconds(50));
                    }
                    catch (AggregateException ex)
                    {
                        WriteVerbose($"Mixing task cancelled: {ex.InnerExceptions.FirstOrDefault()?.Message}");
                    }
                    catch (Exception ex)
                    {
                        WriteVerbose($"Error waiting for mixing task: {ex.Message}");
                    }
                }
                // Dispose audio inputs
                try
                {
                    _primaryWaveIn?.Dispose();
                    _secondaryWaveIn?.Dispose();
                }
                catch (Exception ex)
                {
                    WriteVerbose($"Error disposing audio inputs: {ex.Message}");
                }
                // Dispose wavBufferStream
                try
                {
                    wavBufferStream?.Dispose();
                }
                catch (Exception ex)
                {
                    WriteVerbose($"Error disposing wavBufferStream: {ex.Message}");
                }
                // Dispose Whisper processor first (it uses the factory)
                if (_processor != null)
                {
                    try
                    {
                        // Properly dispose async resources
                        if (_processor is IAsyncDisposable asyncDisposable)
                        {
                            // Wait for async disposal to complete
                            asyncDisposable.DisposeAsync().AsTask().Wait(TimeSpan.FromSeconds(50));
                        }
                        else if (_processor is IDisposable disposable)
                        {
                            disposable.Dispose();
                        }
                    }
                    catch (Exception ex)
                    {
                        WriteVerbose($"Error disposing Whisper processor: {ex.Message}");
                    }
                    finally
                    {
                        _processor = null;
                    }
                }
                // Then dispose Whisper factory
                if (_whisperFactory != null)
                {
                    try
                    {
                        _whisperFactory.Dispose();
                    }
                    catch (Exception ex)
                    {
                        WriteVerbose($"Error disposing Whisper factory: {ex.Message}");
                    }
                    finally
                    {
                        _whisperFactory = null;
                    }
                }
                // Finally dispose cancellation token source
                if (_cts != null)
                {
                    try
                    {
                        _cts.Dispose();
                    }
                    catch (Exception ex)
                    {
                        WriteVerbose($"Error disposing cancellation token source: {ex.Message}");
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
        /// <summary>
        /// Decides how many threads to hand to whisper.
        ///
        /// ggml parallelises with OpenMP, so asking for more threads than the
        /// machine has logical processors does not go faster - the workers contend
        /// for the same cores and the extra scheduling makes it slower.
        /// </summary>
        /// <param name="physicalCoreCount">Physical cores detected via WMI.</param>
        /// <returns>Thread count to use.</returns>
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
                _verboseQueue.Enqueue(
                    $"-CpuThreads {CpuThreads} exceeds the {logical} logical processors " +
                    $"on this machine; using {logical}. Oversubscribing ggml's OpenMP " +
                    $"pool slows transcription down.");

                return logical;
            }

            return CpuThreads;
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
                    WhisperInterop.AddProbeDirectory(Path.Combine(moduleBase, "lib"));
                }
            }
            catch (Exception ex)
            {
                // Not fatal - the resolver still probes the directory holding the
                // assembly itself, which covers the normal layouts
                WriteVerbose($"Could not resolve the module base: {ex.Message}");
            }
        }

        /// <summary>
        /// Resolves the model file for a model type, downloading it on first use.
        /// </summary>
        /// <param name="modelType">The GGML model type.</param>
        /// <returns>Full path to the model file.</returns>
        private string EnsureModelAvailable(GgmlType modelType)
        {
            // Accept a model that is already on disk under either the canonical
            // whisper.cpp name or the older name this cmdlet used to write
            foreach (var candidate in modelType.GetModelFileNameCandidates())
            {
                var existing = Path.GetFullPath(Path.Combine(ModelFileDirectoryPath, candidate));
                if (File.Exists(existing))
                {
                    WriteVerbose($"Using Whisper model: {existing}");
                    return existing;
                }
            }

            var modelFileName = Path.GetFullPath(
                Path.Combine(ModelFileDirectoryPath, modelType.ToModelFileName()));

            WriteVerbose($"Downloading Whisper model {modelType} to {modelFileName}");
            System.Console.WriteLine($"Downloading Whisper model {modelType.ToCanonicalName()}...");

            var lastPercent = -1;

            WhisperGgmlDownloader.DownloadModelAsync(
                modelType,
                modelFileName,
                percent =>
                {
                    // Only report when the number actually moves
                    if (percent == lastPercent) return;
                    lastPercent = percent;
                    _verboseQueue.Enqueue($"Downloading {modelType.ToCanonicalName()}: {percent}%");
                },
                _cts.Token).GetAwaiter().GetResult();

            return modelFileName;
        }
    }
}
