using System;
using System.IO;
using System.Xml.Linq;

namespace RoadPro.Hub.Core
{
    /// <summary>
    /// A RoadPro.bundle folder (Autodesk ApplicationPlugins format) and the
    /// version written in its PackageContents.xml.
    /// </summary>
    public sealed class BundleInfo
    {
        public const string BundleFolderName = "RoadPro.bundle";
        public const string ManifestName = "PackageContents.xml";
        public const string PluginFile = "Contents/RoadPro.lsp";

        public string Path { get; }
        public Version Version { get; }
        public string FriendlyVersion { get; }

        private BundleInfo(string path, Version version, string friendly)
        {
            Path = path;
            Version = version;
            FriendlyVersion = friendly;
        }

        /// <summary>True when the folder holds the manifest and the plugin file.</summary>
        public static bool LooksComplete(string bundlePath)
        {
            return File.Exists(System.IO.Path.Combine(bundlePath, ManifestName))
                && File.Exists(System.IO.Path.Combine(bundlePath, PluginFile));
        }

        /// <summary>Reads a bundle folder; null when it is missing or damaged.</summary>
        public static BundleInfo TryRead(string bundlePath)
        {
            try
            {
                if (string.IsNullOrEmpty(bundlePath) || !LooksComplete(bundlePath)) return null;
                var doc = XDocument.Load(System.IO.Path.Combine(bundlePath, ManifestName));
                var root = doc.Root;
                if (root == null || root.Name.LocalName != "ApplicationPackage") return null;
                var app = (string)root.Attribute("AppVersion");
                if (!VersionText.TryParse(app, out var v)) return null;
                var friendly = (string)root.Attribute("FriendlyVersion");
                return new BundleInfo(bundlePath, v, string.IsNullOrWhiteSpace(friendly) ? VersionText.Friendly(v) : friendly.Trim());
            }
            catch (Exception)
            {
                return null;
            }
        }
    }

    /// <summary>Where the installed plugin stands against the one shipped with the Hub.</summary>
    public enum PluginState
    {
        NotInstalled,
        Older,
        Current,
        Newer
    }

    public static class PluginStates
    {
        public static PluginState Compare(BundleInfo installed, BundleInfo available)
        {
            if (installed == null) return PluginState.NotInstalled;
            if (available == null) return PluginState.Current;
            int c = installed.Version.CompareTo(available.Version);
            return c < 0 ? PluginState.Older : c == 0 ? PluginState.Current : PluginState.Newer;
        }
    }
}
