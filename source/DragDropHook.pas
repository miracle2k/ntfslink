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

unit DragDropHook;

interface

uses
  Windows, Classes, ActiveX, ComObj, ShlObj, JclNTFS;

type
  TDragDropHook = class(TComObject, IShellExtInit, IContextMenu)
  private
    FSourceFileList: TStringList;
    FTargetPath: string;
  protected
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

  TDragDropHookFactory = class(TComObjectFactory)
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;  

const
  Class_DragDropHook: TGUID = '{93A6090E-DCD1-4E94-9499-8AB61B3F37E8}';

implementation

uses ComServ, ShellAPI, SysUtils, Registry;

{ TDragDropHook }

destructor TDragDropHook.Destroy;
begin
  FSourceFileList.Free;
  inherited;
end;

function TDragDropHook.GetCommandString(idCmd, uType: UINT;
  pwReserved: PUINT; pszName: LPSTR; cchMax: UINT): HResult;
begin
  if (idCmd = 0) then begin
    if (uType = GCS_HELPTEXT) then
      StrCopy(pszName, 'Create hard links or directory junctions');
    Result := NOERROR;
  end
  else
    Result := E_INVALIDARG;
end;

function TDragDropHook.InvokeCommand(
  var lpici: TCMInvokeCommandInfo): HResult;
var NewDir: string;
    i: integer;
    Success: boolean;

    function CheckBackslash(AFileName: string): string;
    begin
      if (AFileName <> '') and (AFileName[length(AFileName)] <> '\') then
        Result := AFileName + '\'
      else Result := AFileName;
    end;

    function RemoveBackslash(AFileName: string): string;
    begin
      if (AFileName <> '') and (AFileName[length(AFileName)] = '\') then
        Result := Copy(AFileName, 1, length(AFileName) - 1)
      else Result := AFileName;
    end;

    function GetLinkFileName(Source, TargetDir: string; Directory: boolean): string;
    var x: integer;
    begin
      Result := CheckBackslash(TargetDir) + ExtractFileName(Source);
      x := 0;
      while ((Directory) and (DirectoryExists(Result))) or
            ((not Directory) and (FileExists(Result))) do
      begin
        Inc(x);
        Result := CheckBackslash(TargetDir) + 'Copy (' + IntToStr(x) + ') of ' + ExtractFileName(Source);
      end;

      if Directory then Result := CheckBackslash(Result);
    end;

begin
  // Standard Result
  Result := E_FAIL;

  try
    // Make sure we are not being called by an application
    if (HiWord(Integer(lpici.lpVerb)) <> 0) then exit;

    // Make sure we aren't being passed an invalid argument number
    if (LoWord(lpici.lpVerb) <> 0) then
    begin
      Result := E_INVALIDARG;
      exit;
    end;

    // Create Hardlink
    for i := 0 to FSourceFileList.Count - 1 do
    begin
      // Create a junction if the object is a directory,
      // otherwise create hard link
      if DirectoryExists(FSourceFileList[i]) then begin
        NewDir := GetLinkFileName(RemoveBackslash(FSourceFileList[i]), FTargetPath, True);
        // We need to create the directory first
        Success := CreateDir(NewDir);
        // If successfull, then try to make a junction
        if Success then begin
          Success := NtfsCreateJunctionPoint(NewDir, CheckBackslash(FSourceFileList[i]));
          // if junction creation was unsuccessfull, delete created directory  
          if not Success then RemoveDir(NewDir);
        end;
      end else begin
        Success := NtfsCreateHardLink(GetLinkFileName(FSourceFileList[i], FTargetPath, False),
                                      PAnsiChar(FSourceFileList[i]));
      end;

      if (GetLastError <> 0) and (not Success) then
        MessageBox(0, PAnsiChar('An error occured (' + IntToStr(GetLastError) +
                      '): ' + SysErrorMessage(GetLastError)), 'Failed to create link', MB_OK + MB_ICONERROR)
      else if (not Success) then
        MessageBox(0, PAnsiChar('An error occured.'), 'Failed to create link', MB_OK + MB_ICONERROR)
      else Result := NOERROR;
    end;
  except
    Result := E_FAIL;
  end;
end;

function TDragDropHook.QueryContextMenu(Menu: HMENU; indexMenu, idCmdFirst,
  idCmdLast, uFlags: UINT): HResult;
var mString: string;
begin
  Result := MakeResult(SEVERITY_SUCCESS, FACILITY_NULL, 0);

  if ((uFlags and $0000000F) = CMF_NORMAL) or
     ((uFlags and CMF_EXPLORE) <> 0) then
  begin
    // Add one menu item to context menu
    if FSourceFileList.Count = 1 then mString := 'Create Hardlink'
    else mString := 'Create Hardlinks';
    InsertMenu(Menu, GetMenuItemCount(Menu) - 2, MF_STRING or MF_BYPOSITION,
               idCmdFirst, PAnsiChar(mString));

    // Return number of menu items added
    Result := MakeResult(SEVERITY_SUCCESS, FACILITY_NULL, 1);
  end;
end;

function TDragDropHook.SEIInitialize(pidlFolder: PItemIDList;
  lpdobj: IDataObject; hKeyProgID: HKEY): HResult;
var StgMedium: TStgMedium;
    FormatEtc: TFormatEtc;
    AFileName, pszPath: array[0..MAX_PATH] of Char;
    SrcCount, i: Integer;
begin
  // Create Source File List
  FSourceFileList := TStringList.Create;
  FSourceFileList.Clear;

  // Fail the call if lpdobj is nil.
  if (lpdobj = nil) then begin
    Result := E_INVALIDARG;
    exit;
  end else begin
    SHGetPathFromIDList(pidlFolder, pszPath);
    FTargetPath := pszPath;
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
  
  // If only one file is selected, retrieve the file name and store it in
  // FFileName. Otherwise fail the call.
  SrcCount := DragQueryFile(StgMedium.hGlobal, $FFFFFFFF, nil, 0);
  if SrcCount > 0 then
    for i := 0 to SrcCount - 1 do begin
      DragQueryFile(StgMedium.hGlobal, i, AFileName, SizeOf(AFileName));
      FSourceFileList.Add(AFileName);
    end
  else Result := E_FAIL;

  // Free ressources
  ReleaseStgMedium(StgMedium);
end;

{ TDragDropHookFactory }

procedure TDragDropHookFactory.UpdateRegistry(Register: Boolean);
var
  ClassID: string;
begin
  if Register then begin
    inherited UpdateRegistry(Register);

    ClassID := GUIDToString(Class_DragDropHook);
    CreateRegKey('Folder\shellex\DragDropHandlers\ntfslink', '', ClassID);
    if (Win32Platform = VER_PLATFORM_WIN32_NT) then
      with TRegistry.Create do
        try
          RootKey := HKEY_LOCAL_MACHINE;
          OpenKey('SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions', True);
          OpenKey('Approved', True);
          WriteString(ClassID, 'ntfslink dragdrop shell extension handler');
        finally
          Free;
        end;
  end
  else begin
    DeleteRegKey('Folder\shellex\DragDropHandlers\ntfslink');

    inherited UpdateRegistry(Register);
  end;
end;

initialization
  TDragDropHookFactory.Create(ComServer, TDragDropHook, Class_DragDropHook, '',
    'ntfslink dragdrop shell extension handler', ciMultiInstance, tmApartment);
end.
