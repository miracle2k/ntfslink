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

unit BaseExtensionFactory;

interface

uses
  ComObj;

type
  TExtensionRegistryData = record
    RootKey: NativeUInt;
    BaseKey: string;
    UseGUIDAsKeyName: boolean;
  end;

  TBaseExtensionFactory = class(TComObjectFactory)
  protected
    function GetInstallationData: TExtensionRegistryData; virtual; abstract;
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;

implementation

uses
  Global;

{ TBaseExtensionFactory }

procedure TBaseExtensionFactory.UpdateRegistry(Register: Boolean);
var
  ClassIDStr, KeyToCreate: string;
begin
  if Register then
  begin
    inherited UpdateRegistry(Register);

    // Convert ClassID GUID to a string
    ClassIDStr := GUIDToString(ClassId);

    // If UseGUIDAsKeyName equals true, we have to append the GUID to the key
    KeyToCreate := GetInstallationData.BaseKey;
    if GetInstallationData.UseGUIDAsKeyName then
      KeyToCreate := CheckBackslash(KeyToCreate) + ClassIDStr;
    // Register the extension using the key provided by derived classes
    CreateRegKey(KeyToCreate, '', ClassIDStr, GetInstallationData.RootKey);

    // Approve extension (so users with restricted rights may use it too)
    ApproveExtension(ClassIDStr, Description);
  end
  else begin
    // Otherwise delete the extension
    DeleteRegKey(GetInstallationData.BaseKey, GetInstallationData.RootKey);
    inherited UpdateRegistry(Register);
  end;
end;

end.
