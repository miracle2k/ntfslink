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

unit CopyHook;

interface

uses          
  Windows, SysUtils, ActiveX, ComObj, ShlObj;

type
  TCopyHook = class(TComObject, ICopyHook)
  public
    { ICopyHook }
    function CopyCallback(Wnd: HWND; wFunc, wFlags: UINT; pszSrcFile: PAnsiChar;
      dwSrcAttribs: DWORD; pszDestFile: PAnsiChar; dwDestAttribs: DWORD): UINT; stdcall;
  end;

  TCopyHookFactory = class(TComObjectFactory)
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;

const
  Class_CopyHook: TGUID = '{2B7A7890-365C-4BDF-BB15-B6F6D15A1DE3}';

implementation

uses
  Global, JclNTFS, JclWin32, ShellAPI, ComServ;

{ TCopyHook }

function TCopyHook.CopyCallback(Wnd: HWND; wFunc, wFlags: UINT;
  pszSrcFile: PAnsiChar; dwSrcAttribs: DWORD; pszDestFile: PAnsiChar;
  dwDestAttribs: DWORD): UINT;
begin
  Result := IDYES; // rewrite logic

  // We do only intercept DELETE actions, and only for reparse points
  if (wFunc = FO_DELETE) and ((dwSrcAttribs and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) then
  begin
    // If we are here, we already have made sure that the source folder has
    // a reparse point, however, we want to make sure that it is really a
    // junction (note that the check above might also be skipped, but as the
    // Explorer is kind enough to pass a ready-to-use parameter containing the
    // file attributes...
    if NtfsIsFolderMountPoint(pszSrcFile) then
      if NtfsDeleteJunctionPoint(pszSrcFile) then Result := IDYES
      else Result := IDNO;
  end
  else
    // if not deleting, or no junction, than permit
    Result := IDYES;
end;

{ TCopyHookFactory }

procedure TCopyHookFactory.UpdateRegistry(Register: Boolean);
var
  ClassIDStr: string;
  InstallationKey: string;
begin
  // Store the key we need to create (or delete) in a local variable
  InstallationKey := 'Directory\shellex\CopyHookHandlers\NTFSLink';

  if Register then
  begin
    inherited UpdateRegistry(Register);      

    // Convert ClassID GUID to a string
    ClassIDStr := GUIDToString(ClassId);

    // Register the CopyHook extension
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
  TCopyHookFactory.Create(ComServer, TCopyHook, Class_CopyHook, '',
      'NTFSLink CopyHook Shell Extension', ciMultiInstance, tmApartment);

end.
