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

  NTFSLINK_TRACKING_STREAM = 'ntfslink.junction-tracking';

  OVERLAY_HARDLINK_ICONINDEX = 0;
  OVERLAY_JUNCTION_ICONINDEX = 1;
  OVERLAY_PRIORITY_DEFAULT = 50;

const
  LINK_PREFIX_TEMPLATE_DEFAULT =  'Link%s to %s';
  COPY_PREFIX_TEMPLATE_DEFAULT =  'Copy%s of %s';


// Make certain registry entries to make sure the extension also works for
// non-Admin accounts with restricted rights.
procedure ApproveExtension(ClassIDStr, Description: string);

// Will add a backslash to the end of the passed string, if not yet existing
function CheckBackslash(AFileName: string): string;
// Exactly the opposite: removes the backslash, if it is there
function RemoveBackslash(AFileName: string): string;

// Return the name of the file/directory to create. This depends on the
// existing files/directories, i.e. if the user creates multiple links
// of the same file, we will enumerate them: Copy(1), Copy(2), etc..
function GetLinkFileName(Source, TargetDir: string; Directory: boolean;
  PrefixTemplate: string = LINK_PREFIX_TEMPLATE_DEFAULT): string;

// Internal functions used to create a links
function InternalCreateHardlink(Source, Destination: string): boolean;
function InternalCreateJunctionEx(LinkTarget, Junction: string): boolean;
function InternalCreateJunction(LinkTarget, Junction: string;
  TargetFileName: string = '';  
  PrefixTemplate: string = LINK_PREFIX_TEMPLATE_DEFAULT): boolean;

implementation

uses
  ShlObj, JclNTFS, GNUGetText, JunctionMonitor;

// ************************************************************************** //

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

// ************************************************************************** //

function GetLinkFileName(Source, TargetDir: string; Directory: boolean;
  PrefixTemplate: string = LINK_PREFIX_TEMPLATE_DEFAULT): string;
var
  x: integer;
  SrcFile: string;
  LinkStr, NumStr: string;
begin
  // Get the filename part of the source path. If the source path is a drive,
  // then use the drive letter.
  SrcFile := ExtractFileName(RemoveBackslash(Source));
  if SrcFile = '' then SrcFile := 'Drive ' + ExtractFileDrive(Source)[1];

  // Loop until we finally find a filename not yet in use
  x := 0;
  repeat
    Inc(x);

    // Try to get the translated Format-template for the filename
    LinkStr := _(PrefixTemplate);
    // The very first link does not get a number
    if x > 1 then NumStr := ' (' + IntToStr(x) + ')' else NumStr := '';

    // Format the template and use the result as our filename. As the
    // translated template might be invalid, the Format() call might
    // fail. If this is the case, we catch the exception and use
    // the default template.
    try
      Result := CheckBackslash(TargetDir) + Format(LinkStr, [NumStr, SrcFile]);
    except
      Result := CheckBackslash(TargetDir) + Format(PrefixTemplate, [NumStr, SrcFile]);
    end;
  until ((Directory) and (not DirectoryExists(Result))) or
        ((not Directory) and (not FileExists(Result)));

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

// ************************************************************************** //

function InternalCreateHardlink(Source, Destination: string): boolean;
begin
  try
    Result := NtfsCreateHardLink(GetLinkFileName(Source, Destination, False),
                                 PAnsiChar(Source));
    // TODO correctly notify and set position
    SHChangeNotify(SHCNE_UPDATEITEM, SHCNF_PATH, PAnsiChar(Source), nil);
    SHChangeNotify(SHCNE_CREATE, SHCNF_PATH, PAnsiChar(GetLinkFileName(Source, Destination, False)), nil);
  except
    Result := False;
  end;
end;

// ************************************************************************** //

// TODO comment, to describe differences between these two functions
function InternalCreateJunctionEx(LinkTarget, Junction: string): boolean;
begin
  // Create an empty directory first
  Result := CreateDir(Junction);
  // If successful, then try to make a junction
  if Result then
  begin
    Result := NtfsCreateJunctionPoint(Junction, LinkTarget);
    // if junction creation was unsuccessful, delete created directory  
    if not Result then
      RemoveDir(Junction)
    // otherwise (junction successful created): store the information about the
    // new junction, so that we can later find out about how many junctions are
    // pointing to a certain directory.
    else
      TrackJunction(Junction, LinkTarget);
  end;
end;

function InternalCreateJunction(LinkTarget, Junction: string;
  TargetFileName: string = '';  // see inline comment
  PrefixTemplate: string = LINK_PREFIX_TEMPLATE_DEFAULT): boolean;
var
  NewDir: string;
begin
  // Calculate name of directory to create
  if TargetFileName <> '' then
    // The TargetFileName parameter was added, because this function is
    // called in two different situations. For one, from the DragDrop Hook,
    // were we simply have the source directory we want to link to, and the
    // target directory we want to create the junction in. The second situation
    // is the call from the CopyHook, were we need the directory to link to,
    // the directory were to create the junction, /and/ in addition the
    // filename to use as a template for the junction filename. In the first
    // case, this template filename is identical with the filename of the
    // directory to link to, in the second this is not the case. Therefore,
    // a new parameter, TargetFileName, was added, which will be used as a
    // template. In the second case, we can use "Junction" for that.
    NewDir := GetLinkFileName(TargetFileName, Junction, True, PrefixTemplate)
  else
    NewDir := GetLinkFileName(LinkTarget, Junction, True, PrefixTemplate);

  // Call the sibling function which does create the hardlink, but which takes
  // the final filename of the junction as a parameter
  Result := InternalCreateJunctionEx(LinkTarget, NewDir);
end;

end.
