using System;
using System.IO;
using System.Linq;
using System.Runtime.Serialization;
using System.Runtime.Serialization.Json;
using System.Text;

namespace RoadPro.Hub.Core
{
    /// <summary>
    /// update.json - published with every GitHub Release next to the setup:
    /// { "version": "3.6.1", "released": "2026-11-12",
    ///   "setupUrl": "https://github.com/.../RoadPro_Setup_v3.6.1.exe",
    ///   "sha256": "64 hex chars", "size": 8584053,
    ///   "notes": "short text", "notesUrl": "https://...", "minimumHub": "3.6.1" }
    /// </summary>
    [DataContract]
    public sealed class UpdateManifest
    {
        [DataMember(Name = "version", Order = 1)] public string VersionText { get; set; }
        [DataMember(Name = "released", Order = 2, EmitDefaultValue = false)] public string Released { get; set; }
        [DataMember(Name = "setupUrl", Order = 3)] public string SetupUrl { get; set; }
        [DataMember(Name = "sha256", Order = 4)] public string Sha256 { get; set; }
        [DataMember(Name = "size", Order = 5)] public long Size { get; set; }
        [DataMember(Name = "notes", Order = 6, EmitDefaultValue = false)] public string Notes { get; set; }
        [DataMember(Name = "notesUrl", Order = 7, EmitDefaultValue = false)] public string NotesUrl { get; set; }
        [DataMember(Name = "minimumHub", Order = 8, EmitDefaultValue = false)] public string MinimumHub { get; set; }

        [IgnoreDataMember]
        public Version Version => Core.VersionText.TryParse(VersionText, out var v) ? v : null;

        [IgnoreDataMember]
        public string FriendlyVersion => Core.VersionText.Friendly(Version);

        /// <summary>Web hosts a setup may be downloaded from.</summary>
        public static readonly string[] TrustedHosts =
        {
            "github.com", "objects.githubusercontent.com", "release-assets.githubusercontent.com",
            "www.exceltokml.com", "exceltokml.com"
        };

        public static UpdateManifest Parse(string json)
        {
            if (string.IsNullOrWhiteSpace(json)) throw new UpdateException("The update information is empty.");
            UpdateManifest m;
            try
            {
                var ser = new DataContractJsonSerializer(typeof(UpdateManifest));
                using (var ms = new MemoryStream(Encoding.UTF8.GetBytes(json.Trim().TrimStart('﻿'))))
                    m = (UpdateManifest)ser.ReadObject(ms);
            }
            catch (Exception ex)
            {
                throw new UpdateException("The update information could not be read (" + ex.Message + ").");
            }
            m.Validate();
            return m;
        }

        public string ToJson()
        {
            var ser = new DataContractJsonSerializer(typeof(UpdateManifest));
            using (var ms = new MemoryStream())
            {
                ser.WriteObject(ms, this);
                return Encoding.UTF8.GetString(ms.ToArray());
            }
        }

        public void Validate()
        {
            if (Version == null) throw new UpdateException("The update has no valid version number.");
            if (string.IsNullOrWhiteSpace(Sha256) || Sha256.Trim().Length != 64 || !Sha256.Trim().All(Uri.IsHexDigit))
                throw new UpdateException("The update has no valid SHA-256 check code.");
            if (Size <= 0) throw new UpdateException("The update has no file size.");
            if (!Uri.TryCreate(SetupUrl, UriKind.Absolute, out var u))
                throw new UpdateException("The update has no valid download address.");
            if (u.Scheme != Uri.UriSchemeHttps && u.Scheme != Uri.UriSchemeFile)
                throw new UpdateException("The update download must use https.");
            if (MinimumHub != null && !Core.VersionText.TryParse(MinimumHub, out _))
                throw new UpdateException("The update has an invalid minimum Hub version.");
        }

        /// <summary>
        /// The setup must come from a trusted web host; a local file is only
        /// accepted when the manifest itself was read from a local file (testing).
        /// </summary>
        public bool IsTrustedSource(string manifestUrl)
        {
            var u = new Uri(SetupUrl);
            if (u.Scheme == Uri.UriSchemeFile)
                return Uri.TryCreate(manifestUrl, UriKind.Absolute, out var mu) && mu.Scheme == Uri.UriSchemeFile;
            return TrustedHosts.Any(h => string.Equals(h, u.Host, StringComparison.OrdinalIgnoreCase));
        }
    }

    public sealed class UpdateException : Exception
    {
        public UpdateException(string message) : base(message) { }
    }
}
