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
located at http://www.elsdoerfer.net/ntfslink/

Known Issues:
-----------------------------------------------------------------------------}

unit ContextMenuHook;

interface
uses          
  Windows, SysUtils, ActiveX, ComObj, ShlObj, BaseExtensionFactory;

type
  TContextMenuHook = class(TComObject, IShellExtInit, IContextMenu)
  private
    FFileName: string;
  public
    { IShellExtInit }
    function IShellExtInit.Initialize = SEIInitialize; // Avoid compiler warning
    function SEIInitialize(pidlFolder: PItemIDList; lpdobj: IDataObject;
      hKeyProgID: HKEY): HResult; stdcall;
    { IContextMenu }
    function QueryContextMenu(Menu: HMENU; indexMenu, idCmdFirst, idCmdLast,
      uFlags: UINT): HResult; stdcall;
    function InvokeCommand(var lpici: TCMInvokeCommandInfo): HResult; stdcall;
    function GetCommandString(idCmd, uType: UINT; pwReserved: PUINT;
      pszName: LPSTR; cchMax: UINT): HResult; stdcall; 
  end;

  TContextMenuHookFactory = class(TBaseExtensionFactory)
  protected
    function GetInstallationData: TExtensionRegistryData; override;
  end;

const
  Class_ContextMenuHook: TGUID = '{B6E9A8C7-4300-4FB1-AFBD-A44BFDE7E3B1}';

implementation

uses
  ShellAPI, ComServ, JclRegistry, GNUGetText, Global;

{ TContextMenuHook }

function TContextMenuHook.GetCommandString(idCmd, uType: UINT;
  pwReserved: PUINT; pszName: LPSTR; cchMax: UINT): HResult;
begin
  if (idCmd = 0) then begin
    if (uType = GCS_HELPTEXT) then
      // Return nothing, as this is shown nowhere
      StrCopy(pszName, 'Remove the junction point');
      Result := NOERROR;
  end
  else
    Result := E_INVALIDARG;
end;

function TContextMenuHook.InvokeCommand(
  var lpici: TCMInvokeCommandInfo): HResult;
begin
  Result := S_OK;
end;

function TContextMenuHook.QueryContextMenu(Menu: HMENU; indexMenu,
  idCmdFirst, idCmdLast, uFlags: UINT): HResult;
var
  mString: string;
begin                  
  // No items created yet
  Result := MakeResult(SEVERITY_SUCCESS, FACILITY_NULL, 0);

  if (uFlags and $0000000F = CMF_NORMAL) or (uFlags and CMF_EXPLORE <> 0) then
  begin
    mString := _('Unlink Junction');

    // Add our menu item to context menu
    InsertMenu(Menu, indexMenu, MF_STRING or MF_BYPOSITION,
               idCmdFirst, PAnsiChar(mString));

    // Return number of menu items added
    Result := MakeResult(SEVERITY_SUCCESS, FACILITY_NULL, 1);
  end;
end;

function TContextMenuHook.SEIInitialize(pidlFolder: PItemIDList;
  lpdobj: IDataObject; hKeyProgID: HKEY): HResult;
var
  StgMedium: TStgMedium;
  FormatEtc: TFormatEtc;
  tempFile: array[0..MAX_PATH] of Char;
  SrcCount: Integer;
begin
  // Initialize FormatEtc
  with FormatEtc do begin
    cfFormat := CF_HDROP;
    ptd      := nil;
    dwAspect := DVASPECT_CONTENT;
    lindex   := -1;
    tymed    := TYMED_HGLOBAL;
  end;

  // Render the data referenced by the IDataObject pointer to an HGLOBAL
  // storage medium in CF_HDROP format.
  Result := lpdobj.GetData(FormatEtc, StgMedium);
  if Failed(Result) then exit;
  
  // Put all the source files in the StringList
  SrcCount := DragQueryFile(StgMedium.hGlobal, $FFFFFFFF, nil, 0);
  if SrcCount = 1 then begin
    DragQueryFile(StgMedium.hGlobal, 0, tempFile, SizeOf(tempFile));
    FFileName := tempFile;
  end
  else
    Result := E_INVALIDARG;

  // Free resources
  ReleaseStgMedium(StgMedium);
end;

{ TContextMenuHookFactory }

function TContextMenuHookFactory.GetInstallationData: TExtensionRegistryData;
begin
  Result.RootKey := HKEY_CLASSES_ROOT;
  Result.BaseKey := 'Directory\shellex\ContextMenuHandlers\NTFSLink';
  Result.UseGUIDAsKeyName := False;
end;

initialization
  TContextMenuHookFactory.Create(ComServer, TContextMenuHook,
      Class_ContextMenuHook, '', 'NTFSLink ContextMenu Shell Extension',
      ciMultiInstance, tmApartment);

end.      
