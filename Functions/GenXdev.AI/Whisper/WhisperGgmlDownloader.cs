namespace GenXdev.AI.Whisper
{
    /// <summary>
    /// Fetches ggml Whisper models from the ggerganov/whisper.cpp HuggingFace
    /// repository - the same source whisper.cpp's own download-ggml-model script
    /// uses.
    /// </summary>
    public sealed class WhisperGgmlDownloader
    {
        private const string BaseUrl =
            "https://huggingface.co/ggerganov/whisper.cpp/resolve/main";

        private static readonly HttpClient _httpClient = CreateClient();

        public static WhisperGgmlDownloader Default { get; } =
            new WhisperGgmlDownloader();

        private WhisperGgmlDownloader() { }

        private static HttpClient CreateClient()
        {
            var client = new HttpClient
            {
                // Models run to gigabytes on a slow link, so no request timeout;
                // cancellation is what stops a download.
                Timeout = Timeout.InfiniteTimeSpan
            };

            client.DefaultRequestHeaders.UserAgent.ParseAdd("GenXdev.PowerShell");

            return client;
        }

        /// <summary>
        /// Opens a stream over the model file for the given type.
        /// </summary>
        public static async Task<Stream> GetGgmlModelAsync(
            GgmlType modelType,
            CancellationToken cancellationToken = default)
        {
            var url = $"{BaseUrl}/{modelType.ToModelFileName()}";

            var response = await _httpClient.GetAsync(
                url,
                HttpCompletionOption.ResponseHeadersRead,
                cancellationToken).ConfigureAwait(false);

            if (!response.IsSuccessStatusCode)
            {
                throw new HttpRequestException(
                    $"Could not download the Whisper model " +
                    $"'{modelType.ToCanonicalName()}' from {url} - the server " +
                    $"replied {(int)response.StatusCode} {response.ReasonPhrase}.");
            }

            return await response.Content.ReadAsStreamAsync(cancellationToken)
                .ConfigureAwait(false);
        }

        /// <summary>
        /// Downloads a model to disk, reporting progress as a percentage.
        ///
        /// The download lands in a temporary file that is only moved into place
        /// once it completes, so an interrupted download can never leave a
        /// half-written model that would fail to load on the next run.
        /// </summary>
        public static async Task DownloadModelAsync(
            GgmlType modelType,
            string destinationPath,
            Action<int> progress = null,
            CancellationToken cancellationToken = default)
        {
            var url = $"{BaseUrl}/{modelType.ToModelFileName()}";

            using var response = await _httpClient.GetAsync(
                url,
                HttpCompletionOption.ResponseHeadersRead,
                cancellationToken).ConfigureAwait(false);

            if (!response.IsSuccessStatusCode)
            {
                throw new HttpRequestException(
                    $"Could not download the Whisper model " +
                    $"'{modelType.ToCanonicalName()}' from {url} - the server " +
                    $"replied {(int)response.StatusCode} {response.ReasonPhrase}.");
            }

            var totalBytes = response.Content.Headers.ContentLength ?? -1L;

            var tempPath = destinationPath + ".download";

            try
            {
                using (var source = await response.Content
                    .ReadAsStreamAsync(cancellationToken).ConfigureAwait(false))
                using (var target = new FileStream(
                    tempPath, FileMode.Create, FileAccess.Write, FileShare.None,
                    81920, useAsync: true))
                {
                    var buffer = new byte[81920];

                    long copied = 0;

                    var lastReported = -1;

                    int read;

                    while ((read = await source
                        .ReadAsync(buffer, cancellationToken)
                        .ConfigureAwait(false)) > 0)
                    {
                        await target.WriteAsync(
                            buffer.AsMemory(0, read), cancellationToken)
                            .ConfigureAwait(false);

                        copied += read;

                        if (progress != null && totalBytes > 0)
                        {
                            var percent = (int)(copied * 100 / totalBytes);

                            if (percent != lastReported)
                            {
                                lastReported = percent;

                                progress(percent);
                            }
                        }
                    }
                }

                if (File.Exists(destinationPath))
                {
                    File.Delete(destinationPath);
                }

                int retries = 5;
                while (true) try {

                    File.Move(tempPath, destinationPath, true);
                    break;
                }
                catch {

                    if (--retries <= 0) throw new Exception($"Could not move file {tempPath} -> {destinationPath} after 5 retries");
                    await Task.Delay(400, cancellationToken);
                }
            }
            catch
            {
                TryDelete(tempPath);

                throw;
            }
        }

        private static void TryDelete(string path)
        {
            try
            {
                if (File.Exists(path)) File.Delete(path);
            }
            catch
            {
                // Best effort - a stray .download file is harmless.
            }
        }
    }
}
