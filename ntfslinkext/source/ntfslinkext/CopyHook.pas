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

unit CopyHook;

// TODO [v2.1] If a folder is deleted, check if there are junctions for
// objects within subdirectories. If so, show our dialog

interface

uses
  Windows, SysUtils, ComObj, ShlObj, BaseExtensionFactory;

type
  TCopyHook = class(TComObject, ICopyHook)
  public
    { ICopyHook }
    function CopyCallback(Wnd: HWND; wFunc, wFlags: UINT; pszSrcFile: PAnsiChar;
      dwSrcAttribs: DWORD; pszDestFile: PAnsiChar; dwDestAttribs: DWORD): UINT; stdcall;
  end;

  TCopyHookFactory = class(TBaseExtensionFactory)
  protected
    function GetInstallationData: TExtensionRegistryData; override;
  end;

const
  Class_CopyHook: TGUID = '{28334C90-3383-4616-AFF3-BC4D5CE769AF}';

implementation

uses
  Global, JunctionMonitor, JclNTFS, JclWin32, JclRegistry, ShellAPI, JclShell,
  ComServ, Classes, DialogLinksExisting, GNUGetText, Constants,
  ActivationContext;

{ TCopyHook }

function TCopyHook.CopyCallback(Wnd: HWND; wFunc, wFlags: UINT;
  pszSrcFile: PAnsiChar; dwSrcAttribs: DWORD; pszDestFile: PAnsiChar;
  dwDestAttribs: DWORD): UINT;

  function DeleteJunctionsInDirectory(ADir: string): boolean;
  var
    SearchData: TSearchRec;
    CurrDir: string;
  begin
    Result := False;

    if FindFirst(CheckBackslash(ADir) + '*', faDirectory, SearchData) = 0 then
      try
        repeat
          CurrDir := CheckBackslash(ADir) + SearchData.Name;
          if (SearchData.Name <> '.') and (SearchData.Name <> '..') and
             ((SearchData.Attr and faDirectory) <> 0) then
            if NtfsIsFolderMountPoint(CurrDir) then
            begin
               // We have found a junction, so return true
               Result := True;
               // Delete junction point
               if NtfsDeleteJunctionPoint(CurrDir) then
                 RemoveDir(CurrDir);
            end
            else
              DeleteJunctionsInDirectory(CurrDir);
        until FindNext(SearchData) <> 0;
      finally
        FindClose(SearchData);
      end;
  end;

var
  tempDest: string;
  tempResult: Cardinal;
  tempList: TStringList;
  i: Integer;
  Success: boolean;
begin
  // Per default, allow all operations
  Result := ID_YES;

  // Check if there are junctions pointing to this object; if yes, warn user
  if (wFunc <> FO_COPY) and
     (GetFolderLinkCount(pszSrcFile, Dialog_JunctionListAsString) > 0) then
  begin
    // Set a global flag, to tell the dialog what texts to display
    Dialog_IsDeleteOperation := (wFunc = FO_DELETE); // otherwise it's MOVE or RENAME
    // Show the dialog and ask user what do to
    tempResult := DialogBoxWithContext(HInstance, MakeIntResource(1000),
                            Wnd, @DialogCallback);

    // Depending on the result, let explorer continue with the operation or not
    if not ((tempResult = ID_YES) or (tempResult = ID_RETRY)) then
      Result := ID_NO;

    // If we delete the folder, make sure the appropriate tracking entries
    // in the registry will be deleted as well; note that the entries for the
    // current folder, which Explorer wants to delete now, will not yet be
    // deleted, as the folder is still existing *at the moment*,  This is kind
    // of a flaw, but it's not a big deal, and I'm too lazy now to change it.
    if tempResult <> ID_NO then
      CleanRegistryTrackingInformation;

    // "Retry" is returned, if the user clicked "Yes + delete/change links".
    // So this is what we have to to now: Either delete all the links, or
    // let them point to the new location of the folder:
    if (tempResult = ID_RETRY) then begin
      tempList := TStringList.Create;
      try
        tempList.Text := Dialog_JunctionListAsString;
        for i := 0 to tempList.Count - 1 do
          if (wFunc = FO_DELETE) then
          begin
            // First delete the junction, then the folder itself
            if NtfsDeleteJunctionPoint(tempList[i]) then
              RemoveDir(tempList[i]);
            // Notify Explorer that the directory was deleted
            SHChangeNotify(SHCNE_RMDIR, SHCNF_PATH, PAnsiChar(tempList[i]), nil);
          end else
          begin
            // Uuuurg, what a very, very, very dirty hack. We have to create
            // an empty dummy folder first, because otherwise the creation
            // of the junction point will fail (that's because Explorer will
            // do the finally action (remove or rename) not before our code
            // has finished.
            CreateDirectory(pszDestFile, nil);
            try
              // Let the junction link to the new location
              InternalCreateJunctionBase(pszDestFile, tempList[i]);
            finally
              RemoveDirectory(pszDestFile);
            end;
          end;
      finally
        tempList.Free;
      end;
    end;
  end;

  // Differ between two cases - the folder is either a junction point, or not.
  // If it is, we have to intercept the DELETE and MOVE operations
  if ((dwSrcAttribs and FILE_ATTRIBUTE_REPARSE_POINT) <> 0) and
     (NtfsIsFolderMountPoint(pszSrcFile)) and
     (Result = ID_YES)  (* Maybe previous code already deactivated operation *) then
  begin
    // Attempt to get the directory the (old) junction, the one we
    // want to move, points to. Note that NtfsGetJunctionPointDestination()
    // has a bug and always adds a #0 at the end, which we have to remove.
    // We use this later in several cases.
    NtfsGetJunctionPointDestination(pszSrcFile, tempDest);
    if (tempDest[Length(tempDest)]) = #0 then
      Delete(tempDest, Length(tempDest), 1);
    tempDest := CheckBackslash(tempDest);

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
        Result := ID_NO;

      // Delete Folder manually, if this is not a recycle-bin-delete (see above)
      if (FOF_ALLOWUNDO and wFlags) = 0 then begin
        RemoveDir(pszSrcFile);
        Result := ID_NO;
      end;
    end

    // If this is a move operation, we have to make sure, that Explorer does
    // *not* move the contents of the target directory, but only the junction.
    else if (wFunc = FO_MOVE) then
    begin
      // Whatever may happen: do not allow the operation.
      Result := ID_NO;

      // Make sure the target drive supports reparse points
      if NtfsReparsePointsSupported(ExtractFileDrive(pszDestFile) + '\') then
      begin
        // Create an empty directory and set the junction reparse point
        Success := False;
        if CreateDir(pszDestFile) then
          if InternalCreateJunctionBase(tempDest,pszDestFile) then
          begin
            // Delete the old (source) junction
            Success := NtfsDeleteJunctionPoint(pszSrcFile);
            // Delete the directory previously containing the junction
            RemoveDir(pszSrcFile);
          end;

        // If the thing went not smoothly, then show a message
        if not Success then
          if DirectoryExists(pszDestFile) then
            MessageBoxWithContext(Wnd, PAnsiChar(string(Format(_('' + (* dxgettext hack *)
               '"%s" could not be moved, because there ' +
               'is already a directory "%s".'), [ExtractFileName(pszSrcFile), pszDestFile]))),
               PAnsiChar('NTFS Link'), MB_OK + MB_ICONERROR)
          else
            MessageBoxWithContext(Wnd, PAnsiChar(string(Format(_('' + (* dxgettext hack *)
               '"%s" could not be moved to "%s" because of ' +
               'unkown reasons.'), [ExtractFileName(pszSrcFile), pszDestFile]))),
             PAnsiChar('NTFS Link'), MB_OK + MB_ICONERROR);
      end
      else
        // Moving the junction point is not possible
        MessageBoxWithContext(Wnd, PAnsiChar(string(Format(_('' + (* dxgettext hack *)
           '"%s" is a junction point, but the target file system does not ' +
           'support junctions.'), [pszSrcFile]))),
           PAnsiChar('NTFS Link'), MB_OK + MB_ICONERROR);
    end

    // If a junction is renamed, make sure the tracking information is updated
    else if (wFunc = FO_RENAME) then
      TrackJunctionCreate(pszDestFile, GetJPDestination(pszSrcFile))

    // Finally, if it's a copy operation, ask the user what he wants: Either
    // copy the junction, or copy the contents of the directory.
    else if (wFunc = FO_COPY) then
    begin
      // Interception of copy operations can be configured; check if activated:
      if RegReadBoolDef(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                         'InterceptJunctionCopying', True) then

        // Check if the target file system supports junctions; if not, we have
        // nothing to do, because the only option left is to copy the contents
        // of the linked directory.
        if NtfsReparsePointsSupported(ExtractFileDrive(pszDestFile) + '\') then
        begin
          // Ask user what he wants to do
          tempResult := MessageBox(Wnd, PAnsiChar(string((Format(_('' + (* dxgettext hack *)
               '"%s" is a junction point. If you want to copy the junction ' +
               'only, click "Yes", if you want to copy the target directory ' +
               'including all it''s content, click "No". If you choose ' +
               '"Cancel", nothing will happen.'), [pszSrcFile])))),
               PAnsiChar('NTFS Link'), MB_YESNOCANCEL + MB_ICONINFORMATION);

          case tempResult of
            // User wants to copy the contents of the linked directory; this can
            // be better done by the Explorer.
            ID_NO:
              Result := ID_YES;

            // User wants to copy the junction point only, so we do it.
            ID_YES:
              begin
                // We are doing all the stuff ourself
                Result := ID_NO;

                // Create the junction point
                InternalCreateJunction(tempDest,
                                       ExtractFilePath(RemoveBackslash(pszDestFile)),
                                       pszDestFile,
                                       COPY_PREFIX_TEMPLATE_DEFAULT);
              end;

            // Seems as if our user does not want to do anything anymore...
            ID_CANCEL:
              Result := ID_NO;
          end;
        end;
    end;
  end

  // Before we let explorer delete a (non junction) folder, search for
  // junctions within subfolders, and make sure they are all unlinked
  else
    if (Result = ID_YES) and (wFunc = FO_DELETE) then
      // If this function returns false, it means we have found junctions. In
      // that case, do not delete the folder - Explorer has already an internal
      // list of files it wants to delete, and as the junctions are now unlinked,
      // it might not find all of them and show an error.
      // Instead, we call SHDeleteFolder to instruct Explorer to start the
      // delete operation again
      if (DeleteJunctionsInDirectory(pszSrcFile)) then
      begin
        Result := ID_NO;
        if (FOF_ALLOWUNDO and wFlags) = 0 then
          SHDeleteFolder(Wnd, pszSrcFile, [doSilent])
        else
          SHDeleteFolder(Wnd, pszSrcFile, [doSilent, doAllowUndo])
      end;
end;

{ TCopyHookFactory }

function TCopyHookFactory.GetInstallationData: TExtensionRegistryData;
begin
  Result.RootKey := HKEY_CLASSES_ROOT;
  Result.BaseKey := 'Directory\shellex\CopyHookHandlers\NTFSLink';
  Result.UseGUIDAsKeyName := False;
end;

initialization
  TCopyHookFactory.Create(ComServer, TCopyHook, Class_CopyHook, '',
      'NTFSLink CopyHook Shell Extension', ciMultiInstance, tmApartment);

end.
