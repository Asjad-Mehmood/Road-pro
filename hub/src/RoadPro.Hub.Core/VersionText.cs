using System;

namespace RoadPro.Hub.Core
{
    /// <summary>Parses and prints RoadPro version numbers ("3.6", "3.6.0", "v3.6").</summary>
    public static class VersionText
    {
        public static bool TryParse(string text, out Version version)
        {
            version = null;
            if (string.IsNullOrWhiteSpace(text)) return false;
            var t = text.Trim();
            if (t.StartsWith("v", StringComparison.OrdinalIgnoreCase)) t = t.Substring(1);
            if (!Version.TryParse(t, out var v)) return false;
            // normalise to major.minor.build so 3.6 == 3.6.0
            version = new Version(v.Major, v.Minor, Math.Max(0, v.Build));
            return true;
        }

        public static Version Parse(string text)
        {
            if (!TryParse(text, out var v)) throw new FormatException("Not a version number: " + text);
            return v;
        }

        /// <summary>3.6.0 -> "3.6", 3.6.1 -> "3.6.1".</summary>
        public static string Friendly(Version v)
        {
            if (v == null) return "";
            return v.Build > 0 ? $"{v.Major}.{v.Minor}.{v.Build}" : $"{v.Major}.{v.Minor}";
        }
    }
}
