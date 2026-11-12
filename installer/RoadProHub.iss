; RoadPro Hub - Windows setup (Inno Setup 6)
; Build:  ISCC.exe /DAppVersion=3.6.2 installer\RoadProHub.iss
; Expects the published Hub in ..\build\hub (see .github/workflows/build.yml).

#ifndef AppVersion
  #define AppVersion "0.0.0"
#endif
#define AppName "RoadPro Hub"
#define AppExe "RoadProHub.exe"
#define Publisher "exceltokml.com"
#define PublisherUrl "https://www.exceltokml.com/"

[Setup]
; never change AppId - Windows uses it to find and upgrade the installed Hub
AppId={{6F3B1C52-2B7E-4C0A-9E57-3E1D1B7C9A41}
AppName={#AppName}
AppVersion={#AppVersion}
AppVerName=RoadPro {#AppVersion}
AppPublisher={#Publisher}
AppPublisherURL={#PublisherUrl}
AppSupportURL={#PublisherUrl}contact
AppUpdatesURL={#PublisherUrl}roadpro
AppCopyright=Copyright (C) 2026 {#Publisher}
VersionInfoVersion={#AppVersion}
VersionInfoDescription=RoadPro for AutoCAD and Civil 3D - setup
; per-user install: no administrator prompt (same as the AutoCAD plugin folder)
PrivilegesRequired=lowest
DefaultDirName={autopf}\RoadPro Hub
DefaultGroupName=RoadPro
DisableProgramGroupPage=yes
DisableDirPage=auto
UsePreviousAppDir=yes
LicenseFile=EULA.txt
OutputDir=Output
OutputBaseFilename=RoadPro_Setup_v{#AppVersion}
SetupIconFile=..\hub\src\RoadPro.Hub\Assets\RoadPro.ico
UninstallDisplayIcon={app}\{#AppExe}
UninstallDisplayName=RoadPro {#AppVersion}
WizardStyle=modern
WizardImageFile=assets\wizard.bmp,assets\wizard_200.bmp
WizardSmallImageFile=assets\wizard_small.bmp,assets\wizard_small_200.bmp
Compression=lzma2/max
SolidCompression=yes
; .NET Framework 4.8 needs Windows 7 SP1 or newer
MinVersion=6.1sp1
CloseApplications=yes
RestartApplications=no

[Languages]
Name: "english"; MessagesFile: "compiler:Default.isl"

[Tasks]
Name: "installplugin"; Description: "Install the RoadPro plugin in AutoCAD / Civil 3D now (recommended)"; GroupDescription: "RoadPro plugin:"
Name: "autoupdate"; Description: "Check for RoadPro updates when Windows starts (once a day)"; GroupDescription: "Updates:"
Name: "desktopicon"; Description: "{cm:CreateDesktopIcon}"; GroupDescription: "{cm:AdditionalIcons}"; Flags: unchecked

[InstallDelete]
; plugin payload and docs are replaced as a whole on every update
Type: filesandordirs; Name: "{app}\payload"
Type: filesandordirs; Name: "{app}\docs"
; an update installed by hand: the "update available" notice in AutoCAD is no longer true
Type: files; Name: "{localappdata}\RoadPro Hub\update-available.txt"

[Files]
Source: "..\build\hub\*"; DestDir: "{app}"; Flags: ignoreversion recursesubdirs createallsubdirs; Excludes: "*.pdb,*.xml"
Source: "..\plugin\RoadPro.bundle\*"; DestDir: "{app}\payload\RoadPro.bundle"; Flags: ignoreversion recursesubdirs createallsubdirs
Source: "..\docs\*"; DestDir: "{app}\payload\RoadPro.bundle\Contents\Docs"; Flags: ignoreversion
Source: "..\docs\*"; DestDir: "{app}\docs"; Flags: ignoreversion

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueType: string; ValueName: "RoadPro Hub"; ValueData: """{app}\{#AppExe}"" /checkupdates"; Flags: uninsdeletevalue; Tasks: autoupdate
; task unticked on an update: remove the start-up check
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; ValueName: "RoadPro Hub"; ValueType: none; Flags: deletevalue; Tasks: not autoupdate

[Icons]
Name: "{autoprograms}\RoadPro Hub"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\RoadPro Hub"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Parameters: "/installplugin /quiet"; StatusMsg: "Installing the RoadPro plugin for AutoCAD..."; Flags: runhidden waituntilterminated; Tasks: installplugin
Filename: "{app}\{#AppExe}"; Description: "Open RoadPro Hub"; Flags: nowait postinstall skipifsilent
; update started from RoadPro Hub (/RELAUNCH=1): open the Hub again when done
Filename: "{app}\{#AppExe}"; Parameters: "/updated"; Flags: nowait; Check: RelaunchHub

[UninstallRun]
Filename: "{app}\{#AppExe}"; Parameters: "/uninstallplugin /quiet"; RunOnceId: "RemoveRoadProPlugin"; Flags: runhidden waituntilterminated

[Code]
function IsDotNet48Installed: Boolean;
var
  Release: Cardinal;
begin
  Result := RegQueryDWordValue(HKLM, 'SOFTWARE\Microsoft\NET Framework Setup\NDP\v4\Full', 'Release', Release)
            and (Release >= 528040);
end;

function RelaunchHub: Boolean;
begin
  Result := ExpandConstant('{param:RELAUNCH|0}') = '1';
end;

function InitializeSetup: Boolean;
begin
  Result := IsDotNet48Installed;
  if not Result then
    MsgBox('RoadPro Hub needs Microsoft .NET Framework 4.8 (built into Windows 10 and 11).' + #13#10 + #13#10 +
           'Please install it from https://dotnet.microsoft.com/download/dotnet-framework/net48 and run this setup again.',
           mbError, MB_OK);
end;
