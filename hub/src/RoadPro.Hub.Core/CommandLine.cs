using System;
using System.Linq;

namespace RoadPro.Hub.Core
{
    public enum HubCommand
    {
        ShowWindow,
        InstallPlugin,
        UninstallPlugin,
        /// <summary>Windows start-up: check quietly, show a small prompt only when an update is waiting.</summary>
        CheckUpdates,
        /// <summary>Check, download and run the update without any window (for testing).</summary>
        AutoUpdate,
        /// <summary>Started by the setup after an update.</summary>
        Updated,
        Help
    }

    /// <summary>
    /// RoadProHub.exe [/installplugin | /uninstallplugin | /checkupdates | /autoupdate | /updated] [/quiet] [/manifest=URL]
    /// Used by the setup program; "-" and "--" prefixes work too.
    /// </summary>
    public sealed class CommandLine
    {
        public HubCommand Command { get; private set; } = HubCommand.ShowWindow;
        public bool Quiet { get; private set; }
        public string Unknown { get; private set; }
        /// <summary>Other update.json address (testing); default is GitHub Releases.</summary>
        public string ManifestUrl { get; private set; }

        public static CommandLine Parse(string[] args)
        {
            var c = new CommandLine();
            foreach (var raw in args ?? new string[0])
            {
                var t = (raw ?? "").Trim().TrimStart('/', '-');
                int eq = t.IndexOf('=');
                if (eq > 0 && t.Substring(0, eq).Equals("manifest", StringComparison.OrdinalIgnoreCase))
                {
                    c.ManifestUrl = t.Substring(eq + 1).Trim('"');
                    continue;
                }
                var a = t.ToLowerInvariant();
                switch (a)
                {
                    case "": break;
                    case "installplugin": case "install": c.Command = HubCommand.InstallPlugin; break;
                    case "uninstallplugin": case "uninstall": c.Command = HubCommand.UninstallPlugin; break;
                    case "checkupdates": c.Command = HubCommand.CheckUpdates; break;
                    case "autoupdate": c.Command = HubCommand.AutoUpdate; break;
                    case "updated": c.Command = HubCommand.Updated; break;
                    case "quiet": case "q": case "silent": c.Quiet = true; break;
                    case "?": case "h": case "help": c.Command = HubCommand.Help; break;
                    default: if (c.Unknown == null) c.Unknown = raw; break;
                }
            }
            return c;
        }

        public const string Usage =
            "RoadProHub.exe                     open RoadPro Hub\n" +
            "RoadProHub.exe /installplugin      install / update the RoadPro plugin\n" +
            "RoadProHub.exe /uninstallplugin    remove the RoadPro plugin\n" +
            "RoadProHub.exe /checkupdates       check for a new version (Windows start-up)\n" +
            "add /quiet to run without messages (exit code 0 = OK, 1 = failed)";
    }
}
