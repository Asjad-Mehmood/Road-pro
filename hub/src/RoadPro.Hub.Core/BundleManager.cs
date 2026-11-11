using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using System.Security.Cryptography;

namespace RoadPro.Hub.Core
{
    public sealed class OperationResult
    {
        public bool Success { get; }
        public string Message { get; }
        public Version Version { get; }

        private OperationResult(bool ok, string message, Version version)
        {
            Success = ok;
            Message = message;
            Version = version;
        }

        public static OperationResult Ok(string message, Version version = null) => new OperationResult(true, message, version);
        public static OperationResult Fail(string message) => new OperationResult(false, message, null);
        public override string ToString() => (Success ? "OK: " : "FAILED: ") + Message;
    }

    /// <summary>
    /// Installs, updates, repairs and removes RoadPro.bundle in an Autodesk
    /// ApplicationPlugins folder. Every change is staged next to the target,
    /// verified, and the previous bundle is kept as a backup so it can be
    /// restored if anything goes wrong.
    /// </summary>
    public sealed class BundleManager
    {
        public const int BackupsToKeep = 3;

        private readonly string _pluginsRoot;
        private readonly string _backupRoot;
        private readonly Logger _log;

        public BundleManager(string pluginsRoot, string backupRoot, Logger log = null)
        {
            _pluginsRoot = pluginsRoot ?? throw new ArgumentNullException(nameof(pluginsRoot));
            _backupRoot = backupRoot ?? throw new ArgumentNullException(nameof(backupRoot));
            _log = log ?? Logger.None;
        }

        public string TargetPath => Path.Combine(_pluginsRoot, BundleInfo.BundleFolderName);
        public string BackupRoot => _backupRoot;

        public BundleInfo GetInstalled() => BundleInfo.TryRead(TargetPath);

        /// <summary>A damaged install: the folder is there but the manifest or plugin is missing.</summary>
        public bool IsDamaged => Directory.Exists(TargetPath) && GetInstalled() == null;

        /// <summary>Install, update or repair from a source bundle folder.</summary>
        public OperationResult Install(string sourceBundle)
        {
            var src = BundleInfo.TryRead(sourceBundle);
            if (src == null)
                return OperationResult.Fail("The RoadPro files in the setup are missing or damaged. Please download the setup again.");

            var before = GetInstalled();
            string staging = TargetPath + ".new-" + Guid.NewGuid().ToString("N").Substring(0, 8);
            string backup = null;
            try
            {
                Directory.CreateDirectory(_pluginsRoot);
                _log.Info($"Install {src.Version} from {sourceBundle} to {TargetPath} (installed: {before?.Version.ToString() ?? "none"})");

                // 1. stage a full copy and check every byte
                CopyDirectory(sourceBundle, staging);
                var bad = FirstDifference(sourceBundle, staging);
                if (bad != null)
                {
                    SafeDelete(staging);
                    return OperationResult.Fail("Copy check failed on " + bad + ". Nothing was changed.");
                }

                // 2. move the current bundle aside as a backup
                if (Directory.Exists(TargetPath))
                {
                    backup = NewBackupPath(before?.Version);
                    MoveDirectory(TargetPath, backup);
                    StampBackup(backup);
                    _log.Info("Backup: " + backup);
                }

                // 3. put the staged bundle in place
                Directory.Move(staging, TargetPath);

                var now = GetInstalled();
                if (now == null || now.Version != src.Version)
                    throw new IOException("The installed bundle could not be read back.");

                PruneBackups();
                string verb = before == null ? "installed" : before.Version < src.Version ? "updated" : before.Version == src.Version ? "repaired" : "replaced";
                _log.Info($"RoadPro {src.Version} {verb}");
                return OperationResult.Ok($"RoadPro {src.FriendlyVersion} {verb}. It loads the next time AutoCAD starts.", src.Version);
            }
            catch (Exception ex)
            {
                _log.Error("Install failed", ex);
                SafeDelete(staging);
                // roll back to what was there before
                if (backup != null && Directory.Exists(backup))
                {
                    try
                    {
                        SafeDelete(TargetPath);
                        MoveDirectory(backup, TargetPath);
                        _log.Info("Rolled back to the previous bundle");
                    }
                    catch (Exception rex)
                    {
                        _log.Error("Rollback failed", rex);
                    }
                }
                return OperationResult.Fail("Install failed: " + ex.Message + (backup != null ? " The previous version was kept." : ""));
            }
        }

        /// <summary>Remove the bundle; a backup copy is kept so it can be restored.</summary>
        public OperationResult Uninstall()
        {
            if (!Directory.Exists(TargetPath))
                return OperationResult.Ok("RoadPro is not installed.");
            try
            {
                var before = GetInstalled();
                var backup = NewBackupPath(before?.Version);
                MoveDirectory(TargetPath, backup);
                StampBackup(backup);
                PruneBackups();
                _log.Info("Uninstalled; backup " + backup);
                return OperationResult.Ok("RoadPro was removed. Restart AutoCAD to unload it.", before?.Version);
            }
            catch (Exception ex)
            {
                _log.Error("Uninstall failed", ex);
                return OperationResult.Fail("Could not remove RoadPro: " + ex.Message + " Close AutoCAD and try again.");
            }
        }

        /// <summary>Backups, newest first.</summary>
        public IList<string> ListBackups()
        {
            if (!Directory.Exists(_backupRoot)) return new List<string>();
            return Directory.GetDirectories(_backupRoot, BundleInfo.BundleFolderName + "_*")
                            .OrderByDescending(d => Directory.GetCreationTimeUtc(d))
                            .ThenByDescending(d => d, StringComparer.Ordinal)
                            .ToList();
        }

        /// <summary>Put the newest backup back in place (the current bundle becomes a backup).</summary>
        public OperationResult RestoreLatestBackup()
        {
            var latest = ListBackups().FirstOrDefault(b => BundleInfo.TryRead(b) != null);
            if (latest == null) return OperationResult.Fail("There is no backup to restore.");
            var info = BundleInfo.TryRead(latest);
            string staging = TargetPath + ".restore-" + Guid.NewGuid().ToString("N").Substring(0, 8);
            try
            {
                CopyDirectory(latest, staging);
                SafeDelete(latest);
                if (Directory.Exists(TargetPath))
                {
                    var b = NewBackupPath(GetInstalled()?.Version);
                    MoveDirectory(TargetPath, b);
                    StampBackup(b);
                }
                Directory.Move(staging, TargetPath);
                PruneBackups();
                return OperationResult.Ok($"RoadPro {info.FriendlyVersion} restored.", info.Version);
            }
            catch (Exception ex)
            {
                SafeDelete(staging);
                _log.Error("Restore failed", ex);
                return OperationResult.Fail("Restore failed: " + ex.Message);
            }
        }

        // ------------------------------------------------------------------ helpers

        private string NewBackupPath(Version v)
        {
            Directory.CreateDirectory(_backupRoot);
            string name = $"{BundleInfo.BundleFolderName}_{(v == null ? "unknown" : v.ToString())}_{DateTime.Now:yyyyMMdd-HHmmss}";
            string path = Path.Combine(_backupRoot, name);
            int i = 1;
            while (Directory.Exists(path)) path = Path.Combine(_backupRoot, name + "-" + i++);
            return path;
        }

        /// <summary>A moved folder keeps its old creation time; stamp it so backups sort by backup time.</summary>
        private static void StampBackup(string path)
        {
            try { Directory.SetCreationTimeUtc(path, DateTime.UtcNow); } catch (Exception) { }
        }

        private void PruneBackups()
        {
            foreach (var old in ListBackups().Skip(BackupsToKeep))
                SafeDelete(old);
        }

        internal static void CopyDirectory(string from, string to)
        {
            Directory.CreateDirectory(to);
            foreach (var dir in Directory.GetDirectories(from, "*", SearchOption.AllDirectories))
                Directory.CreateDirectory(Path.Combine(to, Relative(from, dir)));
            foreach (var file in Directory.GetFiles(from, "*", SearchOption.AllDirectories))
            {
                var dest = Path.Combine(to, Relative(from, file));
                File.Copy(file, dest, true);
                File.SetAttributes(dest, FileAttributes.Normal);
            }
        }

        /// <summary>Move a folder; falls back to copy + delete across drives.</summary>
        internal static void MoveDirectory(string from, string to)
        {
            try
            {
                Directory.Move(from, to);
            }
            catch (IOException)
            {
                CopyDirectory(from, to);
                SafeDelete(from);
                if (Directory.Exists(from)) throw;
            }
        }

        /// <summary>Relative path of the first file that differs, or null when both trees match.</summary>
        internal static string FirstDifference(string a, string b)
        {
            var fa = Directory.GetFiles(a, "*", SearchOption.AllDirectories).Select(f => Relative(a, f)).OrderBy(x => x, StringComparer.OrdinalIgnoreCase).ToList();
            var fb = Directory.GetFiles(b, "*", SearchOption.AllDirectories).Select(f => Relative(b, f)).OrderBy(x => x, StringComparer.OrdinalIgnoreCase).ToList();
            if (fa.Count != fb.Count) return "(file count)";
            for (int i = 0; i < fa.Count; i++)
            {
                if (!string.Equals(fa[i], fb[i], StringComparison.OrdinalIgnoreCase)) return fa[i];
                if (!SameFile(Path.Combine(a, fa[i]), Path.Combine(b, fb[i]))) return fa[i];
            }
            return null;
        }

        private static bool SameFile(string x, string y)
        {
            var ix = new FileInfo(x);
            var iy = new FileInfo(y);
            if (ix.Length != iy.Length) return false;
            using (var sha = SHA256.Create())
            {
                byte[] hx, hy;
                using (var s = File.OpenRead(x)) hx = sha.ComputeHash(s);
                using (var s = File.OpenRead(y)) hy = sha.ComputeHash(s);
                return hx.SequenceEqual(hy);
            }
        }

        private static string Relative(string root, string path)
        {
            var r = Path.GetFullPath(root).TrimEnd(Path.DirectorySeparatorChar, Path.AltDirectorySeparatorChar) + Path.DirectorySeparatorChar;
            var p = Path.GetFullPath(path);
            return p.StartsWith(r, StringComparison.OrdinalIgnoreCase) ? p.Substring(r.Length) : p;
        }

        internal static void SafeDelete(string dir)
        {
            try
            {
                if (string.IsNullOrEmpty(dir) || !Directory.Exists(dir)) return;
                foreach (var f in Directory.GetFiles(dir, "*", SearchOption.AllDirectories))
                    File.SetAttributes(f, FileAttributes.Normal);
                Directory.Delete(dir, true);
            }
            catch (Exception)
            {
                // best effort; a later run cleans it
            }
        }
    }
}
