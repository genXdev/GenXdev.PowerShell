using System.Collections.Concurrent;
using EdgeTTS.DotNet;
using NAudio.Wave;

namespace GenXdev.Helpers
{
    /// <summary>
    /// Provides static text-to-speech instances backed by Microsoft Edge's
    /// neural TTS engine and NAudio for audio playback.
    /// </summary>
    public static class Misc
    {
        /// <summary>
        /// Default TTS synthesizer (uses Edge's default voice).
        /// </summary>
        public static EdgeTtsSynthesizer Speech = new EdgeTtsSynthesizer();

        /// <summary>
        /// Customizable TTS synthesizer – voice, rate, volume
        /// and pitch can be set before speaking.
        /// </summary>
        public static EdgeTtsSynthesizer SpeechCustomized =
            new EdgeTtsSynthesizer();

        /// <summary>
        /// Emergency TTS synthesizer – used by <c>Start-TextToSpeech -Force</c>
        /// to speak urgent text without disturbing the main queue.
        /// </summary>
        public static EdgeTtsSynthesizer EmergencySpeech =
            new EdgeTtsSynthesizer();

        // -- global pause / resume (across all three instances) -------------

        /// <summary>
        /// <c>true</c> after <see cref="PauseAllSpeech"/> is called,
        /// <c>false</c> after <see cref="ResumeAllSpeech"/>.  Used by
        /// <c>InterruptAndSpeak</c> to decide whether to auto-resume.
        /// </summary>
        public static bool IsUserPaused { get; private set; }

        /// <summary>
        /// Pause audio on whichever synthesizer is currently producing
        /// sound — queued speech, force-interrupted speech, or the
        /// default instance.  Safe to call when nothing is playing
        /// (no-op).  Sets <see cref="IsUserPaused"/> so that a
        /// subsequent <c>-Force</c> call won't auto-resume.
        /// </summary>
        public static void PauseAllSpeech()
        {
            Speech.PauseSpeech();
            SpeechCustomized.PauseSpeech();
            EmergencySpeech.PauseSpeech();
            IsUserPaused = true;
        }

        /// <summary>
        /// Resume audio on whichever synthesizer was paused via
        /// <see cref="PauseAllSpeech"/>.  Only the instance that
        /// actually has a paused <c>_currentOutput</c> will wake up;
        /// the other two are harmless no-ops.  Clears
        /// <see cref="IsUserPaused"/>.
        /// </summary>
        public static void ResumeAllSpeech()
        {
            Speech.ResumeSpeech();
            SpeechCustomized.ResumeSpeech();
            EmergencySpeech.ResumeSpeech();
            IsUserPaused = false;
        }
    }

    // -----------------------------------------------------------------------
    // Voice metadata (replaces System.Speech InstalledVoice / VoiceInfo)
    // -----------------------------------------------------------------------

    /// <summary>
    /// Metadata for an available Edge TTS voice.  The <c>Name</c>
    /// property provides backward-compatibility with the old
    /// <c>.VoiceInfo.Name</c> pattern used in PowerShell scripts.
    /// </summary>
    public class VoiceInfo
    {
        public string ShortName { get; internal set; }
        public string Locale { get; internal set; }
        public string Gender { get; internal set; }
        public string Name => ShortName; // backward compat
    }

    // -----------------------------------------------------------------------
    // EdgeTTS synthesizer wrapper
    // -----------------------------------------------------------------------

    /// <summary>
    /// Wraps EdgeTTS.DotNet and NAudio into an API surface compatible
    /// with the legacy <c>SpeechSynthesizer</c> calls used by
    /// <c>Start-TextToSpeech</c>, <c>Stop-TextToSpeech</c>
    /// and <c>Get-IsSpeaking</c>.
    /// </summary>
    public class EdgeTtsSynthesizer : IDisposable
    {
        /// <summary>Lightweight record for queued speech items.</summary>
        private readonly record struct SpeechItem(
            string Text, string Voice, string Rate, string Volume, string Pitch);

        private readonly object _gate = new();

        // -- queue-based speech (replaces _queueSemaphore + _globalCancel) --
        private readonly ConcurrentQueue<SpeechItem> _speechQueue = new();
        private readonly SemaphoreSlim _queueSignal = new(0, int.MaxValue);
        private CancellationTokenSource _queueCts;
        private bool _queueActive; // guarded by _gate

        // -- settings / state --
        private string _voice = "en-US-AriaNeural";
        private string _rate = "+0%";
        private string _volume = "+0%";
        private string _pitch = "+0Hz";
        private CancellationTokenSource _activeCts;
        private WaveOutEvent _currentOutput; // guarded by _gate
        private bool _disposed;

        // -- preload (eliminates EdgeTTS API latency between sentences) --
        private WaveOutEvent _preloadedOutput;  // guarded by _gate
        private Mp3FileReader _preloadedReader; // guarded by _gate
        private MemoryStream _preloadedStream;   // guarded by _gate

        /// <summary>True while audio is playing.</summary>
        public bool IsSpeaking
        {
            get
            {
                lock (_gate)
                {
                    return _activeCts != null &&
                        !_activeCts.IsCancellationRequested;
                }
            }
        }

        /// <summary>
        /// String state for backward-compat ("Speaking" / "Ready").
        /// </summary>
        public string State => IsSpeaking ? "Speaking" : "Ready";

        // -- configuration setters ------------------------------------------

        public void SetVoice(string voice)
        {
            lock (_gate) { _voice = voice; }
        }

        public void SetRate(string rate)
        {
            lock (_gate) { _rate = rate; }
        }

        public void SetVolume(string volume)
        {
            lock (_gate) { _volume = volume; }
        }

        public void SetPitch(string pitch)
        {
            lock (_gate) { _pitch = pitch; }
        }

        /// <summary>
        /// Copies voice/prosody settings to another synthesizer.
        /// </summary>
        public void CopySettingsTo(EdgeTtsSynthesizer other)
        {
            string v, r, vol, p;
            lock (_gate)
            {
                v = _voice; r = _rate; vol = _volume; p = _pitch;
            }
            other.SetVoice(v);
            other.SetRate(r);
            other.SetVolume(vol);
            other.SetPitch(p);
        }

        // -- voice discovery ------------------------------------------------

        /// <summary>Returns all Edge TTS voices (blocks).</summary>
        public List<VoiceInfo> GetInstalledVoices()
        {
            var t = EdgeTTS.DotNet.Voices.ListVoicesAsync();
            t.Wait();
            return t.Result.Select(v => new VoiceInfo
            {
                ShortName = v.ShortName,
                Locale = v.Locale,
                Gender = v.Gender
            }).ToList();
        }

        /// <summary>
        /// Select a voice from the list returned by
        /// <see cref="GetInstalledVoices"/>.
        /// </summary>
        public void SelectVoice(VoiceInfo voice)
        {
            if (voice != null) SetVoice(voice.ShortName);
        }

        // -- text splitting -----------------------------------------------

        /// <summary>
        /// Splits text on sentence boundaries (., !, ?) and line-breaks,
        /// trims each chunk, and discards empty ones.  This keeps Edge TTS
        /// responsive by avoiding huge single MP3 files.
        /// </summary>
        public static IEnumerable<string> SplitText(string text)
        {
            if (string.IsNullOrWhiteSpace(text))
                yield break;

            var chunks = System.Text.RegularExpressions.Regex.Split(
                text, @"(?<=[.!?])\s+|\r?\n");

            foreach (var chunk in chunks)
            {
                var trimmed = chunk.Trim();
                if (trimmed.Length > 0)
                    yield return trimmed;
            }
        }

        // -- speak (synchronous) --------------------------------------------

        /// <summary>
        /// Speak with configured voice/prosody.  Blocks until playback
        /// finishes.  The input text is split on sentence boundaries
        /// for responsiveness.
        /// </summary>
        public void Speak(string text)
        {
            foreach (var chunk in SplitText(text))
                SpeakInternal(chunk, wait: true);
        }

        // -- speak (asynchronous / fire-and-forget) -------------------------

        /// <summary>
        /// Speak on a background thread.  Returns immediately.
        /// </summary>
        public void SpeakAsync(string text)
        {
            string voice, rate, volume, pitch;
            CancellationToken token;
            lock (_gate)
            {
                if (_disposed)
                    throw new ObjectDisposedException(
                        nameof(EdgeTtsSynthesizer));

                voice = _voice;
                rate = _rate;
                volume = _volume;
                pitch = _pitch;

                _activeCts?.Cancel();
                _activeCts?.Dispose();
                _activeCts = new CancellationTokenSource();
                token = _activeCts.Token;
            }

            _ = Task.Run(async () =>
            {
                try
                {
                    await SpeakCoreAsync(text, voice, rate, volume,
                        pitch, wait: false, token);
                }
                catch (OperationCanceledException) { }
                catch (Exception)
                {
                }
                finally
                {
                    lock (_gate)
                    {
                        if (_activeCts != null &&
                            _activeCts.Token == token)
                        {
                            _activeCts.Dispose();
                            _activeCts = null;
                        }
                    }
                }
            }, token);
        }

        // -- speak (queued, like old System.Speech) -------------------------

        /// <summary>
        /// Enqueue text to speak after any currently-playing speech
        /// finishes.  Multiple calls queue up sequentially without
        /// cancelling each other.  A single background processor drains
        /// the queue so that <see cref="SpeakAsyncCancelAll"/> can
        /// atomically clear it.
        /// The input text is split on sentence boundaries so each
        /// chunk is a small, quick-to-cancel MP3.
        /// </summary>
        public void SpeakAsyncQueued(string text)
        {
            string voice, rate, volume, pitch;
            lock (_gate)
            {
                if (_disposed)
                    throw new ObjectDisposedException(
                        nameof(EdgeTtsSynthesizer));
                voice = _voice;
                rate = _rate;
                volume = _volume;
                pitch = _pitch;
            }

            int count = 0;
            foreach (var chunk in SplitText(text))
            {
                _speechQueue.Enqueue(
                    new SpeechItem(chunk, voice, rate, volume, pitch));
                count++;
            }

            if (count > 0)
            {
                // One signal is enough — the processor drains all items
                // in its inner while (TryDequeue) loop once woken.
                _queueSignal.Release();
                EnsureQueueProcessor();
            }
        }

        /// <summary>
        /// Starts the single background queue processor if it isn't
        /// already running.  Caller must NOT hold <c>_gate</c>.
        /// </summary>
        private void EnsureQueueProcessor()
        {
            lock (_gate)
            {
                if (_queueActive || _disposed)
                    return;

                _queueActive = true;
                _queueCts = new CancellationTokenSource();
                var myCts = _queueCts;        // capture for finally check
                var token = _queueCts.Token;

                _ = Task.Run(() => ProcessQueueAsync(token, myCts));
            }
        }

        /// <summary>
        /// Single background loop that drains <c>_speechQueue</c>.
        /// While one sentence plays, the next is pre-synthesized in
        /// the background: played and immediately paused so that
        /// Resuming it has zero API latency.
        /// </summary>
        private async Task ProcessQueueAsync(
            CancellationToken token, CancellationTokenSource myCts)
        {
            try
            {
                while (!token.IsCancellationRequested)
                {
                    await _queueSignal.WaitAsync(token);

                    while (_speechQueue.TryDequeue(out var item))
                    {
                        if (token.IsCancellationRequested)
                            break;

                        using var cts = CancellationTokenSource
                            .CreateLinkedTokenSource(token);
                        lock (_gate)
                        {
                            _activeCts?.Dispose();
                            _activeCts = cts;
                        }

                        // -- preload the NEXT item while we play
                        //    the current one -----------------------
                        Task nextPreload = null;
                        if (_speechQueue.TryPeek(out var nextItem))
                            nextPreload = PreloadAsync(nextItem, cts.Token);

                        try
                        {
                            // Take ownership of any preloaded
                            // (paused) audio from previous iteration
                            WaveOutEvent preOut;
                            Mp3FileReader preRdr;
                            MemoryStream preStm;
                            lock (_gate)
                            {
                                preOut = _preloadedOutput;
                                preRdr = _preloadedReader;
                                preStm = _preloadedStream;
                                _preloadedOutput = null;
                                _preloadedReader = null;
                                _preloadedStream = null;
                            }

                            if (preOut != null)
                            {
                                // Resume — instant, no API latency
                                PlayPreloaded(preOut, preRdr, preStm,
                                    cts.Token);
                            }
                            else
                            {
                                await SpeakCoreAsync(
                                    item.Text, item.Voice, item.Rate,
                                    item.Volume, item.Pitch,
                                    wait: true, cts.Token);
                            }
                        }
                        catch (OperationCanceledException) { }
                        catch { }
                        finally
                        {
                            lock (_gate)
                            {
                                _activeCts?.Dispose();
                                _activeCts = null;
                            }
                        }

                        if (nextPreload != null)
                        {
                            try { await nextPreload; } catch { }
                        }
                    }
                }
            }
            catch (OperationCanceledException) { }
            finally
            {
                lock (_gate)
                {
                    if (_queueCts == myCts)
                    {
                        _queueActive = false;
                        _queueCts?.Dispose();
                        _queueCts = null;
                    }
                }
            }
        }

        /// <summary>
        /// Preload the next sentence: synthesize via EdgeTTS to a temp
        /// file, load into a MemoryStream (deleting the file immediately),
        /// then create a NAudio WaveOutEvent, Play and immediately Pause.
        /// The paused output stays in memory — no lingering temp file.
        /// </summary>
        private async Task PreloadAsync(SpeechItem item, CancellationToken token)
        {
            string tempFile = null;
            try
            {
                var communicate = new Communicate(
                    item.Text, voice: item.Voice,
                    rate: item.Rate, volume: item.Volume,
                    pitch: item.Pitch);

                tempFile = Path.GetTempFileName() + ".mp3";
                await communicate.SaveAsync(tempFile, token);

                if (new FileInfo(tempFile).Length == 0)
                    return;

                // Load into memory, delete temp file immediately
                var stream = new MemoryStream(
                    await File.ReadAllBytesAsync(tempFile, token));
                File.Delete(tempFile);
                tempFile = null;

                var reader = new Mp3FileReader(stream);
                var output = new WaveOutEvent();
                output.Init(reader);
                output.Play();
                output.Pause(); // buffered, ready to resume

                lock (_gate)
                {
                    DisposePreloaded(); // discard stale
                    _preloadedOutput = output;
                    _preloadedReader = reader;
                    _preloadedStream = stream;
                }
            }
            catch (OperationCanceledException) { }
            catch { }
            finally
            {
                if (tempFile != null)
                {
                    try { File.Delete(tempFile); } catch { }
                }
            }
        }

        /// <summary>Resume a preloaded (paused) output and wait for it.</summary>
        private void PlayPreloaded(
            WaveOutEvent output, Mp3FileReader reader,
            MemoryStream stream, CancellationToken token)
        {
            lock (_gate) { _currentOutput = output; }
            try
            {
                var stopped = new ManualResetEventSlim(false);
                output.PlaybackStopped += (_, _) => stopped.Set();
                output.Play();

                while (output.PlaybackState == PlaybackState.Playing &&
                       !token.IsCancellationRequested)
                    Thread.Sleep(50);

                if (token.IsCancellationRequested)
                    output.Stop();

                stopped.Wait(TimeSpan.FromSeconds(60));
            }
            finally
            {
                lock (_gate) { _currentOutput = null; }
                try { output.Dispose(); } catch { }
                try { reader.Dispose(); } catch { }
                try { stream.Dispose(); } catch { }
            }
        }

        /// <summary>Cleanup stale preload. Call under <c>_gate</c>.</summary>
        private void DisposePreloaded()
        {
            if (_preloadedOutput != null)
            {
                try { _preloadedOutput.Dispose(); } catch { }
                _preloadedOutput = null;
            }
            if (_preloadedReader != null)
            {
                try { _preloadedReader.Dispose(); } catch { }
                _preloadedReader = null;
            }
            if (_preloadedStream != null)
            {
                try { _preloadedStream.Dispose(); } catch { }
                _preloadedStream = null;
            }
        }

        // -- pause / resume -------------------------------------------------

        /// <summary>Pause the currently playing audio, if any.</summary>
        public void PauseSpeech()
        {
            lock (_gate)
            {
                _currentOutput?.Pause();
            }
        }

        /// <summary>Resume previously paused audio, if any.</summary>
        public void ResumeSpeech()
        {
            lock (_gate)
            {
                _currentOutput?.Play();
            }
        }

        // -- cancel / clear -------------------------------------------------

        /// <summary>
        /// Cancel the currently-playing item (if any), immediately stop
        /// audio output, and atomically clear the internal queue and stop
        /// the background processor.
        /// </summary>
        public void StopAndClear()
        {
            CancellationTokenSource capturedQueueCts;
            lock (_gate)
            {
                _activeCts?.Cancel();
                // Stop NAudio playback immediately — don't wait for the
                // token-polling loop in PlaySync.
                _currentOutput?.Stop();
                capturedQueueCts = DrainAndStopQueue();
            }

            capturedQueueCts?.Cancel();
            capturedQueueCts?.Dispose();
        }

        /// <summary>
        /// Cancel all active and queued speech.  Atomically clears the
        /// internal queue, cancels the active item, and stops the
        /// background processor.
        /// </summary>
        public void SpeakAsyncCancelAll() => StopAndClear();

        /// <summary>
        /// Pauses any currently playing speech on this instance, speaks
        /// <paramref name="text"/> on a <b>separate emergency instance</b>
        /// (blocking), then resumes the paused speech.  The internal
        /// queue on this instance is left completely untouched.
        /// </summary>
        public void InterruptAndSpeak(string text)
        {
            // If the user manually paused (Suspend-TextToSpeech),
            // don't auto-resume after the forced speech — respect
            // the user's explicit pause.
            bool wasUserPaused = Misc.IsUserPaused;

            // 1. Pause any audio currently playing on this instance
            //    (unless the user already paused everything).
            if (!wasUserPaused)
                PauseSpeech();

            // Let the pause settle before using the audio device.
            System.Threading.Thread.Sleep(1000);

            try
            {
                // 2. Copy voice/prosody settings to the emergency
                //    synthesizer — it is a completely independent
                //    instance so the main queue keeps running.
                CopySettingsTo(Misc.EmergencySpeech);

                // 3. Speak the forced text synchronously on the
                //    emergency instance (blocking).
                Misc.EmergencySpeech.Speak(text);
            }
            finally
            {
                // 4. Brief silence so the interjection is clearly
                //    separated from the resumed speech.
                System.Threading.Thread.Sleep(2000);

                // 5. Resume whatever was paused — BUT only if we
                //    paused it.  If the user paused manually, stay
                //    paused so they can Resume-TextToSpeech later.
                if (!wasUserPaused)
                    ResumeSpeech();
            }
        }

        // -- helpers --------------------------------------------------------

        /// <summary>
        /// Drains <c>_speechQueue</c>, sets <c>_queueActive=false</c>,
        /// nulls <c>_queueCts</c>.  MUST be called under <c>_gate</c>.
        /// Returns the old <c>_queueCts</c> so the caller can cancel
        /// and dispose it OUTSIDE the lock.
        /// </summary>
        private CancellationTokenSource DrainAndStopQueue()
        {
            _speechQueue.Clear();
            var old = _queueCts;
            _queueActive = false;
            _queueCts = null;
            DisposePreloaded();
            return old;
        }

        // -- internals ------------------------------------------------------

        private void SpeakInternal(string text, bool wait)
        {
            string voice, rate, volume, pitch;
            CancellationToken token;
            lock (_gate)
            {
                if (_disposed)
                    throw new ObjectDisposedException(
                        nameof(EdgeTtsSynthesizer));

                voice = _voice;
                rate = _rate;
                volume = _volume;
                pitch = _pitch;

                _activeCts?.Cancel();
                _activeCts?.Dispose();
                _activeCts = new CancellationTokenSource();
                token = _activeCts.Token;
            }

            try
            {
                SpeakCoreAsync(text, voice, rate, volume,
                    pitch, wait, token).GetAwaiter().GetResult();
            }
            catch (OperationCanceledException) { }
            finally
            {
                lock (_gate)
                {
                    if (_activeCts != null &&
                        _activeCts.Token == token)
                    {
                        _activeCts.Dispose();
                        _activeCts = null;
                    }
                }
            }
        }

        private async Task SpeakCoreAsync(
            string text, string voice, string rate,
            string volume, string pitch,
            bool wait, CancellationToken token)
        {
            string tempFile = null;
            try
            {
                var communicate = new Communicate(
                    text,
                    voice: voice,
                    rate: rate,
                    volume: volume,
                    pitch: pitch);

                tempFile = Path.GetTempFileName() + ".mp3";
                await communicate.SaveAsync(tempFile, token);

                if (new FileInfo(tempFile).Length == 0)
                {
                    return;
                }

                PlayAudioFile(tempFile, token, wait);
                tempFile = null; // ownership transferred to PlayAudioFile
            }
            catch (OperationCanceledException) { }
            catch (Exception)
            {
            }
            finally
            {
                if (tempFile != null)
                {
                    try { File.Delete(tempFile); } catch { }
                }
            }
        }

        private void PlayAudioFile(
            string filePath, CancellationToken token, bool wait)
        {
            var reader = new AudioFileReader(filePath);
            var output = new WaveOutEvent();
            output.Init(reader);

            if (wait)
                PlaySync(output, reader, filePath, token);
            else
                PlayAsync(output, reader, filePath, token);
        }

        private void PlaySync(
            WaveOutEvent output, AudioFileReader reader,
            string filePath, CancellationToken token)
        {
            // Track the output so PauseSpeech/ResumeSpeech can control it.
            lock (_gate) { _currentOutput = output; }

            try
            {
                using (reader)
                {
                    var stopped = new ManualResetEventSlim(false);
                    output.PlaybackStopped += (_, _) => stopped.Set();
                    output.Play();

                    while (output.PlaybackState == PlaybackState.Playing &&
                           !token.IsCancellationRequested)
                    {
                        Thread.Sleep(50);
                    }

                    if (token.IsCancellationRequested)
                        output.Stop();

                    // Wait for PlaybackStopped with generous timeout
                    stopped.Wait(TimeSpan.FromSeconds(60));
                }
            }
            finally
            {
                lock (_gate) { _currentOutput = null; }
                output.Dispose();
            }

            // Safe to delete now — playback is done
            try { File.Delete(filePath); } catch { }
        }

        private void PlayAsync(
            WaveOutEvent output, AudioFileReader reader,
            string filePath, CancellationToken token)
        {
            // Track the output so PauseSpeech/ResumeSpeech can control it.
            lock (_gate) { _currentOutput = output; }

            // NO using blocks — cleanup on PlaybackStopped or cancel
            var capturedOutput = output;
            var capturedReader = reader;
            var capturedPath = filePath;

            var ctr = token.Register(() =>
            {
                try { capturedOutput.Stop(); } catch { }
            });

            capturedOutput.PlaybackStopped += (_, _) =>
            {
                ctr.Dispose();
                try { capturedOutput.Dispose(); } catch { }
                try { capturedReader.Dispose(); } catch { }
                try { File.Delete(capturedPath); } catch { }
                lock (_gate) { _currentOutput = null; }
            };

            capturedOutput.Play();
        }

        // -- IDisposable ----------------------------------------------------

        public void Dispose()
        {
            CancellationTokenSource capturedQueueCts;
            lock (_gate)
            {
                if (_disposed) return;
                _disposed = true;

                _activeCts?.Cancel();
                capturedQueueCts = DrainAndStopQueue();
            }

            capturedQueueCts?.Cancel();

            _activeCts?.Dispose();
            _activeCts = null;
            capturedQueueCts?.Dispose();
            _queueSignal.Dispose();
        }
    }
}