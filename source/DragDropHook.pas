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

unit DragDropHook;

interface

uses
  Windows, Classes, ActiveX, ComObj, ShlObj, BaseExtensionFactory;

type
  // We have to differ between dragged files, dragged directories, or
  // multiple dragged objects containing both types. 
  TDragDropMode = (ddmUnknown, ddmFile, ddmDirectory, ddmFileAndDirectory);

  // Our ComObject for the Handler, implementing the IContextMenu Interface
  TDragDropHook = class(TComObject, IShellExtInit, IContextMenu)
  private
    FSourceFileMode: TDragDropMode;
    FSourceFileList: TStringList;
    FTargetPath: string;
  protected
    // Frees the memory allocated by the source file StringList
    procedure FreeSourceFileList;
    // Looks at FSourceFileList to decide on the dragging mode
    procedure InitSourceFileMode;
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
  public
    destructor Destroy; override;
  end;

  TDragDropHookFactory = class(TBaseExtensionFactory)
  protected
    function GetInstallationData: TExtensionRegistryData; override;
  end;  

const
  Class_DragDropHook: TGUID = '{93A6090E-DCD1-4E94-9499-8AB61B3F37E8}';

implementation

uses
  ComServ, ShellAPI, SysUtils, JclNTFS, Global, GNUGetText;

{ TDragDropHook }

destructor TDragDropHook.Destroy;
begin
  FreeSourceFileList;
  inherited;
end;

procedure TDragDropHook.FreeSourceFileList;
begin
  if FSourceFileList <> nil then
    FSourceFileList.Free;
  FSourceFileList := nil;
end;

function TDragDropHook.GetCommandString(idCmd, uType: UINT;
  pwReserved: PUINT; pszName: LPSTR; cchMax: UINT): HResult;
begin
  if (idCmd = 0) then begin
    if (uType = GCS_HELPTEXT) then
      // Return nothing, as this is shown nowhere
      StrCopy(pszName, '');
      Result := NOERROR;
  end
  else
    Result := E_INVALIDARG;
end;

procedure TDragDropHook.InitSourceFileMode;
var
  i: integer;
begin
  FSourceFileMode := ddmUnknown;
  
  for i := 0 to FSourceFileList.Count - 1 do
    // Check if it's a directory
    if DirectoryExists(FSourceFileList[i]) then
      // If we already found a file, then we now have both types 
      if FSourceFileMode = ddmFile then begin
        FSourceFileMode := ddmFileAndDirectory;
        break;   // Mode can not change anymore now
      end
        else FSourceFileMode := ddmDirectory
    else
      // If we already found a directory, then we now have both types
      if FSourceFileMode = ddmDirectory then begin
        FSourceFileMode := ddmFileAndDirectory;
        break;   // Mode can not change anymore now
      end
        else FSourceFileMode := ddmFile;
end;

function TDragDropHook.InvokeCommand(
  var lpici: TCMInvokeCommandInfo): HResult;
var
  ErrorMsg: string;
  i: integer;
  Success: boolean;
begin
  Result := S_OK;
                                         
  try
    // Make sure we are not being called by an application
    if (HiWord(Integer(lpici.lpVerb)) <> 0) then exit;

    // Make sure we aren't being passed an invalid argument number
    if (LoWord(lpici.lpVerb) <> 0) then
    begin
      Result := E_INVALIDARG;
      exit;
    end;

    // Create a link (hardlink or junction) for each source file
    for i := 0 to FSourceFileList.Count - 1 do
    begin
      // Create junction if it's a directory, otherwise hardlink
      if DirectoryExists(FSourceFileList[i]) then
        Success := InternalCreateJunction(FSourceFileList[i], FTargetPath)
      else
        Success := InternalCreateHardlink(FSourceFileList[i], FTargetPath);

      // Tell the user if an error occurred
      if (not Success) then
      begin
        ErrorMsg := _('Failed to create link');
        if (GetLastError <> 0) then
          ErrorMsg := ErrorMsg + ': ' + SysErrorMessage(GetLastError);
        MessageBox(lpici.hwnd, PAnsiChar(ErrorMsg), PAnsiChar('NTFS Link'),
                   MB_OK + MB_ICONERROR)
      end else
        Result := NOERROR;
    end;
  except
    Result := E_FAIL;
  end;
end;

function TDragDropHook.QueryContextMenu(Menu: HMENU; indexMenu, idCmdFirst,
  idCmdLast, uFlags: UINT): HResult;
var
  mString: string;
begin                  
  // No items created yet
  Result := MakeResult(SEVERITY_SUCCESS, FACILITY_NULL, 0);

  if (uFlags and $0000000F = CMF_NORMAL) or (uFlags and CMF_EXPLORE <> 0) then
  begin
    // Depending on the type and the number of the source objects, choose
    // an appropriate menu caption
    // TODO Perhaps it looks nicer if we use glyphs for the items here...
    case FSourceFileMode of
      ddmFile:
        if FSourceFileList.Count = 1 then mString := _('Create Hardlink Here')
        else mString := _('Create Hardlinks Here');
        
      ddmDirectory:
        if FSourceFileList.Count = 1 then mString := _('Create Junction Here')
        else mString := _('Create Junctions Here');

      ddmFileAndDirectory:
        mString := _('Create Links Here')
    end;

    // Add our menu item to context menu
    InsertMenu(Menu, GetMenuItemCount(Menu) - 2, MF_STRING or MF_BYPOSITION,
               idCmdFirst, PAnsiChar(mString));

    // Return number of menu items added
    Result := MakeResult(SEVERITY_SUCCESS, FACILITY_NULL, 1);
  end;
end;

function TDragDropHook.SEIInitialize(pidlFolder: PItemIDList;
  lpdobj: IDataObject; hKeyProgID: HKEY): HResult;
var
  StgMedium: TStgMedium;
  FormatEtc: TFormatEtc;
  tempFile, pszPath: array[0..MAX_PATH] of Char;
  SrcCount, i: Integer;

  // Hardlinks are not supported across different file systems
  procedure RemoveInvalidItems;
  var
    i: integer;
  begin
    for i := FSourceFileList.Count - 1 downto 0 do
      if not
         ((DirectoryExists(FSourceFileList[i])) or
         (ExtractFileDrive(FSourceFileList[i]) = ExtractFileDrive(FTargetPath)))
      then
        FSourceFileList.Delete(i);
  end;

begin
  // Create list for storing all the selected source files
  FreeSourceFileList;
  FSourceFileList := TStringList.Create;

  // Fail the call if lpdobj is nil.
  if (lpdobj = nil) then begin
    Result := E_INVALIDARG;
    exit;
  end else begin
    SHGetPathFromIDList(pidlFolder, pszPath);
    FTargetPath := pszPath;
  end;

  // Make sure the taget file system is NTFS: To keep it as easy as possible,
  // we just check if reparse points are supported. This is only the case on
  // NTFS, and thus we can assume that hard links are supported as well.
  if not (NtfsReparsePointsSupported(ExtractFileDrive(FTargetPath) + '\')) then
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
  
  // Put all the source files in the StringList
  SrcCount := DragQueryFile(StgMedium.hGlobal, $FFFFFFFF, nil, 0);
  if SrcCount > 0 then
    for i := 0 to SrcCount - 1 do begin
      DragQueryFile(StgMedium.hGlobal, i, tempFile, SizeOf(tempFile));
      FSourceFileList.Add(tempFile);
    end
  else
    Result := E_FAIL;

  // Go through the list of source objects and remove invalid items
  RemoveInvalidItems;
  // If there are no items left, then exit
  if FSourceFileList.Count = 0 then begin
    Result := E_ABORT;
    exit;
  end;

  // Have a closer look at the source files
  InitSourceFileMode;

  // Free resources
  ReleaseStgMedium(StgMedium);
end;

{ TDragDropHookFactory }

function TDragDropHookFactory.GetInstallationData: TExtensionRegistryData;
begin
  Result.RootKey := HKEY_CLASSES_ROOT;
  Result.BaseKey := 'Folder\shellex\DragDropHandlers\NTFSLink';
  Result.UseGUIDAsKeyName := False;
end;

initialization
  TDragDropHookFactory.Create(ComServer, TDragDropHook, Class_DragDropHook, '',
      'NTFSLink Drag&Drop Shell Extension', ciMultiInstance, tmApartment);
end.
