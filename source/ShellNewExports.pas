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

unit ShellNewExports;

interface

uses                   // JvBrowseFolder JvSelectDirectory
  Windows, Messages, ActiveX, SysUtils;

procedure NewHardlink(hwnd: HWND; hinst: Cardinal;
  lpCmdLine: LPTSTR; nCmdShow: Integer); stdcall;
  
procedure NewJunction(hwnd: HWND; hinst: Cardinal;
  lpCmdLine: LPTSTR; nCmdShow: Integer); stdcall;

implementation

uses
  ShlObj, CommDlg, Global, GNUGetText;

// Parts of the following code were taken from Delphi's Dialogs.pas
procedure NewHardlink(hwnd: HWND; hinst: Cardinal;
  lpCmdLine: LPTSTR; nCmdShow: Integer); stdcall;
var
  OpenFileName: TOpenFileName;
  TempFileName: string;
begin
  FillChar(OpenFileName, SizeOf(OpenFileName), 0);
  with OpenFileName do
  begin
    // Init the filename buffer
    SetLength(TempFilename, nMaxFile + 2);
    lpstrFile := PChar(TempFilename);
    FillChar(lpstrFile^, nMaxFile + 2, 0);
    StrLCopy(lpstrFile, '', nMaxFile);

    // Init other struct members
    lStructSize := SizeOf(TOpenFilename);
    hInstance := SysInit.HInstance;
    nMaxFile := MAX_PATH;    
    lpstrTitle := PAnsiChar(string(_('Choose the source file you want to create a hard link to')));
    lpstrFilter := PAnsiChar(string(_('All Files') + #0'*.*'#0));        
    nFilterIndex := 1;
    lpstrFileTitle := nil;
    nMaxFileTitle := 0;
    lpstrInitialDir := '.';
    Flags := OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY;
  end;

  // Execute the dialog
  if GetOpenFileName(OpenFileName) then
    // If positive result, then try to create hardlink
    // TODO test hardlink creation is possible and catch all errors before they may occur
    InternalCreateHardlink(OpenFileName.lpstrFile, lpCmdLine);
end;

procedure NewJunction(hwnd: HWND; hinst: Cardinal;
  lpCmdLine: LPTSTR; nCmdShow: Integer); stdcall;
var
  bi: TBrowseInfoA;
  a: array[0..MAX_PATH] of Char;
  idl: PItemIDList;
begin
  FillChar(bi, SizeOf(bi), #0);

  // Init BrowseInfo struct
  bi.hwndOwner := 0;
  bi.pszDisplayName := @a[0];
  bi.lpszTitle := PChar(string(_('Choose the target folder or drive to which you want to create a junction point.' )));
  bi.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE or BIF_VALIDATE;
  bi.lParam := 0;
  bi.pidlRoot := nil;

  // Call SHBrowseForFolder()
  CoInitialize(nil);
  idl := SHBrowseForFolder(bi);

  // If successful, create junction
  if idl <> nil then begin
    SHGetPathFromIDList(idl,a);
    InternalCreateJunction(StrPas(a), lpCmdLine);
  end;    
end;

end.
