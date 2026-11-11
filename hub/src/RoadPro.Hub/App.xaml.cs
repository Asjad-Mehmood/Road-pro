using System;
using System.IO;
using System.Reflection;
using System.Windows;
using System.Windows.Threading;
using RoadPro.Hub.Core;

namespace RoadPro.Hub
{
    public partial class App : Application
    {
        internal static HubPaths Paths { get; private set; }
        internal static Logger Log { get; private set; }

        internal static Version HubVersion => Assembly.GetExecutingAssembly().GetName().Version;

        internal static BundleManager NewManager() => new BundleManager(Paths.UserPlugins, Paths.Backups, Log);

        protected override void OnStartup(StartupEventArgs e)
        {
            base.OnStartup(e);
            string appRoot = Path.GetDirectoryName(Assembly.GetExecutingAssembly().Location) ?? AppDomain.CurrentDomain.BaseDirectory;
            Paths = HubPaths.ForCurrentUser(appRoot);
            Log = new Logger(Paths.LogFile);
            DispatcherUnhandledException += OnUnhandled;

            var cmd = CommandLine.Parse(e.Args);
            Log.Info($"RoadPro Hub {HubVersion} start: {string.Join(" ", e.Args)}");

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
                default:
                    if (cmd.Unknown != null) Log.Warn("Unknown argument " + cmd.Unknown);
                    var w = new MainWindow();
                    MainWindow = w;
                    w.Show();
                    return;
            }
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
