using System.Runtime.CompilerServices;
using System.Runtime.InteropServices;
using System.Threading.Channels;

namespace GenXdev.AI.Whisper
{
    /// <summary>
    /// Everything the builder collects, applied onto a fresh copy of the native
    /// defaults on each transcription run.
    /// </summary>
    internal sealed class WhisperProcessorSettings
    {
        public WhisperSamplingStrategy Strategy { get; set; }
            = WhisperSamplingStrategy.Greedy;

        public string Language { get; set; } = "en";

        public int? Threads { get; set; }

        public bool Translate { get; set; }

        public float? Temperature { get; set; }

        public float? TemperatureInc { get; set; }

        public bool TokenTimestamps { get; set; }

        public float? TokenTimestampsSumThreshold { get; set; }

        public string Prompt { get; set; }

        public string SuppressRegex { get; set; }

        public Action<int> ProgressHandler { get; set; }

        public bool SplitOnWord { get; set; }

        public int? MaxTokensPerSegment { get; set; }

        public float? NoSpeechThreshold { get; set; }

        public int? AudioContextSize { get; set; }

        public bool SuppressBlankDisabled { get; set; }

        public TimeSpan? Duration { get; set; }

        public TimeSpan? Offset { get; set; }

        public int? MaxLastTextTokens { get; set; }

        public bool SingleSegment { get; set; }

        public bool PrintSpecialTokens { get; set; }

        public int? MaxSegmentLength { get; set; }

        public int? MaxInitialTs { get; set; }

        public float? LengthPenalty { get; set; }

        public float? EntropyThreshold { get; set; }

        public float? LogProbThreshold { get; set; }

        public bool NoContext { get; set; }
    }

    /// <summary>
    /// Fluent configuration for a WhisperProcessor.
    /// </summary>
    public sealed class WhisperProcessorBuilder
    {
        private readonly WhisperFactory _factory;

        internal WhisperProcessorSettings Settings { get; }
            = new WhisperProcessorSettings();

        internal WhisperProcessorBuilder(WhisperFactory factory)
        {
            _factory = factory;
        }

        public WhisperProcessorBuilder WithLanguage(string language)
        {
            Settings.Language = language;
            return this;
        }

        public WhisperProcessorBuilder WithThreads(int threads)
        {
            Settings.Threads = threads;
            return this;
        }

        public WhisperProcessorBuilder WithTranslate()
        {
            Settings.Translate = true;
            return this;
        }

        public WhisperProcessorBuilder WithTemperature(float temperature)
        {
            Settings.Temperature = temperature;
            return this;
        }

        public WhisperProcessorBuilder WithTemperatureInc(float temperatureInc)
        {
            Settings.TemperatureInc = temperatureInc;
            return this;
        }

        public WhisperProcessorBuilder WithTokenTimestamps()
        {
            Settings.TokenTimestamps = true;
            return this;
        }

        public WhisperProcessorBuilder WithTokenTimestampsSumThreshold(
            float threshold)
        {
            Settings.TokenTimestampsSumThreshold = threshold;
            return this;
        }

        public WhisperProcessorBuilder WithPrompt(string prompt)
        {
            Settings.Prompt = prompt;
            return this;
        }

        public WhisperProcessorBuilder WithSuppressRegex(string suppressRegex)
        {
            Settings.SuppressRegex = suppressRegex;
            return this;
        }

        public WhisperProcessorBuilder WithProgressHandler(Action<int> handler)
        {
            Settings.ProgressHandler = handler;
            return this;
        }

        public WhisperProcessorBuilder SplitOnWord()
        {
            Settings.SplitOnWord = true;
            return this;
        }

        public WhisperProcessorBuilder WithMaxTokensPerSegment(int maxTokens)
        {
            Settings.MaxTokensPerSegment = maxTokens;
            return this;
        }

        public WhisperProcessorBuilder WithNoSpeechThreshold(float threshold)
        {
            Settings.NoSpeechThreshold = threshold;
            return this;
        }

        public WhisperProcessorBuilder WithAudioContextSize(int audioContextSize)
        {
            Settings.AudioContextSize = audioContextSize;
            return this;
        }

        public WhisperProcessorBuilder WithoutSuppressBlank()
        {
            Settings.SuppressBlankDisabled = true;
            return this;
        }

        public WhisperProcessorBuilder WithDuration(TimeSpan duration)
        {
            Settings.Duration = duration;
            return this;
        }

        public WhisperProcessorBuilder WithOffset(TimeSpan offset)
        {
            Settings.Offset = offset;
            return this;
        }

        public WhisperProcessorBuilder WithMaxLastTextTokens(int maxLastTextTokens)
        {
            Settings.MaxLastTextTokens = maxLastTextTokens;
            return this;
        }

        public WhisperProcessorBuilder WithSingleSegment()
        {
            Settings.SingleSegment = true;
            return this;
        }

        public WhisperProcessorBuilder WithPrintSpecialTokens()
        {
            Settings.PrintSpecialTokens = true;
            return this;
        }

        public WhisperProcessorBuilder WithMaxSegmentLength(int maxSegmentLength)
        {
            Settings.MaxSegmentLength = maxSegmentLength;
            return this;
        }

        public WhisperProcessorBuilder WithMaxInitialTs(int maxInitialTs)
        {
            Settings.MaxInitialTs = maxInitialTs;
            return this;
        }

        public WhisperProcessorBuilder WithLengthPenalty(float lengthPenalty)
        {
            Settings.LengthPenalty = lengthPenalty;
            return this;
        }

        public WhisperProcessorBuilder WithEntropyThreshold(float entropyThreshold)
        {
            Settings.EntropyThreshold = entropyThreshold;
            return this;
        }

        public WhisperProcessorBuilder WithLogProbThreshold(float logProbThreshold)
        {
            Settings.LogProbThreshold = logProbThreshold;
            return this;
        }

        public WhisperProcessorBuilder WithNoContext()
        {
            Settings.NoContext = true;
            return this;
        }

        public WhisperProcessorBuilder WithBeamSearchSamplingStrategy()
        {
            Settings.Strategy = WhisperSamplingStrategy.BeamSearch;
            return this;
        }

        public WhisperProcessor Build()
        {
            return new WhisperProcessor(_factory, Settings);
        }
    }

    /// <summary>
    /// Owns a loaded Whisper model. Create processors from it via CreateBuilder.
    /// </summary>
    public sealed class WhisperFactory : IDisposable
    {
        private IntPtr _context;

        private bool _disposed;

        private readonly object _lock = new();

        private WhisperFactory(IntPtr context, bool isMultilingual)
        {
            _context = context;

            IsMultilingual = isMultilingual;
        }

        /// <summary>
        /// False for the English-only models (the ".en" variants). Those cannot
        /// detect a language or translate, and asking them to produces garbage -
        /// auto-detect on tiny.en will happily report Nepali at p=0.01.
        /// </summary>
        public bool IsMultilingual { get; }

        internal IntPtr Context
        {
            get
            {
                if (_disposed)
                {
                    throw new ObjectDisposedException(nameof(WhisperFactory));
                }

                return _context;
            }
        }

        /// <summary>
        /// Serialises access to the native context - whisper_full is not safe to
        /// call concurrently on one context.
        /// </summary>
        internal object SyncRoot => _lock;

        /// <summary>
        /// Loads a ggml Whisper model from disk.
        /// </summary>
        public static WhisperFactory FromPath(string path)
        {
            if (string.IsNullOrWhiteSpace(path))
            {
                throw new ArgumentException(
                    "Model path is required", nameof(path));
            }

            if (!File.Exists(path))
            {
                throw new FileNotFoundException(
                    $"Whisper model not found: {path}", path);
            }

            WhisperInterop.EnsureLayoutValid();

            var paramsPtr = WhisperInterop.whisper_context_default_params_by_ref();

            if (paramsPtr == IntPtr.Zero)
            {
                throw new InvalidOperationException(
                    "whisper_context_default_params_by_ref returned null.");
            }

            WhisperContextParams contextParams;

            try
            {
                contextParams =
                    Marshal.PtrToStructure<WhisperContextParams>(paramsPtr);
            }
            finally
            {
                WhisperInterop.whisper_free_context_params(paramsPtr);
            }

            // Only the CPU backend ships with this module, so skip GPU probing
            // entirely rather than letting it fail over.
            contextParams.UseGpu = 0;

            var context = WhisperInterop.whisper_init_from_file_with_params(
                path, contextParams);

            if (context == IntPtr.Zero)
            {
                throw new InvalidOperationException(
                    $"Failed to load Whisper model '{path}'. The file may be " +
                    $"truncated or corrupt - delete it and let it download again.");
            }

            return new WhisperFactory(
                context,
                WhisperInterop.whisper_is_multilingual(context) != 0);
        }

        public WhisperProcessorBuilder CreateBuilder()
        {
            return new WhisperProcessorBuilder(this);
        }

        public void Dispose()
        {
            lock (_lock)
            {
                if (_disposed) return;

                _disposed = true;

                if (_context != IntPtr.Zero)
                {
                    WhisperInterop.whisper_free(_context);

                    _context = IntPtr.Zero;
                }
            }
        }
    }

    /// <summary>
    /// Transcribes audio using a configured Whisper model.
    ///
    /// whisper_full is a single long blocking native call, so it runs on a
    /// background thread and its new-segment callback publishes into a channel.
    /// That keeps segments flowing to the caller as they are produced rather than
    /// arriving in one batch at the end.
    /// </summary>
    public sealed class WhisperProcessor : IDisposable, IAsyncDisposable
    {
        private readonly WhisperFactory _factory;

        private readonly WhisperProcessorSettings _settings;

        private bool _disposed;

        internal WhisperProcessor(
            WhisperFactory factory, WhisperProcessorSettings settings)
        {
            _factory = factory;
            _settings = settings;
        }

        /// <summary>
        /// Number of samples handed to whisper_full per call when streaming from a
        /// stream: ten minutes of 16 kHz mono audio, about 38 MB as float.
        ///
        /// Deliberately an exact multiple of whisper's internal 30 second frame, so
        /// a window boundary always lands on a frame boundary whisper would have
        /// cut at anyway rather than part way through one.
        /// </summary>
        private const int WindowSamples = AudioDecoder.WhisperSampleRate * 600;

        /// <summary>
        /// Transcribes an audio stream. Any format NAudio can decode is accepted;
        /// it is downmixed to mono and resampled to the 16 kHz Whisper expects.
        ///
        /// The audio is pulled and transcribed one window at a time rather than
        /// decoded up front, so peak memory is bounded by WindowSamples regardless
        /// of length - a six hour recording costs the same as a six minute one -
        /// and segments start arriving after the first window instead of after the
        /// whole file. Segment timestamps are shifted to stay absolute.
        /// </summary>
        public async IAsyncEnumerable<SegmentData> ProcessAsync(
            Stream audioStream,
            [EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            if (_disposed)
            {
                throw new ObjectDisposedException(nameof(WhisperProcessor));
            }

            using var reader = AudioDecoder.OpenPcm16KMono(audioStream);

            // One buffer, reused for every window - each window is fully consumed
            // before the next read, so there is no aliasing hazard.
            var buffer = new float[WindowSamples];

            long samplesConsumed = 0;

            while (!cancellationToken.IsCancellationRequested)
            {
                var read = reader.Read(buffer, WindowSamples);

                if (read <= 0) break;

                var offset = TimeSpan.FromSeconds(
                    (double)samplesConsumed / AudioDecoder.WhisperSampleRate);

                await foreach (var segment in
                    ProcessCoreAsync(buffer, read, cancellationToken)
                        .ConfigureAwait(false))
                {
                    yield return offset == TimeSpan.Zero
                        ? segment
                        : Shift(segment, offset);
                }

                samplesConsumed += read;

                // A short read means the source is drained.
                if (read < WindowSamples) break;
            }
        }

        /// <summary>
        /// Re-stamps a segment so its times are absolute within the whole stream
        /// rather than relative to the window it came from.
        /// </summary>
        private static SegmentData Shift(SegmentData segment, TimeSpan offset)
        {
            return new SegmentData(
                segment.Text,
                segment.Start + offset,
                segment.End + offset,
                segment.MinProbability,
                segment.MaxProbability,
                segment.Probability,
                segment.NoSpeechProbability,
                segment.Language,
                segment.Tokens);
        }

        /// <summary>
        /// Transcribes raw 16 kHz mono PCM samples in the range -1..1.
        /// </summary>
        public IAsyncEnumerable<SegmentData> ProcessAsync(
            float[] samples,
            CancellationToken cancellationToken = default)
        {
            if (_disposed)
            {
                throw new ObjectDisposedException(nameof(WhisperProcessor));
            }

            return ProcessCoreAsync(
                samples, samples?.Length ?? 0, cancellationToken);
        }

        /// <summary>
        /// Transcribes the first <paramref name="sampleCount"/> samples of the
        /// buffer, so callers can reuse one window buffer across calls.
        /// </summary>
        private async IAsyncEnumerable<SegmentData> ProcessCoreAsync(
            float[] samples,
            int sampleCount,
            [EnumeratorCancellation] CancellationToken cancellationToken = default)
        {
            if (samples == null || sampleCount <= 0)
            {
                yield break;
            }

            var channel = Channel.CreateUnbounded<SegmentData>(
                new UnboundedChannelOptions
                {
                    SingleReader = true,
                    SingleWriter = true
                });

            var runTask = Task.Run(
                () => RunTranscription(
                    samples, sampleCount, channel.Writer, cancellationToken),
                CancellationToken.None);

            while (await channel.Reader.WaitToReadAsync(CancellationToken.None)
                .ConfigureAwait(false))
            {
                while (channel.Reader.TryRead(out var segment))
                {
                    yield return segment;
                }
            }

            // Surfaces any native failure to the caller.
            await runTask.ConfigureAwait(false);
        }

        /// <summary>
        /// Builds the native parameter block, runs whisper_full, and publishes
        /// segments as the native callback reports them.
        /// </summary>
        private void RunTranscription(
            float[] samples,
            int sampleCount,
            ChannelWriter<SegmentData> writer,
            CancellationToken cancellationToken)
        {
            Exception failure = null;

            // Native strings and the pinned sample buffer have to outlive the
            // whisper_full call, so they are tracked here and released in finally.
            var allocated = new List<IntPtr>();

            GCHandle samplesHandle = default;

            // Delegates must stay reachable for the whole native call.
            WhisperNewSegmentCallback segmentCallback = null;
            WhisperProgressCallback progressCallback = null;
            GgmlAbortCallback abortCallback = null;

            try
            {
                lock (_factory.SyncRoot)
                {
                    var ctx = _factory.Context;

                    var paramsPtr = WhisperInterop.whisper_full_default_params_by_ref(
                        (int)_settings.Strategy);

                    if (paramsPtr == IntPtr.Zero)
                    {
                        throw new InvalidOperationException(
                            "whisper_full_default_params_by_ref returned null.");
                    }

                    WhisperFullParams p;

                    try
                    {
                        p = Marshal.PtrToStructure<WhisperFullParams>(paramsPtr);
                    }
                    finally
                    {
                        WhisperInterop.whisper_free_params(paramsPtr);
                    }

                    // whisper.cpp defaults print_progress and print_timestamps to
                    // true and writes them to stderr; that would pollute the
                    // PowerShell streams, so everything native stays quiet.
                    p.PrintProgress = 0;
                    p.PrintRealtime = 0;
                    p.PrintTimestamps = 0;
                    p.PrintSpecial = (byte)(_settings.PrintSpecialTokens ? 1 : 0);

                    ApplySettings(ref p, allocated);

                    var segmentsEmitted = 0;

                    segmentCallback = (c, state, nNew, userData) =>
                    {
                        try
                        {
                            var total = WhisperInterop.whisper_full_n_segments(c);

                            for (var i = total - nNew; i < total; i++)
                            {
                                if (i < segmentsEmitted) continue;

                                writer.TryWrite(ReadSegment(c, i));

                                segmentsEmitted = i + 1;
                            }
                        }
                        catch
                        {
                            // A managed exception must never unwind into native
                            // code; a dropped segment is the lesser evil.
                        }
                    };

                    var progressHandler = _settings.ProgressHandler;

                    if (progressHandler != null)
                    {
                        progressCallback = (c, state, progress, userData) =>
                        {
                            try { progressHandler(progress); }
                            catch { }
                        };

                        p.ProgressCallback =
                            Marshal.GetFunctionPointerForDelegate(progressCallback);
                    }

                    abortCallback = userData =>
                        (byte)(cancellationToken.IsCancellationRequested ? 1 : 0);

                    p.NewSegmentCallback =
                        Marshal.GetFunctionPointerForDelegate(segmentCallback);

                    p.AbortCallback =
                        Marshal.GetFunctionPointerForDelegate(abortCallback);

                    samplesHandle = GCHandle.Alloc(samples, GCHandleType.Pinned);

                    var result = WhisperInterop.whisper_full(
                        ctx,
                        p,
                        samplesHandle.AddrOfPinnedObject(),
                        sampleCount);

                    GC.KeepAlive(segmentCallback);
                    GC.KeepAlive(progressCallback);
                    GC.KeepAlive(abortCallback);

                    if (result != 0 && !cancellationToken.IsCancellationRequested)
                    {
                        // -5 is whisper's "audio_ctx is larger than the maximum
                        // allowed" - worth naming, since the bare code gives the
                        // caller no clue which parameter is at fault
                        if (result == -5 && _settings.AudioContextSize.HasValue)
                        {
                            throw new InvalidOperationException(
                                $"The audio context size " +
                                $"{_settings.AudioContextSize.Value} exceeds what " +
                                $"this model allows (the maximum is 1500). Lower " +
                                $"-AudioContextSize; around 750 roughly halves " +
                                $"encoder work at some cost in accuracy.");
                        }

                        throw new InvalidOperationException(
                            $"whisper_full failed with code {result}.");
                    }
                }
            }
            catch (Exception ex)
            {
                failure = ex;
            }
            finally
            {
                if (samplesHandle.IsAllocated)
                {
                    samplesHandle.Free();
                }

                foreach (var ptr in allocated)
                {
                    if (ptr != IntPtr.Zero)
                    {
                        Marshal.FreeCoTaskMem(ptr);
                    }
                }

                writer.TryComplete(failure);
            }
        }

        /// <summary>
        /// Copies the builder settings onto the native parameter block. Strings are
        /// allocated as UTF-8 and registered for release once the call returns.
        /// </summary>
        private void ApplySettings(
            ref WhisperFullParams p, List<IntPtr> allocated)
        {
            IntPtr Utf8(string value)
            {
                var ptr = Marshal.StringToCoTaskMemUTF8(value);

                allocated.Add(ptr);

                return ptr;
            }

            var language = _settings.Language;

            var wantsAuto = string.IsNullOrWhiteSpace(language) ||
                string.Equals(language, "auto", StringComparison.OrdinalIgnoreCase);

            if (!_factory.IsMultilingual)
            {
                // English-only models cannot detect a language or translate.
                // Forcing "en" here mirrors what whisper.cpp's own CLI does
                // (examples/cli/cli.cpp) - without it, auto-detect on a ".en"
                // model returns a nonsense language at p=0.01 and the
                // transcription comes back empty.
                if (wantsAuto ||
                    !string.Equals(language, "en", StringComparison.OrdinalIgnoreCase) ||
                    _settings.Translate)
                {
                    WhisperInterop.Log(
                        "model is English-only: ignoring the requested language " +
                        (wantsAuto ? "auto-detection" : $"'{language}'") +
                        (_settings.Translate ? " and translation" : "") +
                        " and using 'en'");
                }

                p.Language = Utf8("en");
                p.DetectLanguage = 0;
                p.Translate = 0;
            }
            else if (wantsAuto)
            {
                p.Language = Utf8("auto");
                p.DetectLanguage = 1;
            }
            else
            {
                if (WhisperInterop.whisper_lang_id(language) < 0)
                {
                    throw new ArgumentException(
                        $"'{language}' is not a language Whisper recognises. Use a " +
                        $"code such as 'en', 'nl' or 'de', or 'auto' to detect it.");
                }

                p.Language = Utf8(language);
                p.DetectLanguage = 0;
            }

            if (_settings.Threads.HasValue && _settings.Threads.Value > 0)
            {
                p.NThreads = _settings.Threads.Value;
            }

            // Guarded by IsMultilingual: the English-only branch above already
            // cleared Translate, and this must not re-enable it
            if (_settings.Translate && _factory.IsMultilingual) p.Translate = 1;

            if (_settings.NoContext) p.NoContext = 1;

            if (_settings.SingleSegment) p.SingleSegment = 1;

            if (_settings.SplitOnWord) p.SplitOnWord = 1;

            if (_settings.SuppressBlankDisabled) p.SuppressBlank = 0;

            if (_settings.TokenTimestamps) p.TokenTimestamps = 1;

            if (_settings.TokenTimestampsSumThreshold.HasValue)
                p.TholdPtsum = _settings.TokenTimestampsSumThreshold.Value;

            if (_settings.Temperature.HasValue)
                p.Temperature = _settings.Temperature.Value;

            if (_settings.TemperatureInc.HasValue)
                p.TemperatureInc = _settings.TemperatureInc.Value;

            if (_settings.NoSpeechThreshold.HasValue)
                p.NoSpeechThold = _settings.NoSpeechThreshold.Value;

            if (_settings.EntropyThreshold.HasValue)
                p.EntropyThold = _settings.EntropyThreshold.Value;

            if (_settings.LogProbThreshold.HasValue)
                p.LogprobThold = _settings.LogProbThreshold.Value;

            if (_settings.LengthPenalty.HasValue)
                p.LengthPenalty = _settings.LengthPenalty.Value;

            if (_settings.MaxInitialTs.HasValue)
                p.MaxInitialTs = _settings.MaxInitialTs.Value;

            if (_settings.MaxTokensPerSegment.HasValue)
                p.MaxTokens = _settings.MaxTokensPerSegment.Value;

            if (_settings.MaxSegmentLength.HasValue)
                p.MaxLen = _settings.MaxSegmentLength.Value;

            if (_settings.MaxLastTextTokens.HasValue)
                p.NMaxTextCtx = _settings.MaxLastTextTokens.Value;

            if (_settings.AudioContextSize.HasValue)
                p.AudioCtx = _settings.AudioContextSize.Value;

            if (_settings.Offset.HasValue)
                p.OffsetMs = (int)_settings.Offset.Value.TotalMilliseconds;

            if (_settings.Duration.HasValue)
                p.DurationMs = (int)_settings.Duration.Value.TotalMilliseconds;

            if (!string.IsNullOrWhiteSpace(_settings.Prompt))
                p.InitialPrompt = Utf8(_settings.Prompt);

            if (!string.IsNullOrWhiteSpace(_settings.SuppressRegex))
                p.SuppressRegex = Utf8(_settings.SuppressRegex);
        }

        /// <summary>
        /// Materialises one native segment. Called on the native callback thread,
        /// so it stays allocation-light and never throws outward.
        /// </summary>
        private static SegmentData ReadSegment(IntPtr ctx, int index)
        {
            var text = WhisperInterop.PtrToString(
                WhisperInterop.whisper_full_get_segment_text(ctx, index));

            // whisper reports timestamps in centiseconds.
            var t0 = WhisperInterop.whisper_full_get_segment_t0(ctx, index);
            var t1 = WhisperInterop.whisper_full_get_segment_t1(ctx, index);

            var noSpeech =
                WhisperInterop.whisper_full_get_segment_no_speech_prob(ctx, index);

            var tokenCount = WhisperInterop.whisper_full_n_tokens(ctx, index);

            var tokens = new WhisperToken[Math.Max(0, tokenCount)];

            var min = 1f;
            var max = 0f;
            var sum = 0f;

            for (var i = 0; i < tokenCount; i++)
            {
                var prob = WhisperInterop.whisper_full_get_token_p(ctx, index, i);

                if (prob < min) min = prob;
                if (prob > max) max = prob;

                sum += prob;

                tokens[i] = new WhisperToken
                {
                    Text = WhisperInterop.PtrToString(
                        WhisperInterop.whisper_full_get_token_text(ctx, index, i)),
                    Probability = prob
                };
            }

            if (tokenCount == 0)
            {
                min = 0f;
            }

            var langId = WhisperInterop.whisper_full_lang_id(ctx);

            var language = langId >= 0
                ? WhisperInterop.PtrToString(WhisperInterop.whisper_lang_str(langId))
                : string.Empty;

            return new SegmentData(
                text,
                TimeSpan.FromMilliseconds(t0 * 10),
                TimeSpan.FromMilliseconds(t1 * 10),
                min,
                max,
                tokenCount > 0 ? sum / tokenCount : 0f,
                noSpeech,
                language,
                tokens);
        }

        public void Dispose()
        {
            _disposed = true;
        }

        public ValueTask DisposeAsync()
        {
            Dispose();

            return ValueTask.CompletedTask;
        }
    }
}
