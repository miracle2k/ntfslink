[Setup]
; Changing the AppID requires changes in code section!
AppID=ntfslink
AppName=NTFS Link
AppVerName=NTFS Link 2.0
AppCopyright=Copyright ©2004 by Michael Elsdörfer
DefaultDirName={pf}\NTFS Link
AlwaysRestart=yes
Compression=bzip
PrivilegesRequired=poweruser
MinVersion=0,5.0.2195
UsePreviousUserInfo=false
AllowNoIcons=true
ShowLanguageDialog=yes
SolidCompression=true
LicenseFile=..\Setup\gpl.txt
ChangesAssociations=true
DefaultGroupName=NTFS Link
OutputDir=..\
SourceDir=..\ntfslink-temp
OutputBaseFilename=ntfslink

[Dirs]
Name: {app}\locale
Name: {app}\locale\de
Name: {app}\locale\de\LC_MESSAGES

[Files]
Source: locale\de\LC_MESSAGES\default.mo; DestDir: {app}\locale\de\LC_MESSAGES
Source: ConfigUtil.exe; DestDir: {app}
Source: ntfslink.dll; DestDir: {app}; Flags: regserver uninsrestartdelete;

[Icons]
Name: {group}\Configure NTFS Link; Filename: {app}\ConfigUtil.exe; WorkingDir: {app}; IconFilename: {app}\ConfigUtil.exe; IconIndex: 0; Flags: createonlyiffileexists; Languages: English
Name: {group}\NTFS Link Homepage; Filename: {app}\NTFSLink.url
Name: {group}\NTFS Link konfigurieren; Filename: {app}\ConfigUtil.exe; WorkingDir: {app}; IconFilename: {app}\ConfigUtil.exe; IconIndex: 0; Flags: createonlyiffileexists; Languages: Deutsch
Name: {group}\Uninstall NTFS Link; Filename: {uninstallexe}; Languages: English
Name: {group}\NTFS Link deinstallieren; Filename: {uninstallexe}; Languages: Deutsch

[Languages]
Name: English; MessagesFile: compiler:Default.isl
Name: Deutsch; MessagesFile: Compiler:Languages\German.isl

[INI]
Filename: {app}\NTFSLink.url; Section: InternetShortcut; Key: URL; String: http://www.elsdoerfer.net/ntfslink/

[UninstallDelete]
Type: files; Name: {app}\NTFSLink.url

[Registry]
Root: HKLM; Subkey: Software\elsdoerfer.net\NTFS Link\Config; Flags: uninsdeletekey

[CustomMessages]
English.AlreadyInstalled=An older version of NTFS Link was found. You have to uninstall every previous version, before you can continue. Do you want to uninstall the old version now?
English.UninstallationFailed=Uninstallation failed. You you want to continue with the installation of the new version?
Deutsch.AlreadyInstalled=Eine alte Version von NTFS Link wurde gefunden. Sie müssen ältere Versionen deinstallieren, bevor sie die Installation fortsetzen können. Wollen sie die Deinstallation der alten Version nun starten?
Deutsch.UninstallationFailed=Deinstallation fehlgeschlagen. Wollen sie trotzdem mit der Installation der neuen Version fortfahren?

[Code]
function QueryUninstallKey(RootKey: Integer; AppID: string; var UninstallExec: string): boolean;
begin
  Result := RegQueryStringValue(RootKey, 'Software\Microsoft\Windows\CurrentVersion\Uninstall\'+AppID+'_is1',
                                         'QuietUninstallString', UninstallExec);
end;

function GetUninstallExec(AppID: string): String;
var
  UninstallExec: string;
begin
  if not QueryUninstallKey(HKLM, AppID, UninstallExec) then
    QueryUninstallKey(HKCU, AppID, UninstallExec);
  Result := UninstallExec;
end;

procedure SplitCommandLine(Command: string; var FileName, Parameters: string);
var
  SpaceSep: Integer;
  i: Integer;
  InQuote: boolean;
begin
  // Get the first space character
  SpaceSep := 0;
  InQuote := False;
  for i := 1 to Length(Command) do
    if Command[i] = '"' then InQuote := not InQuote
    else if Command[i] = ' ' then
      if not InQuote then begin
        SpaceSep := i;
        break;
      end;
  
  // Split command
  if SpaceSep > 0 then begin
    FileName := Copy(Command, 1, SpaceSep - 1);
    Parameters := Copy(Command, SpaceSep + 1, Length(Command));
  end else begin
    FileName := Command;
    Parameters := '';
  end;
end;

function InitializeSetup(): Boolean;
var
	UnInstallExec: string;
	UnInstallProgram, UnInstallParams: string;
	ErrorCode: Integer;
begin
  UnInstallExec := GetUninstallExec('ntfslink');  // THIS MUST BE THE APPID!
  SplitCommandLine(UnInstallExec, UnInstallProgram, UnInstallParams);
  
  Result := False;
  if (Length(UnInstallExec) > 0) then
  begin
    if MsgBox(ExpandConstant('{cm:AlreadyInstalled}'), mbConfirmation, MB_YESNO) = IDYES then
    begin
      if not ShellExec('open', UnInstallProgram, UnInstallParams, '', SW_SHOW, ewWaitUntilTerminated, ErrorCode) then
      begin
        if MsgBox(ExpandConstant('{cm:UninstallationFailed}') + #13#10 + SysErrorMessage(ErrorCode), mbConfirmation, MB_YESNO) = IDYES then
          Result := True;
      end
      else
        Result := True;
    end;
  end
  else
    Result := True;
end;

(*var
  LogOffPage: TInputOptionWizardPage;
  
procedure InitializeWizard;
begin
  { Create the pages }
  LogOffPage := CreateInputOptionPage(wpInstalling,
     'Installation Completed', 'Installation of NTFS Link successfully completed.',
     'Before you can use NTFS Link, you have to log off and re-logon first. Do you want to do this now?', True, False);
  LogOffPage.Add('Yes, Log off now');
  LogOffPage.Add('No, I will Log off later');
end;

function ShouldSkipPage(PageID: Integer): Boolean;
begin
  if PageID = wpFinished then
    Result := True
  else
    Result := False;
end;

procedure CurPageChanged(CurPageID: Integer);
begin
  if CurPageID = LogOffPage.ID then
    WizardForm.NextButton.Caption := SetupMessage(msgButtonFinish);
end;


// from winuser.h
const EWX_LOGOFF = 0;
const EWX_SHUTDOWN = 1;
const EWX_REBOOT = 2;
const EWX_FORCE = 4;
const EWX_POWEROFF = 8;

function ExitWindowsEx(
	uFlags: Longint;
	dwReserved: LongInt ) : Integer;
external 'ExitWindowsEx@user32.dll stdcall';

function GetLastError( ) : Integer;
external 'GetLastError@kernel32.dll';

function Reboot(): Boolean;
var answ: Integer; CrLf: String;
    ercode: Integer;
begin
 Result := False;
 exit;
  CrLf := #13#10;

  // if is nt alogged on an Admin ask if wants logoff
  if not IsAdminLoggedOn then
  begin
    // anyway cannot continue setup
    Result := false;

    answ := MsgBox( 'User logged on is not an Administrator, please logoff and logon as administrator.' +
      CrLf + 'Do you want lo logoff now ?', mbConfirmation, MB_YESNO );

    if answ = IDYES then
    begin
      answ := ExitWindowsEx( EWX_LOGOFF, 0 );
      // if answ is 0 Exitwindows had erros so show error message
      if answ = 0 then
      begin
        ercode := GetLastError();
        MsgBox( 'Logoff error' + CrLf +
          IntToStr(ercode) + ':' + SysErrorMessage( ercode ), mbError, MB_OK );
      end;
    end;
  end;
end;    *)
