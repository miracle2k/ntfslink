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

unit ShellNewExports;

interface

uses                  
  Windows, ActiveX, SysUtils;

// Shows an Open Dialog to query the user for the /file/ to link to
procedure NewHardlinkDlg(hwnd: HWND; hinst: Cardinal;
  lpCmdLine: LPTSTR; nCmdShow: Integer); stdcall;

// Shows an Browse Folder dialog to query the user for the /folder/ to link to
procedure NewJunctionDlg(hwnd: HWND; hinst: Cardinal;
  lpCmdLine: LPTSTR; nCmdShow: Integer); stdcall;

// Called by NewJunctionDlg(); does implement the dialog handling and executes
// the final command to create the link;
// If "SubFolder" is False, we directly attach the junction reparse point to the
// folder specified by "Directory". If "SubFolder" is True, we create a
// junction within "Directory", as a subfolder.
procedure NewJunctionDlgInternal(hwnd: HWND; Directory: string;
  SubFolder: boolean); stdcall;

implementation

uses
  ShlObj, CommDlg, Global, GNUGetText;

// TODO test if hardlink/junction creation is possible before trying to create / show a message if not

// Parts of the following code were taken from Delphi's Dialogs.pas
procedure NewHardlinkDlg(hwnd: HWND; hinst: Cardinal;
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
    try
      InternalCreateHardlink(OpenFileName.lpstrFile, lpCmdLine);
    except end;
end;

procedure NewJunctionDlgInternal(hwnd: HWND; Directory: string;
  SubFolder: boolean); stdcall;
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
    SHGetPathFromIDList(idl, a);

    if SubFolder then
      InternalCreateJunction(StrPas(a), Directory)
    else
      InternalCreateJunctionBase(StrPas(a), Directory);
  end;    
end;

procedure NewJunctionDlg(hwnd: HWND; hinst: Cardinal;
  lpCmdLine: LPTSTR; nCmdShow: Integer); stdcall;
begin
  NewJunctionDlgInternal(hwnd, lpCmdLine, True);
end;

end.
