; Inno Setup installer for the Windows store app.
; ISCC /DStore=wael setup.iss   (or /DStore=sham)
#ifndef Store
  #define Store "wael"
#endif
#if Store == "sham"
  #define AppName "Sham Telecom"
  #define AppExe "ShamTelecom.exe"
  #define AppGuid "{{6E0B7C51-3A1F-4D7E-9B42-5C8D2A1F0E63}"
#else
  #define AppName "Wael Telecom"
  #define AppExe "WaelTelecom.exe"
  #define AppGuid "{{2F4A9D10-8C3E-4B6A-A1D5-7E9F0B3C2D84}"
#endif
#define SrcDir "dist\" + Store

[Setup]
AppId={#AppGuid}
AppName={#AppName}
AppVersion=1.3
AppPublisher={#AppName}
DefaultDirName={localappdata}\Programs\{#AppName}
DefaultGroupName={#AppName}
DisableProgramGroupPage=yes
DisableDirPage=yes
PrivilegesRequired=lowest
OutputDir=out
OutputBaseFilename={#StringChange(AppName, " ", "")}-Setup
SetupIconFile=icons\{#Store}.ico
UninstallDisplayIcon={app}\{#AppExe}
Compression=lzma2/max
SolidCompression=yes
WizardStyle=modern
ArchitecturesAllowed=x64compatible
ArchitecturesInstallIn64BitMode=x64compatible
CloseApplications=yes

[Tasks]
Name: "desktopicon"; Description: "Create a desktop shortcut"; GroupDescription: "Shortcuts:"

[Files]
Source: "{#SrcDir}\*"; DestDir: "{app}"; Flags: recursesubdirs ignoreversion

[Icons]
Name: "{autoprograms}\{#AppName}"; Filename: "{app}\{#AppExe}"
Name: "{autodesktop}\{#AppName}"; Filename: "{app}\{#AppExe}"; Tasks: desktopicon

[Run]
Filename: "{app}\{#AppExe}"; Description: "Open {#AppName}"; Flags: nowait postinstall skipifsilent
