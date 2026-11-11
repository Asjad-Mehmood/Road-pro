using System;
using System.Collections.Generic;
using System.Globalization;
using System.Linq;
using System.Text.RegularExpressions;

namespace RoadPro.Hub.Core
{
    /// <summary>Read access to HKEY_LOCAL_MACHINE (abstracted so it can be tested).</summary>
    public interface IRegistryReader
    {
        IEnumerable<string> GetSubKeyNames(string path);
        string GetValue(string path, string name);
    }

    public sealed class AutoCadProduct
    {
        public string Name { get; set; }
        public string Release { get; set; }        // R24.3
        public string ProductKey { get; set; }     // ACAD-7101:409
        public string Location { get; set; }
        public int? Year { get; set; }
        /// <summary>RoadPro needs AutoCAD 2013 (R19.0) or newer.</summary>
        public bool Supported { get; set; }

        public override string ToString() => $"{Name} ({Release})";
    }

    /// <summary>
    /// Finds AutoCAD-based products (AutoCAD, Civil 3D, Map 3D, ...) from the
    /// registry: HKLM\SOFTWARE\Autodesk\AutoCAD\Rxx.x\ACAD-xxxx:xxx.
    /// AutoCAD LT lives under a different key and is not listed.
    /// </summary>
    public sealed class AutoCadLocator
    {
        public const string RootKey = @"SOFTWARE\Autodesk\AutoCAD";
        public static readonly Version MinRelease = new Version(19, 0);

        private static readonly Regex ReleaseRx = new Regex(@"^R(\d+)\.(\d+)$", RegexOptions.IgnoreCase);

        private static readonly Dictionary<string, int> Years = new Dictionary<string, int>(StringComparer.OrdinalIgnoreCase)
        {
            ["R17.0"] = 2007, ["R17.1"] = 2008, ["R17.2"] = 2009, ["R18.0"] = 2010, ["R18.1"] = 2011, ["R18.2"] = 2012,
            ["R19.0"] = 2013, ["R19.1"] = 2014, ["R20.0"] = 2015, ["R20.1"] = 2016, ["R21.0"] = 2017, ["R22.0"] = 2018,
            ["R23.0"] = 2019, ["R23.1"] = 2020, ["R24.0"] = 2021, ["R24.1"] = 2022, ["R24.2"] = 2023, ["R24.3"] = 2024,
            ["R25.0"] = 2025, ["R25.1"] = 2026, ["R25.2"] = 2027
        };

        private readonly IRegistryReader _reg;

        public AutoCadLocator(IRegistryReader registry)
        {
            _reg = registry ?? throw new ArgumentNullException(nameof(registry));
        }

        public static int? YearOf(string release) => release != null && Years.TryGetValue(release, out var y) ? y : (int?)null;

        public IList<AutoCadProduct> Find()
        {
            var list = new List<AutoCadProduct>();
            IEnumerable<string> releases;
            try { releases = _reg.GetSubKeyNames(RootKey) ?? Enumerable.Empty<string>(); }
            catch (Exception) { return list; }

            foreach (var rel in releases)
            {
                var m = ReleaseRx.Match(rel ?? "");
                if (!m.Success) continue;
                var rv = new Version(int.Parse(m.Groups[1].Value, CultureInfo.InvariantCulture), int.Parse(m.Groups[2].Value, CultureInfo.InvariantCulture));
                string relKey = RootKey + "\\" + rel;
                IEnumerable<string> prods;
                try { prods = _reg.GetSubKeyNames(relKey) ?? Enumerable.Empty<string>(); }
                catch (Exception) { continue; }

                foreach (var pk in prods.Where(p => p != null && p.StartsWith("ACAD-", StringComparison.OrdinalIgnoreCase)))
                {
                    string key = relKey + "\\" + pk;
                    string name = Safe(() => _reg.GetValue(key, "ProductName"));
                    string loc = Safe(() => _reg.GetValue(key, "AcadLocation")) ?? Safe(() => _reg.GetValue(key, "Location"));
                    if (string.IsNullOrWhiteSpace(name) && string.IsNullOrWhiteSpace(loc)) continue;   // leftover key
                    int? year = YearOf("R" + rv.Major + "." + rv.Minor);
                    list.Add(new AutoCadProduct
                    {
                        Name = string.IsNullOrWhiteSpace(name) ? "AutoCAD " + (year?.ToString(CultureInfo.InvariantCulture) ?? rel) : name.Trim(),
                        Release = "R" + rv.Major + "." + rv.Minor,
                        ProductKey = pk,
                        Location = loc?.Trim(),
                        Year = year,
                        Supported = rv >= MinRelease
                    });
                }
            }

            return list.GroupBy(p => (p.Release + "|" + p.ProductKey).ToUpperInvariant())
                       .Select(g => g.First())
                       .OrderByDescending(p => Version.Parse(p.Release.Substring(1)))
                       .ThenBy(p => p.Name, StringComparer.OrdinalIgnoreCase)
                       .ToList();
        }

        private static string Safe(Func<string> f)
        {
            try { return f(); } catch (Exception) { return null; }
        }
    }
}
