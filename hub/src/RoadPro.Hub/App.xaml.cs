using System;
using System.IO;
using System.Net;
using System.Reflection;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Threading;
using RoadPro.Hub.Core;

namespace RoadPro.Hub
{
    public partial class App : Application
    {
        internal static HubPaths Paths { get; private set; }
        internal static Logger Log { get; private set; }
        internal static UpdateService Updates { get; private set; }

        /// <summary>Hub version = RoadPro version (one version.txt for plugin, Hub and setup).</summary>
        internal static Version HubVersion
        {
            get
            {
                var v = Assembly.GetExecutingAssembly().GetName().Version;
                return new Version(v.Major, v.Minor, Math.Max(0, v.Build));
            }
        }

        internal static BundleManager NewManager() => new BundleManager(Paths.UserPlugins, Paths.Backups, Log);

        protected override async void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            string appRoot = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? AppDomain.CurrentDomain.BaseDirectory;
            Paths = HubPaths.ForCurrentUser(appRoot);
            Log = new Logger(Paths.LogFile);
            DispatcherUnhandledException += OnUnhandled;

            // .NET 4.8 uses the Windows TLS defaults; make sure TLS 1.2 is on for older Windows
            if (ServicePointManager.SecurityProtocol != SecurityProtocolType.SystemDefault)
                ServicePointManager.SecurityProtocol |= SecurityProtocolType.Tls12;

            var cmd = CommandLine.Parse(e.Args);
            Log.Info($"RoadPro Hub {HubVersion} start: {string.Join(" ", e.Args)}");
            string manifest = cmd.ManifestUrl ?? Environment.GetEnvironmentVariable("ROADPRO_UPDATE_MANIFEST");
            Updates = new UpdateService(HubVersion, Paths.DataRoot, new WebDownloader(), manifest, Log);

            switch (cmd.Command)
            {
                case HubCommand.InstallPlugin:
                    Finish(NewManager().Install(Paths.PayloadBundle), cmd.Quiet);
                    return;

                case HubCommand.UninstallPlugin:
                    Finish(NewManager().Uninstall(), cmd.Quiet);
                    return;

                case HubCommand.Help:
                    MessageBox.Show(CommandLine.Usage, "RoadPro Hub", MessageBoxButton.OK, MessageBoxImage.Information);
                    Shutdown(0);
                    return;

                case HubCommand.CheckUpdates:
                    await CheckAtStartupAsync();
                    return;

                case HubCommand.AutoUpdate:
                    await AutoUpdateAsync();
                    return;

                case HubCommand.Updated:
                    AfterUpdate();
                    return;

                default:
                    if (cmd.Unknown != null) Log.Warn("Unknown argument " + cmd.Unknown);
                    ShowMain(null);
                    return;
            }
        }

        private void ShowMain(string banner)
        {
            var w = new MainWindow(banner);
            MainWindow = w;
            w.Show();
        }

        /// <summary>Windows start-up: quiet unless an update is waiting.</summary>
        private async Task CheckAtStartupAsync()
        {
            if (!Updates.IsAutoCheckDue(DateTime.UtcNow))
            {
                Shutdown(0);
                return;
            }
            // let Windows finish starting before going online
            await Task.Delay(TimeSpan.FromSeconds(20));
            var r = await Task.Run(() => Updates.Check(honourSkip: true));
            if (r.Status != UpdateStatus.Available)
            {
                Shutdown(0);
                return;
            }
            var prompt = new UpdatePromptWindow(r.Manifest);
            MainWindow = prompt;
            prompt.Show();
        }

        /// <summary>No window: check, download, verify and start the setup (exit 0 = done or up to date).</summary>
        private async Task AutoUpdateAsync()
        {
            var r = await Task.Run(() => Updates.Check(honourSkip: false));
            Log.Info("Auto update check: " + r.Status + " - " + r.Message);
            if (r.Status == UpdateStatus.UpToDate) { Shutdown(0); return; }
            if (r.Status == UpdateStatus.Failed) { Shutdown(1); return; }
            var run = await Updater.DownloadAndRunAsync(Updates, r.Manifest, false, null, CancellationToken.None);
            Log.Info("Auto update: " + run);
            Shutdown(run.Success ? 0 : 1);
        }

        /// <summary>Started by the setup after an update: bring the plugin up to date too.</summary>
        private void AfterUpdate()
        {
            Updates.WriteNotice(null);
            var m = NewManager();
            var installed = m.GetInstalled();
            var payload = BundleInfo.TryRead(Paths.PayloadBundle);
            string extra = "";
            if (installed != null && PluginStates.Compare(installed, payload) == PluginState.Older)
            {
                var r = m.Install(Paths.PayloadBundle);
                extra = r.Success ? " The AutoCAD plugin was updated too." : " " + r.Message;
            }
            ShowMain($"RoadPro was updated to {VersionText.Friendly(HubVersion)}.{extra} Restart AutoCAD to use the new version.");
        }

        private void Finish(OperationResult r, bool quiet)
        {
            Log.Info("Command result: " + r);
            if (!quiet)
                MessageBox.Show(r.Message, "RoadPro Hub", MessageBoxButton.OK, r.Success ? MessageBoxImage.Information : MessageBoxImage.Error);
            Shutdown(r.Success ? 0 : 1);
        }

        private void OnUnhandled(object sender, DispatcherUnhandledExceptionEventArgs e)
        {
            Log?.Error("Unhandled", e.Exception);
            MessageBox.Show("Something went wrong: " + e.Exception.Message + "\n\nDetails are in the log:\n" + Paths?.LogFile,
                            "RoadPro Hub", MessageBoxButton.OK, MessageBoxImage.Error);
            e.Handled = true;
        }
    }
}
