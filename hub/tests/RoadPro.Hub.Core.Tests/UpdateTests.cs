using System;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using RoadPro.Hub.Core;
using Xunit;

namespace RoadPro.Hub.Core.Tests
{
    /// <summary>A fake release: setup file + update.json in a temp folder, read through file:// URLs.</summary>
    public sealed class FakeRelease : IDisposable
    {
        public string Root { get; } = Path.Combine(Path.GetTempPath(), "rpupd-" + Guid.NewGuid().ToString("N"));
        public string Data => Path.Combine(Root, "data");
        public string SetupPath => Path.Combine(Root, "release", "RoadPro_Setup_v3.7.0.exe");
        public string ManifestPath => Path.Combine(Root, "release", "update.json");
        public string ManifestUrl => new Uri(ManifestPath).AbsoluteUri;

        public FakeRelease(string version = "3.7.0", Action<UpdateManifest> tweak = null)
        {
            Directory.CreateDirectory(Path.GetDirectoryName(SetupPath));
            var bytes = new byte[200_000];
            new Random(7).NextBytes(bytes);
            File.WriteAllBytes(SetupPath, bytes);
            var m = new UpdateManifest
            {
                VersionText = version,
                Released = "2026-11-12",
                SetupUrl = new Uri(SetupPath).AbsoluteUri,
                Sha256 = UpdateService.Sha256Of(SetupPath),
                Size = bytes.Length,
                Notes = "Test release"
            };
            tweak?.Invoke(m);
            File.WriteAllText(ManifestPath, m.ToJson());
        }

        public UpdateService Service(string current = "3.6.1") =>
            new UpdateService(VersionText.Parse(current), Data, new WebDownloader(), ManifestUrl, new Logger(Path.Combine(Root, "log.txt")));

        public void Dispose()
        {
            try { Directory.Delete(Root, true); } catch { }
        }
    }

    public class ManifestTests
    {
        const string Good = "{\"version\":\"3.6.1\",\"released\":\"2026-11-12\",\"setupUrl\":\"https://github.com/Asjad-Mehmood/Road-pro/releases/download/v3.6.1/RoadPro_Setup_v3.6.1.exe\"," +
                            "\"sha256\":\"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef\",\"size\":8584053,\"notes\":\"x\"}";

        [Fact]
        public void Parses_a_github_manifest()
        {
            var m = UpdateManifest.Parse(Good);
            Assert.Equal(new Version(3, 6, 1), m.Version);
            Assert.Equal(8584053, m.Size);
            Assert.True(m.IsTrustedSource(UpdateService.DefaultManifestUrl));
        }

        [Fact]
        public void Round_trips_to_json()
        {
            var m = UpdateManifest.Parse(Good);
            var again = UpdateManifest.Parse(m.ToJson());
            Assert.Equal(m.Sha256, again.Sha256);
            Assert.Equal(m.SetupUrl, again.SetupUrl);
        }

        [Theory]
        [InlineData("")]
        [InlineData("not json")]
        [InlineData("{\"version\":\"abc\",\"setupUrl\":\"https://github.com/a.exe\",\"sha256\":\"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef\",\"size\":1}")]
        [InlineData("{\"version\":\"3.7\",\"setupUrl\":\"https://github.com/a.exe\",\"sha256\":\"short\",\"size\":1}")]
        [InlineData("{\"version\":\"3.7\",\"setupUrl\":\"http://github.com/a.exe\",\"sha256\":\"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef\",\"size\":1}")]
        [InlineData("{\"version\":\"3.7\",\"setupUrl\":\"https://github.com/a.exe\",\"sha256\":\"0123456789abcdef0123456789abcdef0123456789abcdef0123456789abcdef\",\"size\":0}")]
        public void Rejects_bad_manifests(string json) => Assert.Throws<UpdateException>(() => UpdateManifest.Parse(json));

        [Fact]
        public void Untrusted_host_is_refused()
        {
            var m = UpdateManifest.Parse(Good.Replace("github.com", "evil.example.com"));
            Assert.False(m.IsTrustedSource(UpdateService.DefaultManifestUrl));
        }

        [Fact]
        public void Local_setup_only_with_local_manifest()
        {
            var m = UpdateManifest.Parse(Good.Replace("https://github.com/Asjad-Mehmood/Road-pro/releases/download/v3.6.1/", "file:///C:/temp/"));
            Assert.False(m.IsTrustedSource(UpdateService.DefaultManifestUrl));
            Assert.True(m.IsTrustedSource("file:///C:/temp/update.json"));
        }
    }

    public class UpdateServiceTests
    {
        [Fact]
        public void Newer_release_is_available_and_notice_written()
        {
            using var r = new FakeRelease("3.7.0");
            var s = r.Service("3.6.1");
            var c = s.Check(true);
            Assert.Equal(UpdateStatus.Available, c.Status);
            Assert.Equal(new Version(3, 7, 0), c.Manifest.Version);
            Assert.Equal("3.7", File.ReadAllLines(s.NoticeFile)[0]);
            Assert.Equal("3.7.0", s.LoadState().AvailableVersion);
        }

        [Fact]
        public void Same_or_older_release_is_up_to_date_and_notice_removed()
        {
            using var r = new FakeRelease("3.6.1");
            var s = r.Service("3.6.1");
            s.WriteNotice(UpdateManifest.Parse(File.ReadAllText(r.ManifestPath)));
            var c = s.Check(true);
            Assert.Equal(UpdateStatus.UpToDate, c.Status);
            Assert.False(File.Exists(s.NoticeFile));
        }

        [Fact]
        public void Skipped_version_is_quiet_but_manual_check_still_shows_it()
        {
            using var r = new FakeRelease("3.7.0");
            var s = r.Service();
            var c = s.Check(true);
            s.Skip(c.Manifest);
            Assert.Equal(UpdateStatus.Skipped, s.Check(true).Status);
            Assert.False(File.Exists(s.NoticeFile));
            Assert.Equal(UpdateStatus.Available, s.Check(false).Status);
        }

        [Fact]
        public void Offline_is_a_soft_failure()
        {
            var data = Path.Combine(Path.GetTempPath(), "rpupd-" + Guid.NewGuid().ToString("N"));
            var s = new UpdateService(new Version(3, 6, 1), data, new WebDownloader(), new Uri(Path.Combine(data, "missing", "update.json")).AbsoluteUri);
            var c = s.Check(true);
            Assert.Equal(UpdateStatus.Failed, c.Status);
            Assert.Contains("internet", c.Message);
            Assert.NotNull(s.LoadState().LastCheck);
        }

        [Fact]
        public void Auto_check_runs_once_per_20_hours()
        {
            using var r = new FakeRelease();
            var s = r.Service();
            var now = new DateTime(2026, 11, 12, 8, 0, 0, DateTimeKind.Utc);
            Assert.True(s.IsAutoCheckDue(now));
            s.Check(true, now);
            Assert.False(s.IsAutoCheckDue(now.AddHours(5)));
            Assert.True(s.IsAutoCheckDue(now.AddHours(21)));
            Assert.True(s.IsAutoCheckDue(now.AddDays(-1)));   // clock moved back
        }

        [Fact]
        public async Task Download_verifies_and_keeps_the_file()
        {
            using var r = new FakeRelease();
            var s = r.Service();
            var c = s.Check(true);
            double last = 0;
            var file = await s.DownloadAsync(c.Manifest, new Progress<double>(p => last = p), CancellationToken.None);
            Assert.True(File.Exists(file));
            Assert.Equal(UpdateService.Sha256Of(r.SetupPath), UpdateService.Sha256Of(file));
            Assert.EndsWith("RoadPro_Setup_v3.7.0.exe", file);
        }

        [Fact]
        public async Task Tampered_download_is_deleted()
        {
            using var r = new FakeRelease();
            var s = r.Service();
            var c = s.Check(true);
            File.AppendAllText(r.SetupPath, "x");               // file changed after publishing
            await Assert.ThrowsAsync<UpdateException>(() => s.DownloadAsync(c.Manifest, null, CancellationToken.None));
            Assert.Empty(Directory.GetFiles(s.DownloadDir));
        }

        [Fact]
        public async Task Wrong_hash_is_refused()
        {
            using var r = new FakeRelease(tweak: m => m.Sha256 = new string('a', 64));
            var s = r.Service();
            var c = s.Check(true);
            var ex = await Assert.ThrowsAsync<UpdateException>(() => s.DownloadAsync(c.Manifest, null, CancellationToken.None));
            Assert.Contains("security check", ex.Message);
        }

        [Fact]
        public void Setup_arguments()
        {
            Assert.Contains("/SILENT", UpdateService.SetupArguments(true));
            Assert.Contains("/RELAUNCH=1", UpdateService.SetupArguments(true));
            Assert.DoesNotContain("/RELAUNCH", UpdateService.SetupArguments(false));
        }
    }
}
