using System;
using System.Linq;

namespace RoadPro.Hub.Core
{
    public enum HubCommand
    {
        ShowWindow,
        InstallPlugin,
        UninstallPlugin,
        Help
    }

    /// <summary>
    /// RoadProHub.exe [/installplugin | /uninstallplugin] [/quiet]
    /// Used by the setup program; "-" and "--" prefixes work too.
    /// </summary>
    public sealed class CommandLine
    {
        public HubCommand Command { get; private set; } = HubCommand.ShowWindow;
        public bool Quiet { get; private set; }
        public string Unknown { get; private set; }

        public static CommandLine Parse(string[] args)
        {
            var c = new CommandLine();
            foreach (var raw in args ?? new string[0])
            {
                var a = (raw ?? "").Trim().TrimStart('/', '-').ToLowerInvariant();
                switch (a)
                {
                    case "": break;
                    case "installplugin": case "install": c.Command = HubCommand.InstallPlugin; break;
                    case "uninstallplugin": case "uninstall": c.Command = HubCommand.UninstallPlugin; break;
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
            "add /quiet to run without messages (exit code 0 = OK, 1 = failed)";
    }
}
