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

unit ColumnHook;

interface

uses          
  Windows, SysUtils, ActiveX, ComObj, ShlObj;

// TODO does a ready-to-use delpi impl. exist?

type
//  typedef struct {
//      ULONG dwFlags;
//      ULONG dwReserved;
//      WCHAR wszFolder[MAX_PATH];
//  } SHCOLUMNINIT, *LPSHCOLUMNINFO;
//
//  IColumnProvider = interface(IUnknown)
//    ['{044BAFB4-45FE-4D5E-BB7C-BC8C388F5F50}']
//    function Initialize(psci: LPCSHCOLUMNINIT): HRESULT;
//    STDMETHOD (GetColumnInfo)(DWORD dwIndex, SHCOLUMNINFO* psci);
//    STDMETHOD (GetItemData)(LPCSHCOLUMNID pscid, LPCSHCOLUMNDATA pscd, 
//                            VARIANT* pvarData);
//  end;

  TColunnHook = class(TComObject)
  end;

  TColumnHookFactory = class(TComObjectFactory)
  public
    procedure UpdateRegistry(Register: Boolean); override;
  end;

const
  Class_ColumnHook: TGUID = '{9B9E4642-8BF2-4AFB-A742-1CD2FD456BE1}';

implementation

uses
  ComServ, JclRegistry, Global;

{ TColumnHookFactory }

procedure TColumnHookFactory.UpdateRegistry(Register: Boolean);
begin
  inherited;

end;

end.
