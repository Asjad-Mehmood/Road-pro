using System;
using System.IO;
using System.Linq;
using RoadPro.Hub.Core;
using Xunit;

namespace RoadPro.Hub.Core.Tests
{
    /// <summary>Each test gets its own temp folder with a fake ApplicationPlugins and backup root.</summary>
    public sealed class Sandbox : IDisposable
    {
        public string Root { get; } = Path.Combine(Path.GetTempPath(), "rphub-" + Guid.NewGuid().ToString("N"));
        public string Plugins => Path.Combine(Root, "ApplicationPlugins");
        public string Backups => Path.Combine(Root, "backup");
        public string RepoBundle => Path.Combine(AppContext.BaseDirectory, "TestBundle", "RoadPro.bundle");

        public Sandbox() { Directory.CreateDirectory(Root); }

        public BundleManager Manager() => new BundleManager(Plugins, Backups, new Logger(Path.Combine(Root, "log.txt")));

        /// <summary>A copy of the real bundle with its version changed.</summary>
        public string BundleVersion(string version, string marker = null)
        {
            var dir = Path.Combine(Root, "src-" + version + "-" + Guid.NewGuid().ToString("N").Substring(0, 6), "RoadPro.bundle");
            Copy(RepoBundle, dir);
            var pc = Path.Combine(dir, "PackageContents.xml");
            var xml = File.ReadAllText(pc);
            xml = System.Text.RegularExpressions.Regex.Replace(xml, "AppVersion=\"[^\"]+\"", $"AppVersion=\"{version}\"");
            File.WriteAllText(pc, xml);
            if (marker != null) File.WriteAllText(Path.Combine(dir, "Contents", "marker.txt"), marker);
            return dir;
        }

        public static void Copy(string from, string to)
        {
            Directory.CreateDirectory(to);
            foreach (var d in Directory.GetDirectories(from, "*", SearchOption.AllDirectories))
                Directory.CreateDirectory(d.Replace(from, to));
            foreach (var f in Directory.GetFiles(from, "*", SearchOption.AllDirectories))
                File.Copy(f, f.Replace(from, to), true);
        }

        public void Dispose()
        {
            try { Directory.Delete(Root, true); } catch { }
        }
    }

    public class BundleManagerTests
    {
        [Fact]
        public void Repo_bundle_is_valid_and_matches_version_txt()
        {
            using var s = new Sandbox();
            var info = BundleInfo.TryRead(s.RepoBundle);
            Assert.NotNull(info);
            var versionTxt = File.ReadAllText(Path.Combine(AppContext.BaseDirectory, "..", "..", "..", "..", "..", "..", "version.txt")).Trim();
            Assert.Equal(VersionText.Parse(versionTxt), info.Version);
        }

        [Fact]
        public void Fresh_install_copies_the_bundle()
        {
            using var s = new Sandbox();
            var m = s.Manager();
            Assert.Null(m.GetInstalled());
            var r = m.Install(s.RepoBundle);
            Assert.True(r.Success, r.Message);
            Assert.Contains("installed", r.Message);
            Assert.NotNull(m.GetInstalled());
            Assert.True(File.Exists(Path.Combine(m.TargetPath, "Contents", "RoadPro.lsp")));
            Assert.Empty(m.ListBackups());
            Assert.DoesNotContain(Directory.GetDirectories(s.Plugins), d => !d.EndsWith("RoadPro.bundle"));
        }

        [Fact]
        public void Update_from_older_version_keeps_a_backup()
        {
            using var s = new Sandbox();
            var m = s.Manager();
            Assert.True(m.Install(s.BundleVersion("3.5.0", "old")).Success);
            var r = m.Install(s.BundleVersion("3.6.0", "new"));
            Assert.True(r.Success, r.Message);
            Assert.Contains("updated", r.Message);
            Assert.Equal(new Version(3, 6, 0), m.GetInstalled().Version);
            Assert.Equal("new", File.ReadAllText(Path.Combine(m.TargetPath, "Contents", "marker.txt")));
            var b = Assert.Single(m.ListBackups());
            Assert.Equal(new Version(3, 5, 0), BundleInfo.TryRead(b).Version);
        }

        [Fact]
        public void Repair_restores_a_deleted_plugin_file()
        {
            using var s = new Sandbox();
            var m = s.Manager();
            m.Install(s.RepoBundle);
            File.Delete(Path.Combine(m.TargetPath, "Contents", "RoadPro.lsp"));
            Assert.True(m.IsDamaged);
            Assert.Null(m.GetInstalled());
            var r = m.Install(s.RepoBundle);
            Assert.True(r.Success, r.Message);
            Assert.False(m.IsDamaged);
        }

        [Fact]
        public void Same_version_is_reported_as_repaired()
        {
            using var s = new Sandbox();
            var m = s.Manager();
            m.Install(s.RepoBundle);
            var r = m.Install(s.RepoBundle);
            Assert.Contains("repaired", r.Message);
        }

        [Fact]
        public void Damaged_source_changes_nothing()
        {
            using var s = new Sandbox();
            var m = s.Manager();
            m.Install(s.BundleVersion("3.5.0", "old"));
            var bad = s.BundleVersion("3.6.0");
            File.Delete(Path.Combine(bad, "Contents", "RoadPro.lsp"));
            var r = m.Install(bad);
            Assert.False(r.Success);
            Assert.Equal(new Version(3, 5, 0), m.GetInstalled().Version);
            Assert.Equal("old", File.ReadAllText(Path.Combine(m.TargetPath, "Contents", "marker.txt")));
            Assert.DoesNotContain(Directory.GetDirectories(s.Plugins), d => !d.EndsWith("RoadPro.bundle"));
        }

        [Fact]
        public void Uninstall_removes_and_keeps_backup_then_restore_brings_it_back()
        {
            using var s = new Sandbox();
            var m = s.Manager();
            m.Install(s.RepoBundle);
            var r = m.Uninstall();
            Assert.True(r.Success, r.Message);
            Assert.False(Directory.Exists(m.TargetPath));
            Assert.Single(m.ListBackups());
            var rr = m.RestoreLatestBackup();
            Assert.True(rr.Success, rr.Message);
            Assert.NotNull(m.GetInstalled());
        }

        [Fact]
        public void Uninstall_when_not_installed_is_ok()
        {
            using var s = new Sandbox();
            var r = s.Manager().Uninstall();
            Assert.True(r.Success);
        }

        [Fact]
        public void Only_three_backups_are_kept()
        {
            using var s = new Sandbox();
            var m = s.Manager();
            foreach (var v in new[] { "3.1.0", "3.2.0", "3.3.0", "3.4.0", "3.5.0", "3.6.0" })
            {
                Assert.True(m.Install(s.BundleVersion(v)).Success);
                System.Threading.Thread.Sleep(20);
            }
            var backups = m.ListBackups();
            Assert.Equal(BundleManager.BackupsToKeep, backups.Count);
            var versions = backups.Select(b => BundleInfo.TryRead(b).Version.ToString()).OrderBy(x => x).ToArray();
            Assert.Equal(new[] { "3.3.0", "3.4.0", "3.5.0" }, versions);
        }

        [Fact]
        public void Restore_after_update_goes_back_to_previous_version()
        {
            using var s = new Sandbox();
            var m = s.Manager();
            m.Install(s.BundleVersion("3.5.0"));
            m.Install(s.BundleVersion("3.6.0"));
            var r = m.RestoreLatestBackup();
            Assert.True(r.Success, r.Message);
            Assert.Equal(new Version(3, 5, 0), m.GetInstalled().Version);
        }

        [Fact]
        public void Read_only_files_in_old_bundle_do_not_block_update()
        {
            using var s = new Sandbox();
            var m = s.Manager();
            m.Install(s.BundleVersion("3.5.0"));
            File.SetAttributes(Path.Combine(m.TargetPath, "Contents", "RoadPro.lsp"), FileAttributes.ReadOnly);
            var r = m.Install(s.BundleVersion("3.6.0"));
            Assert.True(r.Success, r.Message);
            r = m.Uninstall();
            Assert.True(r.Success, r.Message);
        }
    }
}
