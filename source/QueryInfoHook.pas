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

unit QueryInfoHook;

interface

uses          
  Windows, SysUtils, ActiveX, ComObj, ShlObj;

type
  TQueryInfoHook = class(TComObject, IQueryInfo, IPersistFile)
  private
    FFileName: string;
  public
    { IQueryInfo }
    function GetInfoTip(dwFlags: DWORD; var ppwszTip: PWideChar): HResult; stdcall;
    function GetInfoFlags(out pdwFlags: DWORD): HResult; stdcall;
    { IPersistFile }
    function GetClassID(out classID: TCLSID): HResult; stdcall;
    function IsDirty: HResult; stdcall;
    function Load(pszFileName: POleStr; dwMode: Longint): HResult;
      stdcall;
    function Save(pszFileName: POleStr; fRemember: BOOL): HResult;
      stdcall;
    function SaveCompleted(pszFileName: POleStr): HResult;
      stdcall;
    function GetCurFile(out pszFileName: POleStr): HResult;
      stdcall;
  end;

  TQueryInfoHookFactory = class(TComObjectFactory)
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;

const
  Class_QueryInfoHook: TGUID = '{99471CEB-396C-430D-9E14-623C9A6261CD}';

implementation

uses
  ComServ, JclRegistry, Global;

{ TQueryInfoHook }

function TQueryInfoHook.GetClassID(out classID: TCLSID): HResult;
begin
  Result := E_NOTIMPL;
end;

function TQueryInfoHook.GetCurFile(out pszFileName: POleStr): HResult;
begin
  Result := E_NOTIMPL;
end;

function TQueryInfoHook.GetInfoFlags(out pdwFlags: DWORD): HResult;
begin
  Result := E_NOTIMPL;
end;

function TQueryInfoHook.GetInfoTip(dwFlags: DWORD;
  var ppwszTip: PWideChar): HResult;
begin
  ppwszTip := 'Mein Tipp';
  Result := S_OK;
end;

function TQueryInfoHook.IsDirty: HResult;
begin
  Result := E_NOTIMPL;
end;

function TQueryInfoHook.Load(pszFileName: POleStr;
  dwMode: Integer): HResult;
begin
  FFileName := pszFileName;
  Result := S_OK;
end;

function TQueryInfoHook.Save(pszFileName: POleStr;
  fRemember: BOOL): HResult;
begin
  Result := E_NOTIMPL;
end;

function TQueryInfoHook.SaveCompleted(pszFileName: POleStr): HResult;
begin
  Result := E_NOTIMPL;
end;

{ TQueryInfoHookFactory }

procedure TQueryInfoHookFactory.UpdateRegistry(Register: Boolean);
var
  ClassIDStr: string;
  InstallationKey: string;
begin
  // Store the key we need to create (or delete) in a local variable
  InstallationKey := 'txtfile\shellex\{00021500-0000-0000-C000-000000000046}';

  if Register then
  begin
    inherited UpdateRegistry(Register);      

    // Convert ClassID GUID to a string
    ClassIDStr := GUIDToString(ClassId);

    // Register the IconOverlay extension
    CreateRegKey(InstallationKey, '', ClassIDStr, HKEY_CLASSES_ROOT);

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
//  TQueryInfoHookFactory.Create(ComServer, TQueryInfoHook, Class_QueryInfoHook,
//      '', 'NTFSLink QueryInfo Shell Extension', ciMultiInstance, tmApartment);

end.
