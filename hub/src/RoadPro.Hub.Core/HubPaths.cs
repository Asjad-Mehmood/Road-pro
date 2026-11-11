using System;
using System.IO;

namespace RoadPro.Hub.Core
{
    /// <summary>Standard folders used by the Hub (all per-user, no administrator needed).</summary>
    public sealed class HubPaths
    {
        /// <summary>%APPDATA%\Autodesk\ApplicationPlugins - AutoCAD loads bundles from here for this user.</summary>
        public string UserPlugins { get; }

        /// <summary>%ProgramData%\Autodesk\ApplicationPlugins - all-users bundles (read only for the Hub).</summary>
        public string AllUsersPlugins { get; }

        /// <summary>%LOCALAPPDATA%\RoadPro Hub - logs and backups.</summary>
        public string DataRoot { get; }

        /// <summary>Folder of RoadProHub.exe; the setup puts the plugin under payload\.</summary>
        public string AppRoot { get; }

        public string Backups => Path.Combine(DataRoot, "backup");
        public string LogFile => Path.Combine(DataRoot, "logs", "RoadProHub.log");
        public string PayloadBundle => Path.Combine(AppRoot, "payload", BundleInfo.BundleFolderName);
        public string Docs => Path.Combine(AppRoot, "docs");

        public HubPaths(string userPlugins, string allUsersPlugins, string dataRoot, string appRoot)
        {
            UserPlugins = userPlugins;
            AllUsersPlugins = allUsersPlugins;
            DataRoot = dataRoot;
            AppRoot = appRoot;
        }

        public static HubPaths ForCurrentUser(string appRoot)
        {
            return new HubPaths(
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData), "Autodesk", "ApplicationPlugins"),
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.CommonApplicationData), "Autodesk", "ApplicationPlugins"),
                Path.Combine(Environment.GetFolderPath(Environment.SpecialFolder.LocalApplicationData), "RoadPro Hub"),
                appRoot);
        }

        /// <summary>A RoadPro bundle installed for all users (AutoCAD would load two copies).</summary>
        public BundleInfo AllUsersBundle() => BundleInfo.TryRead(Path.Combine(AllUsersPlugins, BundleInfo.BundleFolderName));

        /// <summary>First file in the docs folder matching a pattern, or null.</summary>
        public string FindDoc(string pattern)
        {
            try
            {
                if (!Directory.Exists(Docs)) return null;
                var files = Directory.GetFiles(Docs, pattern);
                Array.Sort(files, StringComparer.OrdinalIgnoreCase);
                return files.Length > 0 ? files[files.Length - 1] : null;
            }
            catch (Exception)
            {
                return null;
            }
        }
    }
}
