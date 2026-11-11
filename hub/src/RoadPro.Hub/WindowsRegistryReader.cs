using System;
using System.Collections.Generic;
using System.Linq;
using Microsoft.Win32;
using RoadPro.Hub.Core;

namespace RoadPro.Hub
{
    /// <summary>Reads HKEY_LOCAL_MACHINE in both the 64-bit and 32-bit registry views.</summary>
    internal sealed class WindowsRegistryReader : IRegistryReader
    {
        private static readonly RegistryView[] Views = Environment.Is64BitOperatingSystem
            ? new[] { RegistryView.Registry64, RegistryView.Registry32 }
            : new[] { RegistryView.Registry32 };

        public IEnumerable<string> GetSubKeyNames(string path)
        {
            var names = new List<string>();
            foreach (var view in Views)
            {
                try
                {
                    using (var hklm = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, view))
                    using (var key = hklm.OpenSubKey(path))
                    {
                        if (key != null) names.AddRange(key.GetSubKeyNames());
                    }
                }
                catch (Exception)
                {
                    // no access to this view - skip it
                }
            }
            return names.Distinct(StringComparer.OrdinalIgnoreCase).ToList();
        }

        public string GetValue(string path, string name)
        {
            foreach (var view in Views)
            {
                try
                {
                    using (var hklm = RegistryKey.OpenBaseKey(RegistryHive.LocalMachine, view))
                    using (var key = hklm.OpenSubKey(path))
                    {
                        var v = key?.GetValue(name) as string;
                        if (!string.IsNullOrEmpty(v)) return v;
                    }
                }
                catch (Exception)
                {
                }
            }
            return null;
        }
    }
}
