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
  Windows, SysUtils, ActiveX, ComObj, ShlObj, BaseExtensionFactory;

type
  TCopyHook = class(TComObject, ICopyHook)
  public
    { ICopyHook }
    function CopyCallback(Wnd: HWND; wFunc, wFlags: UINT; pszSrcFile: PAnsiChar;
      dwSrcAttribs: DWORD; pszDestFile: PAnsiChar; dwDestAttribs: DWORD): UINT; stdcall;
  end;

  TCopyHookFactory = class(TBaseExtensionFactory)
  protected
    function GetInstallationKey: string; override;
  end;

const
  Class_CopyHook: TGUID = '{28334C90-3383-4616-AFF3-BC4D5CE769AF}';

implementation

uses
  Global, JclNTFS, JclWin32, ShellAPI, ComServ;

{ TCopyHook }

function TCopyHook.CopyCallback(Wnd: HWND; wFunc, wFlags: UINT;
  pszSrcFile: PAnsiChar; dwSrcAttribs: DWORD; pszDestFile: PAnsiChar;
  dwDestAttribs: DWORD): UINT;
begin
  // Per default, allow all operations
  Result := IDYES;

  // TODO What happens if junctions are moved or copied?
  // We should intercept that too, and ask the user if he wants to copy/move
  // the actual content or only the junction.

  // We do only intercept DELETE actions, and only for reparse points
  if (wFunc = FO_DELETE) and ((dwSrcAttribs and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) then
  begin
    // If we are here, we already have made sure that the source folder has
    // a reparse point, however, we want to make sure that it is really a
    // junction (note that the check above might also be skipped, but as the
    // Explorer is kind enough to pass a ready-to-use parameter containing the
    // file attributes...
    if NtfsIsFolderMountPoint(pszSrcFile) then
    begin
      // Now, there are two possible delete operations. Either Explorer wants
      // to delete to the recycle bin, or it wants to remove the file
      // permanently from the disk (for example if Shift+Del was used). In
      // the former case FOF_ALLOWUNDO is in wFlags, in the latter not.
      // Why does this matter? Because somehow (on WinXP at least), if we
      // are deleting directly, Explorer seems to have build up an internal
      // list of files the folder contains when this here is called. After we
      // have removed the junction point, the folder is empty and all the file
      // paths in Explorer's list are invalid. This is not the case when
      // deleting to recycle  bin.
      // The solution: We check which delete action the Explorer is doing, and
      // if this is an undoable action (recycle bin), we let Explorer do the
      // actual delete (we only remove the junction). In the other case, we
      // do both: removing the junction and deleting the folder.
      if not NtfsDeleteJunctionPoint(pszSrcFile) then
        Result := IDNO;

      // Delete Folder manually, if this is not a recycle-bin-delete (see above)
      if (FOF_ALLOWUNDO and wFlags) = 0 then begin
        RemoveDir(pszSrcFile);
        Result := IDNO;
      end;
    end;
  end;
end;

{ TCopyHookFactory }

function TCopyHookFactory.GetInstallationKey: string;
begin
  Result := 'Directory\shellex\CopyHookHandlers\NTFSLink';
end;

initialization
  TCopyHookFactory.Create(ComServer, TCopyHook, Class_CopyHook, '',
      'NTFSLink CopyHook Shell Extension', ciMultiInstance, tmApartment);

end.
