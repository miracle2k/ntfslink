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

unit ColumnHook;

interface

uses
  Windows, SysUtils, ActiveX, ComObj, ShlObj, ShellObjExtended, CommCtrl,
  BaseExtensionFactory;

type
  TColunnHook = class(TComObject, IColumnProvider)
  public
    { IColumnProvider }
    function IColumnProvider.Initialize = SEIInitialize;
    function SEIInitialize(psci: PSHCOLUMNINIT): HResult; stdcall;
    function GetColumnInfo(dwIndex: DWORD; psci: PSHCOLUMNINFO): HResult; stdcall;
    function GetItemData(pscid: PSHCOLUMNID; pscd: PSHCOLUMNDATA; pvarData: Variant): HResult; stdcall;
  end;

  TColumnHookFactory = class(TBaseExtensionFactory)
  protected
    function GetInstallationKey: string; override;
  public
    procedure UpdateRegistry(Register: Boolean); override;    
  end;

const
  Class_ColumnHook: TGUID = '{23AB7EA6-C2FF-44D2-956D-0D28420A1354}';

implementation

uses
  ComServ, JclRegistry, Global, Variants;

{ TColunnHook }

function TColunnHook.GetColumnInfo(dwIndex: DWORD;
  psci: PSHCOLUMNINFO): HResult;
begin
  case dwIndex of
    0: begin
         psci.scid.fmtid := Class_ColumnHook;
         psci.scid.pid := 0;
         psci.vt := VT_INT;
         psci.fmt := LVCFMT_LEFT;
         psci.cChars := 32;
         psci.csFlags :=  SHCOLSTATE_TYPE_STR;
         //StringToWideChar('Test'#0, psci.wszTitle, sizeof(psci.wszTitle));
         //StringToWideChar('Test'#0, psci.wszTitle, SizeOf(psci.wszDescription));
       end;

    1: begin
       end;
  end;

  if dwIndex > 0 then Result := S_FALSE
  else Result := S_OK;
end;

function TColunnHook.GetItemData(pscid: PSHCOLUMNID; pscd: PSHCOLUMNDATA;
  pvarData: Variant): HResult;
begin
  if IsEqualGUID(pscid.fmtid, Class_ColumnHook) then begin
    case pscid.pid of
      0: begin
           pvarData := 13434; 
           Result := S_OK;
         end;
      else
        Result := S_FALSE;
    end;
  end
  else
    Result := S_FALSE;
end;

function TColunnHook.SEIInitialize(psci: PSHCOLUMNINIT): HResult;
begin
  Result := S_OK;
end;

{ TColumnHookFactory }

function TColumnHookFactory.GetInstallationKey: string;
begin
  Result := 'Folder\shellex\ColumnHandlers\NTFSLink';
end;

procedure TColumnHookFactory.UpdateRegistry(Register: Boolean);
var
  ClassIDStr: string;
begin
  if Register then
  begin
    inherited UpdateRegistry(Register);

    // Convert ClassID GUID to a string
    ClassIDStr := GUIDToString(ClassId);
    // Register the extension using the key provided by a direved classes
    CreateRegKey(GetInstallationKey, '', ClassIDStr, HKEY_CLASSES_ROOT);
    CreateRegKey('Test', '', ClassIDStr, HKEY_CLASSES_ROOT);
    // Approve extension (so users with restricted rights may use it too)
    ApproveExtension(ClassIDStr, Description);
  end
  else begin
    // Otherwise delete the extension
    DeleteRegKey(GetInstallationKey);
    inherited UpdateRegistry(Register);
  end;
end;

initialization
// TODO Is this really a useful feature? I currently are not convinced it is.
// Until this changes, this extension will be deactivated. Note that it is
// *not* completed yet - still a lot of work to do here.

//  TColumnHookFactory.Create(ComServer, TColunnHook, Class_ColumnHook, '',
//      'NTFSLink Column Extension', ciMultiInstance, tmApartment);

end.
