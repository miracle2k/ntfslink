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

unit JunctionMonitor;

interface

uses
  Windows, Classes;

function GetFolderLinkCount(Folder: string): Integer;
procedure TrackJunction(Junction, Target: string);

implementation

uses
  JclNTFS, Global;

procedure RemoveInvalidTrackingEntries(Folder: string);
begin

end;

procedure GetFolderLinks(Folder: string; Links: TStrings);

  procedure ReadFromStream;
  var
    FindData: TFindStreamData;
  begin
    if NtfsFindFirstStream(Folder, [], FindData) then
    begin
      repeat
         if FindData.Name = 'ntfslink.junction.tracking' then begin
//           FindData.StreamID
         end;
      until not NtfsFindNextStream(FindData);
      NtfsFindStreamClose(FindData);
    end;
  end;

  procedure ReadFromRegistry;
  begin

  end;

begin
  ReadFromStream;
  ReadFromRegistry;

    //go through list and remove invalid
end;

function GetFolderLinkCount(Folder: string): Integer;
var
  LinkList: TStringList;
begin
  Result := 0;
  LinkList := TStringList.Create;
  try
    GetFolderLinks(Folder, LinkList);
    Result := LinkList.Count;
  finally
    LinkList.Free;
  end;
end;

procedure TrackJunction(Junction, Target: string);
var
  Handle: THandle;
  BytesWritten: Cardinal;
  StrToWrite: string;
begin
  Handle := CreateFile(PChar(Target + ':' + NTFSLINK_TRACKING_STREAM),
                       GENERIC_WRITE, // TODO fewer rights possible?
                       0, nil, OPEN_ALWAYS,
                       FILE_FLAG_BACKUP_SEMANTICS,  // TODO other flags that are needed?
                       0);
  if Handle <> 0 then
    try
      SetFilePointer(Handle, 0, nil, FILE_END);
      StrToWrite := Junction + #13#10;
      WriteFile(Handle, StrToWrite, Length(StrToWrite), BytesWritten, nil);
    finally
      CloseHandle(Handle);
    end;
end;

end.
