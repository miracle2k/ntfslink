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

unit BaseExtensionFactory;

interface

uses
  Windows, ComObj;

type
  TBaseExtensionFactory = class(TComObjectFactory)
  protected
    function GetInstallationKey: string; virtual; abstract;
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;

implementation

uses
  Global;

{ TBaseExtensionFactory }

procedure TBaseExtensionFactory.UpdateRegistry(Register: Boolean);
var
  ClassIDStr: string;
begin
  if Register then
  begin
    inherited UpdateRegistry(Register);

    // Convert ClassID GUID to a string
    ClassIDStr := GUIDToString(ClassId);
    // Register the extension using the key provided by a direved classes
    CreateRegKey(GetInstallationKey, '', ClassIDStr, HKEY_CLASSES_ROOT); 
    // Approve extension (so users with restricted rights may use it too)
    ApproveExtension(ClassIDStr, Description);
  end
  else begin
    // Otherwise delete the extension
    DeleteRegKey(GetInstallationKey);
    inherited UpdateRegistry(Register);
  end;
end;

end.
