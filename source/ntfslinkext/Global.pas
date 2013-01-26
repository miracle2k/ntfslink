{-----------------------------------------------------------------------------
The contents of this file are subject to the GNU General Public License
Version 1.1 or later (the "License"); you may not use this file except in
compliance with the License. You may obtain a copy of the License at
http://www.gnu.org/copyleft/gpl.html

Software distributed under the License is distributed on an "AS IS" basis,
WITHOUT WARRANTY OF ANY KIND, either expressed or implied. See the License for
the specific language governing rights and limitations under the License.

The Initial Developer of the Original Code is Michael Elsdörfer, with
contributions from Sebastian Schuberth.

You can find more information at http://elsdoerfer.name/ntfslink
-----------------------------------------------------------------------------}

unit Global;

interface

uses
  SysUtils, Windows, JclRegistry, Constants, System.Classes;

var
  // Handles to various glyphs used in shell menus; initialized at startup.
  GLYPH_HANDLE_STD: HBITMAP;
  GLYPH_HANDLE_JUNCTION: HBITMAP;
  GLYPH_HANDLE_HARDLINK: HBITMAP;
  GLYPH_HANDLE_LINKDEL: HBITMAP;
  GLYPH_HANDLE_EXPLORER: HBITMAP;

// Will add a backslash to the end of the passed string, if not yet existing.
function CheckBackslash(AFileName: string): string;
// Exactly the opposite: removes the backslash, if it is there.
function RemoveBackslash(AFileName: string): string;

// Result depends on configuration - whether to add a "Link to" prefix or not.
function IsLinkPrefixTemplateDisabled: boolean;

// Return the name of the file/directory to create. This depends on the
// existing files/directories, i.e. if the user creates multiple links
// of the same file, we will enumerate them: Copy(1), Copy(2), etc.
function GetLinkFileName(Source, TargetDir: string; Directory: boolean;
  PrefixTemplate: string = LINK_PREFIX_TEMPLATE_DEFAULT): string;

// Creates certain registry entries to make sure the extension also works for
// non-Admin accounts with restricted rights.
procedure ApproveExtension(ClassIDStr, Description: string);

// Internal function used to create hardlinks.
procedure InternalCreateHardlink(Source, Destination: string);
// Calls the one above, but catches all exceptions and returns a boolean.
function InternalCreateHardlinkSafe(Source, Destination: string): boolean;

// Interal functions used to create junctions; the Base-function actually creates
// the junctions using a final directory name, the other one first generates
// the directory name based on a template and a base name (e.g. does the
// "Link (x) of ..."), and then calls InternalCreateJunctionBase().
function InternalCreateJunctionBase(LinkTarget, Junction: string): boolean;
function InternalCreateJunction(LinkTarget, Junction: string;
  TargetDirName: string = '';
  PrefixTemplate: string = LINK_PREFIX_TEMPLATE_DEFAULT): boolean;

// Wrapper around NtfsGetJunctionPointDestinationW(), passing the
// destination as the result, not as a var parameter; in addition, fix some
// issues with the result value of the JCL function, e.g. remove \\?\ prefix.
function GetJPDestination(Folder: string): string;

procedure MaintainHardLinkCmdFile(const Source, Destination: string);
function MatchFileAgainstRecreateHardlinksCmdFile(const AFileName: String;
    ACmds: TStringList; var ASourceLink: String): Integer;
procedure GetHardLinks(AFileName: String; AHardLinks: TStrings);

implementation

uses
  ShlObj, JclNTFS, JclWin32, GNUGetText, JunctionMonitor;

function FindFirstFileNameW(lpFileName : PWideChar; dwFlags : DWORD; var StringLength : DWORD; LinkName : PWideChar) : THandle; stdcall; external 'kernel32.dll';
function FindNextFileNameW(hFindStream : THandle; var StringLength : DWORD; LinkName : PWideChar) : BOOL; stdcall; external 'kernel32.dll';

// ************************************************************************** //


function CheckBackslash(AFileName: string): string;
var
  l: Integer;
begin
  Result := AFileName;
  l := Length(AFileName);
  if (l > 0) and (AFileName[l] <> PathDelim) then
    Result := AFileName + PathDelim;
end;

function RemoveBackslash(AFileName: string): string;
var
  l: Integer;
begin
  Result := AFileName;
  l := Length(AFileName);
  if (l > 0) and (AFileName[l] = PathDelim) then
    Result := Copy(AFileName, 1, l - 1);
end;

// ************************************************************************** //

function IsLinkPrefixTemplateDisabled: boolean;
begin
  Result := RegReadBoolDef(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION,
                          'CreateLinksSuppressPrefix', False);
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

  // Loop until we finally find a filename not yet in use.
  x := 0;
  repeat
    Inc(x);

    // If "Link to" prefix is disabled and this is the first link, then use our
    // "light" template (without a prefix). Otherwise, use the specified template.
    if (x = 1) and (IsLinkPrefixTemplateDisabled) then
      LinkStr := LINK_NO_PREFIX_TEMPLATE
    else
      LinkStr := _(PrefixTemplate);

    // The very first link does not get a number.
    if x > 1 then NumStr := ' (' + IntToStr(x) + ')' else NumStr := '';

    // Format the template and use the result as our filename. As the
    // translated template might be invalid, the Format() call might
    // fail. If this is the case, we catch the exception and use
    // the default template.
    try
      Result := CheckBackslash(TargetDir) + WideFormat(LinkStr, [NumStr, SrcFile]);
    except
      Result := CheckBackslash(TargetDir) + WideFormat(PrefixTemplate, [NumStr, SrcFile]);
    end;
  until ((Directory) and (not DirectoryExists(Result))) or
        ((not Directory) and (not FileExists(Result)));

  // Directories/Junctions require a trailing backslash.
  if Directory then
    Result := CheckBackslash(Result);
end;

// ************************************************************************** //

procedure ApproveExtension(ClassIDStr, Description: string);
begin
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
    RegWritestring(HKEY_LOCAL_MACHINE,
       'SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved',
       ClassIDStr, Description);
end;

// ************************************************************************** //

procedure InternalCreateHardlink(Source, Destination: string);
var
  NewFileName: string;
begin
  NewFileName := GetLinkFileName(Source, Destination, False);
  if not NtfsCreateHardLinkW(NewFileName, Source) then
    raise Exception.Create('NtfsCreateHardLinkW() failed.');

  SHChangeNotify(SHCNE_CREATE, SHCNF_PATHW, PWideChar(NewFileName), nil);
  SHChangeNotify(SHCNE_UPDATEITEM, SHCNF_PATHW, PWideChar(Source), nil);

  if RegReadBoolDef(HKEY_LOCAL_MACHINE, NTFSLINK_CONFIGURATION, 'SetupHardlinksCmdFile', False) then
    MaintainHardLinkCmdFile(Source, NewFileName); 
end;

function InternalCreateHardlinkSafe(Source, Destination: string): boolean;
begin
  try
    InternalCreateHardlink(Source, Destination);
    Result := True;
  except
    Result := False;
  end;
end;

// ************************************************************************** //

function InternalCreateJunctionBase(LinkTarget, Junction: string): boolean;
begin
  // Create an empty directory first; note that we continue if the directory
  // already exists, because this is required when the ContextMenu hook wants
  // to make a junction based on an existing, empty folder.
  Result := CreateDir(Junction) or DirectoryExists(Junction);

  // If successful, then try to create a junction.
  if Result then
  begin
    // Allow to easily override existing junction points with a new target
    // folder: If there is already a junction point, just delete it.
    if GetJPDestination(Junction) <> '' then
      NtfsDeleteJunctionPoint(Junction);

    // Create the junction.
    Result := NtfsCreateJunctionPoint(CheckBackslash(Junction), LinkTarget);

    if not Result then
      // If junction creation was unsuccessful, delete created directory.
      RemoveDir(Junction)
    else
      // Otherwise (junction successful created): store the information about the
      // new junction, so that we can later find out about how many junctions are
      // pointing to a certain directory.
      TrackJunctionCreate(Junction, LinkTarget);

    // Notify explorer of the change.
    SHChangeNotify(SHCNE_CREATE, SHCNF_PATHW, PWideChar(Junction), nil);
  end;
end;

function InternalCreateJunction(LinkTarget, Junction: string;
  TargetDirName: string = '';  // See inline comment.
  PrefixTemplate: string = LINK_PREFIX_TEMPLATE_DEFAULT): boolean;
var
  NewDir: string;
begin
  // Calculate name of directory to create.
  if TargetDirName <> '' then
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
    NewDir := GetLinkFileName(TargetDirName, Junction, True, PrefixTemplate)
  else
    NewDir := GetLinkFileName(LinkTarget, Junction, True, PrefixTemplate);

  // Call the sibling function which creates the hardlink, but which takes
  // the final filename of the junction as a parameter.
  Result := InternalCreateJunctionBase(LinkTarget, NewDir);
end;

// ************************************************************************** //

function GetJPDestination(Folder: string): string;
var
  l: integer;
begin
  // Use JCL utility function to get the target folder.
  NtfsGetJunctionPointDestination(Folder, Result);

  // If a path was returned, make some corrections.
  l := Length(Result);  
  if (l > 0) then
  begin
    // Bug in JCL? There seems to be always a #0 appended.
    if (Result[l]) = #0 then
      Delete(Result, l, 1);
    Result := CheckBackslash(Result);
    // Remove the \\?\ if it exists.
    if Pos('\??\', Result) = 1 then
      Delete(Result, 1, 4);
  end;
end;

procedure MaintainHardLinkCmdFile(const Source, Destination: string);
var
  CmdFileName : string;
  SetupHardLinksScript : TStringList;
  HardLinkIdx : integer;
  CreateHardLinkCode : string;
  SourceLink : string;
begin
  CmdFileName := ExtractFilePath(Destination) + RECREATE_HARDLINKS_FILENAME;
  SetupHardLinksScript := TStringList.Create;
  try
    if FileExists(CmdFileName) then
      SetupHardLinksScript.LoadFromFile(CmdFileName);
    HardLinkIdx := MatchFileAgainstRecreateHardlinksCmdFile(Destination, SetupHardLinksScript, SourceLink);
    CreateHardLinkCode := Format('%s"%s" "%s"', [MKLINK_COMMAND, Destination, Source]);
    if HardLinkIdx >= 0 then
      SetupHardLinksScript[HardLinkIdx] := CreateHardLinkCode
    else
    begin
      SetupHardLinksScript.Add(Format('%s"%s"', [DEL_COMMAND, Destination]));
      SetupHardLinksScript.Add(CreateHardLinkCode);
    end;
    SetupHardLinksScript.SaveToFile(CmdFileName);
  finally
    SetupHardLinksScript.Free;
  end;
end;

function MatchFileAgainstRecreateHardlinksCmdFile(const AFileName: String;
    ACmds: TStringList; var ASourceLink: String): Integer;
var
  i : integer;
  AQuotedFileName : String;
begin
  AQuotedFileName := AnsiQuotedStr(AFileName, '"');
  Result := -1;
  for i := 0 to ACmds.Count - 1 do
    begin
      if (CompareText(system.copy(ACmds[i], 1, length(MKLINK_COMMAND)), MKLINK_COMMAND) = 0) and
         (CompareText(Trim(system.Copy(ACmds[i], length(MKLINK_COMMAND) + 1, length(AQuotedFileName))), AQuotedFileName) = 0) then
        begin
          Result := i;
          ASourceLink := AnsiDequotedStr(system.copy(ACmds[i], length(MKLINK_COMMAND) + length(AQuotedFileName) + 2, length(ACmds[i])), '"');
          break;
        end;
    end;
end;

procedure GetHardLinks(AFileName: String; AHardLinks: TStrings);
const
  DriveLen = 2;
var
  h : THandle;
  ADrive, Link : String;
  Len : DWORD;
  PLink : PWideChar;
  procedure AddHardLinkToList;
  begin
    if Len > 0 then
      AHardLinks.Add(system.Copy(Link, 1, Len + DriveLen));
    Len := MAX_PATH + DriveLen;
  end;
begin
  AFileName := ExpandFileName(AFileName);
  ADrive := ExtractFileDrive(AFileName);
  Len := MAX_PATH + DriveLen;  
  Link := ADrive;
  SetLength(Link, Len);
  PLink := PWideChar(Link);
  inc(PLink, DriveLen); // Let's position the pointer leaving room for drive and colon
  h := FindFirstFileNameW(PWideChar(AFileName), 0, Len, PLink);
  if h = 0 then
    RaiseLastOSError;     
  try    
    AddHardLinkToList;
    while FindNextFileNameW(h, Len, PLink) do
      AddHardLinkToList;
  finally
    Windows.FindClose(h);
  end;
end;

end.
