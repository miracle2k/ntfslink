{-----------------------------------------------------------------------------
The contents of this file are subject to the GNU General Public License
Version 1.1 or later (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at
http://www.gnu.org/copyleft/gpl.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Initial Developer of the Original Code is Michael Elsd�rfer, with
contributions from Sebastian Schuberth.

You can find more information at http://elsdoerfer.name/ntfslink
-----------------------------------------------------------------------------}

unit IconOverlayHook;

interface

uses
  Windows, SysUtils, ComObj, ShlObj, BaseExtensionFactory;

type
  // Base class for our IconOverlay COM objects (we need two: one for junctions,
  // another one for hardlinks); Provides base functionality, namely looking
  // for configuration options in the registry
  TIconOverlayHook = class(TComObject, IShellIconOverlayIdentifier)
  private
    FSettingsLoaded: boolean;
  protected
    // File containing the overlay icon, and the index of the icon
    ConfigIconFile: string;
    ConfigIconIndex: Integer;
    ConfigEnableNetworkDrives: Boolean;
    // The value we return in IShellIconOverlayIdentifier.GetPriority()
    ConfigOverlayPriority: Cardinal;

    // Returns true, if icon overlays should be activated for the drive
    // passed as the paramter; Result depends on drive type.
    function EnableHooksForDrive(Drive: PWideChar): boolean;
    // Tries to load the above configuration values from the registry
    procedure LoadSettings; virtual;
    // Every derived class has it's own set of the configuration values above.
    // But as the loading is done in this base class, we need a way to find
    // out *which* value set we actually want. Every derived class must
    // implement this class method to specify an unique identfier used to
    // differ between the configuration sets.
    class function Config_Prefix: string; virtual; abstract;
    // Default value to use for index, if no configuration value available;
    // See the comment above for more information why it is here.
    class function Config_IconIndex_Default: Integer; virtual; abstract;

    { IShellIconOverlayIdentifier }
    function IsMemberOf(pwszPath: PWideChar; dwAttrib: DWORD): HResult; stdcall;
    function GetOverlayInfo(pwszIconFile: PWideChar; cchMax: Integer;
      var pIndex: Integer; var pdwFlags: DWORD): HResult; stdcall;
    function GetPriority(out pIPriority: Integer): HResult; stdcall;
  end;

  // We need this type later to access the static class methods
  TIconOverlayHookClass = class of TIconOverlayHook;

  // Icon Overlay Hook for JunctionPoints
  TJunctionOverlayHook = class(TIconOverlayHook, IShellIconOverlayIdentifier)
  protected
    class function Config_Prefix: string; override;
    class function Config_IconIndex_Default: Integer; override;
  public
    { IShellIconOverlayIdentifier }
    function IsMemberOf(pwszPath: PWideChar; dwAttrib: DWORD): HResult; stdcall;
  end;

  // Icon Overlay Hook for Hardlinks
  THardlinkOverlayHook = class(TIconOverlayHook, IShellIconOverlayIdentifier)
  protected
    class function Config_Prefix: string; override;
    class function Config_IconIndex_Default: Integer; override;
  public
    { IShellIconOverlayIdentifier }
    function IsMemberOf(pwszPath: PWideChar; dwAttrib: DWORD): HResult; stdcall;
  end;

  // Icon Overlay Hook for Hardlinks
  TBrokenHardlinkOverlayHook = class(TIconOverlayHook, IShellIconOverlayIdentifier)
  protected
    class function Config_Prefix: string; override;
    class function Config_IconIndex_Default: Integer; override;
  public
    { IShellIconOverlayIdentifier }
    function IsMemberOf(pwszPath: PWideChar; dwAttrib: DWORD): HResult; stdcall;
  end;

  /// ComObjectFactory for our IconOverlay objects
  TIconOverlayHookFactory = class(TBaseExtensionFactory)
  protected
    function GetInstallationData: TExtensionRegistryData; override;
  end;

const
  Class_JunctionOverlayHook       : TGUID = '{61702EF5-1B33-487F-995F-6FA23F1D6652}';
  Class_HardlinkOverlayHook       : TGUID = '{0314E3A0-45DB-4D75-BB86-27B8EF28907B}';
  Class_BrokenHardlinkOverlayHook : TGUID = '{A11BFC65-EBEE-4C48-8B87-65F206D4F6F6}';

implementation

uses
  ComServ, JclNTFS, JclRegistry, Constants, Classes, Global;

{ TJunctionOverlayHook }

class function TJunctionOverlayHook.Config_IconIndex_Default: Integer;
begin
  Result := OVERLAY_JUNCTION_ICONINDEX;
end;

class function TJunctionOverlayHook.Config_Prefix: string;
begin
  Result := 'Junction';
end;

function TJunctionOverlayHook.IsMemberOf(pwszPath: PWideChar;
  dwAttrib: DWORD): HResult;
begin
  Result := S_FALSE;

  // IconOverlays are disabled for some drive types (e.g. remote)
  if not EnableHooksForDrive(pwszPath) then
    exit;

  try
    if NtfsFileHasReparsePoint(pwszPath) then
      Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

{ THardlinkOverlayHook }

class function THardlinkOverlayHook.Config_IconIndex_Default: Integer;
begin
  Result := OVERLAY_HARDLINK_ICONINDEX;
end;

class function THardlinkOverlayHook.Config_Prefix: string;
begin
  Result := 'Hardlink';
end;

function THardlinkOverlayHook.IsMemberOf(pwszPath: PWideChar;
  dwAttrib: DWORD): HResult;
var
  LinkInfo: TNtfsHardLinkInfo;
begin
  Result := S_FALSE;

  // IconOverlays are disabled for some drive types (e.g. remote)
  if not EnableHooksForDrive(pwszPath) then
    exit;

  try
    // Retrieve file information, and look if there are links existing; if no,
    // than this file is *not* a link, and we skip
    if NtfsGetHardLinkInfo(pwszPath, LinkInfo) then
      if LinkInfo.LinkCount > 1 then
        Result := S_OK;
  except
    Result := E_UNEXPECTED;
  end;
end;

{ TIconOverlayHook }

function TIconOverlayHook.EnableHooksForDrive(Drive: PWideChar): boolean;
var
  DriveType: Cardinal;
begin
  DriveType := GetDriveType(PWideChar(ExtractFileDrive(Drive)));
  Result := (DriveType = DRIVE_FIXED) or (DriveType = DRIVE_RAMDISK);
end;

function TIconOverlayHook.GetOverlayInfo(pwszIconFile: PWideChar;
  cchMax: Integer; var pIndex: Integer; var pdwFlags: DWORD): HResult;
begin
  // The first time this is called, we have to make sure that the settings
  // are loaded from the registry. I guess it should be possible to do this
  // *somehow* in the constructor, but TComObject.Create is not virtual, so we
  // cannot override it. Our constructor is never called, because we have to
  // use TComObjectFactory to instantiate the class.
  if not FSettingsLoaded then LoadSettings;

  // We need the string as a PWideChar
  StringToWideChar(ConfigIconFile, pwszIconFile, cchMax);

  // Choose pdwFlags value depending on IconIndex config value
  if ConfigIconIndex <> -1 then begin
    pIndex := ConfigIconIndex;
    pdwFlags := ISIOI_ICONFILE or ISIOI_ICONINDEX;
  end
  else
    PdwFlags := ISIOI_ICONFILE;

  // Return success
  Result := S_OK;
end;

function TIconOverlayHook.GetPriority(out pIPriority: Integer): HResult;
begin
  pIPriority := ConfigOverlayPriority;
  Result := S_OK;
end;

function TIconOverlayHook.IsMemberOf(pwszPath: PWideChar;
  dwAttrib: DWORD): HResult;
begin
  Result := E_NOTIMPL;
end;

procedure TIconOverlayHook.LoadSettings;
begin
  ConfigIconFile := RegReadStringDef(
           HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
           Config_Prefix + 'OverlayFile',
           '');
  if ConfigIconFile = '' then
    ConfigIconFile := GetModuleName(HINSTANCE);
  ConfigIconIndex := RegReadIntegerDef(
           HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
           Config_Prefix + 'OverlayIndex',
           -1);
  if ConfigIconIndex = -1 then
    ConfigIconIndex := Config_IconIndex_Default;
  ConfigOverlayPriority := RegReadIntegerDef(
           HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
           Config_Prefix + 'OverlayPriority',
           OVERLAY_PRIORITY_DEFAULT);
  ConfigEnableNetworkDrives := RegReadBoolDef(
           HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
           'EnableRemoveDriveIconOverlays', False);
  FSettingsLoaded := True;
end;

{ TBrokenHardlinkOverlayHook }

class function TBrokenHardlinkOverlayHook.Config_IconIndex_Default: Integer;
begin
  Result := OVERLAY_BROKEN_HARDLINK_ICONINDEX;
end;

class function TBrokenHardlinkOverlayHook.Config_Prefix: string;
begin
  Result := 'BrokenHardlink';
end;

function TBrokenHardlinkOverlayHook.IsMemberOf(pwszPath: PWideChar; dwAttrib:
    DWORD): HResult;
var
  ReCreateHardlinkFileName : string;
  RecreateCmds : TStringList;
  SourceLink : string;
  Links : TStrings;
begin
  Result := S_FALSE;

  // IconOverlays are disabled for some drive types (e.g. remote)
  if not EnableHooksForDrive(pwszPath) then
    exit;

  try
    ReCreateHardlinkFileName := ExtractFilePath(pwszPath) + RECREATE_HARDLINKS_FILENAME;
    if FileExists(ReCreateHardlinkFileName) then
      begin
        RecreateCmds := TStringList.Create;
        try
          RecreateCmds.LoadFromFile(ReCreateHardlinkFileName);
          if MatchFileAgainstRecreateHardlinksCmdFile(pwszPath, RecreateCmds, SourceLink) >= 0 then
            begin
              Links := TStringList.Create;
              try
                GetHardLinks(pwszPath, Links);
                if Links.IndexOf(SourceLink) < 0 then
                  Result := S_OK;
              finally
                Links.Free;
              end;
            end;
        finally
          RecreateCmds.Free;
        end;
      end;
  except
    Result := E_UNEXPECTED;
  end;
end;

{ TIconOverlayHookFactory }

function TIconOverlayHookFactory.GetInstallationData: TExtensionRegistryData;
begin
  Result.RootKey := HKEY_LOCAL_MACHINE;
  Result.BaseKey := 'Software\Microsoft\Windows\CurrentVersion\Explorer\' +
                    'ShellIconOverlayIdentifiers\0NTFSLink_' +
                    TIconOverlayHookClass(ComClass).Config_Prefix;
  Result.UseGUIDAsKeyName := False;
end;

initialization
  TIconOverlayHookFactory.Create(ComServer, THardlinkOverlayHook,
      Class_HardlinkOverlayHook, '',
      'NTFSLink OverlayIcon Shell Extension for Hardlinks',
      ciMultiInstance, tmApartment);

  TIconOverlayHookFactory.Create(ComServer, TJunctionOverlayHook,
      Class_JunctionOverlayHook, '',
      'NTFSLink OverlayIcon Shell Extension for JunctionPoints',
      ciMultiInstance, tmApartment);

  TIconOverlayHookFactory.Create(ComServer, TBrokenHardlinkOverlayHook,
      Class_BrokenHardlinkOverlayHook, '',
      'NTFSLink OverlayIcon Shell Extension for Broken Hardlinks',
      ciMultiInstance, tmApartment);

end.
