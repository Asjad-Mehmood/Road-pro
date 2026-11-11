using System;
using System.Collections.Generic;
using System.Diagnostics;
using System.IO;
using System.Linq;
using System.Threading;
using System.Threading.Tasks;
using System.Windows;
using System.Windows.Controls;
using System.Windows.Media;
using System.Windows.Navigation;
using RoadPro.Hub.Core;

namespace RoadPro.Hub
{
    public partial class MainWindow : Window
    {
        private BundleInfo _available;
        private BundleInfo _installed;
        private PluginState _state;

        private readonly string _startBanner;
        private UpdateManifest _update;
        private bool _loadingAutoCheck;

        public MainWindow() : this(null) { }

        internal MainWindow(string startBanner)
        {
            _startBanner = startBanner;
            InitializeComponent();
            HubVersionText.Text = "Version " + VersionText.Friendly(App.HubVersion);
            _loadingAutoCheck = true;
            AutoCheckBox.IsChecked = StartupRegistration.IsEnabled;
            _loadingAutoCheck = false;
            Loaded += async (s, e) =>
            {
                RefreshAll();
                await CheckUpdatesAsync(false);
            };
            Activated += (s, e) => RefreshBanner();
        }

        // ------------------------------------------------------------------ refresh

        private void RefreshAll()
        {
            RefreshPlugin();
            RefreshAutoCad();
            RefreshDocs();
            RefreshBanner();
        }

        private void RefreshPlugin()
        {
            var m = App.NewManager();
            _available = BundleInfo.TryRead(App.Paths.PayloadBundle);
            _installed = m.GetInstalled();
            _state = PluginStates.Compare(_installed, _available);
            bool damaged = m.IsDamaged;

            InstalledText.Text = _installed != null
                ? "Installed: plugin v" + _installed.FriendlyVersion
                : damaged ? "Installed: damaged (files missing) - use Repair" : "Installed: not yet";
            AvailableText.Text = _available != null
                ? "In this Hub: plugin v" + _available.FriendlyVersion
                : "In this Hub: plugin files missing - please run the setup again";
            LocationText.Text = m.TargetPath;

            switch (_state)
            {
                case PluginState.NotInstalled:
                    SetPill(damaged ? "Damaged" : "Not installed", damaged ? "Bad" : "Warn");
                    InstallButton.Content = damaged ? "Repair" : "Install";
                    break;
                case PluginState.Older:
                    SetPill("Update available", "Warn");
                    InstallButton.Content = "Update to v" + _available.FriendlyVersion;
                    break;
                case PluginState.Current:
                    SetPill("Up to date", "Good");
                    InstallButton.Content = "Reinstall";
                    break;
                case PluginState.Newer:
                    SetPill("Newer than this Hub", "Good");
                    InstallButton.Content = "Install v" + (_available?.FriendlyVersion ?? "");
                    break;
            }

            InstallButton.IsEnabled = _available != null;
            RepairButton.Visibility = _state == PluginState.Current ? Visibility.Visible : Visibility.Collapsed;
            InstallButton.Visibility = _state == PluginState.Current ? Visibility.Collapsed : Visibility.Visible;
            RepairButton.IsEnabled = _available != null;
            UninstallButton.IsEnabled = Directory.Exists(m.TargetPath);
            RestoreButton.Visibility = m.ListBackups().Any(b => BundleInfo.TryRead(b) != null) ? Visibility.Visible : Visibility.Collapsed;
        }

        private void RefreshAutoCad()
        {
            IList<AutoCadProduct> products;
            try { products = new AutoCadLocator(new WindowsRegistryReader()).Find(); }
            catch (Exception ex) { App.Log.Error("AutoCAD scan", ex); products = new List<AutoCadProduct>(); }

            AcadList.ItemsSource = products.Select(p => new AcadRow(p)).ToList();
            AcadEmpty.Visibility = products.Count == 0 ? Visibility.Visible : Visibility.Collapsed;
        }

        private void RefreshDocs()
        {
            foreach (var b in new[] { GuideButton, ShortcutsButton, NewsButton, ReportButton })
                b.IsEnabled = App.Paths.FindDoc((string)b.Tag) != null;
        }

        private void RefreshBanner()
        {
            var notes = new List<string>();
            if (!string.IsNullOrEmpty(_startBanner)) notes.Add(_startBanner);
            if (IsAutoCadRunning())
                notes.Add("AutoCAD is running. You can install now - the new RoadPro loads the next time AutoCAD starts.");
            var all = App.Paths.AllUsersBundle();
            if (all != null)
                notes.Add($"Another RoadPro {all.FriendlyVersion} is installed for all users in {Path.GetDirectoryName(all.Path)}. " +
                          "AutoCAD may load two copies - ask your IT administrator to remove that folder.");
            BannerText.Text = string.Join(Environment.NewLine, notes);
            Banner.Visibility = notes.Count > 0 ? Visibility.Visible : Visibility.Collapsed;
        }

        private void SetPill(string text, string kind)
        {
            StateText.Text = text;
            StateText.Foreground = (Brush)FindResource(kind);
            StatePill.Background = (Brush)FindResource(kind + "Soft");
        }

        private static bool IsAutoCadRunning()
        {
            try { return Process.GetProcessesByName("acad").Length > 0; }
            catch (Exception) { return false; }
        }

        // ------------------------------------------------------------------ actions

        private async void OnInstall(object sender, RoutedEventArgs e)
        {
            if (_available == null) return;
            await RunAsync(() => App.NewManager().Install(App.Paths.PayloadBundle));
        }

        private async void OnUninstall(object sender, RoutedEventArgs e)
        {
            var ask = MessageBox.Show(this, "Remove RoadPro from AutoCAD?\n\nYour drawings are not changed. A backup is kept, so you can restore it later.",
                                      "RoadPro Hub", MessageBoxButton.YesNo, MessageBoxImage.Question);
            if (ask != MessageBoxResult.Yes) return;
            await RunAsync(() => App.NewManager().Uninstall());
        }

        private async void OnRestore(object sender, RoutedEventArgs e)
        {
            var latest = App.NewManager().ListBackups().Select(BundleInfo.TryRead).FirstOrDefault(b => b != null);
            if (latest == null) return;
            var ask = MessageBox.Show(this, $"Go back to plugin v{latest.FriendlyVersion} (the previous version)?",
                                      "RoadPro Hub", MessageBoxButton.YesNo, MessageBoxImage.Question);
            if (ask != MessageBoxResult.Yes) return;
            await RunAsync(() => App.NewManager().RestoreLatestBackup());
        }

        private async Task RunAsync(Func<OperationResult> work)
        {
            SetBusy(true);
            OperationResult r;
            try { r = await Task.Run(work); }
            catch (Exception ex) { App.Log.Error("Operation", ex); r = OperationResult.Fail(ex.Message); }
            SetBusy(false);
            ResultText.Text = r.Message;
            ResultText.Foreground = (Brush)FindResource(r.Success ? "Good" : "Bad");
            ResultText.Visibility = Visibility.Visible;
            RefreshPlugin();
            RefreshBanner();
        }

        private void SetBusy(bool busy)
        {
            Busy.Visibility = busy ? Visibility.Visible : Visibility.Collapsed;
            foreach (var b in new[] { InstallButton, RepairButton, UninstallButton, RestoreButton })
                b.IsEnabled = !busy;
            if (busy) ResultText.Visibility = Visibility.Collapsed;
        }

        private void OnRefresh(object sender, RoutedEventArgs e) => RefreshAll();

        // ------------------------------------------------------------------ updates

        private async void OnCheckUpdates(object sender, RoutedEventArgs e) => await CheckUpdatesAsync(true);

        private async Task CheckUpdatesAsync(bool manual)
        {
            CheckButton.IsEnabled = false;
            UpdateText.Text = "Checking for updates...";
            var r = await Task.Run(() => App.Updates.Check(honourSkip: false));
            CheckButton.IsEnabled = true;
            _update = r.Status == UpdateStatus.Available ? r.Manifest : null;
            UpdateNotes.Visibility = Visibility.Collapsed;
            UpdateActions.Visibility = Visibility.Collapsed;
            switch (r.Status)
            {
                case UpdateStatus.Available:
                    UpdateText.Text = r.Message;
                    UpdateText.Foreground = (Brush)FindResource("Warn");
                    UpdateNotes.Text = r.Manifest.Notes ?? "";
                    UpdateNotes.Visibility = string.IsNullOrWhiteSpace(UpdateNotes.Text) ? Visibility.Collapsed : Visibility.Visible;
                    UpdateNowButton.Content = "Update to " + r.Manifest.FriendlyVersion;
                    UpdateActions.Visibility = Visibility.Visible;
                    SkipButton.Visibility = App.Updates.LoadState().SkippedVersion == r.Manifest.Version.ToString() ? Visibility.Collapsed : Visibility.Visible;
                    break;
                case UpdateStatus.Failed:
                    UpdateText.Text = manual ? r.Message : "Could not check for updates right now (offline?). Use Check now to try again.";
                    UpdateText.Foreground = (Brush)FindResource(manual ? "Bad" : "Muted");
                    break;
                default:
                    UpdateText.Text = r.Message + "  Checked " + DateTime.Now.ToString("d MMM yyyy, HH:mm") + ".";
                    UpdateText.Foreground = (Brush)FindResource("Good");
                    break;
            }
        }

        private async void OnUpdateNow(object sender, RoutedEventArgs e)
        {
            if (_update == null) return;
            if (IsAutoCadRunning())
            {
                var ask = MessageBox.Show(this, "AutoCAD is open. Save your drawings first: the new RoadPro loads the next time AutoCAD starts.\n\nUpdate now?",
                                          "RoadPro Hub", MessageBoxButton.YesNo, MessageBoxImage.Question);
                if (ask != MessageBoxResult.Yes) return;
            }
            UpdateActions.IsEnabled = false;
            CheckButton.IsEnabled = false;
            UpdateProgress.Value = 0;
            UpdateProgress.Visibility = Visibility.Visible;
            UpdateText.Text = $"Downloading RoadPro {_update.FriendlyVersion}...";
            UpdateText.Foreground = (Brush)FindResource("InkSoft");
            var progress = new Progress<double>(p => UpdateProgress.Value = p);
            var r = await Updater.DownloadAndRunAsync(App.Updates, _update, true, progress, CancellationToken.None);
            if (r.Success)
            {
                UpdateText.Text = r.Message + " RoadPro Hub opens again when the update is finished.";
                Application.Current.Shutdown(0);
                return;
            }
            UpdateProgress.Visibility = Visibility.Collapsed;
            UpdateActions.IsEnabled = true;
            CheckButton.IsEnabled = true;
            UpdateText.Text = r.Message;
            UpdateText.Foreground = (Brush)FindResource("Bad");
        }

        private void OnSkipUpdate(object sender, RoutedEventArgs e)
        {
            if (_update == null) return;
            App.Updates.Skip(_update);
            SkipButton.Visibility = Visibility.Collapsed;
            UpdateText.Text = $"RoadPro {_update.FriendlyVersion} will not be offered at Windows start. You can still install it here.";
        }

        private void OnAutoCheckChanged(object sender, RoutedEventArgs e)
        {
            if (_loadingAutoCheck) return;
            StartupRegistration.Set(AutoCheckBox.IsChecked == true);
        }

        private void OnOpenDoc(object sender, RoutedEventArgs e)
        {
            var path = App.Paths.FindDoc((string)((Button)sender).Tag);
            if (path != null) Open(path);
        }

        private void OnOpenPluginFolder(object sender, RoutedEventArgs e)
        {
            var dir = Directory.Exists(App.NewManager().TargetPath) ? App.NewManager().TargetPath : App.Paths.UserPlugins;
            Directory.CreateDirectory(dir);
            Open(dir);
        }

        private void OnOpenLog(object sender, RoutedEventArgs e)
        {
            if (!File.Exists(App.Paths.LogFile)) App.Log.Info("Log opened");
            Open(App.Paths.LogFile);
        }

        private void OnNavigate(object sender, RequestNavigateEventArgs e)
        {
            Open(e.Uri.AbsoluteUri);
            e.Handled = true;
        }

        private void Open(string target)
        {
            try
            {
                Process.Start(new ProcessStartInfo(target) { UseShellExecute = true });
            }
            catch (Exception ex)
            {
                App.Log.Error("Open " + target, ex);
                MessageBox.Show(this, "Could not open " + target + "\n" + ex.Message, "RoadPro Hub", MessageBoxButton.OK, MessageBoxImage.Warning);
            }
        }
    }

    /// <summary>One AutoCAD product in the list (public so WPF data binding can read it).</summary>
    public sealed class AcadRow
    {
        public AcadRow(AutoCadProduct p)
        {
            Title = p.Name;
            Detail = p.Release + (p.Year.HasValue ? "  ·  " + p.Year : "") + (string.IsNullOrEmpty(p.Location) ? "" : "  ·  " + p.Location);
            Badge = p.Supported ? "Supported" : "Too old (2013+ needed)";
            var app = Application.Current;
            BadgeForeground = (Brush)app.FindResource(p.Supported ? "Good" : "Bad");
            BadgeBackground = (Brush)app.FindResource(p.Supported ? "GoodSoft" : "BadSoft");
        }

        public string Title { get; }
        public string Detail { get; }
        public string Badge { get; }
        public Brush BadgeForeground { get; }
        public Brush BadgeBackground { get; }
    }
}
