[Setup]
AppName=Scam Line by StormGamesStudios
AppVersion=1.0.4
DefaultDirName={userappdata}\StormGamesStudios\NewGameDir\ScamLine
DefaultGroupName=StormGamesStudios
OutputDir=C:\Users\melio\Documents\GitHub\ScamLine\output
OutputBaseFilename=ScamLine_Launcher_Installer
Compression=lzma
SolidCompression=yes
AppCopyright=Copyright © 2025 StormGamesStudios. All rights reserved.
VersionInfoCompany=StormGamesStudios
AppPublisher=StormGamesStudios
SetupIconFile=ScamLine.ico
VersionInfoVersion=1.0.4.0
DisableDirPage=yes
DisableProgramGroupPage=yes
CloseApplications=no

[Files]
; Archivos del lanzador
Source: "C:\Users\melio\Documents\GitHub\ScamLine\dist\installer_updater.exe"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\melio\Documents\GitHub\ScamLine\ScamLine.ico"; DestDir: "{app}"; Flags: ignoreversion
Source: "C:\Users\melio\Documents\GitHub\ScamLine\ScamLine.png"; DestDir: "{app}"; Flags: ignoreversion

[Icons]
; Acceso directo en el escritorio
; Name: "{userdesktop}\Scam Line"; Filename: "{app}\installer_updater.exe"; IconFilename: "{app}\ScamLine.ico"; Comment: "Lanzador de Scam Line"; WorkingDir: "{app}"

; Acceso directo en el menú de inicio dentro de la carpeta StormGamesStudios
Name: "{commonprograms}\StormGamesStudios\Scam Line"; Filename: "{app}\installer_updater.exe"; IconFilename: "{app}\ScamLine.ico"; Comment: "Lanzador de Scam Line"; WorkingDir: "{app}"
Name: "{commonprograms}\StormGamesStudios\Desinstalar Scam Line"; Filename: "{uninstallexe}"; IconFilename: "{app}\ScamLine.ico"; Comment: "Desinstalar Scam Line"

[Registry]
; Guardar ruta de instalación para poder desinstalar
Root: HKCU; Subkey: "Software\Scam Line"; ValueType: string; ValueName: "Install_Dir"; ValueData: "{app}"

[UninstallDelete]
; Eliminar carpeta del appdata y acceso directo
Type: filesandordirs; Name: "{app}"

[Run]
; Ejecutar el lanzador después de la instalación
Filename: "{app}\installer_updater.exe"; Description: "Ejecutar Scam Line"; Flags: nowait postinstall skipifsilent

[Code]
procedure CloseApp();
var
  ResultCode: Integer;
begin
  // Cierra el actualizador y el launcher si están abiertos
  Exec('taskkill', '/F /IM installer_updater.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('taskkill', '/F /IM win_launcher.exe', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
  Exec('taskkill', '/F /IM "Scam Line.exe"', '', SW_HIDE, ewWaitUntilTerminated, ResultCode);
end;

procedure CurStepChanged(CurStep: TSetupStep);
begin
  // Durante la instalación, cierra cualquier instancia abierta
  if CurStep = ssInstall then
  begin
    CloseApp();
  end;
end;

procedure CurUninstallStepChanged(CurUninstallStep: TUninstallStep);
begin
  // Durante la desinstalación, cierra cualquier instancia abierta
  if CurUninstallStep = usUninstall then
  begin
    CloseApp();
  end;
end;
