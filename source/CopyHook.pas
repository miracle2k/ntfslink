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
  Global, JunctionMonitor, JclNTFS, JclWin32, ShellAPI, ComServ;

{ TCopyHook }

function TCopyHook.CopyCallback(Wnd: HWND; wFunc, wFlags: UINT;
  pszSrcFile: PAnsiChar; dwSrcAttribs: DWORD; pszDestFile: PAnsiChar;
  dwDestAttribs: DWORD): UINT;
var
  tempDest: string;
  tempResult: Cardinal;
  Success: boolean;
begin
  // Per default, allow all operations
  Result := IDYES;

  // Differ between two cases - the folder is either a junction point, or not.
  // If it is, we have to intercept the DELETE and MOVE operations
  if ((dwSrcAttribs and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) and
     (NtfsIsFolderMountPoint(pszSrcFile)) then
  begin
    // If this is a delete operation, make sure *only* the junction point
    // will be deleted, not the contents of the target directory.
    if (wFunc = FO_DELETE) then
    begin
      // Now, there are two possible delete operations. Either Explorer wants
      // to delete to the recycle bin, or it wants to remove the file
      // permanently from the disk (for example if Shift+Del was used). In
      // the former case, FOF_ALLOWUNDO is in wFlags, in the latter not.
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
    end

    // If this is a move operation, we have to make sure, that Explorer does
    // *not* move the contents of the target directory, but only the junction.
    else if (wFunc = FO_MOVE) then
    begin
      // Whatever may happen: do not allow the operation. We will have to do
      // all the work ourself.
      Result := ID_NO;

      // Make sure the target drive supports reparse points
      if NtfsReparsePointsSupported(ExtractFileDrive(pszDestFile) + '\') then
      begin
        // Attempt to get the directory the (old) junction, the one we
        // want to move, points to. Note that NtfsGetJunctionPointDestination()
        // has a bug and always adds a #0 at the end, which we have to remove.
        NtfsGetJunctionPointDestination(pszSrcFile, tempDest);
        if (tempDest[Length(tempDest)]) = #0 then
          Delete(tempDest, Length(tempDest), 1);
        tempDest := CheckBackslash(tempDest);

        // Create an empty directory and set the junction reparse point
        Success := False;
        if CreateDir(pszDestFile) then
          if InternalCreateJunctionEx(tempDest,pszDestFile) then
          begin
            // Delete the old (source) junction
            Success := NtfsDeleteJunctionPoint(pszSrcFile);
            // Delete the directory previously containing the junction
            RemoveDir(pszSrcFile);
          end;

        // If the thing went not smoothly, then show a message
        if not Success then
          if DirectoryExists(pszDestFile) then
            MessageBox(0, PAnsiChar('Junction could not be moved, because there ' +
               'is already a directory named "' + pszDestFile + '".'),
               PAnsiChar('NTFS Link'), MB_OK + MB_ICONERROR)
          else
            MessageBox(0, PAnsiChar('"' + pszSrcFile + '" could not be moved to "' +
             pszDestFile + '" because of unkown reasons.'),
             PAnsiChar('NTFS Link'), MB_OK + MB_ICONERROR);
      end
      else
        // Moving the junction point is not possible
        MessageBox(0, PAnsiChar('"' + pszSrcFile + '" is a junction point, ' +
           'but the target file system does not support junctions.'),
           PAnsiChar('NTFS Link'), MB_OK + MB_ICONERROR);
    end

    // Finally, if it's a copy operation, ask the user what he wants: Either
    // copy the junction, or copy the contents of the directory.
    else if (wFunc = FO_COPY) then
    begin
      // Check if the target file system supports junctions; if not, we have
      // nothing to do, because the only option left is to copy the contents
      // of the linked directory.
      if NtfsReparsePointsSupported(ExtractFileDrive(pszDestFile) + '\') then
      begin
        // Ask user what he wants to do
        tempResult := MessageBox(0, PAnsiChar('The directory you want to copy is a junction. Please choose ' +
             'whether you want to copy the junction only, or the directory contents. ' +
             'Do you want to copy the junction only (if you click no, the contents will be copied)?'),
             PAnsiChar('NTFS Link'), MB_YESNOCANCEL + MB_ICONINFORMATION);
        case tempResult of
          // User wants to copy the contents of the linked directory; this can
          // be better done by the Explorer.
          ID_NO:
            Result := ID_YES;

          // User wants to copy the junction point only, so we do it.
          ID_YES:
            begin
              Result := ID_NO;

              // Attempt to get the directory the source junction, the one we
              // want to copy, points to. Note that NtfsGetJunctionPointDestination()
              // has a bug and always adds a #0 at the end, which we have to remove.
              NtfsGetJunctionPointDestination(pszSrcFile, tempDest);
              if (tempDest[Length(tempDest)]) = #0 then
                Delete(tempDest, Length(tempDest), 1);
              tempDest := CheckBackslash(tempDest);

              // Finally, create the junction point
              InternalCreateJunction(tempDest,
                                     ExtractFilePath(RemoveBackslash(pszDestFile)),
                                     pszDestFile,
                                     COPY_PREFIX_TEMPLATE_DEFAULT);
            end;

          // Seems as if our user does not want to do anything anymore...
          ID_CANCEL:
            Result := ID_NO;
        end;
      end
      // If junctions are not supported, let the Explorer do the copying
      else
        Result := ID_YES;
    end;
  end

  else if GetFolderLinkCount(pszSrcFile) > 0 then begin
//    WarnUser;
//    If UserAccepts then let explorer do the job;
//    if UserWantsToDeleteJunctinos then DeleteJunctions;
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
