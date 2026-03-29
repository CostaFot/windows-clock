[Setup]
AppName=Windows Clock
AppVersion={#AppVersion}
AppPublisher=costafot
DefaultDirName={localappdata}\WindowsClock
DisableDirPage=yes
OutputBaseFilename=clock-setup
Compression=lzma
SolidCompression=yes
PrivilegesRequired=lowest
SetupIconFile=clock.ico
UninstallDisplayIcon={app}\clock.ico

[Files]
Source: "clock.exe"; DestDir: "{app}"
Source: "clock.ico"; DestDir: "{app}"

[Icons]
Name: "{userprograms}\Windows Clock"; Filename: "{app}\clock.exe"; IconFilename: "{app}\clock.ico"; Tasks: startmenu

[Tasks]
Name: startmenu; Description: "Create Start Menu shortcut"; Flags: checked
Name: startup; Description: "Start on login"; Flags: unchecked

[Registry]
Root: HKCU; Subkey: "Software\Microsoft\Windows\CurrentVersion\Run"; \
    ValueType: string; ValueName: "WindowsClock"; ValueData: "{app}\clock.exe"; \
    Tasks: startup; Flags: uninsdeletevalue

[Run]
Filename: "{app}\clock.exe"; Description: "Launch Windows Clock"; \
    Flags: postinstall nowait skipifsilent

[UninstallRun]
Filename: "taskkill.exe"; Parameters: "/IM clock.exe /F"; Flags: runhidden
