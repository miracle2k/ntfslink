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

Contains declarations which are not included in the ShlObj.pas version that
ships with Delphi 7.
-----------------------------------------------------------------------------}

unit ShellObjExtended;

interface

uses
  Windows, ShlObj;

const
  IID_IColumnProvider: TGUID = (
    D1: $E8025004; D2: $1C42; D3: $11D2; D4: ($BE, $2C, $0, $A0, $C9, $A8, $3D, $A1));

  SID_IColumnProvider = '{E8025004-1C42-11D2-BE2C-00A0C9A83DA1}';

  FILE_FLAG_OPEN_REPARSE_POINT = $00200000;
                                  
const
  MAX_COLUMN_NAME_LEN = 80;
  MAX_COLUMN_DESC_LEN = 128;

type
  SHCOLUMNINFO = packed record
    scid: SHCOLUMNID;
    vt: integer;
    fmt: DWORD;
    cChars: UINT;
    csFlags: dword;
    wszTitle: array[0..MAX_COLUMN_NAME_LEN - 1] of WideChar;
    wszDescription: array[0..MAX_COLUMN_DESC_LEN - 1] of WideChar;
  end;
  LPSHCOLUMNINFO = ^SHCOLUMNINFO;

  TShColumnInfo = SHCOLUMNINFO;
  PShColumnInfo = LPSHCOLUMNINFO;

  SHCOLUMNINIT = packed record
    dwFlags: ulong;
    dwReserved: ulong;
    wszFolder: array[0..MAX_PATH - 1] of WideChar;
  end;
  LPSHCOLUMNINIT = ^SHCOLUMNINIT;

  TShColumnInit = SHCOLUMNINIT;
  PShColumnInit = LPSHCOLUMNINIT;

const
  SHCDF_UPDATEITEM = $00000001;

type
  SHCOLUMNDATA = packed record
    dwFlags: ULONG;
    dwFileAttributes: DWord;
    dwReserved: ULONG;
    pwszExt: PWideChar;
    wszFile: array[0..MAX_PATH - 1] of WideChar
  end;
  LPSHCOLUMNDATA = ^SHCOLUMNDATA;

  TShColumnData = SHCOLUMNDATA;
  PShColumnData = LPSHCOLUMNDATA;

  IColumnProvider = interface
    [SID_IColumnProvider]
    function Initialize(psci: PSHCOLUMNINIT): HResult; stdcall;
    function GetColumnInfo(dwIndex: DWORD; psci: PSHCOLUMNINFO): HResult; stdcall;
    function GetItemData(pscid: PSHCOLUMNID; pscd: PSHCOLUMNDATA; pvarData: Variant): HResult; stdcall;
  end;

implementation

end.

