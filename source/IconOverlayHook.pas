{-----------------------------------------------------------------------------
The contents of this file are subject to the GNU General Public License
Version 1.1 or later (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at
http://www.gnu.org/copyleft/gpl.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Initial Developer of the Original Code is Michael Elsdörfer.
All Rights Reserved.

You may retrieve the latest version of this file at the NTFS Link Homepage
located at http://www.elsdoerfer.net/?pid=ntfslink

Known Issues:
-----------------------------------------------------------------------------}

unit IconOverlayHook;

interface

uses          
  Windows, SysUtils, ActiveX, ComObj, ShlObj;

type
  // Base class for our IconOverlay COM objects (we need two: one for junctions,
  // another one for hardlinks); Provides base functionality, namely looking
  // for configuration options in the registry
  TIconOverlayHook = class(TComObject, IShellIconOverlayIdentifier)
  protected
    // File containing the overlay icon, and the index of the icon
    ConfigIconFile: string;
    ConfigIconIndex: Integer;
    // The value we return in IShellIconOverlayIdentifier.GetPriority()
    ConfigOverlayPriority: Cardinal;

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
  public
    constructor Create; reintroduce;
  end;

  // TODO add comment
  TIconOverlayHookClass = class of TIconOverlayHook;

  // Icon Overlay Hook for JunctionPoints
  TJunctionOverlayHook = class(TIconOverlayHook)
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

  /// ComObjectFactory for our IconOverlay objects
  TIconOverlayHookFactory = class(TComObjectFactory)
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;  

const
  Class_JunctionOverlayHook: TGUID = '{61702EF5-1B33-487F-995F-6FA23F1D6652}';
  Class_HardlinkOverlayHook: TGUID = '{0314E3A0-45DB-4D75-BB86-27B8EF28907B}';  

implementation

uses
  ComServ, JclNTFS, JclRegistry, Global;

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

constructor TIconOverlayHook.Create;
begin
  inherited Create;
  LoadSettings;
end;

function TIconOverlayHook.GetOverlayInfo(pwszIconFile: PWideChar;
  cchMax: Integer; var pIndex: Integer; var pdwFlags: DWORD): HResult;
begin         LoadSettings;
  // We need the string as a PWideChar
  StringToWideChar(ConfigIconFile, pwszIconFile, cchMax);
  
  // Choose pdwFlags value depending on IconIndex config value 
  if ConfigIconIndex <> -1 then begin
    pIndex := ConfigIconIndex;
    pdwFlags := ISIOI_ICONINDEX;
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
           ConfigIconFile + 'OverlayFile',
           '');      // TODO we need the main module here
  ConfigIconIndex := RegReadIntegerDef(
           HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
           ConfigIconFile + 'OverlayIndex',
           -1);
  ConfigOverlayPriority := RegReadIntegerDef(
           HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
           ConfigIconFile + 'OverlayPriority',
           -1);

  // TODO remove this, hack
  ConfigIconFile := 'F:\Developing\Projects\NTFSLink\source\hl_cust.ico';
  ConfigIconIndex := -1;
end;

{ TIconOverlayHookFactory }

procedure TIconOverlayHookFactory.UpdateRegistry(Register: Boolean);
var
  ClassIDStr: string;
  InstallationKey: string;
begin
  // Store the key we need to create (or delete) in a local variable
  InstallationKey := 'SOFTWARE\Microsoft\Windows\CurrentVersion\Explorer\' +
                        'ShellIconOverlayIdentifiers\NTFSLink_' +
                        TIconOverlayHookClass(ComClass).Config_Prefix; 

  if Register then
  begin
    inherited UpdateRegistry(Register);      

    // Convert ClassID GUID to a string
    ClassIDStr := GUIDToString(ClassId);

    // Register the IconOverlay extension
    CreateRegKey(InstallationKey, '', ClassIDStr, HKEY_LOCAL_MACHINE);

    // Approve extension (so users with restricted rights may use it too)
    ApproveExtension(ClassIDStr, Description);
  end
  else
  begin
    DeleteRegKey(InstallationKey);
    inherited UpdateRegistry(Register);
  end;
end;

initialization
  TIconOverlayHookFactory.Create(ComServer, TJunctionOverlayHook,
      Class_JunctionOverlayHook, '',
      'NTFSLink OverlayIcon Shell Extension for JunctionPoints',
      ciMultiInstance, tmApartment);

  TIconOverlayHookFactory.Create(ComServer, THardlinkOverlayHook,
      Class_HardlinkOverlayHook, '',
      'NTFSLink OverlayIcon Shell Extension for Hardlinks',
      ciMultiInstance, tmApartment);

end.
