<p align="center">
  <img src="hub/src/RoadPro.Hub/Assets/RoadPro_256.png" width="96" alt="RoadPro" />
</p>

<h1 align="center">RoadPro</h1>
<p align="center"><b>Road builder for AutoCAD and Civil 3D</b><br/>
Roads, junctions, roundabouts, corridor, pavement, markings, signs and cross sections, from one centre line.</p>

---

## Download

**[⬇ Download RoadPro (latest setup)](https://github.com/Asjad-Mehmood/Road-pro/releases/latest/download/RoadPro_Setup.exe)**, or pick a version on the [Releases](https://github.com/Asjad-Mehmood/Road-pro/releases) page, and run it.
No administrator rights are needed. The setup installs **RoadPro Hub** and the AutoCAD plugin.

**Works with:** AutoCAD 2013 or newer, Civil 3D, Map 3D and other AutoCAD-based programs (not AutoCAD LT), on Windows 7 SP1 / 10 / 11 with .NET Framework 4.8.

## RoadPro Hub

A small Windows app that looks after RoadPro:

- installs, updates, repairs and uninstalls the AutoCAD plugin in one click
- keeps the previous version as a backup, so you can go back
- lists the AutoCAD / Civil 3D versions on the computer
- opens the user guide, shortcut keys, what's new and the test report
- **automatic updates**: checks this repository's Releases when it opens and once a day at Windows start,
  downloads the new setup, verifies its size and SHA-256 and installs it (Hub and plugin); "Skip this version" is possible
- AutoCAD shows a notice at start-up when an update is waiting; the `RDHUB` command opens the Hub

After installing, start AutoCAD: RoadPro loads in every drawing. Type `RDP` to build a road and `RDHELP` for all commands.

## Repository layout

| Folder | What is inside |
|---|---|
| `plugin/RoadPro.bundle` | the AutoCAD plugin (Autodesk ApplicationPlugins bundle): `RoadPro.lsp`, `RP_PAVER.pat`, `PackageContents.xml` |
| `hub/` | RoadPro Hub (C#): `RoadPro.Hub` WPF app (.NET Framework 4.8), `RoadPro.Hub.Core` logic library, unit tests |
| `installer/` | Inno Setup script for `RoadPro_Setup.exe`, wizard art, licence terms |
| `docs/` | user guide, shortcut keys, what's new, test report |
| `.github/workflows` | builds and tests everything on Windows for every push |
| `version.txt` | the last released version of the setup and RoadPro Hub (e.g. 3.6.2), used by builds that are not a release (a release takes its version from its tag); the AutoCAD plugin keeps its own version in `PackageContents.xml` and `RoadPro.lsp` (e.g. 3.6.1) |

## Build

Every push to `main` builds the setup on GitHub Actions (Windows). The run:

1. checks the versions: the release number (the tag, else `version.txt`) is valid, and `PackageContents.xml` and `RoadPro.lsp` show the same plugin version
2. runs the Hub unit tests
3. builds RoadPro Hub and installs / uninstalls the plugin from the command line
4. builds `RoadPro_Setup_vX.Y.Z.exe` with Inno Setup and a test "next version" setup
5. installs the setup silently, updates it to the next version through the Hub, checks a tampered update is refused, uninstalls
6. attaches the setup and screenshots to the run (Actions -> the run -> Artifacts)

**Publishing a release:** on github.com: *Releases → Draft a new release → tag* `v3.6.3` *→ Publish*. The tag is the version: nothing has to be edited first. Optional: a few lines for the new version in `docs/RoadPro_WhatsNew.txt` (the release notes are made from it), and the plugin version if the plugin changed.
The setup and `update.json` are attached to a new GitHub Release automatically, and every installed Hub offers the update.

Local build on Windows: Visual Studio 2022 (".NET desktop development"), open `hub/RoadProHub.sln`; then
`ISCC.exe /DAppVersion=1.0.0 installer\RoadProHub.iss` with Inno Setup 6.

Command line (used by the setup):

```
RoadProHub.exe /installplugin [/quiet]     install / update the plugin
RoadProHub.exe /uninstallplugin [/quiet]   remove the plugin
RoadProHub.exe /checkupdates               Windows start-up check (prompt only when an update waits)
RoadProHub.exe /autoupdate [/manifest=URL] check, download, verify and install without a window
```

### How updates work

Each tagged release carries `RoadPro_Setup_vX.Y.Z.exe` and `update.json` (version, download address, size, SHA-256).
The Hub reads `releases/latest/download/update.json`, compares versions, downloads the setup only from github.com
(or exceltokml.com), checks size and SHA-256, then runs it silently; the setup closes and reopens the Hub.
The previous plugin is kept as a backup. Every build tests a real update from this version to the next one,
and that a tampered download is refused.

## Roadmap

- [x] **Phase 1:** RoadPro Hub app and setup program
- [x] **Phase 2:** automatic updates (Hub and plugin)
- [ ] **Phase 3:** code protection and licence (optional)
- [ ] **Phase 4:** public launch (release 1.0.0)

## Licence

Copyright © 2026 [exceltokml.com](https://www.exceltokml.com/). All rights reserved.
The source is published so it can be read and checked. RoadPro is free to use; see [installer/EULA.txt](installer/EULA.txt).
Redistribution or publishing modified copies needs written permission.

Developed by [www.exceltokml.com](https://www.exceltokml.com/) · SurveyX Digital
