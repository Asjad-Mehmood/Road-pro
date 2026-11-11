using System;
using System.Collections.Generic;
using System.IO;
using System.Linq;
using RoadPro.Hub.Core;
using Xunit;

namespace RoadPro.Hub.Core.Tests
{
    public class VersionTests
    {
        [Theory]
        [InlineData("3.6", "3.6.0")]
        [InlineData("3.6.0", "3.6.0")]
        [InlineData("v3.7.1", "3.7.1")]
        [InlineData(" 3.6 ", "3.6.0")]
        public void Parses(string text, string expected) => Assert.Equal(Version.Parse(expected), VersionText.Parse(text));

        [Theory]
        [InlineData("")]
        [InlineData(null)]
        [InlineData("three")]
        public void Rejects(string text) => Assert.False(VersionText.TryParse(text, out _));

        [Fact]
        public void Friendly() => Assert.Equal("3.6", VersionText.Friendly(new Version(3, 6, 0)));

        [Fact]
        public void States()
        {
            using var s = new Sandbox();
            var v35 = BundleInfo.TryRead(s.BundleVersion("3.5.0"));
            var v36 = BundleInfo.TryRead(s.BundleVersion("3.6.0"));
            Assert.Equal(PluginState.NotInstalled, PluginStates.Compare(null, v36));
            Assert.Equal(PluginState.Older, PluginStates.Compare(v35, v36));
            Assert.Equal(PluginState.Current, PluginStates.Compare(v36, v36));
            Assert.Equal(PluginState.Newer, PluginStates.Compare(v36, v35));
        }
    }

    public class FakeRegistry : IRegistryReader
    {
        public Dictionary<string, Dictionary<string, string>> Keys = new Dictionary<string, Dictionary<string, string>>(StringComparer.OrdinalIgnoreCase);

        public void Add(string path, params (string name, string value)[] values)
        {
            Keys[path] = values.ToDictionary(v => v.name, v => v.value, StringComparer.OrdinalIgnoreCase);
        }

        public IEnumerable<string> GetSubKeyNames(string path) =>
            Keys.Keys.Where(k => k.StartsWith(path + "\\", StringComparison.OrdinalIgnoreCase))
                     .Select(k => k.Substring(path.Length + 1).Split('\\')[0]).Distinct();

        public string GetValue(string path, string name) =>
            Keys.TryGetValue(path, out var v) && v.TryGetValue(name, out var x) ? x : null;
    }

    public class AutoCadLocatorTests
    {
        const string R = AutoCadLocator.RootKey;

        [Fact]
        public void Finds_autocad_and_civil3d_newest_first()
        {
            var reg = new FakeRegistry();
            reg.Add(R + @"\R24.3\ACAD-7101:409", ("ProductName", "AutoCAD 2024"), ("AcadLocation", @"C:\Program Files\Autodesk\AutoCAD 2024"));
            reg.Add(R + @"\R25.0\ACAD-8000:409", ("ProductName", "Autodesk Civil 3D 2025"), ("AcadLocation", @"C:\Program Files\Autodesk\AutoCAD 2025"));
            reg.Add(R + @"\R18.2\ACAD-A001:409", ("ProductName", "AutoCAD 2012"), ("AcadLocation", @"C:\old"));
            var list = new AutoCadLocator(reg).Find();
            Assert.Equal(3, list.Count);
            Assert.Equal("Autodesk Civil 3D 2025", list[0].Name);
            Assert.Equal(2025, list[0].Year);
            Assert.True(list[0].Supported);
            Assert.Equal("AutoCAD 2024", list[1].Name);
            Assert.False(list[2].Supported);   // 2012 is older than 2013
        }

        [Fact]
        public void Ignores_leftovers_and_non_acad_keys()
        {
            var reg = new FakeRegistry();
            reg.Add(R + @"\R24.3\ACAD-7101:409");                                   // uninstalled leftover
            reg.Add(R + @"\R24.3\Something", ("ProductName", "x"));
            reg.Add(R + @"\CurVer", ("ProductName", "x"));
            Assert.Empty(new AutoCadLocator(reg).Find());
        }

        [Fact]
        public void Name_falls_back_to_year()
        {
            var reg = new FakeRegistry();
            reg.Add(R + @"\R24.1\ACAD-5101:409", ("AcadLocation", @"C:\acad"));
            var p = Assert.Single(new AutoCadLocator(reg).Find());
            Assert.Equal("AutoCAD 2022", p.Name);
        }

        [Fact]
        public void Registry_errors_give_an_empty_list()
        {
            Assert.Empty(new AutoCadLocator(new ThrowingRegistry()).Find());
        }

        class ThrowingRegistry : IRegistryReader
        {
            public IEnumerable<string> GetSubKeyNames(string path) => throw new UnauthorizedAccessException();
            public string GetValue(string path, string name) => throw new UnauthorizedAccessException();
        }
    }

    public class CommandLineTests
    {
        [Fact]
        public void Default_opens_window() => Assert.Equal(HubCommand.ShowWindow, CommandLine.Parse(new string[0]).Command);

        [Theory]
        [InlineData("/installplugin", HubCommand.InstallPlugin)]
        [InlineData("--install", HubCommand.InstallPlugin)]
        [InlineData("/UNINSTALLPLUGIN", HubCommand.UninstallPlugin)]
        [InlineData("/?", HubCommand.Help)]
        public void Commands(string arg, HubCommand expected) => Assert.Equal(expected, CommandLine.Parse(new[] { arg }).Command);

        [Fact]
        public void Quiet_flag()
        {
            var c = CommandLine.Parse(new[] { "/installplugin", "/quiet" });
            Assert.True(c.Quiet);
            Assert.Equal(HubCommand.InstallPlugin, c.Command);
        }

        [Fact]
        public void Unknown_is_reported() => Assert.Equal("/foo", CommandLine.Parse(new[] { "/foo" }).Unknown);
    }

    public class HubPathsTests
    {
        [Fact]
        public void Finds_docs_by_pattern()
        {
            using var s = new Sandbox();
            var p = new HubPaths(s.Plugins, Path.Combine(s.Root, "all"), Path.Combine(s.Root, "data"), s.Root);
            Directory.CreateDirectory(p.Docs);
            File.WriteAllText(Path.Combine(p.Docs, "RoadPro_v3.6_User_Guide.pdf"), "x");
            Assert.EndsWith("RoadPro_v3.6_User_Guide.pdf", p.FindDoc("*User_Guide*.pdf"));
            Assert.Null(p.FindDoc("*Nothing*"));
            Assert.Null(p.AllUsersBundle());
        }

        [Fact]
        public void Detects_all_users_copy()
        {
            using var s = new Sandbox();
            var all = Path.Combine(s.Root, "all");
            Sandbox.Copy(s.BundleVersion("3.5.0"), Path.Combine(all, "RoadPro.bundle"));
            var p = new HubPaths(s.Plugins, all, Path.Combine(s.Root, "data"), s.Root);
            Assert.Equal(new Version(3, 5, 0), p.AllUsersBundle().Version);
        }
    }
}
