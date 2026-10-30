using NAudio.Wave;
using NAudio.Wave.SampleProviders;

namespace GenXdev.AI.Whisper
{
    /// <summary>
    /// Turns audio into the 16 kHz mono float PCM that whisper.cpp expects.
    ///
    /// Whisper.net effectively only accepted 16 kHz WAV. Decoding through NAudio
    /// means WAV, MP3 and AIFF work directly, plus anything Media Foundation can
    /// open (m4a, wma), with downmix and resample handled here.
    /// </summary>
    public static class AudioDecoder
    {
        /// <summary>The sample rate every Whisper model is trained on.</summary>
        public const int WhisperSampleRate = 16000;

        private static bool _mediaFoundationStarted;

        private static readonly Lock _mediaFoundationLock = new();

        /// <summary>
        /// Opens an audio stream as a pull-based source of mono 16 kHz samples.
        ///
        /// Preferred over DecodeToPcm16KMono for anything long: the caller reads a
        /// window at a time, so peak memory stays flat no matter how many hours of
        /// audio there are. Decoding a two hour film in one go would otherwise cost
        /// roughly 460 MB of float samples.
        /// </summary>
        public static Pcm16KMonoReader OpenPcm16KMono(Stream audioStream)
        {
            ArgumentNullException.ThrowIfNull(audioStream);

            // The readers need to seek, and Media Foundation needs a stream it can
            // re-read after a failed probe.
            var seekable = EnsureSeekable(audioStream);

            var reader = OpenReader(seekable);

            try
            {
                ISampleProvider sampleProvider = reader.ToSampleProvider();

                if (sampleProvider.WaveFormat.Channels > 1)
                {
                    sampleProvider = new MonoDownmixSampleProvider(sampleProvider);
                }

                if (sampleProvider.WaveFormat.SampleRate != WhisperSampleRate)
                {
                    sampleProvider = new WdlResamplingSampleProvider(
                        sampleProvider, WhisperSampleRate);
                }

                return new Pcm16KMonoReader(reader, sampleProvider);
            }
            catch
            {
                reader.Dispose();

                throw;
            }
        }

        /// <summary>
        /// Decodes an entire audio stream to mono 16 kHz samples in the range -1..1.
        ///
        /// Materialises the whole thing, so only use it for audio of known-modest
        /// length; the windowed Pcm16KMonoReader is the general path.
        /// </summary>
        public static float[] DecodeToPcm16KMono(Stream audioStream)
        {
            using var reader = OpenPcm16KMono(audioStream);

            // Pre-size from the reported duration so the accumulator does not
            // repeatedly double and then copy the whole buffer again on ToArray.
            var estimate = reader.EstimatedSampleCount;

            var result = new List<float>(
                estimate > 0 && estimate < int.MaxValue
                    ? (int)estimate
                    : WhisperSampleRate * 30);

            var buffer = new float[WhisperSampleRate];

            int read;

            while ((read = reader.Read(buffer, buffer.Length)) > 0)
            {
                for (var i = 0; i < read; i++)
                {
                    result.Add(buffer[i]);
                }
            }

            return [.. result];
        }

        /// <summary>
        /// Converts interleaved 16-bit PCM bytes to the float samples whisper
        /// expects. Used by the real-time path, which already captures at
        /// 16 kHz mono and so needs no resampling.
        /// </summary>
        public static float[] Pcm16ToFloat(byte[] buffer, int byteCount)
        {
            if (buffer == null || byteCount <= 1) return [];

            var sampleCount = byteCount / 2;

            var samples = new float[sampleCount];

            for (var i = 0; i < sampleCount; i++)
            {
                var sample = (short)(buffer[i * 2] | (buffer[i * 2 + 1] << 8));

                samples[i] = sample / 32768f;
            }

            return samples;
        }

        /// <summary>
        /// Converts a block of captured audio to mono 16 kHz float samples,
        /// honouring whatever format the capture device actually produced.
        ///
        /// Live capture cannot assume 16 kHz mono 16-bit: a capture device may
        /// deliver its own format (commonly 48 kHz stereo IEEE float) and some
        /// microphones refuse a requested format. Reinterpreting those bytes as
        /// 16-bit mono PCM yields noise, which whisper then transcribes as nothing.
        /// </summary>
        public static float[] ConvertToPcm16KMono(
            byte[] buffer, int byteCount, WaveFormat sourceFormat)
        {
            if (buffer == null || byteCount <= 1) return [];

            // Fast path - already exactly what whisper wants
            if (sourceFormat == null ||
                (sourceFormat.SampleRate == WhisperSampleRate &&
                 sourceFormat.Channels == 1 &&
                 sourceFormat.Encoding == WaveFormatEncoding.Pcm &&
                 sourceFormat.BitsPerSample == 16))
            {
                return Pcm16ToFloat(buffer, byteCount);
            }

            var memory = new MemoryStream(buffer, 0, byteCount, writable: false);

            using var raw = new RawSourceWaveStream(memory, sourceFormat);

            ISampleProvider provider = raw.ToSampleProvider();

            if (provider.WaveFormat.Channels > 1)
            {
                provider = new MonoDownmixSampleProvider(provider);
            }

            if (provider.WaveFormat.SampleRate != WhisperSampleRate)
            {
                provider = new WdlResamplingSampleProvider(
                    provider, WhisperSampleRate);
            }

            // Bounded by the caller's block size, so a plain list is fine here
            var result = new List<float>(byteCount / 2);

            var scratch = new float[WhisperSampleRate];

            int read;

            while ((read = provider.Read(scratch.AsSpan())) > 0)
            {
                for (var i = 0; i < read; i++)
                {
                    result.Add(scratch[i]);
                }
            }

            return [.. result];
        }

        private static Stream EnsureSeekable(Stream input)
        {
            if (input.CanSeek)
            {
                input.Position = 0;

                return input;
            }

            var memory = new MemoryStream();

            input.CopyTo(memory);

            memory.Position = 0;

            return memory;
        }

        /// <summary>
        /// Picks a reader by sniffing the container, falling back to Media
        /// Foundation for whatever the codecs installed on the box can open.
        /// </summary>
        private static WaveStream OpenReader(Stream stream)
        {
            var header = new byte[12];

            var read = stream.Read(header, 0, header.Length);

            stream.Position = 0;

            var isRiff = read >= 4 &&
                header[0] == (byte)'R' && header[1] == (byte)'I' &&
                header[2] == (byte)'F' && header[3] == (byte)'F';

            if (isRiff)
            {
                return new WaveFileReader(stream);
            }

            var isAiff = read >= 4 &&
                header[0] == (byte)'F' && header[1] == (byte)'O' &&
                header[2] == (byte)'R' && header[3] == (byte)'M';

            if (isAiff)
            {
                return new AiffFileReader(stream);
            }

            try
            {
                return new Mp3FileReader(stream);
            }
            catch
            {
                stream.Position = 0;
            }

            EnsureMediaFoundationStarted();

            try
            {
                return new StreamMediaFoundationReader(stream);
            }
            catch (Exception ex)
            {
                throw new NotSupportedException(
                    "Could not decode this audio. Supported formats are WAV, AIFF, " +
                    "MP3 and anything the installed Media Foundation codecs can " +
                    "open (m4a, wma). Convert to 16 kHz mono WAV and retry.", ex);
            }
        }

        private static void EnsureMediaFoundationStarted()
        {
            lock (_mediaFoundationLock)
            {
                if (_mediaFoundationStarted) return;

                try
                {
                    NAudio.MediaFoundation.MediaFoundationApi.Startup();
                }
                catch
                {
                    // Media Foundation is unavailable on some SKUs; the reader
                    // construction below will report the real problem.
                }

                _mediaFoundationStarted = true;
            }
        }

        /// <summary>
        /// A pull-based source of mono 16 kHz float samples, decoded on demand.
        /// Dispose it to release the underlying reader and stream.
        /// </summary>
        public sealed class Pcm16KMonoReader : IDisposable
        {
            private readonly WaveStream _reader;

            private readonly ISampleProvider _provider;

            private bool _disposed;

            internal Pcm16KMonoReader(WaveStream reader, ISampleProvider provider)
            {
                _reader = reader;
                _provider = provider;
            }

            /// <summary>
            /// Sample count implied by the source duration, or 0 when unknown.
            /// An estimate only - resampling makes it approximate.
            /// </summary>
            public long EstimatedSampleCount
            {
                get
                {
                    try
                    {
                        return (long)(_reader.TotalTime.TotalSeconds
                            * WhisperSampleRate);
                    }
                    catch
                    {
                        return 0;
                    }
                }
            }

            /// <summary>
            /// Fills up to <paramref name="count"/> samples into the buffer.
            /// Returns the number of samples read, or 0 at end of stream.
            /// </summary>
            public int Read(float[] buffer, int count)
            {
                if (_disposed)
                {
                    throw new ObjectDisposedException(nameof(Pcm16KMonoReader));
                }

                if (buffer == null || count <= 0) return 0;

                var wanted = Math.Min(count, buffer.Length);

                // A provider may return a short read without being at the end, so
                // keep pulling until the window is full or the source runs dry.
                var total = 0;

                while (total < wanted)
                {
                    var read = _provider.Read(
                        buffer.AsSpan(total, wanted - total));

                    if (read <= 0) break;

                    total += read;
                }

                return total;
            }

            public void Dispose()
            {
                if (_disposed) return;

                _disposed = true;

                _reader?.Dispose();
            }
        }

        /// <summary>
        /// Averages all channels down to one. NAudio's StereoToMonoSampleProvider
        /// only handles exactly two channels, and multi-channel sources do occur.
        /// </summary>
        private sealed class MonoDownmixSampleProvider : ISampleProvider
        {
            private readonly ISampleProvider _source;

            private readonly int _channels;

            private float[] _sourceBuffer = [];

            public MonoDownmixSampleProvider(ISampleProvider source)
            {
                _source = source;

                _channels = source.WaveFormat.Channels;

                WaveFormat = WaveFormat.CreateIeeeFloatWaveFormat(
                    source.WaveFormat.SampleRate, 1);
            }

            public WaveFormat WaveFormat { get; }

            public int Read(Span<float> buffer)
            {
                var needed = buffer.Length * _channels;

                if (_sourceBuffer.Length < needed)
                {
                    _sourceBuffer = new float[needed];
                }

                var read = _source.Read(_sourceBuffer.AsSpan(0, needed));

                var frames = read / _channels;

                for (var frame = 0; frame < frames; frame++)
                {
                    var sum = 0f;

                    for (var channel = 0; channel < _channels; channel++)
                    {
                        sum += _sourceBuffer[frame * _channels + channel];
                    }

                    buffer[frame] = sum / _channels;
                }

                return frames;
            }
        }
    }
}
