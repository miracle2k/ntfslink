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
  NTFSLINK_REGISTRY = 'Software\elsdoerfer.net\NTFSLink\';
  NTFSLINK_CONFIGURATION = NTFSLINK_REGISTRY + 'Config\';

  OVERLAY_JUNCTION_ICONINDEX = 1;
  OVERLAY_HARDLINK_ICONINDEX = 2;

procedure ApproveExtension(ClassIDStr, Description: string);

implementation

procedure ApproveExtension(ClassIDStr, Description: string);
begin
  if (Win32Platform = VER_PLATFORM_WIN32_NT) then
    RegWriteString(HKEY_LOCAL_MACHINE,
       'SOFTWARE\Microsoft\Windows\CurrentVersion\Shell Extensions\Approved',
       ClassIDStr, Description);
end;

end.
