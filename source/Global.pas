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

unit Global;

interface

uses
  SysUtils, Windows, JclRegistry;

const
  NTFSLINK_REGISTRY = 'Software\elsdoerfer.net\NTFS Link\';
  NTFSLINK_CONFIGURATION = NTFSLINK_REGISTRY + 'Config\';

  OVERLAY_HARDLINK_ICONINDEX = 0;  
  OVERLAY_JUNCTION_ICONINDEX = 1;
  OVERLAY_PRIORITY_DEFAULT = 50;

procedure ApproveExtension(ClassIDStr, Description: string);
function InternalCreateHardlink(Source, Dest: string): boolean;
function InternalCreateJunction(Source, Dest: string): boolean;

implementation

uses
  ShlObj, JclNTFS, GNUGetText;

// ************************************************************************** //

// Return the name of the file/directory to create. This depends on the
// existing files/directories, i.e. if the user creates multiple links
// of the same file, we will enumerate them: Copy(1), Copy(2), etc..
function GetLinkFileName(Source, TargetDir: string; Directory: boolean): string;

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

var
  x: integer;
  LinkStr, NumStr: string;
const
  LinkStrDefault =  'Link%s to %s';
begin
  Result := CheckBackslash(TargetDir) + ExtractFileName(RemoveBackslash(Source));
  x := 0;
  // Loop until we finally find a filename not yet in use
  while ((Directory) and (DirectoryExists(Result))) or
        ((not Directory) and (FileExists(Result))) do
  begin
    Inc(x);

    // Try to get the translated Format-template for the filename
    LinkStr := _(LinkStrDefault);
    // The very first link does not get a number
    if x > 1 then NumStr := ' (' + IntToStr(x) + ')' else NumStr := '';

    // Format the template and use the result as our filename. As the
    // translated template might be invalid, the Format() call might
    // fail. If this is the case, we catch the exception and use
    // the default template.
    try
      Result := CheckBackslash(TargetDir) +
                Format(LinkStr, [NumStr, ExtractFileName(Source)]);
    except
      Result := CheckBackslash(TargetDir) +
                Format(LinkStrDefault, [NumStr, ExtractFileName(Source)]);
    end;
  end;

  // Directories/Junctions require a trailing backslash
  if Directory then
    Result := CheckBackslash(Result);
end;

// ************************************************************************** //

procedure ApproveExtension(ClassIDStr, Description: string);
begin
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
    RegWriteString(HKEY_LOCAL_MACHINE,
       'SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved',
       ClassIDStr, Description);
end;

function InternalCreateHardlink(Source, Dest: string): boolean;
begin
  try
    Result := NtfsCreateHardLink(GetLinkFileName(Source, Dest, False),
                                 PAnsiChar(Source));
    // or ?
    SHChangeNotify(SHCNE_UPDATEITEM, SHCNF_PATH, PAnsiChar(Source), nil);
    SHChangeNotify(SHCNE_CREATE, SHCNF_PATH, PAnsiChar(GetLinkFileName(Source, Dest, False)), nil);
  except
    Result := False;
  end;
end;

// TODO make drive junctions working
function InternalCreateJunction(Source, Dest: string): boolean;
var
  NewDir: string;
begin
  // Calculate name of directory to create
  NewDir := GetLinkFileName(Source, Dest, True);
  // Create an empty directory first
  Result := CreateDir(NewDir);
  // If successful, then try to make a junction
  if Result then begin
    Result := NtfsCreateJunctionPoint(NewDir, Source);
    // if junction creation was unsuccessful, delete created directory  
    if not Result then RemoveDir(NewDir);
  end;
end;

end.
