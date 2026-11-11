using System;
using System.Threading;
using System.Windows;
using System.Windows.Media;
using RoadPro.Hub.Core;

namespace RoadPro.Hub
{
    /// <summary>Small window in the corner of the screen, shown at Windows start when an update is waiting.</summary>
    public partial class UpdatePromptWindow : Window
    {
        private readonly UpdateManifest _m;
        private CancellationTokenSource _cts;

        internal UpdatePromptWindow(UpdateManifest m)
        {
            _m = m;
            InitializeComponent();
            TitleText.Text = $"RoadPro {m.FriendlyVersion} is available";
            InfoText.Text = $"You have RoadPro {VersionText.Friendly(App.HubVersion)}. The update takes about a minute; close AutoCAD first if it is open.";
            NotesText.Text = Shorten(m.Notes);
            NotesText.Visibility = string.IsNullOrWhiteSpace(NotesText.Text) ? Visibility.Collapsed : Visibility.Visible;
            Loaded += (s, e) =>
            {
                var wa = SystemParameters.WorkArea;
                Left = wa.Right - ActualWidth - 16;
                Top = wa.Bottom - ActualHeight - 16;
            };
            Closed += (s, e) => _cts?.Cancel();
        }

        private static string Shorten(string notes)
        {
            if (string.IsNullOrWhiteSpace(notes)) return "";
            var t = notes.Trim();
            return t.Length > 260 ? t.Substring(0, 257) + "..." : t;
        }

        private async void OnUpdate(object sender, RoutedEventArgs e)
        {
            Buttons.IsEnabled = false;
            Progress.Visibility = Visibility.Visible;
            ShowStatus("Downloading...", "InkSoft");
            _cts = new CancellationTokenSource();
            var progress = new Progress<double>(p => Progress.Value = p);
            var r = await Updater.DownloadAndRunAsync(App.Updates, _m, true, progress, _cts.Token);
            if (r.Success)
            {
                ShowStatus(r.Message, "Good");
                Application.Current.Shutdown(0);
                return;
            }
            ShowStatus(r.Message, "Bad");
            Progress.Visibility = Visibility.Collapsed;
            Buttons.IsEnabled = true;
        }

        private void OnLater(object sender, RoutedEventArgs e) => Close();

        private void OnSkip(object sender, RoutedEventArgs e)
        {
            App.Updates.Skip(_m);
            Close();
        }

        private void ShowStatus(string text, string brush)
        {
            StatusText.Text = text;
            StatusText.Foreground = (Brush)FindResource(brush);
            StatusText.Visibility = Visibility.Visible;
        }
    }
}
