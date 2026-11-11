using System;
using System.Globalization;
using System.IO;
using System.Linq;
using System.Net;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Security.Cryptography;
using System.Text;
using System.Threading;
using System.Threading.Tasks;

namespace RoadPro.Hub.Core
{
    /// <summary>Downloads text and files (abstracted so the update flow can be tested).</summary>
    public interface IDownloader
    {
        string GetText(string url);
        Task DownloadFileAsync(string url, string path, IProgress<double> progress, CancellationToken cancel);
    }

    /// <summary>WebClient based downloader: https (TLS 1.2+), redirects, file:// for tests.</summary>
    public sealed class WebDownloader : IDownloader
    {
        public const string UserAgent = "RoadProHub";

        private static WebClient NewClient()
        {
            var wc = new WebClient { Encoding = Encoding.UTF8 };
            wc.Headers[HttpRequestHeader.UserAgent] = UserAgent + "/" + typeof(WebDownloader).Assembly.GetName().Version;
            wc.Headers[HttpRequestHeader.CacheControl] = "no-cache";
            return wc;
        }

        public string GetText(string url)
        {
            using (var wc = NewClient()) return wc.DownloadString(url);
        }

        public async Task DownloadFileAsync(string url, string path, IProgress<double> progress, CancellationToken cancel)
        {
            using (var wc = NewClient())
            using (cancel.Register(wc.CancelAsync))
            {
                if (progress != null)
                    wc.DownloadProgressChanged += (s, e) =>
                    {
                        if (e.TotalBytesToReceive > 0) progress.Report((double)e.BytesReceived / e.TotalBytesToReceive);
                    };
                try
                {
                    await wc.DownloadFileTaskAsync(new Uri(url), path).ConfigureAwait(false);
                }
                catch (WebException ex) when (ex.Status == WebExceptionStatus.RequestCanceled)
                {
                    throw new OperationCanceledException(cancel);
                }
            }
            progress?.Report(1.0);
        }
    }

    /// <summary>What the Hub remembers between update checks (update-state.json).</summary>
    [DataContract]
    public sealed class UpdateState
    {
        [DataMember(Name = "lastCheckUtc", Order = 1, EmitDefaultValue = false)] public string LastCheckUtc { get; set; }
        [DataMember(Name = "skippedVersion", Order = 2, EmitDefaultValue = false)] public string SkippedVersion { get; set; }
        [DataMember(Name = "availableVersion", Order = 3, EmitDefaultValue = false)] public string AvailableVersion { get; set; }

        [IgnoreDataMember]
        public DateTime? LastCheck
        {
            get => DateTime.TryParse(LastCheckUtc, CultureInfo.InvariantCulture, DateTimeStyles.AdjustToUniversal | DateTimeStyles.AssumeUniversal, out var d) ? d : (DateTime?)null;
            set => LastCheckUtc = value?.ToUniversalTime().ToString("o", CultureInfo.InvariantCulture);
        }
    }

    public enum UpdateStatus
    {
        UpToDate,
        Available,
        Skipped,
        Failed
    }

    public sealed class UpdateCheckResult
    {
        public UpdateStatus Status { get; }
        public UpdateManifest Manifest { get; }
        public string Message { get; }

        public UpdateCheckResult(UpdateStatus status, UpdateManifest manifest, string message)
        {
            Status = status;
            Manifest = manifest;
            Message = message;
        }
    }

    /// <summary>
    /// Checks GitHub Releases (update.json) for a newer RoadPro, downloads the
    /// setup, verifies its size and SHA-256 and tells the Hub how to run it.
    /// Also writes update-available.txt so the AutoCAD plugin can show a notice.
    /// </summary>
    public sealed class UpdateService
    {
        public const string DefaultManifestUrl = "https://github.com/Asjad-Mehmood/Road-pro/releases/latest/download/update.json";
        public static readonly TimeSpan AutoCheckInterval = TimeSpan.FromHours(20);

        private readonly IDownloader _dl;
        private readonly Logger _log;
        private readonly string _dataRoot;

        public string ManifestUrl { get; }
        public Version CurrentVersion { get; }
        public string StateFile => Path.Combine(_dataRoot, "update-state.json");
        /// <summary>Read by RoadPro.lsp at load: line 1 = the new version.</summary>
        public string NoticeFile => Path.Combine(_dataRoot, "update-available.txt");
        public string DownloadDir => Path.Combine(_dataRoot, "updates");

        public UpdateService(Version current, string dataRoot, IDownloader downloader, string manifestUrl = null, Logger log = null)
        {
            CurrentVersion = current ?? throw new ArgumentNullException(nameof(current));
            _dataRoot = dataRoot ?? throw new ArgumentNullException(nameof(dataRoot));
            _dl = downloader ?? throw new ArgumentNullException(nameof(downloader));
            ManifestUrl = string.IsNullOrWhiteSpace(manifestUrl) ? DefaultManifestUrl : manifestUrl.Trim();
            _log = log ?? Logger.None;
        }

        // ------------------------------------------------------------------ state

        public UpdateState LoadState()
        {
            try
            {
                if (!File.Exists(StateFile)) return new UpdateState();
                var ser = new DataContractJsonSerializer(typeof(UpdateState));
                using (var fs = File.OpenRead(StateFile)) return (UpdateState)ser.ReadObject(fs) ?? new UpdateState();
            }
            catch (Exception ex)
            {
                _log.Warn("update-state.json unreadable: " + ex.Message);
                return new UpdateState();
            }
        }

        public void SaveState(UpdateState state)
        {
            try
            {
                Directory.CreateDirectory(_dataRoot);
                var ser = new DataContractJsonSerializer(typeof(UpdateState));
                using (var ms = new MemoryStream())
                {
                    ser.WriteObject(ms, state);
                    File.WriteAllBytes(StateFile, ms.ToArray());
                }
            }
            catch (Exception ex)
            {
                _log.Warn("update-state.json not saved: " + ex.Message);
            }
        }

        /// <summary>The Windows start-up check runs at most once every 20 hours.</summary>
        public bool IsAutoCheckDue(DateTime utcNow)
        {
            var last = LoadState().LastCheck;
            return last == null || utcNow - last.Value >= AutoCheckInterval || last.Value > utcNow.AddMinutes(5);
        }

        public void Skip(UpdateManifest m)
        {
            var s = LoadState();
            s.SkippedVersion = m.Version.ToString();
            SaveState(s);
            WriteNotice(null);
        }

        // ------------------------------------------------------------------ check

        public UpdateCheckResult Check(bool honourSkip, DateTime? utcNow = null)
        {
            var state = LoadState();
            state.LastCheck = utcNow ?? DateTime.UtcNow;
            try
            {
                var m = UpdateManifest.Parse(_dl.GetText(ManifestUrl));
                if (!m.IsTrustedSource(ManifestUrl))
                    throw new UpdateException("The update download address is not trusted: " + m.SetupUrl);

                if (m.Version <= CurrentVersion)
                {
                    state.AvailableVersion = null;
                    SaveState(state);
                    WriteNotice(null);
                    return new UpdateCheckResult(UpdateStatus.UpToDate, m, $"RoadPro {VersionText.Friendly(CurrentVersion)} is up to date.");
                }

                state.AvailableVersion = m.Version.ToString();
                SaveState(state);
                bool skipped = honourSkip && state.SkippedVersion == m.Version.ToString();
                WriteNotice(skipped ? null : m);
                _log.Info($"Update {m.Version} available{(skipped ? " (skipped by the user)" : "")}");
                return new UpdateCheckResult(skipped ? UpdateStatus.Skipped : UpdateStatus.Available, m,
                    $"RoadPro {m.FriendlyVersion} is available (you have {VersionText.Friendly(CurrentVersion)}).");
            }
            catch (Exception ex)
            {
                SaveState(state);
                _log.Warn("Update check failed: " + ex.Message);
                string msg = ex is UpdateException ? ex.Message : "Could not reach the update server. Check the internet connection and try again.";
                return new UpdateCheckResult(UpdateStatus.Failed, null, msg);
            }
        }

        // ------------------------------------------------------------------ download

        /// <summary>Download the setup and verify size + SHA-256. Returns the verified file path.</summary>
        public async Task<string> DownloadAsync(UpdateManifest m, IProgress<double> progress, CancellationToken cancel)
        {
            if (!m.IsTrustedSource(ManifestUrl)) throw new UpdateException("The update download address is not trusted.");
            Directory.CreateDirectory(DownloadDir);
            foreach (var old in Directory.GetFiles(DownloadDir))
                TryDelete(old);

            string file = Path.Combine(DownloadDir, $"RoadPro_Setup_v{m.Version}.exe");
            string part = file + ".part";
            _log.Info($"Downloading {m.SetupUrl}");
            try
            {
                await _dl.DownloadFileAsync(m.SetupUrl, part, progress, cancel).ConfigureAwait(false);
            }
            catch (OperationCanceledException)
            {
                TryDelete(part);
                throw;
            }
            catch (Exception ex)
            {
                TryDelete(part);
                throw new UpdateException("The download failed: " + ex.Message);
            }

            var len = new FileInfo(part).Length;
            if (len != m.Size)
            {
                TryDelete(part);
                throw new UpdateException($"The download is incomplete ({len:N0} of {m.Size:N0} bytes). Please try again.");
            }
            var hash = Sha256Of(part);
            if (!string.Equals(hash, m.Sha256.Trim(), StringComparison.OrdinalIgnoreCase))
            {
                TryDelete(part);
                throw new UpdateException("The downloaded file failed the security check (SHA-256 does not match). It was deleted.");
            }
            File.Move(part, file);
            _log.Info($"Downloaded and verified {file} ({len:N0} bytes, SHA-256 {hash})");
            return file;
        }

        /// <summary>Arguments for the downloaded Inno Setup: quiet update, progress shown.</summary>
        public static string SetupArguments(bool relaunchHub, string logFile = null)
        {
            var a = "/SILENT /SUPPRESSMSGBOXES /NORESTART /CLOSEAPPLICATIONS /SP-";
            if (relaunchHub) a += " /RELAUNCH=1";
            if (!string.IsNullOrEmpty(logFile)) a += " \"/LOG=" + logFile + "\"";
            return a;
        }

        public static string Sha256Of(string file)
        {
            using (var sha = SHA256.Create())
            using (var fs = File.OpenRead(file))
                return string.Concat(sha.ComputeHash(fs).Select(b => b.ToString("x2", CultureInfo.InvariantCulture)));
        }

        // ------------------------------------------------------------------ notice for AutoCAD

        /// <summary>Writes (or removes) update-available.txt for RoadPro.lsp.</summary>
        public void WriteNotice(UpdateManifest m)
        {
            try
            {
                if (m == null)
                {
                    TryDelete(NoticeFile);
                    return;
                }
                Directory.CreateDirectory(_dataRoot);
                File.WriteAllText(NoticeFile, VersionText.Friendly(m.Version) + Environment.NewLine + (m.Released ?? "") + Environment.NewLine, new UTF8Encoding(false));
            }
            catch (Exception ex)
            {
                _log.Warn("update notice not written: " + ex.Message);
            }
        }

        private static void TryDelete(string f)
        {
            try { if (File.Exists(f)) File.Delete(f); } catch (Exception) { }
        }
    }
}
