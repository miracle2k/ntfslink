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

Development of the extended version has been moved from Novell Forge to
SourceForge by Sebastian Schuberth.

You may retrieve the latest extended version at the "NTFS Link Ext" project page
located at http://sourceforge.net/projects/ntfslinkext/

The original version can still be retrieved from the "NTFS Link" homepage
located at http://www.elsdoerfer.net/ntfslink/
-----------------------------------------------------------------------------}

unit ContextMenuHook;

interface

uses
  Windows, SysUtils, ActiveX, ComObj, ShlObj, BaseExtensionFactory;

// TODO [v2.1] Let the context menu extension operate on multiple folders

type
  // Depending on what object is selected in explorer, we have to provide
  // different menu items and do different things.
  TContextMenuType = (cmmUnkown, cmmEmptyFolder, cmmJunctionPoint);

  TContextMenuHook = class(TComObject, IShellExtInit, IContextMenu)
  private
  private
    FSourceDirMode: TContextMenuType;
    FDirectory: string;
    FJunctionTarget: string;
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
  JclNTFS, JclRegistry, ShellAPI, ComServ, GNUGetText, Global, ShellNewExports,
  Constants, ShellObjExtended;

{ TContextMenuHook }

function TContextMenuHook.GetCommandString(idCmd, uType: UINT;
  pwReserved: PUINT; pszName: LPSTR; cchMax: UINT): HResult;
var
  HelpStr: string;
begin
  HelpStr := '';
  if (uType = GCS_HELPTEXT) then
    case idCmd of
      0:
        HelpStr := _('Link selected folder to another directory or drive');
      1:
        HelpStr := _('Remove this folder''s junction point');
      2:
        HelpStr := _('Open the target of this junction in Windows Explorer');
    end;

  if HelpStr <> '' then begin
    StrCopy(pszName, PAnsiChar(HelpStr));
    Result := S_OK
  end
  else
    Result := E_INVALIDARG;
end;

function TContextMenuHook.InvokeCommand(
  var lpici: TCMInvokeCommandInfo): HResult;
var
  i: integer;
  VolumeName: array[0..MAX_PATH] of Char;
//  VolumeUniqueName, VolumeName, DriveBuf: array[0..MAX_PATH] of Char;
//  temp: Cardinal;
//  FindRec: Cardinal;
begin
  // Make sure we aren't being passed an invalid command id
  case (LoWord(lpici.lpVerb))of
    0:
      begin
        // Call the "Create Junction" dialog
        NewJunctionDlgInternal(lpici.hwnd, FDirectory, False);
        // Notify the explorer, so that our icon overlay will be displayed
        SHChangeNotify(SHCNE_CREATE, SHCNF_PATH, PAnsiChar(FDirectory), nil);
      end;

    1:
      begin
        // Delete the junction point
        NtfsDeleteJunctionPoint(FDirectory);
        // Notify the explorer, so that our icon overlay will be removed
        SHChangeNotify(SHCNE_CREATE, SHCNF_PATH, PAnsiChar(FDirectory), nil);
      end;

    2:
      begin
        // First check if this is a volume mount point using a volume GUID; if
        // so, we have to find out what
        if Pos('Volume{', FJunctionTarget) = 1 then
        begin
//          FindRec := FindFirstVolume(VolumeUniqueName, MAX_PATH);
//          if (FindRec <> INVALID_HANDLE_VALUE) then
//          begin
//            if VolumeUniqueName = ('\\?\' + FJunctionTarget) then begin
//              GetVolumeInformation(VolumeUniqueName, VolumeName, MAX_PATH, nil,
//                                   temp, temp, nil, 0);
//              GetVolumePathNamesForVolumeName(PAnsiChar(FJunctionTarget), DriveBuf , MAX_PATH, temp);
//              FJunctionTarget := DriveBuf;
//              break;
//            end;
//            if not (FindNextVolume(FindRec, VolumeUniqueName, MAX_PATH)) then
//              break;
//          end;
//          FindVolumeClose(FindRec);

          for i := Ord('c') to Ord('z') do begin
            GetVolumeNameForVolumeMountPoint(PAnsiChar(Chr(i) + ':\'), VolumeName, MAX_PATH);
            if VolumeName = ('\\?\' + FJunctionTarget) then
               FJunctionTarget := Chr(i) + ':\';
          end;
        end;
        // Execute explorer
        ShellExecute(0, 'explore', PAnsiChar(FJunctionTarget), nil, nil, SW_NORMAL);
      end;

    else
      begin
        Result := E_INVALIDARG;
        exit;
      end;
  end;

  Result := S_OK;
end;

function TContextMenuHook.QueryContextMenu(Menu: HMENU; indexMenu,
  idCmdFirst, idCmdLast, uFlags: UINT): HResult;
var
  SubMenu: HMENU;

  procedure CreateMenuItem(Menu: HMENU; Caption: string; Glyph: HBITMAP = 0;
    ItemID: Cardinal = 0; ByIndex: Integer = MaxInt; SubMenu: HMENU = 0);
  var
    mii: TMenuItemInfo;
  begin
    // First off, initialize the MENUITEMINFO structure
    with mii do
    begin
      cbSize := SizeOf(TMenuItemInfo);
      // Some members are always passed, reflect that in the default mask
      fMask := MIIM_STRING or MIIM_ID;
      // Initialize this standard members
      wID := ItemID;
      dwTypeData := PAnsiChar(Caption);
      // If a submenu handle is specified, use it + include SUBMENU flag
      if SubMenu <> 0 then begin
        fMask := fMask or MIIM_SUBMENU;
        hSubMenu := SubMenu;
      end;
      // Assign the glyph, if a handle is specified, and include correct flag;
      if Glyph <> 0 then begin
        fMask := fMask or MIIM_CHECKMARKS;
        hbmpUnchecked := Glyph;
        hbmpChecked := Glyph;
      end;
    end;

    // Finally, insert the item
    InsertMenuItem(Menu, ByIndex, True, mii);
  end;

begin
  // No items created yet
  Result := MakeResult(SEVERITY_SUCCESS, FACILITY_NULL, 0);

  if (uFlags and $0000000F = CMF_NORMAL) or (uFlags and CMF_EXPLORE <> 0) then
  begin
    // Create submenu
    SubMenu := CreatePopupMenu;
    CreateMenuItem(Menu, 'NTFS Link', GLYPH_HANDLE_STD, 0, indexMenu, SubMenu);

      // Add items to the submenu, depending on mode
      if FSourceDirMode = cmmEmptyFolder then
        CreateMenuItem(SubMenu, _('Link Folder...'), GLYPH_HANDLE_JUNCTION, idCmdFirst)
      else begin
        CreateMenuItem(SubMenu, Format(_('Unlink From "%s"'), [FJunctionTarget]),
                       GLYPH_HANDLE_LINKDEL, idCmdFirst + 1);
        CreateMenuItem(SubMenu, Format(_('Open "%s"'), [FJunctionTarget]),
                       GLYPH_HANDLE_EXPLORER, idCmdFirst + 2);
      end;

    // The required return value is (according to lastest MSDN) the largest
    // command id *minus* idCmdFirst (that's the offset) *plus* 1.
    // In our case, the larget command id varies, depending on the number of
    // items created. To keep things simple, we will always calculate the
    // return value based on the largest command id used in *any* case, also
    // if in the *current* case we created fewer items (which is a bit a waste
    // of command id's, but who cares :-);
    Result := MakeResult(SEVERITY_SUCCESS, FACILITY_NULL, 3);  // (idCmdFirst + 2) - idCmdFirst + 1
  end;
end;

function TContextMenuHook.SEIInitialize(pidlFolder: PItemIDList;
  lpdobj: IDataObject; hKeyProgID: HKEY): HResult;
var
  StgMedium: TStgMedium;
  FormatEtc: TFormatEtc;
  tempFile: array[0..MAX_PATH] of Char;
  SrcCount: Integer;

  function IsDirectoryEmpty(ADir: string): boolean;
  var
    SearchData: TSearchRec;
  begin
    Result := True;

    if FindFirst(CheckBackslash(ADir) + '*', faAnyFile or faDirectory, SearchData) = 0 then
      try
        while FindNext(SearchData) = 0 do
          if (SearchData.Name <> '.') and (SearchData.Name <> '..') then
          begin
            Result := False;
            break;
          end;
      finally
        FindClose(SearchData);
      end;
  end;

begin
  // Make sure this extension is not disabled
  if not RegReadBoolDef(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                        'IntegrateIntoContextMenu', True) then
  begin
    Result := E_ABORT;
    exit;
  end;

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

  // Get the selected object; note that only *1* is supported;
  SrcCount := DragQueryFile(StgMedium.hGlobal, $FFFFFFFF, nil, 0);
  if SrcCount = 1 then begin
    DragQueryFile(StgMedium.hGlobal, 0, tempFile, SizeOf(tempFile));
    FDirectory := tempFile;
  end
  else begin
    Result := E_INVALIDARG;
    exit;
  end;

  // Free resources
  ReleaseStgMedium(StgMedium);

  // Try to find out whether to show our menu item here, and which mode to use
  FSourceDirMode := cmmUnkown;
  if (DirectoryExists(FDirectory)) then
  begin
    // Either the directory is a junction point..
    if (NtfsIsFolderMountPoint(FDirectory)) then
    begin
      FSourceDirMode := cmmJunctionPoint;
      // In that case, we also need the junction taraget, so query it
      FJunctionTarget := GetJPDestination(FDirectory);
    end
    // .. or it is empty
    else if (IsDirectoryEmpty(FDirectory)) then
      FSourceDirMode := cmmEmptyFolder
  end;

  // If no mode was selected, fail and do not show our menu item
  if FSourceDirMode = cmmUnkown then
    Result := E_INVALIDARG
  else
    Result := S_OK;
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
