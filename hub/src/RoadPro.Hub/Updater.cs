using System;
using System.Diagnostics;
using System.IO;
using System.Threading;
using System.Threading.Tasks;
using Microsoft.Win32;
using RoadPro.Hub.Core;

namespace RoadPro.Hub
{
    /// <summary>Runs a downloaded, verified setup and closes the Hub so the setup can replace it.</summary>
    internal static class Updater
    {
        public static async Task<OperationResult> DownloadAndRunAsync(UpdateService svc, UpdateManifest m, bool relaunchHub,
                                                                      IProgress<double> progress, CancellationToken cancel)
        {
            string setup;
            try
            {
                setup = await svc.DownloadAsync(m, progress, cancel);
            }
            catch (OperationCanceledException)
            {
                return OperationResult.Fail("The download was cancelled.");
            }
            catch (UpdateException ex)
            {
                return OperationResult.Fail(ex.Message);
            }

            try
            {
                string log = Path.Combine(svc.DownloadDir, "setup.log");
                var psi = new ProcessStartInfo(setup, UpdateService.SetupArguments(relaunchHub, log))
                {
                    UseShellExecute = true,
                    WorkingDirectory = svc.DownloadDir
                };
                App.Log.Info($"Starting {setup} {psi.Arguments}");
                Process.Start(psi);
                return OperationResult.Ok($"Installing RoadPro {m.FriendlyVersion}...", m.Version);
            }
            catch (Exception ex)
            {
                App.Log.Error("Could not start the setup", ex);
                return OperationResult.Fail("Could not start the setup: " + ex.Message);
            }
        }
    }

    /// <summary>"Check for updates when Windows starts" - HKCU Run value (same one the setup writes).</summary>
    internal static class StartupRegistration
    {
        private const string RunKey = @"Software\Microsoft\Windows\CurrentVersion\Run";
        private const string ValueName = "RoadPro Hub";

        private static string Command => "\"" + Path.Combine(App.Paths.AppRoot, "RoadProHub.exe") + "\" /checkupdates";

        public static bool IsEnabled
        {
            get
            {
                try
                {
                    using (var k = Registry.CurrentUser.OpenSubKey(RunKey))
                        return k?.GetValue(ValueName) is string s && s.IndexOf("/checkupdates", StringComparison.OrdinalIgnoreCase) >= 0;
                }
                catch (Exception) { return false; }
            }
        }

        public static void Set(bool enabled)
        {
            try
            {
                using (var k = Registry.CurrentUser.CreateSubKey(RunKey))
                {
                    if (enabled) k.SetValue(ValueName, Command);
                    else if (k.GetValue(ValueName) != null) k.DeleteValue(ValueName, false);
                }
                App.Log.Info("Check at Windows start: " + (enabled ? "on" : "off"));
            }
            catch (Exception ex)
            {
                App.Log.Error("Run key", ex);
            }
        }
    }
}
