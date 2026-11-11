using System;
using System.IO;
using System.Text;

namespace RoadPro.Hub.Core
{
    /// <summary>Small append-only text log; never throws.</summary>
    public sealed class Logger
    {
        private readonly object _gate = new object();
        public string FilePath { get; }

        public Logger(string filePath)
        {
            FilePath = filePath;
        }

        public static Logger None { get; } = new Logger(null);

        public void Info(string message) => Write("INFO ", message);
        public void Warn(string message) => Write("WARN ", message);
        public void Error(string message, Exception ex = null) => Write("ERROR", ex == null ? message : message + " | " + ex.GetType().Name + ": " + ex.Message);

        private void Write(string level, string message)
        {
            if (string.IsNullOrEmpty(FilePath)) return;
            try
            {
                lock (_gate)
                {
                    var dir = Path.GetDirectoryName(FilePath);
                    if (!string.IsNullOrEmpty(dir)) Directory.CreateDirectory(dir);
                    File.AppendAllText(FilePath, $"{DateTime.Now:yyyy-MM-dd HH:mm:ss} {level} {message}{Environment.NewLine}", Encoding.UTF8);
                }
            }
            catch (Exception)
            {
                // logging must never break the Hub
            }
        }
    }
}
