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
  ShlObj, CommDlg, Global, GNUGetText, ActivationContext;

// Parts of the following code were taken from Delphi's Dialogs.pas
procedure NewHardlinkDlg(hwnd: HWND; hinst: Cardinal;
  lpCmdLine: LPTSTR; nCmdShow: Integer); stdcall;
var
  OpenFileName: TOpenFileNameW;
  TempFileName: WideString;
  ErrorMsg: string;
begin
  FillChar(OpenFileName, SizeOf(OpenFileName), 0);
  with OpenFileName do
  begin
    // Init the filename buffer
    SetLength(TempFilename, nMaxFile + 2);
    lpstrFile := PWideChar(TempFilename);
    FillChar(lpstrFile^, nMaxFile + 2, 0);

    // Init other struct members
    lStructSize := SizeOf(TOpenFilename);
    hInstance := SysInit.HInstance;
    nMaxFile := MAX_PATH;
    lpstrTitle := PWideChar(_('Choose the file you want to create a hard link to'));
    lpstrFilter := PWideChar(_('All Files') + #0'*.*'#0);
    nFilterIndex := 1;
    lpstrFileTitle := nil;
    nMaxFileTitle := 0;
    lpstrInitialDir := PWideChar(CheckBackslash(lpCmdLine));
    Flags := OFN_PATHMUSTEXIST or OFN_FILEMUSTEXIST or OFN_HIDEREADONLY;
  end;

  // Execute the dialog
  if GetOpenFileNameW(OpenFileName) then
    // If positive result, then try to create hardlink
    try
      InternalCreateHardlink(OpenFileName.lpstrFile, ExtractFilePath(lpCmdLine));
    except
      ErrorMsg := _('Failed to create link. Most likely the target file ' +
                    'system does not support this feature, or you tried ' +
                    'to create a hard link across different partitions.');
      MessageBoxWithContext(hwnd, PAnsiChar(ErrorMsg), 'NTFS Link',
                 MB_OK or MB_ICONERROR)
    end;
end;

procedure NewJunctionDlgInternal(hwnd: HWND; Directory: string;
  SubFolder: boolean); stdcall;
const
  // Some versions of Delphi miss this in ShlObj.pas.
  BIF_NEWDIALOGSTYLE = $0040;
var
  bi: TBrowseInfoA;
  a: array[0..MAX_PATH] of Char;
  idl: PItemIDList;
  ErrorMsg: string;
  Success: boolean;
begin
  // Init BrowseInfo struct
  FillChar(bi, SizeOf(bi), #0);
  bi.hwndOwner := 0;
  bi.pszDisplayName := @a[0];
  bi.lpszTitle := PChar(string(_('Choose the target folder or drive to which ' +
                                 'you want to create a junction point.' )));
  bi.ulFlags := BIF_RETURNONLYFSDIRS or BIF_NEWDIALOGSTYLE or BIF_VALIDATE;
  bi.lParam := 0;
  bi.pidlRoot := nil;

  // Call SHBrowseForFolder()
  CoInitialize(nil);
  idl := SHBrowseForFolder(bi);

  // If successful, create junction
  if idl <> nil then
  begin
    SHGetPathFromIDList(idl, a);

    // See comment at declaration why the "SubFolder" parameter is needed
    if SubFolder then
      Success := InternalCreateJunction(StrPas(a), Directory)
    else
      Success := InternalCreateJunctionBase(StrPas(a), Directory);

    // If junction creation failed, show message box
    if not Success then begin
      ErrorMsg := _('Failed to create junction. Most likely the target file ' +
                    'system does not support this feature.');
      MessageBoxWithContext(hwnd, PAnsiChar(ErrorMsg), PAnsiChar('NTFS Link'),
                 MB_OK + MB_ICONERROR);
    end;
  end;
end;

procedure NewJunctionDlg(hwnd: HWND; hinst: Cardinal;
  lpCmdLine: LPTSTR; nCmdShow: Integer); stdcall;
begin
  NewJunctionDlgInternal(hwnd, ExtractFilePath(lpCmdLine), True);
end;

end.
