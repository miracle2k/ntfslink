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

Please note:
This is /not/ a real shell extension. We use this fake COM object factory to
register the "ShellNew" menu items. It's just the easiest way to do this,
because the Delphi RTL will automatically call the UpdateRegistry() method if
a client calls DllRegisterServer.
-----------------------------------------------------------------------------}

unit ShellNewDummyHook;

interface

uses
  Windows, ComObj, ActiveX;

type
  TShellNewDummyHook = class(TComObject(* no interfaces needed, it's a fake! *))
  end;

  TShellNewDummyFactory = class(TComObjectFactory)
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;

implementation

uses
  ComServ, SysUtils, JclRegistry;

{ TShellNewDummyFactory }

procedure TShellNewDummyFactory.UpdateRegistry(Register: Boolean);

  procedure CreateShellNewStructure(FileExtKey, FileClassKey,
    DllFunctionName, ItemCaption: string; IconIndex: Integer);
  begin
    // Create the file extension key + the "ShellNew" key
    CreateRegKey(FileExtKey, '', FileClassKey, HKEY_CLASSES_ROOT);
    CreateRegKey(FileExtKey + '\ShellNew', 'Command',
                 'rundll32.exe "' + ComServer.ServerFileName + '",' +
                    DLLFunctionName + ' %1',
                 HKEY_CLASSES_ROOT);
    // Create the file class key, + the the icon and a command sub-key
    CreateRegKey(FileClassKey, '', ItemCaption, HKEY_CLASSES_ROOT);
    CreateRegKey(FileClassKey + '\DefaultIcon', '',
                 ComServer.ServerFileName + ',' + IntToStr(IconIndex),
                 HKEY_CLASSES_ROOT);
    CreateRegKey(FileClassKey + '\Shell\Open\Command', '', '.',
                 HKEY_CLASSES_ROOT);
  end;

const
  HARDLINK_FILEEXT_KEY   = '.ntfs-hardlink';
  HARDLINK_FILECLASS_KEY = 'NTFSLink.Hardlink';
  JUNCTION_FILEEXT_KEY   = '.ntfs-junction';
  JUNCTION_FILECLASS_KEY = 'NTFSLink.Junction';
begin
  if Register then
  begin
    CreateShellNewStructure(HARDLINK_FILEEXT_KEY, HARDLINK_FILECLASS_KEY,
                            'NewHardlinkDlg', 'NTFS Hardlink', 0);
    CreateShellNewStructure(JUNCTION_FILEEXT_KEY, JUNCTION_FILECLASS_KEY,
                            'NewJunctionDlg', 'NTFS Junction Point', 1);
  end else
  begin
    try RegDeleteKeyTree(HKEY_CLASSES_ROOT, HARDLINK_FILEEXT_KEY); except end;
    try RegDeleteKeyTree(HKEY_CLASSES_ROOT, HARDLINK_FILECLASS_KEY); except end;
    try RegDeleteKeyTree(HKEY_CLASSES_ROOT, JUNCTION_FILEEXT_KEY); except end;
    try RegDeleteKeyTree(HKEY_CLASSES_ROOT, JUNCTION_FILECLASS_KEY); except end;
  end;
  
  // *NO* inherited call here, it would just make unnecessary registry entries
end;

initialization
  TShellNewDummyFactory.Create(ComServer, TShellNewDummyHook, GUID_NULL, '', '',
      ciMultiInstance, tmApartment);

end.
